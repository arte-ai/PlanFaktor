#!/bin/sh
# check_corpus.sh — corpus lint v1: машинная проверка инвариантов конвейера
# Planfaktor. Источник решений: docs/plans/261111_2243_corpus_lint_ci.md
# (Solution п.1–8, проверки C1–C10, cutoff C4/C5) + docs/plans/
# 261112_0111_route_token_accounting.md (C11 — usage-строки, cutoff
# C3/C8 — секционная версионность).
#
# Это dev-инфраструктура репо, НЕ рантайм конвейера: роли не обязаны звать
# его для маршрутизации, Manager от него не зависит.
#
# POSIX sh + grep/sed/cut/head/tail/mktemp; python и внешние зависимости
# не используются. Временные файлы — только mktemp -d под ${TMPDIR:-/tmp},
# удаляются при любом исходе (trap).
#
# Обычный прогон (из корня репо или по абсолютному пути):
#   scripts/check_corpus.sh
#   вывод: `OK Cn <имя>` на проверку (C4/C5/C11 печатают `excluded`-планы),
#   `FAIL Cn <имя>: <детали>` при дефекте, итог `corpus: clean` либо
#   `corpus: N failures`; exit 0 только при clean.
#
# Selftest:
#   scripts/check_corpus.sh --selftest
#   строит в ${TMPDIR:-/tmp} копии корпуса, подсаживает по одному дефекту
#   на каждый класс C1–C11 и проверяет, что каждая проверка ловит свой
#   дефект; итог `selftest: N/12 caught`; exit 0 только при 12/12.

set -u

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

# Cutoff форматов C4/C5/C7-шапки: до 261111_1455 правила были другими,
# а append-only (конституция §5) запрещает правку истории.
CUTOFF=261111_1455

# Cutoff секции `## Token usage` и формата usage-строк C11: секция введена
# планом 261112_0111, более ранние планы её не имеют и не обязаны.
USAGE_CUTOFF=261112_0111

# Канонические формы usage-строк (план 261112_0111, Solution п.1/п.4).
# Детектор в C11 — с якорем `^- <TS> — usage: `: без якоря ловятся
# примеры формата в прозе/комментариях.
USAGE_DISPATCH_RE='^- [0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2} — usage: (architect|planner|coder|reviewer-risk|reviewer-contracts)\.(work|censor|r[0-9]+) ([0-9]+|unknown \(why=[^)]*\)) tokens — (dispatch|sendmessage|unknown)$'
USAGE_CHECKPOINT_RE='^- [0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2} — usage: manager-context checkpoint ~[0-9]+ tokens-left — approximate$'

# Замороженный список обязательных секций плана: 13 секций шаблона
# docs/plans/_template.md на момент плана 261111_2243 (cutoff-версионность
# C3/C8, план 261112_0111). Обязательны ВСЕМ планам независимо от возраста;
# живой шаблон не источник обязательности — только индикатор
# консистентности (см. check_c3).
FROZEN_SECTIONS='## Как я понял задачу
## Problem
## Solution / Decisions
## Scope
## Out of scope
## Acceptance criteria / DoD
## Tests / Commands
## Changes (by area)
## Evidence (chronological, append-only)
## Q&A log (chronological, append-only)
## Suggestions log (chronological, append-only)
## Objections log (chronological, append-only)
## Follow-ups (deferred)'

# Секции, добавленные в шаблон ПОЗЖЕ замороженного списка: запись
# `<заголовок>|<Plan ID вводящего плана>`; секция обязательна только
# планам с Plan ID >= cutoff. Новые секции шаблона вносятся сюда —
# иначе check_c3 FAIL (шаблон без записи = рассинхрон носителя и линта).
SECTION_CUTOFF='## Token usage (append-only)|261112_0111'

# ---------------------------------------------------------------- helpers

# sect_body <file> <header-prefix> — тело секции на stdout: от строки
# `^## <header-prefix>` (исключая её) до следующего `^## ` или EOF.
sect_body() {
    _sb_f=$1
    _sb_h=$2
    _sb_start=$(grep -n "^## $_sb_h" "$_sb_f" | head -n 1 | cut -d: -f1)
    [ -n "$_sb_start" ] || return 1
    { tail -n +"$((_sb_start + 1))" "$_sb_f"
      printf '\n## __lint_section_end__\n'
    } | sed -n '1,/^## /p' | sed '$d'
}

# first_plan <corpus> — первый (лексикографически) план [0-9]*.md.
first_plan() {
    for _fp_f in "$1"/docs/plans/[0-9]*.md; do
        if [ -f "$_fp_f" ]; then printf '%s\n' "$_fp_f"; return 0; fi
    done
    return 1
}

# plan_prefix <basename> — префикс Plan ID `YYMMDD_HHMM` из имени файла
# (два первых подчёрк-разделённых сегмента; дальше — тема).
plan_prefix() {
    _pp_a=${1%%_*}
    _pp_rest=${1#*_}
    _pp_b=${_pp_rest%%_*}
    printf '%s_%s' "$_pp_a" "$_pp_b"
}

# post_cutoff_plan_with <corpus> <cutoff> <ERE> — первый план с префиксом
# >= <cutoff>, в котором есть строка, матчащая <ERE>.
post_cutoff_plan_with() {
    for _pc_f in "$1"/docs/plans/[0-9]*.md; do
        [ -f "$_pc_f" ] || continue
        _pc_pid=$(plan_prefix "$(basename "$_pc_f")")
        if [ "$_pc_pid" \< "$2" ]; then continue; fi
        if grep -qE "$3" "$_pc_f"; then printf '%s\n' "$_pc_f"; return 0; fi
    done
    return 1
}

# section_cutoff_of <header> — cutoff Plan ID секции из SECTION_CUTOFF
# (stdout) либо rc=1, если секция не в таблице.
section_cutoff_of() {
    while IFS='|' read -r _sc_hdr _sc_cut; do
        [ -n "$_sc_hdr" ] || continue
        if [ "$_sc_hdr" = "$1" ]; then printf '%s\n' "$_sc_cut"; return 0; fi
    done <<EOF
$SECTION_CUTOFF
EOF
    return 1
}

# mutate <file> <sed-script> — применить sed к файлу на месте без `sed -i`
# (POSIX: -i непортативен между BSD/GNU).
mutate() {
    sed "$2" "$1" > "$1.lintmut" && mv "$1.lintmut" "$1"
}

# ------------------------------------------------------------- checks C1-C10

# C1: каждый план имеет ровно одну строку `^**Status:**` из 9 допустимых
# значений конституции §2.
check_c1() {
    _c1_corpus=$1
    _c1_rc=0
    for _c1_f in "$_c1_corpus"/docs/plans/[0-9]*.md; do
        [ -f "$_c1_f" ] || continue
        _c1_valid=$(grep -cE '^\*\*Status:\*\* (Draft|Ready for Planner|Planning|Ready for Coder|In progress|In review|Merged|Done|Superseded)[[:space:]]*$' "$_c1_f" || true)
        _c1_total=$(grep -c '^\*\*Status:\*\*' "$_c1_f" || true)
        if [ "$_c1_valid" -ne 1 ] || [ "$_c1_total" -ne 1 ]; then
            printf '%s: status lines total=%s valid=%s (want exactly 1 of 9 allowed)\n' \
                "${_c1_f#$_c1_corpus/}" "$_c1_total" "$_c1_valid"
            _c1_rc=1
        fi
    done
    return $_c1_rc
}

# C2: `^**Plan ID:** YYMMDD_HHMM` — ровно один, значение совпадает
# с префиксом имени файла.
check_c2() {
    _c2_corpus=$1
    _c2_rc=0
    for _c2_f in "$_c2_corpus"/docs/plans/[0-9]*.md; do
        [ -f "$_c2_f" ] || continue
        _c2_base=$(basename "$_c2_f" .md)
        _c2_prefix=$(plan_prefix "$_c2_base")
        _c2_cnt=$(grep -c '^\*\*Plan ID:\*\*' "$_c2_f" || true)
        _c2_got=$(sed -n 's/^\*\*Plan ID:\*\* //p' "$_c2_f" | head -n 1)
        if [ "$_c2_cnt" -ne 1 ] \
           || ! printf '%s\n' "$_c2_got" | grep -qE '^[0-9]{6}_[0-9]{4}$' \
           || [ "$_c2_got" != "$_c2_prefix" ]; then
            printf '%s: Plan ID line "%s" (want %s), count=%s\n' \
                "${_c2_f#$_c2_corpus/}" "${_c2_got:-<none>}" "$_c2_prefix" "$_c2_cnt"
            _c2_rc=1
        fi
    done
    return $_c2_rc
}

# C3: обязательные секции планов — cutoff-версионность (план 261112_0111):
# каждому плану обязателен замороженный список FROZEN_SECTIONS (13 секций
# шаблона на момент 261111_2243) плюс секции SECTION_CUTOFF, чей cutoff
# <= Plan ID плана («замороженный список ⊇ + per-section cutoff», а не
# равенство живому шаблону). Заголовок обязательной секции матчится
# ТОЧНОЙ строкой (`grep -qxF`, якорь всей строки): упоминание заголовка
# в prose/код-спанах проверку не удовлетворяет (review 261112_0111
# Round 1, finding 1). Консистентность носителя и линта: шаблон
# обязан содержать все замороженные секции; каждая секция шаблона сверх
# замороженного списка обязана иметь запись в SECTION_CUTOFF; записи
# SECTION_CUTOFF обязаны существовать в шаблоне (иначе проверка молча
# деградирует при расширении шаблона).
check_c3() {
    _c3_corpus=$1
    _c3_rc=0
    _c3_tmpl=$_c3_corpus/docs/plans/_template.md
    if [ ! -f "$_c3_tmpl" ]; then
        printf 'docs/plans/_template.md: missing\n'
        return 1
    fi
    # 1) шаблон ⊇ замороженный список.
    while IFS= read -r _c3_sec; do
        [ -n "$_c3_sec" ] || continue
        if ! grep -qxF "$_c3_sec" "$_c3_tmpl"; then
            printf 'docs/plans/_template.md: frozen section missing from template: %s\n' "$_c3_sec"
            _c3_rc=1
        fi
    done <<EOF
$FROZEN_SECTIONS
EOF
    # 2) каждая запись SECTION_CUTOFF существует в шаблоне.
    while IFS='|' read -r _c3_hdr _c3_cut; do
        [ -n "$_c3_hdr" ] || continue
        if ! grep -qxF "$_c3_hdr" "$_c3_tmpl"; then
            printf 'docs/plans/_template.md: SECTION_CUTOFF record without template section: %s\n' "$_c3_hdr"
            _c3_rc=1
        fi
    done <<EOF
$SECTION_CUTOFF
EOF
    # 3) каждая секция шаблона — замороженная либо с записью cutoff.
    while IFS= read -r _c3_tsec; do
        [ -n "$_c3_tsec" ] || continue
        if printf '%s\n' "$FROZEN_SECTIONS" | grep -qxF "$_c3_tsec"; then
            continue
        fi
        if ! section_cutoff_of "$_c3_tsec" > /dev/null; then
            printf 'docs/plans/_template.md: template section outside frozen list lacks SECTION_CUTOFF record: %s\n' "$_c3_tsec"
            _c3_rc=1
        fi
    done <<EOF
$(grep '^## ' "$_c3_tmpl")
EOF
    # 4) планам — обязательные секции по возрасту (точная строка, якорь).
    for _c3_f in "$_c3_corpus"/docs/plans/[0-9]*.md; do
        [ -f "$_c3_f" ] || continue
        _c3_pid=$(plan_prefix "$(basename "$_c3_f")")
        _c3_req=$FROZEN_SECTIONS
        while IFS='|' read -r _c3_hdr _c3_cut; do
            [ -n "$_c3_hdr" ] || continue
            if ! [ "$_c3_pid" \< "$_c3_cut" ]; then
                _c3_req="$_c3_req
$_c3_hdr"
            fi
        done <<EOF
$SECTION_CUTOFF
EOF
        while IFS= read -r _c3_sec; do
            [ -n "$_c3_sec" ] || continue
            if ! grep -qxF "$_c3_sec" "$_c3_f"; then
                printf '%s: missing template section: %s\n' \
                    "${_c3_f#$_c3_corpus/}" "$_c3_sec"
                _c3_rc=1
            fi
        done <<EOF
$_c3_req
EOF
    done
    return $_c3_rc
}

# C4 (cutoff >= 261111_1455, скоуп — секция ## Evidence): строки-маркеры
# формы `(Role CENSOR) (OK|FAIL):` обязаны нести префикс
# `- YYYY-MM-DD HH:MM:SS — `; в блоке после валидного маркера —
# `Censor dispatch id: censor:<role>:<YYMMDD_HHMMSS>` и
# `Final censor verdict: (OK|FAIL)` (толерантно к отступам/дефису списка).
check_c4() {
    _c4_corpus=$1
    _c4_rc=0
    for _c4_f in "$_c4_corpus"/docs/plans/[0-9]*.md; do
        [ -f "$_c4_f" ] || continue
        _c4_pid=$(plan_prefix "$(basename "$_c4_f")")
        if [ "$_c4_pid" \< "$CUTOFF" ]; then
            printf '%s: excluded (pre-cutoff %s < %s)\n' \
                "${_c4_f#$_c4_corpus/}" "$_c4_pid" "$CUTOFF"
            continue
        fi
        _c4_ev=$(sect_body "$_c4_f" 'Evidence') || continue
        [ -n "$_c4_ev" ] || continue
        # 1) маркер без префикса метки времени (класс 261111_0427).
        if _c4_bad=$(printf '%s\n' "$_c4_ev" | grep -nE '^\(Role CENSOR\) (OK|FAIL):'); then
            printf '%s: receipt marker(s) without timestamp prefix:\n' \
                "${_c4_f#$_c4_corpus/}"
            printf '%s\n' "$_c4_bad" | sed 's/^/  /'
            _c4_rc=1
        fi
        # 2) блок валидного маркера: dispatch id + final verdict.
        _c4_open=0
        _c4_idx=0
        _c4_have_id=0
        _c4_have_v=0
        _c4_block_rc=0
        while IFS= read -r _c4_line; do
            if printf '%s\n' "$_c4_line" | grep -qE \
                '^- [0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2} — \(Role CENSOR\) (OK|FAIL):'
            then
                if [ "$_c4_open" -eq 1 ] \
                   && { [ "$_c4_have_id" -eq 0 ] || [ "$_c4_have_v" -eq 0 ]; }; then
                    printf '%s: receipt #%s incomplete (dispatch id=%s, final verdict=%s)\n' \
                        "${_c4_f#$_c4_corpus/}" "$_c4_idx" "$_c4_have_id" "$_c4_have_v"
                    _c4_block_rc=1
                fi
                _c4_open=1
                _c4_idx=$((_c4_idx + 1))
                _c4_have_id=0
                _c4_have_v=0
            elif printf '%s\n' "$_c4_line" | grep -qE \
                '^[-[:space:]]*Censor dispatch id: censor:(architect|planner|coder):[0-9]{6}_[0-9]{6}[[:space:]]*$'
            then
                [ "$_c4_open" -eq 1 ] && _c4_have_id=1
            elif printf '%s\n' "$_c4_line" | grep -qE \
                '^[-[:space:]]*Final censor verdict: (OK|FAIL)[[:space:]]*$'
            then
                [ "$_c4_open" -eq 1 ] && _c4_have_v=1
            fi
        done <<EOF
$_c4_ev
EOF
        if [ "$_c4_open" -eq 1 ] \
           && { [ "$_c4_have_id" -eq 0 ] || [ "$_c4_have_v" -eq 0 ]; }; then
            printf '%s: receipt #%s incomplete (dispatch id=%s, final verdict=%s)\n' \
                "${_c4_f#$_c4_corpus/}" "$_c4_idx" "$_c4_have_id" "$_c4_have_v"
            _c4_block_rc=1
        fi
        _c4_rc=$((_c4_rc + _c4_block_rc))
    done
    return $_c4_rc
}

# C5 (cutoff >= 261111_1455, скоуп — секция ## Q&A log): строки
# `Intake (...)` обязаны иметь форму
# `- Intake (YYYY-MM-DD HH:MM:SS): AGENTS.md@<8hex> <role>.md@<8hex>`
# с ролью из 5 субагентных; строки-плейсхолдеры `<!-- ... -->` исключаются.
check_c5() {
    _c5_corpus=$1
    _c5_rc=0
    for _c5_f in "$_c5_corpus"/docs/plans/[0-9]*.md; do
        [ -f "$_c5_f" ] || continue
        _c5_pid=$(plan_prefix "$(basename "$_c5_f")")
        if [ "$_c5_pid" \< "$CUTOFF" ]; then
            printf '%s: excluded (pre-cutoff %s < %s)\n' \
                "${_c5_f#$_c5_corpus/}" "$_c5_pid" "$CUTOFF"
            continue
        fi
        _c5_qa=$(sect_body "$_c5_f" 'Q&A log') || continue
        [ -n "$_c5_qa" ] || continue
        while IFS= read -r _c5_line; do
            case $_c5_line in
                *'<!--'*) continue ;;
            esac
            printf '%s\n' "$_c5_line" | grep -qE 'Intake \(' || continue
            if printf '%s\n' "$_c5_line" | grep -qE \
                '^- Intake \([0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\): AGENTS\.md@[0-9A-Fa-f]{8} (architect|planner|coder|reviewer-risk|reviewer-contracts)\.md@[0-9A-Fa-f]{8}[[:space:]]*$'
            then
                :
            else
                printf '%s: malformed intake line: %s\n' \
                    "${_c5_f#$_c5_corpus/}" "$_c5_line"
                _c5_rc=1
            fi
        done <<EOF
$_c5_qa
EOF
    done
    return $_c5_rc
}

# C6: `@`-хвосты digest'ов в планах — ровно 8 hex-символов; литеральный
# плейсхолдер `@8hex` (и `@<8hex>`) вырезается до проверки. Ловит только
# формовые нарушения; value-опечатки — v2 (Out of scope п.1 плана).
check_c6() {
    _c6_corpus=$1
    _c6_rc=0
    for _c6_f in "$_c6_corpus"/docs/plans/[0-9]*.md; do
        [ -f "$_c6_f" ] || continue
        for _c6_d in $(sed 's/@8hex/@/g' "$_c6_f" | grep -oE '@[0-9A-Fa-f]+' | sort -u || true); do
            _c6_h=${_c6_d#@}
            if [ "${#_c6_h}" -ne 8 ]; then
                printf '%s: digest %s has %s hex chars (want 8)\n' \
                    "${_c6_f#$_c6_corpus/}" "$_c6_d" "${#_c6_h}"
                _c6_rc=1
            fi
        done
    done
    return $_c6_rc
}

# C7: review-артефакты — ровно одна строка `^**Round:** N`; вердикт-строки
# `### (Risk|Contracts) verdict: pass|needs-fix` (опц. `— superseded
# (round M)`); каждый числовой лейбл `superseded (round M)` — с M, равным
# текущему Round; `**Created:**` и `**Round k started:**` (k = 2..N)
# требуются только у артефактов >= cutoff.
check_c7() {
    _c7_corpus=$1
    _c7_rc=0
    for _c7_f in "$_c7_corpus"/docs/reviews/[0-9]*.md; do
        [ -f "$_c7_f" ] || continue
        _c7_rel=${_c7_f#$_c7_corpus/}
        _c7_pid=$(plan_prefix "$(basename "$_c7_f")")
        _c7_rounds=$(sed -n 's/^\*\*Round:\*\* //p' "$_c7_f")
        _c7_n=$(printf '%s\n' "$_c7_rounds" | grep -cE '^[0-9]+$' || true)
        _c7_round=$(printf '%s\n' "$_c7_rounds" | head -n 1)
        if [ "$_c7_n" -ne 1 ] || [ -z "$_c7_round" ]; then
            printf '%s: **Round:** lines=%s (want exactly 1)\n' \
                "$_c7_rel" "$_c7_n"
            _c7_rc=1
            continue
        fi
        while IFS= read -r _c7_v; do
            [ -n "$_c7_v" ] || continue
            if ! printf '%s\n' "$_c7_v" | grep -qE \
                '^### (Risk|Contracts) verdict: (pass|needs-fix)( — superseded \(round [0-9]+\))?[[:space:]]*$'
            then
                printf '%s: malformed verdict line: %s\n' "$_c7_rel" "$_c7_v"
                _c7_rc=1
            fi
        done <<EOF
$(grep -E '^### (Risk|Contracts) verdict:' "$_c7_f" || true)
EOF
        _c7_lbls=$(grep -oE 'superseded \(round [0-9]+\)' "$_c7_f" | sort -u || true)
        while IFS= read -r _c7_lbl; do
            [ -n "$_c7_lbl" ] || continue
            _c7_m=${_c7_lbl##*round }
            _c7_m=${_c7_m%)}
            if [ "$_c7_m" != "$_c7_round" ]; then
                printf '%s: superseded label "%s" != current Round %s\n' \
                    "$_c7_rel" "$_c7_lbl" "$_c7_round"
                _c7_rc=1
            fi
        done <<EOF
$_c7_lbls
EOF
        if [ "$_c7_pid" \< "$CUTOFF" ]; then
            :
        else
            if ! grep -q '^\*\*Created:\*\* ' "$_c7_f"; then
                printf '%s: missing **Created:** header\n' "$_c7_rel"
                _c7_rc=1
            fi
            _c7_k=2
            while [ "$_c7_k" -le "$_c7_round" ]; do
                if ! grep -q "^\*\*Round $_c7_k started:\*\* " "$_c7_f"; then
                    printf '%s: missing **Round %s started:** header\n' \
                        "$_c7_rel" "$_c7_k"
                    _c7_rc=1
                fi
                _c7_k=$((_c7_k + 1))
            done
        fi
    done
    return $_c7_rc
}

# C8: каждая `##`-секция несёт `<!-- owner:` на следующей строке —
# в обоих шаблонах (структура) и в планах (фактические файлы).
# Cutoff-версионность (план 261112_0111), симметрично C3: секция
# SECTION_CUTOFF, чей cutoff > Plan ID плана, этому плану не обязательна
# (ни наличием — C3, ни owner-меткой — C8); прочие секции планов и все
# секции шаблонов метку несут обязательно (строгость не ниже прежней).
check_c8() {
    _c8_corpus=$1
    _c8_rc=0
    for _c8_f in "$_c8_corpus"/docs/plans/_template.md \
                 "$_c8_corpus"/docs/reviews/_template_review.md
    do
        [ -f "$_c8_f" ] || continue
        _c8_check_one "$_c8_corpus" "$_c8_f" '' || _c8_rc=1
    done
    for _c8_f in "$_c8_corpus"/docs/plans/[0-9]*.md; do
        [ -f "$_c8_f" ] || continue
        _c8_pid=$(plan_prefix "$(basename "$_c8_f")")
        _c8_check_one "$_c8_corpus" "$_c8_f" "$_c8_pid" || _c8_rc=1
    done
    return $_c8_rc
}

# _c8_check_one <corpus> <file> <pid|''> — owner-метки всех секций файла;
# <pid> пуст для шаблонов (без cutoff-пропуска); печатает все нарушения.
_c8_check_one() {
    _c8o_corpus=$1
    _c8o_f=$2
    _c8o_pid=$3
    _c8o_rc=0
    for _c8o_ln in $(grep -n '^## ' "$_c8o_f" | cut -d: -f1); do
        _c8o_next=$(sed -n "$((_c8o_ln + 1))p" "$_c8o_f")
        case $_c8o_next in
            '<!-- owner:'*) continue ;;
        esac
        if [ -n "$_c8o_pid" ]; then
            _c8o_hdr=$(sed -n "${_c8o_ln}p" "$_c8o_f")
            if _c8o_cut=$(section_cutoff_of "$_c8o_hdr") \
               && [ "$_c8o_pid" \< "$_c8o_cut" ]; then
                continue
            fi
        fi
        printf '%s: section at line %s lacks owner marker: %s\n' \
            "${_c8o_f#$_c8o_corpus/}" "$_c8o_ln" \
            "$(sed -n "${_c8o_ln}p" "$_c8o_f")"
        _c8o_rc=1
    done
    return $_c8o_rc
}

# C9: относительные пути `docs/…`/`.zcode/…` из README, AGENTS.md,
# роль-доков и команд существуют; плейсхолдеры allowlist'а пропускаются
# (кириллические `docs/plans/<файл>` и `docs/roles/<роль>.md` обрезаются
# токенизатором до `docs/<dir>/<`); слэш-команды `/planfaktor-*` требуют
# `.zcode/commands/<имя>.md`. Glob-паттерн `docs/plans/[0-9]*.md`
# токенизатором обрезается до существующего каталога `docs/plans/`
# (квадратные скобки не входят в алфавит пути-токена).
check_c9() {
    _c9_corpus=$1
    _c9_rc=0
    for _c9_src in "$_c9_corpus/README.md" "$_c9_corpus/AGENTS.md" \
                   "$_c9_corpus"/docs/roles/*.md \
                   "$_c9_corpus"/.zcode/commands/*.md
    do
        [ -f "$_c9_src" ] || continue
        _c9_rel=${_c9_src#$_c9_corpus/}
        for _c9_tok in $(grep -hoE '(docs|\.zcode)/[A-Za-z0-9_./<>*]+' "$_c9_src" | sort -u || true); do
            case $_c9_tok in
                'docs/plans/YYMMDD_HHMM_topic.md' \
                |'docs/plans/<PlanID>_<topic>.md' \
                |'docs/reviews/<PlanID>_review.md' \
                |'docs/roles/<role>.md' \
                |'docs/plans/[0-9]*.md' \
                |'docs/plans/<' \
                |'docs/roles/<')
                    continue
                    ;;
                *planfaktor-*\**.md)
                    # glob-плейсхолдер planfaktor-*.md (в т.ч. с префиксом каталога)
                    continue
                    ;;
            esac
            if [ -e "$_c9_corpus/$_c9_tok" ]; then
                :
            else
                printf '%s: dangling path %s\n' "$_c9_rel" "$_c9_tok"
                _c9_rc=1
            fi
        done
        for _c9_cmd in $(grep -hoE '/planfaktor-[a-z-]+' "$_c9_src" | sort -u || true); do
            if [ -f "$_c9_corpus/.zcode/commands/${_c9_cmd#/}.md" ]; then
                :
            else
                printf '%s: slash command %s lacks .zcode/commands/%s.md\n' \
                    "$_c9_rel" "$_c9_cmd" "${_c9_cmd#/}"
                _c9_rc=1
            fi
        done
    done
    return $_c9_rc
}

# C10: 5 субагентных ролей §1 ↔ 5 docs/roles/*.md ↔ 5 .zcode/agents/planfaktor-*.md
# (Owner и Manager — не субагенты, файлов не имеют).
check_c10() {
    _c10_corpus=$1
    _c10_rc=0
    _c10_want='architect
coder
planner
reviewer-contracts
reviewer-risk'
    # Служебные носители (_-префикс и index) — не роль-доки, из сверки исключены.
    _c10_roles=$(ls "$_c10_corpus/docs/roles" 2>/dev/null | sed -n 's/\.md$//p' | grep -vE '^_|^index$' | sort)
    _c10_agents=$(ls "$_c10_corpus/.zcode/agents" 2>/dev/null | sed -n 's/^planfaktor-\(.*\)\.md$/\1/p' | sort)
    if [ "$_c10_roles" != "$_c10_want" ]; then
        printf 'docs/roles: got [%s] want [architect coder planner reviewer-contracts reviewer-risk]\n' \
            "$(printf '%s ' $_c10_roles)"
        _c10_rc=1
    fi
    if [ "$_c10_agents" != "$_c10_want" ]; then
        printf '.zcode/agents: got [%s] want [architect coder planner reviewer-contracts reviewer-risk]\n' \
            "$(printf '%s ' $_c10_agents)"
        _c10_rc=1
    fi
    return $_c10_rc
}

# C11 (cutoff >= 261112_0111, скоуп — секция ## Token usage): строки
# с якорем `^- <TS> — usage: ` — ровно две канонические формы: dispatch
# (роль.пасс из множеств, N — целое либо `unknown (why=...)`, источник из
# {dispatch|sendmessage|unknown}) и checkpoint (manager-context).
# Отсутствие секции у плана >= cutoff ловит C3 (необязательность — зона
# cutoff-версионности), здесь — только формат присутствующих строк.
# Осознанная асимметрия (review 261112_0111 Round 1, finding 3): скоуп —
# только тело секции; usage-строка, ошибочно записанная вне её (например,
# в ## Evidence), этим линтом не контролируется, но агрегатор
# /planfaktor-status (шаги 6–7) грепает файл плана целиком и посчитает её.
# Дисциплина записи (§1(f) AGENTS.md): usage-строки — исключительно
# в секции ## Token usage.
check_c11() {
    _c11_corpus=$1
    _c11_rc=0
    for _c11_f in "$_c11_corpus"/docs/plans/[0-9]*.md; do
        [ -f "$_c11_f" ] || continue
        _c11_pid=$(plan_prefix "$(basename "$_c11_f")")
        if [ "$_c11_pid" \< "$USAGE_CUTOFF" ]; then
            printf '%s: excluded (pre-usage-cutoff %s < %s)\n' \
                "${_c11_f#$_c11_corpus/}" "$_c11_pid" "$USAGE_CUTOFF"
            continue
        fi
        _c11_tu=$(sect_body "$_c11_f" 'Token usage') || continue
        [ -n "$_c11_tu" ] || continue
        while IFS= read -r _c11_line; do
            case $_c11_line in
                *'<!--'*) continue ;;
            esac
            printf '%s\n' "$_c11_line" | grep -qE \
                '^- [0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2} — usage: ' \
                || continue
            if printf '%s\n' "$_c11_line" | grep -qE \
                -e "$USAGE_DISPATCH_RE" -e "$USAGE_CHECKPOINT_RE"
            then
                :
            else
                printf '%s: malformed usage line: %s\n' \
                    "${_c11_f#$_c11_corpus/}" "$_c11_line"
                _c11_rc=1
            fi
        done <<EOF
$_c11_tu
EOF
    done
    return $_c11_rc
}

# ------------------------------------------------------------------ report

# report <id> <name> <corpus> <func> — печать `OK/FAIL Cn name(: details)`
# и info-строки проверки (excluded) с отступом; rc проверки наружу.
report() {
    _rp_id=$1
    _rp_name=$2
    _rp_corpus=$3
    _rp_fn=$4
    _rp_out=$($_rp_fn "$_rp_corpus" 2>&1)
    _rp_rc=$?
    if [ "$_rp_rc" -eq 0 ]; then
        printf 'OK %s %s\n' "$_rp_id" "$_rp_name"
        if [ -n "$_rp_out" ]; then
            printf '%s\n' "$_rp_out" | sed 's/^/  /'
        fi
    else
        _rp_first=$(printf '%s\n' "$_rp_out" | head -n 1)
        printf 'FAIL %s %s: %s\n' "$_rp_id" "$_rp_name" "$_rp_first"
        if [ -n "$_rp_out" ]; then
            _rp_n=$(printf '%s\n' "$_rp_out" | sed -n '$=')
            if [ "$_rp_n" -gt 1 ]; then
                printf '%s\n' "$_rp_out" | tail -n +2 | sed 's/^/  /'
            fi
        fi
    fi
    return "$_rp_rc"
}

# run_all <corpus> — прогон C1–C11; rc = число проваленных проверок.
run_all() {
    _ra_corpus=$1
    _ra_fails=0
    report C1 statuses             "$_ra_corpus" check_c1  || _ra_fails=$((_ra_fails + 1))
    report C2 plan-id-vs-filename  "$_ra_corpus" check_c2  || _ra_fails=$((_ra_fails + 1))
    report C3 plan-sections        "$_ra_corpus" check_c3  || _ra_fails=$((_ra_fails + 1))
    report C4 censor-receipts      "$_ra_corpus" check_c4  || _ra_fails=$((_ra_fails + 1))
    report C5 intake-lines         "$_ra_corpus" check_c5  || _ra_fails=$((_ra_fails + 1))
    report C6 digest-format        "$_ra_corpus" check_c6  || _ra_fails=$((_ra_fails + 1))
    report C7 review-artifacts     "$_ra_corpus" check_c7  || _ra_fails=$((_ra_fails + 1))
    report C8 owner-markers        "$_ra_corpus" check_c8  || _ra_fails=$((_ra_fails + 1))
    report C9 link-integrity       "$_ra_corpus" check_c9  || _ra_fails=$((_ra_fails + 1))
    report C10 roles-vs-agents     "$_ra_corpus" check_c10 || _ra_fails=$((_ra_fails + 1))
    report C11 token-usage-lines   "$_ra_corpus" check_c11 || _ra_fails=$((_ra_fails + 1))
    return $_ra_fails
}

# ----------------------------------------------------------------- selftest

# seed_corpus <dir> — свежая копия корпуса для подсадки дефектов.
seed_corpus() {
    mkdir -p "$1"
    cp -R "$ROOT/docs" "$1/docs"
    cp -R "$ROOT/.zcode" "$1/.zcode"
    cp "$ROOT/README.md" "$ROOT/AGENTS.md" "$1/"
}

selftest() {
    _st_base=$(mktemp -d "${TMPDIR:-/tmp}/check_corpus_selftest.XXXXXXXX")
    trap 'rm -rf "$_st_base"' 0
    trap 'rm -rf "$_st_base"; exit 1' HUP INT TERM

    # Baseline: чистая копия корпуса обязана проходить все проверки;
    # иначе selftest сам сломан и подсевать дефекты бессмысленно.
    seed_corpus "$_st_base/base"
    _st_bad=0
    for _st_fn in check_c1 check_c2 check_c3 check_c4 check_c5 \
                  check_c6 check_c7 check_c8 check_c9 check_c10 check_c11
    do
        if ! "$_st_fn" "$_st_base/base" > /dev/null 2>&1; then
            printf 'selftest baseline: %s fails on clean corpus copy\n' "$_st_fn"
            _st_bad=1
        fi
    done
    if [ "$_st_bad" -ne 0 ]; then
        printf 'selftest: baseline failed\n'
        return 1
    fi

    _st_caught=0
    _st_total=12

    # C1: недопустимое значение статуса.
    _st_dir=$_st_base/c1
    seed_corpus "$_st_dir"
    _st_plan=$(first_plan "$_st_dir")
    mutate "$_st_plan" 's/^\*\*Status:\*\* .*/**Status:** NotAStatus/'
    if check_c1 "$_st_dir" > /dev/null 2>&1; then
        printf 'MISSED C1\n'
    else
        printf 'caught C1\n'
        _st_caught=$((_st_caught + 1))
    fi

    # C2: Plan ID рассинхронизирован с именем файла.
    _st_dir=$_st_base/c2
    seed_corpus "$_st_dir"
    _st_plan=$(first_plan "$_st_dir")
    mutate "$_st_plan" 's/^\*\*Plan ID:\*\* .*/**Plan ID:** 991231_2359/'
    if check_c2 "$_st_dir" > /dev/null 2>&1; then
        printf 'MISSED C2\n'
    else
        printf 'caught C2\n'
        _st_caught=$((_st_caught + 1))
    fi

    # C3: из плана удалена обязательная секция шаблона.
    _st_dir=$_st_base/c3
    seed_corpus "$_st_dir"
    _st_plan=$(first_plan "$_st_dir")
    mutate "$_st_plan" '/^## Out of scope$/d'
    if check_c3 "$_st_dir" > /dev/null 2>&1; then
        printf 'MISSED C3\n'
    else
        printf 'caught C3\n'
        _st_caught=$((_st_caught + 1))
    fi

    # C4: у receipt-маркера срезан префикс метки времени.
    _st_dir=$_st_base/c4
    seed_corpus "$_st_dir"
    _st_plan=$(post_cutoff_plan_with "$_st_dir" "$CUTOFF" \
        '^- [0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2} — \(Role CENSOR\) (OK|FAIL):')
    if [ -z "$_st_plan" ]; then
        printf 'selftest: cannot seed C4 (no post-cutoff receipt in corpus)\n'
        return 1
    fi
    mutate "$_st_plan" \
        's/^- [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\} — (Role CENSOR) OK:/(Role CENSOR) OK:/'
    mutate "$_st_plan" \
        's/^- [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\} — (Role CENSOR) FAIL:/(Role CENSOR) FAIL:/'
    if check_c4 "$_st_dir" > /dev/null 2>&1; then
        printf 'MISSED C4\n'
    else
        printf 'caught C4\n'
        _st_caught=$((_st_caught + 1))
    fi

    # C5: intake-строка сломанной формы.
    _st_dir=$_st_base/c5
    seed_corpus "$_st_dir"
    _st_plan=$(post_cutoff_plan_with "$_st_dir" "$CUTOFF" '^- Intake \([0-9]{4}-')
    if [ -z "$_st_plan" ]; then
        printf 'selftest: cannot seed C5 (no post-cutoff intake in corpus)\n'
        return 1
    fi
    mutate "$_st_plan" \
        's/^- Intake ([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}):/- Intake (broken):/'
    if check_c5 "$_st_dir" > /dev/null 2>&1; then
        printf 'MISSED C5\n'
    else
        printf 'caught C5\n'
        _st_caught=$((_st_caught + 1))
    fi

    # C6: digest-хвост не из 8 hex.
    _st_dir=$_st_base/c6
    seed_corpus "$_st_dir"
    _st_plan=$(first_plan "$_st_dir")
    printf '\nlint-bait digest: AGENTS.md@abcdef12345\n' >> "$_st_plan"
    if check_c6 "$_st_dir" > /dev/null 2>&1; then
        printf 'MISSED C6\n'
    else
        printf 'caught C6\n'
        _st_caught=$((_st_caught + 1))
    fi

    # C7: superseded-лейбл с номером, не равным текущему Round.
    _st_dir=$_st_base/c7
    seed_corpus "$_st_dir"
    _st_rv=''
    for _st_rf in "$_st_dir"/docs/reviews/[0-9]*.md; do
        [ -f "$_st_rf" ] || continue
        if grep -qE 'superseded \(round [0-9]+\)' "$_st_rf"; then
            _st_rv=$_st_rf
            break
        fi
    done
    if [ -z "$_st_rv" ]; then
        printf 'selftest: cannot seed C7 (no superseded labels in corpus)\n'
        return 1
    fi
    mutate "$_st_rv" 's/superseded (round [0-9]*)/superseded (round 77)/'
    if check_c7 "$_st_dir" > /dev/null 2>&1; then
        printf 'MISSED C7\n'
    else
        printf 'caught C7\n'
        _st_caught=$((_st_caught + 1))
    fi

    # C8: секция без ownership-метки.
    _st_dir=$_st_base/c8
    seed_corpus "$_st_dir"
    printf '\n## Lint bait section\nlint bait body\n' >> "$_st_dir/docs/plans/_template.md"
    if check_c8 "$_st_dir" > /dev/null 2>&1; then
        printf 'MISSED C8\n'
    else
        printf 'caught C8\n'
        _st_caught=$((_st_caught + 1))
    fi

    # C9: битая относительная ссылка.
    _st_dir=$_st_base/c9
    seed_corpus "$_st_dir"
    printf '\nlint bait link: docs/lint-bait-missing.md\n' >> "$_st_dir/README.md"
    if check_c9 "$_st_dir" > /dev/null 2>&1; then
        printf 'MISSED C9\n'
    else
        printf 'caught C9\n'
        _st_caught=$((_st_caught + 1))
    fi

    # C10: роль-док без пары.
    _st_dir=$_st_base/c10
    seed_corpus "$_st_dir"
    rm "$_st_dir/docs/roles/coder.md"
    if check_c10 "$_st_dir" > /dev/null 2>&1; then
        printf 'MISSED C10\n'
    else
        printf 'caught C10\n'
        _st_caught=$((_st_caught + 1))
    fi

    # C11 (dispatch-форма): источник вне множества {dispatch|sendmessage|unknown}.
    _st_dir=$_st_base/c11a
    seed_corpus "$_st_dir"
    _st_plan=$(post_cutoff_plan_with "$_st_dir" "$USAGE_CUTOFF" \
        '^- [0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2} — usage: (architect|planner|coder|reviewer-risk|reviewer-contracts)\.(work|censor|r[0-9]+) ([0-9]+|unknown \(why=[^)]*\)) tokens — (dispatch|sendmessage|unknown)$')
    if [ -z "$_st_plan" ]; then
        printf 'selftest: cannot seed C11a (no post-usage-cutoff dispatch line in corpus)\n'
        return 1
    fi
    mutate "$_st_plan" 's/tokens — dispatch$/tokens — via-dispatch/'
    if check_c11 "$_st_dir" > /dev/null 2>&1; then
        printf 'MISSED C11a\n'
    else
        printf 'caught C11a (dispatch form)\n'
        _st_caught=$((_st_caught + 1))
    fi

    # C11 (чекпоинт-форма): потерян `~` перед числом остатка.
    _st_dir=$_st_base/c11b
    seed_corpus "$_st_dir"
    _st_plan=$(post_cutoff_plan_with "$_st_dir" "$USAGE_CUTOFF" \
        '^- [0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2} — usage: manager-context checkpoint ~[0-9]+ tokens-left — approximate$')
    if [ -z "$_st_plan" ]; then
        printf 'selftest: cannot seed C11b (no post-usage-cutoff checkpoint line in corpus)\n'
        return 1
    fi
    mutate "$_st_plan" 's/checkpoint ~/checkpoint /'
    if check_c11 "$_st_dir" > /dev/null 2>&1; then
        printf 'MISSED C11b\n'
    else
        printf 'caught C11b (checkpoint form)\n'
        _st_caught=$((_st_caught + 1))
    fi

    printf 'selftest: %s/%s caught\n' "$_st_caught" "$_st_total"
    if [ "$_st_caught" -eq "$_st_total" ]; then
        return 0
    fi
    return 1
}

# -------------------------------------------------------------------- main

case ${1:-} in
    --selftest)
        selftest
        exit $?
        ;;
    '')
        _main_fails=0
        run_all "$ROOT" || _main_fails=$?
        if [ "$_main_fails" -eq 0 ]; then
            printf 'corpus: clean\n'
            exit 0
        fi
        printf 'corpus: %s failures\n' "$_main_fails"
        exit 1
        ;;
    *)
        printf 'usage: %s [--selftest]\n' "$0" >&2
        exit 2
        ;;
esac
