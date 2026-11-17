# Docs wave 1: архив исполнения и пользовательская поверхность

**Plan ID:** 261117_2002
**Status:** Done
**Created:** 2026-11-17
**Owner gates:** merge (`In review` → `Merged`); вопросы `to=Owner` — по мере возникновения

> Шапка — parser-контракт: строки выше grep'аются Manager'ом. Не менять формат.
> Имя файла: `YYMMDD_HHMM_topic.md` (тема латиницей, слова через `_`).

## Как я понял задачу
<!-- owner: architect; 3–7 строк; обязательна при Architect intake -->
Ревью документации (Owner-бриф, 2026-11-17) дало S1×2 + S2×12 + S3×14;
F1 закрыта merge 1419, контрактный слой (F5–F9, S3.1–8) — вторая волна.
Волна 1 — механические правки без контрактов §1: целостность архива
(F3 lost follow-up, F4 висячие merge-хеши) и поверхность (гайды F2/F10,
lifecycle F11, F12, S3.9–14). Кураторские зоны переприняты верификацией
(intake 20:24:10, живые прогоны): 9/9 находок подтверждены; F4 уточнён
до 5 планов (b53f8c5 — фантом, 1642/1943/1944 уже несут актуальные
хеши); коллизия C17 разрешена (C17=release-notes-lint по релиз-нотам,
C18=index-counter-consistency); пачка материализации — 3 новые строки
+ 2 правки (Solution п.7).

## Problem
<!-- owner: architect; пронумерованные пункты -->
1. **F3 — потерянный follow-up при harvest 1321**: открытая suggestion
   Architect'а (261116_1321:427, 14:03:35: «формат-часть qa-lint
   не покрыта… чтобы хвост не закрылся как handled целиком») не учтена
   closeout-узлом (:372 «источник (б): открытых нет»); qa-lint закрыт
   `handled` целиком. Формат Q/A-строк (`to=`/`blocker:`/`needs_owner:`)
   не покрыт ни C16, ни одной строкой backlog — lost follow-up §2.
2. **F4 — висячие merge-хеши в 5 планах** после пересборки публичной
   истории 2026-11-13: `782971a` (0320:502 + цитаты 0427:391, 1455:46),
   `3c93628` (0427:445), `64b6622` (2243:335), `afe047d`+`653cd2b`
   (обе в одной строке 0151:698) — объекты не существуют
   (`git cat-file -e` — отказ; проверено Architect'ом). Кураторские
   «b53f8c5» и локации «1642/1943/1944» grep'ом корпуса опровергнуты:
   b53f8c5 не встречается ни в одном файле (фантом), планы 1642/1943/1944
   уже несут актуальные хеши (a53592b/7b23670/6596b7f — существуют).
   Дополнительно найдено: `782971a` в docs/reviews/261111_0427_review.md:40
   («HEAD = 782971a») — исторический вердикт-факт review-артефакта, не
   чинится (Out of scope п.3). Замены (git log --grep по PlanID):
   782971a→`7a668f0` (0320), 3c93628→`51447d4` (0427), 64b6622→`5835c53`
   (2243), afe047d/653cd2b→`2bc0fd7` (0151) — все новые существуют.
3. **F2 — гайд установки невоспроизводим**: «закрытый набор файлов»
   `docs/getting_started.md` (:24–:35) не включает
   `scripts/check_corpus.sh`; слова «линт» в гайде нет — а merge-рутина
   (§8 pre-merge verify) требует свежего `corpus: clean`: первый
   merge-коммит в целевом репо закончится fail-loud стопом.
4. **F10 — 9 битых относительных ссылок**: `docs/getting_started.md`
   (:8, :48, :50, :132, :136–138) и `docs/model_run.md` (:12–13) —
   ссылки вида `](README.md)`, `](AGENTS.md)`, `](docs/lifecycle.md)`
   написаны от корня при размещении файлов в `docs/` → 404 на
   GitHub-рендере (CONTRIBUTING.md:71 сам требует валидности путей).
5. **F11 — lifecycle без бюджетной заметки**: описание merge/closeout
   гейтов не знает §8-заметки (сверка с тирами, budgets.md) — волна
   261117_0221 не доехала (пробел fan-out: README/run объявлены «БЕЗ
   правок», lifecycle не упомянут).
6. **F12 + S3.9–14 — устаревания и мелочи**: плейбук docs_canon_sweep:30
   «C1–C13» (дважды устарело — C14/C15/C16); backlog-строка
   release-notes-lint «кандидат C15/v2» — C15 занят digest-verify
   (нота зовёт его C17); plans/README:58 `Merged → Done` без
   harvest-конъюнкта §2; model_run:107 «получает судьбу (backlog-строку)»
   сужает механику §2 + нет pointer на budgets.md; lifecycle:4 «§§1–8»
   (конституция §§1–10); опечатка «гейтях» (run.md), «≤ суммы»
   (status.md:58); releases/README:29 «C14-чистота (gitleaks…)» — C14
   это встроенный safety-scan, gitleaks — отдельный кандидат
   (history-secret-audit).

## Solution / Decisions
<!-- owner: architect; решения уровня «что и почему», без детализации -->
1. **F3**: новая строка `qa-format-lint` (P3, формат Q/A-строк —
   `to=`/`blocker:`/`needs_owner:` — кандидат v3 рядом с парностью C16,
   source_ref → 261116_1321#suggestions-log) + закрывающая
   резолвинг-запись в Suggestions log 1321 (suggestion 14:03:35
   материализована строкой — lost follow-up резолвнут явно, история
   append-only не переписывается). Форма записи — append-only
   поясняющая строка с пометкой о материализации; прецедент пометок
   канона — 0217:459 («хэш — новой истории»), 2121:195 («вне конвейера,
   санитизация/пересборка 2026-11-13»); в 2236 прямого прецедента нет
   (перекоммит инцидента merge-untracked-guard — без поясняющей записи).
2. **F4**: append-only резолвинг-записи в Evidence затронутых планов —
   5 планов (0320, 0427, 1455, 2243, 0151; в 0427 обе замены одной
   записью), по одной записи в хвост Evidence каждого плана:
   `резолвинг merge-хеша после пересборки публичной истории 2026-11-13:
   <старый> → <новый> (<subject>)`; исторические строки не правятся.
   Замены фиксированы верификацией (git log --grep + `git cat-file -e`):
   782971a→7a668f0, 3c93628→51447d4, 64b6622→5835c53,
   afe047d/653cd2b→2bc0fd7; прецедент формы — 0217:459, 2121:195.
   b53f8c5 и планы 1642/1943/1944 из волны выпадают (Problem п.2);
   0427_review.md:40 — историческое наблюдаемое, не чинится.
3. **F2**: `scripts/check_corpus.sh` в набор копирования + шаг
   «первый линт» после копирования (прогон `sh scripts/check_corpus.sh`
   в целевом репо; указание, что merge-рутина §8 требует свежий
   `corpus: clean`).
4. **F10**: переписать 9 ссылок от фактического размещения `docs/`
   (`../README.md`, `../AGENTS.md`, `lifecycle.md`,
   `playbooks/manual_terminal_recovery.md` и т.п.); проверка —
   скрипт-обход всех относительных ссылок двух гайдов (все резолвятся).
5. **F11**: в lifecycle-описание merge/closeout — бюджетная заметка §8
   (сверка сумм с тирами budgets.md; warn — инфо, discuss —
   обоснование) + pointer на `docs/reference/budgets.md`.
6. **F12/S3-мелочи**: docs_canon_sweep — актуальный диапазон C1–C16;
   **резолвинг коллизии C17** (найдена верификацией: релиз-ноты
   v0.1.0:83 / v0.1.1:59 / v0.2.0:64 закрепляют «release-notes-lint —
   кандидат C17/v2», а backlog:38 index-counter-consistency претендует
   на тот же C17): release-notes-lint backlog:26 — «кандидат C15/v2» →
   «кандидат C17/v2» (C15 занят digest-verify с 1321; прецедент C17 —
   три релиз-ноты), index-counter-consistency backlog:38 — «кандидат
   C17/v2 рядом с release-notes-lint» → «кандидат C18/v2» (снимает
   коллизию, номер по порядку материализации); rejected alternative:
   закрепить C17 за index-counter-consistency — why: три релиз-ноты
   уже опубликованы с C17=release-notes-lint, сильнейший прецедент.
   plans/README `Merged → Done` — harvest-конъюнкт («Follow-ups
   заполнен; harvest-инвентарь §2 (источники а/б/в) с судьбами»);
   model_run — pointer budgets.md + формулировка «получает судьбу»
   по §2 (материализация строкой, терминальные закрытия); lifecycle:4 —
   «§§1–10»; «гейтях» → «гейтах»; «≤ суммы» → «≤ сумме»;
   releases/README — «C14 safety-scan (встроенный чек); gitleaks по
   истории — кандидат history-secret-audit» (строка backlog:20
   существует — pointer корректен).
7. **Backlog-механика — финальный состав пачки для материализации
   Manager'ом при активации** (оговорка Evidence 20:21:46 п.1):
   3 новые строки + 2 правки существующих + пересборка index.
   Новые (все status=open, plan=none, id свободны — проверено):
   (a) `qa-format-lint` (P3, кандидат v3 рядом с парностью C16,
   source_ref=docs/plans/261116_1321_lint_v2_digest_qa.md#suggestions-log);
   (b) `site-redeploy` (P3, редеплой сайта после обеих волн, F13-хвост,
   source_ref → Out of scope этого плана; to=Owner);
   (c) `guides-link-lint` (P3, машинная проверка относительных ссылок
   гайдов, кандидат C19/v3 — после C17/C18 из п.6; source_ref → этот
   план) — rejected alternative: фиксация в Suggestions log
   (кураторский вариант Out of scope п.4) — why: Suggestions log плана
   не переносимый носитель, канон-носитель класса «кандидат Cn» —
   backlog (прецеденты release-notes-lint, index-counter-consistency).
   Правки: release-notes-lint → «C17/v2», index-counter-consistency →
   «C18/v2» (п.6; правкой строк, не новыми). Терминальных закрытий
   пачка не несёт — все новые строки остаются open. Кураторские
   «11 строк» верификацией не восстановимы из корпуса (отчёт ревью вне
   репо; открытых строк backlog сейчас ровно 11 — вероятный источник
   ошибки счёта) — состав переопределён этим решением (A/B-фиксация:
   дизъюнкция снята, alternatives зафиксированы rejected-строками).
8. **F2-r1 (needs-fix r1, live-блокер #B1 — маршрут Evidence 22:09:03;
   дизайн-решение Architect'а по фактическим чекам, не по памяти)**:
   «закрытый набор файлов» гайда заменяется «канон-каркасом корпуса» —
   копируется полный каркас канона: корневые контракты (AGENTS.md,
   README.md, CONTRIBUTING.md, SECURITY.md), docs/ канона (справочники
   getting_started/lifecycle/model_run; каталоги plans(README+
   _template)/reviews(_template)/roles/playbooks/releases/requirements/
   reference/compliance; followups — пустые носители по _template),
   scripts/check_corpus.sh, .github/workflows/corpus.yml,
   .zcode/{commands,agents}/*; артефакты исполнения (планы и ревью
   вне шаблонов, чужой backlog-контент, docs/img) не копируются.
   Шаг «первый линт» из п.3 остаётся и на каркасе обязан давать
   `corpus: clean` в целевом репо. Фактическая база (живые прогоны):
   C9 пропускает отсутствующие носители (`[ -f ] || continue`), но
   каждый относительный путь существующих контрактов обязан
   существовать — AGENTS.md §9 перечисляет все каталоги docs/*;
   C12 требует docs/requirements/registry.md; smoke-режим доказывает
   зелёный C1–C16 на каркасе с инстанцированным шаблоном-планом.
   Точный минимальный состав каркаса и форму первого прогона (голый
   каркас vs каркас + первый план из шаблона) Planner доводит до
   DoD; проверяемый исход — `sh scripts/check_corpus.sh` в целевом
   репо сразу после копирования = corpus: clean. rejected
   alternatives: (б) «честная переформулировка — первый линт в
   полном клоне Planfaktor, набор только для структуры» — why: не
   чинит цель F2: §8-инвариант требует свежий corpus: clean в самом
   целевом репо перед первым merge; линт, зелёный только в клоне,
   оставляет первый merge пользователя fail-loud стопом — исходный
   дефект F2 воспроизводится; (а-наивный) расширение перечисления
   набора точечными путями (18 C9-путей + registry) — why: хрупко:
   состав протухает при каждой новой ссылке в контрактах, а
   C9-носители шире набора копирования (README/CONTRIBUTING/SECURITY
   — тоже источники путей); (в-линт) fast-path отсутствия в C9/C12 —
   why: правка scripts/check_corpus.sh = смена shared-контракта,
   волной исключена (Fan-out Scope: контракты §1 не трогаем,
   selftest-числа не меняются) — класс второй волны.

## Scope
<!-- owner: architect (границы), planner (уточняет); fan-out инвентарь для shared-контрактов -->
Изменения:
- `docs/getting_started.md` — набор файлов + линт-шаг + 6 ссылок;
- `docs/model_run.md` — 2 ссылки + budgets-pointer + формулировка §2;
- `docs/lifecycle.md` — бюджетная заметка в гейтах + «§§1–10»;
- `docs/playbooks/docs_canon_sweep.md` — диапазон проверок;
- `docs/plans/README.md` — harvest-конъюнкт `Merged → Done`;
- `docs/releases/README.md` — C14/gitleaks формулировка;
- `docs/plans/261116_1321_*.md` — резолвинг-запись в Suggestions log (F3);
- затронутые планы F4 (0320, 0427, 1455, 2243, 0151 — финальный список
  по grep; 1642/1943/1944 исключены верификацией — актуальные хеши
  уже в планах) — append-only Evidence-резолвинг-записи;
- `.zcode/commands/planfaktor-run.md`, `planfaktor-status.md` — только
  опечатки («гейтях», «≤ сумме»);
- `docs/followups/backlog.md` + `index.md` — материализация 3 строк
  (qa-format-lint, site-redeploy, guides-link-lint) + правка 2 строк
  (release-notes-lint → C17, index-counter-consistency → C18) +
  пересборка index; терминальных закрытий нет (Solution п.7).
Fan-out: контрактов §1 волна НЕ трогает (AGENTS/роли/шаблоны/команды как
носители — только опечатки run/status без изменения семантики; digest
 role-доков не меняется); C9 не затронут (ссылки гайдов вне его скоупа,
 но все новые пути обязаны существовать — контроль в Tests); правки
Done-планов — append-only Evidence/Suggestions в существующих секциях
(C3-структура не меняется; pre-cutoff планы — их проверки excluded);
линт-числа selftest/smoke не меняются.

## Out of scope
<!-- owner: architect -->
1. Контрактный слой F5–F9 + S3.1–8 (роль-доки, §3-intake, §9-каталог) —
   вторая волна, отдельный план.
2. Сайт (F13) — редеплой после обеих волн по регламенту сайта.
3. Исторические таймстампы closeout-узлов и прочее append-only
   наблюдаемое — не чинится (конвенция).
4. Машинная проверка ссылок гайдов (кандидат линта) — фиксация в
   Suggestions, не в этой волне.
5. Push-санкция накопленных коммитов — решение Owner вне этого плана.

## Acceptance criteria / DoD
<!-- owner: planner; чек-лист проверяемых исходов; перепринято 20:41 из
     кураторского черновика: рассинхроны D1/D2/D6/D12 сняты по
     objections Architect 20:31:40/20:34:30 и Solution п.2/п.7;
     материализация пачки 3+2 (Manager, 20:38–20:41) верифицирована
     Planner'ом живым чтением backlog (строки qa-format-lint/
     site-redeploy/guides-link-lint open; release-notes-lint C17/v2;
     index-counter-consistency C18/v2) — Coder backlog/index не правит -->
- [ ] D1 (F3): резолвинг-запись в Suggestions log плана 261116_1321 —
      append-only поясняющая строка с пометкой, что suggestion
      14:03:35 материализована строкой `qa-format-lint` (id, судьба
      open), lost follow-up резолвнут явно; сама строка backlog уже
      существует и Coder'ом не правится.
- [ ] D2 (F4): 5 резолвинг-записей — по одной в хвост Evidence каждого
      из 5 планов (0320:502, 0427:391+:445 одной записью, 1455:46,
      2243:335, 0151:698), формат Solution п.2: `резолвинг merge-хеша
      после пересборки публичной истории 2026-11-13: <старый> →
      <новый> (<subject>)`; замены: 782971a→7a668f0, 3c93628→51447d4,
      64b6622→5835c53, afe047d/653cd2b→2bc0fd7; каждый новый хеш
      существует (`git cat-file -e` → 0); исторические строки не
      изменены (git diff по 5 планам — вставки только в хвост).
- [ ] D3 (F2, needs-fix r1 → Solution п.8 «канон-каркас»): getting_started
      описывает копирование канон-каркаса вместо «закрытого набора»:
      корневые контракты (AGENTS.md, README.md, CONTRIBUTING.md,
      SECURITY.md); docs/ канона — справочники getting_started/lifecycle/
      model_run; каталоги plans (README + _template + канон-пример-план
      261111_2243 — файл-цель ссылки CONTRIBUTING:49), reviews
      (_template_review), roles, playbooks, releases (README + _template
      + релиз-ноты), requirements (README + registry и matrix как пустые
      носители — без строк требований), reference, compliance; followups —
      пустые носители по _template; scripts/check_corpus.sh;
      .github/workflows/corpus.yml; .zcode/{commands,agents}; артефакты
      исполнения (планы вне шаблона и канон-примера, ревью, чужой
      backlog/requirements-контент, docs/img) не копируются; шаг «первый
      линт» сохранён — прогон в целевом репо сразу после копирования,
      ожидание `corpus: clean`, связь с §8 pre-merge verify.
- [ ] D4 (F10): 9 ссылок (getting_started :8, :48, :50, :132, :136,
      :137, :138; model_run :12, :13) переписаны от размещения `docs/`
      (`../README.md`, `../AGENTS.md`, `lifecycle.md`,
      `playbooks/manual_terminal_recovery.md`); все относительные ссылки
      обоих гайдов — включая добавляемые ссылки каркас-раздела D3 —
      резолвятся: скрипт-обход → 0 битых целей.
- [ ] D5 (F11): lifecycle описывает бюджетную заметку §8 в
      merge/closeout-гейтах (сверка с тирами budgets.md; warn — инфо,
      discuss — обоснование) + pointer на `docs/reference/budgets.md`.
- [ ] D6 (F12): docs_canon_sweep:30 — «C1–C13» → «C1–C16» (единственное
      вхождение); backlog release-notes-lint несёт «C17/v2» и
      index-counter-consistency — «C18/v2» (уже материализовано,
      Coder'ом не правятся — предусловие, не шаг).
- [ ] D7: plans/README:58 `Merged → Done` несёт harvest-конъюнкт §2
      («Follow-ups заполнен; harvest-инвентарь (источники а/б/в) с
      судьбами»).
- [ ] D8: model_run — pointer на budgets.md (:107 рядом с «получает
      судьбу») и формулировка судьбы хвостов по §2 (материализация
      строкой, терминальные закрытия), без сужения механики.
- [ ] D9: lifecycle:4 «§§1–8» → «§§1–10»; run.md:179 «гейтях» →
      «гейтах»; status.md:58 оба вхождения «≤ суммы»-класса →
      «≤ сумме».
- [ ] D10: releases/README:30 — «C14 safety-scan (встроенный чек);
      gitleaks по истории — кандидат history-secret-audit» (строка
      backlog:20 существует — pointer корректен), приписки
      «(gitleaks…)» к C14 нет.
- [ ] D11: свежий прогон на финальном дереве: `corpus: clean` +
      `selftest: 38/38 caught` + `smoke: clean`.
- [ ] D12: волна не меняет backlog/index: git status по
      docs/followups/ чист; счётчик index = носитель по status
      (база Planner-верификации 20:41: open 14 / closed 18); все 3
      новые строки остаются open (терминальных закрытий волна не
      несёт, Solution п.7); CI зелёный на merge-пуше — приёмка
      merge-гейта (Manager, gh run list), не шаг Coder'а.
- [ ] D13 (fan-out инвентарь §5): правки .zcode/commands/
      planfaktor-run.md и planfaktor-status.md — только опечатки
      D9 без изменения семантики; AGENTS.md и docs/roles/* не
      тронуты (git diff пуст); selftest/smoke-числа не меняются
      (38/38, clean — носитель скрипта не правится).
- [ ] D14 (needs-fix r1, live-блокер #B1 — Solution п.8, доводка
      Planner'а 22:16–22:20): гайд воспроизводим — симуляция
      установки (сборка каркаса D3 по cp-блоку гайда в отдельном
      каталоге) даёт первый линт `corpus: clean` сразу после
      копирования, без планов пользователя. Форма первого прогона —
      голый каркас (A/B-фиксация развилки п.8): rejected alternatives:
      «каркас + первый план из шаблона до линта» — why: не закрывает
      ни C9 (нужен именно 261111_2243), ни C12 при полном реестре
      (живой прогон), а на голом каркасе линт уже зелёный — шаг лишний;
      «полный реестр требований в каркасе» — why: C12 тянет планы
      261112_2236+261115_2252 (8 rows → missing, живой прогон 22:18) —
      три артефакта исполнения вместо одного, G56939-строки — контекст
      Planfaktor, не нового целевого репо; «строго без планов в каркасе»
      — why: C9 FAIL на CONTRIBUTING:49 → dangling
      docs/plans/261111_2243_corpus_lint_ci.md (живой прогон 22:18),
      а правка CONTRIBUTING — смена корневого контракта вне волны
      (Fan-out Scope); план 261111_2243 входит в каркас как
      канон-пример (файл-цель ссылки контракта, сам excluded по
      usage/digest-cutoff'ам).

## Tests / Commands
<!-- owner: planner (задаёт), coder (заполняет факт); каждый Dn покрывается строкой с меткой (Dn);
     все команды Planner-прогоны 20:36–20:41 на текущем дереве: до правок
     скрипт-обход даёт 4 битых цели (9 вхождений), корневые формы — 9 строк,
     selftest 38/38; после правок — ожидания ниже -->
- (D1) `grep -n 'qa-format-lint' docs/plans/261116_1321_lint_v2_digest_qa.md`
  → ≥ 1 строки в ## Suggestions log (резолвинг-запись; до правок — 0,
  проверено); в записи — упоминание судьбы «материализована … строкой»
  и указание на id `qa-format-lint`.
- (D2) `for h in 7a668f0 51447d4 5835c53 2bc0fd7; do git cat-file -e $h
  || echo BROKEN $h; done` → пусто (все существуют; Planner-прогон 20:37
  подтвердил); subject каждой записи — `git log -1 --format=%s <новый>`
  (верифицированные needs-fix r1, 22:15: 7a668f0 `feat(261111_0320):
  add HH:MM:SS timing marks and phase durations`, 51447d4
  `docs(261111_0427): rewrite README as owner quickstart`, 5835c53
  `feat(261111_2243): add corpus lint script, CI stub and ops line`
  [finding C2 Round 1: прежняя Planner-цитата и резолвинг-запись Coder'а
  в 2243 несли «ops log» — слово ошибочно], 2bc0fd7 `feat(261114_0151):
  planfaktor-init and run PLAN_PATH argument`); C2-якорь fixes-итерации:
  `grep -c 'ops log' docs/plans/261111_2243_corpus_lint_ci.md` → 0
  (до фикса — 1: резолвинг-запись :336) и `grep -c 'ops line' …` → 2
  (историческая merge-строка :334 + резолвинг-запись после фикса;
  Planner-прогоны 22:15: git-subject — «ops line», в 2243 сейчас
  ops line=1/ops log=1); `grep -c 'резолвинг
  merge-хеша после пересборки публичной истории 2026-11-13'
  docs/plans/261111_0320*.md docs/plans/261111_0427*.md
  docs/plans/261111_1455*.md docs/plans/261111_2243*.md
  docs/plans/261114_0151*.md` → ровно по 1 на файл; append-only:
  `git diff HEAD -- <5 планов>` (дерево против HEAD до коммита,
  staged/unstaged вместе) — только вставки в хвост Evidence, удалений
  0, старые хеши 782971a/3c93628/64b6622/afe047d/653cd2b остаются
  в исторических строках (правка C2 — замена слова внутри
  резолвинг-строки :336, append-only истории не ломает).
- (D3) каркас-состав гайда (needs-fix r1, Solution п.8):
  `grep -cE 'check_corpus|линт' docs/getting_started.md` ≥ 2;
  `grep -n 'corpus: clean' docs/getting_started.md` ≥ 1 (шаг первого
  линта + связь с §8); маркеры каркаса: `grep -c 'CONTRIBUTING'
  docs/getting_started.md` ≥ 1, `grep -c '_template'
  docs/getting_started.md` ≥ 1, `grep -c '261111_2243'
  docs/getting_started.md` ≥ 1 (канон-пример-план), `grep -cE
  'followups|requirements' docs/getting_started.md` ≥ 2 (пустые
  носители), `grep -c 'corpus.yml' docs/getting_started.md` ≥ 1,
  `grep -c 'agents' docs/getting_started.md` ≥ 1 (.zcode/agents);
  форма ограниченного набора не остаётся: `grep -c 'набор файлов'
  docs/getting_started.md` → 0 (заголовок секции текущего набора,
  Planner-прогон 22:23 — 1; каркас-раздел приходит ему на смену) и
  `grep -c 'каркас' docs/getting_started.md` ≥ 1.
- (D4) скрипт-обход (Planner-прогон 20:41, до правок — 4 битых цели;
  после fixes-итерации покрывает и ссылки каркас-раздела D3 — обход
  гоняется по обоим гайдам целиком, новые ссылки попадают автоматически):
  `grep -hoE '\]\([^)]+\)' docs/getting_started.md docs/model_run.md |
  sed 's/^](//; s/)$//' | grep -vE '^(https?:|#|mailto:)' | sort -u |
  while read -r p; do [ -e "docs/$p" ] || echo "BROKEN: $p"; done`
  → пусто; `grep -nE '\]\((README\.md|AGENTS\.md|docs/)'
  docs/getting_started.md docs/model_run.md` → 0 (до правок — 9 строк).
- (D5) `grep -n 'budgets' docs/lifecycle.md` ≥ 1 (pointer);
  `grep -c 'бюджет' docs/lifecycle.md` ≥ 1 (заметка в гейтах).
- (D6) `grep -n 'C1–C16' docs/playbooks/docs_canon_sweep.md` ≥ 1;
  `grep -c 'C1–C13' docs/playbooks/docs_canon_sweep.md` → 0;
  `grep -n 'кандидат C17/v2' docs/followups/backlog.md` → строка
  release-notes-lint; `grep -n 'кандидат C18/v2' docs/followups/backlog.md`
  → строка index-counter-consistency (предусловие — уже на месте,
  Planner-прогон 20:36 подтвердил).
- (D7) `grep -E '^\| .Merged. → .Done.' docs/plans/README.md | grep -c
  'harvest'` → 1 — конъюнкт именно в строке табличного перехода :58
  (CENSOR-прогон 20:49: слово «harvest» уже есть в plans/README
  :121/:123/:145/:231 в секции harvest — голый grep по файлу прошёл бы
  без правки :58, якорь на строку перехода обязателен; сейчас в
  строке перехода 0).
- (D8) `grep -n 'budgets' docs/model_run.md` ≥ 1; осмотр :100–:115 —
  «получает судьбу» раскрывает механику §2 (материализация строкой,
  терминальные закрытия).
- (D9) `grep -c '§§1–10' docs/lifecycle.md` ≥ 1; `grep -rc 'гейтях'
  .zcode/` → 0; `grep -c '≤ сумме' .zcode/commands/planfaktor-status.md`
  ≥ 2 и `grep -c '≤ суммы' .zcode/commands/planfaktor-status.md` → 0
  (оба вхождения :58; Planner-прогон 20:38: :58 несёт «≤ сумма» и
  «≤ суммы» — правятся оба).
- (D10) `grep -n 'C14' docs/releases/README.md` — без «(gitleaks»;
  `grep -n 'history-secret-audit' docs/releases/README.md` ≥ 1.
- (D11) `sh scripts/check_corpus.sh` → `corpus: clean`;
  `sh scripts/check_corpus.sh --selftest` → `selftest: 38/38 caught`
  (Planner-прогон 20:38 подтвердил); `sh scripts/check_corpus.sh --smoke`
  → `smoke: clean`.
- (D12) `git status --porcelain docs/followups/` → пусто; счётчик:
  `grep -c ' — status=open — ' docs/followups/backlog.md` → 14 и
  `grep -c ' — status=handled — ' docs/followups/backlog.md` → 18
  (Planner-прогон 20:43: разделитель row-грамматики обязателен — голый
  `status=open` даёт 15 из-за упоминания формата в тексте строки :13
  qa-lint; чекбоксы тоже ненадёжны: :31 несёт `[ ]` при handled —
  считать по status);
  `grep 'Счётчик' docs/followups/index.md` → «открытых — 14, закрытых
  — 18»; CI: `gh run list --limit 1` → success — проверка merge-гейта
  (Manager), не шаг Coder'а.
- (D13) `git diff HEAD --stat -- AGENTS.md docs/roles/` → пусто;
  `git diff HEAD -- .zcode/commands/` — только run.md:179/
  status.md:58 (опечатки D9), семантика шагов команд не изменена.
- (D14) симуляция установки (B1-fix): после правки гайда — выполнить
  cp-блок гайда (D3) в свежий TMPDIR-каталог (эталон состава,
  Planner-прогон 22:18–22:20: корневые AGENTS/README/CONTRIBUTING/
  SECURITY; docs/getting_started+lifecycle+model_run; plans/README+
  _template+261111_2243_corpus_lint_ci.md; reviews/_template_review;
  roles/*.md; playbooks/*.md; releases/*.md; requirements/README.md +
  registry с пустой секцией `## Требования` (без row-строк) + matrix
  пустой формы; reference/*.md; compliance/*.md; followups/_template.md
  + backlog.md («# Follow-ups backlog» + пустая секция) + index.md
  («Счётчик: открытых — 0, закрытых … — 0»); scripts/check_corpus.sh;
  .github/workflows/corpus.yml; .zcode/commands/*.md;
  .zcode/agents/*.md), затем `cd <копия> && sh scripts/check_corpus.sh`
  → `corpus: clean`, 0 FAIL (живой Planner-прогон эталона: clean,
  FAILS=0; контрфакты: голый каркас без плана 2243 — C9 FAIL
  CONTRIBUTING:49; полный реестр — C12 FAIL 8 rows → missing
  261112_2236/261115_2252).

### Coder run facts (2026-11-17, прогоны 20:55–21:12; все — из корня
### репо, если не указано иное)

- (D1) `grep -n 'qa-format-lint' docs/plans/261116_1321_lint_v2_digest_qa.md`
  → 1 строка (:431) — резолвинг-запись 20:59:10 в `## Suggestions log`
  («материализована отдельной строкой backlog id=qa-format-lint
  (status=open, план 261117_2002 …)»); до правок 0.
- (D2) `git cat-file -e` по 7a668f0/51447d4/5835c53/2bc0fd7 → все
  существуют; по 782971a/3c93628/64b6622/afe047d/653cd2b → все MISSING
  (прогоны 20:55–20:57); subjects сверены `git log -1 --format=%s` —
  совпадают дословно, 2bc0fd7 без усечения: «feat(261114_0151):
  planfaktor-init and run PLAN_PATH argument»; `grep -c 'резолвинг
  merge-хеша после пересборки публичной истории 2026-11-13'` по 5 планам
  → ровно по 1 на файл; `git diff HEAD --numstat -- <5 планов>` →
  5×(+1/−0) — вставки только в хвост Evidence, старые хеши в
  исторических строках на местах (grep 20:56).
- (D3) `grep -cE 'check_corpus|линт' docs/getting_started.md` → 5 (≥2);
  `grep -n 'corpus: clean'` → 3 строки (:34 — набор, :57 — ожидание
  первого линта, :60 — §8-связь).
- (D4) python3-обход всех относительных ссылок двух гайдов (экстракт
  `](...)` с исключением http/#/mailto, resolve от `docs/`) → broken=0;
  `grep -nE '\]\((README\.md|AGENTS\.md|docs/)'` по обоим гайдам →
  0 строк.
- (D5) `grep -n 'budgets' docs/lifecycle.md` → :103, :134; `grep -c
  'бюджет'` → 1 (≥1).
- (D6) `grep -n 'C1–C16' docs/playbooks/docs_canon_sweep.md` → :30;
  `grep -c 'C1–C13'` → 0; предусловие на месте и не правилось:
  `grep -n 'кандидат C17/v2' docs/followups/backlog.md` → :26
  (release-notes-lint), `grep -n 'кандидат C18/v2'` → :38
  (index-counter-consistency).
- (D7) `grep -E '^\| .Merged. → .Done.' docs/plans/README.md | grep -c
  'harvest'` → 1.
- (D8) `grep -n 'budgets' docs/model_run.md` → :111; осмотр :106–:112 —
  «получает судьбу по §2 — материализуется строкой … либо терминально
  закрывается (`handled` / `already-tracked-elsewhere`)»: сужения
  механики нет.
- (D9) `grep -c '§§1–10' docs/lifecycle.md` → 1; `grep -rc 'гейтях'
  .zcode/` → 0 по всем 9 файлам; `grep -c '≤ сумме' …planfaktor-status.md`
  → 2, `grep -c '≤ суммы'` → 0 (:58 разбита переносом для построчного
  счёта — правка только падежа).
- (D10) `grep -n 'C14' docs/releases/README.md` → :30/:61/:77, ни одна
  не несёт «(gitleaks»; `grep -n 'history-secret-audit'` → :31–32.
- (D11) `sh scripts/check_corpus.sh` → `corpus: clean`;
  `--selftest` → `selftest: 38/38 caught`; `--smoke` → `smoke: clean`.
  Наблюдаемое: в выводах selftest/smoke есть stderr-шум «printf: write
  error: Broken pipe» — механика пайпов в C12/C13-кейсах скрипта,
  носитель скрипта волной не правился, вердиктам не мешает; smoke-план
  261130_0000 удалён прогоном (git status по docs/plans/ без smoke-хвостов).
- (D12) `git status --porcelain docs/followups/` → 2 записи (backlog.md,
  index.md) — обе суть материализация пачки 3+2 Manager'ом 20:38–20:41
  (правка :26 C15→C17, :38 C17→C18, +3 строки open, index 11→14 +
  P3 10→13; верифицирована Planner'ом 20:44:10, Coder backlog/index не
  правил — unstaged-дельта волны, стейджится вместе с ней); счётчики:
  `grep -c ' — status=open — '` → 14, `grep -c ' — status=handled — '`
  → 18; `grep 'Счётчик' docs/followups/index.md` → «открытых — 14,
  закрытых (promoted/handled/cancelled) — 18»; все 3 новые строки
  остаются open. CI — приёмка merge-гейта (Manager), не шаг Coder.
- (D13) `git diff HEAD --stat -- AGENTS.md docs/roles/` → пусто;
  `git diff HEAD -- .zcode/commands/` → только planfaktor-run.md
  («гейтях» → «гейтах») и planfaktor-status.md (два «≤ сумме», перенос
  строки) — семантика шагов не изменена; selftest 38/38 / smoke clean —
  носитель скрипта не правился, числа не менялись.

### Coder run facts, fixes-итерация r1 (2026-11-17, прогоны 22:27–22:37)

Коррекция r0-факта (finding C2 Round 1): заявление r0-блока «subjects
сверены — совпадают дословно» для 5835c53 было неверным — фактический
git-subject «…CI stub and ops line», r0-резолвинг-запись 2243:336 несла
«ops log» (ошибка переноса цитаты; хеш и ссылка были верны). Исправлено
этой итерацией: слово в :336 + данный рун-факт.

- (D2/C2) `grep -c 'ops log' docs/plans/261111_2243_corpus_lint_ci.md`
  → 0 (baseline 22:27: 1, :336); `grep -c 'ops line' …` → 2 (:334
  историческая merge-строка + :336 исправленная резолвинг-запись);
  резолвинг-grep по 5 планам → ровно по 1 на файл; `git diff HEAD
  --numstat` по 5 планам → 5×(+1/−0); старые хеши 782971a/3c93628/
  64b6622/afe047d/653cd2b — в исторических строках на местах
  (0320:502, 0427:391+:445, 1455:46, 2243:335, 0151:698; grep 22:44).
- (D3) маркеры каркаса: `grep -cE 'check_corpus|линт'` → 7 (≥2);
  `grep -c 'corpus: clean'` → 4; `grep -c 'CONTRIBUTING'` → 2;
  `grep -c '_template'` → 6; `grep -c '261111_2243'` → 2;
  `grep -cE 'followups|requirements'` → 12; `grep -c 'corpus.yml'` → 2;
  `grep -c 'agents'` → 4; `grep -c 'набор файлов'` → 0 (baseline 22:27:
  1 — заголовок секции закрытого набора); `grep -c 'каркас'` → 2 (≥1).
- (D4) python3-обход всех относительных ссылок обоих гайдов (24 ссылки;
  каркас-раздел несёт 2 markdown-ссылки — lifecycle.md,
  playbooks/manual_terminal_recovery.md, прочие пути состава —
  code-span'ы вне линк-грамматики; исключения http/#/mailto,
  resolve от `docs/`) → broken=0; `grep -nE
  '\]\((README\.md|AGENTS\.md|docs/)'` по обоим гайдам → 0 строк.
- (D14) симуляция установки (B1-fix, эталон D14): из getting_started
  дословно извлечён первый ```bash-блок (cp-блок каркаса), исполнен
  `sh install.sh` в свежем TMPDIR-каталоге с PF=<репо> → exit 0;
  инвентарь копии — 48 файлов, состав = эталон (корневые
  AGENTS/README/CONTRIBUTING/SECURITY; гайды ×3; plans README+
  _template+261111_2243; reviews/_template_review; roles ×7; playbooks
  ×6; releases ×5; requirements README+пустые registry/matrix;
  reference/budgets; compliance/gost; followups _template+пустые
  backlog/index; scripts/check_corpus.sh; .github/workflows/corpus.yml;
  .zcode/commands ×4; .zcode/agents ×5; docs/img и артефакты исполнения
  отсутствуют); «первый линт» из копии (`sh scripts/check_corpus.sh`,
  cwd=копия) → exit 0, C1–C16 OK (2243 — excluded по usage/digest
  cutoff'ам), `corpus: clean`, 0 FAIL — без планов пользователя.
- (D11) свежие прогоны на финальном дереве (после правки гайда,
  завершены к 22:37:48):
  `sh scripts/check_corpus.sh` → `corpus: clean`; `--selftest` →
  `selftest: 38/38 caught`; `--smoke` → `smoke: clean`; smoke-хвост
  docs/plans/261130_0000 — отсутствует (ls grep → 0).
- (D12) `git status --porcelain docs/followups/` → MM backlog.md,
  MM index.md: staged-часть — материализация пачки 3+2 (r0), unstaged —
  R2-фикс Manager'а 22:09–22:2x (plan=261117_2002 → plan=none в трёх
  новых строках + index), Coder'ом контент не правился, стейджится
  с волной; счётчики: ` — status=open — ` → 14, ` — status=handled — `
  → 18; index «Счётчик: открытых — 14, закрытых
  (promoted/handled/cancelled) — 18».
- (D13) `git diff HEAD --stat -- AGENTS.md docs/roles/` → пусто;
  `.zcode/commands/` → только run.md (2 +−) и status.md (3 ++-) —
  r0-опечатки D9, r1 не трогала; scripts/check_corpus.sh не правился
  (38/38, smoke clean — числа не менялись).

## Changes (by area)
<!-- owner: coder; фактические изменения по областям; заполняется в ходе работы -->
- docs/plans/261116_1321_lint_v2_digest_qa.md — D1: резолвинг-запись в
  хвост `## Suggestions log` (append-only): suggestion 14:03:35
  материализована строкой id=qa-format-lint (status=open, план
  261117_2002), lost follow-up резолвнут явно.
- 5 планов F4 (0320/0427/1455/2243/0151) — D2: по одной резолвинг-записи
  в хвост `## Evidence` каждого (фраза резолвинга — одной строкой,
  line-based grep): 782971a → 7a668f0 (0320; цитаты в 1455:46 и 0427:391
  тем же соответствием, в 0427 — одной записью с 3c93628 → 51447d4),
  64b6622 → 5835c53 (2243), afe047d/653cd2b → 2bc0fd7 (0151);
  исторические строки не тронуты (numstat: 5 файлов, +5/−0).
- docs/getting_started.md — D3: строка таблицы набора
  (`scripts/check_corpus.sh`), mkdir+cp скрипта в командный блок, шаг
  «первый линт» после копирования (`sh scripts/check_corpus.sh`,
  ожидание `corpus: clean`, связь с §8 pre-merge verify); D4: 7 ссылок
  переписаны от размещения `docs/` (`../README.md` ×2, `../AGENTS.md`,
  `lifecycle.md` ×2, `playbooks/manual_terminal_recovery.md` ×2).
- docs/model_run.md — D4: `../README.md`, `../AGENTS.md` (:12–13); D8:
  «получает судьбу» раскрыт по §2 (материализация строкой backlog /
  терминальные закрытия handled/already-tracked-elsewhere) + тиры
  budgets.md (:106–112).
- docs/lifecycle.md — D5: бюджетная заметка §8 в гейте Merge (сверка
  сумм Token usage с тирами budgets.md: warn — инфо, discuss —
  обоснование) и в closeout `Merged → Done`; D9: «§§1–8» → «§§1–10».
- docs/playbooks/docs_canon_sweep.md — D6: «C1–C13» → «C1–C16» (:30,
  единственное вхождение).
- docs/plans/README.md — D7: harvest-конъюнкт §2 в строке перехода
  `Merged → Done` таблицы статусной машины.
- docs/releases/README.md — D10: «C14-чистота (gitleaks …)» → «C14
  safety-scan (встроенный чек по рабочему дереву); gitleaks по истории —
  кандидат history-secret-audit» + pointer на строку backlog.
- .zcode/commands/planfaktor-run.md — D9: «гейтях» → «гейтах» (:179).
- .zcode/commands/planfaktor-status.md — D9: оба вхождения
  «≤ суммы»-класса → «≤ сумме» (:57–58; строка разбита переносом —
  построчный `grep -c` честно считает 2; правка только падежа,
  семантика шага 6 не менялась).
- Не правились (инварианты): docs/followups/backlog.md и index.md —
  unstaged-дельта = материализация пачки 3+2 Manager'ом 20:38–20:41
  (верифицирована Planner'ом 20:44:10), Coder-дельты нет, стейджится с
  волной; AGENTS.md и docs/roles/* — diff пуст; scripts/check_corpus.sh —
  носитель не правился (selftest/smoke числа не менялись).

Fixes-итерация r1 (needs-fix Round 1: live-блокер #B1 + finding C2;
intake 22:27:06):
- docs/getting_started.md — D3/D14 (B1-fix по Solution п.8): Шаг 1
  переписан под канон-каркас — «закрытый набор» упразднён (0 вхождений
  «набор файлов»); таблица состава каркаса (корневые контракты
  AGENTS/README/CONTRIBUTING/SECURITY; гайды getting_started/lifecycle/
  model_run; канон docs/ — plans README+_template+канон-пример
  261111_2243, reviews-шаблон, roles/playbooks/releases/reference/
  compliance; requirements/followups — пустые носители; check_corpus.sh;
  corpus.yml; .zcode/{commands,agents}); командный блок — mkdir 10
  каталогов + cp по составу + 4 heredoc пустых носителей
  (requirements/registry с пустой `## Требования`, matrix, followups/
  backlog, index «Счётчик: 0/0»); в шаге «первый линт» — самодостаточность
  каркаса (`corpus: clean` сразу после копирования, до первых планов,
  связь §8 сохранена); оговорка: артефакты исполнения Planfaktor (планы
  вне шаблона и канон-примера, ревью, строки техдолга/требований, img)
  не копируются.
- docs/plans/261111_2243_corpus_lint_ci.md — C2-фикс: «ops log» →
  «ops line» в резолвинг-записи :336 (строка — незакоммиченная вставка
  волны, numstat против HEAD +1/−0; замена слова до коммита, история
  репозитория не переписывается).
- docs/plans/261117_2002_docs_wave1_archive_surface.md — мета-правки
  плана: intake fixes-итерации (Q&A log), статусный переход
  In review → In progress → In review по §2, AC-to-test r1, рун-факты
  r1 (включая коррекцию r0-заявления о дословности subject 5835c53),
  эти Changes-записи, Evidence-узлы.

## Evidence (chronological, append-only)
<!-- owner: все роли + CENSOR; событийные записи с датой и локальным временем -->
- 2026-11-17 20:02:00 — Curator: триаж ревью документации против живого
  дерева. Подтверждено лично: F3 (1321:427 suggestion вербатим ↔ closeout
  «источник (б) открытых нет» ↔ qa-lint handled-целиком); F4 (cat-file:
  782971a/3c93628/64b6622/b53f8c5/afe047d/653cd2b — все MISSING; реальные
  2bc0fd7/0aa2d02 существуют); F2 (0 упоминаний линта в гайде); F10
  (битые ссылки :8/:48/:50/:132/:12–13); F11 (0 «бюджет» в lifecycle);
  F1 ревью устарел — счётчик исправлен при merge 1419 (17/11 → closeout
  11/18, материализована index-counter-consistency). Ревью — Owner-бриф:
  текст отчёта фиксируется в Evidence этого плана при активации
  (Manager, дословная цитата ключевых находок); происхождение —
  кураторский драфт по прецеденту 1321/0221/1419, зоны перепринимаются.
- 2026-11-17 20:21:46 — Manager: план активирован вызовом Owner `/planfaktor-run docs/plans/261117_2002_docs_wave1_archive_surface.md` (валидации 1a пройдены: файл/Plan ID/статус Draft/инвариант одного активного — прочие 20 планов Done; спец-указаний в сопроводительном сообщении нет). Ветвление Draft: кураторский черновик §1(g) — зоны предзаполнены, intake роли нет → диспатч Architect (PHASE=work) на перепринятие, не rubber-stamp. Две оговорки Manager (fail loud, §1(d)): (1) материализация 11 строк (Solution п.7 «при активации») отложена до Architect-переприятия — состав пачки в кураторском Solution, untrusted до верификации (прецедент 261117_1419: 2 из 8 кураторских находок опровергнуты; при подтверждении состава — исполню немедленно после CENSOR); (2) дословный Owner-бриф ревью (отчёт вне репо) этой сессии недоступен — ревью выполнялось другой сессией; ключевые находки вербатим уже в триаже куратора (Evidence 20:02:00), переприятие Architect'ом верифицирует их против дерева
- 2026-11-17 20:32:20 — Architect: переприятие кураторских зон
  верификацией против репозитория (живые прогоны, untrusted input).
  Подтверждено: F3 (1321:427 вербатим ↔ closeout 1321:372 «судьбы
  handled» целиком ↔ backlog:13 qa-lint handled; qa-format-lint в
  backlog отсутствует); F4 по существу (cat-file: 782971a/3c93628/
  64b6622/afe047d/653cd2b — MISSING; замены по git log --grep:
  7a668f0/51447d4/5835c53/2bc0fd7 — существуют); F2 (0 упоминаний
  линта/check_corpus в getting_started, набор :24–:35 без скрипта);
  F10 (скрипт-обход — ровно 9 битых: getting_started :8/:48/:50/:132/
  :136/:137/:138, model_run :12/:13); F11 (0 «бюджет» в lifecycle;
  0221:86/:91 «БЕЗ правок»); F12+S3.9–14 (sweep:30 «C1–C13»;
  backlog:26 «C15/v2»; plans/README:58 без harvest-конъюнкта;
  model_run:107 + 0 «budgets»; lifecycle:4 «§§1–8»; run.md:179
  «гейтях»; status.md:58 «≤ суммы»; releases/README:30 «C14-чистота
  (gitleaks…)»; history-secret-audit backlog:20 существует); прецедент
  резолвинг-формы 0217:459 + 2121:195; selftest 38/38 актуален;
  id qa-format-lint/site-redeploy/guides-link-lint свободны.
  Опровергнуто/переопределено: F4 «6 планов» → 5 (b53f8c5 — фантом;
  1642:980/1943/1944:842 уже несут a53592b/7b23670/6596b7f);
  0427_review.md:40 «HEAD = 782971a» — исторический вердикт-факт,
  не чинится; НОВАЯ находка — коллизия C17 (релиз-ноты v0.1.0:83/
  v0.1.1:59/v0.2.0:64 зовут release-notes-lint C17/v2, backlog:38
  претендует на тот же C17) → резолвинг C17/C18 (Solution п.6);
  «11 строк» пачки невосстановимы (открытых строк backlog ровно 11 —
  вероятная контаминация счёта) → финальный состав 3+2 (Solution п.7).
  Рассинхрон DoD D1/D2/D6/D12 — objection в Objections log. Открытых
  вопросов к Owner нет
- 2026-11-17 20:33:10 — Architect: фаза work завершена — зоны
  (понимание, Problem, Solution/Decisions, Scope, Out of scope)
  переприняты и заполнены; intake 20:24:10; верификация записана
  Evidence 20:32:20; финальный состав backlog-пачки — Solution п.7
  (для материализации Manager'ом после CENSOR по оговорке
  Evidence 20:21:46 п.1). Переход Draft → Ready for Planner
- 2026-11-17 20:37:30 — (Role CENSOR) OK: Ready for Planner validated; current=true
Censor dispatch id: censor:architect:261117_203143
Observations:
- Second opinion: шапка перечитана с диска — `**Status:** Ready for
  Planner` (:4) = PRE_STATUS_LINE конверта, Plan ID 261117_2002 (:3) =
  имени файла; свои секции (понимание :13–22, Problem :26–68, Solution
  :72–142, Scope+Fan-out :146–169, Out of scope :173–180) заполнены,
  решения несут rejected alternatives (п.6 C17-резолвинг, п.7
  guides-link-lint/Suggestions), п.7 — A/B-фиксация без дизъюнкции;
  чужие зоны не тронуты: DoD :184–206 / Tests :210–229 / Changes :231 /
  Follow-ups :316–321 — кураторские, рассинхроны D1/D2/D6/D12 и
  Follow-ups-строка оформлены objections (:300, :309), не правками;
  открытых Q к Owner нет (intake :289–:292 NO×3 + :294–:297 NO×3).
- Counterfactuals considered: (1) собственный факт «1943 несёт 7b23670»
  мог быть галлюцинацией раннего grep'а (в усечённом выводе его не
  было) — перепроверен живым прогоном: 1943:722 несёт merge-коммит
  7b23670, факт верен; (2) цитаты-локации моих секций могли протухнуть
  за время итерации — сверены повторным чтением файлов: 1321:427/:372,
  backlog:13/:20/:26/:38, релиз-ноты v0.1.0:83/v0.1.1:59/v0.2.0:64,
  sweep:30, plans/README:58, model_run:107, lifecycle:4, run.md:179,
  status.md:58, releases/README:30 — на месте; (3) «len» правок чужих
  зон — полный перечёт файла: правки только моих секций + Q&A intake +
  Objections (моя запись) + Evidence (append); (4) хронология Evidence
  монотонна (20:02:00 → 20:21:46 → 20:32:20 → 20:33:10).
- Addendum (new angle): сверил кураторскую Problem-фразу п.6 «(нота
  зовёт его C17)» с Solution п.6 — противоречия нет (раскрыта как
  три релиз-ноты); сверил Fan-out Scope против C15-набора: правки
  .zcode/commands (опечатки) не меняют digest роль-доков, selftest
  38/38 согласован с носителем; проверил, что фантомный b53f8c5 не
  фигурирует нигде вне Problem/Solution/Evidence этого плана.
- Fixes: none (NO FINDINGS; искал: правки чужих зон, протухшие
  локации-цитаты, дизъюнкции в решениях, потерянные Q к Owner,
  расхождение статуса с конвертом, галлюцинированные факты —
  все проверены живыми прогонами/перечётом, дефектов нет)
- Final censor verdict: OK
- 2026-11-17 20:44:10 — Planner: переприятие кураторских зон (DoD,
  Tests, Follow-ups) верификацией против дерева, не rubber-stamp.
  Живыми прогонами подтверждено: материализация пачки 3+2 фактически
  выполнена (backlog :26 release-notes-lint «C17/v2», :38
  index-counter-consistency «C18/v2», :39/:40/:41 qa-format-lint/
  site-redeploy/guides-link-lint open — конверт Manager'а сходится с
  носителем); хеши: 7a668f0/51447d4/5835c53/2bc0fd7 существуют,
  782971a/3c93628/64b6622/afe047d/653cd2b MISSING, локации 0320:502 /
  0427:391+:445 / 1455:46 / 2243:335 / 0151:698 на месте; suggestion
  1321 (14:03:35) вербатим подтверждена, qa-format-lint в плане 1321
  не упоминается (резолвинг-запись Coder'а будет первым вхождением);
  selftest 38/38 caught (прогон 20:38); скрипт-обход ссылок — 4 битых
  цели по 9 вхождениям, корневые формы — 9 строк, sweep — одно
  вхождение «C1–C13»; счётчик index = носитель по « — status=open — »
  → 14 / « — status=handled — » → 18 (нюансы, пойманные при
  верификации: голый grep 'status=open' даёт 15 — упоминание формата
  в тексте строки :13 qa-lint; чекбокс :31 s2-coder-status-contract
  `[ ]` при status=handled — вне скоупа волны, класс уже tracking'ся
  кандидатом C18). Objections Architect 20:31:40/20:34:30 приняты:
  D2 → 5 планов/5 старых хешей/4 новых, D6 → C17+C18, D1/D12 → пачка
  3+2 без терминальных закрытий, Follow-ups-строка 1 переписана;
  добавлен D13 (fan-out инвентарь §5 → DoD, носители контрактов
  неизменны). Решения Architect не менялись
- 2026-11-17 20:47:30 — Planner: finalize completion-pass (глазами
  Coder и Reviewer, до простановки статуса). Самопроверка-1 («что
  придётся угадывать, где блокер переживёт handoff»): нашёл и
  починил в своей зоне — Tests (D2)/(D13) несли неопределённый
  `<base>` → заменено на определённый критерий `git diff HEAD --
  <файлы>` (дерево против HEAD до коммита) с ожиданием «только
  вставки, удалений 0»; subject резолвинг-записей (D2) материализован
  командой `git log -1 --format=%s <новый>` + четырьмя
  верифицированными значениями; Tests (D12) дважды ловился на
  неточных счётных паттернах (чекбоксы → 15/17; голый 'status=open'
  → 15 из-за упоминания формата в тексте :13) — зафиксирован
  точный row-паттерн « — status=open — » → 14/« — status=handled — »
  → 18, оба живо прогнаны. Самопроверка-2 («implicit-доказательства»):
  каждый Dn несёт команду/локацию/ожидание (D1 grep в 1321 + id +
  судьба; D4 дословный скрипт-обход + 9 локаций + целевые формы;
  D8 осмотр :100–:115; D11 три прогона с числами) — implicit-носителей
  не осталось; формулировки записей (D1/D2) взяты из Solution п.1/п.2
  с прецедентами 0217:459/2121:195. Вердикт: дефектов не осталось
- 2026-11-17 20:48:20 — Planner: фаза work завершена (intake 20:41:39,
  Planning 20:41): DoD D1–D13 и Tests переприняты из кураторского
  черновика с устранением рассинхронов по objections Architect
  20:31:40/20:34:30 (5 планов/5+4 хешей, пачка 3+2 без терминальных
  закрытий, C17/C18 предусловием, D13 fan-out); Follow-ups (deferred)
  строка 1 переписана; открытых Q&A нет (intake NO×3, к Owner вопросов
  нет); finalize completion-pass 20:47:30; верификация 20:44:10.
  Переход Planning → Ready for Coder. Готов к CENSOR-проходу
- 2026-11-17 20:50:40 — (Role CENSOR) OK: Ready for Coder validated; current=true
Censor dispatch id: censor:planner:261117_204733
Observations:
- Second opinion: шапка перечитана с диска — `**Status:** Ready for
  Coder` (:4) = PRE_STATUS_LINE конверта, Plan ID 261117_2002 (:3) =
  имени файла; DoD D1–D13 (:190–244) — каждый пункт утверждение с
  исходом (grep/прогон/осмотр, без «по необходимости»); Tests (D1)–(D13)
  покрывают DoD 1:1 (:251–319); finalize completion-pass (:426–443,
  20:47:30, «дефектов не осталось») записан ДО простановки статуса
  (:444–451, 20:48:20); Follow-ups — два хвоста с судьбами (:502–509);
  открытых Q нет (три intake NO×3, :462–:484); обе objections
  Architect'а материализованы в секциях (D2/D6/D12 + Follow-ups
  строка 1), сами objection-строки (:482–496) append-only не тронуты.
- Counterfactuals considered: (1) тест-ожидания могли протухнуть к
  моменту CENSOR — живые прогоны 20:49: qa-format-lint в 1321 = 0,
  битые цели гайдов = 4 (9 вхождений), абсолютных ](/ = 0, C17/C18
  в backlog = 1/1, «≤ сумме» = 0 при 2 вхождениях «≤ суммы»-класса,
  счётчики row-паттерном 14/18 — все «до правок»-ожидания актуальны;
  (2) glob'ы (D2) могли не разрешаться — прямой ls из корня репо
  матчит все 5 шаблонов (первичный ноль был артефактом проверочного
  цикла с NOMATCH, не Tests; команды конвенции гоняются из корня);
  (3) слабость тестов к ложному прохождению — нашёл случай (D7) и
  починил (Fixes); (4) чужие зоны — построчная сверка с чтением до
  правок: понимание/Problem/Solution/Scope/Out of scope/Changes/
  Objections дословно нетронуты, Evidence до receipt Architect
  не изменён, хронология 20:02:00→…→20:48:20 монотонна; (5) линт
  плана — corpus: clean на дереве с правками (прогон 20:48).
- Addendum (new angle): сверил локации DoD против живых номеров строк
  носителей (getting_started :8/:48/:50/:132/:136–138, model_run :12–13,
  lifecycle:4, run.md:179, status.md:58, releases/README:30, sweep:30 —
  все grep-подтверждены в фазе work и не сдвинуты к 20:49); сверил
  (D2)-глоб против docs/reviews — review-артефакты в другом каталоге,
  grep -c по docs/plans их не задевает; usage-строка Manager'а :504
  (planner.work, dispatch 20:47:33) — зона Manager, согласована с
  dispatch id этого конверта.
- Fixes: тест (D7) усилен якорем на строку перехода —
  `grep -E '^\| .Merged. → .Done.' docs/plans/README.md | grep -c
  'harvest'` → 1 вместо слабого `grep 'harvest' ≥ 1`: слово «harvest»
  уже есть в plans/README :121/:123/:145/:231 (секция harvest de-scoped
  хвостов), слабый тест прошёл бы без правки :58 (в строке перехода
  сейчас 0, живой прогон 20:49); добавлен intake CENSOR-итерации.
- Final censor verdict: OK
- 2026-11-17 20:51:37 — Manager: Q&A чист, открытых вопросов к Owner нет, статус In progress
- 2026-11-17 22:09:03 — Manager: needs-fix-возврат (шаг 4 рутины) — Итог Round 1 review-артефакта 261117_2002: needs-fix / Artifact state current_red; live-блокер #B1 (Current state: open + Severity: S1 — гайд обещает первый линт corpus: clean на закрытом наборе, фактический прогон набора — C9 18 висячих путей + C12 missing registry, воспроизведён обоими лейнами независимо); Loop signal N/A (Round 1, lineage новый) → штатный возврат без reopened-классификации. Состав возврата: B1 (S1, дизайн-решение — расширение набора vs честная формулировка: зона Architect, диспатч микро-итерации до Coder — прецедент 0221); R2 minor (row-грамматика трёх строк материализации — зона Manager, `open ⇒ plan=none`, чиню этим шагом, fail-loud: моя ошибка материализации 20:38–20:41, класс открытых строк с plan= — контаминация формы из Solution куратора); C2 minor (subject 5835c53 «ops log» → «ops line» в резолвинг-записи 2243 — зона Coder, fixes-итерация). Stale/Rerun note: вердикты Round 1 относятся к пред-фиксному diff (17 файлов staged 21:12–21:16); реран ревью обязателен (Round 2, Rerun mode обязателен)
- 2026-11-17 20:57:00 — Coder: AC-to-test (до правок, §5): D1 — explicit
  assertion (Tests (D1): резолвинг-запись Coder'а в Suggestions log 1321 —
  первое вхождение qa-format-lint, до правок 0); D2 — explicit assertion
  (Tests (D2): cat-file 4 новых хешей → 0 отказов — самоуправно
  перепроверено 20:55–20:57: 7a668f0/51447d4/5835c53/2bc0fd7 существуют,
  782971a/3c93628/64b6622/afe047d/653cd2b MISSING, subjects сверены с
  git log -1 --format=%s; резолвинг-grep → ровно 1 на файл; git diff HEAD —
  вставки только в хвост Evidence); D3, D4, D5, D7, D8, D9, D10, D11,
  D13 — explicit assertion (команды Tests (Dn) покрывают каждый пункт);
  D6 — explicit assertion (Tests (D6): C1–C16 ≥ 1 / C1–C13 → 0; строки
  C17/C18 в backlog — предусловие теста, прочитаны живым чтением backlog
  :26/:38, Coder'ом не правятся); D12 — N/A (why=CI-зелёный на merge-пуше
  и closeout-судьбы строк — приёмка merge-гейта Manager'а (gh run list),
  вне фазы Coder по конверту диспатча; неизменность backlog/index волной
  подтверждается прогонами Tests (D12) без правок носителя — счётчики
  14/18 и «открытых — 14, закрытых — 18» сняты живым прогоном 20:57).
- 2026-11-17 21:11:08 — Coder: фаза work завершена (intake 20:52:52;
  AC-to-test 20:57:00): D1 — резолвинг-запись в Suggestions log 1321;
  D2 — 5 Evidence-резолвингов (замены верифицированы cat-file +
  subjects, append-only +5/−0); D3/D4 — getting_started (набор + скрипт
  + шаг первого линта, 7 ссылок) и model_run (2 ссылки); D5 — бюджетная
  заметка §8 в merge/closeout lifecycle; D6 — sweep C1–C16 (C17/C18 —
  предусловие Manager-материализации, не правились); D7 — harvest-
  конъюнкт plans/README; D8 — судьбы по §2 + budgets в model_run;
  D9 — «§§1–10», «гейтах», «≤ сумме» ×2 (перенос строки status.md —
  построчный счёт, семантика шага не менялась); D10 — C14/gitleaks в
  releases/README; D11 — свежие прогоны на финальном дереве 21:05–21:08:
  corpus: clean / selftest: 38/38 caught / smoke: clean; D12/D13 —
  неизменности подтверждены (AGENTS/roles diff пуст; docs/followups/
  дельта = Manager-материализация 20:38–20:41, верифицированная
  Planner'ом 20:44:10, Coder-дельты нет); метка AC-to-test до handoff
  скорректирована 21:04:40 → 20:57:00 (ошибка часов при внесении;
  фактический интервал правки 20:52:52–20:58:50; прецедент правки
  собственных фактов до стейджинга — 0427 CENSOR (г)). Changes (by
  area) и Tests «Coder run facts» заполнены. Стейджинг: 17 файлов
  (16 modified + план 2002). Переход In progress → In review
- 2026-11-17 21:15:21 — (Role CENSOR) OK: In review validated; current=true
Censor dispatch id: censor:coder:261117_211206
Observations:
- Second opinion: шапка перечитана с диска — `**Status:** In review` (:4)
  = PRE_STATUS_LINE конверта censor:coder:261117_211206, Plan ID
  261117_2002 (:3) = имени файла; DoD D1–D13 закрыты фактами «Coder run
  facts» и отражены в Changes (by area) 1:1 (D1 — 1321 :431; D2 — 5
  Evidence-резолвингов; D3/D4 — гайды; D5 — lifecycle-заметка; D6 —
  sweep :30; D7 — harvest-конъюнкт; D8 — model_run :106–112; D9 — три
  опечатки; D10 — releases/README :30; D11 — три прогона; D12/D13 —
  неизменности); AC-to-test (20:57:00) записан до заполнения Changes,
  Assumption-строк нет; стейджинг = 17 файлов состава Changes +
  Manager-материализация followups; DoD-чекбоксы `[ ]` нетронуты
  (зона Planner), Problem/Solution/Scope/Out of scope/Suggestions/
  Objections/Follow-ups плана 2002 нетронуты; в 1321 и 5 планах F4 —
  только append-only вставки в логи (Scope); Follow-ups — две строки
  с судьбами; хронология Evidence монотонна 20:02:00 → 21:11:08.
- Counterfactuals considered: (1) локации Coder run facts могли протухнуть
  после вставок — перепроверены живыми прогонами: `grep -n
  'qa-format-lint'` по 1321 → :431; резолвинг-grep glob-формой Tests →
  ровно по 1 на каждый из 5 планов; `git diff --cached --numstat` по
  6 планам → 5×(+1/−0) и 1321 (+6/−0); (2) staged мог разойтись с
  деревом — `git status --porcelain`: AM только план 2002 (intake
  CENSOR дописан после стейджинга) — рестейдж этим проходом (прецедент
  1419 «рестейдж (в)»), остальные 16 файлов — M без unstaged-хвостов;
  (3) append-only чужих планов мог быть нарушен — staged numstat:
  удалений 0 по всем шести; (4) отладочный мусор — grep TODO/FIXME/XXX
  по staged diff — пусто; (5) опечатки D9 могли остаться в других
  активных носителях — grep «гейтях|≤ суммы» по гайдам/lifecycle/
  plans-README/releases-README/README/CONTRIBUTING/sweep — пусто.
- Addendum (new angle): свежий `sh scripts/check_corpus.sh` на дереве
  с правками → `corpus: clean` (C1–C16, exit 0); коррекция метки
  AC-to-test (21:04:40 → 20:57:00) сверена с фактическими date-замерами
  20:52:52/20:58:50 — метка теперь внутри интервала правки, фиксация
  прозрачна (Evidence 21:11:08); usage-строка Manager'а 21:12:06
  (coder.work) — зона Manager, receipt её не трогает.
- Fixes: none (NO FINDINGS; искал: расхождение статуса с конвертом,
  незакрытые DoD-пункты, правки чужих зон/чекбоксов, нарушения
  append-only в 6 планах, протухшие локации фактов, рассинхрон staged
  с деревом, TODO-мусор, дрейф опечаток D9 за пределами .zcode —
  все проверены живыми прогонами, дефектов нет); стейджинг плана 2002
  рестейджнут после intake CENSOR-итерации и receipt.
- Final censor verdict: OK
- 2026-11-17 22:17:40 — Architect: микро-итерация needs-fix r1
  (live-блокер #B1, зона Architect — маршрут Evidence 22:09:03;
  статус In review не тронут, статусного перехода микрозадача не
  несёт). Дизайн-развилка F2 разрешена в Solution п.8 (append-only
  дополнение с меткой needs-fix r1): «закрытый набор» → «канон-
  каркас корпуса» — полный каркас канона минус артефакты исполнения,
  первый линт в целевом репо обязан быть зелёным. Опора — живые
  прогоны: check_c9 (носители README/AGENTS/CONTRIBUTING/SECURITY/
  roles/commands; отсутствующий носитель skip, путь существующего
  контракта обязан существовать), C12 (REQ_REGISTRY=
  docs/requirements/registry.md), smoke (C1–C16 зелёные на каркасе
  с шаблоном-планом). Отвергнуты: (б) честная переформулировка —
  ломает §8-инвариант первого merge целевого репо (цель F2);
  (а-наивный) точечное расширение перечисления — хрупко, C9-носители
  шире набора; (в-линт) fast-path C9/C12 — смена контракта вне волны.
  Fixes-итерация Coder'а идёт по Solution п.8; DoD-доводка состава
  каркаса — зона Planner (Round 2 rerun увидит финальный diff)
- 2026-11-17 22:21:10 — Planner: микро-итерация needs-fix r1 (intake
  22:16:30; статус In review не менялся — правка зон fixes-итерации).
  Доводка DoD/Tests до Solution п.8 живой симуляцией (untrusted-база —
  собственные прогоны, не память): (1) голый каркас по буквальному
  составу п.8 в TMPDIR — `corpus: 2 failures`: C9
  CONTRIBUTING:49 → dangling docs/plans/261111_2243_corpus_lint_ci.md
  (литеральная ссылка корневого контракта, code-span C9 не исключает),
  C12 — 8 rows реестра → missing планы 261112_2236/261115_2252 —
  строгое «минус артефакты исполнения» с полным реестром цель
  «clean сразу после копирования» не достигает; (2) минимальная
  зелёная комплектация: каркас + канон-пример-план 261111_2243
  (файл-цель ссылки CONTRIBUTING, сам excluded по usage/digest-cutoff)
  + пустые requirements-носители (registry с пустой секцией
  «## Требования», по аналогии с пустыми followups) → `corpus: clean`,
  FAILS=0 (прогоны 22:18–22:20). Развилка п.8 закрыта A/B-фиксацией
  (D14): форма — голый каркас, сразу после копирования; rejected
  alternatives — «каркас+шаблон-план до линта» (не закрывает C9/C12,
  шаг лишний), «полный реестр» (тянет 2 плана-артефакта, G56939 —
  контекст Planfaktor), «строго без планов» (C9 FAIL, правка
  CONTRIBUTING вне волны). Правки: D3 переписан под канон-каркас
  (состав), D4 дополнен ссылками каркас-раздела, добавлен D14
  (симуляционный критерий B1-fix с эталоном состава), Tests (D3)
  — маркеры каркаса + «закрытый набор» → 0, Tests (D14) —
  симуляция по cp-блоку гайда. C2-якорь: корень — Planner-цитата
  subject 5835c53 «ops log» (перенесена Coder'ом в резолвинг-запись
  2243:336); фактический subject — «ops line» (git log 22:15;
  историческая merge-строка 2243:334 несёт «line»); Tests (D2)
  исправлен: цитата «ops line» + проверки `grep -c 'ops log'` → 0 /
  `grep -c 'ops line'` → 2 по 2243 (fixes-итерация Coder'а: слово
  в резолвинг-строке :336 + синхронный рун-факт (D2) плана 2002).
  Решения Architect (Problem/Solution п.1–8/Scope) не менялись;
  состав каркаса и форма прогона — доводка по прямой делегации п.8
  («Planner доводит до DoD»); открытых Q нет
- 2026-11-17 22:28:30 — Coder: AC-to-test fixes-итерации r1 (до правок,
  §5; зона покрытия — DoD-пункты, затронутые needs-fix Round 1):
  D3 (доведён Planner 22:21:10 под Solution п.8) — explicit assertion
  (Tests (D3): маркеры каркаса — check_corpus|линт ≥2, corpus: clean ≥1,
  CONTRIBUTING ≥1, _template ≥1, 261111_2243 ≥1, followups|requirements
  ≥2, corpus.yml ≥1, agents ≥1, «набор файлов» → 0, «каркас» ≥1);
  D4 (дополнен ссылками каркас-раздела) — explicit assertion (Tests (D4):
  python3-обход всех относительных ссылок обоих гайдов от docs/ →
  0 битых; корневые формы ](README.md|AGENTS.md|docs/ → 0); D14 —
  explicit assertion (Tests (D14): дословное исполнение cp-блока гайда
  в свежем TMPDIR-каталоге → `sh scripts/check_corpus.sh` из копии →
  `corpus: clean`, 0 FAIL; форма — голый каркас по A/B-фиксации D14);
  D2 (finding C2 Round 1) — explicit assertion (Tests (D2) C2-якорь:
  `grep -c 'ops log'` по 2243 → 0 (до фикса 1, резолвинг-строка :336),
  `grep -c 'ops line'` → 2 (историческая merge-строка :334 + исправленная
  резолвинг-строка); резолвинг-grep → по-прежнему ровно 1 на файл;
  append-only: git diff HEAD по 2243 — замена слова внутри
  резолвинг-строки :336, исторические строки без изменений); D11 —
  explicit assertion (три свежих прогона на финальном дереве после
  правок); D12/D13 — explicit assertion (прогоны Tests без правок
  носителей: followups-дельта — R2-фикс Manager'а, AGENTS/roles diff
  пуст, selftest/smoke числа не меняются). Baseline fixes-итерации
  (прогоны 22:27–22:28): «ops log» в 2243 = 1 (:336), «ops line» = 1
  (:334) — фикс ещё не применён; «набор файлов» в getting_started = 1
  (заголовок секции) — до правки гайда
- 2026-11-17 22:38:53 — Coder: fixes-итерация r1 завершена (intake
  22:27:06; AC-to-test 22:28:30; факты — «Coder run facts, fixes-
  итерация r1», Changes дополнены): B1-fix — getting_started переписан
  под канон-каркас Solution п.8 (состав D3, cp-блок с heredoc пустых
  носителей, самодостаточность первого линта); D14 — симуляция
  установки в свежем TMPDIR: cp-блок гайда exit 0, инвентарь 48 файлов
  = эталон, `sh scripts/check_corpus.sh` из копии → `corpus: clean`,
  0 FAIL, без планов пользователя; C2-fix — 2243:336 «ops log» →
  «ops line» (ops log=0 / ops line=2, резолвинг-grep 1/файл,
  numstat +1/−0), r0-заявление о дословности subject'а скорректировано
  рун-фактом; D4 — 24 ссылки обоих гайдов, broken=0, корневых форм 0;
  D11 — corpus: clean / selftest: 38/38 caught / smoke: clean на
  финальном дереве; D12/D13 — счётчики 14/18, AGENTS/roles diff пуст,
  .zcode — только r0-опечатки. Стейджинг: 17 файлов волны (16 M/A +
  план 2002 A), unstaged-хвостов нет; unstaged R2-фикс Manager'а
  (backlog/index plan=none) застейджен с волной, контент Coder'ом не
  правился. Переход In progress → In review
- 2026-11-17 22:45:03 — (Role CENSOR) OK: In review validated; current=true
Censor dispatch id: censor:coder:261117_224102
Review verdict seen: Round 1, needs-fix (#B1 live S1, C2 minor)
Observations:
- Second opinion: шапка перечитана с диска — `**Status:** In review`
  (:4) = PRE_STATUS_LINE конверта, Plan ID 261117_2002 (:3) = имени
  файла; вердикт Round 1 перечитан в review-артефакте — :90 «Итоговый
  вердикт: needs-fix», #B1 :149–150 «Current state: open» +
  «Severity: S1», C2 :115 accepted_non_blocking_followup — fixes
  отвечают именно этим находкам: B1 → getting_started переписан под
  канон-каркас (живые grep: «набор файлов» 0, «каркас» 2,
  check_corpus|линт 7, corpus: clean 4), C2 → 2243 ops log 0 /
  ops line 2 (:334+:336); DoD D1–D14 закрыты рун-фактами r1
  («Coder run facts, fixes-итерация r1») и отражены в Changes-блоке
  r1; AC-to-test 22:28:30 записан в Evidence до узла 22:38:53
  «Changes дополнены»; Assumption-строк 0; DoD-чекбоксы `[ ]` — 14,
  нетронуты (зона Planner); стейджинг = 17 файлов волны, unstaged-хвост
  только план 2002 (intake+receipt этого прохода — рестейдж ниже,
  прецедент 1419 «рестейдж (в)»); usage-строка Manager'а 22:41:02 —
  зона Manager'а, согласована с dispatch id конверта, receipt не тронул.
- Counterfactuals considered: (1) D14 мог быть одноразовым артефактом —
  перезапущен живым рераном в новом TMPDIR (22:42): cp-блок гайда
  exit 0, инвентарь 48 файлов идентичен эталону, `sh
  scripts/check_corpus.sh` из копии → `corpus: clean`, 0 FAIL —
  воспроизводится; (2) grep TODO/FIXME/XXX по staged diff дал 2 матча —
  оба внутри прозы r0-receipt самого плана 2002 (самоописание проверки
  «grep TODO/FIXME/XXX — пусто»), по всем прочим staged-файлам — 0;
  (3) мои r1-вставки могли нести латинскую «c» в кириллице (дважды
  чинилось «правилcя») — grep «правилc» по плану → 0; (4) интервал
  прогонов в рун-фактах мог быть завышен — сверено с date-замером
  22:37:48, заголовок блока 22:27–22:37; (5) стейджинг мог разойтись
  с деревом — porcelain: 16 M + A план 2002 (+AM-хвост этого прохода),
  review-артефакт untracked — зона Manager'а на merge.
- Addendum (new angle): сверил `## Follow-ups (deferred)` с живым
  носителем backlog — строка 2 ссылалась site-redeploy
  «plan=261117_2002», а backlog:40 после R2-нормализации Round 1 несёт
  `plan=none` — рассинхрон носителей (устранён, см. Fixes); свежий
  `sh scripts/check_corpus.sh` на дереве с receipt → `corpus: clean`
  (C1–C16, exit 0); img-оговорка Planner'а (Suggestions 22:24:30)
  остаётся открытой — решение Architect, fixes-итерацией не решалась;
  python3-обход ссылок гайдов перезапущен — 24/0 битых.
- Fixes: Follow-ups строка 2 — поле plan= site-redeploy синхронизировано
  с R2-нормализованным носителем (plan=261117_2002 → plan=none,
  с пояснением об исходной формулировке 20:44); иных правок нет
  (искал: невоспроизводимый D14, отладочный мусор, тронутые чужие зоны,
  латиницу в кириллице своих записей, рассинхрон plan↔backlog —
  единственная находка устранена).
- Final censor verdict: OK
- 2026-11-18 00:53:41 — Manager: Owner-гейт merge — Owner ответил merge-указанием (чат; сопроводительно два пре-шага зоны Manager, оба исполнены до этого узла): (1) дозакрыт терминал 1419 в носителе — backlog s2-coder-status-contract `[ ]`→`[x]` при status=handled/disposition merge 9ed4cf1 (наполовину исполненный closeout 1419; носитель 14/18 = index); (2) настоящая заметка. Контроли (а): staged 17 = дословный список Итога Round 2; unstaged — план (рестейдж (в)) и backlog (пре-шаг 1, санкционирован указанием Owner); untracked — review-артефакт (санкция (в)); свежий pre-merge verify → `corpus: clean`, EXIT=0; ручной leak-контроль → 0. Review Round 2: Risk pass (0 находок) / Contracts pass / Итог pass / Artifact state current_green (#B1 historical-fixed, R2/C2 closed). Бюджетная заметка (merge-узел): текущая сумма numeric usage-строк — 42,795,368 (42.8M) → [discuss] (порог 40M пересечён записями после гейт-заметки 38.6M [warn]). Обоснование расхода (discuss, дословно из гейт-доклада): «Разбивка: 15 диспатчей (architect ×3, planner ×3, coder ×3, risk ×3, contracts ×3) — полный конвейер + полноценный fixes-раунд: B1-дизайн (Architect r1) + доводка DoD (Planner r1) + реализация (Coder r1) + Round 2 full-rerun обоих лейнов с третьей независимой репродукцией D14. Волна честно дорогая: 17 файлов, из них 6 планов append-only-резолвингом». Статус Merged
- 2026-11-18 00:53:41 — Manager: merge-коммит `9d65f5b` (`fix(261117_2002): docs wave 1 — archive integrity and user surface`, 18 файлов: staged-состав Итога Round 2 (17) + санкционированные: backlog (пре-шаг 1 — терминал s2), review-артефакт шага (в); план рестейджнут); сверка (г) — расхождений нет; рабочее дерево после — чистое
- 2026-11-18 01:00:00 — Manager: closeout, статус Done. Условия: `## Follow-ups (deferred)` заполнен (2 хвоста с судьбами); review-артефакт терминален (Round 2 `current_green`, full-rerun). Harvest по §2: (а) Follow-ups: материализация 3+2 исполнена при активации/после CENSOR (Evidence-оговорка 20:21:46); судьбы трёх open-строк — остаются открытыми (qa-format-lint v3, site-redeploy — после обеих волн, guides-link-lint v3: классы будущей работы, закрытий пачка не несла — Solution п.7); (б) открытых Q/A/objections нет; suggestion Planner'а 22:24:30 (img-рендер) → судьба open, материализована id=guides-img-renders (конвенция 1321: открытая suggestion не теряется); (в) Out of scope: п.1 вторая волна → судьба open, материализована id=docs-wave2-contract-layer; п.2 сайт → already-tracked-elsewhere (id=site-redeploy, open); п.3 append-only история — граница конвенции, не кандидат; п.4 линк-линт → already-tracked (id=guides-link-lint); п.5 push — исполнен этим циклом по санкции Owner, не кандидат. Все candidates с судьбой, lost follow-up нет. Derived index: открытых 16 (P2 +1, P3 +1), закрытых 18. Бюджетная заметка closeout: финальная сумма 42,795,368 (42.8M) → [discuss] — тождественна merge-узлу (пост-гейт записей numeric не добавлялось); обоснование — в merge-узле дословно. Хвост-коммит по конвенции §8: `chore(261117_2002): closeout tail`; далее push всего накопленного по санкции Owner

## Token usage (append-only)
<!-- owner: manager; dispatch-форма и чекпоинт-форма — грамматика шаблона -->

- 2026-11-17 20:31:43 — usage: architect.work 1573499 tokens — dispatch
- 2026-11-17 20:38:40 — usage: architect.censor 596343 tokens — sendmessage
- 2026-11-17 20:47:33 — usage: planner.work 2346014 tokens — dispatch
- 2026-11-17 20:51:37 — usage: planner.censor 1547835 tokens — sendmessage
- 2026-11-17 21:12:06 — usage: coder.work 5043960 tokens — dispatch
- 2026-11-17 21:16:21 — usage: coder.censor 1678835 tokens — sendmessage
- 2026-11-17 21:27:30 — usage: reviewer-risk.work 1989425 tokens — dispatch
- 2026-11-17 21:36:00 — usage: reviewer-contracts.work 2607193 tokens — dispatch
- 2026-11-17 21:36:00 — usage: reviewer-contracts.work unknown (why=первый резюм-хендл таймаут 600с без usage в notification, работа продолжена вторым резюмом) tokens — sendmessage
- 2026-11-17 22:09:03 — usage: reviewer-contracts.work 3664091 tokens — sendmessage
- 2026-11-17 22:14:58 — usage: architect.r1 1225579 tokens — sendmessage
- 2026-11-17 22:23:53 — usage: planner.r1 3702092 tokens — sendmessage
- 2026-11-17 22:41:02 — usage: coder.r1 6377700 tokens — dispatch
- 2026-11-17 22:47:14 — usage: coder.censor 2915655 tokens — sendmessage
- 2026-11-17 23:10:22 — usage: reviewer-risk.r1 3037984 tokens — dispatch
- 2026-11-17 23:10:22 — usage: reviewer-risk.r1 259272 tokens — sendmessage
- 2026-11-17 23:32:31 — usage: reviewer-contracts.r1 4229891 tokens — dispatch
- 2026-11-17 23:32:31 — usage: manager-context checkpoint ~14936000 tokens-left — approximate

## Q&A log (chronological, append-only)
<!-- owner: все роли; intake и Q/A-грамматика — по шаблону; кураторских Q нет: состав волны утверждён Owner («домержили, готовь») -->
- Intake (2026-11-17 20:24:10): AGENTS.md@e7ac58fe architect.md@f6cd38e4
- NO QUESTIONS
- NO SUGGESTIONS
- NO OBJECTIONS
- Intake (2026-11-17 20:36:40): AGENTS.md@e7ac58fe architect.md@f6cd38e4
  (CENSOR-итерация; digest'ы неизменны — миграционных записей не требуется)
- NO QUESTIONS
- NO SUGGESTIONS
- NO OBJECTIONS
- Intake (2026-11-17 20:41:39): AGENTS.md@e7ac58fe planner.md@f013858b
- NO QUESTIONS
- NO SUGGESTIONS
- NO OBJECTIONS
- Intake (2026-11-17 20:50:18): AGENTS.md@e7ac58fe planner.md@f013858b
  (CENSOR-итерация; digest'ы неизменны — shasum 20:48:16,
  миграционных записей не требуется)
- NO QUESTIONS
- NO SUGGESTIONS
- NO OBJECTIONS
- Intake (2026-11-17 20:52:52): AGENTS.md@e7ac58fe coder.md@4620164d
- NO QUESTIONS
- NO SUGGESTIONS
- NO OBJECTIONS
- Intake (2026-11-17 21:12:46): AGENTS.md@e7ac58fe coder.md@4620164d
  (CENSOR-итерация; digest'ы неизменны — shasum 21:12:20,
  миграционных записей не требуется)
- NO QUESTIONS
- NO SUGGESTIONS
- NO OBJECTIONS
- Intake (2026-11-17 21:17:04): AGENTS.md@e7ac58fe reviewer-risk.md@a51f0eb4
- NO QUESTIONS
- NO SUGGESTIONS
- NO OBJECTIONS
- Intake (2026-11-17 21:28:39): AGENTS.md@e7ac58fe reviewer-contracts.md@dd9bcb7a
- NO QUESTIONS
- NO SUGGESTIONS
- NO OBJECTIONS
- Intake (2026-11-17 22:14:50): AGENTS.md@e7ac58fe architect.md@f6cd38e4
  (микро-итерация needs-fix r1, блокер #B1 — зона Architect; digest'ы
  неизменны, миграционных записей не требуется; план перечитан целиком,
  статус In review сверен с маршрутом Evidence 22:09:03)
- NO QUESTIONS
- NO SUGGESTIONS
- NO OBJECTIONS
- Intake (2026-11-17 22:16:30): AGENTS.md@e7ac58fe planner.md@f013858b
  (микро-итерация needs-fix r1, зона Planner — DoD/Tests-доводка до
  Solution п.8; digest'ы неизменны — shasum 22:15:41; план и
  review-артефакт Round 1 перечитаны целиком; статус In review не
  меняется — правка зон fixes-итерации, Evidence-строкой)
- NO QUESTIONS
- NO SUGGESTIONS
- NO OBJECTIONS
- Intake (2026-11-17 22:27:06): AGENTS.md@e7ac58fe coder.md@4620164d
  (fixes-итерация needs-fix r1: live-блокер #B1 (S1, Current state:
  open) + finding C2 minor — маршрут Evidence 22:09:03, вердикты
  Round 1 review-артефакта перечитаны; digest'ы неизменны — shasum
  22:27:24, миграционных записей не требуется; статус In review сверен
  с PRE_STATUS_LINE конверта — расхождений нет, статусный переход
  In review → In progress ставится этим intake по §2)
- NO QUESTIONS
- NO SUGGESTIONS
- NO OBJECTIONS
- Intake (2026-11-17 22:41:52): AGENTS.md@e7ac58fe coder.md@4620164d
  (CENSOR-итерация fixes-r1 — конверт censor:coder:261117_224102;
  digest'ы неизменны — shasum 22:41:52, миграционных записей не
  требуется; handoff-статус In review сверен с PRE_STATUS_LINE;
  вне-зоновое изменение плана с момента handoff — usage-строка
  Manager'а 22:41:02 в ## Token usage, зона Manager'а, receipt её
  не трогает)
- NO QUESTIONS
- NO SUGGESTIONS
- NO OBJECTIONS
- Intake (2026-11-17 22:48:41): AGENTS.md@e7ac58fe reviewer-risk.md@a51f0eb4
  (реран ревью Round 2 — fixes-итерация r1 закрыта: B1-фикс getting_started
  под канон-каркас Solution п.8, C2-слово в 2243:336, R2-нормализация
  backlog-строк plan=none — зона Manager; digest'ы неизменны против intake
  Round 1 21:17:04 — shasum 22:47:40, миграционных записей не требуется;
  план и review-артефакт Round 1 перечитаны целиком; статус In review сверен
  с PRE_STATUS_LINE конверта — расхождений нет)
- NO QUESTIONS
- NO SUGGESTIONS
- NO OBJECTIONS
- Intake (2026-11-17 23:17:47): AGENTS.md@e7ac58fe reviewer-contracts.md@dd9bcb7a
  (реран contracts-лейна Round 2 — Risk Round 2 уже открыт, Rerun mode:
  full, Risk verdict Round 2: pass записан 22:57:41; digest'ы неизменны
  против intake Round 1 21:28:39 — shasum 23:17:47, миграционных записей
  не требуется; план и review-артефакт перечитаны целиком; статус
  In review сверен с PRE_STATUS_LINE конверта — расхождений нет)
- NO QUESTIONS
- NO SUGGESTIONS
- NO OBJECTIONS

## Suggestions log (chronological, append-only)
<!-- owner: все роли; несрочные улучшения -->
- 2026-11-17 22:24:30 — Planner (микро-итерация r1, доводка D3/D14):
  гайды канона несут относительные img-ссылки (getting_started :69/:112/:133,
  model_run :21+:25+:36+:44+:54+:63+:72+ — все `img/...`), а Solution п.8
  исключает docs/img из каркаса — в целевом репо GitHub-рендер гайдов
  останется без иллюстраций (линт не ловит: C9 гайды не проверяет,
  D4-обход в репо Planfaktor зелёный — img на месте). Кандидаты (решение
  Architect, волны не блокирует): оговорка в гайде «иллюстрации — в
  исходном репо Planfaktor» либо включение docs/img в каркас. blocker: no.

## Objections log (chronological, append-only)
<!-- owner: все роли; `### <Role> objections`; строка на возражение, blocker: при блокере -->
### Architect objections
- 2026-11-17 20:31:40 — Architect → Planner: кураторский DoD-черновик
  рассинхронизирован с перепринятыми зонами (прецедент 1321:334):
  D2 — «все 6 старых хешей» → фактически 5 (b53f8c5 — фантом,
  0 живых вхождений), затронуты 5 планов (1642/1943/1944 опровергнуты);
  D6 — сверх «C17» в release-notes-lint требуется правка
  index-counter-consistency → C18 (коллизия C17, Solution п.6);
  D1/D12 — «материализация 11 строк → терминальные закрытия» →
  3 новые строки + 2 правки, терминальных закрытий нет (Solution п.7).
  blocker: no — Planner переприводит DoD/Tests на фазе Planning.
- 2026-11-17 20:34:30 — Architect → Planner: кураторская строка
  `## Follow-ups (deferred)` («Материализация 11 строк при активации
  — зона Manager (Solution п.7); терминальные закрытия при closeout»)
  устарела против перепринятого Solution п.7 (3 новые строки + 2
  правки, терминальных закрытий нет) — зона coder/planner, правится
  на фазе Planning, Architect молча не правит. blocker: no

## Follow-ups (deferred)
<!-- owner: coder/planner при CENSOR; незакрытые хвосты; строка 1
     перепринята Planner'ом 20:44 (objection Architect 20:34:30:
     кураторская формулировка устарела против Solution п.7) -->
- Материализация пачки 3+2 выполнена Manager'ом 20:38–20:41
  (верифицировано Planner'ом живым чтением backlog 20:36–20:43);
  строки qa-format-lint/site-redeploy/guides-link-lint остаются open,
  терминальных закрытий волна не несёт (Solution п.7) — судьбы при
  closeout-harvest этого плана.
- Вторая волна (F5–F9 + S3.1–8 — контрактный слой) — следующий план;
  редеплой сайта после обеих волн — backlog-строка `site-redeploy`
  (open, plan=none — поле синхронизировано с R2-нормализацией Round 1,
  CENSOR fixes-r1; исходная формулировка 20:44 ссылалась на
  plan=261117_2002 до нормализации).
