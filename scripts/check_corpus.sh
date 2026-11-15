#!/bin/sh
# check_corpus.sh — corpus lint v1: машинная проверка инвариантов конвейера
# Planfaktor. Источник решений: docs/plans/261111_2243_corpus_lint_ci.md
# (Solution п.1–8, проверки C1–C10, cutoff C4/C5) + docs/plans/
# 261112_0111_route_token_accounting.md (C11 — usage-строки, cutoff
# C3/C8 — секционная версионность) + docs/plans/
# 261113_1642_anti_loop_blocker_ids.md (C13 — грамматика live-блокеров
# и rerun-цикла review-артефактов, cutoff REVIEW_CUTOFF + exclude-лист)
# + docs/plans/261113_1944_public_repo_hygiene.md (C14 — safety-scan
# контента: классы приватных значений по фиксированным поверхностям,
# явный allowlist, selftest-кейсы на синтетике).
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
#   вывод: `OK Cn <имя>` на проверку (C4/C5/C11/C13 печатают
#   `excluded`-артефакты), `FAIL Cn <имя>: <детали>` при дефекте,
#   итог `corpus: clean` либо `corpus: N failures`; exit 0 только при clean.
#
# Selftest:
#   scripts/check_corpus.sh --selftest
#   строит в ${TMPDIR:-/tmp} копии корпуса, подсаживает по одному дефекту
#   на каждый класс C1–C14 и проверяет, что каждая проверка ловит свой
#   дефект; итог `selftest: N/33 caught`; exit 0 только при 33/33.

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

# Cutoff C12(в): R-DoD-покрытие Tests обязательно планам >= 261112_2236
# в статусе Done (план 261112_2236 — первый носитель R-меток; до гейта
# Done связку DoD<->Tests закрывает Planner + contracts-лан review,
# план 261112_2236 Solution п.7). Cutoff нужен только для (в).
REQ_CUTOFF=261112_2236

# Cutoff C13: грамматика live-блокеров/rerun review-артефактов (план
# 261113_1642, Solution п.8): Plan ID не монотонен по времени создания
# артефакта, поэтому cutoff + явный exclude-лист, а не чистое число.
REVIEW_CUTOFF=261113_1642

# Exclude-лист C13: артефакты с Plan ID >= REVIEW_CUTOFF, созданные по
# старой грамматике до введения чека (первое имя — 261113_2121_review.md,
# merge 720519f); критерий исторически закрыт — новые имена не добавляются.
REVIEW_EXCLUDE='261113_2121_review.md'

# Канонические enum'ы C13 (значения — план 261113_1642, Solution п.1–13).
C13_STATE_RE='^(open|historical-fixed|superseded)$'
C13_SEV_RE='^(S1|S2|S3)$'
C13_ROOT_RE='^(stale-evidence|same-contract-reroute|closed-baseline-split|real-scope-expansion|de-scoped-followup)$'
C13_ARTIFACT_RE='^(current_green|historical_reconciled|current_red|needs_reviewer_rerun)$'
C13_MODE_RE='^[- ]*\*\*Rerun mode:\*\* (incremental|full)[[:space:]]*$'
C13_RISK_DOMAINS='regression-behavior edge-cases data-integrity-secrets command-reproducibility brittleness'
C13_CONTRACTS_DOMAINS='constitution-compliance canon-drift artifact-grammar review-artifact-truthfulness scope-dod-boundaries tests-evidence-trace'
C13_DISP_RE='(accepted_blocker|accepted_non_blocking_followup|accepted_risk|dismissed|superseded)'

# Allowlist C14 — default deny (план 261113_1944, Solution п.3): совпадение
# класса в файле вне allowlist — FAIL; формат записи `путь|класс` (путь от
# корня репо), обоснование — комментарием под таблицей. Прецедент явных
# исключений линта: case-плейсхолдеры C9, `<!--`-фильтр C5/C11/C12.
# Bait-строки фикстур в репо отсутствуют: selftest-кейсы C14 генерируют
# синтетику конкатенациями в ${TMPDIR}-копиях, литеральных тел
# в исходнике нет (D5 плана 261113_1944).
C14_ALLOWLIST='scripts/check_corpus.sh|gh-token'
# scripts/check_corpus.sh|gh-token — why: единственный легальный
# bait-носитель allowlist-кейса selftest (C14g подсаживает bait в копию
# самого скрипта — прецедент exclude-кейса C13k); попутно исключение
# страхует эволюцию текста детектора: описания классов в комментариях
# и ERE-определения этого класса не обязаны самопроверяться на каждом
# изменении формулировок.

# Реестр внешних требований (план 261112_2236, Solution п.1/п.7): rows —
# в теле секции `## Требования`, статусы — `## Журнал статусов`.
REQ_REGISTRY=docs/requirements/registry.md

# R-метка: `[R: <ID>]`, ID — алфанумерик с `.`/`-` (форма = T1 плана
# 261112_2236).
R_TAG_RE='\[R: [A-Za-z0-9][A-Za-z0-9.-]*\]'

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

# ------------------------------------------------------------- checks C1-C12

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
# CONTRIBUTING.md, SECURITY.md, роль-доков и команд существуют;
# плейсхолдеры allowlist'а пропускаются
# (кириллические `docs/plans/<файл>` и `docs/roles/<роль>.md` обрезаются
# токенизатором до `docs/<dir>/<`); слэш-команды `/planfaktor-*` требуют
# `.zcode/commands/<имя>.md`. Glob-паттерн `docs/plans/[0-9]*.md`
# токенизатором обрезается до существующего каталога `docs/plans/`
# (квадратные скобки не входят в алфавит пути-токена). Дефис — часть
# алфавита пути-токена (план 261112_2236: файлы вида
# docs/compliance/gost-r-56939-2024.md без дефиса обрезались
# до несуществующего префикса).
check_c9() {
    _c9_corpus=$1
    _c9_rc=0
    for _c9_src in "$_c9_corpus/README.md" "$_c9_corpus/AGENTS.md" \
                   "$_c9_corpus/CONTRIBUTING.md" "$_c9_corpus/SECURITY.md" \
                   "$_c9_corpus"/docs/roles/*.md \
                   "$_c9_corpus"/.zcode/commands/*.md
    do
        [ -f "$_c9_src" ] || continue
        _c9_rel=${_c9_src#$_c9_corpus/}
        for _c9_tok in $(grep -hoE '(docs|\.zcode)/[A-Za-z0-9_./<>*-]+' "$_c9_src" | sort -u || true); do
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

# C12: трассируемость внешних требований (план 261112_2236, Solution
# п.7). Три ветки:
# (а) каждая R-метка из тел `## Scope` и `## Acceptance criteria / DoD`
#     планов существует в реестре REQ_REGISTRY; ID rows реестра
#     без дублей;
# (б) rows реестра (тело `## Требования`) валидны: ровно 8 полей /
#     7 разделителей ` — ` (разделитель заменяется на `|`, поля
#     считаются cut'ом), формы полей — ID (`REQ-<n>`|`G56939-<пункт>`),
#     `предъявлено=`, `принято=`, enum приоритетов/статусов, `срок=`,
#     `plan=<PlanID>|none`; plan=<PlanID> существует в корпусе;
# (в) планам >= REQ_CUTOFF в статусе Done: каждая DoD-строка с [R: ...]
#     несёт метку Dn, и `(Dn)` упомянута в теле `## Tests / Commands`.
# Секционно-якорный детектор (прецедент C5/C11): строки с `<!--`
# исключены — примеры формата в прозе/комментариях не считаются.
check_c12() {
    _c12_corpus=$1
    _c12_rc=0
    _c12_reg=$_c12_corpus/$REQ_REGISTRY
    _c12_ids=''

    # --- (б) rows реестра + сборка ID ---
    if [ ! -f "$_c12_reg" ]; then
        printf '%s: missing\n' "$REQ_REGISTRY"
        _c12_rc=1
    else
        if ! _c12_rows=$(sect_body "$_c12_reg" 'Требования'); then
            printf '%s: missing section `## Требования`\n' "$REQ_REGISTRY"
            _c12_rows=''
            _c12_rc=1
        fi
        while IFS= read -r _c12_row; do
            [ -n "$_c12_row" ] || continue
            case $_c12_row in *'<!--'*) continue ;; esac
            case $_c12_row in '- '*) ;; *) continue ;; esac
            _c12_pipe=$(printf '%s\n' "$_c12_row" | sed 's/^- //' | sed 's/ — /|/g')
            _c12_nf=$(printf '%s\n' "$_c12_pipe" | awk -F'|' '{print NF}')
            if [ "$_c12_nf" -ne 8 ]; then
                printf '%s: row has %s fields (want 8): %.60s...\n' \
                    "$REQ_REGISTRY" "$_c12_nf" "$_c12_row"
                _c12_rc=1
                continue
            fi
            _c12_id=$(printf '%s\n' "$_c12_pipe" | cut -d'|' -f1)
            _c12_ids="$_c12_ids $_c12_id"
            if ! printf '%s\n' "$_c12_id" | grep -qE \
                '^(REQ-[0-9]+|G56939-[0-9]+(\.[0-9]+)*[a-z]?)$'
            then
                printf '%s: bad ID `%s`\n' "$REQ_REGISTRY" "$_c12_id"
                _c12_rc=1
            fi
            if ! printf '%s\n' "$_c12_pipe" | cut -d'|' -f3 | grep -qE \
                '^предъявлено=[0-9]{4}-[0-9]{2}-[0-9]{2}, .+$'
            then
                printf '%s: row %s: bad `предъявлено=` field\n' \
                    "$REQ_REGISTRY" "$_c12_id"
                _c12_rc=1
            fi
            if ! printf '%s\n' "$_c12_pipe" | cut -d'|' -f4 | grep -qE \
                '^принято=(none|.+, [0-9]{4}-[0-9]{2}-[0-9]{2})$'
            then
                printf '%s: row %s: bad `принято=` field\n' \
                    "$REQ_REGISTRY" "$_c12_id"
                _c12_rc=1
            fi
            if ! printf '%s\n' "$_c12_pipe" | cut -d'|' -f5 | grep -qE \
                '^приоритет=P[123]$'
            then
                printf '%s: row %s: bad `приоритет=` field\n' \
                    "$REQ_REGISTRY" "$_c12_id"
                _c12_rc=1
            fi
            if ! printf '%s\n' "$_c12_pipe" | cut -d'|' -f6 | grep -qE \
                '^срок=(none|[0-9]{4}-[0-9]{2}-[0-9]{2})$'
            then
                printf '%s: row %s: bad `срок=` field\n' \
                    "$REQ_REGISTRY" "$_c12_id"
                _c12_rc=1
            fi
            if ! printf '%s\n' "$_c12_pipe" | cut -d'|' -f7 | grep -qE \
                '^статус=(open|planned|verified|released)$'
            then
                printf '%s: row %s: bad `статус=` field\n' \
                    "$REQ_REGISTRY" "$_c12_id"
                _c12_rc=1
            fi
            _c12_pl=$(printf '%s\n' "$_c12_pipe" | cut -d'|' -f8 | sed 's/^plan=//')
            if ! printf '%s\n' "$_c12_pl" | grep -qE '^(none|[0-9]{6}_[0-9]{4})$'; then
                printf '%s: row %s: bad `plan=` field\n' \
                    "$REQ_REGISTRY" "$_c12_id"
                _c12_rc=1
            elif [ "$_c12_pl" != none ]; then
                _c12_found=''
                for _c12_pf in "$_c12_corpus"/docs/plans/"$_c12_pl"_*.md; do
                    if [ -f "$_c12_pf" ]; then _c12_found=1; break; fi
                done
                if [ -z "$_c12_found" ]; then
                    printf '%s: row %s references missing plan %s\n' \
                        "$REQ_REGISTRY" "$_c12_id" "$_c12_pl"
                    _c12_rc=1
                fi
            fi
        done <<EOF
$_c12_rows
EOF
        _c12_dup=$(printf '%s\n' $_c12_ids | sed '/^$/d' | sort | uniq -d)
        if [ -n "$_c12_dup" ]; then
            printf '%s: duplicate row IDs: %s\n' \
                "$REQ_REGISTRY" "$(printf '%s ' $_c12_dup)"
            _c12_rc=1
        fi
    fi

    # --- (а) R-метки планов существуют в реестре ---
    for _c12_f in "$_c12_corpus"/docs/plans/[0-9]*.md; do
        [ -f "$_c12_f" ] || continue
        _c12_rel=${_c12_f#$_c12_corpus/}
        _c12_tags=$({ sect_body "$_c12_f" 'Scope' || true
                      sect_body "$_c12_f" 'Acceptance criteria / DoD' || true
                    } | grep -v '<!--' | grep -oE "$R_TAG_RE" \
                      | sed 's/^\[R: //; s/\]$//' | sort -u || true)
        while IFS= read -r _c12_tag; do
            [ -n "$_c12_tag" ] || continue
            if ! printf '%s\n' $_c12_ids | grep -qxF "$_c12_tag"; then
                printf '%s: R-tag `%s` not in %s\n' \
                    "$_c12_rel" "$_c12_tag" "$REQ_REGISTRY"
                _c12_rc=1
            fi
        done <<EOF
$_c12_tags
EOF

        # --- (в) R-DoD-покрытие: планы >= REQ_CUTOFF в статусе Done ---
        _c12_pid=$(plan_prefix "$(basename "$_c12_f")")
        if [ "$_c12_pid" \< "$REQ_CUTOFF" ]; then continue; fi
        _c12_status=$(sed -n 's/^\*\*Status:\*\* //p' "$_c12_f" | head -n 1)
        [ "$_c12_status" = Done ] || continue
        _c12_tests=$(sect_body "$_c12_f" 'Tests / Commands') || _c12_tests=''
        _c12_rrows=$(sect_body "$_c12_f" 'Acceptance criteria / DoD' \
            | grep -v '<!--' | grep '\[R: ' || true)
        while IFS= read -r _c12_dl; do
            [ -n "$_c12_dl" ] || continue
            _c12_d=$(printf '%s\n' "$_c12_dl" | grep -oE 'D[0-9]+' | head -n 1)
            if [ -z "$_c12_d" ]; then
                printf '%s: R-DoD line without Dn label: %.60s...\n' \
                    "$_c12_rel" "$_c12_dl"
                _c12_rc=1
                continue
            fi
            if ! printf '%s\n' "$_c12_tests" | grep -qF "($_c12_d)"; then
                printf '%s: R-DoD %s not covered by `(%s)` in Tests\n' \
                    "$_c12_rel" "$_c12_d" "$_c12_d"
                _c12_rc=1
            fi
        done <<EOF
$_c12_rrows
EOF
    done
    return $_c12_rc
}

# C13 (cutoff >= REVIEW_CUTOFF минус REVIEW_EXCLUDE, скоуп — review-
# артефакты): грамматика канонических live-блокеров и rerun-цикла (план
# 261113_1642). Базовая часть:
# (а) каждый присутствующий блок `### B<N>` несёт `Current state:` и
#     `Severity:` из enum'ов — отсутствие B-блоков не дефект (раунд без
#     блокеров — норма);
# (б) ID-пространство блоков артефакта — без дублей заголовков `### B<N>`
#     и без дыр (множество ID = 1..max подряд);
# (в) live-блок (`Current state: open`), чей ID упомянут `#B<N>` в строке
#     с лейблом `superseded (round ...)`, несёт `Root cause class:` из
#     enum'а (Loop signal).
# Расширенная часть:
# (г) `**Artifact state:**` записанной формы (одиночный токен из enum'а;
#     без superseded-лейбла) — значение из enum'а, а при записанном
#     (не-superseded) Contracts-вердикте — обязательна; плейсхолдер
#     шаблона (альтернативы через « | ») — не записанная форма, в окне
#     между лейнами не валидируется (транзиент-безопасность);
# (д) `**Round:**` >= 2 — ровно одна (не-superseded) строка
#     `**Rerun mode:` incremental|full текущего раунда — superseded-строки
#     прошлых раундов (Round >= 3) изымаются из подсчёта и валидации;
#     incremental — наличие четырёх полей доверия (Baseline artifact /
#     Rerun scope / Trusted unaffected surfaces / Reused evidence);
# (е) при записанном (не-superseded) вердикте лейна — `**Coverage:**` в
#     секции раунда этого вердикта (токены только из enum'а лейна, без
#     дублей), а при пустой таблице находок секции — `**No findings
#     reason:**` с непустым текстом;
# (ж) при записанном Contracts-вердикте Итог несёт судьбы (строки без
#     superseded-лейбла) всех заполненных строк находок текущего раунда
#     (`Finding R<n>` / `Finding C<n>`) либо no-findings placeholder.
# Транзиент-безопасность (прецедент C7-транзиента 261113_0217): проверяется
# форма присутствующего — артефакт в промежуточном состоянии между лейнами
# линт не роняет.
check_c13() {
    _c13_corpus=$1
    _c13_rc=0
    for _c13_f in "$_c13_corpus"/docs/reviews/[0-9]*.md; do
        [ -f "$_c13_f" ] || continue
        _c13_rel=${_c13_f#$_c13_corpus/}
        _c13_pid=$(plan_prefix "$(basename "$_c13_f")")
        if [ "$_c13_pid" \< "$REVIEW_CUTOFF" ]; then
            printf '%s: excluded (pre-review-cutoff %s < %s)\n' \
                "$_c13_rel" "$_c13_pid" "$REVIEW_CUTOFF"
            continue
        fi
        case " $REVIEW_EXCLUDE " in
            *" $(basename "$_c13_f") "*) continue ;;
        esac
        _c13_check_one "$_c13_f" "$_c13_rel" || _c13_rc=1
    done
    return $_c13_rc
}

# _c13_check_one <file> <relpath> — все ветки C13 по одному артефакту.
_c13_check_one() {
    _c13o_f=$1
    _c13o_rel=$2
    _c13o_rc=0

    # --- (а)+(в): B-блоки; reused-IDs — `#B<N>` в superseded-строках.
    _c13o_reused=$(grep -E 'superseded \(round [0-9]+\)' "$_c13o_f" \
        | grep -oE '#B[0-9]+' | sed 's/^#B//' | sort -nu || true)
    _c13o_ids=''
    while IFS= read -r _c13o_h; do
        [ -n "$_c13o_h" ] || continue
        _c13o_ln=${_c13o_h%%:*}
        _c13o_n=$(printf '%s\n' "$_c13o_h" | sed 's/^[0-9]*:### B//; s/[[:space:]]*$//')
        _c13o_ids="$_c13o_ids $_c13o_n"
        _c13o_end=$(awk -v s="$_c13o_ln" 'NR>s && /^#{2,3} /{print NR; exit}' "$_c13o_f")
        if [ -n "$_c13o_end" ]; then
            _c13o_body=$(sed -n "$((_c13o_ln+1)),$((_c13o_end-1))p" "$_c13o_f")
        else
            _c13o_body=$(tail -n +"$((_c13o_ln+1))" "$_c13o_f")
        fi
        _c13o_state=$(printf '%s\n' "$_c13o_body" \
            | sed -n 's/^Current state: //p' | head -n 1)
        if [ -z "$_c13o_state" ] \
           || ! printf '%s\n' "$_c13o_state" | grep -qE "$C13_STATE_RE"; then
            printf '%s: B%s: bad/missing Current state: %s\n' \
                "$_c13o_rel" "$_c13o_n" "${_c13o_state:-<none>}"
            _c13o_rc=1
        fi
        _c13o_sev=$(printf '%s\n' "$_c13o_body" \
            | sed -n 's/^Severity: //p' | head -n 1)
        if [ -z "$_c13o_sev" ] \
           || ! printf '%s\n' "$_c13o_sev" | grep -qE "$C13_SEV_RE"; then
            printf '%s: B%s: bad/missing Severity: %s\n' \
                "$_c13o_rel" "$_c13o_n" "${_c13o_sev:-<none>}"
            _c13o_rc=1
        fi
        if [ "$_c13o_state" = open ] \
           && printf '%s\n' "$_c13o_reused" | grep -qxF "$_c13o_n"; then
            _c13o_root=$(printf '%s\n' "$_c13o_body" \
                | sed -n 's/^Root cause class: //p' | head -n 1)
            if [ -z "$_c13o_root" ] \
               || ! printf '%s\n' "$_c13o_root" | grep -qE "$C13_ROOT_RE"; then
                printf '%s: B%s: live reused-ID block lacks Root cause class (Loop signal): %s\n' \
                    "$_c13o_rel" "$_c13o_n" "${_c13o_root:-<none>}"
                _c13o_rc=1
            fi
        fi
    done <<EOF
$(grep -nE '^### B[0-9]+[[:space:]]*$' "$_c13o_f" || true)
EOF

    # --- (б): дубли заголовков и дыры ID-пространства.
    if [ -n "$_c13o_ids" ]; then
        _c13o_dup=$(printf '%s\n' $_c13o_ids | sort -n | uniq -d)
        if [ -n "$_c13o_dup" ]; then
            printf '%s: duplicate B-block headers: %s\n' \
                "$_c13o_rel" "$(printf '%s ' $_c13o_dup)"
            _c13o_rc=1
        fi
        _c13o_exp=1
        for _c13o_id in $(printf '%s\n' $_c13o_ids | sort -nu); do
            if [ "$_c13o_id" -ne "$_c13o_exp" ]; then
                printf '%s: hole in B-ID space at B%s (want B%s)\n' \
                    "$_c13o_rel" "$_c13o_id" "$_c13o_exp"
                _c13o_rc=1
                break
            fi
            _c13o_exp=$((_c13o_exp + 1))
        done
    fi

    # --- (г): Artifact state. Валидируется значение записанной формы —
    # одиночный токен из enum'а; плейсхолдер шаблона (перечисление
    # альтернатив через « | ») и superseded-строки истории раундов не
    # валидируются и записанной формой не считаются (транзиент-
    # безопасность окна между лейнами: risk создаёт артефакт из шаблона,
    # Итог ещё за плейсхолдерами). Обязательность — при записанном
    # (не-superseded) Contracts-вердикте: нужна хотя бы одна строка
    # записанной формы.
    _c13o_astate_recorded=''
    while IFS= read -r _c13o_st; do
        [ -n "$_c13o_st" ] || continue
        _c13o_val=$(printf '%s\n' "$_c13o_st" \
            | sed -n 's/^[- ]*\*\*Artifact state:\*\* *//p')
        case $_c13o_val in
            *' | '*) continue ;;
        esac
        if ! printf '%s\n' "$_c13o_val" | grep -qE "$C13_ARTIFACT_RE"; then
            printf '%s: bad **Artifact state:** value: %s\n' \
                "$_c13o_rel" "${_c13o_val:-<empty>}"
            _c13o_rc=1
        else
            _c13o_astate_recorded=1
        fi
    done <<EOF
$(grep -E '^[- ]*\*\*Artifact state:\*\*' "$_c13o_f" \
    | grep -v 'superseded (round' || true)
EOF
    if grep -qE '^### Contracts verdict: (pass|needs-fix)[[:space:]]*$' "$_c13o_f" \
       && [ -z "$_c13o_astate_recorded" ]; then
        printf '%s: recorded Contracts verdict without **Artifact state:**\n' "$_c13o_rel"
        _c13o_rc=1
    fi

    # --- (д): Rerun mode. Подсчёт/валидация — только по строкам текущего
    # раунда: superseded-строки прошлых раундов изымаются (артефакт
    # Round >= 3 с накопленными секциями раундов легально несёт по
    # одной Rerun mode-строке на раунд >= 2; действительна последняя).
    _c13o_round=$(sed -n 's/^\*\*Round:\*\* //p' "$_c13o_f" | head -n 1)
    _c13o_modes=$(grep -E '^[- ]*\*\*Rerun mode:\*\*' "$_c13o_f" \
        | grep -cv 'superseded (round' || true)
    if [ -n "$_c13o_round" ] && [ "$_c13o_round" -ge 2 ] 2>/dev/null \
       && [ "$_c13o_modes" -ne 1 ]; then
        printf '%s: Round %s without exactly one **Rerun mode:** line\n' \
            "$_c13o_rel" "$_c13o_round"
        _c13o_rc=1
    fi
    while IFS= read -r _c13o_m; do
        [ -n "$_c13o_m" ] || continue
        if ! printf '%s\n' "$_c13o_m" | grep -qE "$C13_MODE_RE"; then
            printf '%s: malformed **Rerun mode:** line: %s\n' \
                "$_c13o_rel" "$_c13o_m"
            _c13o_rc=1
        fi
    done <<EOF
$(grep -E '^[- ]*\*\*Rerun mode:\*\*' "$_c13o_f" \
    | grep -v 'superseded (round' || true)
EOF
    if grep -E '^[- ]*\*\*Rerun mode:\*\*' "$_c13o_f" \
       | grep -v 'superseded (round' \
       | grep -qE '^[- ]*\*\*Rerun mode:\*\* incremental[[:space:]]*$'; then
        for _c13o_p in 'Baseline artifact' 'Rerun scope' \
                       'Trusted unaffected surfaces' 'Reused evidence'; do
            if ! grep -qE "^[- ]*\*\*$_c13o_p:\*\* .+" "$_c13o_f"; then
                printf '%s: incremental lacks trust field **%s:**\n' \
                    "$_c13o_rel" "$_c13o_p"
                _c13o_rc=1
            fi
        done
    fi

    # --- (е): Coverage / No findings reason / заполненные находки секций
    # раунда с записанным (не-superseded) вердиктом лейна.
    _c13o_rfilled=''
    _c13o_cfilled=''
    for _c13o_lane in Risk Contracts; do
        _c13o_vln=$(grep -nE "^### $_c13o_lane verdict: (pass|needs-fix)[[:space:]]*$" \
            "$_c13o_f" | tail -n 1 | cut -d: -f1)
        [ -n "$_c13o_vln" ] || continue
        _c13o_hln=$(grep -nE "^## Findings — $_c13o_lane lane" "$_c13o_f" \
            | cut -d: -f1 | awk -v v="$_c13o_vln" '$1<v' | tail -n 1)
        if [ -z "$_c13o_hln" ]; then
            printf '%s: %s verdict outside its lane section\n' \
                "$_c13o_rel" "$_c13o_lane"
            _c13o_rc=1
            continue
        fi
        _c13o_end=$(awk -v s="$_c13o_hln" 'NR>s && /^## /{print NR; exit}' "$_c13o_f")
        if [ -n "$_c13o_end" ]; then
            _c13o_sec=$(sed -n "$((_c13o_hln+1)),$((_c13o_end-1))p" "$_c13o_f")
        else
            _c13o_sec=$(tail -n +"$((_c13o_hln+1))" "$_c13o_f")
        fi
        _c13o_cov=$(printf '%s\n' "$_c13o_sec" \
            | grep -E '^[- ]*\*\*Coverage:\*\*' | head -n 1)
        if [ -z "$_c13o_cov" ]; then
            printf '%s: %s round section lacks **Coverage:**\n' \
                "$_c13o_rel" "$_c13o_lane"
            _c13o_rc=1
        else
            case $_c13o_lane in
                Risk) _c13o_dom=$C13_RISK_DOMAINS ;;
                *)    _c13o_dom=$C13_CONTRACTS_DOMAINS ;;
            esac
            _c13o_seen=''
            for _c13o_tok in $(printf '%s\n' "$_c13o_cov" \
                | sed 's/^[- ]*\*\*Coverage:\*\* *//' | tr ';' ' '); do
                if ! printf '%s\n' $_c13o_dom | grep -qxF "$_c13o_tok"; then
                    printf '%s: %s Coverage token outside lane enum: %s\n' \
                        "$_c13o_rel" "$_c13o_lane" "$_c13o_tok"
                    _c13o_rc=1
                fi
                case " $_c13o_seen " in
                    *" $_c13o_tok "*)
                        printf '%s: %s Coverage duplicate token: %s\n' \
                            "$_c13o_rel" "$_c13o_lane" "$_c13o_tok"
                        _c13o_rc=1
                        ;;
                esac
                _c13o_seen="$_c13o_seen $_c13o_tok"
            done
        fi
        _c13o_filled=''
        while IFS= read -r _c13o_row; do
            _c13o_rest=$(printf '%s\n' "$_c13o_row" | sed 's/^| [0-9]\{1,\} |//')
            if printf '%s' "$_c13o_rest" | grep -q '[^|[:space:]]'; then
                _c13o_num=$(printf '%s\n' "$_c13o_row" \
                    | sed 's/^| \([0-9]\{1,\}\) |.*/\1/')
                _c13o_filled="$_c13o_filled $_c13o_num"
            fi
        done <<EOF
$(printf '%s\n' "$_c13o_sec" | grep -E '^\| [0-9]+ \|' || true)
EOF
        if [ -z "$_c13o_filled" ] \
           && ! printf '%s\n' "$_c13o_sec" | grep -qE '^[- ]*\*\*No findings reason:\*\* .+'; then
            printf '%s: %s round section: empty findings table without **No findings reason:**\n' \
                "$_c13o_rel" "$_c13o_lane"
            _c13o_rc=1
        fi
        if [ "$_c13o_lane" = Risk ]; then
            _c13o_rfilled=$_c13o_filled
        else
            _c13o_cfilled=$_c13o_filled
        fi
    done

    # --- (ж): судьбы в Итоге при записанном Contracts-вердикте.
    if grep -qE '^### Contracts verdict: (pass|needs-fix)[[:space:]]*$' "$_c13o_f"; then
        _c13o_sum=$(sect_body "$_c13o_f" 'Итог') || _c13o_sum=''
        if [ -n "${_c13o_rfilled}${_c13o_cfilled}" ]; then
            for _c13o_n in $_c13o_rfilled; do
                if ! printf '%s\n' "$_c13o_sum" \
                    | grep -E "^- Finding R$_c13o_n → $C13_DISP_RE" \
                    | grep -qv 'superseded (round'; then
                    printf '%s: Итог lacks disposition for Finding R%s\n' \
                        "$_c13o_rel" "$_c13o_n"
                    _c13o_rc=1
                fi
            done
            for _c13o_n in $_c13o_cfilled; do
                if ! printf '%s\n' "$_c13o_sum" \
                    | grep -E "^- Finding C$_c13o_n → $C13_DISP_RE" \
                    | grep -qv 'superseded (round'; then
                    printf '%s: Итог lacks disposition for Finding C%s\n' \
                        "$_c13o_rel" "$_c13o_n"
                    _c13o_rc=1
                fi
            done
        else
            if ! printf '%s\n' "$_c13o_sum" | grep -qE '^[- ]*\*\*No findings reason:\*\* .+'; then
                printf '%s: Итог lacks no-findings placeholder\n' "$_c13o_rel"
                _c13o_rc=1
            fi
        fi
    fi

    return $_c13o_rc
}

# C14: safety-scan контента (план 261113_1944, Solution п.2–3) — машинный
# барьер против утечек приватных значений в публичный корпус. Поверхности —
# фиксированный явный список по прецеденту C9; классы — POSIX ERE
# с payload-принципом: каждый паттерн требует значащий payload (сегмент
# имени / тело токена), чтобы документационные плейсхолдеры `<...>`,
# `<REDACTED>` и упоминания классов в прозе без тел не матчились — это
# минимизирует allowlist. Классы (имена — идентификаторы allowlist'а,
# формулировки без триггерных литералов, D2 плана 261113_1944):
#   home-path — абсолютный домашний путь: префикс Users либо home
#               с сегментом имени пользователя (минимум 2 латинские
#               буквы/цифры) до следующего слэша или конца токена;
#   gh-token  — короткий префиксный класс токена хостинга: gh + одна
#               латинская буква + подчёркивание, тело от 20
#               букв/цифр/подчёркиваний/дефисов;
#   gh-pat    — составной префиксный класс fine-grained токена: имя
#               сервиса с двумя подчёркиваниями-разделителями, тело
#               от 20 тех же символов;
#   pem-key   — маркер заголовка PEM-блока приватного ключа
#               канонического вида: пять дефисов, слово начала блока,
#               уточнение вида ключа из семейства приватных, закрывающие
#               дефисы;
#   bearer    — заголовок авторизации Bearer: слово-схема с телом
#               от 20 букв/цифр после разделителя;
#   jwt       — JWT-подобное значение: три base64url-сегмента,
#               разделённые точками, каждый не короче 10 символов,
#               первый начинается с канонического префикса base64url-
#               кодировки открывающей фигурной скобки JSON.
# Полный класс приватных идентификаторов (имена, сессии) машинными
# классами не покрывается — направленный ручной просмотр перед
# публикацией (SECURITY.md; Problem п.2 плана 261113_1944).
check_c14() {
    _c14_corpus=$1
    _c14_rc=0
    _c14_surfaces=''
    for _c14_s in docs .zcode scripts .github/workflows \
                  README.md AGENTS.md CONTRIBUTING.md SECURITY.md LICENSE
    do
        [ -e "$_c14_corpus/$_c14_s" ] \
            && _c14_surfaces="$_c14_surfaces $_c14_s"
    done
    [ -n "$_c14_surfaces" ] || return 0
    for _c14_cls in home-path gh-token gh-pat pem-key bearer jwt; do
        _c14_re=$(_c14_re_of "$_c14_cls")
        _c14_hits=$(cd "$_c14_corpus" \
            && grep -rnE -- "$_c14_re" $_c14_surfaces 2>/dev/null || true)
        while IFS= read -r _c14_hit; do
            [ -n "$_c14_hit" ] || continue
            _c14_file=${_c14_hit%%:*}
            if _c14_allowed "$_c14_file" "$_c14_cls"; then continue; fi
            printf 'c14-%s: %s\n' "$_c14_cls" "$_c14_hit"
            _c14_rc=1
        done <<EOF
$_c14_hits
EOF
    done
    return $_c14_rc
}

# _c14_re_of <class> — ERE класса (единственное место с телами паттернов).
_c14_re_of() {
    case $1 in
        home-path) printf '%s\n' '/(Users|home)/[A-Za-z0-9][A-Za-z0-9]+' ;;
        gh-token)  printf '%s\n' 'gh[A-Za-z]_[A-Za-z0-9_-]{20,}' ;;
        gh-pat)    printf '%s\n' 'github_pat_[A-Za-z0-9_-]{20,}' ;;
        pem-key)   printf '%s\n' '-----BEGIN [A-Z ]*PRIVATE KEY-----' ;;
        bearer)    printf '%s\n' 'Bearer[[:space:]]+[A-Za-z0-9]{20,}' ;;
        jwt)       printf '%s\n' 'eyJ[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}' ;;
    esac
}

# _c14_allowed <relpath> <class> — rc 0, если пара `путь|класс` в
# C14_ALLOWLIST (default deny: всё вне таблицы — FAIL).
_c14_allowed() {
    while IFS='|' read -r _c14a_path _c14a_cls; do
        [ -n "$_c14a_path" ] || continue
        if [ "$_c14a_path" = "$1" ] && [ "$_c14a_cls" = "$2" ]; then
            return 0
        fi
    done <<EOF
$C14_ALLOWLIST
EOF
    return 1
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

# run_all <corpus> — прогон C1–C14; rc = число проваленных проверок.
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
    report C12 requirements-traceability "$_ra_corpus" check_c12 || _ra_fails=$((_ra_fails + 1))
    report C13 review-blocker-grammar "$_ra_corpus" check_c13 || _ra_fails=$((_ra_fails + 1))
    report C14 safety-scan         "$_ra_corpus" check_c14 || _ra_fails=$((_ra_fails + 1))
    return $_ra_fails
}

# ----------------------------------------------------------------- selftest

# seed_corpus <dir> — свежая копия корпуса для подсадки дефектов.
# Копируются все поверхности C14 (docs/, .zcode/, scripts/,
# .github/workflows/ через .github/, корневые файлы — включая
# CONTRIBUTING.md, SECURITY.md, LICENSE) со структурой корня — иначе
# кейсы C14 в копиях невоспроизводимы (D7 плана 261113_1944).
seed_corpus() {
    mkdir -p "$1"
    cp -R "$ROOT/docs" "$1/docs"
    cp -R "$ROOT/.zcode" "$1/.zcode"
    cp -R "$ROOT/scripts" "$1/scripts"
    cp -R "$ROOT/.github" "$1/.github"
    cp "$ROOT/README.md" "$ROOT/AGENTS.md" "$ROOT/CONTRIBUTING.md" \
       "$ROOT/SECURITY.md" "$ROOT/LICENSE" "$1/"
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
                  check_c6 check_c7 check_c8 check_c9 check_c10 check_c11 \
                  check_c12 check_c13 check_c14
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
    _st_total=33

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

    # C12 (а): R-метка с ID, отсутствующим в реестре требований.
    _st_dir=$_st_base/c12a
    seed_corpus "$_st_dir"
    _st_plan=$(post_cutoff_plan_with "$_st_dir" "$REQ_CUTOFF" "$R_TAG_RE")
    if [ -z "$_st_plan" ]; then
        printf 'selftest: cannot seed C12a (no R-tags in corpus plans)\n'
        return 1
    fi
    mutate "$_st_plan" 's/\[R: G56939-5\.3\.3\.2\]/[R: G56939-9.9.9]/'
    if check_c12 "$_st_dir" > /dev/null 2>&1; then
        printf 'MISSED C12a\n'
    else
        printf 'caught C12a (R-tag not in registry)\n'
        _st_caught=$((_st_caught + 1))
    fi

    # C12 (б): row реестра с невалидным полем статуса (вне enum).
    # Паттерн не привязан к значению статуса ([a-z]+, не литерал planned):
    # живые переводы open→planned→verified не должны обнулять посадку.
    _st_dir=$_st_base/c12b
    seed_corpus "$_st_dir"
    mutate "$_st_dir/docs/requirements/registry.md" \
        's/ — статус=[a-z][a-z]*/ — статус=in-progress/'
    if check_c12 "$_st_dir" > /dev/null 2>&1; then
        printf 'MISSED C12b\n'
    else
        printf 'caught C12b (bad registry row)\n'
        _st_caught=$((_st_caught + 1))
    fi

    # C12 (в): R-DoD без упоминания `(Dn)` в Tests у плана >= cutoff
    # в статусе Done (метка D1 из T2 переименована в несуществующую D9).
    _st_dir=$_st_base/c12c
    seed_corpus "$_st_dir"
    _st_plan=$(post_cutoff_plan_with "$_st_dir" "$REQ_CUTOFF" "$R_TAG_RE")
    if [ -z "$_st_plan" ]; then
        printf 'selftest: cannot seed C12c (no R-tags in corpus plans)\n'
        return 1
    fi
    mutate "$_st_plan" 's/^\*\*Status:\*\* .*/**Status:** Done/'
    mutate "$_st_plan" 's/^- T2 (D1):/- T2 (D9):/'
    if check_c12 "$_st_dir" > /dev/null 2>&1; then
        printf 'MISSED C12c\n'
    else
        printf 'caught C12c (R-DoD uncovered in Tests)\n'
        _st_caught=$((_st_caught + 1))
    fi

    # make_c13_bait <dir> — синтетический bait-артефакт C13: Plan ID >=
    # REVIEW_CUTOFF, полная новая грамматика (Round 2, incremental,
    # B1 live с Loop-подблоком, судьбы, Coverage, Artifact state).
    # Живёт только в selftest-копиях ${TMPDIR} (прецедент bait C6/C8/C9),
    # в репо не появляется; чист против C13/C7 — дефекты подсаживаются
    # кейсами C13a–C13j точечно.
    make_c13_bait() {
        mkdir -p "$1/docs/reviews"
        cat > "$1/docs/reviews/261130_0000_c13bait.md" <<'EOF'
# Review — 261130_0000

**Plan:** docs/plans/261130_0000_c13bait_plan.md
**Reviewed:** staged-изменения против HEAD
**Status плана на момент review:** In review
**Created:** 2026-11-14 02:00:00
**Round:** 2
**Round 2 started:** 2026-11-14 02:30:00
**Lanes:** risk → contracts (последовательно; contracts читает секцию risk)

## Findings — Risk lane
<!-- owner: reviewer-risk -->

| # | Серьёзность | Файл:строка | Суть | Почему риск |
|---|---|---|---|---|
| 1 — superseded (round 2) | minor | bait.md:1 | Round 1 finding | bait |

**Coverage:** edge-cases; brittleness

### Risk verdict: pass — superseded (round 2)
superseded verdict of round 1
2026-11-14 02:10:00 — round 1 verdict

## Findings — Risk lane — Round 2
<!-- owner: reviewer-risk -->

| # | Серьёзность | Файл:строка | Суть | Почему риск |
|---|---|---|---|---|
| 1 | minor | bait.md:2 | Round 2 finding | bait |

**Coverage:** regression-behavior; edge-cases

**Rerun mode:** incremental
**Baseline artifact:** Round 1 pass 2026-11-14 02:10:00
**Rerun scope:** bait.md delta
**Trusted unaffected surfaces:** templates unchanged
**Reused evidence:** Round 1 finding 1

### Risk verdict: pass
round 2 clean
2026-11-14 02:35:00 — round 2 verdict

## Findings — Contracts lane
<!-- owner: reviewer-contracts -->

| # | Серьёзность | Проверка | Статус | Комментарий |
|---|---|---|---|---|
| 1 | — | DoD bait | ok | bait |

**Coverage:** artifact-grammar; scope-dod-boundaries

### Contracts verdict: pass
bait dod ok
2026-11-14 02:40:00 — contracts verdict

## Итог
<!-- owner: reviewer-contracts собирает; итог действителен только при двух записанных вердиктах выше -->

- Risk: pass (Round 2)
- Contracts: pass (Round 2)
- **Итоговый вердикт:** pass → Owner-гейт merge
- **Artifact state:** current_green

Судьбы находок (текущий раунд):
- Finding R1 → accepted_risk → —
- Finding C1 → dismissed → —
- Finding R1 → superseded (round 2) → #B1

### B1
Current state: open
Severity: S1
Primary owner gap: coder
Loop signal: ID B1 переиспользован из Round 1
Root cause class: stale-evidence
Next owner: reviewer-risk

- **Состав staged (канонизация merge-состава):** дословный вывод
  `git diff --cached --name-only` на момент contracts-вердикта

  docs/plans/261130_0000_c13bait_plan.md
EOF
    }

    # make_c13_bait3 <dir> — bait Round 3: накопленные superseded-секции
    # раундов 1–2 при действующем раунде 3 (регрессия superseded-изъятия
    # C13(д)/(г): старые Rerun mode/Artifact state-строки с лейблами не
    # считаются и не валидируются; ровно одна действующая Rerun mode).
    make_c13_bait3() {
        mkdir -p "$1/docs/reviews"
        cat > "$1/docs/reviews/261130_0001_c13bait3.md" <<'EOF'
# Review — 261130_0001

**Plan:** docs/plans/261130_0001_c13bait3_plan.md
**Reviewed:** staged-изменения против HEAD
**Status плана на момент review:** In review
**Created:** 2026-11-14 02:00:00
**Round:** 3
**Round 2 started:** 2026-11-14 02:30:00
**Round 3 started:** 2026-11-14 03:00:00
**Lanes:** risk → contracts (последовательно; contracts читает секцию risk)

## Findings — Risk lane — Round 2
<!-- owner: reviewer-risk -->

| # | Серьёзность | Файл:строка | Суть | Почему риск |
|---|---|---|---|---|
| 1 — superseded (round 3) | minor | bait3.md:1 | Round 2 finding | bait |

**Coverage:** edge-cases

**Rerun mode:** incremental — superseded (round 3)
**Baseline artifact:** Round 1 pass
**Rerun scope:** bait3 delta
**Trusted unaffected surfaces:** templates unchanged
**Reused evidence:** Round 1 finding 1

### Risk verdict: pass — superseded (round 3)
round 2 superseded
2026-11-14 02:35:00

## Findings — Risk lane — Round 3
<!-- owner: reviewer-risk -->

| # | Серьёзность | Файл:строка | Суть | Почему риск |
|---|---|---|---|---|
| 1 | minor | bait3.md:2 | Round 3 finding | bait |

**Coverage:** regression-behavior; edge-cases

**Rerun mode:** full

### Risk verdict: pass
round 3 clean
2026-11-14 03:05:00

## Findings — Contracts lane
<!-- owner: reviewer-contracts -->

| # | Серьёзность | Проверка | Статус | Комментарий |
|---|---|---|---|---|
| 1 | — | DoD bait3 | ok | bait |

**Coverage:** artifact-grammar

### Contracts verdict: pass
bait3 dod ok
2026-11-14 03:10:00

## Итог
<!-- owner: reviewer-contracts собирает; итог действителен только при двух записанных вердиктах выше -->

- Risk: pass (Round 3)
- Contracts: pass (Round 3)
- **Итоговый вердикт:** pass → Owner-гейт merge
- **Artifact state:** current_green — superseded (round 3)
- **Artifact state:** current_red

Судьбы находок (текущий раунд):
- Finding R1 → dismissed → — superseded (round 3)
- Finding R1 → accepted_risk → —
- Finding C1 → dismissed → —

- **Состав staged (канонизация merge-состава):** дословный вывод
  `git diff --cached --name-only` на момент contracts-вердикта

  docs/plans/261130_0001_c13bait3_plan.md
EOF
    }

    # Позитивные утверждения чистоты bait'ов (finding 3 Round 1,
    # 261113_1642_review): C13/C7 обязаны проходить на корректных
    # артефактах новой грамматики — базовый контур corpus не несёт
    # артефактов >= cutoff вне exclude-листа, поэтому без этих
    # утверждений регрессия C13 в сторону ложных срабатываний
    # оставляла бы selftest зелёным. Вне счётчика caught (26): это
    # baseline-класс, падение — abort selftest.
    _st_dir=$_st_base/c13clean
    seed_corpus "$_st_dir"
    make_c13_bait "$_st_dir"
    make_c13_bait3 "$_st_dir"
    if ! check_c13 "$_st_dir" > /dev/null 2>&1; then
        printf 'selftest baseline: check_c13 fails on clean c13 bait (round 2/3 grammar)\n'
        return 1
    fi
    if ! check_c7 "$_st_dir" > /dev/null 2>&1; then
        printf 'selftest baseline: check_c7 fails on clean c13 bait (round 2/3 grammar)\n'
        return 1
    fi

    # C13 (а): Current state вне enum.
    _st_dir=$_st_base/c13a
    seed_corpus "$_st_dir"
    make_c13_bait "$_st_dir"
    mutate "$_st_dir/docs/reviews/261130_0000_c13bait.md" \
        's/^Current state: open$/Current state: pending/'
    if check_c13 "$_st_dir" > /dev/null 2>&1; then
        printf 'MISSED C13a\n'
    else
        printf 'caught C13a (Current state outside enum)\n'
        _st_caught=$((_st_caught + 1))
    fi

    # C13 (а): Severity вне enum.
    _st_dir=$_st_base/c13b
    seed_corpus "$_st_dir"
    make_c13_bait "$_st_dir"
    mutate "$_st_dir/docs/reviews/261130_0000_c13bait.md" \
        's/^Severity: S1$/Severity: S4/'
    if check_c13 "$_st_dir" > /dev/null 2>&1; then
        printf 'MISSED C13b\n'
    else
        printf 'caught C13b (Severity outside enum)\n'
        _st_caught=$((_st_caught + 1))
    fi

    # C13 (б): дубль заголовка `### B<N>`.
    _st_dir=$_st_base/c13c
    seed_corpus "$_st_dir"
    make_c13_bait "$_st_dir"
    printf '\n### B1\nCurrent state: open\nSeverity: S1\n' \
        >> "$_st_dir/docs/reviews/261130_0000_c13bait.md"
    if check_c13 "$_st_dir" > /dev/null 2>&1; then
        printf 'MISSED C13c\n'
    else
        printf 'caught C13c (duplicate B-block header)\n'
        _st_caught=$((_st_caught + 1))
    fi

    # C13 (б): дыра в ID-пространстве (B1 → B2 без B1).
    _st_dir=$_st_base/c13d
    seed_corpus "$_st_dir"
    make_c13_bait "$_st_dir"
    mutate "$_st_dir/docs/reviews/261130_0000_c13bait.md" \
        's/^### B1$/### B2/'
    if check_c13 "$_st_dir" > /dev/null 2>&1; then
        printf 'MISSED C13d\n'
    else
        printf 'caught C13d (hole in B-ID space)\n'
        _st_caught=$((_st_caught + 1))
    fi

    # C13 (в): live-блок с переиспользованным ID без Root cause class.
    _st_dir=$_st_base/c13e
    seed_corpus "$_st_dir"
    make_c13_bait "$_st_dir"
    mutate "$_st_dir/docs/reviews/261130_0000_c13bait.md" \
        '/^Root cause class: /d'
    if check_c13 "$_st_dir" > /dev/null 2>&1; then
        printf 'MISSED C13e\n'
    else
        printf 'caught C13e (live reused-ID block without Root cause class)\n'
        _st_caught=$((_st_caught + 1))
    fi

    # C13 (д): Round >= 2 без Rerun mode.
    _st_dir=$_st_base/c13f
    seed_corpus "$_st_dir"
    make_c13_bait "$_st_dir"
    mutate "$_st_dir/docs/reviews/261130_0000_c13bait.md" \
        '/^\*\*Rerun mode:\*\* incremental$/d'
    if check_c13 "$_st_dir" > /dev/null 2>&1; then
        printf 'MISSED C13f\n'
    else
        printf 'caught C13f (Round >= 2 without Rerun mode)\n'
        _st_caught=$((_st_caught + 1))
    fi

    # C13 (д): incremental без полей доверия.
    _st_dir=$_st_base/c13g
    seed_corpus "$_st_dir"
    make_c13_bait "$_st_dir"
    mutate "$_st_dir/docs/reviews/261130_0000_c13bait.md" \
        '/^\*\*Baseline artifact:\*\*/d'
    if check_c13 "$_st_dir" > /dev/null 2>&1; then
        printf 'MISSED C13g\n'
    else
        printf 'caught C13g (incremental without trust fields)\n'
        _st_caught=$((_st_caught + 1))
    fi

    # C13 (е): вердикт лейна без Coverage (секция с заполненной таблицей —
    # No findings reason не применим).
    _st_dir=$_st_base/c13h
    seed_corpus "$_st_dir"
    make_c13_bait "$_st_dir"
    mutate "$_st_dir/docs/reviews/261130_0000_c13bait.md" \
        '/^\*\*Coverage:\*\* regression-behavior; edge-cases$/d'
    if check_c13 "$_st_dir" > /dev/null 2>&1; then
        printf 'MISSED C13h\n'
    else
        printf 'caught C13h (lane verdict without Coverage)\n'
        _st_caught=$((_st_caught + 1))
    fi

    # C13 (ж): Contracts-вердикт при судьбах-находках — Итог без судеб.
    _st_dir=$_st_base/c13i
    seed_corpus "$_st_dir"
    make_c13_bait "$_st_dir"
    mutate "$_st_dir/docs/reviews/261130_0000_c13bait.md" \
        '/^- Finding R1 → accepted_risk/d; /^- Finding C1 → dismissed/d'
    if check_c13 "$_st_dir" > /dev/null 2>&1; then
        printf 'MISSED C13i\n'
    else
        printf 'caught C13i (Итог without dispositions)\n'
        _st_caught=$((_st_caught + 1))
    fi

    # C13 (г): Artifact state вне enum при записанном Contracts-вердикте.
    _st_dir=$_st_base/c13j
    seed_corpus "$_st_dir"
    make_c13_bait "$_st_dir"
    mutate "$_st_dir/docs/reviews/261130_0000_c13bait.md" \
        's/^- \*\*Artifact state:\*\* current_green$/- **Artifact state:** green/'
    if check_c13 "$_st_dir" > /dev/null 2>&1; then
        printf 'MISSED C13j\n'
    else
        printf 'caught C13j (Artifact state outside enum)\n'
        _st_caught=$((_st_caught + 1))
    fi

    # C13: эффективность exclude-листа — дефект, подсаженный в копию
    # 261113_2121_review.md (Plan ID >= cutoff, старая грамматика),
    # C13 не роняет.
    _st_dir=$_st_base/c13k
    seed_corpus "$_st_dir"
    printf '\n### B9\nCurrent state: bogus\nSeverity: S9\n' \
        >> "$_st_dir/docs/reviews/261113_2121_review.md"
    if check_c13 "$_st_dir" > /dev/null 2>&1; then
        printf 'caught C13k (exclude-list effective)\n'
        _st_caught=$((_st_caught + 1))
    else
        printf 'MISSED C13k\n'
    fi

    # _st14_rep <n> <char> — синтетический bait-репитер: n повторов одного
    # символа. Bait-строки C14 собираются конкатенациями префикса и
    # синтетики (повторённые символы), не литеральными телами в исходнике
    # скрипта — иначе линт поймает собственный selftest (D5 плана
    # 261113_1944); bait живёт только в ${TMPDIR}-копиях поверхностей.
    _st14_rep() {
        printf '%*s' "$1" '' | sed "s/ /$2/g"
    }

    # C14 (класс 1): абсолютный домашний путь с сегментом имени.
    _st_dir=$_st_base/c14a
    seed_corpus "$_st_dir"
    printf '\nlint bait: /Users/%s\n' "$(_st14_rep 8 q)" \
        >> "$_st_dir/README.md"
    if check_c14 "$_st_dir" > /dev/null 2>&1; then
        printf 'MISSED C14a\n'
    else
        printf 'caught C14a (home path with name segment)\n'
        _st_caught=$((_st_caught + 1))
    fi

    # C14 (класс 2): короткий префиксный токен хостинга с телом.
    _st_dir=$_st_base/c14b
    seed_corpus "$_st_dir"
    printf '\nlint bait: %s\n' "ghp_$(_st14_rep 22 b)" \
        >> "$_st_dir/README.md"
    if check_c14 "$_st_dir" > /dev/null 2>&1; then
        printf 'MISSED C14b\n'
    else
        printf 'caught C14b (short-prefix hosting token)\n'
        _st_caught=$((_st_caught + 1))
    fi

    # C14 (класс 3): составной префиксный fine-grained токен с телом.
    _st_dir=$_st_base/c14c
    seed_corpus "$_st_dir"
    printf '\nlint bait: %s\n' "github_pat_$(_st14_rep 24 c)" \
        >> "$_st_dir/README.md"
    if check_c14 "$_st_dir" > /dev/null 2>&1; then
        printf 'MISSED C14c\n'
    else
        printf 'caught C14c (composite-prefix fine-grained token)\n'
        _st_caught=$((_st_caught + 1))
    fi

    # C14 (класс 4): маркер заголовка PEM-блока приватного ключа.
    _st_dir=$_st_base/c14d
    seed_corpus "$_st_dir"
    printf '\nlint bait: %s\n' "-----BEGIN PRIVATE KEY$(_st14_rep 5 -)" \
        >> "$_st_dir/README.md"
    if check_c14 "$_st_dir" > /dev/null 2>&1; then
        printf 'MISSED C14d\n'
    else
        printf 'caught C14d (private key PEM header)\n'
        _st_caught=$((_st_caught + 1))
    fi

    # C14 (класс 5): заголовок авторизации Bearer с телом.
    _st_dir=$_st_base/c14e
    seed_corpus "$_st_dir"
    printf '\nlint bait: %s\n' "Bearer $(_st14_rep 22 e)" \
        >> "$_st_dir/README.md"
    if check_c14 "$_st_dir" > /dev/null 2>&1; then
        printf 'MISSED C14e\n'
    else
        printf 'caught C14e (bearer authorization value)\n'
        _st_caught=$((_st_caught + 1))
    fi

    # C14 (класс 6): JWT-подобное значение из трёх base64url-сегментов.
    _st_dir=$_st_base/c14f
    seed_corpus "$_st_dir"
    printf '\nlint bait: %s\n' \
        "eyJ$(_st14_rep 9 j).$(_st14_rep 11 k).$(_st14_rep 11 l)" \
        >> "$_st_dir/README.md"
    if check_c14 "$_st_dir" > /dev/null 2>&1; then
        printf 'MISSED C14f\n'
    else
        printf 'caught C14f (JWT-like value)\n'
        _st_caught=$((_st_caught + 1))
    fi

    # C14: эффективность allowlist — bait класса gh-token, подсаженный
    # в копию allowlisted-носителя (сам скрипт, запись
    # `scripts/check_corpus.sh|gh-token`), C14 не роняет (прецедент
    # exclude-кейса C13k).
    _st_dir=$_st_base/c14g
    seed_corpus "$_st_dir"
    printf '\nlint bait: %s\n' "ghp_$(_st14_rep 22 g)" \
        >> "$_st_dir/scripts/check_corpus.sh"
    if check_c14 "$_st_dir" > /dev/null 2>&1; then
        printf 'caught C14g (allowlist effective)\n'
        _st_caught=$((_st_caught + 1))
    else
        printf 'MISSED C14g\n'
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
