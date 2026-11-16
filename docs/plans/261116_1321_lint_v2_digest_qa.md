# Corpus lint v2: digest-verify и Q&A-парность

**Plan ID:** 261116_1321
**Status:** Merged
**Created:** 2026-11-16
**Owner gates:** merge (`In review` → `Merged`); вопросы `to=Owner` — по мере возникновения

> Шапка — parser-контракт: строки выше grep'аются Manager'ом. Не менять формат.
> Имя файла: `YYMMDD_HHMM_topic.md` (тема латиницей, слова через `_`).

## Как я понял задачу
<!-- owner: architect; 3–7 строк; обязательна при Architect intake -->
Две P2-строки бэклога (lint-v2-digest-verify, qa-lint) закрывают один класс
пробела: линт v1 проверяет форму, но не значение и не парность (прецедент
a2c2faf8↔a2c2faf9 — живой). Кураторские Architect-секции переприняты
верификацией против репозитория: cutoff 261113_1644 и 0 нарушений обоих
инвариантов подтверждены моим прогоном; найден и исправлен дефект git-механики
selftest/smoke (Solution п.4: перенос .git вместо init+commit — одно-коммитная
история роняла baseline на живых post-cutoff цитатах).

## Problem
<!-- owner: architect; пронумерованные пункты -->
1. C6 проверяет только форму `@`-хвостов (ровно 8 hex); значение-опечатка
   (класс a2c2faf8↔a2c2faf9, план 261111_1455, Tests-цитата T4) не ловится:
   роль может процитировать дайджест, которого никогда не существовало.
2. Парность Q&A не проверяется ничем, кроме ручного перечитывания на
   merge-гейте (§2, AGENTS.md): осиротевший `A#n` и открытый `Q#n` в слитом
   плане проходят молча.
3. Обе строки — P2 бэклога (lint-v2-digest-verify с 2026-11-11, qa-lint
   с 2026-11-11; грамматика закреплена планом 261113_2121), осознанно
   отложенные из 261111_2243 как «grep-v1 не по зубам» — фактическая
   проверка на прототипе показала, что POSIX-grep+shasum+git-log достаточно.

## Solution / Decisions
<!-- owner: architect; решения уровня «что и почему», без детализации -->
1. **C15 «digest-verify»**: каждая digest-цитата intake-строки (якорь
   `^- Intake (`) планов ≥ cutoff `261113_1644` обязана состоять во множестве
   исторических состояний файла: дайджесты всех коммитов, трогавших файл
   (`git log --format=%H -- <f>` → `git show <H>:<f>`), ∪ текущий shasum.
   Легитимная смена контракта в полёте проходит (старое состояние реально
   существовало — роль перечитала и записала новую строку); опечатка —
   значение, которого никогда не было → FAIL.
2. **Cutoff C15 = 261113_1644** (эмпирическая граница чистоты, прототип
   2026-11-16: 10 цитат 8 планов ≤ 261113_1642 ссылаются на состояния
   рабочего дерева/истории до перезаписи; ≥ 261113_1644 — 0 расхождений).
   Pre-cutoff — excluded с выводом (прецедент C4/C5/C11/C13).
3. **C16 «qa-lint»**, скоуп — секция `## Q&A log`, cutoff как у C5
   (≥ 261111_1455), якоря `^- Q(` / `^- A(`:
   (а) осиротевший `A(<кто>#<n>)` без парного `Q(<роль>#<n>)` в той же
   секции — FAIL при любом статусе;
   (б) непарный `Q#n` без `A#n` ниже — FAIL только для статусов
   Merged/Done (в активных планах открытый Q легитимен — ждёт ответа;
   Superseded исключён — заморожен в полёте).
   Безномерные `- A(owner):` (записи решений Owner, прецедент ночных
   делегаций) — не кандидаты парности. Упоминания `Q(...)`/`A(...)` в прозе
   вне секции не считаются.
4. **Git-зависимость C15**: fast-path — 0 цитат в скоупе → проверка
   проходит без обращения к git (верифицируется на корпусе без post-cutoff
   цитат — напр. мини-корпус из smoke-инстанса шаблона; полный --smoke несёт
   живые цитаты и идёт реальным код-путём); цитаты есть, но корень корпуса —
   не git-репозиторий → fail-loud с диагностикой (не молчаливый skip).
   `seed_corpus` переносит git-историю исходного репо в seeded-копию (копия
   `.git`): selftest/smoke гоняют C15 по реальному код-пути на живых планах —
   post-cutoff цитаты входят в перенесённую историю (membership-прогон
   2026-11-16), дефектные кейсы подсаживают опечатку поверх; trap-очистка
   temp изолирует и `.git`. Отсутствие `.git` у исходного репо при selftest —
   fail-loud (selftest requires git history), не skip.
   rejected alternative: git init+commit в копии — одно-коммитная история
   несёт только текущее состояние каждого файла, а планы ≥ 261113_1644
   цитируют не-текущие исторические дайджесты (напр. architect.md@65060cee
   у 261113_1644 при текущем f6cd38e4) — C15 FAILил бы baseline selftest
   и smoke на чистой копии.
5. **Selftest +3 кейса**: C15 опечатка-дайджест; C16 осиротевший A; C16
   открытый Q в Done-плане; счётчик 33 → 36. Заголовок скрипта: набор
   утилит += git; реестр проверок += ссылки на этот план.
6. Нумерация C15/C16 — продолжение реестра проверок; занятие C17 под
   release-notes-lint (P3-строка) вперёд не делается.

## Scope
<!-- owner: architect (границы), planner (уточняет); список изменений; пункты, реализующие внешние требования, несут метку [R: <ID>]; план, меняющий shared-контракт, до handoff несёт fan-out инвентарь -->
Изменения:
- `scripts/check_corpus.sh`: +`check_c15`, +`check_c16` (реестр, cutoff'ы
  константами по прецеденту `REVIEW_CUTOFF`); selftest +3 кейса (33→36);
  `seed_corpus` += перенос `.git` (полная git-история); заголовок — утилиты
  += git, источники C15/C16.
- Backlog-промоушен при активации плана (зона Manager): строки
  `lint-v2-digest-verify`, `qa-lint` → `status=promoted`, `plan=261116_1321`
  (+ пересборка index); терминальное закрытие при closeout (harvest).
Fan-out инвентарь (§5, носитель — shared-контракт check_corpus.sh):
- зависимые проверки: selftest (общий счётчик), smoke (реальный код-путь
  C15 по перенесённой git-истории копии), fast-path C15 (корпус без
  post-cutoff цитат), baseline selftest (C15/C16 обязаны быть зелёными
  на чистой копии с перенесённой git-историей);
- зависимые доки: нет — README/CONTRIBUTING счётчики проверок не
  перечисляют; упоминание «33/33» в docs/model_run.md — append-only нарратив
  модельного прогона, не правится;
- consumer-пути: CI `.github/workflows/corpus.yml` (lint-матрица запускает
  скрипт; static-джоба — smoke) — правок не требует: git доступен в
  checkout, smoke использует перенесённую git-историю копии (реальный
  код-путь C15);
- AGENTS.md / шаблон плана — без правок: C16 усиливает существующий §2
  merge-гейт инвариант, грамматику не меняет.

## Out of scope
<!-- owner: architect -->
1. `stale-intake-digest` (P2, отдельная строка бэклога): «дайджест реально
   существовал, но контракт сменился ПОСЛЕ intake» — membership-проверка
   сознательно не ловит (другой класс); отдельный план при появлении живого
   прецедента.
2. `hex-typo-t4` (P3): опечатка живёт в Tests-цитате, не в intake-строке —
   C15 её не видит; строка остаётся открытой до первого плана, трогающего
   Tests (append-only).
3. `lint-robustness` (heredoc-раскрытие, cwd-чувствительность, P3) —
   отдельная строка, здесь не трогаем.
4. Верификация `@<8hex>`-упоминаний вне intake-строк (миграционные записи
   Evidence `old→new`): обе стороны — реальные состояния, но скоуп v2
   сознательно intake-only.
5. Release-notes-lint и прочие кандидаты v3 — нумерация не занимается.

## Acceptance criteria / DoD
<!-- owner: planner; чек-лист проверяемых исходов -->
- [ ] D1: C15 ловит опечатку-значение: intake-цитата с несуществующим
      дайджестом в плане ≥ 261113_1644 → FAIL с диагностикой (файл, строка,
      цитата, множество-источник).
- [ ] D2: C15 cutoff: планы < 261113_1644 с цитатами вне исторических
      множеств → excluded-вывод, не FAIL (прецедент C4).
- [ ] D3: C15 fast-path: корпус без intake-цитат в скоупе → pass без
      обращения к git; полный `--smoke` идёт реальным код-путём (git
      задействован, перенесённая история копии) → clean (Solution п.4).
- [ ] D4: C15 fail-loud: цитаты в скоупе + корень без git-репозитория →
      явная диагностика, exit ≠ 0 (не молчаливый skip).
- [ ] D5: `seed_corpus` переносит `.git` исходного репо в seeded-копию
      (полная git-история, не init+commit); selftest/smoke гоняют C15 по
      реальному код-пути (не стаб); trap-очистка temp удаляет копию
      целиком, включая `.git`.
- [ ] D6: C16 ловит осиротевший `A(<кто>#<n>)` без парного Q — FAIL при
      любом статусе плана ≥ cutoff 261111_1455.
- [ ] D7: C16 ловит непарный `Q#n` в Merged/Done; активные статусы и
      Superseded — не FAIL.
- [ ] D8: C16 скоуп: только секция `## Q&A log`, только якоря `^- Q(` /
      `^- A(`; безномерные `- A(owner)` и прозаические упоминания вне
      секции не считаются.
- [ ] D9: selftest — `selftest: 36/36 caught`, exit 0; baseline чист,
      включая C15/C16 на seeded-копии с перенесённой `.git`-историей
      (механика D5, текст исхода — Solution п.5).
- [ ] D10: чистый прогон корпуса: `scripts/check_corpus.sh` →
      `corpus: clean`, exit 0 на дереве с этим планом (все текущие
      планы + Draft).
- [ ] D11: merge-коммит: CI corpus-lint зелёный (lint-матрица ubuntu/macos
      + static: shellcheck/actionlint/smoke). Проверка живёт на merge-гейте
      после Owner-«да» — вне фазы Coder.
- [ ] D12: selftest при отсутствии `.git` у исходного репо → fail-loud
      («selftest requires git history»), не skip (Solution п.4).
- [ ] D13: заголовок `scripts/check_corpus.sh`: перечень утилит включает
      git; реестр проверок содержит C15/C16 со ссылкой на план 261116_1321
      (Solution п.5).

## Tests / Commands
<!-- owner: planner (задание), coder (заполняет факт); каждый Dn покрывается строкой с меткой (Dn) -->
- (D1) Temp-корпус с git-историей (два коммита разных состояний AGENTS.md)
  и планом ≥ 261113_1644, intake-цитата: дайджест AGENTS.md — значение,
  отсутствующее в истории и текущем дереве (дайджест роль-дока — текущий
  shasum) → `check_c15` FAIL с диагностикой (файл, строка, цитата);
  замена на дайджест первого коммита (реальное историческое состояние)
  → pass.
  Результат (2026-11-16 14:41): пройдено. Фаза 1 —
  `docs/plans/261114_0100_t.md:7: intake digest AGENTS.md@deadbeef not in
  historical set of AGENTS.md (members: a2528410 7210adf9 a2528410)`,
  rc 1; фаза 2 (deadbeef → a2528410, дайджест первого коммита) — rc 0.
- (D2) Прогон C15 на текущем корпусе: 8 pre-cutoff планов (261111_0320 …
  261113_1642) в excluded-выводе, 0 FAIL.
  Результат (2026-11-16 14:43): пройдено — excluded-строк ровно 8
  (261111_0320 … 261113_1642), rc 0; виден и в полном прогоне (D10)
  под `OK C15 digest-verify`.
- (D3) Два прогона: (а) fast-path — temp-корпус только из инстанса
  шаблона плана (Plan ID ≥ 261113_1644, Q&A log пуст — intake-цитат нет)
  + PATH-заглушка git (shim-скрипт, аппендящий вызовы в лог-файл) →
  C15 pass, exit 0, лог вызовов git пуст; (б) `scripts/check_corpus.sh
  --smoke` → `smoke: clean`, exit 0 — реальный код-путь: seeded-копия
  несёт живые post-cutoff цитаты (9 планов ≥ 261113_1644) и перенесённую
  `.git`-историю.
  Результат (2026-11-16 14:41/14:43): (а) rc 0, лог вызовов git пуст
  (shim не сработал ни разу); (б) `smoke: plan 261130_0000_smoke.md
  instantiated from docs/plans/_template.md` → `OK C1` … `OK C16`
  (C15 с 8 excluded-строками и membership по перенесённой истории —
  реальный код-путь) → `smoke: clean`, exit 0.
- (D4) Temp-корпус с планом ≥ 261113_1644 с intake-цитатой, без `.git`
  в корне (скрипт запускается из копии: `<tmp>/scripts/check_corpus.sh`)
  → прогон FAIL с диагностикой C15 fail-loud, exit ≠ 0.
  Результат (2026-11-16 14:45): пройдено — seeded-копия минус `.git`,
  запуск `<tmp>/copy/scripts/check_corpus.sh` → единственный провал C15:
  `c15: digest quotes in scope but corpus is not a git repository:
  <tmp>/copy (selftest/smoke seeded-copies carry .git; …)`; итог
  `corpus: 1 failures`, exit 1.
- (D5) После selftest-посева: `git -C <copy> rev-list --count HEAD` ==
  `git rev-list --count HEAD` исходного репо (полная история перенесена);
  post-cutoff intake-цитаты seeded-копии membership-зелёные (базис D9);
  после завершения selftest temp-путь (с `.git`) не существует.
  Результат (2026-11-16 14:45): пройдено — rev-list исходного = 43,
  копии = 43; `check_c15 <copy>` rc 0 (все post-cutoff цитаты копии во
  множествах); после `--selftest`/`--smoke` путей
  `${TMPDIR:-/tmp}/check_corpus_selftest.*` / `check_corpus_smoke.*`
  не существует (trap удаляет копии целиком, включая `.git`).
- (D6) Мутация seeded-копии: строка `- A(manager#9):` в `## Q&A log`
  плана ≥ cutoff без парного Q → C16 FAIL.
  Результат (2026-11-16 14:41): пройдено — ручная мутация 261115_2254
  (первый план ≥ cutoff с `- NO QUESTIONS`) → 8 диагностик
  `orphan answer A#9 (section line N): no matching Q#9 in Q&A log`,
  rc 1; автоматический кейс C16a в selftest (D9) ловит тот же класс.
- (D7) Мутации: план со статусом Done + `- Q(coder#5):` без A → C16 FAIL;
  тот же Q в статусе In review → pass; план Superseded + непарный Q →
  pass.
  Результат (2026-11-16 14:45): пройдено — [Done] rc 1,
  `open question Q#5 (section line 519): no matching A#5 below
  (status Done)`; [In review] rc 0; [Superseded] rc 0; автоматический
  кейс C16b в selftest (D9) закрывает Done-ветку.
- (D8) Мутации: `- Q(coder#1)` в прозе Evidence (вне секции `## Q&A log`)
  → C16 pass; безномерный `- A(owner):` в секции → не FAIL.
  Результат (2026-11-16 14:45): пройдено — строка `- Q(coder#1): …`
  дописана в конец файла (вне секции): rc 0; замена `- NO QUESTIONS` →
  `- A(owner): …` (безномерный, в секции): rc 0.
- (D9) `scripts/check_corpus.sh --selftest` → `selftest: 36/36 caught`,
  exit 0 (baseline-этап зелёный до подсадки дефектов).
  Результат (2026-11-16 14:40): пройдено — `caught C1` … `caught C14g`
  + `caught C15 (intake digest outside historical set)` + `caught C16a
  (orphan answer without paired Q)` + `caught C16b (open question in
  Done plan)`; `selftest: 36/36 caught`, exit 0; baseline-этап
  (включая check_c15/check_c16 на чистой seeded-копии с перенесённой
  `.git`-историей) зелёный.
- (D10) `scripts/check_corpus.sh` (из корня репо) → `corpus: clean`,
  exit 0.
  Результат (2026-11-16 14:43): пройдено — `OK C1` … `OK C16`
  (C15 с excluded-выводом 8 планов, C16 с excluded-выводом 2 планов),
  `corpus: clean`, exit 0, на дереве с этим планом и его intake-строками.
- (D11) После push merge-коммита: `gh run list` → corpus-lint на
  merge-коммите success (lint ubuntu/macos + static; зона merge-гейта,
  вне фазы Coder).
  Результат: N/A в фазе Coder (merge-гейт после Owner-«да»; AC-to-test
  исход N/A, Evidence 14:26:40).
- (D12) Temp-копия исходного репо без `.git` (планы с post-cutoff
  цитатами на месте, скрипт запускается из копии): `<tmp>/scripts/
  check_corpus.sh --selftest` → FAIL с диагностикой «selftest requires
  git history», не skip.
  Результат (2026-11-16 14:45): пройдено — `seed_corpus: selftest
  requires git history: <tmp>/copy/.git missing (C15 membership needs
  commit-time states)`, exit 1 (fail-loud до какого-либо посева).
- (D13) Осмотр заголовка: `grep -n git scripts/check_corpus.sh | head -5`
  → строка блока утилит заголовка перечисляет git; `grep -n 261116_1321
  scripts/check_corpus.sh` → непусто (ссылка реестра проверок на план).
  Результат (2026-11-16 14:43): пройдено — `grep -n git | head -5`
  включает строку 21 `# POSIX sh + grep/sed/cut/head/tail/mktemp/git/
  shasum (git/shasum — C15: …)`; `grep -n 261116_1321` — 7 строк
  (реестр источников, DIGEST_CUTOFF-комментарий, комментарии C15/C16/
  seed_corpus, selftest-кейс).

## Changes (by area)
<!-- owner: coder; фактические изменения по областям; заполняется в ходе работы -->
- `scripts/check_corpus.sh` — единственный изменённый файл кода
  (2127 → 2437 строк; git diff: +323/−13):
  - Заголовок: реестр источников += план 261116_1321 (C15/C16, cutoff'ы,
    selftest 33→36, перенос .git); блок утилит += git/shasum (носитель —
    C15) с уточнённой формулировкой «python не используется»; описания
    режимов синхронизированы (excluded-печать C4/C5/C11/C13/C15/C16;
    selftest C1–C16, 36/36; smoke C1–C16; selftest-абзац упоминает
    перенесённую .git-историю). Версионный маркер «lint v1» в строке 3
    сохранён — переименование вне перечня Solution п.5 (Scope).
  - Константа `DIGEST_CUTOFF=261113_1644` (cutoff C15, прецедент
    REVIEW_CUTOFF) с комментарием-обоснованием.
  - `check_c15` (digest-verify): двухфазная схема — сбор цитат intake-строк
    секции `## Q&A log` планов ≥ DIGEST_CUTOFF (маппинг короткого имени
    цитаты на реальный путь носителя: `<role>.md` → `docs/roles/<role>.md`,
    `AGENTS.md` → корень; `<!--`-строки исключены по прецеденту C5/C11),
    затем membership-сверка; fast-path — 0 цитат → rc 0 без единой
    git-команды; цитаты есть + корень не git-репозиторий → fail-loud
    rc 1 с диагностикой; FAIL-диагностика несёт файл:строку, цитату и
    members-множество. Pre-cutoff планы с intake-строками — excluded-вывод
    (ровно 8 на текущем корпусе).
  - `_c15_set_of` + `_C15_CACHE`: множество 8hex-дайджестов файла =
    `git log --format=%H -- <f>` → `git show <H>:<f> | shasum -a 256`
    по коммитам ∪ текущий shasum рабочего дерева; кэш по пути за прогон.
  - `check_c16` (qa-lint): скоуп — секция `## Q&A log` планов ≥ CUTOFF,
    якоря `^- Q(`/`^- A(` с извлечением номера `#n` (`sed -n
    's/^- [AQ]([a-z-]*#\([0-9][0-9]*\)).*/\1/p'`; безномерные A(owner)
    не матчатся); ветка (а) — осиротевший A#n без парного Q#n в секции,
    FAIL при любом статусе; ветка (б) — Q#n без A#n с большим номером
    строки ниже, FAIL только при статусе Merged/Done (позиционная
    проверка «A ниже Q», прецедент пары Q(coder#1)↔A(manager#1)
    плана 261113_1642). Pre-cutoff — excluded-вывод.
  - `run_all`: + `report C15 digest-verify`, `report C16 qa-lint`.
  - `seed_corpus`: fail-loud `selftest requires git history` (stderr,
    exit 1) при отсутствии `$ROOT/.git` до какого-либо посева;
    `cp -R "$ROOT/.git" "$1/.git"` — перенос полной истории (не
    init+commit, Solution п.4); комментарий объясняет rejected
    alternative.
  - `selftest`: baseline-список += check_c15, check_c16; `_st_total` 33 →
    36; +3 кейса — C15 (мутация `^\(- Intake .*AGENTS\.md@\)<8hex>` →
    `deadbeef` в первом post-cutoff плане с intake, bait проверен на
    0 пересечений с множествами), C16a (`- NO QUESTIONS` →
    `- A(manager#9): …` в первом плане ≥ CUTOFF с этой строкой),
    C16b (статус → Done + `- NO QUESTIONS` → `- Q(coder#5): …`).
    Негативные контроли C16 (In review/Superseded → pass, проза вне
    секции, безномерный A(owner)) — ручными прогонами Tests (D7)/(D8),
    не в счётчике caught (Solution п.5 фиксирует +3 кейса).
  - Дефекты, найденные и исправленные в ходе реализации (зона Coder):
    (1) извлечение цитат по короткому имени роняло membership (git-история
    живёт по `docs/roles/<role>.md`) — добавлен маппинг имя→путь;
    (2) selftest-мутация C15 — BSD-sed BRE: capture-группа `\(…\)` и
    литеральный префикс внутри группы, иначе sed стирал `- Intake `
    префикс строки.
- Тестовый harness (вне репо, `/tmp`): вызов одиночных проверок —
  source библиотечной вырезки скрипта (`sed -n '1,/^# ---… main$/p' |
  . `) с `ROOT=<repo>`: main-диспетчер не вырезается, сам скрипт под
  тесты не менялся; temp-корпуса через mktemp, очистка в каждой команде.
- Наблюдение (не изменение): smoke-прогон печатает плавающие
  `printf: write error: Broken pipe` (bash builtin `printf | grep -q`
  в существующем коде C12/C13; воспроизведено на HEAD-версии скрипта
  до правок — существующее поведение, на rc/вердикты не влияет) —
  класс lint-robustness (Out of scope п.3), см. Follow-ups.

## Evidence (chronological, append-only)
<!-- owner: все роли + CENSOR; событийные записи с датой и локальным временем -->
- 2026-11-16 13:30:00 — Curator: прототипирование инвариантов до драфта.
  (а) Membership-прогон: собраны множества исторических дайджестов AGENTS.md
  (16 состояний) и 5 роль-доков; все intake-цитаты всех планов сверены —
  10 цитат 8 планов (261111_0320 … 261113_1642) вне множеств, все планы
  ≥ 261113_1644 чисты → граница cutoff. (б) Парность Q#n→A#n: скоуп-корректный
  прогон (секция `## Q&A log`, якоря `^- Q(`/`^- A(`) — 0 нарушений по всем
  планам (первичный наивный прогон без скоупа дал ложные срабатывания на
  прозаических упоминаниях в Evidence плана 261113_1642 — зафиксировано как
  требование якорей в D8). (в) Происхождение: драфт создан кураторской
  сессией по прецеденту 261113_2121; зоны Architect/Planner предзаполнены и
  переприсваиваются на intake (не rubber-stamp).
- 2026-11-16 13:53:01 — Manager: план активирован вызовом Owner `/planfaktor-run docs/plans/261116_1321_lint_v2_digest_qa.md` (валидации 1a пройдены: файл/Plan ID/статус Draft/инвариант одного активного — прочие 16 планов Done; спец-указаний в сопроводительном сообщении нет). Ветвление Draft: кураторский черновик §1(g) — Architect-секции непусты, Planner-зоны предзаполнены, intake роли нет → диспатч Architect (PHASE=work) на перепринятие зон, не rubber-stamp. Промоушен backlog при активации (зона Manager по Solution п.2 Scope, урок 261115_2254): строки id=lint-v2-digest-verify и id=qa-lint → status=promoted, plan=261116_1321, пересборка index — исполнен этим же шагом
- 2026-11-16 14:03:35 — Architect: intake (AGENTS.md@822b4300 architect.md@f6cd38e4); статус сверен с конвертом (Draft = PRE_STATUS_LINE). Кураторские зоны переприняты верификацией против репозитория (untrusted input), не rubber-stamp. Подтверждено независимо: (1) membership-прогон — множества исторических дайджестов (git log/show по 6 контрактам: AGENTS.md 16 коммитов, роль-доки 5–8) ∪ текущие shasum; все цитаты вне множеств — 8 планов ≤ 261113_1642, ровно 10 уникальных AGENTS.md-значений (34e1cecc, b5b5cdf8, ef98b1f0, 5cc19f0c, df2c36d9, e2b75ce4, 7c0b4697, c4378983, 34563f1a, f155be52; вне-множественные роль-доковые значения — в тех же планах); планы ≥ 261113_1644 чисты обоими дайджестами цитат — цитируемые 8 значений (7ec6d0f4, eb9cffe8, ae39388a, 3b937eed, e6c8eec4, 1f66a38f, dee70da5, 822b4300) реальные исторические состояния → cutoff 261113_1644 подтверждён. (2) Парность Q#n→A#n (секция `## Q&A log`, якоря `^- Q(`/`^- A(`): в корпусе 1 номерная пара Q(coder#1)↔A(manager#1) плана 261113_1642 — закрыта; 4 безномерных `- A(owner)` (261111_0320, 261111_0427, 261113_1642); 0 нарушений. (3) Прецедент a2c2faf8↔a2c2faf9 — 261111_1455 (строки 493/997/1174/1250/1454, Tests-цитата T4). (4) check_corpus.sh: реестр C1–C14 (C15/C16 — продолжение), `_st_total=33`, seed_corpus без git, smoke инстанцирует план из шаблона (Q&A log шаблона пуст), REVIEW_CUTOFF — прецедент cutoff-константы, C5 использует CUTOFF=261111_1455. (5) corpus.yml: lint-матрица ubuntu/macos (default + selftest) + static (shellcheck/actionlint/smoke). (6) docs/model_run.md:81 «33/33» — append-only нарратив; README/CONTRIBUTING счётчиков проверок не перечисляют. (7) backlog: lint-v2-digest-verify/qa-lint status=promoted plan=261116_1321 (промоушен Manager 13:53:01 сверен); stale-intake-digest/hex-typo-t4/lint-robustness/release-notes-lint — status=open, соответствуют Out of scope п.1–5. (8) Кураторский прецедент 261113_2121 (§1(g) + грамматика Q#n Solution п.8); урок промоушена 261115_2254 (Evidence 22:54:11, 02:56:14). ДЕФЕКТ кураторского Solution п.4 найден и исправлен в зоне Architect: git init+commit в seeded-копии несовместим с membership-инвариантом — планы ≥ 261113_1644 цитируют не-текущие исторические дайджесты (261113_1644: architect.md@65060cee при текущем f6cd38e4; AGENTS@7ec6d0f4/ae39388a/3b937eed при текущем 822b4300), одно-коммитная история копии несла бы только текущие состояния → C15 FAILил бы baseline selftest/smoke на чистой копии; фикс — перенос `.git` в seeded-копию, fast-path верифицируется на корпусе без post-cutoff цитат; отклонённая альтернатива зафиксирована в Solution п.4 (rejected alternative), Fan-out синхронизирован. Рассинхрон D3/D5/D9 (зона Planner, кураторский черновик) с исправленным п.4 — objection в Objections log, blocker: no
- 2026-11-16 14:04:41 — Architect: фаза завершена — зоны Architect (Как я понял задачу / Problem / Solution / Scope+Fan-out / Out of scope) переприняты верификацией против репозитория и подтверждены; дефект git-механики Solution п.4 исправлен (перенос `.git` вместо init+commit, rejected alternative зафиксирован); Fan-out синхронизирован; открытых вопросов к Owner нет (objection к Planner-зоне — не блокер). Handoff: **Status:** Ready for Planner.
- 2026-11-16 14:08:03 — (Role CENSOR) OK: Ready for Planner validated; current=true
Censor dispatch id: censor:architect:261116_140545
Observations:
- Second opinion: шапка перечитана из файла — `**Status:** Ready for Planner` единственная (строка 4), Plan ID 261116_1321 = префикс имени файла; свои секции сверены с Solution п.4 (перенос `.git`, rejected alternative) и Fan-out — согласованы; Evidence 14:03:35/14:04:41 и Q&A intake 14:03:35 (SUGGESTIONS: 1 / OBJECTIONS: 1) — ссылки на записи логов валидны; Objections 14:03:35 цитируется дословно.
- Counterfactuals considered: (1) остаточные несогласования фикса п.4 — grep `init+commit` по плану нашёл пропущенный кураторский хвост в Scope-Изменения («`seed_corpus` += git init+commit») — прямое противоречие с п.4, устранено (Fix 1); (2) рассинхрон DoD шире зафиксированного objection'а — D1–D11 и Tests прогнаны против п.4: от seeded-механики зависят только D3/D5/D9 — полностью покрыты objection 14:03:35; (3) ошибочность собственного membership-прогона — кросс-чек классификации 18 AGENTS.md-значений IN/OUT побайтово сошёлся с границей 261113_1642/261113_1644, architect.md@65060cee (261113_1644) проверен напрямую (историческое, не текущее f6cd38e4) — основание фикса верно; (4) дубль статусной строки после handoff — grep `^\*\*Status` : одна.
- Addendum (new angle): лимит роль-дока «3–7 строк» для `## Как я понял задачу` — текст занимал 10 физических строк, ужат до 7 с сохранением всех смыслов (Fix 2); Token usage (строка Manager 14:05:45) — зона Manager, цензором не тронута; ссылка «Solution п.1 Scope» в Follow-ups — неточная нумерация в чужой зоне, семантика однозначна (промоушен-пункт Scope), не блокирует.
- Fixes: (1) Scope-Изменения: «`seed_corpus` += git init+commit» → «`seed_corpus` += перенос `.git` (полная git-история)» — устранено противоречие с Solution п.4; (2) «Как я понял задачу» ужата 10 → 7 строк (лимит роль-дока).
- Final censor verdict: OK
- 2026-11-16 14:15:51 — Planner: finalize completion-pass (до простановки статуса, роль-док шаг 3). Оба дословных вопроса-самопроверки: (1) «что Coder/Reviewer будут угадывать и где блокер переживёт handoff» — ответ «ничего существенного»: C15-механика membership задана Solution п.1 (git log → git show ∪ текущий shasum), cutoff'ы — константами по прецеденту REVIEW_CUTOFF (Scope), C16-парность — по номеру #n (прецедент Q(coder#1)↔A(manager#1) плана 261113_1642), статусные множества — D7 + enum check_c1; выбор имён констант/формат excluded-вывода — зона реализации по прецедентам, не решение; (2) «не осталось ли доказательство implicit» — ответ «нет»: каждый исход несёт материальный носитель — «без обращения к git» = PATH-заглушка с лог-файлом (D3а), «полная история» = `rev-list --count` обеих сторон (D5), «trap удаляет .git» = отсутствие temp-пути после прогона (D5), «membership-зелёные цитаты копии» = baseline-этап selftest exit 0 (D9), D11 — `gh run list` на merge-коммите (помечен вне фазы Coder), D13 — grep-команды. Покрытие DoD↔Tests 1:1 (D1–D13 ↔ (D1)–(D13)). Вердикт: дефектов Planner-зоны не найдено, handoff возможен.
- 2026-11-16 14:16:19 — Planner: фаза завершена — DoD (D1–D13) и Tests ((D1)–(D13), покрытие 1:1) переприняты верификацией против репозитория, не rubber-stamp: сверены seed_corpus (строки 1352–1360 scripts/check_corpus.sh — .git не копируется, перенос требуется), механика smoke (план 261130_0000 инстанцируется поверх полной seeded-копии — живые post-cutoff цитаты), 8 pre-cutoff планов с intake-строками (261111_0320 … 261113_1642), пустой Q&A log шаблона (носитель fast-path-корпуса), CI-джобы corpus.yml. Architect objection 14:03:35 исполнен в зоне Planner: D5 переписан на перенос `.git` (полная история, не init+commit) + trap-очистка `.git`; D3 разделён на fast-path (отдельный корпус без post-cutoff цитат, git не вызывается — PATH-заглушка) и полный `--smoke` по реальному код-пути; D9 — механика baseline через перенесённую историю (текст исхода 36/36 сохранён). Решения Architect детализированы до проверяемых исходов: +D12 (selftest без `.git` у исходного — fail-loud «selftest requires git history», Solution п.4), +D13 (заголовок: утилиты += git, реестр C15/C16 со ссылкой на план, Solution п.5). Ответов Q&A к переносу нет — открытых Q в логе не было; решения Architect не менялись. Handoff: **Status:** Ready for Coder.
- 2026-11-16 14:19:07 — (Role CENSOR) OK: Ready for Coder validated; current=true
Censor dispatch id: censor:planner:261116_141707
Observations:
- Second opinion: шапка перечитана из файла — `**Status:** Ready for Coder` (строка 4, единственная по якорю `^\*\*Status:\*\*`, grep-подтверждено); PRE_STATUS_LINE конверта совпадает; DoD↔Tests покрытие 1:1 — 13 пунктов `^- [ ] D*` ↔ 13 меток `^- (D*)` (D1)–(D13) подряд без пропусков, каждая с ожидаемым исходом; запись finalize completion-pass в Evidence 14:15:51 с вердиктом — раньше простановки статуса 14:16:19 (условие §2); Q&A log перечитан — Q-строк нет → открытых вопросов нет; `## Follow-ups` непуст (промоушен/терминальное закрытие — зона Manager); чужие секции (Как я понял задачу, Problem, Solution, Scope+Fan-out, Out of scope, Objections log) не редактировались ни одним правкой Planner'а — все Edit'ы легли в зоны Planner (шапка-статус по §2, DoD, Tests) и append-only логи (Q&A log, Evidence).
- Counterfactuals considered: (1) остаточный рассинхрон с Solution п.4 — grep `init` по плану: вхождения только в зонах Architect (строки 18/68, включая rejected alternative) и в D5 как явное отрицание «не init+commit»; Tests чисты; (2) тест (D1) — не отвергнутая альтернатива: двух-коммитный temp-репо создаётся намеренно и достаточен по построению, отвергалась init+commit-механика seed_corpus для selftest/smoke-копий (одно-коммитная история vs полная перенесённая); (3) собственные intake-цитаты плана (822b4300/f013858b — текущие состояния, свежий shasum сверен) → D10 не сломается записями этого плана; (4) «9 планов ≥ 261113_1644» в (D3б) пересчитано по корпусу (261113_1644, 1943, 1944, 2121, 261114_0151, 261115_1610, 2252, 2254, 261116_1321); (5) переносы строк внутри inline-команд (D12)/(D13) — склейка тривиальна, команды однострочны; (6) Digest-миграция между итерациями — AGENTS.md@822b4300 planner.md@f013858b неизменны (14:12:29 → 14:18:10), записей миграции в Evidence не требуется.
- Addendum (new angle): D6 cutoff 261111_1455 сверен с CUTOFF=261111_1455 (строка 49 scripts/check_corpus.sh) и Solution п.3 «cutoff как у C5»; D11 помечен «вне фазы Coder» — Coder закроет исходом `N/A (why=merge-гейт)` без тупика §5 AC-to-test; текущий план после реализации сам станет носителем C16/C15: Q-строк в его Q&A log нет (C16-зелёность), intake-цитаты — текущие состояния (C15-зелёность) — линт не уроняется собственным планом.
- Fixes: none (NO FINDINGS; сверено машинно: единственность статусного якоря, 13/13 меток Tests, grep init по зонам, число post-cutoff планов, свежие digest'ы контрактов; сверено чтением: даты finalize<status, вердикт finalize-записи, непустота Follow-ups, целостность чужих секций)
- Final censor verdict: OK
- 2026-11-16 14:20:16 — Manager: Q&A чист, открытых вопросов к Owner нет, статус In progress
- 2026-11-16 14:26:10 — Coder: факты окружения до правок (сверка против репозитория, untrusted input — ничего из плана не принято на веру): baseline `scripts/check_corpus.sh --selftest` → `selftest: 33/33 caught`, exit 0; pre-DIGEST_CUTOFF планы с intake-строками — ровно 8 (261111_0320 … 261113_1642), post-cutoff с intake — 9 (261113_1644 … 261116_1321); первый post-cutoff носитель цитат — 261113_1644 (AGENTS.md@7ec6d0f4/ae39388a/3b937eed, architect/planner/coder/reviewer-*); первый план ≥ CUTOFF с `- NO QUESTIONS` — 261115_2254; bait-значение deadbeef — 0 пересечений с множествами исторических состояний AGENTS.md/architect.md (16 состояний git log/show ∪ текущие); .git — 2.8M; якорные строки секций Q&A log корпуса: единственная номерная пара Q(coder#1)↔A(manager#1) плана 261113_1642 [Done] (A ниже Q), безномерные `- A(owner):` в 261111_0320/261113_1642 (261111_0320 — pre-cutoff C16), прочих номерных Q/A в секциях нет → baseline C15/C16 ожидаемо зелёный.
- 2026-11-16 14:26:40 — Coder: AC-to-test до правок (§5, по каждому пункту DoD ровно один исход закрытого набора): D1 `explicit assertion` — temp-корпус с git-историей (два состояния AGENTS.md) + план ≥ cutoff: мёртвый дайджест → check_c15 FAIL с диагностикой, замена на дайджест первого коммита → pass (Tests (D1)); D2 `explicit assertion` — check_c15 на живом корпусе: excluded-вывод = 8 pre-cutoff планов, rc 0 (Tests (D2)); D3 `explicit assertion` — (а) temp-корпус без post-cutoff цитат + PATH-заглушка git с лог-файлом: rc 0, лог вызовов пуст; (б) `--smoke` → smoke: clean по реальному код-пути (Tests (D3)); D4 `explicit assertion` — temp-корпус с цитатой в скоупе без `.git` → FAIL, exit ≠ 0 (Tests (D4)); D5 `explicit assertion` — `git rev-list --count HEAD` seeded-копии == исходному, membership post-cutoff цитат копии зелёный, temp-путь после selftest не существует (Tests (D5)); D6 `explicit assertion` — selftest-кейс C16a + ручная мутация seeded-копии `- A(manager#9):` (Tests (D6)); D7 `explicit assertion` — selftest-кейс C16b (Done + непарный Q → FAIL) + ручные прогоны In review → pass, Superseded → pass (Tests (D7)); D8 `explicit assertion` — прозаическая `- Q(`-строка вне секции → pass; безномерный `- A(owner):` в секции → pass (Tests (D8)); D9 `explicit assertion` — `--selftest` → `selftest: 36/36 caught`, exit 0, включая baseline-этап C15/C16 на seeded-копии с перенесённой `.git`-историей (Tests (D9)); D10 `explicit assertion` — `scripts/check_corpus.sh` из корня → `corpus: clean`, exit 0 (Tests (D10)); D11 `N/A` (why=merge-гейт/CI: проверка живёт на merge-гейте после Owner-«да», вне фазы Coder — конверт Manager); D12 `explicit assertion` — temp-копия репо без `.git`: `--selftest` → FAIL «selftest requires git history», не skip (Tests (D12)); D13 `explicit assertion` — grep-осмотр заголовка скрипта (Tests (D13)). Вызов одиночных проверок в тестах — через source библиотечной части скрипта (вырезка sed'ом до маркера main-блока, сам скрипт не правится под тесты).
- 2026-11-16 14:41:00 — Coder: реализация завершена, прогоны фазы (все зелёные — на финальном коде; одиночные проверки — source библиотечной вырезки с `ROOT=<repo>`): (1) после правок `scripts/check_corpus.sh --selftest` → `caught C1` … `caught C14g` + `caught C15 (intake digest outside historical set)` + `caught C16a (orphan answer without paired Q)` + `caught C16b (open question in Done plan)` → `selftest: 36/36 caught`, exit 0 (~2:07; baseline до правок 33/33 — запись 14:26:10); (2) `scripts/check_corpus.sh` → `corpus: clean`, exit 0 (OK C1…C16; C15 — 8 excluded-строк, C16 — 2); (3) `--smoke` → `smoke: clean`, exit 0 (реальный код-путь C15 — membership по перенесённой .git-истории seeded-копии); (4) харнесс-прогоны (D1)/(D3а)/(D4)/(D5)/(D6) — 14:41, (D7)/(D8)/(D12) + trap-контроль temp — 14:45: исходы совпали с ожиданиями, дословные команды и выводы — `## Tests / Commands`; (5) контроль финального состояния 14:49:29 — `corpus: clean`, exit 0, temp-пути selftest/smoke отсутствуют, `sh -n` чисто. Дефекты собственной реализации найдены и исправлены в зоне Coder до зелёных прогонов: (а) извлечение цитат по короткому имени (`architect.md@…`) роняло membership — git-история живёт по `docs/roles/<role>.md`; добавлен маппинг имя→путь при сборе; (б) selftest-мутация C15 — BSD-sed BRE: `\(…\)`-группа обязана захватывать литеральный префикс `- Intake `, иначе замена стирала префикс и терялся якорь (MISSED C15 при применённой мутации — оба фикса подтверждены повторным selftest).
- 2026-11-16 14:42:00 — Coder: наблюдение (сверка с HEAD, untrusted input): плавающие `printf: write error: Broken pipe` в smoke-выводе — существующее поведение (bash builtin `printf | grep -q` в коде C12/C13), воспроизведено на HEAD-версии скрипта из корня репо (exit 0, smoke: clean); на rc/вердикты не влияет; класс lint-robustness (Out of scope п.3) — строка в Follow-ups.
- 2026-11-16 14:52:10 — Coder: фаза work завершена — реализация строго по Scope (scripts/check_corpus.sh: +check_c15, +check_c16, DIGEST_CUTOFF, seed_corpus += перенос .git с fail-loud, selftest 33→36 с +3 кейсами, заголовок; иных файлов кода не тронуто), DoD D1–D13 закрыты (D11 — N/A merge-гейт по конверту); AC-to-test зафиксирован до правок (14:26:40), Tests/Commands — факты прогонов, Changes (by area) — по факту; intake-строки этого плана (AGENTS.md@822b4300 coder.md@4620164d — текущие состояния) C15-зелёны, Q-строк в Q&A log нет — C16-зелёно; изменения стейджнуты. Handoff: **Status:** In review.
- 2026-11-16 14:58:30 — (Role CENSOR) OK: In review validated; current=true
Censor dispatch id: censor:coder:261116_145305
Observations:
- Second opinion: шапка перечитана из файла — `**Status:** In review` единственная (grep `^\*\*Status:` = 1), Plan ID 261116_1321 = префикс имени файла, PRE_STATUS_LINE конверта совпал; DoD-зона Planner не тронута (13 чекбоксов `- [ ] D`, 0 `- [x]`), Tests — 13 меток (Dn) с фактическими «Результат»-блоками (grep 13/13), AC-to-test (Evidence 14:26:40) — до заполнения Changes; свежие прогоны цензорной итерации 14:58 — `scripts/check_corpus.sh --selftest` → `selftest: 36/36 caught`, полный прогон → `corpus: clean`, exit 0; стейджинг: staged `M scripts/check_corpus.sh` + `A docs/plans/261116_1321_lint_v2_digest_qa.md`, unstaged ` M docs/followups/{backlog,index}.md` — зона Manager (промоушен), цензором не тронута; Follow-ups непуст (2 строки).
- Counterfactuals considered: (1) «Changes разошёлся с кодом» — подтверждалось: wc -l скрипта 2437 против заявленных «2446 → 2519»; фактические границы HEAD=2127 → 2437 (git diff +323/−13) — устранено (Fix 1); (2) «скрипт менялся после зелёного selftest» — git diff working↔staged по скрипту пуст (0 строк), последний Edit скрипта предшествовал selftest 36/36, повторный свежий selftest 14:58 — снова 36/36; (3) «отладочный мусор/TODO» — grep TODO/FIXME/XXX: 2 ложных срабатывания (шаблоны `mktemp -d …XXXXXXXX`, легитимный код), план — 0; (4) «CI static уронит merge-гейт» — полный `shellcheck -s sh scripts/check_corpus.sh` версии 0.11.0 (идентичен CI-джобе corpus.yml) → exit 0; smoke зелёный; workflow-файлы не менялись (actionlint-поверхность нетронута); (5) «план роняет собственные проверки» — intake-цитаты 822b4300/4620164d — текущие состояния (свежий shasum сверен), Q-строк в Q&A log нет, `corpus: clean` подтверждает; (6) «хронология меток Tests лжёт» — сдвиг меток (14:52–14:58 в будущем относительно фактического 14:49) найден self-сверкой и исправлен до handoff на фактические 14:40–14:45 — теперь все метки раньше контрольного прогона 14:49:29 и handoff-узла 14:52:10.
- Addendum (new angle): сверх чек-листа — Assumption-строк нет (grep 0: допущений, влияющих на Scope/DoD, не делалось); Fan-out-поверхности сверены по git status: docs/model_run.md («33/33» append-only нарратив), README/CONTRIBUTING — без правок; digest'ы контрактов на intake 14:53:48 совпадают с 14:22:41 (AGENTS.md@822b4300 coder.md@4620164d — миграции в фазе нет, записи §3 п.7 не требуется); usage-строка coder.work 14:53:05 — зона Manager, цензором не тронута.
- Fixes: (1) `## Changes (by area)`: числа строк скрипта «2446 → 2519» → фактические «2127 → 2437; git diff: +323/−13» (сверка wc -l и git diff против HEAD).
- Final censor verdict: OK
- 2026-11-16 15:34:34 — Manager: reviewer-risk диспатч пережил два транзиента (loop: operational_retry ×2, §6): (1) таймаут неактивности 600с частичного диспатча 15:25 (зона фактически завершена до таймаута: findings-таблица 3 minor, Coverage, вердикт `pass` с меткой 15:24:47 и свежими прогонами — corpus clean / selftest 36/36 / smoke clean, temp-очистка подтверждена); (2) SendMessage-резюм того же хендла ступорился на Bash `rm -rf /tmp/riskrev_*` в ожидании разрешения (фоновому агенту не выдаётся) — задача остановлена Manager'ом (TaskStop). Решение по файлу (notice ≠ mutation truth): Risk-зона артефакта docs/reviews/261116_1321_review.md полна и валидна, вердикт pass принят; fresh-диспатч reviewer-risk не требуется (§7 — один fresh-диспатч на роль прибережён); контракт ревьюеров соблюдён, следующий шаг — contracts-лейн
- 2026-11-16 15:55:39 — Manager: фикс finding C18 contracts-лейна (зона Manager, действие до merge): usage-строка 15:34:34 с unknown-why переформулирована без вложенных скобок (ломала USAGE_DISPATCH_RE чека C11, corpus: 1 failures); прецедент in-place исправления невалидной usage-строки; план рестейджен; контрольный прогон `corpus: clean` (C7/C11/C13/C14 зелёные); review Round 1: Risk pass (R1–R3 accepted_risk) / Contracts pass (C18 accepted_risk, закрыт этим фиксом) / Итог pass → Owner-гейт / Artifact state current_green
- 2026-11-16 18:19:31 — Manager: Owner-гейт merge — Owner ответил «мержим» (чат, дословно); контроли (а) пройдены: staged = дословный список Итога (план + scripts/check_corpus.sh); unstaged — план (append-only записи после рестейджа, штатно), backlog/index (промоушен-правки Manager'а при активации по Solution п.2 Scope — санкционированное включение в merge-коммит, известное отклонение от буквы (а), зафиксировано здесь); untracked — только review-артефакт (санкционирован шагом (в)); свежий pre-merge verify `sh scripts/check_corpus.sh` → `corpus: clean` (C1–C16 OK, включая новые C15/C16 на живом корпусе); ручной leak-контроль запретных токенов по staged-диффу → 0 совпадений. Статус Merged


## Token usage (append-only)
<!-- owner: manager; dispatch-форма и чекпоинт-форма — грамматика шаблона -->

- 2026-11-16 14:05:45 — usage: architect.work 2513766 tokens — dispatch
- 2026-11-16 14:09:13 — usage: architect.censor 1053969 tokens — sendmessage
- 2026-11-16 14:17:07 — usage: planner.work 1092362 tokens — dispatch
- 2026-11-16 14:20:16 — usage: planner.censor 564320 tokens — sendmessage
- 2026-11-16 14:53:05 — usage: coder.work 7064485 tokens — dispatch
- 2026-11-16 14:59:58 — usage: coder.censor 2712423 tokens — sendmessage
- 2026-11-16 15:34:34 — usage: reviewer-risk.work 952104 tokens — dispatch
- 2026-11-16 15:34:34 — usage: reviewer-risk.work unknown (why=резюм хендла остановлен killed, usage в notification отсутствует, зона завершена в первом частичном диспатче) tokens — sendmessage
- 2026-11-16 15:55:39 — usage: reviewer-contracts.work 3414124 tokens — dispatch
- 2026-11-16 15:55:39 — usage: manager-context checkpoint ~14958000 tokens-left — approximate

## Q&A log (chronological, append-only)
<!-- owner: все роли; intake и Q/A-грамматика — по шаблону; кураторских Q нет: брифы Owner получены до драфта -->
- Intake (2026-11-16 14:03:35): AGENTS.md@822b4300 architect.md@f6cd38e4
- NO QUESTIONS
- SUGGESTIONS: 1 — closeout disposition строки qa-lint (записана в Suggestions log)
- OBJECTIONS: 1 — D3/D5/D9 рассинхрон с исправленным Solution п.4 (записана в Objections log), blocker: no
- Intake (2026-11-16 14:08:03): AGENTS.md@822b4300 architect.md@f6cd38e4
- NO QUESTIONS
- NO SUGGESTIONS
- NO OBJECTIONS
- Intake (2026-11-16 14:12:29): AGENTS.md@822b4300 planner.md@f013858b
- NO QUESTIONS
- NO SUGGESTIONS
- NO OBJECTIONS
- Intake (2026-11-16 14:18:10): AGENTS.md@822b4300 planner.md@f013858b
- NO QUESTIONS
- NO SUGGESTIONS
- NO OBJECTIONS
- Intake (2026-11-16 14:22:41): AGENTS.md@822b4300 coder.md@4620164d
- NO QUESTIONS
- NO SUGGESTIONS
- NO OBJECTIONS
- Intake (2026-11-16 14:53:48): AGENTS.md@822b4300 coder.md@4620164d
- NO QUESTIONS
- NO SUGGESTIONS
- NO OBJECTIONS
- Intake (2026-11-16 15:01:01): AGENTS.md@822b4300 reviewer-risk.md@a51f0eb4
- NO QUESTIONS
- NO SUGGESTIONS
- NO OBJECTIONS
- Intake (2026-11-16 15:36:40): AGENTS.md@822b4300 reviewer-contracts.md@dd9bcb7a
- NO QUESTIONS
- NO SUGGESTIONS
- NO OBJECTIONS


## Suggestions log (chronological, append-only)
<!-- owner: все роли; несрочные улучшения -->
- 2026-11-16 14:03:35 — Architect: closeout-инвентарь строки id=qa-lint — backlog-описание шире C16 («формат Q/A-строк» против одной парности); при harvest disposition учесть, что формат-часть описания планом не покрыта (парность покрыта C16), чтобы хвост не закрылся как handled целиком.

## Objections log (chronological, append-only)
<!-- owner: все роли; `### <Role> objections`; строка на возражение, blocker: при блокере -->
### Architect objections
- 2026-11-16 14:03:35 — Architect: DoD D3/D5/D9 (кураторский черновик, зона Planner) рассинхронизированы с исправленным Solution п.4 (перенос `.git` в seeded-копию вместо init+commit; fast-path — корпус без post-cutoff цитат, не полный `--smoke`). Конкретика: D5 «сажает git-репозиторий» → перенос `.git` (полная история); D3-тест `--smoke → clean (fast-path, git не вызывается)` → `--smoke → clean` по реальному код-пути с git, fast-path — отдельный корпус без post-cutoff цитат; D9-механика baseline — через перенесённую историю (текст исхода 36/36 не меняется). Синхронизировать при Planner-перепринятии зон. blocker: no — handoff не блокирует.

## Follow-ups (deferred)
<!-- owner: coder/planner при CENSOR; незакрытые хвосты -->
- Промоушен строк `lint-v2-digest-verify` и `qa-lint` при активации — зона
  Manager (Solution п.1 Scope); терминальное закрытие при closeout.
- Coder (2026-11-16 14:42): плавающие `printf: write error: Broken pipe`
  в smoke/stdout-выводе (bash builtin `printf | grep -q`, код C12/C13,
  существующее поведение — воспроизведено на HEAD) — шум диагностики,
  не влияет на rc; кандидат в существующую строку backlog
  `lint-robustness` (Out of scope п.3), отдельного плана не требует.
