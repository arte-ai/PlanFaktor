# Гигиена публичного репо: SECURITY, safety-scan, pre-merge verify, CI и README

**Plan ID:** 261113_1944
**Status:** Merged
**Created:** 2026-11-13
**Owner gates:** merge (`In review` → `Merged`); вопросы `to=Owner` — по мере возникновения

> Шапка — parser-контракт: строки выше grep'аются Manager'ом. Не менять формат.
> Имя файла: `261113_1944_public_repo_hygiene.md`.

## Как я понял задачу
<!-- owner: architect; 3–7 строк; обязательна при Architect intake -->

Репозиторий публичный (GitHub, Apache-2.0) и уже пережил инцидент с утечкой
приватных ссылок в историю; 2026-11-14 leak-контроль куратора поймал
запретный токен в Evidence на merge-гейте плана 1943 (Evidence 21:33:40) —
утечки продолжаются в живом конвейере, а машинного детектора нет; контрактом
эта защита не закрыта. План закрывает гигиену публичного репо по направлениям
брифа: SECURITY.md (канал отчётов через GitHub private vulnerability
reporting, secret/privacy-правила, плейсхолдер `<REDACTED>`), машинный
safety-scan как новый чек C14 corpus-линта (после живого C13; selftest 26/26
выросший) с selftest-кейсами и осознанным allowlist, строка о скане
публичного артефакта в CONTRIBUTING (de-hardcode счётчиков уже завершён
планом 1642 — не реинтродьюсим), pre-merge verify (свежий green линт до
merge-коммита; green ≠ семантическая приёмка; де-факто практика Manager'а
с 2121 — кодифицируем), дубликат-preflight в /planfaktor-plan против
открытых follow-up, CI-гигиена corpus.yml (permissions/concurrency/
checkout v5/матрица ОС/таймаут) с промоушеном backlog-строки id=ci-hygiene,
README (лицензия, supported verification environment — замыкает
forward-ссылку из шапки corpus.yml, ссылки) и safe-git плейбук для аварийных
git-состояний. Механики адаптированы с модели предков (приватные
первоисточники, ссылки исключены из публичного репо) под локальный
corpus-линт на POSIX sh. Соседние планы 1642/1644 смержены — их механики
(C13, самопроверки handoff) уже канон; наши правки в общих носителях
(README, AGENTS, run.md, check_corpus.sh) соседствуют с их текстами, не
перезаписывая их.

## Problem
<!-- owner: architect; пронумерованные пункты -->

1. **Нет security-политики.** SECURITY.md отсутствует (файла в корне нет;
   grep `SECURITY` по корпусу вне этого плана → только указатели на него
   в плане/review 261113_1943 (трассировка harvest), не политика): не
   определены канал отчёта об уязвимости, состав репорта, запрет
   публикации эксплойт-деталей в issues, правила обращения с секретами
   и приватными идентификаторами, канонический плейсхолдер для redaction
   и правило review публичного артефакта перед публикацией. Репо публичное
   и уже имело утечку приватных ссылок в историю — контрактом это не
   закрыто.
2. **Контент-классы утечек не ловятся машинно.** Corpus-линт (C1–C13,
   selftest 26/26) проверяет грамматику артефактов, но не содержимое:
   классы приватных путей (домашние каталоги), токенов хостинга, маркеров
   приватных ключей, Bearer-токенов и JWT-подобных значений не проверяет
   ни один чек. Контрольный прогон классов по текущему корпусу → 0
   совпадений (дерево чистое), но и детектора нет: новое попадание заметит
   только человек, либо оно уйдёт в пуш. Это не гипотеза, а живой режим:
   2026-11-14 21:33:40 (Evidence плана 261113_1943) leak-контроль куратора
   поймал запретный токен (приватное имя) в Evidence-записи на merge-гейте —
   поймал человек точечным grep'ом, машинного барьера не было; устранено
   pre-commit правкой до коммита. Класс приватных имён не входит в машинные
   классы C14 (зона направленного ручного просмотра, SECURITY.md) —
   прецедент доказывает и ценность
   постоянного машинного барьера для называемых классов, и границу C14:
   полный класс приватных идентификаторов закрывает направленный ручной
   просмотр.
3. **Скан публичного артефакта не предписан контрибьютору.** CONTRIBUTING.md
   не требует скана нового артефакта на приватные пути, ссылки на приватные
   первоисточники и секрет-подобные значения перед ревью (grep — 0). Репо
   публичное: каждый новый артефакт — акт публикации; сейчас это нигде
   не сказано.
4. **Линт не является pre-merge гейтом.** В
   `.zcode/commands/planfaktor-run.md` check_corpus.sh упомянут дважды
   (C11-канон usage-строк; C13-страховка грамматики review-артефакта —
   вклад смерженного 1642), но прогона перед merge-коммитом нет: контроли
   merge-рутины (после Owner-«да») — только git-контроли (diff/untracked,
   вклад 2121) и Evidence-записи; линт выполняется только CI после пуша и
   вручную. Дефект линта в момент merge обнаруживается постфактум на
   удалёнке (на merge-гейтах 2121/1943 Manager прогонял линт де-факто,
   контрактом это не закреплено). Принцип «green линта ≠ семантическая
   приёмка; текущий failure не глушится историческим green» не
   кодифицирован нигде.
5. **Нет дубликат-preflight при создании плана.** `/planfaktor-plan`
   создаёт план без проверки, не закрыта ли тема уже открытым follow-up
   (grep `backlog|followup` по команде → 0): механизм промоушена строк
   backlog описан в docs/plans/README.md, но триггера нет — план-дубликат
   поверх `status=open` строки размывает носители техдолга.
6. **CI-джоба без гигиены.** `.github/workflows/corpus.yml` не задаёт
   `permissions` (джоба наследует дефолтные широкие права токена) и
   `concurrency` (grep → 0 по обоим), использует actions/checkout@v4
   (аннотации GitHub о deprecated Node 20 — предмет backlog id=ci-hygiene:
   `status=open, plan=none`, не промоутирован); осознанность
   `ubuntu-latest` как движущейся ссылки на актуальный runner-образ нигде
   не зафиксирована. Шапка workflow уже ссылается на README-секцию
   supported verification environment, которой в README нет —
   forward-ссылка не замкнута.
7. **README не называет лицензию и окружение верификации.** LICENSE
   (Apache-2.0) существует, но из README не ссылается (grep
   `LICENSE|Apache` по `*.md` → 0); нет секции supported verification
   environment (канон — локальный POSIX sh и стандартные grep/sed; CI —
   hosted-приближение) и ссылок на SECURITY.md/CONTRIBUTING.md.
8. **Аварийные git-состояния не покрыты.** Работа идёт в рабочем дереве
   main без веток (§8), но detached HEAD, незавершённый rebase, вопрос
   «что уже запушено», осознанный amend/force и восстановление потерянного
   коммита через reflog не описаны нигде: docs/playbooks/ после мерджей
   2121/1943 содержит пять плейбуков (manual_terminal_recovery,
   manager_snapshot_restart, contract_edit_invariant_map, doc_gardening,
   docs_canon_sweep) — все про восстановление/гигиену конвейера и канона,
   git-аварий не покрывает ни один; субагент в аварийном состоянии не
   имеет рецептов.

## Solution / Decisions
<!-- owner: architect; решения уровня «что и почему», без детализации -->

1. **SECURITY.md — новый корневой носитель политики.** Секции: (а) отчёт
   об уязвимости — через GitHub private vulnerability reporting репозитория
   arte-ai/PlanFaktor, с запретом публиковать эксплойт-детали, секреты
   и рабочий путь атаки в публичных issues и составом полезного репорта
   (затронутые файлы/версия, ожидаемое воздействие, безопасные шаги
   воспроизведения, минимальная митигация); (б) secret/privacy handling —
   запрет коммитить секреты, токены, cookies, приватные хостнеймы,
   приватные пути и приватные идентификаторы провайдерных сессий;
   канонический плейсхолдер `<REDACTED>` (живых значений под маскировкой
   в корпусе нет; единственное упоминание лексики — 261113_1943:284,
   описание маскирования в snapshot-плейбуке, не значение; вводится этой
   политикой как канон, миграции не требуется; плейсхолдер без payload —
   C14 не матчится, консистентно с п.2);
   разграничение: публичные операционные идентификаторы (Plan ID,
   dispatch/CENSOR id) — легальная публичная evidence, приватные
   (provider user/session/SID/thread id, креды) — редактируются до
   публикации; замороженная история и evidence не переписываются (§5
   append-only) — защита действует вперёд, не ретроспективно; (в) public
   artifact review — перед публикацией нового артефакта скан на приватные
   пути, ссылки на приватные первоисточники и секрет-подобные значения;
   автоскан (C14) помогает, но не заменяет направленный ручной просмотр
   финального артефакта. Включение самой фичи private vulnerability
   reporting в настройках репозитория — действие Owner на площадке, вне
   файлового корпуса; SECURITY.md фиксирует канал.
2. **C14 safety-scan в corpus-линте.** Новый чек — следующий свободный
   номер после живого C13 (план 261113_1642 смержен, C13 в линте; других
   претендентов на C14 в очереди нет): POSIX grep
   по фиксированному списку поверхностей корпуса (docs/, .zcode/,
   scripts/, .github/workflows/, корневые README.md, AGENTS.md,
   CONTRIBUTING.md, SECURITY.md, LICENSE — прецедент явного списка
   источников C9) на классы: приватные пути — домашние каталоги
   `/(Users|home)/` с обязательным сегментом имени пользователя; токены
   хостинга — два префиксных класса с телом; маркеры PEM-блоков приватных
   ключей; Bearer-токены; JWT-подобные значения по префиксному классу.
   Точные ERE, пороги длины и якоря — зона Planner/Coder (прецедент
   формулировки 1642); принцип: паттерн требует значащий payload (сегмент
   имени/тело токена), чтобы документационные плейсхолдеры `<...>` и
   `<REDACTED>` не матчились — это минимизирует allowlist. Selftest:
   кейсы C14 на синтетически сгенерированных строках (повторённые
   символы, не живые значения и не литеральные тела в исходнике — иначе
   линт поймает собственный selftest); итоговый счётчик растёт с текущих
   26. CI покрывается автоматически — corpus.yml уже гоняет обе команды.
3. **Allowlist C14 — явный, default deny.** По прецеденту существующих
   исключений линта (case-плейсхолдеры C9, `<!--`-фильтр C5/C11/C12):
   таблица `путь|класс` с обоснованием каждой записи; попадание вне
   allowlist — FAIL. Ожидаемые стартовые записи: сам
   `scripts/check_corpus.sh` для классов, чьи определения само-матчатся,
   и — при неизбежности — строки фикстур. Описание классов в
   SECURITY.md/CONTRIBUTING ведётся формулировками без триггерных
   литералов, чтобы не расширять allowlist.
4. **CONTRIBUTING: скан публичного артефакта; инвариант de-hardcode.**
   В секцию «Проверки» — строка: для нового публичного артефакта перед
   ревью — скан на приватные пути, ссылки на приватные первоисточники
   и секрет-подобные значения (машинная часть — C14, решающая —
   направленный просмотр). De-hardcode литеральных счётчиков уже завершён
   планом 261113_1642 (строки 79–80 без чисел, литералы `C1–C12|15/15` —
   0): наш вклад — инвариант «при добавлении C14 литеральные числа чеков
   и selftest в CONTRIBUTING не реинтродьюсятся» (действующие
   формулировки «все чеки линта»/«все кейсы caught» уже
   число-независимы и переживают C14 без правки); исторические T-факты
   прошлых планов не переписываются (append-only).
5. **Pre-merge verify: инвариант в §8, механика в команде** (анти-дрейф:
   конституция — инвариант, механика — команда). AGENTS §8 дополняется:
   merge-коммит делается только при свежем green-прогоне corpus-линта;
   green линта ≠ семантическая приёмка (семантику подтверждают два
   pass-вердикта review и Owner-гейт); текущий failure не глушится
   историческим green — прогон всегда свежий, по актуальному дереву.
   Механика — шаг 4 `/planfaktor-run` (pass-ветка, merge-рутина после
   Owner-«да»): свежий `sh scripts/check_corpus.sh` добавляется в контроли
   до коммита — сосед git-контролей (а) и untracked-гэпа 2121, до
   Evidence-записей (б) и коммита из staged-индекса (в); итог не
   `corpus: clean` → стоп без коммита (fail loud, §6; чинится или
   возвращается роли). Де-факто практика Manager'а на merge-гейтах с 2121
   (в т.ч. инцидентный прогон 1943) — контрактом не закреплена, план
   кодифицирует. Факт прогона входит в существующий Evidence-узел
   merge-коммита (§1(a)) — write-surface §1 не расширяется.
   Синхронизация: docs/lifecycle.md — фраза о pre-merge verify в описании
   merge-гейта.
6. **Дубликат-preflight в /planfaktor-plan.** Новый шаг до создания файла
   плана: grep по docs/followups/backlog.md (id= и ключевые слова темы)
   и docs/plans/; тема уже открыта follow-up'ом (`status=open`) →
   план-дубликат не создаётся — Manager предлагает Owner промоушен строки
   (`plan=<PlanID>`, `status=promoted`; row-грамматика уже существует);
   тема покрыта активным планом — доложить Owner без создания. Это рутина
   команды, не новый гейт конституции: §2 не меняется.
7. **CI-гигиена corpus.yml.** Top-level `permissions: contents: read`;
   `concurrency` группой workflow+ref с `cancel-in-progress: true`
   (сверхнабегающие прогоны того же ref снимаются); actions/checkout
   v4 → v5 (закрывает аннотации deprecated Node 20); примечание об
   `ubuntu-latest`: движущаяся ссылка на актуальный runner-образ GitHub —
   пин раннер-образа не вводим, осознанность фиксируется комментарием
   в workflow и фразой в README (п.8). Forward-ссылка шапки workflow на
   README-секцию supported verification environment замыкается п.8.
   Промоушен backlog-строки
   id=ci-hygiene: `[x]`, `status=promoted`, `plan=261113_1944` (в
   staged-наборе этого плана, прецедент 261112_2236), derived
   docs/followups/index.md пересобирается, руками не правится;
   терминальное закрытие строки (`status=handled` с disposition на
   workflow-файл) — малая доки-правка после merge по CONTRIBUTING.
8. **README: лицензия и supported verification environment.** Секция
   «Лицензия» — Apache-2.0 со ссылкой на существующий LICENSE. Секция об
   окружении верификации: каноническое окружение — локальный POSIX sh
   и стандартные grep/sed (линт и selftest прогоняются там же); линт
   запускается из корня репо — прогон из другого каталога даёт ложный C9
   на macOS (cwd-чувствительность подтверждена CI-анализом Owner
   с реальными прогонами; CI всегда выполняется из корня, поэтому не
   блокер — канон фиксируется README-строкой из Scope); CI (матрица
   ubuntu-latest + macos-latest, п.11) — hosted-приближение к канону,
   «зелёный CI — не
   hosted-run result»: конфигурация и бейдж не заменяют локальный прогон
   и не являются семантической приёмкой (согласовано с п.5). Ссылки на
   SECURITY.md и CONTRIBUTING.md. Граница против CONTRIBUTING
   «Окружение»: там — рабочее окружение конвейера (ZCode-сессии, git),
   здесь — окружение верификации корпуса; дублирования нет.
9. **Safe-git плейбук docs/playbooks/git_recovery.md.** Адаптация рецептов
   модели предков под работу в main без веток: где ветка/HEAD
   (`git status -sb`, `git branch --show-current`); что уже запушено
   (`git fetch origin` + `git log --oneline origin/main..HEAD`);
   незавершённый rebase — continue после резолва / abort / skip (редко,
   осознанно); detached HEAD — вернуться `git switch` либо спасти коммит
   rescue-веткой (`git switch -c rescue/<topic>`,
   `git branch rescue/<topic> <sha>`); amend/force — только осознанно
   (коммит уже в origin → переписывание истории; `--force-with-lease` —
   только по явному решению); потерянный коммит — reflog + rescue-ветка.
   Создание без персонального шаблона правомерно: трактовка §9 планом
   261112_2236 — шаблон обязателен для классов повторяющейся структуры,
   штучные носители живут без персонального шаблона (в docs/playbooks/
   шаблона нет). Ссылка на плейбук — в README «Куда дальше».
10. **Миграции и самоприменение.** План меняет контракты (AGENTS.md §8,
    `.zcode/commands/*`) — по §3 п.7 Coder фиксирует смену digest'ов
    старый@8hex → новый@8hex в Evidence; полный прогон линта и selftest —
    регрессионный инвариант (corpus: clean, selftest — все кейсы caught);
    SECURITY.md и CONTRIBUTING.md добавляются в список источников C9 —
    их относительные ссылки валидируются линтом.
11. **CI-матрица ОС + таймаут джобы.** Corpus-джоба получает
    `strategy.matrix` по `os: [ubuntu-latest, macos-latest]` с
    `fail-fast: false` и `timeout-minutes: 10` — гейт против
    360-минутного дефолта GitHub Actions. Почему обе ОС: macOS —
    каноническое окружение Owner'а (README-секция из п.8 объявляет канон
    «локальный POSIX sh + стандартные grep/sed»), а матрица бесплатно
    ловит BSD/GNU-расхождения тулчейна: известные нестрогие места линта
    (`grep -o` ×6, `\<` в test ×9) подтверждённо работают на обоих,
    прогоны под dash и bash-as-sh идентично зелёные (CI-анализ Owner
    с реальными прогонами). `macos-latest` — такая же движущаяся ссылка
    на runner-образ, как `ubuntu-latest`: осознанность фиксируется тем же
    комментарием в workflow (расширение п.7, второго примечания не
    требуется). Матрица не добавляет новой функциональности — это
    усиление уже правимой в этом плане джобы (corpus.yml в Scope
    с п.7).

## Scope
<!-- owner: architect (границы), planner (уточняет); список изменений; пункты, реализующие внешние требования, несут метку [R: <ID>] (ID — из docs/requirements/registry.md) -->

- SECURITY.md — новый файл: канал отчётов (GitHub private vulnerability
  reporting, репозиторий arte-ai/PlanFaktor), состав репорта, запрет
  эксплойт-деталей в issues, secret/privacy handling с плейсхолдером
  `<REDACTED>` и разграничением публичных операционных id / приватных
  provider id, правило review публичного артефакта, принцип «история не
  переписывается».
- scripts/check_corpus.sh — чек C14 (safety-scan по фиксированным
  поверхностям; ERE-классы без живых значений; payload-принцип паттернов)
  + allowlist `путь|класс` с обоснованиями + selftest-кейсы C14 на
  синтетике + рост счётчика selftest; C9: источники += SECURITY.md,
  CONTRIBUTING.md.
- .github/workflows/corpus.yml — `permissions: contents: read`;
  `concurrency` (workflow+ref, cancel-in-progress); actions/checkout
  v4 → v5; примечание об ubuntu-latest; strategy.matrix os
  [ubuntu-latest, macos-latest] с fail-fast: false; timeout-minutes: 10;
  macos-latest покрывается тем же примечанием о движущейся ссылке
  (п.11).
- CONTRIBUTING.md — строка о скане нового публичного артефакта перед
  ревью (приватные пути / ссылки на приватные первоисточники /
  секрет-подобные значения); de-hardcode уже завершён планом
  261113_1642 — здесь только инвариант: литеральные числа чеков и
  selftest-счётчика не реинтродьюсируются при C14.
- AGENTS.md — §8: инвариант pre-merge verify (свежий green линт до
  merge-коммита; green ≠ семантическая приёмка; исторический green не
  глушит текущий failure); миграция digest §3 п.7 — в Evidence этого
  плана.
- .zcode/commands/planfaktor-run.md — шаг 4 (pass-ветка): свежий
  `sh scripts/check_corpus.sh` до merge-коммита; не-clean → стоп fail
  loud; факт прогона в Evidence merge-узла.
- .zcode/commands/planfaktor-plan.md — дубликат-preflight до создания
  плана (grep backlog + docs/plans; открытый follow-up → предложение
  промоушена вместо дублирующего плана).
- docs/lifecycle.md — синхронная фраза о pre-merge verify в merge-гейте.
- README.md — секция «Лицензия» (Apache-2.0 → LICENSE); секция supported
  verification environment (POSIX sh + grep/sed; CI-матрица ОС —
  hosted-приближение; зелёный CI — не hosted-run result); ссылки на
  SECURITY.md/CONTRIBUTING.md; ссылка на git-плейбук; строка о запуске
  линта из корня репо.
- docs/playbooks/git_recovery.md — новый safe-git плейбук (HEAD/ветка;
  запушено; rebase continue/abort/skip; detached HEAD/rescue;
  amend/force осознанно; reflog).
- docs/followups/backlog.md — строка id=ci-hygiene: `[x]`,
  `status=promoted`, `plan=261113_1944`; docs/followups/index.md —
  пересборка (derived).
- Fan-out инвентарь (самоприменение §5 — план меняет shared-контракты:
  AGENTS.md, `.zcode/commands/*`, `scripts/check_corpus.sh`):
  изменяемые носители — перечислены выше (9 правимых + 2 новых:
  SECURITY.md, docs/playbooks/git_recovery.md); зависимые проверки —
  полный прогон `scripts/check_corpus.sh` зелёный после каждого класса
  правок (C1–C13 не деградируют), selftest растёт и зелёный, C9 — новые
  источники SECURITY.md/CONTRIBUTING.md валидируются линтом, CI
  corpus.yml гоняет обе команды на обоих runner-образах матрицы;
  зависимые доки — README.md, docs/lifecycle.md, CONTRIBUTING.md (в этом
  же скоупе), docs/followups/index.md (derived-пересборка);
  известные consumer-пути — `/planfaktor-run` merge-рутина (новый
  pre-verify-контроль вживается в неё), `/planfaktor-plan` (новый
  preflight-шаг), Owner/конрибьюторы (README/CONTRIBUTING/SECURITY —
  точки входа), CI на каждый push/PR.
- Носители: этот план + review-артефакт
  docs/reviews/261113_1944_review.md.

## Out of scope
<!-- owner: architect -->

- Границы с 261113_1642 (смержен, a53592b): его механики — канон, не
  трогаем: чек C13 (живой в линте), C13-страховку ревью-грамматики в
  planfaktor-run, AGENTS §2/§4/§6, review-шаблон, роль-доки, needs-fix
  финалики README. В planfaktor-run наш вклад — только контроли
  pass-ветки merge-рутины (pre-verify), needs-fix ветка — зона 1642.
- Границы с 261113_1644 (смержен, 8274d86): не трогаем AGENTS §2/§4/§5
  (самопроверки handoff), роль-доки planner/coder/architect, шаблоны
  плана/ревью; CONTRIBUTING/README у 1644 были в Out of scope — наши
  правки там не пересекаются с его вкладом.
- Переписывание git-истории и ретроспективная чистка запушенных коммитов
  (инцидент с приватными ссылками в истории): защита — только вперёд
  (C14 + правила SECURITY.md); append-only история не переписывается;
  force-push за рамками плана.
- ai_gate policy-as-config — отложено (в этот план не входит).
- Incremental lint CI (прогон только изменённых файлов / по diff-базе) —
  отложено; наш прогон полный.
- Расширение классов скана за названные брифом (email-адреса, IP, телефоны,
  приватные хостнеймы, third-party prompt-маркеры и другие классы модели
  предков) — кандидат backlog при появлении потребности.
- Машинная сверка значений digest и Q&A-грамматика (backlog
  id=lint-v2-digest-verify, id=qa-lint) — не расширяются.
- merge-untracked-guard (backlog id=merge-untracked-guard): контроль
  посторонних untracked перед коммитом уже promoted планом 261113_2121
  и реализован в merge-рутине planfaktor-run (контроль (а)); наш
  pre-merge verify ортогонален (линт vs untracked) и встраивается в тот
  же блок контролей соседним пунктом — не дублирует и не заменяет.
- Пиннование actions по SHA (практика модели предков) — не вводим: тег v5
  и минимальные права; SHA-пиннинг — кандидат follow-up при требованиях
  supply-chain.
- Шаблон docs/playbooks/_template*.md — не создаётся (штучный носитель;
  прецедент трактовки §9 планом 261112_2236).
- Настройки репозитория на GitHub (включение private vulnerability
  reporting, branch protection и т.п.) — действия Owner на площадке,
  не файловый корпус.
- Static-джоба CI (shellcheck в POSIX-режиме с disable-листом, actionlint
  по workflows, smoke-тест инстанцирования плана из
  `docs/plans/_template.md`) — backlog-строка id=ci-v2-static заведена
  (status=open, plan=none, source_ref → этот Out of scope); промоушен
  отдельным планом после merge этого; сюда не входит. База
  CI-анализа Owner: shellcheck — 43 замечания / 0 багов; actionlint —
  PASS по текущему corpus.yml; smoke-инстанцирование шаблона зелёное,
  байт-в-байт детерминистично — текущий корпус статик-хрупкости не
  показывает.

## Acceptance criteria / DoD
<!-- owner: planner; чек-лист проверяемых исходов; каждый пункт = проверяемое утверждение; пункты, реализующие внешние требования, несут метку [R: <ID>] (ID — из docs/requirements/registry.md) -->

Детализация Solution 1–11 и Scope (включая fan-out инвентарь) до проверяемых
утверждений; R-меток нет — внешние требования реестра план не реализует.
Формулировки классов C14 в этом плане сознательно без триггерных литералов
и без payload-образных примеров (Solution п.3): план — сканируемая C14
поверхность, само-матч размыл бы смысл проверки.

- [ ] **D1.** SECURITY.md — новый корневой файл политики с тремя
  подсекциями: (а) отчёт об уязвимости — канал GitHub private
  vulnerability reporting репозитория arte-ai/PlanFaktor; запрет
  публиковать эксплойт-детали, секреты и рабочий путь атаки в публичных
  issues; состав полезного репорта (затронутые файлы/версия, ожидаемое
  воздействие, безопасные шаги воспроизведения, минимальная митигация);
  (б) secret/privacy handling — запрет коммитить секреты, токены, cookies,
  приватные хостнеймы, приватные пути и приватные идентификаторы
  провайдерных сессий; канонический плейсхолдер редукции `<REDACTED>`;
  разграничение: публичные операционные идентификаторы (Plan ID,
  dispatch/CENSOR id) — легальная публичная evidence, приватные
  (provider user/session/SID/thread id, креды) — редактируются до
  публикации; принцип «замороженная история и Evidence не переписываются
  (append-only) — защита действует вперёд, не ретроспективно»; (в)
  public artifact review — перед публикацией нового артефакта скан на
  приватные пути, ссылки на приватные первоисточники и секрет-подобные
  значения: автоскан C14 помогает, но не заменяет направленный ручной
  просмотр финального артефакта (полный класс приватных идентификаторов —
  зона ручного просмотра, Problem п.2).
- [ ] **D2.** SECURITY.md и CONTRIBUTING.md формулируются без триггерных
  литералов классов C14 и без payload-образных примеров (allowlist C14
  этими файлами не расширяется); плейсхолдер `<REDACTED>` присутствует
  в SECURITY.md и не матчится C14 — доказано живым прогоном `corpus:
  clean` после ввода файла (payload-принцип D3).
- [ ] **D3.** scripts/check_corpus.sh — новый чек C14 safety-scan
  (`check_c14`, следующий номер после живого C13; вызван из run_all):
  поверхности — фиксированный явный список по прецеденту C9 (docs/,
  .zcode/, scripts/, .github/workflows/, корневые README.md, AGENTS.md,
  CONTRIBUTING.md, SECURITY.md, LICENSE); классы детекции — POSIX ERE
  по шести классам: (1) абсолютный домашний путь — префикс `/Users/`
  или `/home/` с обязательным сегментом имени пользователя (не менее 2
  латинских букв/цифр) до следующего слэша или конца токена; (2) короткий
  префиксный класс токена хостинга GitHub — префикс из «gh» + одна
  латинская буква + подчёркивание с телом не менее 20
  букв/цифр/подчёркиваний/дефисов; (3) составной префиксный класс
  fine-grained токена GitHub — префикс из имени сервиса с двумя
  подчёркиваниями-разделителями и телом не менее 20 тех же символов;
  (4) маркер заголовка PEM-блока приватного ключа канонического вида
  (пять дефисов, слово начала блока, уточнение вида ключа из семейства
  приватных, закрывающие дефисы); (5) заголовок авторизации Bearer —
  слово-схема с телом не менее 20 букв/цифр после разделителя; (6)
  JWT-подобное значение — три сегмента base64url-алфавита, разделённые
  точками, каждый сегмент не короче 10 символов, первый сегмент
  начинается с канонического префикса base64url-кодировки открывающей
  фигурной скобки JSON. Payload-принцип: каждый паттерн требует значащий
  payload — документационные плейсхолдеры `<...>`, `<REDACTED>` и
  упоминания классов в прозе без тел не матчатся (минимизация allowlist).
  Реализация ERE в скрипте — Coder; доказательство работы классов —
  selftest-кейсы D5.
- [ ] **D4.** Allowlist C14 — явная таблица записей «путь|класс», каждая
  запись с обоснованием; семантика default deny: совпадение класса вне
  allowlist — FAIL C14 с деталями; стартовые записи — сам
  scripts/check_corpus.sh для классов, чьи определения само-матчатся;
  строки фикстур — только при неизбежности, с обоснованием (прецедент
  исключений линта: case-плейсхолдеры C9, фильтр C5/C11/C12).
- [ ] **D5.** Selftest C14: не менее одного позитивного кейса на каждый
  из шести классов D3 (подсадка синтетического bait в копию поверхности)
  плюс кейс эффективности allowlist (bait в allowlisted-носителе не
  роняет C14 — прецедент exclude-кейса C13k); bait-строки —
  синтетически сгенерированные (повторённые символы, конкатенации
  префикса и синтетики), не живые значения и не литеральные тела
  в исходнике скрипта; счётчик `_st_total` синхронно вырос с 26 (итог
  `selftest: N/N caught`, exit 0, N ≥ 33); шапка-комментарий скрипта
  и комментарий run_all обновлены до C1–C14 (живые литералы старого
  счётчика `26/26`, `_st_total=26`, `C1–C13` не остаются;
  перечисление планов-источников в шапке пополняется этим планом);
  baseline-цикл selftest включает check_c14 (регрессия C14 в сторону
  ложных срабатываний ловится); негативные кейсы-плейсхолдеры
  (`<REDACTED>`, `<...>` не матчатся) — вне счётчика, abort-семантика
  (прецедент bait-чистоты C13).
- [ ] **D6.** C9: источники пополняются SECURITY.md и CONTRIBUTING.md —
  их относительные пути валидируются линтом; прочие механики C9 не
  меняются.
- [ ] **D7.** seed_corpus копирует все поверхности C14: сверх текущих
  docs/, .zcode/, README.md, AGENTS.md — CONTRIBUTING.md, SECURITY.md,
  LICENSE, scripts/, .github/workflows/ (структура корня в selftest-копии
  сохранена) — иначе кейсы C14 в копиях невоспроизводимы.
- [ ] **D8.** CONTRIBUTING.md: в секции «Проверки» — строка о скане
  нового публичного артефакта перед ревью (приватные пути, ссылки на
  приватные первоисточники, секрет-подобные значения; машинная часть —
  C14, решающая — направленный ручной просмотр); инвариант de-hardcode:
  литеральные числа чеков линта и selftest-счётчика не появляются
  (реинтродьюсция при C14 запрещена; действующие формулировки
  «все чеки линта»/«все кейсы caught» не меняются).
- [ ] **D9.** AGENTS.md §8: инвариант pre-merge verify — merge-коммит
  делается только при свежем green-прогоне corpus-линта; green линта ≠
  семантическая приёмка (семантику подтверждают два pass-вердикта review
  и Owner-гейт); текущий failure не глушится историческим green — прогон
  всегда свежий, по актуальному дереву; прочие пункты §8 не меняются,
  §2/§4/§5/§6 не трогаются (зоны 1642/1644).
- [ ] **D10.** .zcode/commands/planfaktor-run.md — шаг 4, pass-ветка
  merge-рутины: свежий `sh scripts/check_corpus.sh` входит в контроли
  (а) до коммита — сосед git-контролей и untracked-гэпа 2121, до
  Evidence-записей (б) и коммита из staged-индекса (в); итог не
  `corpus: clean` → стоп без коммита (fail loud, §6 — чинится или
  возвращается роли); факт прогона входит в существующий Evidence-узел
  merge-коммита §1(a) — write-surface §1 не расширяется; needs-fix
  ветка — зона 1642, не трогается.
- [ ] **D11.** docs/lifecycle.md: фраза о pre-merge verify в описании
  merge-гейта (синхронна D9; «Гейты Owner»/фаза `In review` → `Merged`).
- [ ] **D12.** .zcode/commands/planfaktor-plan.md: дубликат-preflight —
  новый шаг до создания файла плана: grep по docs/followups/backlog.md
  (id= и ключевые слова темы) и docs/plans/; тема уже открыта follow-up'ом
  (`status=open`) → план-дубликат не создаётся — Manager предлагает Owner
  промоушен строки (`plan=<PlanID>`, `status=promoted`; row-грамматика
  существует); тема покрыта активным планом — доложить Owner без
  создания; рутина команды, не новый гейт конституции (§2 не меняется).
- [ ] **D13.** .github/workflows/corpus.yml: top-level
  `permissions: contents: read`; `concurrency` группой workflow+ref с
  `cancel-in-progress: true`; actions/checkout v4 → v5; `strategy.matrix`
  по `os: [ubuntu-latest, macos-latest]` с `fail-fast: false`;
  `timeout-minutes: 10`; примечание-комментарий: ubuntu-latest и
  macos-latest — движущиеся ссылки на актуальный runner-образ GitHub,
  пин раннер-образа не вводим (одно примечание на оба).
- [ ] **D14.** README.md: секция «Лицензия» (Apache-2.0 со ссылкой на
  существующий LICENSE); секция об окружении верификации с фразой-якорем
  supported verification environment (замыкает forward-ссылку шапки
  corpus.yml): канон — локальный POSIX sh и стандартные grep/sed (линт
  и selftest прогоняются там же), строка о запуске линта из корня репо
  (прогон из другого каталога даёт ложный C9 на macOS); CI (матрица
  D13) — hosted-приближение к канону, «зелёный CI — не hosted-run
  result», не замена локальному прогону и не семантическая приёмка
  (согласовано D9); ссылки на SECURITY.md и CONTRIBUTING.md; ссылка на
  docs/playbooks/git_recovery.md в «Куда дальше».
- [ ] **D15.** docs/playbooks/git_recovery.md — новый safe-git плейбук
  (без персонального шаблона — прецедент трактовки §9 планом
  261112_2236) с рецептами: где ветка/HEAD (`git status -sb`,
  `git branch --show-current`); что уже запушено (`git fetch origin` +
  `git log --oneline origin/main..HEAD`); незавершённый rebase —
  continue после резолва / abort / skip (редко, осознанно); detached
  HEAD — вернуться `git switch` либо спасти коммит rescue-веткой
  (`git switch -c rescue/<topic>`, `git branch rescue/<topic> <sha>`);
  amend/force — только осознанно (коммит уже в origin → переписывание
  истории; `--force-with-lease` — только по явному решению); потерянный
  коммит — reflog + rescue-ветка.
- [ ] **D16.** docs/followups/backlog.md, строка id=ci-hygiene:
  `[ ]`→`[x]`, `status=open`→`status=promoted`,
  `plan=none`→`plan=261113_1944` (summary/id/source_ref стабильны —
  row-грамматика); docs/followups/index.md пересобран (derived, руками
  не правится): ci-hygiene в «Закрытые» с plan=261113_1944, счётчики
  согласованы; терминальное закрытие строки (`status=handled` с
  disposition) — вне этого плана (малая доки-правка после merge).
- [ ] **D17.** Миграция контрактов §3 п.7: Evidence плана фиксирует
  смену digest'ов старый@8hex → новый@8hex с меткой времени по каждому
  изменённому контракту — AGENTS.md, .zcode/commands/planfaktor-run.md,
  .zcode/commands/planfaktor-plan.md (старые digest'ы — на момент первой
  правки Coder'а; scripts/check_corpus.sh — вне списка §3 п.7, digest
  не требуется).
- [ ] **D18.** Регрессионный инвариант (fan-out инвентарь Scope): после
  каждого класса правок и в финальном срезе — `sh scripts/check_corpus.sh`
  → `corpus: clean`, exit 0 (C1–C13 не деградировали; C14 не даёт ложных
  срабатываний на живом корпусе, включая новые SECURITY.md, CONTRIBUTING.md,
  README.md и сам этот план); `sh scripts/check_corpus.sh --selftest` →
  все кейсы caught, exit 0; прогоны — в Evidence.
- [ ] **D19.** Out of scope чист: механики 1642 (чек C13, needs-fix
  ветка run.md, AGENTS §2/§4/§5/§6, review-шаблон, роль-доки) и 1644
  (самопроверки handoff, роль-доки planner/coder/architect, шаблоны)
  не тронуты; git-история не переписана (правки только вперёд, без
  amend/force); состав staged-изменений = дословно носители Scope
  (12 файлов: SECURITY.md, scripts/check_corpus.sh,
  .github/workflows/corpus.yml, CONTRIBUTING.md, AGENTS.md,
  .zcode/commands/planfaktor-run.md, .zcode/commands/planfaktor-plan.md,
  docs/lifecycle.md, README.md, docs/playbooks/git_recovery.md,
  docs/followups/backlog.md, docs/followups/index.md) + сам план;
  review-артефакт создаётся при In review и вне staged до вердиктов.

## Tests / Commands
<!-- owner: planner (задаёт), coder (заполняет факт); каждый DoD-пункт (Dn) покрывается строкой с меткой (Dn); R-DoD — обязательно; при переименованиях/миграциях терминологии — narrow + broad proof: narrow — exact-паттерн нового wording (база «сейчас 0», если якорь различающий), broad — prose-drift старого токена по всем активным носителям с классификацией вхождений (исторические планы и append-only артефакты исключены — там старое имя остаётся вечно) -->

Команды воспроизводимы из корня репо; R-меток в плане нет (внешние
требования реестра план не реализует — R-DoD отсутствуют, проверка
трассируемости вырождена корректно, прецедент 1642). Базы «сейчас» сняты
grep'ом по дереву 2026-11-14 22:19–22:25 (Planner).

- **T1** (D3, D6, D18): ``sh scripts/check_corpus.sh`` → вывод содержит
  `OK C14 <имя чека>` (имя — по факту Coder'а, в run_all после C13),
  все проверки OK, итог `corpus: clean`, exit 0.
- **T2** (D5): ``sh scripts/check_corpus.sh --selftest`` →
  `selftest: N/N caught`, exit 0, N ≥ 33; вывод содержит не менее 7 строк
  `caught C14` (шесть классов D3 + allowlist-кейс);
  ``grep -c '_st_total=' scripts/check_corpus.sh`` → 1, значение = N;
  ``grep -nE '_st_total=26|26/26|C1–C13' scripts/check_corpus.sh`` → 0
  (база: 4 живых вхождения — строки 26, 27, 1152, 1206).
- **T3** (D1), файл SECURITY.md: ``test -f SECURITY.md`` → да (база:
  нет); ``grep -c 'private vulnerability reporting' SECURITY.md`` → ≥ 1;
  ``grep -c 'REDACTED' SECURITY.md`` → ≥ 1;
  ``grep -cE 'эксплойт|воспроизвед|митигац' SECURITY.md`` → ≥ 3 (запрет
  публикации + состав репорта);
  ``grep -cE 'истори|append-only' SECURITY.md`` → ≥ 1 (принцип «защита
  вперёд»); ``grep -cE 'Plan ID|dispatch' SECURITY.md`` → ≥ 1
  (разграничение публичных операционных id); осмотр: три подсекции
  (отчёт / secret-privacy / public artifact review).
- **T4** (D2, D18): связка — при ``grep -c 'REDACTED' SECURITY.md`` ≥ 1
  прогон T1 даёт `corpus: clean`: C14 не матчит плейсхолдер
  `<REDACTED>` в живом носителе (payload-принцип доказан не только
  selftest-кейсом).
- **T5** (D3, D6): ``grep -c 'check_c14' scripts/check_corpus.sh`` → ≥ 4
  (определение, run_all, baseline-список, кейсы);
  ``grep -n 'report C14' scripts/check_corpus.sh`` → 1;
  ``grep -cE 'CONTRIBUTING|SECURITY' scripts/check_corpus.sh`` → ≥ 4
  (база: 0; C9-источники + C14-поверхности);
  ``grep -c 'LICENSE' scripts/check_corpus.sh`` → ≥ 1 (база: 0;
  поверхность C14).
- **T6** (D4): ``grep -nE 'allowlist' scripts/check_corpus.sh`` → ≥ 2
  (таблица + применение); осмотр: каждая запись allowlist C14 несёт
  обоснование; default deny подтверждён позитивными кейсами T2
  (bait вне allowlist роняет) и allowlist-кейсом (bait внутри не
  роняет).
- **T7** (D7): ``sed -n '/^seed_corpus()/,/^}/p' scripts/check_corpus.sh``
  → копирование расширено: в теле функции присутствуют CONTRIBUTING.md,
  SECURITY.md, LICENSE, scripts/, .github/ (база: функция копирует
  только docs/, .zcode/, README.md, AGENTS.md);
  ``grep -cE 'LICENSE|\.github' scripts/check_corpus.sh`` → ≥ 2
  (база: 0).
- **T8** (D9): ``grep -n 'pre-merge verify' AGENTS.md`` → ≥ 1 (база: 0),
  в §8; ``grep -c 'семантическая приёмка' AGENTS.md`` → ≥ 1;
  ``grep -cE 'свежий' AGENTS.md`` → ≥ 1 в §8 (прогон всегда свежий);
  осмотр: правка AGENTS.md ограничена §8.
- **T9** (D10): ``grep -c 'check_corpus' .zcode/commands/planfaktor-run.md``
  → 3 (база: 2); ``grep -n 'corpus: clean' .zcode/commands/planfaktor-run.md``
  → ≥ 1 (база: 0); ``grep -nE 'стоп без коммита' .zcode/commands/planfaktor-run.md``
  → ≥ 1; осмотр: новый прогон — в контроле (а) merge-рутины шага 4,
  до (б)/(в); needs-fix ветка не тронута.
- **T10** (D11): ``grep -c 'pre-merge verify' docs/lifecycle.md`` → ≥ 1
  (база: 0); осмотр: фраза — в описании merge-гейта.
- **T11** (D12): ``grep -c 'backlog' .zcode/commands/planfaktor-plan.md``
  → ≥ 2 (база: 0);
  ``grep -nE 'status=open|promot' .zcode/commands/planfaktor-plan.md``
  → ≥ 2; ``grep -nE 'дубликат|preflight' .zcode/commands/planfaktor-plan.md``
  → ≥ 1; осмотр: шаг расположен до создания файла плана (до текущего
  шага 3), §2 конституции не меняется.
- **T12** (D13), файл .github/workflows/corpus.yml:
  ``grep -c 'permissions:' .github/workflows/corpus.yml`` → ≥ 1 (база:
  0); ``grep -c 'contents: read' .github/workflows/corpus.yml`` → ≥ 1;
  ``grep -c 'concurrency:' .github/workflows/corpus.yml`` → ≥ 1;
  ``grep -c 'cancel-in-progress' .github/workflows/corpus.yml`` → ≥ 1;
  ``grep -c 'checkout@v5' .github/workflows/corpus.yml`` → 1 и
  ``grep -c 'checkout@v4' .github/workflows/corpus.yml`` → 0 (база: 1);
  ``grep -c 'matrix:' .github/workflows/corpus.yml`` → ≥ 1;
  ``grep -c 'macos-latest' .github/workflows/corpus.yml`` → ≥ 2 (база:
  0; матрица + примечание); ``grep -c 'fail-fast: false' .github/workflows/corpus.yml``
  → ≥ 1; ``grep -c 'timeout-minutes: 10' .github/workflows/corpus.yml``
  → ≥ 1; ``grep -c 'движущ' .github/workflows/corpus.yml`` → ≥ 1 (база:
  0; примечание о движущейся ссылке runner-образов); осмотр:
  permissions — top-level, группа concurrency — workflow+ref.
- **T13** (D14), файл README.md: ``grep -c 'Лицензия' README.md`` → ≥ 1
  (база: 0); ``grep -c 'Apache-2.0' README.md`` → ≥ 1 (база: 0);
  ``grep -c 'supported verification environment' README.md`` → ≥ 1
  (база: 0; замыкает forward-ссылку шапки corpus.yml — осмотр пары);
  ``grep -c 'SECURITY.md' README.md`` → ≥ 1 (база: 0);
  ``grep -c 'CONTRIBUTING.md' README.md`` → ≥ 1;
  ``grep -c 'git_recovery.md' README.md`` → ≥ 1;
  ``grep -nE 'из корня репо' README.md`` → ≥ 1;
  ``grep -c 'POSIX' README.md`` → ≥ 1 (база: 0; канон окружения);
  ``grep -cE 'hosted|CI' README.md`` → ≥ 1 (граница «зелёный CI — не
  hosted-run result»).
- **T14** (D15): ``test -f docs/playbooks/git_recovery.md`` → да (база:
  нет);
  ``grep -cE 'status -sb|branch --show-current' docs/playbooks/git_recovery.md``
  → ≥ 2; ``grep -c 'origin/main..HEAD' docs/playbooks/git_recovery.md``
  → ≥ 1; ``grep -cE 'reflog|rescue/' docs/playbooks/git_recovery.md``
  → ≥ 2; ``grep -c 'force-with-lease' docs/playbooks/git_recovery.md``
  → ≥ 1; ``grep -cE 'rebase' docs/playbooks/git_recovery.md`` → ≥ 1;
  ``grep -cE 'continue|abort|skip' docs/playbooks/git_recovery.md``
  → ≥ 2.
- **T15** (D16): ``grep 'id=ci-hygiene' docs/followups/backlog.md`` →
  строка несёт `[x]`, `status=promoted`, `plan=261113_1944` (база:
  `[ ]`, `status=open`, `plan=none`; summary/id/source_ref неизменны —
  осмотр);
  ``grep -n 'ci-hygiene' docs/followups/index.md`` → вхождения только в
  «Закрытые» с plan=261113_1944; счётчик строк «Счётчик:» согласован
  (база: открытых — 11, закрытых — 1 → 10/2, осмотр).
- **T16** (D19): ``git diff --name-only HEAD -- docs/roles/ docs/plans/_template.md docs/reviews/_template_review.md``
  → пусто (зоны 1642/1644; diff против HEAD покрывает staged+unstaged
  tracked-изменения — unstaged-diff после стейджинга Coder'а слеп к
  staged-правкам);
  ``git diff --name-only HEAD -- docs/plans/`` → пусто (план 1944
  untracked — в diff против HEAD не входит, его стейджинг учитывает T18;
  другие планы не изменены);
  ``git log --oneline origin/main..HEAD`` → пусто (история не
  переписана, коммитов Coder'а нет — база: HEAD = origin/main);
  осмотр diff run.md: изменения только в pass-ветке контролей (а).
- **T17** (D17): ``grep -cE '@[0-9A-Fa-f]{8} → @[0-9A-Fa-f]{8}' docs/plans/261113_1944_public_repo_hygiene.md``
  → ≥ 3 (миграционные записи §3 п.7: AGENTS.md, run.md, plan.md; после
  правок Coder'а).
- **T18** (D19): ``git diff --cached --name-only`` → ровно 13 файлов:
  12 носителей D19 + сам план — осмотр против перечня Scope.
- **T19** (D18, гейт Manager при `In review`/`Merged`): после создания
  `docs/reviews/261113_1944_review.md` (Round 1, грамматика C13):
  ``sh scripts/check_corpus.sh`` → `corpus: clean` (самоприменение:
  план и review-артефакт — поверхности C14 и не матчатся; артефакт
  ≥ cutoff проходит C13).
- **T20** (D2, D8), файл CONTRIBUTING.md:
  ``grep -nE 'скан' CONTRIBUTING.md`` → ≥ 1 (база: 0);
  ``grep -c 'C14' CONTRIBUTING.md`` → ≥ 1 (база: 0; машинная часть
  скана); ``grep -cE 'реинтродьюц|литеральн' CONTRIBUTING.md`` → ≥ 1
  (инвариант de-hardcode);
  ``grep -cE '[0-9]+/[0-9]+ caught|[0-9]+ чеков линта' CONTRIBUTING.md``
  → 0 (литеральные числа чеков/счётчика не реинтродьюсируются; база: 0 —
  инвариант удержания).

## Changes (by area)
<!-- owner: coder; фактические изменения по областям; заполняется в ходе работы -->

- **scripts/check_corpus.sh** (D3–D7): новый чек C14 safety-scan — `check_c14`
  (поверхности — фиксированный явный список docs/, .zcode/, scripts/,
  .github/workflows/ + корневые README.md, AGENTS.md, CONTRIBUTING.md,
  SECURITY.md, LICENSE; несуществующая поверхность пропускается по `[ -e ]`),
  хелперы `_c14_re_of` (шесть POSIX ERE с payload-принципом: home-path
  `/Users`/`/home` + сегмент имени ≥2 букв-цифр; gh-token `gh`+буква+`_`
  + тело ≥20; gh-pat `github_pat_` + тело ≥20; pem-key маркер приватного
  ключа канонического вида; bearer схема+тело ≥20 букв-цифр; jwt три
  base64url-сегмента ≥10 с JSON-префиксом) и `_c14_allowed`; allowlist
  `C14_ALLOWLIST` (default deny, формат `путь|класс`, обоснование
  комментарием; единственная стартовая запись
  `scripts/check_corpus.sh|gh-token` — why: единственный легальный
  bait-носитель selftest-кейса C14g по прецеденту exclude-кейса C13k +
  страхование эволюции собственных описаний; определения остальных
  классов само-матча не дают — проверено прогоном по живому дереву, 0
  совпадений по шести классам, поэтому allowlist не расширялся); C14
  добавлен в run_all после C13 (`report C14 safety-scan`); C9-источники
  += CONTRIBUTING.md, SECURITY.md; seed_corpus копирует CONTRIBUTING.md,
  SECURITY.md, LICENSE, scripts/, .github/ (структура корня сохранена);
  selftest: baseline-цикл += check_c14, `_st_total` 26→33, новые кейсы
  C14a–C14f (синтетический bait шести классов через репитер `_st14_rep`
  — повторённые символы конкатенациями, литеральных тел в исходнике нет)
  и C14g (bait в копии allowlisted-носителя не роняет); шапка-комментарий:
  перечень планов-источников += 261113_1944, описания selftest и run_all
  обновлены до C1–C14 и 33/33.
- **SECURITY.md** (D1, D2): новый корневой файл политики — три подсекции:
  «Как сообщить об уязвимости» (канал GitHub private vulnerability
  reporting репозитория arte-ai/PlanFaktor; запрет публикации
  эксплойт-деталей/секретов/рабочего пути атаки в публичных issues;
  состав репорта: затронутые файлы/версия, ожидаемое воздействие,
  безопасные шаги воспроизведения, минимальная митигация), «Секреты и
  приватные данные» (запрет коммитить секреты/токены/cookies/приватные
  хостнеймы/пути/идентификаторы сессий; плейсхолдер `<REDACTED>`;
  разграничение публичных операционных id (Plan ID, dispatch/CENSOR id)
  и приватных provider id; append-only история не переписывается —
  защита вперёд, ссылка на backlog id=history-secret-audit), «Обзор
  публичного артефакта перед публикацией» (скан на приватные пути,
  ссылки на приватные первоисточники, секрет-подобные значения; C14
  помогает, но не заменяет направленный ручной просмотр). Формулировки
  без триггерных литералов — файл allowlist не расширяет (прогон
  шести классов по файлу — 0).
- **CONTRIBUTING.md** (D8, D20): в «Проверки» — скан-строка нового
  публичного артефакта перед ревью (приватные пути / ссылки на приватные
  первоисточники / секрет-подобные значения; машинная часть — C14,
  решающая — направленный ручной просмотр, ссылка на SECURITY.md) и
  инвариант de-hardcode (литеральные числа чеков и selftest-счётчика
  не реинтродьюсируются; de-hardcode — план 261113_1642, инвариант —
  этот план).
- **AGENTS.md** (D9): §8 — новый пункт-инвариант pre-merge verify
  (merge-коммит только при свежем green-прогоне corpus-линта; green ≠
  семантическая приёмка — семантику подтверждают два pass-вердикта
  review и Owner-гейт; текущий failure не глушится историческим green);
  прочие пункты §8 и остальные секции не тронуты. Миграция §3 п.7 —
  в Evidence (22:51:29).
- **.zcode/commands/planfaktor-run.md** (D10): шаг 4, pass-ветка,
  контроль (а) merge-рутины — новый пункт после untracked-контроля
  2121 и до «иное нарушение контроля»: свежий `sh scripts/check_corpus.sh`
  из корня репо, итог обязан быть `corpus: clean`, не-clean → стоп без
  коммита (fail loud, §6), факт прогона — в Evidence merge-узла шага (б);
  needs-fix ветка и остальные упоминания check_corpus не тронуты.
- **.zcode/commands/planfaktor-plan.md** (D12): новый шаг 3 —
  дубликат-preflight до создания файла плана (grep docs/followups/
  backlog.md по `id=` и ключевым словам + docs/plans/; открытый
  follow-up `status=open` → предложение Owner промоушена строки
  `status=promoted`, `plan=<PlanID>` вместо дублирующего плана; тема
  покрыта активным планом → доклад Owner без создания; рутина команды,
  §2 не меняется); прежние шаги 3–7 перенумерованы в 4–8.
- **docs/lifecycle.md** (D11): «Гейты Owner», пункт 1 (Merge, `In
  review` → `Merged`) — дополнение: коммит только при свежем green-
  прогоне corpus-линта (инвариант pre-merge verify, §8; green — не
  семантическая приёмка, текущий failure не глушится историческим
  green).
- **.github/workflows/corpus.yml** (D13): top-level `permissions:
  contents: read`; `concurrency` группой `${{ github.workflow }}-${{
  github.ref }}` с `cancel-in-progress: true`; actions/checkout v4 → v5;
  `strategy.matrix` os [ubuntu-latest, macos-latest] с `fail-fast:
  false`; `timeout-minutes: 10`; примечание-комментарий: ubuntu-latest
  и macos-latest — движущиеся ссылки на актуальный runner-образ GitHub,
  пин раннер-образа не вводим (одно примечание на оба).
- **README.md** (D14): новая секция «Окружение верификации (supported
  verification environment)» — канон: локальный POSIX sh + стандартные
  grep/sed, линт/selftest прогоняются там же; запуск из корня репо
  (прогон из другого каталога — ложный C9 на macOS); CI-матрица —
  hosted-приближение, «зелёный CI — не hosted-run result» и не
  семантическая приёмка (§8), не замена локальному прогону перед
  merge; ссылки на CONTRIBUTING.md и SECURITY.md (замыкает forward-
  ссылку шапки corpus.yml). Новая секция «Лицензия» (Apache-2.0 →
  LICENSE). «Куда дальше» += docs/playbooks/git_recovery.md.
- **docs/playbooks/git_recovery.md** (D15): новый safe-git плейбук
  (штучный носитель без персонального шаблона — прецедент трактовки §9
  планом 261112_2236): где ветка/HEAD (`git status -sb`,
  `git branch --show-current`); что запушено (`git fetch origin` +
  `git log --oneline origin/main..HEAD`); незавершённый rebase —
  continue/abort/skip; detached HEAD — `git switch` либо rescue-ветка
  (`git switch -c rescue/<topic>`, `git branch rescue/<topic> <sha>`);
  amend/force только осознанно (`--force-with-lease` — по явному
  решению); потерянный коммит — reflog + rescue-ветка.
- **docs/followups/backlog.md + index.md** (D16): строка id=ci-hygiene —
  `[x]`, `status=promoted`, `plan=261113_1944` (summary/id/source_ref
  неизменны); index.md пересобран: ci-hygiene перенесён в «Закрытые»
  (plan=261113_1944), P3 (4)→(3), счётчик 11/1 → 10/2, дата состояния
  2026-11-14.
- **Инцидент правки плана (своя зона, исправлен до handoff):** первая
  вставка миграционной записи в Evidence легла между `## Changes` и
  Evidence-комментарием с потерей строки-заголовка `## Evidence` —
  структура восстановлена (заголовок на месте, запись дописана в конец
  лога append-only); зафиксировано здесь для прозрачности CENSOR'а.

## Evidence (chronological, append-only)
<!-- owner: все роли + CENSOR; событийные записи с датой и локальным временем `- YYYY-MM-DD HH:MM:SS — <кто>: <текст>`; CENSOR-receipt по формату конституции -->

- 2026-11-13 19:43:42 — Manager: план создан из шаблона по указанию Owner (черновик; сравнение с дополнительными источниками проведено куратором, механики отобраны)
- 2026-11-13 19:55:52 — Architect: фаза начата, контракты прочитаны
- 2026-11-13 20:51:35 — Architect: добавка по итогам CI-анализа Owner (Solution п.11 — CI-матрица ОС + таймаут джобы; дополнение п.8 — канон запуска линта из корня репо; Out of scope — static-джоба id=ci-v2-static; Scope-дополнения corpus.yml и README); план перечитан с диска, контракты неизменны
- 2026-11-14 22:02:12 — Manager: Owner-резюма Draft — диспатч Architect (PHASE=work) на перепринятие кураторских зон по существу, не rubber-stamp; контракты изменились четырьмя мерджами (720519f/2121, a53592b/1642, 8274d86/1644, 7b23670/1943: AGENTS.md@7ec6d0f4→e6c8eec4, architect.md@73ace930→f6cd38e4 — смены зафиксированы Evidence тех планов, §3 п.7). Устаревшие факты зон для сверки против текущего дерева: «границы соседних Draft 1642/1644» — оба смержены (механики теперь канон); selftest 26/26 (не 15/15), C13 живёт в линте; CONTRIBUTING:79–80 уже de-hardcoded частично планом 1642 (его Scope оговаривал остаток за этим планом); backlog merge-untracked-guard уже promoted планом 2121; pre-merge verify (свежий линт до merge-коммита) уже фактически практика Manager'а с 2121 — план кодифицирует. Живой контекст от Owner: инцидент 2026-11-14 21:33:40 (план 261113_1943, Evidence) — leak-контроль куратора поймал запретный токен в Evidence на merge-гейте, устранён pre-commit правкой; прямой прецедент ценности C14 для Problem п.2
- 2026-11-14 22:12:38 — Architect: фаза work завершена — кураторские зоны переприняты по существу против текущих контрактов (intake 22:08:26: AGENTS.md@e6c8eec4, architect.md@f6cd38e4 — цепочки миграций §3 п.7 подтверждены по Evidence планов 2121/1642/1644/1943). Перепринятие меняет факт-базу, не решения: Problem п.1/2/4/6/8 — актуализированы (C1–C13 + selftest 26/26; живой инцидент-прецедент leak-контроля 21:33:40 из Evidence 1943:719; 2 упоминания check_corpus в run.md без pre-merge прогона; forward-ссылка шапки corpus.yml на несуществующую README-секцию; 5 плейбуков без git-аварий); Solution п.1/2/4/5/7 — уточнены (`<REDACTED>`: живых значений нет, лексика — 1943:284; C14 — безусловно следующий после живого C13, счётчик с 26; de-hardcode CONTRIBUTING завершён 1642 — остаётся инвариант нереинтродьюции; механика pre-verify — в контроли merge-рутины (а) до Evidence/коммита, сосед untracked-гэпа 2121); Out of scope — границы 1642/1644 переписаны против смерженного канона, merge-untracked-guard — promoted 2121, ci-v2-static — строка заведена; Scope — добавлен fan-out инвентарь §5 (самоприменение: обязанность введена 1943 после создания плана). Линт после правок: corpus: clean. Статус `Ready for Planner`
- 2026-11-14 22:28:04 — Planner: finalize completion-pass — второй проход по заполненным секциям «глазами Coder и Reviewer» (сверка по файлу на диске: статус-строка ровно 1 = `Planning`, 19 DoD-пунктов D1–D19, 20 T-строк T1–T20, порядок 14 секций шаблона сохранён). Самопроверка 1 «что придётся угадывать»: устранено до handoff — классы/пороги/якоря C14 специфицированы в D3 однозначно, но без триггерных литералов (payload-принцип оговорён; точные ERE — реализация Coder в скрипте, доказательство — кейсы D5/T2); место pre-verify — контроль (а) merge-рутины между git-контролями и (б)/(в) (D10/T9); место preflight — до создания файла плана (D12/T11); staged-состав назван пофайлово: 12 носителей + план = 13 (D19/T18); счётчик selftest — нижняя граница N ≥ 33 с синхронизацией _st_total и шапки (D5/T2); все различающие grep-якоря Tests несут базу «сейчас», снятую по дереву 22:19–22:25. Самопроверка 2 «implicit-доказательства»: материальные носители названы — «C14 не даёт ложных срабатываний» = живой прогон T1 + связка T4 (REDACTED в SECURITY.md при clean) + гейт T19; «allowlist эффективен» = кейс T2 + осмотр T6; «baseline ловит регрессию C14» = требование D5 + grep T5; «CI гоняет обе команды на матрице» — в фазе Coder проверяема только конфигурация (T12), сам CI-прогон — событие после пуша, в DoD как Coder-проверяемое не заявлено (граница фазы, не implicit). Вердикт: дефектов Planner'а не найдено, оба ответа — «ничего».
- 2026-11-14 22:28:54 — Planner: фаза Planning завершена: заполнены `## Acceptance criteria / DoD` (D1–D19 — детализация Solution 1–11 и Scope включая fan-out инвентарь до проверяемых утверждений; решения Architect не менялись — точные классы/пороги C14 конкретизированы в зоне Planner по Solution п.2 «зона Planner/Coder», формулировки без триггерных литералов и payload-образных примеров — план сам сканируемая C14 поверхность) и `## Tests / Commands` (T1–T20, каждый Dn покрыт командой или осмотром с ожидаемым результатом; базы «сейчас» сняты grep'ом по дереву 22:19–22:25; R-меток нет — R-DoD отсутствуют); переноса ответов Q&A не требовалось: открытых Q/A-пар в логе нет, только intake-записи; `## Follow-ups (deferred)` заполнен (2 записи: терминальное закрытие ci-hygiene после merge; SHA-пиннинг/расширение классов — кандидаты при потребности). Handoff: **Status:** Ready for Coder
- 2026-11-14 22:16:23 — (Role CENSOR) OK: Ready for Planner validated; current=true
Censor dispatch id: censor:architect:261114_221422
Observations:
- Second opinion: план перечитан с диска целиком (не из памяти) + grep-батарея против дерева и собственного текста. Шапка: `**Status:** Ready for Planner` — ровно одна статус-строка (`grep -c '^\*\*Status:'` → 1), совпала с PRE_STATUS_LINE конверта; Plan ID 261113_1944 = префикс имени файла. Зоны: мои секции (понимание/Problem п.1–8/Solution п.1–11/Scope/Out of scope) заполнены и взаимно согласованы — кросс-сверки: Problem п.2 «C1–C13, selftest 26/26» ↔ Solution п.2 «счётчик растёт с текущих 26»; Problem п.4 «контроли merge-рутины — только git-контроли + Evidence» ↔ Solution п.5 «в контроли до коммита, сосед git-контролей (а) и untracked-гэпа 2121, до (б)/(в)»; Problem п.6 «forward-ссылка не замкнута» ↔ Solution п.7 «замыкается п.8»; Problem п.8 «пять плейбуков» ↔ Solution п.9 git_recovery.md; Solution п.4 «de-hardcode завершён 1642, инвариант» ↔ Scope CONTRIBUTING «только инвариант»; Solution п.8 «CI (матрица, п.11)» ↔ п.11 ↔ Scope corpus.yml; fan-out инвентарь — 4 компонента §5 (носители/проверки/доки/consumer-пути), счёт «9 правимых + 2 новых» сверен со списком Scope (правимые: check_corpus.sh, corpus.yml, CONTRIBUTING, AGENTS, run.md, plan.md, lifecycle, README, backlog; новые: SECURITY.md, git_recovery.md). Q-строк `grep -cE '^- Q\('` → 0 — вопросы к Owner не терялись, Owner-ответов после фазы не поступало. Чужие зоны не тронуты: DoD-плейсхолдер Planner'а, Tests/Changes, Follow-ups — нетронуты; Token usage пополнял только Manager (§1(f)); append-only соблюдён — intake-строки 19:55:52/20:51:35 и Evidence-история дословно на месте. Линт: `sh scripts/check_corpus.sh` → `corpus: clean` (22:16).
- Counterfactuals considered: (1) «пропущен устаревший факт в глубине секций» — grep-маркеры `строка 118|Draft 1642|Draft 1644|упомянут один раз` → вхождения только в append-only записях (Evidence Manager 22:02:12, исторический intake 20:51:35) и в констатации NO OBJECTIONS о переписывании; живые секции чисты; (2) «рассинхрон ubuntu-latest/матрица после добавки п.11» — grep `ubuntu-latest` по плану: Problem п.6 (осознанность текущего workflow), Solution п.7 (примечание), п.11 (матрица), Scope (примечание) — все контекстно валидны, двойных формулировок CI нет; (3) «нарушен append-only при переприятии» — сверены дословно старые intake-строки Q&A и Evidence-записи 19:43–20:51 — не изменены; (4) «fan-out инвентарь неполон» — сверены 4 компонента против §5 и прецедента 1943 (Scope-формат совпадает); (5) «инцидент-прецедент вписан с ошибкой источника» — Evidence 1943:719–725 перечитан: гейт 21:33:40, правка Coder'а 21:34:17, перефразировка Manager'а 21:39:37 — Problem п.2 и Solution п.1 цитируют корректно.
- Addendum (new angle): сверх чек-листа сверено пересечение с новым Draft-планом очереди 261114_0151 (моложе нашего, исполнится позже): его текст заявляет «Пересечений с существующими командами нет» и ссылается на planfaktor-plan.md только как на прецедент (0151:47,66,106) — наш дубликат-preflight в plan.md конфликта с ним не создаёт; также перечитана шапка corpus.yml на диске — forward-ссылка на README supported verification environment подтверждена дословно (замыкание п.8 актуально).
- Fixes: none (NO FINDINGS; искал: устаревшие факт-числа и ссылки в живых секциях, кросс-противоречия Problem↔Solution↔Scope↔Out of scope, потерянные Q к Owner, нарушения ownership-зон и append-only, рассинхрон матрицы п.11 с п.7/п.8, полноту fan-out инвентаря, точность цитат инцидента 21:33:40, конфликт с планом 0151 — всё проверено grep'ами против файлов, дефектов нет)
- Final censor verdict: OK
- 2026-11-14 22:33:16 — (Role CENSOR) OK: Ready for Coder validated; current=true
Censor dispatch id: censor:planner:261114_222951
Observations:
- Second opinion: план перечитан с диска целиком (не из памяти) + grep-батарея против дерева и собственного текста. Шапка: `**Status:** Ready for Coder` — ровно одна статус-строка (`grep -c '^\*\*Status:'` → 1, строка 4), совпала с PRE_STATUS_LINE конверта; Plan ID 261113_1944 = префикс имени файла. Мои секции: DoD D1–D19 — каждый пункт утверждение, проверяемое прогоном или осмотром; T-покрытие полное — объединение меток (Dn) по T1–T20 замкнуто: D1(T3), D2(T4,T20), D3(T1,T5), D4(T6), D5(T2), D6(T5), D7(T7), D8(T20), D9(T8), D10(T9), D11(T10), D12(T11), D13(T12), D14(T13), D15(T14), D16(T15), D17(T17), D18(T1,T2,T19), D19(T16,T18) — без пропусков и без «по необходимости»-формулировок. Q&A: Q-строк `grep -cE '^- Q\('` → 0 — переносить нечего, зафиксировано Evidence 22:28:54; intake-итераций две (22:25:48 work, 22:30:44 censor), обе с тремя явными ответами. Finalize completion-pass — Evidence 22:28:04 (до статуса 22:28:54), с двумя дословными самопроверками и вердиктом. Follow-ups — 2 записи с why. Чужие зоны не тронуты: Architect-секции перечитаны с диска (строки 11–373 — понимание/Problem п.1–8/Solution п.1–11/Scope/Out of scope дословно на месте), Changes пуст (зона Coder), Token usage пополнял только Manager (22:29:51 planner.work — не моя запись); append-only соблюдён — история Evidence/Q&A не переписывалась. Линт после правок CENSOR-итерации: `sh scripts/check_corpus.sh` → `corpus: clean`; `--selftest` → `selftest: 26/26 caught` (текущее дерево, C14 ещё не введён — база D5).
- Counterfactuals considered: (1) «T-якорь с неверной базой → false-red у Coder'а» — базы перепроверены повторным grep'ом (22:30–22:33): check_corpus в run.md → 2, permissions|concurrency в corpus.yml → 0, Apache в README → 0, backlog в planfaktor-plan.md → 0, `_st_total=26` в скрипте → 1 — базы Tests соответствуют дереву; (2) «план само-матчится будущим C14 → T1 всегда красный» — черновые ERE всех шести классов D3 прогнаны по файлу плана: домашний путь с сегментом имени → 0, короткий gh-префикс с телом → 0, составной префикс с телом → 0, PEM-маркер → 0, Bearer с телом → 0, eyJ-JWT → 0 — формулировки без триггерных литералов выдержаны; (3) «T-команда невоспроизводима из-за git-состояния» — живой прогон: план 1944 untracked (`git status --porcelain` → `??`), `git diff --name-only HEAD -- docs/plans/` → 0 строк — прежняя формулировка T16 была невоспроизводима (unstaged-diff слеп к untracked до стейджинга и к staged после), дефект найден и исправлен (см. Fixes); (4) «DoD меняет решения Architect» — сверка соответствий: шесть классов D3 ↔ Solution п.2 (домашние пути / два префиксных класса хостинга / PEM / Bearer / JWT), пороги — конкретизация отведённой «зоны Planner/Coder», D9+D10 ↔ п.5, D12 ↔ п.6, D13 ↔ п.7+п.11, D14 ↔ п.8, D15 ↔ п.9, D16 ↔ п.7, D17/D18 ↔ п.10+fan-out; дизъюнкций в DoD нет, reject-альтернатив не потребовалось; (5) «пропущен носитель Scope» — все 12 файлов Scope + fan-out-абзац закрыты D1–D19 пофайлово (D19 перечисляет 13 staged).
- Addendum (new angle): сверх чек-листа — (а) сверено пересечение с Draft-планом 261114_0151 (второй untracked в docs/plans/, тема — init/run-команды): наши правки planfaktor-plan.md/planfaktor-run.md соседствуют с его темой без конфликтов формулировок, staged-набор T18 (ровно 13) его не захватывает — untracked Draft в исключениях контроля (а) merge-рутины; (б) арифметика T2: 26 текущих + 6 классовых кейсов + 1 allowlist = 33 = нижняя граница N ≥ 33, синхронно D5; (в) D17 не требует digest для scripts/check_corpus.sh — список §3 п.7 (AGENTS.md, docs/roles/*, шаблоны, .zcode/commands/*) скрипт не включает, оговорка в D17 явная; (г) время Evidence: мои записи 22:28:04/22:28:54 стоят перед receipt'ом Architect'а 22:16:23 (вставка перед последней записью на work-итерации) — append-only соблюдён (история не переписана), новый receipt дописан в конец секции.
- Fixes: T16 переформулирован доreceipt'ом: git-diff-команды заменены на форму `git diff --name-only HEAD -- ...` (staged+unstaged tracked) для зон 1642/1644 и docs/plans/ с ожиданием «пусто»; учёт untracked-плана 1944 перенесён к T18 (staged-осмотр «ровно 13») — прежняя формулировка дала бы Coder'у невоспроизводимое ожидание «только файл этого плана» ( unstaged-diff слеп к untracked/staged). Иных находок нет.
- Final censor verdict: OK
- 2026-11-14 22:34:21 — Manager: CENSOR Planner OK (grep: маркер+TS 22:33:16, dispatch id censor:planner:261114_222951, Observations непустые, verdict OK; фикс T16 в зоне автора) — переход Ready for Coder → In progress подтверждён
- 2026-11-14 22:34:21 — Manager: Q&A чист, открытых вопросов к Owner нет, статус In progress; диспатч Coder (PHASE=work)
- 2026-11-14 22:42:10 — Coder: AC-to-test до правок (§5, закрытый набор; все 19 пунктов — explicit assertion, новых проверок T-батарей с якорями из Tests): D1→T3 (grep-батарея SECURITY.md + осмотр трёх подсекций); D2→T4+T20 (REDACTED в живом носителе при corpus: clean + отсутствие литеральных чисел в CONTRIBUTING); D3→T1+T5 (check_c14 в run_all после C13, классы доказываются selftest-кейсами T2); D4→T6+T2 (allowlist-таблица с обоснованиями + bait-кейсы default-deny/allowlist); D5→T2 (selftest N≥33, 7 строк caught C14, счётчик/шапка синхронны, baseline += check_c14); D6→T5+T1 (источники C9 += SECURITY.md/CONTRIBUTING.md); D7→T7 (seed_corpus копирует все поверхности C14); D8→T20 (скан-строка + инвариант de-hardcode в CONTRIBUTING); D9→T8 (pre-merge verify в §8, осмотр границ правки); D10→T9 (третье упоминание check_corpus в run.md, контроль (а) до (б)/(в)); D11→T10 (фраза в merge-гейте lifecycle.md); D12→T11 (preflight-шаг plan.md до создания файла); D13→T12 (grep-батарея corpus.yml + осмотр top-level permissions/concurrency workflow+ref); D14→T13 (grep-батарея README.md, замыкание forward-ссылки шапки corpus.yml); D15→T14 (grep-батарея git_recovery.md); D16→T15 (row-переход ci-hygiene + derived-пересборка index.md со счётчиком); D17→T17 (≥3 миграционных записи `@8hex → @8hex` в этом Evidence); D18→T1+T2 (финальный срез clean + selftest все caught; T19 — гейт Manager при In review после создания review-артефакта: вне фазы Coder, локальная часть — план как C14-поверхность в T1); D19→T16+T18 (зоны 1642/1644 чисты в diff HEAD; staged = ровно 13 файлов Scope+план). Прогоны и результаты — ниже по ходу работы; baseline до правок (22:41:33): `corpus: clean` exit 0, `selftest: 26/26 caught` exit 0
- 2026-11-14 22:51:29 — Coder: миграция контрактов §3 п.7 — смены digest'ов по каждому изменённому контракту (старые — на момент первой правки Coder'а, сняты 22:41 до изменений; новые — после правок, `shasum -a 256`; scripts/check_corpus.sh — вне списка §3 п.7, digest не требуется):
  AGENTS.md@e6c8eec4 → @1f66a38f — правка §8: инвариант pre-merge verify (D9)
  .zcode/commands/planfaktor-run.md@ccf9685b → @1d02ddb1 — шаг 4, контроль (а): свежий линт до merge-коммита (D10)
  .zcode/commands/planfaktor-plan.md@3d1283f4 → @27f10905 — новый шаг 3: дубликат-preflight (D12)
- 2026-11-14 22:53:40 — Coder: T-батарея по правленому дереву (все grep-проверки из Tests, факт): T2 — selftest выводит 7 строк `caught C14` (C14a–C14g), `grep -c '_st_total='` → 1 (значение 33, строка 1318), старые литералы `_st_total=26|26/26|C1–C13` → 0; T3 — SECURITY.md: private vulnerability reporting 1, REDACTED 2, `эксплойт|воспроизвед|митигац` 3, `истори|append-only` 5, `Plan ID|dispatch` 2, три подсекции (отчёт/secret-privacy/public artifact review); T4 — связка: REDACTED ≥1 в SECURITY.md при `corpus: clean` (прогон T1 ниже, 22:55) — плейсхолдер не матчится C14; T5 — check_c14 ×10, `report C14` → 1 (строка 1273, run_all после C13), `CONTRIBUTING|SECURITY` ×7, LICENSE ×3; T6 — allowlist ×8 вхождений (таблица+применение+комментарии), каждая запись с обоснованием, default deny подтверждён C14a–C14f (bait вне allowlist роняет) и C14g (bait внутри не роняет); T7 — seed_corpus копирует CONTRIBUTING.md, SECURITY.md, LICENSE, scripts/, .github/; T8 — `pre-merge verify` в AGENTS.md строка 336 (§8, между «## 8.» и «## 9.»), `семантическая приёмка` 1, `свежий` в §8 1, правка ограничена §8 (T16); T9 — check_corpus в run.md = 3, `corpus: clean` строка 175, `стоп без коммита` строка 175, прогон в контроле (а) до (б)/(в), needs-fix ветка не тронута (T16); T10 — pre-merge verify в lifecycle.md 1 («Гейты Owner», пункт Merge); T11 — backlog ×2, `status=open|promot` ×2 строки, «Дубликат-preflight» шаг 3 (до создания файла — шаг 4); T12 — permissions/contents: read/concurrency/cancel-in-progress/checkout@v5/matrix/fail-fast/timeout/движущ — все ≥1 (checkout@v5 ровно 1, checkout@v4 0, macos-latest 2), permissions top-level, concurrency `${{ github.workflow }}-${{ github.ref }}`; T13 — README: Лицензия 1, Apache-2.0 1, supported verification environment 1 (заголовок секции — forward-ссылка шапки corpus.yml замкнута), SECURITY.md 1, CONTRIBUTING.md 1, git_recovery.md 1, `из корня репо` строка 81, POSIX 1, `hosted|CI` 4; T14 — git_recovery.md: `status -sb|branch --show-current` 3, origin/main..HEAD 2, `reflog|rescue/` 5, force-with-lease 2, rebase 7, `continue|abort|skip` 3; T15 — backlog id=ci-hygiene несёт `[x]`/`status=promoted`/`plan=261113_1944` (summary/id/source_ref дословно прежние), index.md: ci-hygiene только в «Закрытые» (строка 41), счётчик 10/2; T20 — CONTRIBUTING: `скан` строка 88, C14 2, `реинтродьюц|литеральн` 1, литеральные числа `[0-9]+/[0-9]+ caught|[0-9]+ чеков линта` → 0. T19 — гейт Manager при In review после создания review-артефакта (вне фазы Coder); локальная часть — план как C14-поверхность покрыта финальным T1
- 2026-11-14 22:54:21 — Coder: фаза work завершена — 12 носителей Scope правлены/созданы, Changes/Evidence заполнены, изменения стейджируются (T16 прогнан до стейджинга: `git diff --name-only HEAD -- docs/roles/ docs/plans/_template.md docs/reviews/_template_review.md` → пусто; `-- docs/plans/` → пусто (план 1944 untracked, дельта учтена T18); `git log --oneline origin/main..HEAD` → пусто; итог стейджинга и финальные T1/T2/T17/T18 — записью ниже). Статус `In review`
- 2026-11-14 22:56:20 — Coder: стейджинг и финальный срез: `git add` 13 файлов; T18 — `git diff --cached --name-only` → ровно 13 (12 носителей D19 + этот план), `git status --porcelain` — staged M/A без unstaged-дельты; T17 — 3 миграционные записи `@8hex → @8hex`; финальный T1 (22:55:57, после простановки `In review`): `sh scripts/check_corpus.sh` → `OK C14 safety-scan`, `corpus: clean`, exit 0; T2: `--selftest` → `selftest: 33/33 caught`, exit 0 (7 строк caught C14); контрольный повтор после этой записи — записью ниже. Наблюдение для Manager (не моя зона, не трогал): в рабочем дереве появились посторонние untracked `.playlight-cli`-класса (`.playwright-cli/`, `docs/getting_started.md`, `docs/img/`) — отсутствовали на старте итерации (22:38, чистый статус: только два untracked-плана), в staged-набор не входят, линт по ним clean (docs/-поверхность просканирована)
- 2026-11-14 22:57:11 — Coder: контрольный повтор после записей 22:54–22:56 и простановки статуса: `sh scripts/check_corpus.sh` → `corpus: clean`, exit 0; `--selftest` → `selftest: 33/33 caught`, exit 0; план перездейджирован — staged по-прежнему ровно 13 файлов. Handoff `In review` валиден; жду CENSOR
- 2026-11-14 23:02:19 — (Role CENSOR) OK: In review validated; current=true
Censor dispatch id: censor:coder:261114_225853
Observations:
- Second opinion: план и дерево перечитаны с диска (не из памяти). Шапка: статус-строка ровно 1 (`grep -c '^\*\*Status:\*\*'` → 1), значение `In review` (строка 4) совпало с PRE_STATUS_LINE конверта; Plan ID 261113_1944 = префикс имени файла. DoD↔Changes: каждая запись `## Changes (by area)` несёт метки Dn и закрывает носители Scope пофайлово (D1/D2→SECURITY.md; D3–D7→check_corpus.sh; D8→CONTRIBUTING; D9→AGENTS §8; D10→run.md; D11→lifecycle; D12→plan.md; D13→corpus.yml; D14→README; D15→git_recovery.md; D16→backlog+index; D17→миграции Evidence 22:51:29; D18→прогоны; D19→staged-состав) — пропусков нет, лишних носителей нет (`git diff --cached --name-only` → ровно 13 из D19). AC-to-test: запись Evidence 22:42:10 (все 19 исходов explicit assertion) хронологически до заполнения Changes (метки времени 22:42 < 22:52); Assumption-строк в Q&A нет (`grep -c 'Assumption:'` → 0) — решения позитивной зоны (имя чека safety-scan, единственная allowlist-запись, синтетика bait) отражены в Changes, не молча. Tests: T1–T18, T20 прогнаны, факты с датами — Evidence 22:53:40/22:56:20/22:57:11; цензорный повтор линта: `sh scripts/check_corpus.sh` → `OK C14 safety-scan`, `corpus: clean`, exit 0; `--selftest` → `selftest: 33/33 caught`, exit 0 (23:02). Стейджинг: 13 staged, unstaged-дельта — только сам план (append-only записи цензорной итерации после финального стейджинга work-фазы — штатная категория merge-контроля (а) в /planfaktor-run). Чужие секции плана не тронуты: мои правки — Q&A-intake, Evidence (append), Changes (своя зона), статус-строка §2; Problem/Solution/Scope/Out of scope/DoD/Tests/Follow-ups — дословно Architect/Planner. Follow-ups: 2 записи с why (терминальное закрытие ci-hygiene после merge; SHA-пиннинг/расширение классов — кандидаты).
- Counterfactuals considered: (1) «selftest-кейс C14 ловит не свой класс или allowlist шире заявленного» — C14_ALLOWLIST ровно одна запись (`grep -c '^C14_ALLOWLIST='` → 1: scripts/check_corpus.sh|gh-token, обоснование комментарием под таблицей); изоляция кейсов подтверждена полным 33/33 — в c14g check_c14 обязан пройти rc=0, любой посторонний матч в копии дал бы MISSED, в c14a–C14f bait вне allowlist обязан ронять; (2) «DoD-чекбоксы остались `[ ]`×19 — забытая отметка» — осознанно: закрытие DoD в этом конвейере доказывается Changes/Evidence-фактами, чекбоксы планами-предшественниками (2121/1642/1644/1943 в статусах Done) также не отмечались; (3) «usage-строка Manager'а 22:58:53 (coder.work, зона §1(f)) сломала C11» — цензорный линт 23:02 clean, C11 прошёл; изменение плана между итерациями — только эта строка, моя работа не конфликтует; (4) «правка AGENTS.md вышла за §8» — `git diff --name-only HEAD -- AGENTS.md` на staged: единственный добавленный пункт между «## 8.» и «## 9.» (T8-осмотр); (5) «дописанные после стейджинга записи плана ломают C3/C6» — линт 23:02 clean (C3 секции, C6 digest-хвосты — все 8 hex).
- Addendum (new angle): (а) неточность формулировки в моей Evidence-записи 22:56:20 — «`.playlight-cli`-класса» вместо «.playwright-cli»; точное имя `.playwright-cli/` присутствует в тех же скобках записи, факт не искажён; append-only (§5) не позволяет переписать запись — неточность фиксируется этим receipt'ом; (б) незакрытый T19 — событие Manager-гейта после создания review-артефакта: зона зафиксирована в Evidence 22:53:40 и не является хвостом Coder'а; (в) посторонние untracked (`.playwright-cli/`, `docs/getting_started.md`, `docs/img/`) — вне staged-набора, доложены Manager'у записью 22:56:20, линт по docs/-поверхности clean; (г) сверх чек-листа прогнан `sh -n scripts/check_corpus.sh` (синтаксис POSIX sh — чисто) и выборочная перепроверка якорей T5/T12/T15 — значения совпали с Evidence 22:53:40.
- Fixes: none (NO FINDINGS; искал: расхождения Changes↔код по всем 12 носителям (allowlist 1 запись, checkout@v4 0/checkout@v5 1, счётчик _st_total=33, миграционные записи 3, статус ci-hygiene promoted/plan=261113_1944), хронологию AC-to-test vs Changes, unstaged-дельту носителей вне плана (пусто), правки чужих секций плана и зон 1642/1644 (diff HEAD по docs/roles/, шаблонам — пусто), TODO/отладочный мусор в правимых файлах (0; единственный XXXXXX-матч — mktemp-паттерн `check_corpus_selftest.XXXXXXXX`, рабочий код), Assumption/открытые вопросы (0), деградацию C1–C13 и ложные срабатывания C14 на живом дереве (corpus: clean, 33/33) — дефектов не найдено)
- Final censor verdict: OK
- 2026-11-15 02:02:22 — Manager: Owner-«да» на merge-гейте (дословно через куратора: «да, мержим, но пока не запускаем новый план. нам нужен модельный прогон со съёмкой как идёт чтобы сделать инструкцию с картинками»); контроли (а) пройдены — unstaged: только план (append-only-дельта), untracked: Draft-черновик 0151 (исключение) + review-артефакт (шаг (в)); посторонних untracked нет (доки Owner'а закоммичены им самим — fc3cc79); staged = 13; гейт терминальности: `**Artifact state:** current_green` записанной формой (артефакт :96); pre-merge verify по инварианту §8 (введён этим планом, самоприменение): свежий прогон `corpus: clean` (C1–C14) + `selftest: 33/33 caught`; запретный grep по staged: 0 (мой + повторный куратора); статус Merged, merge-коммит по явному списку из Итога; после merge — push + CI (новая матрица ОС) + closeout с harvest-инвентарём; план 261114_0151 НЕ стартует — Owner готовит модельный прогон со съёмкой

## Token usage (append-only)
<!-- owner: manager; dispatch-форма: `- YYYY-MM-DD HH:MM:SS — usage: <role>.<work|censor|rN> <N|unknown (why=...)> tokens — <dispatch|sendmessage|unknown>`; чекпоинт-форма: `- YYYY-MM-DD HH:MM:SS — usage: manager-context checkpoint ~<N> tokens-left — approximate`; числа — учёт харнесса ZCode (subagent_tokens), приближение, не биллинг провайдера; пишет только Manager из tool-результата вызова -->

- 2026-11-13 19:55:52 — usage: architect.work 1498787 tokens — dispatch
- 2026-11-13 20:51:35 — usage: architect.work 689235 tokens — sendmessage
- 2026-11-14 22:14:22 — usage: architect.work 4324401 tokens — dispatch
- 2026-11-14 22:17:54 — usage: architect.censor 1106245 tokens — sendmessage
- 2026-11-14 22:29:51 — usage: planner.work 3021192 tokens — dispatch
- 2026-11-14 22:34:21 — usage: planner.censor 1530267 tokens — sendmessage
- 2026-11-14 22:58:53 — usage: coder.work 11191588 tokens — dispatch
- 2026-11-14 23:04:21 — usage: coder.censor 2072516 tokens — sendmessage
- 2026-11-14 23:13:25 — usage: reviewer-risk.work 1499541 tokens — dispatch
- 2026-11-14 23:24:29 — usage: reviewer-contracts.work 2779113 tokens — dispatch
- 2026-11-14 23:24:29 — usage: manager-context checkpoint ~14967595 tokens-left — approximate

## Q&A log (chronological, append-only)
<!-- owner: все роли; intake: `Intake (YYYY-MM-DD HH:MM:SS): AGENTS.md@<8hex> <role>.md@<8hex>` (локальное время) + NO QUESTIONS / NO SUGGESTIONS / NO OBJECTIONS; вопросы `Q(<роль>): ... to=Owner|to=<роль>, blocker: yes|no, needs_owner: yes|no, status=open`; закрытие `A(<кто>): ... status=closed, перенесено в <секция>` -->

- Intake (2026-11-13 19:55:52): AGENTS.md@7ec6d0f4 architect.md@73ace930
- architect: NO QUESTIONS (бриф Owner закрывает развилки: канал отчётов и состав репорта; классы C14 и следующий номер после C13 плана 261113_1642; место инварианта pre-merge verify решено анти-дрейфом «§8 — инвариант, команда — механика»; форма плейсхолдера — принят `<REDACTED>`: вхождений в корпусе нет, вводится политикой как канон без миграции; digest'ы сверены `shasum -a 256` — совпали с кураторскими 7ec6d0f4/73ace930)
- architect: NO SUGGESTIONS (анти-false-gap по живому корпусу: SECURITY.md отсутствует — ls/grep; `permissions`/`concurrency` в corpus.yml — 0; check_corpus.sh в planfaktor-run.md — 1 упоминание (строка 118, канон C11), pre-merge шага нет; `backlog|followup` в planfaktor-plan.md — 0; все классы C14 по текущему дереву, включая LICENSE и scripts, — 0 совпадений, после ввода чека корпус остаётся clean кроме явного allowlist; `<REDACTED>` — 0; LICENSE существует, упоминаний в `*.md` — 0; дублирования механик 1642/1644 нет — пересечения только по общим носителям, исполняемым последовательно)
- architect: NO OBJECTIONS (противоречий с конституцией нет: правка §8 — через Scope с миграцией §3 п.7; pre-merge verify не расширяет write-surface §1 — факт прогона входит в существующий merge-узел Evidence; SECURITY.md и git_recovery.md — новые штучные носители без шаблонов по прецеденту 261112_2236; механики соседних черновиков не дублируются — отграничены в Out of scope)
- Intake (2026-11-13 20:51:35): AGENTS.md@7ec6d0f4 architect.md@73ace930
- architect: NO QUESTIONS (добавка однозначна: состав matrix/timeout/fail-fast задан CI-анализом Owner с реальными прогонами; место фиксации cwd-канона — README-секция п.8; digest'ы сверены `shasum -a 256` — неизменны 7ec6d0f4/73ace930, §3 п.7 чист)
- architect: NO SUGGESTIONS (анти-false-gap: matrix|timeout|strategy в corpus.yml — grep → 0 (есть только runs-on ubuntu-latest строка 10 и checkout@v4 строка 13); расхождение ввода с корпусом зафиксировано: строка id=ci-v2-static на момент сверки в backlog.md отсутствовала — вставка Out of scope сформулирована по стабильному id, заведение строки — за куратором при применении вставок; дублирования с п.7 нет — п.11 расширяет уже правимую джобу, не вводя новую сущность)
- architect: NO OBJECTIONS (append-only соблюдён — существующие пункты Solution/Scope/Out of scope не переписываются, только расширяются; матрица не меняет принцип п.8 «зелёный CI — не hosted-run result»: два runner-образа остаются hosted-приближением канона, а не его доказательством; конституцию добавка не трогает)
- Intake (2026-11-14 22:08:26): AGENTS.md@e6c8eec4 architect.md@f6cd38e4
- architect: NO QUESTIONS (перепринятие кураторских зон по существу против текущих контрактов после четырёх мерджей: digest'ы сняты `shasum -a 256` — AGENTS.md@e6c8eec4, architect.md@f6cd38e4, совпадают с конвертом Manager'а 22:02:12; цепочки миграций §3 п.7 подтверждены Evidence планов-предшественников: AGENTS.md 7ec6d0f4→3b937eed (2121/1642/1644) →e6c8eec4 (1943, Evidence 19:13:33), architect.md 73ace930→65060cee→f6cd38e4 (1644:721); статус плана `Draft` сверен с PRE_STATUS_LINE — совпал; бриф Owner'а новых развилок не открыл — решения не пересматривались, менялась только фактическая база: 1642/1644/1943 смержены (статусы `Done` на диске, коммиты a53592b/8274d86/7b23670), их механики — канон)
- architect: NO SUGGESTIONS (анти-false-gap, всё перепрогнано/перегрепано против текущего дерева: `sh scripts/check_corpus.sh` → `corpus: clean` exit 0, C13 живёт в линте; `--selftest` → `26/26 caught` (не 15/15); SECURITY.md в корне отсутствует (ls), упоминания SECURITY вне этого плана — только указатели на него в 1943:283 и review:71 (трассировка harvest), не политика; `permissions`/`concurrency`/`strategy`/`timeout` в corpus.yml — 0, checkout@v4; скан-строки в CONTRIBUTING нет; `backlog|followup|preflight|дубликат` в planfaktor-plan.md — 0; `check_corpus` в planfaktor-run.md — 2 упоминания (131 C11-канон usage, 150 C13-страховка ревью), pre-merge прогона в merge-рутине (контроли (а)/(б)/(в)) нет; LICENSE/Apache в README — 0; docs/playbooks/ — 5 плейбуков (добавились manager_snapshot_restart, contract_edit_invariant_map, doc_gardening, docs_canon_sweep), git-аварии не покрыты ни одним; `<REDACTED>` вне этого плана — единственное упоминание 1943:284 (лексика описания маскирования, не живое значение); литералы `C1–C12|15/15` в CONTRIBUTING — 0 (de-hardcode завершён 1642, T13 PASS); backlog: id=ci-hygiene `status=open, plan=none`, id=merge-untracked-guard `status=promoted, plan=261113_2121`, id=ci-v2-static строка заведена `status=open`; инцидент 2026-11-14 21:33:40 — Evidence 1943:719–725, leak-контроль куратора поймал запретный токен в Evidence на merge-гейте, pre-commit правка Coder'а 21:34:17)
- architect: NO OBJECTIONS (перепринятие не меняет решений, только факт-базу моих секций: устаревшие ссылки «соседние Draft 1642/1644» переписаны как границы против смерженного канона; untracked-контроль 2121 в merge-рутине run.md — сосед нашего pre-verify, не конфликт; fan-out инвентарь §5 добавлен в Scope — обязанность введена мерджем 1943 уже после создания этого плана, самоприменение; append-only логи (Evidence/Q&A) не переписывались — история выбора сохранена; противоречий с конституцией @e6c8eec4 нет: pre-merge verify в §8 через Scope с миграцией §3 п.7, write-surface §1 не расширяется)
- Intake (2026-11-14 22:16:23): AGENTS.md@e6c8eec4 architect.md@f6cd38e4
- architect: NO QUESTIONS (CENSOR-итерация: digest'ы пересчитаны `shasum -a 256` — неизменны e6c8eec4/f6cd38e4 с intake 22:08:26, §3 п.7 чист; план перечитан с диска целиком; PRE_STATUS_LINE конверта `Ready for Planner` сверен с шапкой на диске — строка 4, совпал)
- architect: NO SUGGESTIONS (сверка шла по файлам, не по памяти: все факт-заявления receipt перепроверяемы grep'ами, перечисленными в Observations)
- architect: NO OBJECTIONS (дефектов собственного handoff по чек-листу роль-дока не найдено: секции заполнены и взаимно согласованы, чужие зоны не тронуты, append-only соблюдён)
- Intake (2026-11-14 22:25:48): AGENTS.md@e6c8eec4 planner.md@f013858b
- planner: NO QUESTIONS (решения Architect полны, развилок нет: точные ERE, пороги и якоря C14 отведены «зоне Planner/Coder» Solution п.2 — конкретизированы в DoD без триггерных литералов в тексте плана; статус плана `Ready for Planner` сверен с PRE_STATUS_LINE конверта — совпал, строка 4; digest'ы сняты `shasum -a 256`: AGENTS.md@e6c8eec4 — в цепочке миграций §3 п.7 (Evidence 1943, 19:13:33), planner.md@f013858b — правки этого плана роль-док не затрагивают)
- planner: NO SUGGESTIONS (анти-false-gap, базы сняты grep'ом по живому дереву 22:19–22:25: SECURITY.md и docs/playbooks/git_recovery.md отсутствуют; permissions/concurrency/strategy/timeout/macos в corpus.yml — 0, checkout@v4 — 1; check_corpus в planfaktor-run.md — 2 (строки 131, 150), pre-merge прогона нет; backlog|followup в planfaktor-plan.md — 0; pre-merge в AGENTS.md/lifecycle.md — 0; Apache|лицензия|SECURITY|POSIX в README — 0; скан в CONTRIBUTING — 0; CONTRIBUTING|SECURITY|LICENSE в check_corpus.sh — 0; живые литералы счётчика в скрипте — 4 (26/26, _st_total=26, C1–C13 ×2); id=ci-hygiene — status=open, plan=none; seed_corpus не копирует будущие поверхности C14 — расширение заложено в DoD)
- planner: NO OBJECTIONS (противоречий в решениях нет: Solution 1–11 ↔ Scope ↔ Out of scope взаимно согласованы, fan-out инвентарь полон по §5 (носители/проверки/доки/consumer-пути); зона Planner — детализация до проверяемых AC/DoD/Tests без смены решений)
- Intake (2026-11-14 22:30:44): AGENTS.md@e6c8eec4 planner.md@f013858b
- planner: NO QUESTIONS (CENSOR-итерация: digest'ы пересчитаны `shasum -a 256` — неизменны e6c8eec4/f013858b с intake 22:25:48, §3 п.7 чист; план перечитан с диска целиком; PRE_STATUS_LINE конверта `Ready for Coder` сверен с шапкой на диске — строка 4, совпал)
- planner: NO SUGGESTIONS (сверка идёт по файлам, не по памяти: повторные прогоны баз и grep-батарея против дерева — в Observations receipt'а; факт-записи воспроизводимы перечисленными командами)
- planner: NO OBJECTIONS (по чек-листу роль-дока дефектов собственного handoff не найдено, кроме одного уточнения механики T16 в своей зоне — git-diff-формы при untracked-плане; исправлено до receipt, отражено в Fixes)
- Intake (2026-11-14 22:41:43): AGENTS.md@e6c8eec4 coder.md@4620164d
- coder: NO QUESTIONS (план полон, развилок нет: статус `In progress` сверен с PRE_STATUS_LINE конверта — строка 4, совпал; digest'ы сняты `shasum -a 256` — AGENTS.md@e6c8eec4 в цепочке миграций §3 п.7 (Evidence 1943, 19:13:33), coder.md@4620164d правками этого плана не затрагивается; классы/пороги C14 специфицированы D3 однозначно, точные ERE — зона Coder с доказательством кейсами D5; место allowlist-стартовой записи D4 допускает единственный осмысленный носитель — сам скрипт (selftest-кейс C14g), фикса́ция решения — в Changes, не Q&A; T19 — гейт Manager при In review после создания review-артефакта, вне фазы Coder: фиксирую как фазовую границу в Tests, не reroute — локальная часть T19 (план-поверхность C14) покрыта T1)
- coder: NO SUGGESTIONS (анти-false-gap, базы перепроверены прогонами 22:41:33 до правок: `sh scripts/check_corpus.sh` → `corpus: clean` exit 0 (C1–C13 живые); `--selftest` → `26/26 caught` exit 0; SECURITY.md в корне отсутствует (ls), LICENSE существует; git-дерево чистое кроме двух untracked-планов — этот 1944 и Draft 261114_0151 (штатная очередь, не трогаю); HEAD = origin/main, `git log --oneline origin/main..HEAD` пуст; digest'ы правимых контрактов до правок сняты: planfaktor-run.md@ccf9685b, planfaktor-plan.md@3d1283f4 — для миграционных записей D17)
- coder: NO OBJECTIONS (противоречий с конституцией @e6c8eec4 нет: правка AGENTS.md — только §8 инвариантом pre-merge verify (§2/§4/§5/§6 — зоны 1642/1644, не трогаю); механика — в pass-ветке merge-рутины run.md, needs-fix ветка не трогается; §9 соблюдён — SECURITY.md и git_recovery.md штучные носители без персональных шаблонов по прецеденту трактовки 261112_2236; дубликат-preflight — рутина команды plan.md, §2 не меняется)
- Intake (2026-11-14 23:00:23): AGENTS.md@1f66a38f coder.md@4620164d
- coder: NO QUESTIONS (CENSOR-итерация: digest'ы пересчитаны `shasum -a 256` — AGENTS.md@1f66a38f отличается от work-intake e6c8eec4 правкой ЭТОГО плана (D9), смена зафиксирована в Evidence 22:51:29 миграционной записью §3 п.7 — норма по §3 п.7; coder.md@4620164d неизменен; план перечитан с диска; PRE_STATUS_LINE конверта `In review` сверен с шапкой на диске — строка 4, совпал; dispatch id censor:coder:261114_225853)
- coder: NO SUGGESTIONS (сверка идёт по файлам, не по памяти: чек-лист роль-дока прогоняется grep'ами и повторными прогонами против дерева, факты — в Observations receipt'а)
- coder: NO OBJECTIONS (дефектов собственного handoff по чек-листу роль-дока не найдено; findings, если появятся при сверке, будут исправлены в своей зоне до receipt и отражены в Fixes)
- Intake (2026-11-14 23:05:55): AGENTS.md@1f66a38f reviewer-risk.md@a51f0eb4
- reviewer-risk: NO QUESTIONS (план полон для risk-фазы: статус `In review` сверен с PRE_STATUS_LINE конверта — строка 4, совпал; staged-diff непустой — `git diff --cached --stat` → 13 файлов; digest'ы сняты `shasum -a 256`: AGENTS.md@1f66a38f отличается от work-intake Coder'а (e6c8eec4) правкой ЭТОГО плана (D9, §8), смена зафиксирована Evidence 22:51:29 миграционной записью §3 п.7 — норма; reviewer-risk.md@a51f0eb4 правками плана не затрагивается)
- reviewer-risk: NO SUGGESTIONS (анти-false-gap снят живым состоянием дерева: staged-состав = 13 файлов из D19 (осмотр name-only), unstaged-дельта — только сам план (append-only записи после стейджинга, штатная категория merge-контроля (а) run.md); посторонние untracked (.playwright-cli/, docs/getting_started.md, docs/img/, docs/plans/261114_0151_...) в staged не входят — доложены Coder'ом 22:56:20; несрочные улучшения вне risk-зоны не зафиксированы — находки итерации пойдут в review-артефакт, не в предложения плану)
- reviewer-risk: NO OBJECTIONS (противоречий с конституцией на intake нет: зона итерации — `## Findings — Risk lane` + `### Risk verdict` в docs/reviews/261113_1944_review.md; код, staged-изменения и чужие секции артефакта/плана не правлю)
- Intake (2026-11-14 23:14:19): AGENTS.md@1f66a38f reviewer-contracts.md@dd9bcb7a
- reviewer-contracts: NO QUESTIONS (план полон для contracts-фазы: статус `In review` сверен с PRE_STATUS_LINE конверта — строка 4, совпал; review-артефакт docs/reviews/261113_1944_review.md существует, Risk-verdict записан (pass, 23:11:23) — лан идёт вторым по порядку risk → contracts; digest'ы сняты `shasum -a 256`: AGENTS.md@1f66a38f отличается от intake Coder'а work-фазы (e6c8eec4) правкой ЭТОГО плана (D9, §8 pre-merge verify), смена зафиксирована Evidence 22:51:29 миграционной записью §3 п.7 — норма; reviewer-contracts.md@dd9bcb7a правками плана не затрагивается)
- reviewer-contracts: NO SUGGESTIONS (несрочные улучшения вне contracts-зоны не зафиксированы; находки итерации пойдут в таблицу Contracts lane review-артефакта, не в предложения плану)
- reviewer-contracts: NO OBJECTIONS (противоречий с конституцией на intake нет: зона итерации — `## Findings — Contracts lane` + `### Contracts verdict` + `## Итог` в docs/reviews/261113_1944_review.md; код, staged-изменения, чужие секции артефакта (Risk lane) и план (кроме intake-записей) не правлю; не коммичу и не стейджу)

## Suggestions log (chronological, append-only)
<!-- owner: все роли; несрочные улучшения -->

## Objections log (chronological, append-only)
<!-- owner: все роли; `### <Role> objections`; строка на возражение, blocker: при блокере -->

## Follow-ups (deferred)
<!-- owner: coder/planner при CENSOR; незакрытые хвосты: <описание> — why: <почему сейчас не в скоупе>; обязательна запись `NO FOLLOW-UPS — why: <код_причины>` при отсутствии -->

- Терминальное закрытие backlog-строки id=ci-hygiene (`status=handled` с
  disposition на `.github/workflows/corpus.yml`) — малая доки-правка после
  merge-коммита этого плана — why: disposition требует существующего
  merge-коммита; staged-набор плана фиксирует только промоушен (D16,
  Solution п.7).
- SHA-пиннинг actions по SHA и расширение классов C14 за названные брифом
  (email, IP, телефоны, приватные хостнеймы, third-party prompt-маркеры) —
  кандидаты backlog при появлении потребности — why: потребность не
  возникла (supply-chain требований нет, живых утечек новых классов нет);
  до того отслеживаются пунктами `## Out of scope` этого плана (при
  появлении потребности — строка backlog).
