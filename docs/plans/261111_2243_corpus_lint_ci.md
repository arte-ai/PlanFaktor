# Corpus lint + CI — машинная проверка инвариантов конвейера

**Plan ID:** 261111_2243
**Status:** Done
**Created:** 2026-11-11
**Owner gates:** старт кодинга (`Ready for Coder`), merge (`In review` → `Merged`)

> Шапка — parser-контракт: строки выше grep'аются Manager'ом. Не менять формат.
> Имя файла: `261111_2243_corpus_lint_ci.md`.

## Как я понял задачу
<!-- owner: architect; 3–7 строк; обязательна при Architect intake -->

Корпусные инварианты (статусы §2, censor-receipt'ы §4, intake-строки §3,
digest-формат, ownership-метки, ссылки, состав ролей/агентов) сегодня
проверяются только разово внутри планов и умирают вместе с ними. Нужна
постоянная машинная проверка корпуса: единый grep-линт
`scripts/check_corpus.sh` (POSIX sh, без python и зависимостей) с
selftest-режимом на подсаженных дефектах всех классов, заготовка GitHub
Actions (ремоута нет — файл добавляется вперёд, активируется сам) и
минимальная встройка в конвейер: одна строка в CENSOR-чек Coder'а, без
новых гейтов. Ключевая рамка: это dev-инфраструктура репо, НЕ рантайм
конвейера — маршрутизация Manager'а от линта не зависит. Architect-зоны
были предзаполнены кураторской сессией (Evidence 22:43:59); на intake
2026-11-12 я перепринял владение фактической сверкой с корпусом
(Evidence 01:09:23) — решения принимаю как свои, правок по существу
не потребовалось.


## Problem
<!-- owner: architect; пронумерованные пункты -->

1. Корпусные инварианты (форматы статусов, censor-метки, секции шаблонов,
   ownership-метки, digest-цитаты, ссылки) между прогонами конвейера не
   проверяет ничто: «тесты» живут только в `Tests / Commands` планов и
   умирают вместе с ними.
2. Классы ошибок, найденных руками, лишь частично машинно-ловимы структурным
   линтом: расхождение superseded-формы (261111_0320) — ловится; нарушения
   формата digest-цитат — ловятся. Но value-опечатки digest'ов
   (a2c2faf8↔a2c2faf9, 261111_1455) и невоспроизводимые факты тестов (T4,
   261111_1455 Round 1) grep'ом v1 не ловятся: сверка с `shasum` — v2,
   факты — зона ревью-лансов. Ложных ожиданий план не создаёт.
3. CI отсутствует (репо без ремоута); при появлении ремота проверять
   нечем — нет единой команды «корпус валиден».
4. Ops-находка дня: программно созданной сессии Manager'а нужны выданные
   вперёд права записи (две сессии зависли на permission-гейте до ручного
   одобрения) — знание живёт только в чате куратора.

## Solution / Decisions
<!-- owner: architect; решения уровня «что и почему», без детализации -->

1. **`scripts/check_corpus.sh`** — единая команда проверки корпуса:
   POSIX sh + grep (+ cut/sed в рамках POSIX), без python и без зависимостей.
   Это dev-инфраструктура репо, НЕ рантайм конвейера: роли не обязаны его
   звать для маршрутизации; Manager не зависит от него.
2. Выход: по одной строке на проверку `OK <id> <имя>` / `FAIL <id> <имя>:
   <детали>`; итог `corpus: clean|N failures`; exit 0 только при clean.
3. **Режим `--selftest`**: скрипт создаёт временный каталог с заведомо
   дефектными фрагментами корпуса (по одному на класс) и проверяет, что
   каждая проверка ловит свой дефект. Exit-контракт selftest: итог
   `selftest: N/N caught` и exit 0 — только если пойманы ВСЕ подсаженные
   дефекты; непойманный дефект — `selftest: N/M caught`, exit ≠ 0.
4. **`.github/workflows/corpus.yml`**: on push/pull_request → checkout +
   `scripts/check_corpus.sh`. Файл добавляется сейчас; активируется сам при
   появлении ремоута.
5. Встройка в конвейер — минимальная: одна строка в чек-лист Coder CENSOR
   (`docs/roles/coder.md`): «если `scripts/check_corpus.sh` существует —
   прогони и приложи вывод в Evidence». Никаких новых гейтов.
6. Ops-находка фиксируется строкой в README (owner quickstart): сессии
   Manager'а, создаваемые программно, требуют заранее выданных прав записи.
7. `scripts/` как каталог dev-инфраструктуры фиксируется записью в
   `docs/decisions.md`; §9 конституции не расширяется (там только
   носители процесса).
8. План меняет контракт `docs/roles/coder.md` → по §3 п.7 конституции
   фиксирует в `## Evidence` миграционную запись digest'ов по изменённому
   файлу (старый@8hex → новый@8hex, с меткой времени).

Проверки v1 (все — по фактическим файлам, шаблоны `_template*` — только на
структуру, не на значения). **Cutoff**: C4 и C5 применяются только к планам
с Plan ID ≥ `261111_1455` (лексикографически по префиксу имени файла) — до
этого правила формата receipt'ов/intake были другими, а append-only (§5)
запрещает правку истории; планы 0320/0427 выводятся как `excluded` в этих
двух проверках, остальные проверки идут по всему корпусу.

- **C1 Статусы**: каждый `docs/plans/[0-9]*.md` имеет `**Status:**` из
  допустимого множества (9 значений конституции §2); якорь `^` обязателен
  (в цитатах receipt'ов статус встречается в прозе).
- **C2 Plan ID ↔ имя файла**: `**Plan ID:** YYMMDD_HHMM` (строка шапки,
  с якорем) совпадает с префиксом имени файла.
- **C3 Секционный состав планов**: обязательные `##`-секции шаблона
  присутствуют в каждом плане (fixed-string, по списку).
- **C4 CENSOR-receipt формат** (cutoff ≥ 261111_1455; скоуп — секция
  `## Evidence`; матчатся строки формы `(Role CENSOR) (OK|FAIL):`, не
  сырая подстрока — проза/цитаты дают ложные срабатывания): строка-маркер
  обязана нести префикс `- YYYY-MM-DD HH:MM:SS — `; в блоке —
  `Censor dispatch id: censor:<role>:<YYMMDD_HHMMSS>` и
  `Final censor verdict: (OK|FAIL)` (толерантно к отступам).
- **C5 Intake-строки** (cutoff ≥ 261111_1455): в `## Q&A log` строки
  `Intake (YYYY-MM-DD HH:MM:SS): AGENTS.md@<8hex> <role>.md@<8hex>`;
  роли — из допустимого множества; строки-плейсхолдеры шаблонов
  (`<!-- ... -->`) исключаются.
- **C6 Digest-формат**: `@`-хвосты в планах — ровно 8 hex-символов
  (фильтр плейсхолдера `@8hex`). Ловит только формовые нарушения;
  value-опечатки (8 верных hex-символов, неверное значение — класс
  a2c2faf8) v1 не ловятся: сверка с `shasum` — v2.
- **C7 Review-артефакты**: `**Round:** N`; вердикты `pass|needs-fix`;
  superseded-лейблы — формы `superseded (round [0-9]+)` с N, равным
  текущему `**Round:**`. Глобальный запрет подстроки `round N-1` не
  используется (замороженные шапки артефактов до 261111_1455 —
  append-only); `**Created:**`/`**Round N started:**` требуются только у
  артефактов ≥ 261111_1455.
- **C8 Ownership-метки**: каждая `##`-секция шаблона несёт `<!-- owner: -->`
  на следующей строке.
- **C9 Ссылочная целостность**: относительные пути `docs/…`/`.zcode/…` из
  README, AGENTS.md, ролей и команд существуют; allowlist плейсхолдеров:
  `docs/plans/YYMMDD_HHMM_topic.md`, `docs/plans/<PlanID>_<topic>.md`,
  `docs/plans/<файл>`, `docs/reviews/<PlanID>_review.md`,
  `docs/roles/<role>.md`, `docs/roles/<роль>.md`, `planfaktor-*.md`,
  `docs/plans/[0-9]*.md`; слэш-команды `/planfaktor-*` →
  `.zcode/commands/<имя>.md`.
- **C10 Роли ↔ агенты**: 5 субагентных ролей §1 ↔ 5 `docs/roles/*.md` ↔ 5
  `.zcode/agents/planfaktor-*.md` (Owner и Manager — не субагенты, без файлов).

## Scope
<!-- owner: architect (границы), planner (уточняет); список изменений -->

- Новый: `scripts/check_corpus.sh` (с `--selftest`), `.github/workflows/corpus.yml`.
- Правки: `docs/roles/coder.md` (+1 строка в CENSOR-чек), `README.md`
  (+ops-строка), `docs/decisions.md` (+1 запись).
- Носители плана: этот план + review-артефакт.

## Out of scope
<!-- owner: architect -->

- Сверка digest-цитат с актуальным `shasum` (v2, отдельным планом).
- Q&A-линт (`status=open` без закрытия и т.п.) — грамматика сложна для v1.
- Агрегация метрик длительностей (S1 — уже в Follow-ups 261111_1455).
- Любой python, любые новые гейты конвейера, изменения конституции §1–§8.

## Acceptance criteria / DoD
<!-- owner: planner; чек-лист проверяемых исходов; каждый пункт = проверяемое утверждение -->

- [ ] D1 `scripts/check_corpus.sh` существует, исполним; `sh -n` — без синтаксических ошибок.
- [ ] D2 Прогон на текущем корпусе с cutoff/allowlist: все проверки C1–C10 = OK (в C4/C5 планы 0320/0427 выведены как `excluded`), итог `corpus: clean`, exit 0. Уточнение скоупа C4/C5: валидируется формат встреченных receipt/intake-строк; отсутствие таких строк у плана — не дефект (261112_0111 в Draft до первого диспатча роли проходит чисто; наличие intake/receipt маршится статусами §2/§3, не линтом).
- [ ] D3 `--selftest` подсаживает по одному дефекту на каждый класс C1–C10 (10 дефектов) во временный корпус; итог `selftest: 10/10 caught`, exit 0; при K < 10 пойманных — `selftest: K/10 caught`, exit ≠ 0.
- [ ] D4 Скрипт не использует python и не пишет вне `${TMPDIR}` (fallback `${TMPDIR:-/tmp}` допустим): временные каталоги — только `mktemp -d` под TMPDIR, удаляются при любом исходе; проверяется осмотром кода + чистый `git status --short` после прогонов.
- [ ] D5 `.github/workflows/corpus.yml`: структурный осмотр — `on:` push/pull_request, шаги checkout + вызов `scripts/check_corpus.sh`; YAML согласован по скобкам/отступам.
- [ ] D6 `docs/roles/coder.md` содержит строку прогона линта в CENSOR-чеке.
- [ ] D7 `README.md` содержит ops-строку о правах записи программных сессий Manager'а (ключ проверки: слово «программн» — до правок в README отсутствует).
- [ ] D8 `docs/decisions.md` +1 запись о `scripts/` как dev-инфраструктуре; формат журнала соблюдён.
- [ ] D9 Шаблоны `_template.md`/`_template_review.md`, конституция (§1–§9), `docs/lifecycle.md` и команды не изменены.
- [ ] D10 Результаты прогонов (D2, D3) зафиксированы в `## Tests / Commands` и `## Evidence` с метками времени.
- [ ] D11 Миграционная запись §3 п.7 для изменённого контракта `docs/roles/coder.md` (старый@8hex → новый@8hex, с меткой времени) — в `## Evidence`.

## Tests / Commands
<!-- owner: planner (задаёт), coder (заполняет факт); что прогнать и что должно получиться -->

Все команды — из корня репо; формат каждой строки: команда → ожидаемый
результат. Число в скобках — закрываемый пункт DoD (T1–T11 покрывают
D1–D11 один к одному). Факты прогонов Coder дописывает к своей итерации,
ожидания не переписывает.

- T1 (D1): `sh -n scripts/check_corpus.sh && test -x scripts/check_corpus.sh`
  → тишина, exit 0.
- T2 (D2): `scripts/check_corpus.sh` → по строке OK на каждую C1–C10
  (C4/C5 дополнительно выводят `excluded` для 261111_0320/261111_0427),
  итог `corpus: clean`, exit 0.
- T3 (D3): `scripts/check_corpus.sh --selftest` → итог
  `selftest: 10/10 caught`, exit 0.
- T4 (D4): осмотр кода скрипта: вызовов python нет; временные каталоги —
  только `mktemp -d` под `${TMPDIR}` (fallback `/tmp` допустим), удаление
  при любом исходе; `git status --short` после T2/T3 → временных следов
  в репо нет.
- T5 (D5): `grep -nE 'on:|push|pull_request|checkout|check_corpus\.sh' .github/workflows/corpus.yml`
  → найдены строки на каждое ключевое слово; парность скобок/отступы
  YAML — осмотр, без ошибок.
- T6 (D6): `grep -n "check_corpus" docs/roles/coder.md` → строка в
  CENSOR-чек-листе Coder'а: если скрипт существует — прогнать и приложить
  вывод в Evidence.
- T7 (D7): `grep -n "программн" README.md` → ops-строка о заранее
  выданных правах записи для программных сессий Manager'а (сверка
  смысла — осмотром найденной строки).
- T8 (D8): `grep -n "scripts" docs/decisions.md` и `tail -n 12 docs/decisions.md`
  → новая запись о `scripts/` как dev-инфраструктуре в формате
  «дата — решение — почему — альтернатива».
- T9 (D9): `git status --short` → изменены только файлы из `## Scope`
  (+ этот план); AGENTS.md, `docs/plans/_template*.md`,
  `docs/reviews/_template_review.md`, `docs/lifecycle.md`,
  `.zcode/commands/*` в списке отсутствуют.
- T10 (D10): осмотр плана после фазы Coder: фактические выводы T2/T3
  (команда, результат, метка времени) представлены в
  `## Tests / Commands` и `## Evidence`.
- T11 (D11): `shasum -a 256 docs/roles/coder.md | cut -c1-8` → 8 hex
  совпадают с «новым» значением миграционной записи coder.md в
  `## Evidence` (старый@8hex → новый@8hex, с меткой времени).

Факты прогонов (Coder, итерация intake 2026-11-12 01:27:02; все
команды — из корня репо; прогоны 01:33–01:45, повторная финальная
батарея после всех правок Scope и записей плана — 01:45):

- T1 → пройден: `sh -n scripts/check_corpus.sh` — тишина;
  `test -x scripts/check_corpus.sh` — exit 0.
- T2 → пройден: `scripts/check_corpus.sh` — по строке `OK` на C1–C10;
  C4/C5 вывели `excluded (pre-cutoff 261111_0320 < 261111_1455)` и
  `excluded (pre-cutoff 261111_0427 < 261111_1455)`; итог
  `corpus: clean`, exit 0.
- T3 → пройден: `scripts/check_corpus.sh --selftest` — `caught C1` …
  `caught C10` построчно, итог `selftest: 10/10 caught`, exit 0;
  следов `check_corpus_selftest.*` в TMPDIR после прогона нет.
- T4 → пройден: осмотр кода — слово «python» в скрипте только
  в комментарии-заголовке (строка 9), вызовов нет; временное —
  единственный `mktemp -d "${TMPDIR:-/tmp}/check_corpus_selftest.XXXXXXXX"`
  (строка 503) + `trap 'rm -rf …' 0 HUP INT TERM` (504–505), мутации
  дефектов — только в копиях под этим каталогом (`*.lintmut` в `mutate`);
  `git status --short` после T2/T3 — временных следов в репо нет.
- T5 → пройден: grep нашёл все ключевые слова в
  `.github/workflows/corpus.yml`: `on: [push, pull_request]` (строка 6),
  `checkout` (13), `check_corpus.sh` (15) и `check_corpus.sh --selftest`
  (17); осмотр — скобки/отступы YAML согласованы.
- T6 → пройден: `grep -n "check_corpus" docs/roles/coder.md` → строка
  65 в чек-листе CENSOR-прохода Coder'а.
- T7 → пройден: `grep -n "программн" README.md` → строка 67: «ops:
  программно созданным сессиям Manager'а выдавайте права записи
  заранее — иначе сессия зависнет на permission-гейте до ручного
  одобрения» (смысл сверен осмотром).
- T8 → пройден: `grep -n "scripts" docs/decisions.md` → строка 111
  (и 113, 120 внутри записи); `tail -n 12` показывает запись целиком
  в формате «дата — решение — почему — альтернатива».
- T9 → пройден: `git status --short` — `M README.md`,
  `M docs/decisions.md`, `M docs/roles/coder.md`, `?? .github/`,
  `?? scripts/`, `?? docs/plans/261111_2243_corpus_lint_ci.md` (этот
  план) и `?? docs/plans/261112_0111_route_token_accounting.md`
  (чужой untracked, существовал до фазы Coder — зафиксирован
  Planner CENSOR 01:23:33, не трогался); AGENTS.md,
  `docs/plans/_template*.md`, `docs/reviews/_template_review.md`,
  `docs/lifecycle.md`, `.zcode/commands/*` — в списке отсутствуют.
- T10 → пройден: факты T2/T3 с результатами — выше в этой секции
  и в `## Evidence` с метками времени.
- T11 → пройден: `shasum -a 256 docs/roles/coder.md | cut -c1-8` =
  `942a3f82` — совпадает с «новым» значением миграционной записи
  (`coder.md@9529b5d7 → coder.md@942a3f82`, Evidence 2026-11-12
  01:45:40).


## Changes (by area)
<!-- owner: coder; фактические изменения по областям; заполняется в ходе работы -->

- `scripts/check_corpus.sh` (новый, исполним, 696 строк): corpus lint v1.
  Проверки C1–C10 по Solution: статусы §2 (ровно одна строка
  `^**Status:**` из 9 допустимых); Plan ID ↔ префикс имени файла
  (двухсегментный `YYMMDD_HHMM`); секции шаблона fixed-string в каждом
  плане; censor-receipt'ы (cutoff ≥ 261111_1455 по префиксу имени,
  скоуп — секция `## Evidence`, форма маркера с префиксом
  `- YYYY-MM-DD HH:MM:SS — `, блок: `Censor dispatch id:` +
  `Final censor verdict:`, толерантно к отступам/дефису списка);
  intake-строки (тот же cutoff, скоуп — `## Q&A log`, роль из 5
  субагентных, digest ровно 8 hex, `<!--`-плейсхолдеры исключаются);
  digest-хвосты `@<hex>` в планах ровно 8 hex с фильтром плейсхолдера
  `@8hex`; review-артефакты (`**Round:** N` единственная, вердикт-строки
  `### (Risk|Contracts) verdict: pass|needs-fix (— superseded (round M))?`,
  числовые лейблы `superseded (round M)` с M = текущему Round,
  `**Created:**`/`**Round k started:**` только у артефактов ≥ cutoff);
  ownership-метки `<!-- owner:` после каждой `##`-секции в шаблонах
  и планах; ссылочная целостность `docs/…`/`.zcode/…` из README,
  AGENTS.md, роль-доков и команд с allowlist-плейсхолдерами (включая
  кириллические `docs/plans/<файл>`/`docs/roles/<роль>.md`,
  обрезаемые токенизатором до `docs/<dir>/<`) и слэш-команды
  `/planfaktor-*` → `.zcode/commands/<имя>.md`; 5 роль-доков ↔
  5 `planfaktor-*`-агентов. Режим `--selftest`: baseline-копия корпуса
  (обязана проходить все 10) + по одному подсаженному дефекту на класс
  C1–C10 в свежих копиях под `${TMPDIR:-/tmp}` (mktemp -d, trap-очистка
  0/HUP/INT/TERM), exit-контракт `selftest: N/10 caught`. В ходе
  отладки исправлено: извлечение префикса Plan ID (два сегмента,
  не один), перестановка аргументов post_cutoff_plan_with, итерация
  superseded-лейблов C7 без word splitting. POSIX sh +
  grep/sed/cut/head/tail, без python и зависимостей.
- `.github/workflows/corpus.yml` (новый): `name: corpus-lint`,
  `on: [push, pull_request]`, шаги checkout@v4 + `scripts/check_corpus.sh`
  + `scripts/check_corpus.sh --selftest`; ремоута нет — активируется сам
  при появлении (Solution п.4).
- `docs/roles/coder.md`: +1 строка в CENSOR-чек-лист — «Если
  `scripts/check_corpus.sh` существует — прогони и приложи вывод
  в `## Evidence`» (Solution п.5; строка 65).
- `README.md`: +ops-строка в «Куда дальше» — программно созданным
  сессиям Manager'а выдавать права записи заранее, иначе зависание
  на permission-гейте (Solution п.6; строка 67).
- `docs/decisions.md`: +1 append-запись «2026-11-12 — `scripts/`
  закреплён как каталог dev-инфраструктуры … §9 не расширяется»
  в формате «дата — решение — почему — альтернатива» (Solution п.7;
  строки 111–122).
- Носители плана: этот план (intake, Changes, Tests-факты, Evidence,
  миграционная запись §3 п.7); review-артефакт — зона ревьюеров.

## Evidence (chronological, append-only)
<!-- owner: все роли + CENSOR; событийные записи с датой и локальным временем `- YYYY-MM-DD HH:MM:SS — <кто>: <текст>`; CENSOR-receipt по формату конституции -->

- 2026-11-11 22:43:59 — Manager (кураторская сессия, по прямому указанию Owner): план создан из шаблона `docs/plans/_template.md` (свежее чтение с диска). Owner-бриф дословно: «готовь план, потом валидируй его субагентами» — в контексте обсуждения плана «Corpus lint + CI» (линт инвариантов корпуса + CI-заготовка + ops-строка о правах программных сессий Manager'а). Секции заполнены кураторской сессией как черновик: Architect-зоны (понимание/Problem/Solution/Scope/Out of scope) и Planner-зоны (DoD/Tests) — владение передаётся Architect'у и Planner'у конвейера на intake (переприсвоение, не rubber-stamp). Отклонение (драфт вне ролей конвейера) — по прямому указанию Owner; фиксируется этой записью.
- 2026-11-11 22:54:03 — Manager (кураторская сессия): план провалидирован двумя субагентами (формальная валидация против шаблона/конституции + техническая — прогон прототипов C1–C10 на живом корпусе). По находкам исправлено: cutoff ≥ 261111_1455 для C4/C5 (append-only 0320/0427), C4 скоупится на `## Evidence` и форму маркера, C6 честно про value-опечатки (v2), C7 — лейблы вместо глобального запрета `round N-1`, C9 allowlist, C10 «субагентных», exit-контракт selftest (D3↔T3), §3 п.7-миграция (D11), D9 расширен (§9, lifecycle), ownership-метка Evidence дословно по шаблону, Problem п.2 переформулирован без ложных ожиданий. Точные времена и детали — в этом узле; прототипы паттернов подтверждены прогонами валидатора (все C1–C10 зелёные с cutoff/allowlist).
- 2026-11-12 01:09:23 — Architect: фаза завершена; владение предзаполненными Architect-зонами (Как я понял задачу / Problem / Solution / Decisions / Scope / Out of scope) перепринято фактической сверкой с корпусом, не rubber-stamp. Подтверждено по файлам: 4 плана корпуса — статусы из 9 допустимых §2, Plan ID↔имена файлов (C1/C2); 5 роль-доков ↔ 5 planfaktor-агентов, команды и Owner/Manager вне множества (C10); ремоут пуст, `.github/` и `scripts/` отсутствуют (Problem п.3, Solution п.1/п.4); receipt 261111_0427:395 без префикса метки времени и intake-строка 0427:451 старой формы — живое обоснование cutoff C4/C5 ≥ 261111_1455 при append-only; digest-опечатка a2c2faf8↔a2c2faf9 (1455:493,997,1250,1454) и невоспроизводимый факт T4 (261111_1455_review:52) — Problem п.2; замороженные шапки review 0320/0427 с prose-инструкцией `superseded (round N-1)` при лейблах `superseded (round N)` в теле — мотивация формы C7; README.md (66 строк) ops-строки не содержит, coder.md CENSOR-чек-лист (строки 55+) принимает одну строку, decisions.md — append-only журнал «дата — решение — почему — альтернатива», lifecycle.md существует — точки встройки Solution п.5/п.6 и D6–D9 реальны. Правок Architect-зон по существу не потребовалось; «Как я понял задачу» переписан своей рукой; intake — Q&A log 01:06:38. Handoff: Ready for Planner.
- 2026-11-12 01:13:09 — (Role CENSOR) OK: Ready for Planner validated; current=true
Censor dispatch id: censor:architect:261112_011111
Observations:
- Second opinion: шапка — `**Status:** Ready for Planner` (строка 4), Plan ID `261111_2243` (строка 3) ↔ имя файла `261111_2243_corpus_lint_ci.md` — согласованы. Architect-секции заполнены и непротиворечивы: «Как я понял задачу» (переписан при переприсвоении), Problem п.1–4, Solution п.1–8 + cutoff C4/C5 + C1–C10, Scope, Out of scope. Перекрёстная сверка: Problem п.2 «сверка с `shasum` — v2» ↔ C6 ↔ Out of scope п.1; Solution п.3 exit-контракт ↔ D3 ↔ T3; п.4↔D5; п.5↔D6; п.6↔D7; п.7↔D8; п.8↔D11; cutoff «0320/0427 excluded» ↔ D2 — согласовано. Вопросов к Owner нет (NO QUESTIONS, Q&A log), A(owner)-записей в плане нет — отражать нечего. Чужие зоны не тронуты: DoD/Tests (строки 139–160) и пустой Changes соответствуют дисковому снимку до правок Architect'а.
- Counterfactuals considered: (1) контракты могли измениться между итерациями фазы — shasum пересчитан, AGENTS.md@5cc19f0c / architect.md@73ace930 совпали с рабочей итерацией 01:06:38 (§3 п.7 расхождений нет); (2) цитаты Evidence-узла 01:09:23 могли быть неточны — перепроверены повторным чтением файлов: 0427:395 `(Role CENSOR) OK:` без префикса метки, 0427:451 intake старой формы `- 2026-11-11 — Intake (architect): ...`, 261111_1455_review:52 `| 4 — superseded (round 2) | major | D4: ...` — на месте; (3) append-only: Evidence 22:43:59 → 22:54:03 → 01:09:23 хронологичен, Q&A log только дописывался, переписываний нет; (4) замена «Как я понял задачу» правомерна — §5 append-only покрывает только Evidence/Q&A/Suggestions/Objections.
- Addendum (new angle): прогнана извлекающая выборка всех `docs/…`/`.zcode/…` упоминаний из источников C9 (README, AGENTS.md, 5 роль-доков, 3 команды) и сверена с allowlist — найдена щель: кириллический плейсхолдер `docs/roles/<роль>.md` (AGENTS.md:160 — конверт §5; .zcode/commands/planfaktor-run.md:39,98) allowlist'ом не покрывался (была только латинская форма `docs/roles/<role>.md` — AGENTS.md:77,82); точный match дал бы ложный FAIL на валидном корпусе в T2/D2. Конкретные пути из выборки (decisions.md, lifecycle.md, playbooks/manual_terminal_recovery.md, оба шаблона, docs/plans/, docs/reviews/, .zcode/commands/) существуют.
- Fixes: Solution C9 — allowlist дополнен `docs/roles/<роль>.md` (кириллическая форма); правка зоны Architect до детализации Planner'а, DoD/Tests не затронуты.
- Final censor verdict: OK
- 2026-11-12 01:14:57 — Manager: Architect CENSOR подтверждён grep-гейтом (маркер `(Role CENSOR)` с префиксом метки времени 01:13:09, вердикт OK, dispatch id censor:architect:261112_011111, Observations непусты); диспатч Planner (переход Ready for Planner → Planning на intake Planner'а).
- 2026-11-12 01:20:05 — Planner: фаза завершена; владение предзаполненными Planner-зонами (DoD/Tests) перепринято фактической сверкой с корпусом, не rubber-stamp. Переработано в своей зоне: (1) Tests расширен T1–T4 → T1–T11 с мэппингом на D1–D11 один к одному — черновик оставлял D5–D11 без механизма проверки; (2) D2 дополнен уточнением скоупа C4/C5 — валидация формата встреченных receipt/intake-строк, отсутствие строк не дефект: обоснование живым корпусом — новый план 261112_0111 (Draft, без intake/receipt, ≥ cutoff 261111_1455) появился после Architect-фазы (Evidence 01:09:23 сверяло 4 плана); инвариант наличия дал бы ложный FAIL на валидном корпусе в T2; (3) D3 зафиксирован 10/10 (по одному дефекту на класс, Solution п.3) вместо абстрактного N/N; (4) D4 получили механизм проверки (осмотр mktemp/${TMPDIR} + чистый git status, fallback ${TMPDIR:-/tmp}); (5) D7 получил воспроизводимый ключ grep «программн» (в текущем README отсутствует, сверено). Решения Architect (Solution п.1–8, C1–C10, cutoff, Scope/Out of scope) не менялись. Открытых вопросов в Q&A log нет, A(owner)-записей нет — переносить в секции нечего. Точки встройки сверены с диска: coder.md CENSOR-чек-лист (строки 50–64, одна строка в список), README 66 строк без ops-строки, decisions.md формат соблюдён, lifecycle.md существует, remote пуст, scripts/ и .github/ отсутствуют, 5 роль-доков ↔ 5 planfaktor-агентов. Handoff: Ready for Coder.
- 2026-11-12 01:23:33 — (Role CENSOR) OK: Ready for Coder validated; current=true
Censor dispatch id: censor:planner:261112_012152
Observations:
- Second opinion: шапка — `**Status:** Ready for Coder` (строка 4), Plan ID `261111_2243` (строка 3) ↔ имя файла `261111_2243_corpus_lint_ci.md` — согласованы; PRE_STATUS_LINE конверта совпал. DoD проверяем прогоном/осмотром по каждому пункту D1–D11 (без «по необходимости»/«и т.д.»); Tests T1–T11 покрывают D1–D11 один к одному, у каждой команды — ожидаемый результат; открытых Q в логе нет, A(owner)-записей нет — переносить нечего; решения Architect (строки 11–138) после Evidence 01:09:23 не менялись (своя фаза правила только DoD/Tests/статус/логи). Чужие зоны не тронуты: Architect-секции, Changes (пуст), Manager-узлы Evidence — на месте.
- Counterfactuals considered: (1) контракты могли измениться между итерациями — shasum пересчитан: AGENTS.md@5cc19f0c / planner.md@9afeff0a, совпали с intake 01:18:41, миграционных записей об их смене в Evidence нет (§3 п.7 чист); (2) корпус мог измениться после handoff (прецедент — 0111 появился между фазами) — перепроверен: 261112_0111 по-прежнему Draft без intake, планов 5, README без «программн» (grep 0), remote пуст, scripts/.github отсутствуют, 5↔5 — контекстно-зависимые формулировки D2/T2 остаются валидными; (3) ложные ожидания T-команд: T5-регекс пересмотрен на обязательные элементы workflow (on:/push/pull_request/checkout/check_corpus.sh), T7-ключ «программн» подтверждён уникальным для будущей строки (в текущем README 0 вхождений), T9 покрывает и staged-изменения Coder'а (формулировка «изменены только файлы из ## Scope»), T11 `cut -c1-8` даёт ровно 8 hex для сверки с миграционной записью; (4) append-only: Evidence 22:43:59 → 22:54:03 → 01:09:23 → 01:14:57 → 01:20:05 хронологичен, Q&A log только дописывался.
- Addendum (new angle): (а) совместимость Tests с механикой Coder'а — docs/roles/coder.md п.3 фазы («каждую команду и результат — в секцию и в Evidence») совместим с форматом «команда → ожидание» + правилом «факты дописывает, ожидания не переписывает» (T10 это и проверяет); (б) петля самосогласованности: наш план ≥ cutoff 261111_1455 — этот receipt обязан сам соответствовать C4 (префикс метки времени, dispatch id, Final censor verdict) и написан по §4; после него корпус останется чистым для будущего линта; (в) D2-уточнение сверено с текстом Solution C4/C5 — формулировки Architect про формат строк и исключение плейсхолдеров, не про обязательность наличия: интерпретация внутри решения, не смена.
- Fixes: FAIL-пункт чек-листа «## Follow-ups заполнен» — секция была пуста на handoff; заполнена в этой итерации: v2 digest-сверка (Out of scope п.1), Q&A-линт (Out of scope п.2), отсутствие дубля S1 (уже в Follow-ups 261111_1455); исправлена опечатка «digest'цитат» → «digest-цитат». Других правок зон не потребовалось.
- Final censor verdict: OK
- 2026-11-12 01:24:43 — Manager: Planner CENSOR подтверждён grep-гейтом (маркер с префиксом метки времени 01:23:33, вердикт OK, dispatch id censor:planner:261112_012152, Observations непусты); открыт Owner-гейт «стартуем» (Ready for Coder → In progress), ожидание ответа Owner (owner-silence §6).
- 2026-11-12 01:26:22 — Manager: гейт «стартуем» пройден (Owner: «стартуем»), статус In progress; диспатч Coder.
- 2026-11-12 01:45:10 — Coder: реализация по Scope завершена. `scripts/check_corpus.sh` — corpus lint v1 (C1–C10 + `--selftest`, POSIX sh + grep/sed/cut/head/tail, без python; подробности — Changes); `.github/workflows/corpus.yml` (on push/pull_request, checkout, lint + selftest); `docs/roles/coder.md` +1 строка CENSOR-чек (Solution п.5); `README.md` ops-строка о правах записи программных сессий Manager'а (п.6); `docs/decisions.md` +1 запись о `scripts/` (п.7). В ходе отладки скрипта исправлены три собственных бага (Plan ID-префикс из двух сегментов имени; перестановка аргументов post_cutoff_plan_with; word splitting в итерации superseded-лейблов C7) — все до фиксации фактов. Прогоны: T1 exit 0; T2 `corpus: clean`/exit 0, C4/C5 excluded 0320/0427; T3 `selftest: 10/10 caught`/exit 0; T4 осмотр без python/TMPDIR-only/git status чист; T5–T8 grep-факты; T9 состав изменений = Scope (+чужой untracked 261112_0111, не трогался). Полная батарея перепрогнана после всех правок и записей плана — выводы в Tests/Commands.
- 2026-11-12 01:45:40 — Coder: миграция контракта по §3 п.7 — план меняет `docs/roles/coder.md` (+1 строка CENSOR-чек-листа: прогон `scripts/check_corpus.sh`, вывод в `## Evidence`): coder.md@9529b5d7 → coder.md@942a3f82. Дайджесты пересчитаны shasum; старый совпадает с intake 01:27:02, новый — с текущим файлом (T11).
- 2026-11-12 01:46:17 — Coder: фаза завершена; все D1–D11 закрыты (факты — Tests/Commands: T1–T11 пройдены, финальная батарея 01:45 — `corpus: clean`/exit 0 и `selftest: 10/10 caught`/exit 0); изменения staged: scripts/check_corpus.sh (A), .github/workflows/corpus.yml (A), docs/roles/coder.md (M), README.md (M), docs/decisions.md (M), этот план (A); чужой untracked 261112_0111 не тронут. Handoff: In review.
- 2026-11-12 01:49:02 — (Role CENSOR) OK: In review validated; current=true
Censor dispatch id: censor:coder:261112_014721
Observations:
- Second opinion: шапка перечитана с диска — `**Status:** In review` (строка 4), Plan ID `261111_2243` (строка 3) ↔ имя файла `261111_2243_corpus_lint_ci.md`, PRE_STATUS_LINE конверта censor:coder:261112_014721 совпал. Вся батарея T1–T11 перепрогнана в этой итерации (01:47:50–01:49:02) и воспроизвела факты Tests дословно: T1 тишина/exit 0; T2 — OK C1–C10 построчно, C4/C5 `excluded` для 0320/0427, итог `corpus: clean`/exit 0 (вывод приложен: `OK C1 statuses … OK C10 roles-vs-agents`, `corpus: clean` — прогон по требованиям новой строки coder.md:65, скрипт существует); T3 — `caught C1`…`caught C10`, `selftest: 10/10 caught`/exit 0; T5 — on:/push/pull_request (workflow:6), checkout (13), check_corpus.sh (15,17); T6 — coder.md:65 в CENSOR-чек-листе; T7 — README.md:67 «программно созданным сессиям Manager'а…»; T8 — decisions.md:111, формат соблюдён; T11 — `942a3f82` = «новый» миграционной записи Evidence 01:45:40. Staged-состав (git diff --cached --stat) = 6 путей Scope+план; unstaged-дельта плана — только мои append-записи логов этой итерации. DoD D1–D11 ↔ Changes попарно; чужие зоны не тронуты (DoD/Tests-ожидания Planner'а — строки 143–195 — перечитаны, дословно на месте); Follow-ups заполнен (3 записи).
- Counterfactuals considered: (1) факты Tests могли быть невоспроизводимы (прецедент T4 у 261111_1455) — вся батарея перепрогнана с нуля, exit-коды/строки/digest совпали; (2) staged мог разойтись с планом после handoff — git status перепроверен: изменений вне Scope нет, AGENTS.md/шаблоны/lifecycle/команды отсутствуют в списке, чужой 0111 по-прежнему нетронутый untracked; (3) отладочный мусор/временные следы — `find scripts .github` даёт ровно 2 ожидаемых файла, `*.lintmut` в репо нет, `check_corpus_selftest.*` в TMPDIR нет; (4) свежеисправленные баги могли остаться (Plan ID-префикс, аргументы post_cutoff_plan_with, C7-labels) — selftest 10/10 на перепрогоне подсаживает и ловит дефекты именно этих форм (C2/C4/C5/C7-сиды); (5) расхождение coder.md@942a3f82 с intake 01:27:02 могло быть незафиксированной сменой контракта — нет: миграционная запись Evidence 01:45:40 (§3 п.7), intake CENSOR записан с актуальным digest; (6) DoD-чекбоксы остались `[ ]` — факт закрытия DoD живёт в Tests/Changes/Evidence (зоны Coder'а), чекбоксы DoD — зона Planner, не трогал.
- Addendum (new angle): (а) самосогласованность C4 на этом плане: два receipt-блока подряд (Architect 01:13:09, Planner 01:23:33) — state machine корректно закрывает блок при открытии следующего (незакрытый дал бы `receipt #N incomplete`); настоящий receipt тоже ≥ cutoff — после него корпус обязан остаться clean, финальный контрольный прогон ниже; (б) новая строка coder.md:65 сама делает coder.md источником C9 — токен `scripts/check_corpus.sh` не матчит docs/…/.zcode/…-паттерн, ложных ссылок не создаёт (подтверждено clean-прогоном C9); (в) workflow использует on-список `[push, pull_request]` вместо пустых мап — валидная форма GitHub Actions, шаги uses/run чередуются корректно.
- Fixes: Changes — «~560 строк» → «696 строк» (сверка с git diff --cached --stat: 696 insertions скрипта); других правок не потребовалось. Контрольный прогон линта после записи receipt'а — `corpus: clean`, exit 0 (корпус с этим receipt'ом валиден).
- Final censor verdict: OK
- 2026-11-12 01:49:57 — Manager: Coder CENSOR подтверждён grep-гейтом (маркер с префиксом метки времени 01:49:02, вердикт OK, dispatch id censor:coder:261112_014721, Observations непусты, контрольный перепрогон T1–T11 clean); диспатч reviewer-risk (review-лайн 1 из 2).
- 2026-11-12 02:15:11 — Manager: risk-вердикт pass (grep-проверен: артефакт Round 1, `### Risk verdict: pass` с меткой 02:12:36, 5 minor-находок; диспатч reviewer-risk прерывался 10-минутным таймаутом неактивности — хендл продолжен, артефакт дозаписан; intake 01:50:43). Диспатч reviewer-contracts (review-лайн 2 из 2); до заполнения Contracts-лейна прогон линта ожидаемо красный на плейсхолдере вердикта (finding 5 артефакта — переходное состояние, задокументировано).
- 2026-11-12 02:20:26 — Manager: contracts-вердикт pass (grep-проверен: `### Contracts verdict: pass` с меткой 02:18:53, `## Итог` — итоговый вердикт pass, оба лайна без blocker/major); контрольный прогон Manager'а: `corpus: clean`/exit 0, `selftest: 10/10 caught`/exit 0. Открыт Owner-гейт merge (In review → Merged), ожидание ответа Owner (owner-silence §6).
- 2026-11-12 02:27:19 — Manager: гейт merge пройден (Owner: «давай»); merge-коммит `feat(261111_2243): add corpus lint script, CI stub and ops line` — 7 файлов (scripts/check_corpus.sh, .github/workflows/corpus.yml, docs/roles/coder.md, README.md, docs/decisions.md, этот план, docs/reviews/261111_2243_review.md); чужой untracked docs/plans/261112_0111_route_token_accounting.md в коммит не входит (артефакт другого плана, ждёт своей очереди). Статус Merged.
- 2026-11-12 02:27:45 — Manager: closeout — merge-коммит создан (64b6622, рабочее дерево чистое, кроме чужого untracked 261112_0111), `## Follow-ups` заполнен (3 хвоста с why: corpus lint v2 digest-сверка, Q&A-линт, S1-дубль исключён); статус Done.



## Q&A log (chronological, append-only)
<!-- owner: все роли; intake: `Intake (YYYY-MM-DD HH:MM:SS): AGENTS.md@<8hex> <role>.md@<8hex>` (локальное время) + NO QUESTIONS / NO SUGGESTIONS / NO OBJECTIONS; вопросы `Q(<роль>): ... to=Owner, blocker: yes|no, needs_owner: yes|no, status=open`; закрытие `A(<кто>): ... status=closed, перенесено в <секция>` -->

- Intake (2026-11-12 01:06:38): AGENTS.md@5cc19f0c architect.md@73ace930
  (PRE_STATUS_LINE=Draft сверен с шапкой, строка 4 — совпал; план прочитан
  целиком; для переприсвоения Architect-зон сверены с диска: все 4 плана
  корпуса и 3 review-артефакта (статусы, Plan ID, receipt/intake-формы,
  superseded-лейблы), оба шаблона, решения о cutoff C4/C5 по живым
  прецедентам 0427:395/0427:451, README.md, docs/roles/coder.md CENSOR-чек,
  docs/decisions.md, docs/lifecycle.md, .zcode/agents, .zcode/commands,
  git remote, отсутствие .github и scripts)
- architect: NO QUESTIONS (Owner-бриф и происхождение черновика зафиксированы
  в Evidence 22:43:59; отклонение «драфт вне ролей конвейера» явно
  запротоколировано там же)
- architect: NO SUGGESTIONS
- architect: NO OBJECTIONS (после фактической сверки с корпусом; перечень
  сверенного — Evidence 01:09:23)

- Intake (2026-11-12 01:11:30): AGENTS.md@5cc19f0c architect.md@73ace930
  (итерация CENSOR-прохода, dispatch censor:architect:261112_011111;
  PRE_STATUS_LINE=Ready for Planner сверен с шапкой, строка 4 — совпал;
  план перечитан с диска целиком; digest'ы пересчитаны shasum и совпали
  с рабочей итерацией 01:06:38 — контракты внутри фазы не менялись)
- architect (CENSOR): NO QUESTIONS
- architect (CENSOR): NO SUGGESTIONS
- architect (CENSOR): NO OBJECTIONS

- Intake (2026-11-12 01:18:41): AGENTS.md@5cc19f0c planner.md@9afeff0a
  (PRE_STATUS_LINE=Ready for Planner сверен с шапкой, строка 4 — совпал;
  план прочитан с диска целиком; для перепринятия Planner-зон (DoD/Tests)
  сверено с диска: состав корпуса docs/plans (5 планов, включая новый
  261112_0111 в Draft без intake-строк), 3 review-артефакта, 5 роль-доков
  ↔ 5 planfaktor-агентов, 3 команды, README.md (66 строк, «программн»/
  «права записи» отсутствуют), docs/roles/coder.md CENSOR-чек-лист
  (строки 50–64), хвост docs/decisions.md (формат «дата — решение —
  почему — альтернатива»), docs/lifecycle.md существует, git remote пуст,
  scripts/ и .github/ отсутствуют; digest AGENTS.md@5cc19f0c совпал
  с итерациями Architect'а 01:06:38/01:11:30 — контракты не менялись)
- planner: NO QUESTIONS (происхождение черновика и отклонение
  зафиксированы Evidence 22:43:59; решения Architect сверены с корпусом
  и непротиворечивы)
- planner: NO SUGGESTIONS
- planner: NO OBJECTIONS (пробел черновика «Tests покрывают не все
  пункты DoD» — зона Planner, закрываю в этой фазе сам; находка
  «261112_0111 Draft без intake» — не противоречие решения, а случай
  детализации C4/C5, фиксирую в DoD)

- Intake (2026-11-12 01:22:28): AGENTS.md@5cc19f0c planner.md@9afeff0a
  (итерация CENSOR-прохода, dispatch censor:planner:261112_012152;
  PRE_STATUS_LINE=Ready for Coder сверен с шапкой, строка 4 — совпал;
  план перечитан с диска целиком; digest'ы пересчитаны shasum и совпали
  с рабочей итерацией 01:18:41 — контракты внутри фазы не менялись;
  корпус перепроверен: 261112_0111 по-прежнему Draft без intake, планов 5,
  README без «программн», remote пуст, scripts/ и .github/ отсутствуют,
  5 роль-доков ↔ 5 planfaktor-агентов)
- planner (CENSOR): NO QUESTIONS
- planner (CENSOR): NO SUGGESTIONS
- planner (CENSOR): NO OBJECTIONS

- Intake (2026-11-12 01:27:02): AGENTS.md@5cc19f0c coder.md@9529b5d7
  (PRE_STATUS_LINE=In progress сверен с шапкой, строка 4 — совпал;
  план прочитан с диска целиком; digest AGENTS.md@5cc19f0c совпал
  с итерациями Architect'а/Planner'а — контракты не менялись;
  для реализации Scope сверены с диска: шаблоны _template.md/
  _template_review.md, 5 планов корпуса, 3 review-артефакта, 5 роль-доков,
  5 .zcode/agents/planfaktor-*.md, 3 .zcode/commands/, README.md,
  docs/decisions.md, git remote, отсутствие scripts/ и .github/)
- coder: NO QUESTIONS
- coder: NO SUGGESTIONS
- coder: NO OBJECTIONS

- Intake (2026-11-12 01:47:50): AGENTS.md@5cc19f0c coder.md@942a3f82
  (итерация CENSOR-прохода, dispatch censor:coder:261112_014721;
  PRE_STATUS_LINE=In review сверен с шапкой, строка 4 — совпал;
  план перечитан с диска целиком; digest AGENTS.md@5cc19f0c совпал
  с рабочей итерацией 01:27:02; coder.md@942a3f82 ≠ intake 01:27:02
  (9529b5d7) — смена контракта произведена этим планом и зафиксирована
  миграционной записью §3 п.7 в Evidence 01:45:40: расхождение
  предусмотрено, актуальный digest перечитан с диска)
- coder (CENSOR): NO QUESTIONS
- coder (CENSOR): NO SUGGESTIONS
- coder (CENSOR): NO OBJECTIONS

- Intake (2026-11-12 01:50:43): AGENTS.md@5cc19f0c reviewer-risk.md@607292b4
  (PRE_STATUS_LINE=In review сверен с шапкой, строка 4 — совпал; план
  прочитан с диска целиком; digest AGENTS.md@5cc19f0c совпал
  с итерациями Architect'а/Planner'а/Coder'а — конституция не менялась;
  coder.md@942a3f82 — смена зафиксирована миграционной записью §3 п.7
  Evidence 01:45:40)
- reviewer-risk: NO QUESTIONS
- reviewer-risk: NO SUGGESTIONS
- reviewer-risk: NO OBJECTIONS

- Intake (2026-11-12 02:16:52): AGENTS.md@5cc19f0c reviewer-contracts.md@8d1efb83
  (PRE_STATUS_LINE=In review сверён с шапкой, строка 4 — совпал; план
  прочитан с диска целиком; digest AGENTS.md@5cc19f0c совпал со всеми
  предыдущими итерациями плана — конституция не менялась;
  review-артефакт 261111_2243_review.md существует, Risk-вердикт записан
  с меткой 02:12:36 — лан contracts второй, порядок risk → contracts
  соблюдён)
- reviewer-contracts: NO QUESTIONS
- reviewer-contracts: NO SUGGESTIONS
- reviewer-contracts: NO OBJECTIONS

## Suggestions log (chronological, append-only)
<!-- owner: все роли; несрочные улучшения -->

## Objections log (chronological, append-only)
<!-- owner: все роли; `### <Role> objections`; строка на возражение, blocker: при блокере -->

## Follow-ups (deferred)
<!-- owner: coder/planner при CENSOR; незакрытые хвосты: <описание> — why: <почему сейчас не в скоупе>; обязательна запись `NO FOLLOW-UPS — why: <код_причины>` при отсутствии -->

- Corpus lint v2: сверка значений `@<8hex>`-digest-цитат в планах с фактическим `shasum` контрактов (класс a2c2faf8↔a2c2faf9, Problem п.2) — why: осознанно Out of scope п.1 (v2, отдельным планом); v1 ловит только формовые нарушения (C6).
- Q&A-линт: грамматика Q&A log (`status=open` без закрытия, формат Q/A-строк) — why: Out of scope п.2, грамматика сложна для grep-v1; кандидат в v2 вместе с digest-сверкой.
- S1-агрегация метрик длительностей не дублируется — why: уже зафиксирован в Follow-ups плана 261111_1455 (Out of scope п.3).
