# Corpus hygiene sweep: контракт Coder'а, линт-хрупкости, канон-дрейфы

**Plan ID:** 261117_1419
**Status:** Merged
**Created:** 2026-11-17
**Owner gates:** merge (`In review` → `Merged`); вопросы `to=Owner` — по мере возникновения

> Шапка — parser-контракт: строки выше grep'аются Manager'ом. Не менять формат.
> Имя файла: `YYMMDD_HHMM_topic.md` (тема латиницей, слова через `_`).

## Как я понял задачу
<!-- owner: architect; 3–7 строк; обязательна при Architect intake -->
Ревью кодовой части (2026-11-17) дало S2-дефект контрактного уровня (агент
Coder'а противоречит легальному fixes-диспатчу) и шесть S3-классов +
канон-дрейфы; черновик — кураторский §1(g), зоны переприняты мной живой
верификацией против репозитория (кураторский repro — untrusted input).
Сверка: 6 из 8 находок подтверждены дословно; п.6 инвертирован (носитель —
run.md:11 с 2>/dev/null, init.md:27 уже чист), п.3 наполовину исполнен
носителем (грамматика registry.md уже запрещает ` — ` — жива только
диагностика), п.8 опровергнут в heredoc-части и подтверждён в cwd-части.
Развилки закрыты: C6-порог {7,}; reroute-якорь — AGENTS §2.
S2 идёт первым шагом Coder'а и самолечит собственный fixes-раунд;
backlog-пачка (3 promoted + 7 open) закрывается этим планом.

## Problem
<!-- owner: architect; пронумерованные пункты; верификация Architect 2026-11-17 15:07–15:23 — живые прогоны, не перенос куратора -->
1. **S2 — противоречие контрактов** (подтверждено дословно):
   `planfaktor-coder.md:12–13` требует «Сверь фактический статус плана
   с `PRE_STATUS_LINE` (ожидается `In progress`); расхождение — стоп» — но
   конституция §2 (`AGENTS.md:66`) легализует `In review → In progress`
   (fixes-интейк: «Coder ставит статус на intake fixes-итерации»), и
   /planfaktor-run (шаг 4, needs-fix без Loop signal) диспатчит Coder'а при
   статусе плана `In review` — конверт понесёт `PRE_STATUS_LINE: In review`.
   Первый needs-fix-возврат рискует упереться в ложный стоп роли.
2. **C6 — ложный позитив на `@`-упоминаниях** (`check_corpus.sh:464`,
   подтверждено прогоном детектора): `grep -oE '@[0-9A-Fa-f]+'` без порога
   длины матчит упоминание ника coder как одно-символьный hex-хвост
   (c, 1 hex ≠ 8 → FAIL); ники c0de → 4 hex, facade → 6 hex — все буквы
   hex. Любой hex-стартующий ник ≤6 hex в плане даст ложный FAIL;
   реальные классы формовых опечаток — 7/9/10/11-hex хвосты (selftest-байт
   C6 — 11-hex литерал abcdef12345 после собаки).
3. **C12(б) — диагностика разделителя** (механизм подтверждён,
   формулировка сужена верификацией): `sed 's/ — /|/g'` глобален по строке
   реестра (`check_corpus.sh:776`), внутренний ` — ` в тексте формулировки
   даёт NF>8 → FAIL. Это корректный fail по грамматике — запрет ` — `
   в формулировке уже закреплён носителем (`registry.md:18–19`: «Формулировка
   не содержит ` — ` … иначе счёт полей ломается») — живой дефект только
   в качестве диагностики: FAIL «row has N fields» не называет причину
   (разделитель в формулировке), и класс не покрыт selftest-кейсом (c12b
   сеет невалидный статус, не разделитель).
4. **Канон-дрейфы** (подтверждены): (а) ровно 5 агент-файлов пишут
   `PASS=censor` против канона §4 `PASS: censor` (`AGENTS.md:172`,
   run.md:131) — planner:22, coder:23, architect:25, reviewer-contracts:40,
   reviewer-risk:34 (у ревьюеров — упоминание формы конверта, тоже
   унифицируется); (б) reroute-таксономия в двух нотациях без якоря
   эквивалентности — дефисные (`run.md:258`, `architect.md:32,38`, enum
   C13 `C13_ROOT_RE`) и пробельные (`AGENTS.md:67`, `architect.md:23`);
   (в) двусмысленная ссылка `planfaktor-status.md:49` «(шаг 5 ранее)» —
   текст перенесён в шаги 6–7 (решение 2026-11-12), а шаг 5 сегодня
   о другом.
5. **CI — двойной прогон на PR-пуш** (`corpus.yml:6`, подтверждено):
   `on: [push, pull_request]` + concurrency по `github.ref`: push в PR-ветку
   и PR-событие несут разные ref → OS-матрица отработает дважды. Сегодня
   работа идёт в main — эффекта нет; задел на появление PR-флоу.
6. **run.md:11 — заглушённый stderr** (инверсия кураторской находки,
   установлена верификацией: в init.md нет `2>` вообще — grep пуст):
   `grep -H '^\*\*Status:\*\*' docs/plans/[0-9]*.md 2>/dev/null` в шаге 1
   run.md гасит и шум пустого glob, и реальные ошибки чтения; init.md:27
   уже несёт паттерн без подавления — эталон. Обратный edge (строка
   backlog init-grep-stderr): без подавления пустой
   `docs/plans/[0-9]*.md` даёт stderr-шум пустого glob — закрывается
   guard-механикой, не маскировкой stderr.
7. **hex-опечатка T4** (строка hex-typo-t4; подтверждено: живая цитата —
   строка 493, секция `## Tests / Commands` с заголовка 421): Tests-цитата
   блока коррекции T4 плана 261111_1455 несёт `@a2c2faf8`; верное
   значение — `a2c2faf9` (Evidence 17:25:18 и D13; вывод ревьюера
   пересчитан и верен). Вхождения 1250 (Evidence merge-узла) и 1454
   (Follow-ups) описывают саму опечатку как инцидент — исторические,
   не правятся. Правка предписана строкой backlog: зоной Coder'а, первым
   планом, трогающим Tests.
8. **Робастность линта** (строка lint-robustness; сверена почастично):
   (а) cwd-чувствительность C9 — подтверждена прогоном с точным
   механизмом: `for _c9_tok in $(grep …)` — pathname expansion полей
   unquoted-подстановки по текущему cwd; из корня репо `docs/roles/*`
   случайно глобится в существующие файлы (проверка делает не то, что
   задумано), из /tmp остаётся литералом → ложный FAIL (живой прогон:
   `corpus: 1 failures`, dangling `.zcode/commands/*`, `docs/roles/*`
   из AGENTS.md/CONTRIBUTING.md); (б) awk используется C12/C13
   (`check_corpus.sh:777,979`), но не заявлен в шапке утилит (строки
   21–24) — расхождение самодокументации; (в) heredoc-часть исходной
   находки опровергнута верификацией: раскрытие бэктиков/`$(...)` из
   значений переменных в неквотированных heredoc'ах C4/C5/C11/C12
   не воспроизводится (POSIX не ресканирует результат expansion;
   контрольный прогон — чисто).

## Solution / Decisions
<!-- owner: architect; решения уровня «что и почему», без детализации; развилки закрыты верификацией 2026-11-17 15:07–15:23 -->
1. **S2 — первым шагом Coder'а**: coder.md — «(ожидается `In progress` —
   основной диспатч — либо `In review` — fixes-диспатч: расхождение
   с фактическим статусом остаётся стопом)». Правка ляжет в фазе Coder,
   до собственного ревью плана — needs-fix-раунд этого же плана пойдёт
   по исправленному контракту.
2. **C6 — порог длины `{7,}`** (финальное решение Architect; проверяемо
   DoD: ники ≤6 hex не FAIL, 7-hex ловится): детектор
   `grep -oE '@[0-9A-Fa-f]{7,}'` — ловит реальные классы формовых
   опечаток (7/9/10/11-hex — не-8), отсекает ники ≤6 hex (c, c0de,
   facade — hex-стартующие); 8-hex ник неотличим от дайджеста — принятая
   граница. Тест длины `-ne 8` и sed-вырезание литерала `@8hex`
   сохраняются; комментарий C6 уточнить: плейсхолдер `@<8hex>` безопасен
   `<`-обрывом мача сразу после `@` (sed-замена его не трогает — между
   `@` и `8hex` стоит `<`).
   rejected alternative: якорь `\.md@` — выпадает класс без-префиксных
   цитат (живой прецедент: `digest @a2c2faf8` в 1455:493).
   rejected alternative: порог `{4,}` — ники c0de (4 hex), facade
   (6 hex) дают ложный FAIL.
3. **C12 — диагностика, не грамматика** (сужено верификацией): запрет
   ` — ` в формулировке уже закреплён носителем (registry.md:18–19) —
   реестр не правится; линт остаётся fail-loud, диагностика C12(б)
   дополняется причиной «разделитель ` — ` в формулировке» (файл + строка
   + подсказка), покрывается selftest-кейсом (Solution п.11). Судьба
   строки c12-desc-separator — handled этим планом при closeout.
4. **PASS=censor → PASS: censor** во всех 5 агент-файлах (включая
   ревьюерские упоминания формы конверта) — единый канон §4.
5. **Reroute-якорь — AGENTS.md §2** (дизъюнкция снята; decisions.md
   отклонён): однострочное примечание в абзаце Reroute-классификации §2 —
   канон дефисные токены enum (stale-evidence, same-contract-reroute,
   closed-baseline-split, real-scope-expansion, de-scoped-followup;
   носитель формы — `C13_ROOT_RE`), пробельные написания — легальный
   синоним в прозе.
   rejected alternative: docs/decisions.md — файла нет в корпусе
   (существовал на 2026-11-11, удалён), и reroute-классы — контракт
   статусной машины §2, не проектное решение. Проверяемо DoD: один
   носитель несёт обе формы и слово «канон».
6. **status.md:49**: ссылку привести к факту — «(перенос из шага 5,
   решение 2026-11-12)» вместо «(шаг 5 ранее)».
7. **corpus.yml**: `on: push: branches: [main]` + `pull_request:` — по
   событию одно срабатывание; сегодняшнее поведение в main не меняется.
8. **run.md:11 — снять маскировку stderr** (инверсия черновика по
   верификации): убрать `2>/dev/null` из grep шага 1; edge пустой
   очереди (stderr-шум нераскрытого glob, строка init-grep-stderr)
   закрывается guard-механикой существования файлов до grep — без
   подавления stderr; механику паттерна задаёт Planner. init.md не
   правится (уже без подавления).
9. **T4**: правка Tests-цитаты `@a2c2faf8` → `@a2c2faf9` — единственная
   живая веха: строка 493 плана 261111_1455 (секция Tests; предписана
   строкой backlog); строки 1250/1454 (Evidence/Follow-ups — фиксация
   инцидента) не правятся — исторические.
10. **Cwd-фикс C9 + awk** (heredoc-часть отклонена верификацией):
    подавить pathname expansion в цикле токенов C9 (инвариант — итерация
    полей без globbing; конкретная механика подавления — за Coder'ом,
    например `set -f`), glob-токены `docs/roles/*` и
    `.zcode/commands/*` (AGENTS.md, CONTRIBUTING.md) добавить литеральными
    формами в case-allowlist C9; проверка существования остаётся от
    `$_c9_corpus` (уже якорено от ROOT, аргумент корпуса в main не
    вводится — интерфейс стабилен, Tests-команда cwd-контроля — запуск
    без аргумента из произвольного cwd). Шапка утилит += awk.
    rejected alternative: квотированный heredoc `<<'EOF'` / чтение
    файлом в C4/C5/C11/C12 — раскрытие бэктиков из значений переменных
    не воспроизводится (POSIX не ресканирует expansion), а квотирование
    сломало бы подстановку `$_cX_…` в тело heredoc.
11. **Selftest 36→38, состав фиксирован** (решение Architect): (позитив)
    C6 — план с hex-стартующими никами ≤6 hex (упоминания coder/c0de/
    facade с собакой) не роняет C6; (негатив) C12(б) — ` — `
    в формулировке строки реестра → FAIL с диагностикой. Heredoc-кейс
    в состав не входит — класс опровергнут (п.10).
12. **Backlog-пачка** (промоушен/материализация исполнены Manager'ом
    15:02:57): 7 open-строк (s2-coder-status-contract, c6-hex-nick-threshold,
    c12-desc-separator, pass-censor-notation, reroute-notation-anchor,
    status-cmd-link, ci-pr-dedup) закрываются этим планом — терминальные
    disposition (handled) при closeout; из 3 promoted: hex-typo-t4 —
    правка 493 (п.9); lint-robustness — живут cwd- и awk-части (п.10),
    heredoc-часть закрывается disposition «опровергнута верификацией
    плана» (без правки кода); init-grep-stderr — трансформируется
    в run.md-фикс + guard (п.8), disposition при closeout; index
    пересобрать.

## Scope
<!-- owner: architect (границы), planner (уточняет); fan-out инвентарь для shared-контрактов -->
Изменения:
- `.zcode/agents/planfaktor-coder.md` — S2 (ожидания статуса, :12–13)
  + PASS: унификация (:23);
- `.zcode/agents/planfaktor-{architect,planner,reviewer-risk,reviewer-contracts}.md`
  — PASS: унификация;
- `scripts/check_corpus.sh` — C6 порог `{7,}` + комментарий плейсхолдера,
  C12(б) диагностика причины, C9 cwd-фикс (без pathname expansion) +
  литеральные glob-формы в allowlist, awk в шапке утилит, selftest 36→38
  (Solution п.11);
- `.zcode/commands/planfaktor-status.md` — ссылка (строка 49);
- `.zcode/commands/planfaktor-run.md` — шаг 1: grep без `2>/dev/null`
  + guard существования планов до grep;
- `.github/workflows/corpus.yml` — триггеры;
- `AGENTS.md` — reroute-якорь §2 (однострочное примечание, Solution п.5);
- `docs/plans/261111_1455_hardening_after_dogfood.md` — T4-цитата
  (строка 493, Tests);
- `docs/followups/backlog.md` + `index.md` — терминальные disposition
  пачки при closeout (промоушен/материализация уже исполнены).
Не правятся (решение Architect): `docs/requirements/registry.md` — запрет
` — ` уже в грамматике (18–19); `.zcode/commands/planfaktor-init.md` —
grep уже без подавления; строки 1250/1454 плана 1455 — исторические.
Fan-out инвентарь (§5):
- агент-файлы + команды — контракты §1: digest-миграция (intake ролей
  цитируют новые дайджесты, C15 membership зелёный — правки создают новые
  исторические состояния); C10 (5 ролей ↔ агенты) не меняется;
- `AGENTS.md` — shared-контракт: digest-миграция intake всех ролей;
  §2-примечание меняет только прозу абзаца reroute — таблица переходов
  и §4 не затронуты;
- `check_corpus.sh` — shared: selftest-счётчик синхронен числу кейсов
  (36→38), smoke не затронут (fast-path C15), CI прогоняет счётчик;
  C9-allowlist расширяется литеральными glob-формами — потребитель
  C9 (сам линт) согласован в одном файле;
- `261111_1455` — исторический план: pre-cutoff для C4/C5/C11 (правка
  Tests не ломает), C6/C14 глобальны — `@a2c2faf9` (8 hex) и чистый
  контент проходят;
- `corpus.yml` — actionlint зелёный; consumer-пути CI без правок кода;
- `run.md` — команда Manager-рутины: правка grep шага 1 не добавляет
  путь-токены (C9-поверхность `.zcode/commands` остаётся чистой).

## Out of scope
<!-- owner: architect -->
1. Supply-chain-pinning (SHA-пиннинг checkout + checksum бинарников) —
   отдельная строка, тяжёлее пачки (вкл. finding #5 ревью).
2. stale-intake-digest (P2), role-tier-norming (P3) — не этого класса.
3. Наблюдения ревью без действий: C15-коммиты-удаления (теоретические),
   C14-поведение на бинарных матчах (fail-loud сохраняется), `ls`-парсинг
   C10 (имена без пробелов).
4. PR-флоу как таковой — только подготовка триггеров CI под него.
5. Переписывание исторических записей 1455 вне Tests-цитаты T4 (строки
   1250/1454 — фиксация инцидента, append-only).

## Acceptance criteria / DoD
<!-- owner: planner; чек-лист проверяемых исходов; перепринят по Solution п.1–12 (Architect objection 15:24:40 исполнен: носитель stderr инвертирован run.md←init.md, C12 сужен до диагностики, heredoc-пункт выпал; нумерация D1–D13) -->
- [ ] D1: coder.md (:12–14) — сверка PRE_STATUS_LINE ожидает оба легальных
      статуса: `In progress` (основной диспатч) и `In review` (fixes-диспатч);
      расхождение с фактическим статусом остаётся стопом.
- [ ] D2: детектор C6 (:464) — порог `{7,}` в `grep -oE '@[0-9A-Fa-f]{7,}'`:
      hex-стартующие ники ≤6 hex (упоминания coder/c0de/facade с собакой)
      не FAIL; хвост ≥7 hex ловится; тест `-ne 8` и sed-вырезание
      плейсхолдера `@8hex` сохраняются; комментарий C6 (:455–457) точен:
      порог, класс ников, `<`-обрыв мача плейсхолдера `@<8hex>`
      (между `@` и `8hex` стоит `<` — sed-замена его не трогает).
- [ ] D3: C12(б) — диагностика: FAIL «row has N fields» дополняется
      причиной «разделитель ` — ` в формулировке» (файл, номер строки
      реестра, подсказка на грамматику registry.md:18–19);
      `docs/requirements/registry.md` не правится — запрет уже закреплён
      носителем (Solution п.3).
- [ ] D4: `PASS=censor` — 0 вхождений в `.zcode/agents/`; `PASS: censor` —
      ровно 5 файлов.
- [ ] D5: однострочное примечание в абзаце Reroute-классификации §2
      (AGENTS.md:73): канон — дефисные токены enum `C13_ROOT_RE`
      (stale-evidence, same-contract-reroute, closed-baseline-split,
      real-scope-expansion, de-scoped-followup), пробельные написания —
      легальный синоним в прозе; строка несёт обе формы и слово «канон».
- [ ] D6: status.md:49 — «(шаг 5 ранее)» заменено на «(перенос из шага 5,
      решение 2026-11-12)»; формулировка шага согласована с шагами 6–7.
- [ ] D7: corpus.yml (:6) — `on: push: branches: [main]` + отдельное
      `pull_request:` (одно срабатывание на событие); `actionlint` чист.
- [ ] D8: run.md:11 — grep доклада очереди без `2>/dev/null`; edge пустой
      очереди закрыт guard-паттерном Planner'а (Solution п.8): раскрытие
      списка файлов переносится из glob интерпретатора в find —
      `find docs/plans -maxdepth 1 -name '[0-9]*.md' -type f -exec
      grep -H '^\*\*Status:\*\*' {} +` (пустая очередь — пустой вывод,
      exit 0, stderr чист; реальные ошибки чтения grep'ом не маскируются;
      кросс-оболочно: for-цикл по glob в zsh падает «no matches found»
      до guard'а — живой прогон CENSOR, receipt ниже); init.md не тронут
      (grep :27 уже без подавления).
- [ ] D9: 1455:493 — Tests-цитата T4: `@a2c2faf8` → `@a2c2faf9`;
      единственная правка файла (строки 1250/1454 — фиксация инцидента —
      не тронуты); значение согласовано с Evidence 17:25:18 и D13 плана.
- [ ] D10: C9 — итерация токенов без pathname expansion (инвариант;
      механика подавления — за Coder'ом, Solution п.10); литеральные
      glob-формы `docs/roles/*` и `.zcode/commands/*` (полный inventory
      glob-токенов корпуса — ровно эти два) добавлены в case-allowlist C9;
      проверка существования остаётся от `$_c9_corpus`; запуск без
      аргумента из произвольного cwd → `corpus: clean`.
- [ ] D11: шапка утилит check_corpus.sh (:21–24) заявляет awk
      (используется C12 :777 и C13 :979).
- [ ] D12: selftest 36→38: `_st_total`=38 и комментарий шапки (`N/36`→
      `N/38`) синхронны числу кейсов; состав новых — ровно два
      (Solution п.11): (позитив) C6 — план с никами ≤6 hex не роняет C6;
      (негатив) C12(б) — разделитель в формулировке строки реестра → FAIL
      с новой диагностикой; итоги: `corpus: clean` (включая C10 5↔5 и
      C15 — digest-миграция контрактов на intake следующих итераций),
      `selftest: 38/38 caught`, `smoke: clean`.
- [ ] D13: closeout-условия: CI-прогон corpus-lint на merge-коммите —
      success; 10 строк backlog-пачки `plan=261117_1419` (3 promoted +
      7 open, Solution п.12) несут терминальный статус handled с
      disposition (heredoc-часть lint-robustness — «опровергнута
      верификацией плана», без правки кода); index.md пересобран =
      backlog.md.

## Tests / Commands
<!-- owner: planner (задаёт), coder (заполняет факт); каждый Dn покрывается строкой с меткой (Dn); команды из корня репо, если не указано иное. Порядок Coder'а: правка D2 (порог C6) — до первых selftest/smoke-прогонов (Evidence 15:27:40: @-хвосты ≤6 hex в этом плане правомерно роняют старый C6; после фикса проходят) -->
- (D1) `sed -n '9,15p' .zcode/agents/planfaktor-coder.md` — абзац сверки
  PRE_STATUS_LINE несёт оба статуса и слова «основной диспатч» /
  «fixes-диспатч»; стоп по расхождению с фактическим статусом сохранён.
- (D2) `grep -n "grep -oE '@\[0-9A-Fa-f\]{7,}'" scripts/check_corpus.sh`
  → ровно 1 — детектор check_c6 (:464); границы порога:
  `printf '@%s @%s @%s\n' coder c0de facade | grep -coE '@[0-9A-Fa-f]{7,}'`
  → 0 (ники ≤6 hex не матчатся);
  `printf '@%s\n' abcdef0 | grep -oE '@[0-9A-Fa-f]{7,}'` → ловит хвост
  7 hex;
  `printf '@%s\n' a2c2faf9 | grep -coE '@[0-9A-Fa-f]{7,}'` → 1
  (порог пускает 8-hex дайджест — отсечение не-8 остаётся за `-ne 8`);
  `sed -n '455,458p' scripts/check_corpus.sh` — комментарий C6: порог,
  класс ников, `<`-обрыв `@<8hex>`; `grep -n 's/@8hex/@/g' scripts/check_corpus.sh`
  → вырезание плейсхолдера на месте.
- (D3) `grep -n 'разделител' scripts/check_corpus.sh` → вхождение в
  диагностическом сообщении check_c12 (причина + файл + подсказка на
  registry.md); `git diff --stat -- docs/requirements/registry.md` →
  пусто; `sed -n '18,19p' docs/requirements/registry.md` — запрет уже
  в грамматике (контроль неизменности).
- (D4) `grep -rc 'PASS=censor' .zcode/agents/ | grep -v ':0$'` → пусто;
  `grep -rl 'PASS: censor' .zcode/agents/ | wc -l` → 5.
- (D5) `grep -n 'same-contract-reroute' AGENTS.md` → ровно 1 строка —
  примечание в §2 (абзац Reroute-классификации, :73); выводимая строка
  сама несёт слово «канон», дефисные токены enum и пробельный синоним.
- (D6) `sed -n '49p' .zcode/commands/planfaktor-status.md` → «(перенос
  из шага 5, решение 2026-11-12)»; `grep -c 'шаг 5 ранее' .zcode/commands/planfaktor-status.md`
  → 0.
- (D7) `sed -n '5,8p' .github/workflows/corpus.yml` — `push:` с
  `branches: [main]`, `pull_request:` отдельным ключом;
  `actionlint .github/workflows/corpus.yml` → exit 0, вывод пуст.
- (D8) `grep -c '2>/dev/null' .zcode/commands/planfaktor-run.md` → 0;
  `sed -n '9,16p' .zcode/commands/planfaktor-run.md` — блок шага 1 несёт
  find-механику D8 с grep без подавления; edge: пустая очередь —
  `mkdir -p /tmp/d8e/docs/plans && cd /tmp/d8e && find docs/plans
  -maxdepth 1 -name '[0-9]*.md' -type f -exec grep -H x {} +` → пустой
  вывод, exit 0, stderr чист;
  `git diff -- .zcode/commands/planfaktor-init.md` → пусто (файл не
  тронут).
- (D9) `sed -n '493p' docs/plans/261111_1455_hardening_after_dogfood.md`
  → содержит `@a2c2faf9`;
  `sed -n '/## Tests/,/## Changes/p' docs/plans/261111_1455_hardening_after_dogfood.md | grep -c 'a2c2faf8'`
  → 0; `git diff -- docs/plans/261111_1455_hardening_after_dogfood.md`
  → единственный hunk — строка 493; `grep -n 'a2c2faf8' docs/plans/261111_1455_hardening_after_dogfood.md`
  → только :1250 и :1454 (исторические).
- (D10) `(cd /tmp && sh <repo>/scripts/check_corpus.sh)` — без
  позиционного аргумента (main принимает только --selftest/--smoke,
  прочее — usage exit 2) → `corpus: clean`, exit 0; тот же исход из
  корня репо; `grep -Fn 'docs/roles/*' scripts/check_corpus.sh` и
  `grep -Fn '.zcode/commands/*' scripts/check_corpus.sh` → литеральные
  формы в case-allowlist C9 (:625–632).
- (D11) `sed -n '21,24p' scripts/check_corpus.sh` — awk заявлен в
  перечне утилит.
- (D12) `sh scripts/check_corpus.sh` → `corpus: clean`;
  `sh scripts/check_corpus.sh --selftest` → `selftest: 38/38 caught`,
  exit 0; `sh scripts/check_corpus.sh --smoke` → `smoke: clean`;
  `grep -n '_st_total=' scripts/check_corpus.sh` → 38;
  `grep -c 'N/36' scripts/check_corpus.sh` → 0; состав: selftest-блок
  несёт сиды обоих новых кейсов — `grep -n 'facade' scripts/check_corpus.sh`
  ≥1 (позитив C6); вывод `--selftest` содержит caught-строку нового
  C12-кейса (разделитель в формулировке; точный лейбл кейса фиксирует
  Coder по факту прогона).
- (D13) `gh run list --workflow=corpus.yml --limit 1` → success на
  merge-коммите (после Owner-гейта, фиксация при closeout); при
  closeout: `grep 'plan=261117_1419' docs/followups/backlog.md | grep -c 'status=handled'`
  → 10; `head -9 docs/followups/index.md` — счётчики пересобраны и
  равны факту backlog.md.

### Coder run facts (2026-11-17, прогоны 16:29–16:52; все — из корня
### репо, если не указано иное)

- (D1) `sed -n '9,15p' .zcode/agents/planfaktor-coder.md` — абзац несёт
  оба статуса («`In progress` — основной диспатч — либо `In review` —
  fixes-диспатч»), стоп по расхождению сохранён — OK.
- (D2) `grep -n "grep -oE '@\[0-9A-Fa-f\]{7,}'" scripts/check_corpus.sh`
  → ровно 1 (:477); границы: `printf '@%s @%s @%s\n' coder c0de facade |
  grep -coE '@[0-9A-Fa-f]{7,}'` → 0; `printf '@%s\n' abcdef0 | grep -oE
  '@[0-9A-Fa-f]{7,}'` → вывод — мач с 7-hex хвостом abcdef0 (ловится);
  `printf '@%s\n' a2c2faf9 | grep -coE '@[0-9A-Fa-f]{7,}'` → 1
  (8-hex пускается, отсечение не-8 — за `-ne 8`); комментарий C6 —
  порог/ники/`<`-обрыв (:462–468, сместились от :455 на +7 новой
  летописью шапки); `grep -n 's/@8hex/@/g'` → :477, вырезание на месте.
- (D3) `grep -n 'разделител' scripts/check_corpus.sh` → вхождения,
  включая диагностический printf check_c12 (:815: причина + файл
  $REQ_REGISTRY + номер строки + registry.md:20-21); факт-уточнение:
  запрет ` — ` живёт в registry.md:20–21, а не :18–19 (там пункт
  ID-грамматики; сверка sed 18,19p/20,21p) — подсказка ведёт на
  верифицированный адрес, Assumption 16:22:10; `git diff --stat --
  docs/requirements/registry.md` → пусто.
- (D4) `grep -rc 'PASS=censor' .zcode/agents/ | grep -v ':0$'` → пусто;
  `grep -rl 'PASS: censor' .zcode/agents/ | wc -l` → 5.
- (D5) `grep -n 'same-contract-reroute' AGENTS.md` → ровно 1 строка
  (:81), несёт «канон», дефисные токены enum и пробельный синоним
  (`same contract reroute`, `real scope expansion`).
- (D6) `sed -n '49p' .zcode/commands/planfaktor-status.md` →
  «(перенос из шага 5, решение 2026-11-12)»; `grep -c 'шаг 5 ранее'` → 0.
- (D7) `sed -n '5,8p' .github/workflows/corpus.yml` → `on: push:
  branches: [main]` + `pull_request:` отдельным ключом; `actionlint
  .github/workflows/corpus.yml` → exit 0, вывод пуст.
- (D8) `grep -c '2>/dev/null' .zcode/commands/planfaktor-run.md` → 0;
  `sed -n '9,16p'` — find-механика + grep без подавления; edge: пустая
  очередь в `/tmp/d8e` → пустой вывод, exit 0, stderr чист; `git diff --
  .zcode/commands/planfaktor-init.md` → пусто.
- (D9) `sed -n '493p' …1455…` → содержит `@a2c2faf9`; в Tests-секции
  (до `## Changes`) `a2c2faf8` → 0; `git diff -U0` по файлу → ровно
  1 hunk; `grep -n 'a2c2faf8'` → только :1250 и :1454.
- (D10) `(cd /tmp && sh <repo>/scripts/check_corpus.sh)` без аргумента →
  `corpus: clean`, exit 0; тот же исход из корня репо → `corpus: clean`,
  exit 0; `grep -Fn 'docs/roles/*'` → :655 case-allowlist (+ :626
  комментарий), `grep -Fn '.zcode/commands/*'` → :656 case-allowlist
  (+ :626, :637 — реальный glob источников C9).
- (D11) `sed -n '21,24p'` теперь попадает в летопись-шапку (строки
  сместились +4 от нового источника 261117_1419): awk-строка —
  `sed -n '25,29p'` → «POSIX sh + grep/sed/awk/cut/head/tail/mktemp/
  git/shasum (awk — C12/C13: подсчёт полей row и поиск границ секций;
  …)» — awk заявлен.
- (D12) `sh scripts/check_corpus.sh` → `corpus: clean`, exit 0;
  `--selftest` → `selftest: 38/38 caught`, exit 0, включая
  `caught C6b (hex-nick mentions <=6 hex stay green)` и
  `caught C12d (separator in wording)`; `--smoke` → `smoke: clean`,
  exit 0; `grep -n '_st_total='` → :1678, значение 38; `grep -c 'N/36'`
  → 0; `grep -n 'facade'` → :463 (комментарий C6), :1765/:1771 (сид
  кейса c6b).
- (D13) N/A в Coder-фазе (AC-to-test 16:07:40): CI на merge-коммите и
  терминальные disposition 10 строк — closeout за Owner-гейтом merge
  (§8); проверяемая в Coder-фазе часть отсутствует.
- Сводка серий: полный линт + selftest + smoke прогнаны дважды
  (16:29–16:33 — после D-правок; 16:46–16:52 — финал после правки
  диагностического сообщения C12 на :20-21) — итоги стабильны:
  clean / 38/38 / clean; /tmp-cwd-прогон — clean. Прерывание диспатча
  (таймаут неактивности 600с и ожидание разрешения Bash,
  operational_retry §6 — оба зафиксированы Manager'ом) пришлось на
  Tests (D8c/D9) и живой repro C12-диагностики (покрыт selftest-кейсом
  c12d, отдельный repro не строился) — повторено простыми командами,
  состояние по файлам сверено перед продолжением.

## Changes (by area)
<!-- owner: coder; фактические изменения по областям; заполняется в ходе работы -->
- `.zcode/agents/planfaktor-coder.md` (D1, D4): сверка PRE_STATUS_LINE
  теперь ожидает оба легальных статуса — «`In progress` — основной
  диспатч — либо `In review` — fixes-диспатч»; стоп по расхождению
  с фактическим статусом сохранён; `PASS=censor` → `PASS: censor`
  (:24).
- `.zcode/agents/planfaktor-{architect,planner,reviewer-risk,reviewer-contracts}.md`
  (D4): `PASS=censor` → `PASS: censor` (architect:25, planner:22,
  reviewer-risk:34, reviewer-contracts:40).
- `scripts/check_corpus.sh` (D2, D3, D10, D11, D12): C6-детектор —
  порог `grep -oE '@[0-9A-Fa-f]{7,}'` (:477), комментарий C6 переписан
  (порог {7,}, класс ников ≤6 hex, `<`-обрыв плейсхолдера `@<8hex>`,
  сохранность sed-вырезания `@8hex`); C12(б) — при NF>8 диагностика
  несёт причину «разделитель ` — ` в формулировке», номер строки
  реестра (grep -nF по row), число разделителей и подсказку на
  грамматику registry.md:20-21 (верифицированный адрес запрета;
  DoD-ссылка :18-19 неточна — Assumption 16:22:10); C9 — токен-цикл
  под `set -f`/`set +f` (итерация полей без pathname expansion),
  литеральные `'docs/roles/*'` и `'.zcode/commands/*'` в case-allowlist,
  комментарий-обоснование; шапка утилит += awk (:25, сместилась +4 от
  летописи) с назначением (C12/C13); летопись += источник 261117_1419;
  selftest `_st_total` 36→38 (:1678), шапка selftest N/38 и 38/38,
  новые кейсы: c6b (позитив — `@coder @c0de @facade` ≤6 hex остаются
  зелёными) и c12d (негатив — ` — ` в формулировке row, ловится именно
  слово «разделител» в выводе).
- `.zcode/commands/planfaktor-status.md` (D6): :49 — «(шаг 5 ранее)» →
  «(перенос из шага 5, решение 2026-11-12)».
- `.zcode/commands/planfaktor-run.md` (D8): шаг 1 — grep очереди через
  `find docs/plans -maxdepth 1 -name '[0-9]*.md' -type f -exec grep -H
  '^\*\*Status:\*\*' {} +` (без `2>/dev/null`; пустая очередь — пустой
  вывод exit 0; ошибки чтения не маскируются) + пояснение скобками.
- `.github/workflows/corpus.yml` (D7): `on: [push, pull_request]` →
  `on: push: branches: [main]` + отдельный `pull_request:`; поведение
  в main не меняется.
- `AGENTS.md` (D5): однострочное примечание в конце абзаца
  Reroute-классификации §2 (:81) — канон дефисных токенов enum
  `C13_ROOT_RE`, пробельные написания — легальный синоним в прозе.
- `docs/plans/261111_1455_hardening_after_dogfood.md` (D9): :493 —
  Tests-цитата T4 `@a2c2faf8` → `@a2c2faf9`; единственный hunk файла;
  :1250/:1454 (фиксация инцидента) не тронуты.
- Не правились (по плану): `docs/requirements/registry.md` (git diff
  пуст), `.zcode/commands/planfaktor-init.md` (git diff пуст),
  строки 1250/1454 плана 1455, `docs/roles/*`.
- План (этот файл): intake Coder, AC-to-test, Assumption D3-адреса,
  самофикс intake-цитаты, Tests-факты, Evidence, Follow-ups — зоны Coder.

## Evidence (chronological, append-only)
<!-- owner: все роли + CENSOR; событийные записи с датой и локальным временем -->
- 2026-11-17 14:19:21 — Curator: независимая сверка всех восьми находок
  ревью (по поручению Owner; текст ревью — вне репо, находки материализуются
  строками backlog с source_ref → этот план). Подтверждено лично: (1) S2 —
  coder.md:12 «(ожидается `In progress`); расхождение — стоп» против
  AGENTS.md:66 fixes-легализации и диспатча run.md с `PRE_STATUS_LINE:
  In review`; (2) C6 — repro: упоминание ника coder даёт одно-hex матч (c),
  ники c0de/facade — 4/6 hex, порог {4,} бессилен; заодно C6 поймал сам
  этот драфт (7-hex литерал примера в Solution/Tests) — живая демонстрация
  класса до правки текста; (3) C12 — sed-глобальность
  `s/ — /|/g` при NF=8; (4) PASS=censor ×5 против PASS: §4:172; reroute
  run.md:258/architect.md:32,38 ↔ AGENTS.md:67/architect.md:23; status.md:48
  «(шаг 5 ранее)»; (5) `on: [push, pull_request]`; (6) init.md:27 2>/dev/null;
  (7) 1455:493/1250/1454 — контекст опечатки; (8) шапка скрипта без awk.
  Драфт — кураторская сессия по прецеденту 261116_1321/261117_0221; зоны
  Architect/Planner переприсваиваются на intake.
- 2026-11-17 15:02:57 — Manager: план активирован вызовом Owner `/planfaktor-run docs/plans/261117_1419_corpus_hygiene_sweep.md` (валидации 1a пройдены: файл/Plan ID/статус Draft/инвариант одного активного; спец-указаний в сопроводительном сообщении нет). Ветвление Draft: кураторский черновик §1(g) — зоны предзаполнены, intake роли нет → диспатч Architect (PHASE=work) на перепринятие, не rubber-stamp. Backlog-пачка при активации (Solution п.12, зона Manager): промоушен трёх существующих (lint-robustness, init-grep-stderr, hex-typo-t4 → promoted/plan=261117_1419) и материализация семи новых (S2-контракт, C6-порог, C12-разделитель, pass-нотация, reroute-якорь, status-ссылка, ci-pr-дедуп — open, source_ref → этот план) с пересборкой index — исполнена этим же шагом
- 2026-11-17 15:25:30 — Architect: фаза PHASE=work завершена — зоны
  переприняты верификацией против репозитория (кураторский repro —
  untrusted input; ключевые перепроверены живыми прогонами 15:07–15:23).
  Подтверждены: S2 (coder.md:12–13 ↔ AGENTS.md:66 ↔ run.md шаг 4);
  C6 (прогон детектора: `@coder`→`@c` 1 hex, c0de/facade 4/6 hex,
  selftest-байт 11 hex); C12-механизм (sed-глобальность :776) — но
  грамматика registry.md:18–19 уже запрещает ` — ` (живой остаток —
  диагностика + selftest-кейс); PASS=censor ровно ×5 (planner:22,
  coder:23, architect:25, reviewer-contracts:40, reviewer-risk:34);
  reroute-двойная нотация (run.md:258 дефисная ↔ AGENTS.md:67,
  architect.md:23 пробельные; enum C13_ROOT_RE дефисный);
  status.md «(шаг 5 ранее)» — строка 49 (не 48); CI `on: [push,
  pull_request]`; T4 — живая Tests-цитата 493 (секция с :421), 1250/1454
  исторические; awk в :777/:979 вне шапки утилит (:21–24). Опровергнуты
  верификацией: п.6 черновика инвертирован (init.md не содержит `2>`
  вообще — grep пуст; подавление живёт в run.md:11; смысл строки
  backlog init-grep-stderr — обратный); п.8 heredoc-раскрытие не
  воспроизводится (контрольный прогон sh: бэктики/`$(...)` в значении
  переменной через неквотированный heredoc не раскрываются — POSIX
  не ресканирует expansion; квотирование `<<'EOF'` сломало бы
  подстановку переменных — отклонено). Cwd-чувствительность C9
  подтверждена прогоном с механизмом: pathname expansion полей
  unquoted-подстановки в for-списке по текущему cwd (из корня
  `docs/roles/*` глобится в файлы — проверка делает не то, что задумано;
  из /tmp литерал → живой FAIL `corpus: 1 failures` dangling
  `.zcode/commands/*`, `docs/roles/*`; `[ -e …/* ]` литералом rc=1).
  Развилки закрыты (A/B-фиксация §5): C6 — порог `{7,}` + rejected
  `\.md@`-якорь и `{4,}`; reroute-якорь — AGENTS §2 (decisions.md
  отсутствует в корпусе — существовал 2026-11-11, удалён); selftest
  36→38 составом C6-позитив + C12-негатив. Возражение на черновые
  DoD/Tests (D2/D3/D8/D9/D10/D11) — Objections log, не блокирует.
  Открытых вопросов к Owner нет. Handoff: **Status:** Ready for Planner.
- 2026-11-17 15:27:40 — Architect: оговорка красного окна C6 (append
  к 15:25:30): репо-литералы `@`-упоминаний в Evidence этого плана
  (`@coder`→`@c` в записи верификации) правомерно роняют текущий C6
  (живой прогон 15:26: `corpus: 1 failures` — digest c/c0de/facade/
  11-hex) до применения Solution п.2; append-only Evidence не
  переписывается — прецедент кураторского драфта (класс демонстрируется
  собственным носителем). Следствие для Coder'а: правка C6-порога
  обязана предшествовать selftest/smoke-прогонам DoD (baseline этих
  режимов требует clean-копию корпуса, содержащую этот план); после
  фикса {7,} упоминаемые хвосты ≤6 hex перестают матчиться — корпус
  зелёный. Устранимые @-хвосты из Problem/Solution/Objectives
  переведены в описательные формулировки 15:26–15:27.
- 2026-11-17 15:37:20 — (Role CENSOR) OK: Ready for Planner validated; current=true
Censor dispatch id: censor:architect:261117_153231
Observations:
- Second opinion: шапка перечитана — `**Status:** Ready for Planner`
  (строка 4), Plan ID 261117_1419 ↔ имя файла согласованы; intake обеих
  итераций в каноне C5 (`- Intake (…)` 15:23:10 и 15:35:20), digest'ы
  идентичны между итерациями (AGENTS.md@c971fb26, architect.md@f6cd38e4 —
  shasum 15:07 и 15:35 совпали, миграции контрактов нет, §3 п.7 соблюдён);
  Evidence 15:25:30 несёт handoff-строку `**Status:** Ready for Planner`,
  согласованную со шапкой; Objections-строка `### Architect objections`
  с blocker: no — по шаблону; перекрёстные ссылки Objections → Solution
  п.2/3/8/9/10/11 сверены с фактической нумерацией (1–12 не менялась);
  открытых Q к Owner нет (авто-переход `Ready for Coder` → `In progress`
  моей фазой не блокируется).
- Counterfactuals considered: (1) путаница носителя grep-правки —
  перепроверено grep'ом `2>` по обоим командам: init.md пуст, run.md:11
  несёт `2>/dev/null` — фиксация инверсии верна; (2) ссылка 1455:493
  вне Tests — перепроверено awk-границей секции (заголовок
  `## Tests / Commands` на :421) — локализация верна; (3) статус шапки
  расходится с Evidence — сверено дословно, оба Ready for Planner;
  (4) мои репро-литералы роняют чужие чеки — прогон 15:28: единственный
  FAIL C6 (`@c` из append-only Evidence), 15 остальных чеков OK — красное
  окно локализовано и оговорено записью 15:27:40; (5) чужие секции
  затронуты правками фазы — зона DoD/Tests сверкнута построчно (57 строк
  структуры D1–D14 без моих правок), Follow-ups/Changes не тронуты;
  (6) usage-строка Manager'а 15:32:31 (зона §1(f)) не затёрта моими
  правками — конфликт обновления разрешён перечтением, зона нетронута.
- Addendum (new angle): сверка нормы «3–7 строк» блока понимания с
  прецедентами корпуса (261116_1321 — 8, 261115_2254 — 16, 261114_0151 —
  19 физических строк): норма читается логически; блок после сжатия —
  4 предложения; C15 membership обеих intake-цитат зелёный по прогону
  (digest'ы — реальные состояния файлов).
- Fixes: (1) блок «Как я понял задачу» сжат 15→4 логических предложений
  (было многословно сверх нормы роли-дока); (2) Solution п.10 —
  «`set -f` либо эквивалент» переформулировано без «либо»-формы
  (инвариант — без globbing; механика — за Coder'ом), снят риск чтения
  как открытая A/B-развилка; дизъюнкций-развилок в Solution не осталось
  (grep «либо» — только легальное перечисление статусов в п.1).
- Final censor verdict: OK
- 2026-11-17 15:50:10 — Planner: finalize completion-pass по DoD/Tests
  (второй проход «глазами Coder и Reviewer», до простановки статуса).
  Самопроверка-1 («что придётся угадывать»): после трёх уточнений —
  ничего содержательного; механика D8 задана паттерном явно, D10 несёт
  инвариант (механика подавления — свобода Coder'а по Solution п.10,
  исход проверяем из /tmp и корня), лейбл нового C12-кейса фиксируется
  по факту прогона (носитель — вывод --selftest). Самопроверка-2
  («implicit-доказательства»): устранены в проходе — детектор D2
  сверкается полным паттерном grep-команды (не голым `{7,}`), новый
  C12-кейс — caught-строкой вывода selftest, нетронутость init.md и
  registry.md — git diff. Верификация носителей при переприятии
  выполнена живыми прогонами (untrusted input §5): coder.md:12–13,
  PASS=censor ×5 (строки 25/22/23/40/34), run.md:11 — единственный
  `2>/dev/null`, init.md — 0, status.md:49 «(шаг 5 ранее)», corpus.yml:6
  `on: [push, pull_request]`, check_corpus.sh: детектор :464 без порога
  / sed :776 / awk :777,:979 вне шапки :21–24 / `_st_total=36` :1638 /
  main без позиционного аргумента (usage exit 2) / C9 unquoted-цикл
  :624 / glob-токены корпуса — ровно `docs/roles/*` и
  `.zcode/commands/*`, 1455:493 `@a2c2faf8` (Tests с :421; 1250/1454
  исторические), registry.md:18–19 запрет уже в грамматике, backlog —
  10 строк `plan=261117_1419`. C6-контроль собственной записи: все
  @-хвосты этого плана после правки — ≤6 или ровно 8 hex (прогон
  детектора по файлу; 7/9/10/11-hex хвостов нет, bait-литералы в Tests
  экранированы формой `printf '@%s'`). Дефектов по итогам прохода не
  осталось.
- 2026-11-17 15:50:25 — Planner: фаза PHASE=work завершена — DoD/Tests
  переприняты по Solution п.1–12 с живой верификацией носителей
  (Architect objection 15:24:40 исполнен полностью: D8 инвертирован на
  run.md:11 + guard-паттерн задан Planner'ом; D3 сужен до диагностики
  с запретом правки registry.md; heredoc-пункт выпал — класс опровергнут
  верификацией; D6 уточнён на строку 49; D11-команда cwd заменена на
  запуск без аргумента — main позиционный аргумент не принимает;
  нумерация переписана D1–D13). Из Q&A/Objections перенесено: состав
  corrections-объекта objection → соответствующие DoD/Tests; порядок
  Coder'а «фикс C6 до selftest/smoke-баз» (Evidence 15:27:40) → шапка
  Tests. Открытых вопросов нет. Handoff: **Status:** Ready for Coder.
- 2026-11-17 15:55:42 — (Role CENSOR) OK: Ready for Coder validated; current=true
Censor dispatch id: censor:planner:261117_155216
Observations:
- Second opinion: шапка перечитана — `**Status:** Ready for Coder`
  (строка 4), совпадает с PRE_STATUS_LINE конверта; Plan ID ↔ имя файла
  согласованы; обе intake-строки Planner'а (work 15:48:07, censor
  15:53:27) в каноне C5, digest'ы идентичны между итерациями
  (AGENTS.md@c971fb26, planner.md@f013858b — shasum 15:43 и 15:53
  совпали, миграции контрактов нет, §3 п.7); запись finalize
  completion-pass на месте (:464, 15:50:10) и хронологически раньше
  handoff-строки (15:50:25) — условие перехода §2 соблюдено; DoD
  перечитан построчно: 13 пунктов D1–D13, каждый — утверждение с
  проверяемым исходом (grep/sed/прогон/diff/осмотр), «по
  необходимости»/«и т.д.» нет; покрытие: метки (D1)–(D13) в Tests —
  ровно 13 уникальных, каждая строка несёт команду и ожидаемый
  результат; Q&A-грамматика: Q-строк `^- Q(` — 0, открытых вопросов
  к Owner нет; usage-строка Manager'а (:504, зона §1(f)) не затёрта —
  конфликт обновления разрешён перечтением, зона нетронута.
- Counterfactuals considered: (1) мои bait-литералы роняют чужие чеки —
  прогон детектора по файлу плана: хвостов 7–11 hex нет (только ≤6 и
  ровно 8), полный линт 15:54: единственный FAIL C6 `@c` — ровно
  оговорённое красное окно Evidence 15:27:40, новых отказов от моих
  правок нет; (2) граничные команды (D2) невоспроизводимы — прогнаны
  как написаны: printf-пайпы дают 0 (ники ≤6 hex) / 1 (abcdef0,
  7 hex) / 1 (a2c2faf9, 8 hex); (3) guard-паттерн D8 не решает edge —
  живой прогон for-цикла по glob в zsh пустого каталога упал «no
  matches found» ДО guard'а (nomatch) — дефект найден и исправлен
  (Fixes п.1); (4) DoD меняет решения Architect — Solution п.8
  перечитан: инвариант «guard существования до grep без подавления
  stderr» сохранён, механика была делегирована Planner'у дословно
  («механику паттерна задаёт Planner») — решения не тронуты;
  (5) чужие секции — правки фазы ограничены шапкой статуса (переход
  §2), DoD, Tests, intake Q&A, Evidence; Problem/Solution/Scope/
  Out of scope/Follow-ups/Changes/Token usage нетронуты.
- Addendum (new angle): follow-ups-хвост перечитан — единственная строка
  ссылает на Manager-зону Solution п.12 с closeout-механикой (незакрытых
  Planner-хвостов нет — D13 несёт closeout-условия как DoD, не хвост);
  «явная форма отсутствия» по моим секциям — TBD/пусто/UNCONFIRMED нет,
  единственная делегированная свобода (механика подавления pathname
  expansion в D10) — решение Architect п.10, не моя развилка;
  воспроизводимость edge-команды (D8) после исправления — прогнана
  как написана (`/tmp/d8e`: rc=0, пустой вывод, stderr чист).
- Fixes: (1) механика D8 переписана с for-цикла по glob на find-форму
  (`find docs/plans -maxdepth 1 -name '[0-9]*.md' -type f -exec
  grep -H '^\*\*Status:\*\*' {} +`) — for-guard падает в zsh «no
  matches found» до проверки существования; find-форма проверена
  живыми прогонами в обоих режимах (пустая очередь — тишина/rc=0,
  репо — полный доклад очереди); DoD D8 и Tests (D8) синхронизированы.
- Final censor verdict: OK
- 2026-11-17 15:56:51 — Manager: Q&A чист, открытых вопросов к Owner нет, статус In progress
- 2026-11-17 16:07:40 — Coder: AC-to-test по DoD до начала правок (§5,
  закрытый набор; ref — Tests-строки плана): D1 explicit assertion
  (Tests D1: sed-абзац + оба статуса/слова диспатчей); D2 explicit
  assertion (Tests D2: grep полного паттерна детектора, printf-границы
  порога, sed комментария, grep sed-вырезания); D3 explicit assertion
  (Tests D3: grep 'разделител' в check_c12 + git diff registry.md
  пуст + sed 18,19 контроль носителя); D4 explicit assertion (Tests D4:
  grep -rc PASS=censor пуст / grep -rl 'PASS: censor' wc -l 5); D5
  explicit assertion (Tests D5: grep 'same-contract-reroute' AGENTS.md —
  1 строка с «канон» и обеими формами); D6 explicit assertion (Tests D6:
  sed 49p + grep 'шаг 5 ранее' = 0); D7 explicit assertion (Tests D7:
  sed 5,8p corpus.yml + actionlint exit 0); D8 explicit assertion
  (Tests D8: grep -c 2>/dev/null run.md = 0, sed 9,16p find-механика,
  edge /tmp/d8e пустая очередь, git diff init.md пуст); D9 explicit
  assertion (Tests D9: sed 493p, grep a2c2faf8 только :1250/:1454,
  git diff единственный hunk); D10 explicit assertion (Tests D10: запуск
  без аргумента из /tmp и из корня → corpus: clean + grep -Fn литеральных
  glob-форм в allowlist C9); D11 explicit assertion (Tests D11: sed
  21,24p шапки — awk заявлен); D12 explicit assertion (Tests D12: три
  прогона clean/38-38/smoke + grep _st_total=38 + grep -c N/36=0 +
  grep сидов обоих кейсов); D13 N/A (why=closeout-условия за Owner-гейтом
  merge: CI-прогон на merge-коммите и терминальные disposition 10 строк
  backlog-пачки — зона closeout-хвоста §8/§2, Solution п.12; Tests D13
  сами маркированы «после Owner-гейта, фиксация при closeout» — в
  Coder-фазе до merge не проверяемы). Порядок работ конверта принят:
  C6-порог первым шагом (Evidence 15:27:40) до selftest/smoke-базлайнов.
- 2026-11-17 16:14:02 — Coder: самофикс intake-цитаты до handoff
  (fail loud): в intake-строке 16:07:24 ошибочно стоял digest
  агент-файла `.zcode/agents/planfaktor-coder.md`@6b4ad4b4 — канон §3
  цитирует роль-док `docs/roles/coder.md`; исправлено на реальное
  прочитанное состояние docs/roles/coder.md@4620164d (файл не правился,
  HEAD-состояние, входит в историческое множество C15 — проверено
  прогоном линта после исправления). Оба файла реально прочитаны на
  intake; ошибка — только в цитируемом digest. Дефект пойман C15
  (`intake digest docs/roles/coder.md@6b4ad4b4 not in historical set`)
  — механика digest-verify отработала штатно.
- 2026-11-17 16:29:12 — Coder: серия прогонов после D-правок (D2
  первым, до базлайнов — конверт/Evidence 15:27:40): полный линт
  `corpus: clean` (exit 0; до самофикса intake-цитаты — единственный
  FAIL C15 по дефекту собственной intake-строки, см. 16:14:02);
  `--selftest` → `selftest: 38/38 caught`, exit 0, новые кейсы:
  `caught C6b (hex-nick mentions <=6 hex stay green)`,
  `caught C12d (separator in wording)`; `--smoke` → `smoke: clean`,
  exit 0; D10 cwd-контроль: из /tmp без аргумента и из корня —
  `corpus: clean`, exit 0 оба (до фикса из /tmp падал dangling-литералами
  — механика воспроизведена Architect 15:25:30).
- 2026-11-17 16:33:40 — Coder: Tests (D1)–(D12) прогнаны дословно
  (факты — секция Tests «Coder run facts»): все зелёные; D7 actionlint
  exit 0; D9 единственный hunk :493; D8 edge пустая очередь exit 0.
  Расхождения-факты против плановых строк-ориентиров: шапка утилит
  awk — :25 (не :21–24; смещение +4 новой летописью источника), стрелки
  комментария C6 — :462–468 (не :455–458; +7), allowlist C9 — :655–656
  (не :625–632; смещение правками C9-комментария), allowlist-грепы
  дополнительно матчат комментарий :626 и реальные glob-источники
  :636–637 (это не allowlist-строки; case-строки — :655–656); адрес
  грамматики запрета — registry.md:20–21, не :18–19 (Assumption
  16:22:10). Функциональные исходы всех проверок — по ожиданиям.
- 2026-11-17 16:52:50 — Coder: финальная серия после правки
  диагностического сообщения C12 (адрес :18-19 → :20-21): полный
  линт `corpus: clean` exit 0; `--selftest` `selftest: 38/38 caught`
  exit 0 (C6b/C12d на месте); `--smoke` `smoke: clean` exit 0;
  /tmp-cwd `corpus: clean` exit 0. Прогоны свежие к финальному
  состоянию скрипта (digest c2ee77aa).
- 2026-11-17 16:58:10 — Coder: миграция контрактов §3 п.7 — смена
  digest'ов по тронутым контрактам (старое состояние рабочего дерева
  до правок → новое, shasum -a 256):
  AGENTS.md@c971fb26 → @e7ac58fe (D5 reroute-якорь);
  .zcode/agents/planfaktor-coder.md@6b4ad4b4 → @1e0556fd (D1+D4);
  .zcode/agents/planfaktor-architect.md@3f6db307 → @1ee610f2 (D4);
  .zcode/agents/planfaktor-planner.md@049782a6 → @a254471f (D4);
  .zcode/agents/planfaktor-reviewer-risk.md@cffc8129 → @8f7698b4 (D4);
  .zcode/agents/planfaktor-reviewer-contracts.md@13b1f313 →
  @ef7a0354 (D4);
  .zcode/commands/planfaktor-run.md@9bebb021 → @c2b57614 (D8);
  .zcode/commands/planfaktor-status.md@337eba19 → @8c220a19 (D6);
  scripts/check_corpus.sh@11e87bf0 → @c2ee77aa (D2/D3/D10/D11/D12).
  Не менялись: docs/roles/*@4620164d (coder) — роль-доки не в Scope;
  intake следующих итераций ролей цитируют новые состояния (C15
  membership: старые состояния остаются в git-истории после
  merge-коммита Manager'а; в рабочем дереве до коммита C15 зелёный
  по неизменённым файлам и историческим состояниям HEAD — финальный
  прогон 16:52 подтверждает).
- 2026-11-17 17:02:00 — Coder: фаза PHASE=work завершена — D1–D12
  реализованы и проверены (Tests «Coder run facts»), D13 — closeout
  за Owner-гейтом merge (AC-to-test N/A 16:07:40); изменения
  застейджены (`git add`), коммит не делался (§8). Handoff:
  **Status:** In review.
- 2026-11-17 17:10:46 — (Role CENSOR) OK: In review validated; current=true
Censor dispatch id: censor:coder:261117_170527
Observations:
- Second opinion: шапка перечитана — `**Status:** In review` (:4),
  совпадает с PRE_STATUS_LINE конверта; Plan ID 261117_1419 ↔ имя
  файла согласованы; intake-строки обеих итераций в каноне C5
  (16:07:24 AGENTS.md@c971fb26 coder.md@4620164d; 17:07:30
  AGENTS.md@e7ac58fe coder.md@4620164d — смена AGENTS-цитаты легальна:
  файл правился этой же фазой, миграция зафиксирована Evidence
  16:58:10, §3 п.7 соблюдён); AC-to-test D1–D13 (Evidence 16:07:40)
  хронологически до Changes (заполнение с 16:56+), Assumption D3-адреса
  — в Q&A (16:22:10); DoD-покрытие сверено пофайлово: D1 — sed 9,15p
  coder-agent (оба статуса, оба слова «диспатч», стоп сохранён);
  D2 — grep полного паттерна =1 (:477), printf-границы (ники ≤6 → 0,
  7-hex ловится, 8-hex пускается); D3 — «разделител» в printf check_c12
  (:815), registry.md не правлен (git diff пуст); D4 — 0/5; D5 —
  1 строка (:81, «канон» + обе формы); D6 — :49 / grep 0; D7 — sed
  5,8p + actionlint exit 0; D8 — grep 0, find-механика в блоке, edge
  /tmp/d8e exit 0, init.md не тронут (diff пуст); D9 — staged hunk
  ровно `@@ -493 +493 @@`, a2c2faf8 жив только на :1250/:1454; D10 —
  case-строки :655–656, /tmp-прогон clean; D11 — awk в шапке (:25);
  D12 — 38/38 c C6b/C12d, _st_total=38 (:1678), N/36=0; D13 — N/A
  closeout по AC-to-test. `## Tests / Commands` — факты прогонов
  с командами и исходами (подсекция «Coder run facts»); `## Changes
  (by area)` — по каждой Dn-области; `## Follow-ups` заполнен
  (строка Coder NO FOLLOW-UPS с why + строка Manager-зоны).
- Counterfactuals considered: (1) C15 падает на intake-цитате нового
  состояния AGENTS.md@e7ac58fe до merge-коммита — сверено по коду
  check_c15 (:1348–1353): множество = дайджесты коммитов ∪ текущий
  shasum рабочего дерева; полный прогон 17:09 — `corpus: clean`,
  цитата легальна; (2) bait-литерал 7-hex в моих Tests-фактах роняет
  C6 — сканер по файлу плана: не-8-hex @-хвостов 0 (найденный bait
  с 7-hex хвостом abcdef0 переформулирован до стейджинга, повторный
  скан чист);
  (3) set -f не восстанавливается (пустой цикл/continue) — код:
  set -f непосредственно до for, set +f сразу после, внутри только
  continue тела for; sh -n exit 0; все прогоны зелёные; (4)
  selftest-кейс c6b проверяет не то (сижу и жду FAIL) — это
  позитивный кейс: check_c6 обязан пройти; при регрессии порога
  выдал бы MISSED C6b — вывод несёт caught; (5) стейджинг разошёлся
  с правками — git status сверен: 11 M + план, backlog/index
  (Manager-промоушен 15:02:57) не стейджены мной; (6) «XXX»-греп —
  ложные попадания mktemp-шаблонов :1655/:2453 (легальная механика),
  TODO/FIXME/DEBUG — 0.
- Addendum (new angle): usage-строки Manager'а 17:05:27 (три, включая
  unknown-форму с why=резюм-хендл) перечитаны — грамматика C11
  покрывает (линт clean), зона §1(f) не тронута моими правками;
  DoD-чекбоксы `[ ]` сознательно не отмечались — DoD зона Planner,
  исполнение подтверждается Changes/Tests/Evidence, не галками;
  C16 по плану зелёный (открытых Q нет, Assumption-строка не Q-форма);
  порядок D2-первым до базлайнов (Evidence 15:27:40) исполнен:
  selftest/smoke впервые прогнаны 16:29 уже с порогом {7,}.
- Fixes: none (NO FINDINGS; сверены: шапка/Plan ID, 13 D-пунктов
  пофайлово, стейджинг против git status, неизменность registry.md/
  init.md/строк 1250/1454 плана 1455, @-хвосты плана сканером,
  синтаксис sh -n, TODO/FIXME/DEBUG-греп, полный линт `corpus: clean`
  exit 0 с новой intake-строкой)
- Final censor verdict: OK
- 2026-11-17 17:12:40 — Coder (пост-фактум receipt'а, до валидации
  гейтом): инлайн-фикс собственного receipt'а 17:10:46 — в
  counterfactual (2) литеральная форма bait-хвоста с собакой сама
  роняла C6 (живой контроль: полный прогон после стейджинга receipt'а
  дал `FAIL C6 digest-format` с 7-hex хвостом abcdef0; класс ровно
  тот, о котором писал counterfactual — bait продемонстрировал себя).
  Литерал в тексте receipt'а переформулирован без `@`-префикса;
  вердикт и Observations не менялись. Контрольный прогон после
  фикса — `corpus: clean`.
- 2026-11-17 19:53:33 — Manager: Owner-гейт merge — Owner ответил «мержим» (чат; сопроводительно: пре-мердж фикс зоны Manager — счётчик index «закрытых — 12» → 11, список/носитель = 11, drift унаследован от closeout 0221 (9 при факте 8), пачка 1419 посчитана от неверной базы; третий экземпляр класса — кандидат index-counter-consistency на closeout-harvest). Контроли (а) пройдены: unstaged — план (рестейдж (в)), backlog/index (зона Manager: промоушен-пачка 15:02:57 + данный фикс — санкционированы указанием Owner, входят в merge-коммит); staged 12 = дословный список Итога; свежий pre-merge verify → `corpus: clean`, EXIT=0; ручной leak-контроль → 0. Review Round 1: Risk pass (R1 major S2 + R2/R3 minor, все accepted_non_blocking_followup) / Contracts pass / Итог pass / Artifact state current_green. Бюджетная заметка (гейт, тир 27/40): 22,031,950 (22.0M) → [ок] (awk, чекпоинты/unknown исключены). Статус Merged


## Token usage (append-only)
<!-- owner: manager; dispatch-форма и чекпоинт-форма — грамматика шаблона -->

- 2026-11-17 15:32:31 — usage: architect.work 3639630 tokens — dispatch
- 2026-11-17 15:40:51 — usage: architect.censor 2202335 tokens — sendmessage
- 2026-11-17 15:52:16 — usage: planner.work 2680423 tokens — dispatch
- 2026-11-17 15:56:51 — usage: planner.censor 1500182 tokens — sendmessage
- 2026-11-17 17:05:27 — usage: coder.work 4142432 tokens — dispatch
- 2026-11-17 17:05:27 — usage: coder.work unknown (why=резюм-хендл остановлен killed на пермишн-ступоре Bash, usage в notification отсутствует; работа продолжена следующим резюмом) tokens — sendmessage
- 2026-11-17 17:05:27 — usage: coder.work 2019885 tokens — sendmessage
- 2026-11-17 17:16:38 — usage: coder.censor 3647779 tokens — sendmessage
- 2026-11-17 17:31:04 — usage: reviewer-risk.work 2199284 tokens — dispatch
- 2026-11-17 17:59:13 — usage: reviewer-contracts.work 2909544 tokens — dispatch
- 2026-11-17 17:59:13 — usage: manager-context checkpoint ~14948000 tokens-left — approximate

## Q&A log (chronological, append-only)
<!-- owner: все роли; intake и Q/A-грамматика — по шаблону; кураторских Q нет: находки ревью подтверждены сверкой, дизайн-развилки — зона Architect -->
- Intake (2026-11-17 15:23:10): AGENTS.md@c971fb26 architect.md@f6cd38e4
- NO QUESTIONS
- NO SUGGESTIONS
- Objections (1): черновые строки DoD/Tests (зона Planner, кураторский §1(g))
  расходятся с верифицированными решениями — D2 (repro-ники),
  D3 (грамматика registry.md уже запрещает ` — `), D8 (носитель
  инвертирован: run.md, не init.md), D9 (Tests-цитата = строка 493),
  D10 (heredoc-класс опровергнут прогоном), D11 (Tests-команда с
  аргументом корпуса сломана — main не принимает позиционный аргумент)
  и парные Tests-строки; blocker: no — Planner перепринимает по
  Solution; полная строка — Objections log.
- Intake (2026-11-17 15:35:20): AGENTS.md@c971fb26 architect.md@f6cd38e4
  — PASS=censor (dispatch id censor:architect:261117_153231)
- NO QUESTIONS
- NO SUGGESTIONS
- NO OBJECTIONS
- Intake (2026-11-17 15:48:07): AGENTS.md@c971fb26 planner.md@f013858b
- NO QUESTIONS
- NO SUGGESTIONS
- NO OBJECTIONS
- Intake (2026-11-17 15:53:27): AGENTS.md@c971fb26 planner.md@f013858b
  — PASS: censor (dispatch id censor:planner:261117_155216)
- NO QUESTIONS
- NO SUGGESTIONS
- NO OBJECTIONS
- Intake (2026-11-17 16:07:24): AGENTS.md@c971fb26 coder.md@4620164d
- NO QUESTIONS
- NO SUGGESTIONS
- NO OBJECTIONS
- Assumption (Coder, 2026-11-17 16:22:10): ссылка D3 «подсказка на
  грамматику registry.md:18–19» неточна к носителю — запрет ` — `
  в формулировке фактически живёт в registry.md:20–21 («Формулировка
  не содержит ` — ` … иначе счёт полей ломается»), :18–19 — пункт
  ID-грамматики (сверка sed по файлу). Подсказка в диагностике C12(б)
  ведёт на верифицированный адрес :20–21; решение D3 (диагностика, не
  грамматика; registry.md не правится) не затронуто — уточнение адреса,
  не смысла.
- Intake (2026-11-17 17:07:30): AGENTS.md@e7ac58fe coder.md@4620164d
  — PASS: censor (dispatch id censor:coder:261117_170527)
- NO QUESTIONS
- NO SUGGESTIONS
- NO OBJECTIONS
- Intake (2026-11-17 17:17:42): AGENTS.md@e7ac58fe reviewer-risk.md@a51f0eb4
- NO QUESTIONS
- NO SUGGESTIONS
- NO OBJECTIONS
- Intake (2026-11-17 17:34:11): AGENTS.md@e7ac58fe reviewer-contracts.md@dd9bcb7a
- NO QUESTIONS
- NO SUGGESTIONS
- NO OBJECTIONS

## Suggestions log (chronological, append-only)
<!-- owner: все роли; несрочные улучшения -->

## Objections log (chronological, append-only)
<!-- owner: все роли; `### <Role> objections`; строка на возражение, blocker: при блокере -->
### Architect objections
- 2026-11-17 15:24:40 — Architect: черновые DoD/Tests-строки зоны Planner
  (кураторский §1(g)) расходятся с верифицированными решениями — D2
  (repro-ники: проверить упоминания coder/c0de/facade с собакой),
  D3 («правило закреплено в грамматике registry.md» уже истинно без
  правок — живой остаток только диагностика), D8 (носитель инвертирован:
  run.md:11, не init.md), D9 (Tests-цитата локализована: строка 493),
  D10 (heredoc-кейс опровергнут — выпадает), D11 (Tests-команда
  `sh <repo>/scripts/check_corpus.sh <repo>` сломана: main не принимает
  позиционный аргумент корпуса — usage exit 2; проверка cwd — запуск
  без аргумента) и парные Tests-строки (D2)(D3)(D8)(D9)(D10)(D11);
  blocker: no — Planner перепринимает по Solution п.2/3/8/9/10/11
  на своём intake (§1(g): зоны перепринимаются, не rubber-stamp).

## Follow-ups (deferred)
<!-- owner: coder/planner при CENSOR; незакрытые хвосты -->
- Промоушен трёх строк и материализация семи новых при активации — зона
  Manager (Solution п.12); терминальные закрытия при closeout.
- Coder: NO FOLLOW-UPS — why: D1–D12 закрыты в фазе с проверками
  (Tests «Coder run facts»); D13 — closeout-условия по конституции §8
  (Manager, за Owner-гейтом merge), не хвост Coder'а; Assumption
  16:22:10 (адрес registry.md:20-21 vs DoD :18-19) — вердикт зоны
  review, не отложенная работа.
