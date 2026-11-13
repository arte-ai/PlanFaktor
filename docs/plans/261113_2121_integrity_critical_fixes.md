# Целостность конвейера: merge-шаг, селекция статусов, needs-fix-переход, роль-доки, куратор, пост-ребилд миграции

**Plan ID:** 261113_2121
**Status:** Merged
**Created:** 2026-11-13
**Owner gates:** merge (`In review` → `Merged`); вопросы `to=Owner` — по мере возникновения

> Шапка — parser-контракт: строки выше grep'аются Manager'ом. Не менять формат.
> Имя файла: `261113_2121_integrity_critical_fixes.md`.

## Как я понял задачу
<!-- owner: architect; 3–7 строк; обязательна при Architect intake -->

Исполняю итоги внешнего аудита целостности конвейера: девять
подтверждённых дефектов в трёх классах — merge-рутина (`git add -A`
захватывает постороннее, прецедент eeb7c22), статусная машина (селекция
run.md теряет Draft/Merged/Planning, needs-fix-переход не описан в §2,
конфликты авторов и местоположения возражений) и контрактная гигиена
(формат CENSOR-receipt в роль-доках, легализация кураторских черновиков,
незафиксированные пост-ребилд дрейфы контрактов, позиционная открытость
Q&A, коллизия Plan-ID). Правки куратора, применённые сегодня (коммит
5ec7287), дефектами не считаются и в Problem не входят. План идёт первым
из пяти черновиков (переходом в `Ready for Planner` до остальных —
очередью управляют переходы статусов); техдолг merge-untracked-guard
промоутится этим планом из backlog. Пересборка/force-push истории не
делается — только компенсирующие записи и честные оговорки. Кураторский
черновик моих секций перепринят этой итерацией по существу: все девять
пунктов Problem перепроверены мной grep/shasum/git по текущему дереву,
не rubber-stamp.

## Problem
<!-- owner: architect; пронумерованные пункты -->

1. **Merge-шаг слеп к посторонним файлам** (S1).
   `.zcode/commands/planfaktor-run.md:135` — после Owner-«да»
   `git add -A && git commit` коммитит всё рабочее дерево. §8 декларирует
   обратное: «изменения стейджит Coder… Ревью смотрит staged-изменения
   против HEAD» — но merge-команда индекс не использует. Прецедент:
   dangling-коммит eeb7c22 (первый merge 261112_2236, 2026-11-13 02:23:45)
   захватил 5-минутный untracked Draft плана 261113_0217 (141 строка в
   `--stat`), вылечен amend bce3fb3 (rebuilt-эквивалент 70178a7 — 0217
   в составе нет). Сейчас в дереве 5 untracked-планов (четыре
   Draft-черновика + этот; на момент аудита было ещё 8 unstaged-правок —
   к перепринятию 2026-11-13 23:31 tracked-дерево чисто, коммиты
   88926a2/5ec7287) — любой merge по текущей команде повторяет класс.
   Backlog-строка `id=merge-untracked-guard`
   (backlog.md:18, P2, status=open) открыта.
2. **Селекция run.md теряет три статуса** (S2). Шаг 1 (`run.md:14-17`)
   выбирает активный только среди `Ready for *` / `In progress` /
   `In review` → строки routing-таблицы `Draft` (:23) и `Merged` (:28)
   недостижимы: план 261112_2236 завис в `Merged` — closeout сегодня
   выполнен куратором руками, минуя команду (Evidence 21:21:47 того
   плана); строки `Planning` в таблице нет вовсе — план в статусе
   `Planning` (после intake Planner'а) селекцией не выбирается: «таких
   нет» → «новый план или доложи состояние», застрявший план. Конфликт
   «несколько активных»: `AGENTS.md:83-85` «старейший… Один план в
   активной работе» vs `run.md:16-17` «Несколько активных — стоп,
   спроси Owner» — две несовместимые нормы об одном случае.
3. **needs-fix-переход не описан и конфликтен** (S2). Таблица §2
   (`AGENTS.md:55-64`) не содержит перехода `In review → In progress`.
   Автор статуса конфликтует: `run.md:138` — Manager ставит («статус
   `In progress`… диспатчи Coder»), `coder.md:88-89` — Coder («статус
   обратно `**Status:** In progress`»). Местоположение возражений
   конфликтует: `reviewer-contracts.md:50` и `lifecycle.md:62` —
   «возражения в Objections log», `run.md:138` — «возражения уже
   в артефакте». Objections log пуст во всех 12 планах (grep `^###` по
   секции → 0 везде): ревьюерам туда писать нельзя (их зона —
   review-артефакт), CENSOR-FAIL-возражения (`§4`) — другое назначение;
   живых needs-fix-возражений в логе не было ни разу.
4. **Роль-доки расходятся с каноном §4 и §3** (S2). Формат CENSOR-receipt
   без TS-префикса: `architect.md:52`, `planner.md:64`, `coder.md:70`
   (`(Role CENSOR) OK:` без `- YYYY-MM-DD HH:MM:SS — `) — против канона
   `AGENTS.md:141` и grep-гейта `run.md:81`; класс инцидента —
   `261111_0427`: первый receipt (строка 395 плана) записан без префикса,
   два следующих (:406, :436) — уже с ним. Скопированные блоки §4
   (CENSOR-проход) не несут пометки `DUPLICATE OF AGENTS.md §N —
   синхронизировать при правке` — правило `docs/roles/_template.md`
   (раздел «Анти-дрейф»). Intake-секции всех 5 роль-доков
   (`architect.md:25-27`, `planner.md:26-30`, `coder.md:31-34`,
   `reviewer-risk.md:29-31`, `reviewer-contracts.md:32-34`) называют три
   NO-записи, но не упоминают саму contract-строку intake с digest'ами
   (§3 п.3) — носитель механизма миграции §3 п.7 роль-доком не
   транслируется.
5. **Обёртка reviewer-contracts противоречит стоп-лайну** (S2).
   `.zcode/agents/planfaktor-reviewer-contracts.md:20-21` велит при
   отсутствии артефакта создать его из `docs/reviews/_template_review.md`;
   роль-док `reviewer-contracts.md:72-73` и `lifecycle.md:58-59` — стоп
   («Артефакта ревью нет… → стоп, вопрос Manager'у: твой лан второй»;
   «risk-лайн создаёт»). Отсутствие артефакта — сбой последовательности
   лейнов, а не задача contracts-лана; обёртка маскирует сбой.
6. **Кураторская практика не легализована** (S2). §1 «Manager не пишет
   план» + write-surface (a)–(f) (`AGENTS.md:24-42`) не имеют ветки для
   черновиков внешней сессии; §10 (`AGENTS.md:247-249`) — «Параллельные
   сессии не трогают планы и статусы». При этом кураторская сессия
   систематически пишет черновики секций с честной атрибуцией: слово
   «кураторск» — 41 упоминание в 12 планах (grep, перепринятие
   2026-11-13 23:31; на момент аудита 30 в 11 — счёт вырос созданием
   этого плана и closeout-узлом 2236), включая 4 текущих
   Draft (1642, 1644, 1943, 1944) и этот план (Evidence 21:21:47); роли
   перепринимают зоны, не rubber-stamp (прецедент-паттерн — 0217,
   Evidence 11:11:09). Каждый прецедент по букве — нарушение §1/§10.
7. **Незафиксированные пост-ребилд дрейфы контрактов** (S2). Сверка
   shasum 2026-11-13 21:26: `AGENTS.md` — последняя запись §3 п.7 =
   `@34563f1a` (план 0217, Evidence 12:36:55, r1), диск = `7ec6d0f4`
   (в rebuilt-истории значение появляется в fdef7a2);
   `.zcode/commands/planfaktor-status.md` — последняя = `@55a9284f`
   (0217, 12:19:45/12:21:35), диск = `28731042`. Два живых дрейфа после
   санитизации/пересборки 2026-11-13 без миграционных записей. Третий
   случай аудита — `docs/reviews/_template_review.md@0d20454a→a3452456`:
   по сверке смена произошла до пересборки (в рамках плана 2236) и
   записана в его Evidence 01:25:12 (2236:301); в текущем дереве запись
   совпадает с диском (`a3452456`) — живого дрейфа нет, случай
   документируется как прецедент «дрейф до пересборки». `README.md` и
   `CONTRIBUTING.md` не содержат оговорки, что история пересобрана;
   compliance-маппинг 4.13 (`docs/compliance/gost-r-56939-2024.md:25`)
   заявляет «контроль версий… сквозная трасса» без оговорки о
   воспроизведённой истории.
8. **Q&A-открытость позиционна и grep слеп** (S3, дешёво). Открытость
   определяется положением строк: `run.md:42-48` «Q… ниже которой нет
   закрывающей A-строки» — одна A формально «закрывает» все Q выше;
   идентификаторов у вопросов нет. Статус-команда `status.md:14` — голый
   `grep -n 'to=Owner'`: закрытые вопросы показывает как открытые,
   `needs_owner: yes` без `to=Owner` — пропускает. Будущий qa-lint
   (backlog `id=qa-lint`, backlog.md:13) потребует машинную грамматику —
   определять её надо до линта.
9. **Plan-ID-коллизия** (S3). `planfaktor-plan.md:8` —
   `date +%y%m%d_%H%M` без проверки существования файла; прецедент
   ручного разведения — планы 1943/1944 (соседние минуты одной сессии).

## Solution / Decisions
<!-- owner: architect; решения уровня «что и почему», без детализации -->

1. **Merge-коммит по явному списку.** После Owner-«да» Manager: (а)
   контроли до коммита — `git diff --name-only` пуст (нет unstaged-дрейфа)
   и `git status --porcelain` не содержит посторонних untracked, кроме
   `<PlanID>*.md` и `docs/reviews/<PlanID>_review.md`; нарушение — стоп
   fail loud с докладом Owner; (б) коммит из staged-индекса (предмет
   ревью по §8 — уже staged) + явный `git add` плана и review-артефакта;
   (в) канонизация состава: contracts-вердикт вносит список
   `git diff --cached --name-only` дословно в Итог артефакта — Manager
   сверяет merge-коммит со списком (notice ≠ mutation truth).
   Альтернатива write-tree-хэш (предложена аудитом) отклонена: требует
   многошагового временного индекса (GIT_INDEX_FILE/commit-tree),
   исключений больше, чем «план + review», усложняет рутину Manager'а,
   не добавляя инварианта сверх списка. Самоприменение: merge-коммит
   этого плана — по явному списку, четыре Draft-черновика не
   захватываются. Backlog-строка `merge-untracked-guard` →
   `plan=261113_2121, status=promoted`; `docs/followups/index.md`
   пересобрать.
2. **Селекция: Merged + Draft-резюма + строка Planning; унификация
   «несколько активных».** `AGENTS.md` §2 и `run.md` шаг 1: селекция +=
   `Merged` (closeout-ветка — зависший `Merged` сегодня требовал ручной
   операции куратора). `Draft` резюмируется по указанию Owner (механика
   запуска текущих пяти черновиков: этот план первым, остальные четыре
   остаются Draft — управление очередью через переходы). Routing-таблица
   += строка `Planning` (Planner работает по плану: intake → DoD/Tests —
   план не теряется между диспатчами одной фазы). Конфликт «несколько
   активных»: конституция — авторитет («старейший», `AGENTS.md:83-85`);
   `run.md` убирает дубль-стоп «спроси Owner», оставляет контроль
   «>1 активного — доложи Owner информационно». `docs/plans/README.md` —
   навигационная копия правила очереди, синхронно.
3. **needs-fix-переход закреплён за Coder'ом.** §2 += строка
   `In review → In progress | Coder | needs-fix (blocker/major у лейнов;
   возражения — в review-артефакте)`. `run.md:138`: Manager статус не
   ставит — диспатчит Coder'а с TASK на fixes; Coder ставит
   `In progress` на intake fixes-итерации (уже так в `coder.md:88-89`).
   `reviewer-contracts.md:50` и `lifecycle.md:62`: местоположение
   возражений — review-артефакт. Objections log сохраняет назначение §4 —
   возражения CENSOR-FAIL ролей; его пустота в needs-fix-циклах — норма,
   не дефект.
4. **Роль-доки к канону.** TS-префикс `- YYYY-MM-DD HH:MM:SS — ` в трёх
   receipt-блоках (architect/planner/coder — форма §4 дословно); пометка
   `DUPLICATE OF AGENTS.md §4 — синхронизировать при правке` на
   скопированных §4-блоках (architect/planner/coder; у ревьюеров
   CENSOR-блока нет — пометок не появляется); Intake-секции всех 5 доков
   упоминают contract-строку
   `Intake (…): AGENTS.md@<8hex> <role>.md@<8hex>` (§3 п.3) — носитель
   миграции транслируется роли-доком.
5. **Обёртка reviewer-contracts — стоп-лайн.** «Артефакта нет → стоп,
   вопрос Manager'у» (выравнивание с `reviewer-contracts.md:72-73`):
   risk-лайн создаёт артефакт, отсутствие = сбой последовательности.
   Остальные обёртки `.zcode/agents/` не трогаются.
6. **Легализация кураторских черновиков.** §1 write-surface += (g):
   черновик секций внешней (кураторской) сессии по прямому указанию
   Owner — только в статусе `Draft`, до первого intake роли; роли
   перепринимают зоны (не rubber-stamp, прецедент-паттерн 0217:11:11:09);
   создание фиксируется Evidence-записью (уже практика: 0217:02:17:00,
   этот план 21:21:47). §10 += симметричная оговорка: кураторская сессия
   не трогает планы вне `Draft` и статусы. Почему: практика реальна,
   полезна (Owner-бриф длиннее диспатча) и честно атрибутирована — вне
   контракта она делает каждый прецедент формальным нарушением.
7. **Пост-ребилд честность.** Компенсирующие миграционные записи в
   Evidence этого плана: `AGENTS.md: @34563f1a → @7ec6d0f4`,
   `.zcode/commands/planfaktor-status.md: @55a9284f → @28731042` —
   с пометкой «вне конвейера, санитизация/пересборка 2026-11-13»;
   `docs/reviews/_template_review.md: @0d20454a → @a3452456` —
   прецедентная запись с пометкой «вне конвейера… дрейф до пересборки»
   (запись 2236:301 в текущем дереве есть и совпадает с диском; запись
   здесь фиксирует событие аудита, а не живой дрейф). `README.md` +
   `CONTRIBUTING.md`: оговорка «история пересобрана 2026-11-13 из
   санитизированного архива; коммиты до 34481ff — воспроизведение
   работы, даты коммитов — время пересборки». Compliance 4.13 — одна
   строка: история VCS воспроизводит работу, а не фиксирует её в реальном
   времени.
8. **Идентификаторы Q&A.** Грамматика: `Q(<роль>#<n>): <текст>
   to=Owner|to=<роль>, blocker: yes|no, needs_owner: yes|no,
   status=open` / `A(<кто>#<n>): <ответ> status=closed, перенесено в
   <секция>`; открытость = Q#n, ниже которой нет парной A#n; якорь
   `^- Q\(` и §3-форма скобок сохраняются (экранированная форма —
   прецедент 0217 r1). Носители: `AGENTS.md` §3 п.4, комментарий
   Q&A-секции `_template.md`, механика чистого Q&A `run.md:42-48`, шаг 2
   `status.md` (пары Q#n→A#n вместо голого `to=Owner`). Исторические
   планы (до этого плана) читаются позиционно — переходный период как
   cutoff. Строка backlog `qa-lint` дополняется: будущий линт берёт
   новую грамматику.
9. **Plan-ID без коллизии.** `planfaktor-plan.md` шаг 2 += «файл с таким
   Plan ID уже существует → следующая минута» (ID созданного плана не
   меняется).

## Scope
<!-- owner: architect (границы), planner (уточняет); список изменений; пункты, реализующие внешние требования, несут метку [R: <ID>] (ID — из docs/requirements/registry.md) -->

- `.zcode/commands/planfaktor-run.md` — п.1 (merge по явному списку +
  контроли), п.2 (селекция += `Merged`, Draft-резюма, строка
  `Planning`, унификация «несколько активных»), п.3 (needs-fix:
  Manager диспатчит, не ставит статус), п.8 (механика чистого Q&A по
  Q#n→A#n).
- `AGENTS.md` — п.2 (§2: очередь += `Merged`), п.3 (§2: строка
  `In review → In progress`), п.6 (§1 write-surface (g); §10 оговорка),
  п.8 (§3 п.4 грамматика `#<n>`).
- `docs/roles/architect.md`, `docs/roles/planner.md`,
  `docs/roles/coder.md` — п.4 (TS-префикс receipt, пометка
  `DUPLICATE OF AGENTS.md §4`); все 5 роль-доков (включая
  `reviewer-risk.md`, `reviewer-contracts.md`) — п.4 (contract-строка
  intake в Intake-секции).
- `docs/roles/reviewer-contracts.md` — п.3 (возражения — в
  review-артефакте), п.1 (список `git diff --cached --name-only`
  дословно в Итог).
- `.zcode/agents/planfaktor-reviewer-contracts.md` — п.5 (стоп-лайн
  вместо создания артефакта).
- `docs/lifecycle.md` — п.3 (выравнивание местоположения возражений).
- `docs/plans/_template.md` — п.8 (комментарий Q&A-секции: форма
  `Q(<роль>#<n>)` / `A(<кто>#<n>)`).
- `.zcode/commands/planfaktor-status.md` — п.8 (шаг 2: пары Q#n→A#n).
- `.zcode/commands/planfaktor-plan.md` — п.9 (+1 строка проверки
  коллизии).
- `docs/reviews/_template_review.md` — п.1 (Итог: дословный список
  staged).
- `docs/followups/backlog.md` — п.1: **промоушен
  `merge-untracked-guard`** (`plan=261113_2121, status=promoted`); п.8:
  примечание к `qa-lint` о новой грамматике. `docs/followups/index.md`
  — пересборка derived-индекса.
- `README.md`, `CONTRIBUTING.md` — п.7 (оговорка о пересборке истории).
- `docs/compliance/gost-r-56939-2024.md` — п.7 (одна строка к 4.13).
- `docs/plans/README.md` — п.2 (очередь: `Ready for *` / `In progress` /
  `In review` / `Merged` — навигационная копия правила §2), п.3 (таблица
  «Статусная машина» += строка `In review → In progress`) — *planner-уточнение
  2026-11-13: файл назван носителем в Solution п.2; его норма «таблица —
  навигационная копия §2 … при правке §2 обновляется здесь же» требует
  синхронизации обеих поверхностей; решения не меняет.*
- `docs/reviews/_template_review.md` — дополнение к строке выше (п.1):
  п.3 (строка «Итог»: needs-fix → возражения — в review-артефакте, не
  Objections log) — *planner-уточнение 2026-11-13: файл уже в Scope по п.1;
  его строка Итога дословно предписывает Coder'у искать возражения в
  Objections log плана — прямое противоречие Solution п.3, устраняется
  той же правкой файла; решения не меняет.*
- Носители: этот план + review-артефакт
  `docs/reviews/261113_2121_review.md`.
- Миграционные записи §3 п.7 по всем изменённым контрактам:
  `AGENTS.md`, `docs/plans/_template.md`,
  `docs/reviews/_template_review.md`, 5 роль-доков, 3 команды
  `.zcode/commands/*`, консервативно обёртка
  `.zcode/agents/planfaktor-reviewer-contracts.md`; плюс компенсирующие
  пост-ребилд записи п.7.
- НЕ меняются: исторические планы/ревью (append-only; Q&A до cutoff
  читается позиционно), стоп-матрица §6, merge-гейт, обёртки четырёх
  остальных агентов.

## Out of scope
<!-- owner: architect -->

- Пересборка/force-push git-истории — решение «не делаем»; только
  компенсирующие записи и оговорки (п.7).
- Судьба локальной ветки main-leak — решение Owner, вне файлового
  корпуса.
- Механики черновиков 1642/1644/1943/1944 — зоны соседних черновиков;
  этот план не трогает их секции (граница: grep-база Problem ссылается
  на них только как на прецеденты/факты дерева).
- Новые lint-чеки: qa-lint (`id=qa-lint`), ci-v2-static
  (`id=ci-v2-static`), lint-robustness — остаются backlog; будущий
  qa-lint берёт грамматику п.8.
- Обёртки остальных агентов `.zcode/agents/` — правятся только при
  содержательных причинах (прецедент п.5 — единственный
  подтверждённый).
- Уже исправленное куратором сегодня: Owner-гейт старта в
  requirements/README, coder-агент «после Owner-гейта», lifecycle «на
  раунд»/Token usage, playbook Token usage, backlog
  closeout-tail-convention (формулировка + why=), corpus.yml комментарий,
  closeout 261112_2236 — дефектами не считаются, правок не требуют.

## Acceptance criteria / DoD
<!-- owner: planner; чек-лист проверяемых исходов; каждый пункт = проверяемое утверждение; пункты, реализующие внешние требования, несут метку [R: <ID>] (ID — из docs/requirements/registry.md) -->

- [ ] D1 `.zcode/commands/planfaktor-run.md`, pass-ветка Owner-гейта (шаг 4): `git add -A && git commit` заменён merge-рутиной по явному списку — (а) контроли до коммита: `git diff --name-only` пуст и `git status --porcelain` без посторонних untracked, кроме `<PlanID>*.md` и `docs/reviews/<PlanID>_review.md`; нарушение контроля — стоп fail loud с докладом Owner, без коммита; (б) коммит из staged-индекса (предмет ревью по §8) плюс явный `git add` плана и review-артефакта (Solution п.1(а,б)).
- [ ] D2 Канонизация состава (Solution п.1(в)): `docs/roles/reviewer-contracts.md` — Итог артефакта обязан содержать дословный список `git diff --cached --name-only`; `docs/reviews/_template_review.md` — секция «Итог» несёт инструкцию/поле для дословного списка staged; `.zcode/commands/planfaktor-run.md` — merge-ветка предписывает Manager'у сверку merge-коммита со списком из Итога (notice ≠ mutation truth).
- [ ] D3 Промоушен `merge-untracked-guard` (Solution п.1): `docs/followups/backlog.md` — строка `id=merge-untracked-guard` получила `plan=261113_2121` и `status=promoted`; `docs/followups/index.md` пересобран: строка ушла из P2-таблицы открытых, появилась в «Закрытых», счётчик «открытых — 11, закрытых — 1».
- [ ] D4 Самоприменение (Solution п.1): merge-коммит ЭТОГО плана — гейт-действие Manager (не Coder-фаза), по явному списку, без четырёх Draft-черновиков (261113_1642/1644/1943/1944); проверяется на merge-гейте осмотром `git show --stat` против списка Итога; Coder обеспечивает только текст рутины (D1/D2), отдельной правки не требует.
- [ ] D5 `.zcode/commands/planfaktor-run.md` шаг 1 (Solution п.2): селекция активного плана включает `Merged` (closeout-ветка routing-таблицы достижима); `Draft` резюмируется по указанию Owner (управление очередью через переходы); routing-таблица дополнена строкой `Planning`; «несколько активных» унифицировано: дубль-стоп «спроси Owner, какой вести» убран, норма — старейший (конституция §2 авторитет) с информационным докладом Owner при >1 активного.
- [ ] D6 `AGENTS.md` §2 (Solution п.2, п.3): «Порядок очереди» — старейший план в статусе `Ready for *` / `In progress` / `In review` / `Merged`; таблица переходов дополнена строкой `In review → In progress | Coder | needs-fix (blocker/major у лейнов; возражения — в review-артефакте)`.
- [ ] D7 needs-fix за Coder'ом (Solution п.3): `.zcode/commands/planfaktor-run.md` needs-fix-ветка — Manager статус не ставит, диспатчит Coder с TASK на fixes; `docs/roles/reviewer-contracts.md` (Зона/Фаза 5), `docs/lifecycle.md` (In review), `docs/reviews/_template_review.md` (Итог) — местоположение возражений: review-артефакт, не Objections log; `docs/roles/coder.md` — строка «статус обратно `**Status:** In progress`» не изменяется (уже канон, сверка); назначение Objections log по §4 (CENSOR-FAIL) сохраняется — `## Objections log` остаётся в §5-перечне append-only.
- [ ] D8 Роль-доки к канону (Solution п.4): receipt-блоки `docs/roles/architect.md`, `docs/roles/planner.md`, `docs/roles/coder.md` — форма §4 дословно, первая строка блока с TS-префиксом `- YYYY-MM-DD HH:MM:SS — (Role CENSOR) ...`; на скопированных §4-блоках этих трёх доков — пометка `DUPLICATE OF AGENTS.md §4 — синхронизировать при правке`; Intake-секции всех 5 роль-доков упоминают contract-строку `Intake (...): AGENTS.md@<8hex> <role>.md@<8hex>` (§3 п.3); у reviewer-risk/reviewer-contracts CENSOR-блока нет — пометки не появляются.
- [ ] D9 `.zcode/agents/planfaktor-reviewer-contracts.md` (Solution п.5): ветка «при отсутствии артефакта — создать из шаблона» заменена стоп-лайном «артефакта нет → стоп, вопрос Manager'у: risk-лайн создаёт артефакт, отсутствие = сбой последовательности лейнов»; остальные 4 обёртки `.zcode/agents/` не тронуты.
- [ ] D10 `AGENTS.md` (Solution п.6): §1 write-surface дополнен пунктом (g) — черновик секций внешней (кураторской) сессии по прямому указанию Owner: только в статусе `Draft`, до первого intake роли; роли перепринимают зоны (не rubber-stamp); создание фиксируется Evidence-записью; §10 дополнен симметричной оговоркой — кураторская сессия не трогает планы вне `Draft` и статусы.
- [ ] D11 Компенсирующие пост-ребилд записи (Solution п.7) в `## Evidence` этого плана: `AGENTS.md: @34563f1a → @7ec6d0f4` и `.zcode/commands/planfaktor-status.md: @55a9284f → @28731042` с пометкой «вне конвейера, санитизация/пересборка 2026-11-13»; `docs/reviews/_template_review.md: @0d20454a → @a3452456` — прецедентная запись с пометкой «вне конвейера, дрейф до пересборки».
- [ ] D12 Пост-ребилд оговорки (Solution п.7): `README.md` и `CONTRIBUTING.md` — оговорка «история пересобрана 2026-11-13 из санитизированного архива; коммиты до 34481ff — воспроизведение работы, даты коммитов — время пересборки»; `docs/compliance/gost-r-56939-2024.md`, пункт 4.13 — строка о том, что история VCS воспроизводит работу, а не фиксирует её в реальном времени.
- [ ] D13 Идентификаторы Q&A (Solution п.8): `AGENTS.md` §3 п.4, комментарий Q&A-секции `docs/plans/_template.md`, механика чистого Q&A `.zcode/commands/planfaktor-run.md`, шаг 2 `.zcode/commands/planfaktor-status.md` — грамматика `Q(<роль>#<n>): ...` / `A(<кто>#<n>): ... status=closed`, открытость = Q#n, ниже которой нет парной A#n; якорь `^- Q\(` и §3-форма скобок сохранены; в механику run.md внесена оговорка переходного периода: исторические планы (до 261113_2121) читаются позиционно; `docs/followups/backlog.md` `id=qa-lint` дополнен примечанием — будущий линт берёт грамматику `#<n>`.
- [ ] D14 `.zcode/commands/planfaktor-plan.md` (Solution п.9): шаг 2 дополнен проверкой коллизии Plan ID — файл с таким Plan ID уже существует → следующая минута; ID созданного плана не меняется.
- [ ] D15 Миграционные записи §3 п.7 в `## Evidence` этого плана по каждому изменённому контракту — 12 файлов: `AGENTS.md`, `docs/plans/_template.md`, `docs/reviews/_template_review.md`, `docs/roles/architect.md`, `docs/roles/planner.md`, `docs/roles/coder.md`, `docs/roles/reviewer-risk.md`, `docs/roles/reviewer-contracts.md`, `.zcode/commands/planfaktor-run.md`, `.zcode/commands/planfaktor-status.md`, `.zcode/commands/planfaktor-plan.md`, `.zcode/agents/planfaktor-reviewer-contracts.md`; формат — `<файл>: старый@8hex → новый@8hex` одной строкой, с меткой времени (§3 п.7).
- [ ] D16 Регрессионный инвариант: `./scripts/check_corpus.sh` → итог `corpus: clean`; `./scripts/check_corpus.sh --selftest` → `selftest: 15/15 caught` (база проходит — правки не ломают; в т.ч. C9 — пути в новой прозе существуют, C3/C8 — заголовки секций шаблонов не изменены, заголовок Q&A-секции и её owner-метка на месте).

## Tests / Commands
<!-- owner: planner (задаёт), coder (заполняет факт); каждый DoD-пункт (Dn) покрывается строкой с меткой (Dn); R-DoD — обязательно -->

Команды — из корня репо; «база» — значение на момент Planner-фазы (2026-11-13 23:44–23:5x), снятое grep'ом по текущему дереву; помечено, различающий якорь или инвариант.

- T1 (D1): `grep -c 'git add -A' .zcode/commands/planfaktor-run.md` → 0 (база 1 — различающий); `grep -c 'porcelain' .zcode/commands/planfaktor-run.md` → ≥1 (база 0 — различающий); `grep -c -- '--name-only' .zcode/commands/planfaktor-run.md` → ≥1 (база 0 — различающий; покрывает оба контроля: unstaged-дрейф и staged-список).
- T2 (D2): `grep -c -- 'git diff --cached --name-only' docs/roles/reviewer-contracts.md` → ≥1 (база 0); `grep -c -- 'git diff --cached --name-only' docs/reviews/_template_review.md` → ≥1 (база 0); `grep -c 'Итог' .zcode/commands/planfaktor-run.md` → ≥1 (база 0 — различающий; merge-ветка ссылается на список из Итога).
- T3 (D3): `grep 'id=merge-untracked-guard' docs/followups/backlog.md | grep -c 'status=promoted'` → 1 (база 0); `grep 'id=merge-untracked-guard' docs/followups/backlog.md | grep -c 'plan=261113_2121'` → 1 (база 0); `sed -n '/^### P2/,/^### P3/p' docs/followups/index.md | grep -c 'merge-untracked-guard'` → 0 (база 1); `sed -n '/^## Закрытые/,$p' docs/followups/index.md | grep -c 'merge-untracked-guard'` → ≥1 (база 0); `grep -c 'открытых — 11' docs/followups/index.md` → 1 (база: «открытых — 12, закрытых … — 0»).
- T4 (D4): гейт-проверка Manager на merge-шаге (после Coder-фазы, по инструкции D1/D2): `git show --stat <merge-sha> | grep -cE '261113_(1642|1644|1943|1944)'` → 0; состав merge-коммита = дословный список Итога review-артефакта + план + review-артефакт. Coder в своей фазе фиксирует в Tests только факт T1/T2 (текст рутины), гейт-исполнение не прогоняет и записью не дублирует (симметрично D10 плана 261113_0217).
- T5 (D5): `sed -n '/^## 1\./,/^## 2\./p' .zcode/commands/planfaktor-run.md | grep -cF 'Merged'` → ≥1 (база 0 — различающий; селекция шага 1); `grep -c 'резюмируется' .zcode/commands/planfaktor-run.md` → ≥1 (база 0); `grep -c '^| `Planning` |' .zcode/commands/planfaktor-run.md` → 1 (база 0); `grep -c 'спроси Owner, какой вести' .zcode/commands/planfaktor-run.md` → 0 (база 1); `grep -c 'доложи Owner информационно' .zcode/commands/planfaktor-run.md` → ≥1 (база 0).
- T6 (D6): `grep -cF '`In review` / `Merged`' AGENTS.md` → ≥1 (база 0 — различающий); `grep -cF 'In review → In progress' AGENTS.md` → 1 (база 0); `grep -cF '`In review` / `Merged`' docs/plans/README.md` → ≥1 (база 0); `grep -cF 'In review → In progress' docs/plans/README.md` → ≥1 (база 0 — навигационная копия §2, норма самого файла).
- T7 (D7): `grep -c 'Objections log' docs/roles/reviewer-contracts.md` → 0 (база 1); `grep -c 'Objections log' docs/reviews/_template_review.md` → 0 (база 1); `grep -c 'Objections log' docs/lifecycle.md` → 1 (база 2 — инвариант: §5-перечень append-only остаётся, needs-fix-упоминание уходит); `grep -cE 'не ставит статус|статус не ставит' .zcode/commands/planfaktor-run.md` → ≥1 (база 0 — различающий); `grep -c 'статус обратно' docs/roles/coder.md` → 1 (база 1 — инвариант не-правки); `grep -c 'Objections log' AGENTS.md` → 1 (база 1 — инвариант: назначение §4/§5 сохранено).
- T8 (D8): `grep -c 'HH:MM:SS — (Role CENSOR)' docs/roles/architect.md docs/roles/planner.md docs/roles/coder.md` → 1, 1, 1 (база 0/0/0 — различающий); `grep -c 'DUPLICATE OF AGENTS.md §4' docs/roles/architect.md docs/roles/planner.md docs/roles/coder.md` → 1, 1, 1 (база 0/0/0); `grep -c 'DUPLICATE OF AGENTS.md' docs/roles/reviewer-risk.md docs/roles/reviewer-contracts.md` → 0, 0 (инвариант: у ревьюеров CENSOR-блока нет); `grep -cF 'AGENTS.md@' docs/roles/architect.md docs/roles/planner.md docs/roles/coder.md docs/roles/reviewer-risk.md docs/roles/reviewer-contracts.md` → ≥1 у каждого (база 0/0/0/0/0 — различающий).
- T9 (D9): `grep -c 'создать' .zcode/agents/planfaktor-reviewer-contracts.md` → 0 (база 1 — различающий); `grep -c 'risk-лайн созда' .zcode/agents/planfaktor-reviewer-contracts.md` → ≥1 (база 0); `git diff --cached --name-only -- .zcode/agents/` → ровно одна строка `planfaktor-reviewer-contracts.md` (инвариант: остальные 4 обёртки не тронуты).
- T10 (D10): `grep -cF '(g)' AGENTS.md` → ≥1 (база 0 — различающий); `grep -c 'куратор' AGENTS.md` → ≥2 (база 0 — §1(g) + §10).
- T11 (D11): `sed -n '/^## Evidence/,/^## Token usage/p' docs/plans/261113_2121_integrity_critical_fixes.md | grep -cE '@34563f1a → @7ec6d0f4|@55a9284f → @28731042|@0d20454a → @a3452456'` → 3 (база 0 в Evidence-секции; те же пары в Solution п.7 скоуп-вырезкой исключаются); каждая из трёх записей несёт пометку «вне конвейера» (осмотр).
- T12 (D12): `grep -c 'пересобрана' README.md CONTRIBUTING.md` → ≥1, ≥1 (база 0/0); `grep -c '34481ff' README.md CONTRIBUTING.md` → ≥1, ≥1 (база 0/0); `grep -c 'воспроизводит работу' docs/compliance/gost-r-56939-2024.md` → ≥1 (база 0 — различающий).
- T13 (D13): `grep -c '#<n>' AGENTS.md docs/plans/_template.md .zcode/commands/planfaktor-run.md` → ≥1, ≥1, ≥1 (база 0/0/0 — различающий); `grep -cE 'Q#|A#' .zcode/commands/planfaktor-status.md` → ≥1 (база 0); `grep -c 'status=open' .zcode/commands/planfaktor-run.md` → ≥1 (база ≥1 — инвариант: якорная §3-форма Q-строки сохранена); `grep 'id=qa-lint' docs/followups/backlog.md | grep -c '#<n>'` → 1 (база 0).
- T14 (D14): `grep -c 'уже существует' .zcode/commands/planfaktor-plan.md` → ≥1 (база 0 — различающий).
- T15 (D15): `sed -n '/^## Evidence/,/^## Token usage/p' docs/plans/261113_2121_integrity_critical_fixes.md | grep -cE '@[0-9A-Fa-f]{8} → @[0-9A-Fa-f]{8}'` → ≥15 (база 0: 12 миграционных записей D15 + 3 компенсирующих D11; скоуп-вырезка секцией Evidence исключает те же пары из Solution п.7 — там они записаны, но вне Evidence, база это подтверждает).
- T16 (D16): `./scripts/check_corpus.sh | tail -1` → `corpus: clean`; `./scripts/check_corpus.sh --selftest | tail -1` → `selftest: 15/15 caught` (база проходит — регрессионный инвариант).
- T17 (D4, граница Scope): `git diff --cached --name-only | grep -cE '261113_(1642|1644|1943|1944)|2611(10|11|12)_'` → 0 (staged не содержит ни исторических планов `261110–261112_*` — Plan ID из шести цифр YYMMDD, ни соседних Draft `261113_*`; сам `261113_2121` паттерном не задет — проверено Planner'ом на фактических именах файлов); `git diff --cached --name-only | sort` — осмотр: состав = файлы Scope (15 контрактов + backlog/index + README/CONTRIBUTING/compliance + этот план), ничего лишнего.

Факты прогонов (Coder, 2026-11-14 00:01, из корня репо, финальный срез после всех правок):
- T1: `git add -A` → 0; `porcelain` → 1; `--name-only` → 2 — PASS.
- T2: `git diff --cached --name-only` в reviewer-contracts.md → 2; в _template_review.md → 1; `Итог` в run.md → 2 — PASS.
- T3: `status=promoted` → 1; `plan=261113_2121` → 1; P2-таблица index → 0; `## Закрытые` → 1; `открытых — 11` → 1 — PASS.
- T4: Coder-фазой не прогоняется (гейт-действие Manager на merge-шаге); факт текста рутины покрыт T1/T2 — PASS по регламенту теста.
- T5: селекция шаг 1 `Merged` → 2; `резюмируется` → 1; `^| \`Planning\` |` → 1; `спроси Owner, какой вести` → 0; `доложи Owner информационно` → 1 — PASS.
- T6: `` `In review` / `Merged` `` в AGENTS.md → 1; `In review → In progress` в AGENTS.md → 1; то же в docs/plans/README.md → 1 и → 1 — PASS.
- T7: Objections log в reviewer-contracts.md → 0; в _template_review.md → 0; в lifecycle.md → 1; `статус не ставит` в run.md → 1; `статус обратно` в coder.md → 1; Objections log в AGENTS.md → 1 — PASS.
- T8: `HH:MM:SS — (Role CENSOR)` → 1/1/1 (architect/planner/coder); `DUPLICATE OF AGENTS.md §4` → 1/1/1; у reviewer-risk/reviewer-contracts `DUPLICATE OF AGENTS.md` → 0/0; `AGENTS.md@` → 1 у каждого из 5 — PASS.
- T9: `создать` в обёртке → 0; `risk-лайн созда` → 1; staged по `.zcode/agents/` → ровно одна строка `planfaktor-reviewer-contracts.md` — PASS.
- T10: `(g)` → 2; `куратор` → 2 — PASS.
- T11: пары `@34563f1a → @7ec6d0f4` / `@55a9284f → @28731042` / `@0d20454a → @a3452456` в Evidence → 3; пометка «вне конвейера» — на каждой из трёх записей (осмотр) — PASS.
- T12: `пересобрана` → 1/1; `34481ff` → 1/1; `воспроизводит работу` → 1 — PASS.
- T13: `#<n>` → AGENTS.md 3, _template.md 1, run.md 5; `Q#|A#` в status.md → 2; `status=open` в run.md → 3 (якорная §3-форма сохранена); qa-lint `#<n>` → 1 — PASS.
- T14: `уже существует` → 1 — PASS.
- T15: пары `@8hex → @8hex` в Evidence → 15 (12 миграционных D15 + 3 компенсирующих D11) — PASS.
- T16: `./scripts/check_corpus.sh | tail -1` → `corpus: clean`; `--selftest | tail -1` → `selftest: 15/15 caught` — PASS.
- T17: паттерн `261113_(1642|1644|1943|1944)|2611(10|11|12)_` по staged → 0; осмотр `git diff --cached --name-only | sort`: ровно 20 строк — 12 контрактов D15 + docs/lifecycle.md + docs/plans/README.md + docs/followups/backlog.md + docs/followups/index.md + README.md + CONTRIBUTING.md + docs/compliance/gost-r-56939-2024.md + сам план; ничего лишнего — PASS.

Факты прогонов fixes-итерации раунда 1 (Coder, 2026-11-14 00:19, из корня репо, после правки контроля (а) merge-рутины; повторно прогнаны все Tests, зависящие от run.md, + регресс-инвариант + staged-контроль):
- T1: `git add -A` → 0; `porcelain` → 1; `--name-only` → 2 — PASS.
- T2: `Итог` в run.md → 2; `git diff --cached --name-only` в reviewer-contracts.md → 2; в _template_review.md → 1 — PASS.
- T5: селекция шаг 1 `Merged` → 2; `резюмируется` → 1; `^| \`Planning\` |` → 1; `спроси Owner, какой вести` → 0; `доложи Owner информационно` → 1 — PASS (правка в §4, шаг 1 не тронут).
- T7: Objections log в reviewer-contracts.md → 0; в _template_review.md → 0; в lifecycle.md → 1; `статус не ставит` в run.md → 1; `статус обратно` в coder.md → 1; Objections log в AGENTS.md → 1 — PASS.
- T13 (часть run.md): `#<n>` → 5; `status=open` → 3 — PASS.
- T16: `./scripts/check_corpus.sh` → `corpus: 1 failures` — FAIL C7 review-artifacts: `docs/reviews/261113_2121_review.md: malformed verdict line: ### Contracts verdict: pass | needs-fix`; `--selftest` → `selftest: baseline failed` (selftest требует чистый baseline). Причина вне fixes-итерации: корпус C7 — только `docs/reviews/[0-9]*.md`; артефакт создан risk-лайном 00:09:45 (после последнего чистого прогона T16 — CENSOR 00:06) и находится в промежуточном состоянии раунда (risk-вердикт записан, contracts-вердикт — плейсхолдер шаблона: contracts-лан по последовательности Manager'а ещё не заполнял); правки Coder'а (run.md, план) в корпус C7 не входят, иных FAIL в выводе нет — деградации от fixes-итерации нет. Ожидаемое закрытие: заполнение Contracts-вердикта в раунде 2 (вердикт-строка `pass`/`needs-fix` удовлетворяет regex C7); зафиксировано fail loud в Evidence 00:19.
- T17: паттерн по staged → 0; `git diff --cached --name-only | sort` — те же 20 файлов Scope (перезастейджены run.md и план; review-артефакт не staged — Coder его не менял, добавляется merge-рутиной шаг (в)) — PASS.
- Раунд-1 адресные (findings 1–2): `git diff --name-only` после стейджинга → пусто (finding 1: штатная unstaged-дельта плана теперь в исключении контроля и застейджена — ложный стоп невозможен); `git status --porcelain`: untracked — ровно 4 Draft-черновика очереди (`docs/plans/261113_1642/1644/1943/1944_*.md`, статус Draft) + review-артефакт — оба класса в исключениях контроля (а) (finding 2: самоприменение D4 достижимо, стоп не срабатывает) — PASS.

Факты прогонов fixes-итерации раунда 2 (Coder, 2026-11-14 00:33, из корня репо, после правки шага (г) merge-рутины):
- T1: `git add -A` → 0; `porcelain` → 1; `--name-only` → 2 — PASS.
- T2: `Итог` в run.md → 3 (было 2: (г) теперь упоминает список Итога дважды — сверка + оговорка); `git diff --cached --name-only` в reviewer-contracts.md → 2; в _template_review.md → 1 — PASS.
- T5: селекция шаг 1 `Merged` → 2; `резюмируется` → 1; `^| \`Planning\` |` → 1; `спроси Owner, какой вести` → 0; `доложи Owner информационно` → 1 — PASS.
- T7: Objections log в reviewer-contracts.md → 0; в _template_review.md → 0; в lifecycle.md → 1; `статус не ставит` в run.md → 1; `статус обратно` в coder.md → 1; Objections log в AGENTS.md → 1 — PASS.
- T13 (часть run.md): `#<n>` → 5; `status=open` → 3 — PASS.
- T16: `./scripts/check_corpus.sh` → `corpus: 1 failures` — тот же единственный FAIL C7 на плейсхолдере Contracts-вердикта review-артефакта (артефакт с раунда 1 не менялся, contracts-лан ещё не заполнял); правки раунда 2 (run.md) в корпус C7 не входят, новых FAIL нет — состояние отклонения неизменно с раунда 1, закроется Contracts-вердиктом.
- T17: паттерн по staged → 0; staged = 20 файлов Scope (после рестейджинга run.md и плана) — PASS.
- Раунд-2 адресный (finding 1): оговорка «санкционированные шагом (в) добавления (явный `git add` плана и review-артефакта; review-артефакт на момент contracts-вердикта не staged — ревьюеры не стейджат, в списке Итога его нет) расхождением не считаются; иное расхождение = захвачено постороннее» — на диске (run.md шаг (г)); инвариант сохранён: посторонний файл в коммите остаётся fail loud — PASS.

## Changes (by area)
<!-- owner: coder; фактические изменения по областям; заполняется в ходе работы -->

- **Merge-рутина (D1, D2, D4-текст)** — `.zcode/commands/planfaktor-run.md` шаг 4:
  pass-ветка Owner-гейта переписана с `git add -A && git commit` на рутину
  по явному списку: (а) контроли до коммита `git diff --name-only` пуст +
  `git status --porcelain` без посторонних untracked (кроме
  `<PlanID>*.md` и `docs/reviews/<PlanID>_review.md`), нарушение — стоп
  fail loud без коммита; (б) Evidence-записи и `Merged` до коммита; (в)
  коммит из staged-индекса + явный `git add` плана и review-артефакта
  (`docs/plans/<PlanID>_<topic>.md`, `docs/reviews/<PlanID>_review.md`);
  (г) сверка `git show --stat` merge-коммита с дословным списком
  `git diff --cached --name-only` из Итога review-артефакта.
  Канонизация состава (D2): `docs/roles/reviewer-contracts.md` — Зона и
  Фаза 5: Итог обязан нести дословный список
  `git diff --cached --name-only`; `docs/reviews/_template_review.md` —
  секция «Итог»: новый пункт «Состав staged» с дословным выводом
  `git diff --cached --name-only` и полем под список файлов.
- **Промоушен merge-untracked-guard (D3)** —
  `docs/followups/backlog.md`: строка `id=merge-untracked-guard`
  `[ ]`→`[x]`, `status=open`→`status=promoted`,
  `plan=none`→`plan=261113_2121` (summary/id/source_ref/why не тронуты —
  row-грамматика `_template.md`); `docs/followups/index.md` пересобран:
  счётчик «открытых — 11, закрытых — 1», P2 (6)→(5) со строкой
  merge-untracked-guard из таблицы открытых, строка появилась в
  «Закрытых»; qa-lint-строка индекса дополнена примечанием о грамматике
  `#<n>`.
- **Селекция и routing (D5)** — `.zcode/commands/planfaktor-run.md` шаг 1:
  селекция += `Merged` (closeout-ветка достижима), `Draft` — резюмируется
  по указанию Owner; routing-таблица += строка `Planning` (Planner в
  работе между intake и handoff); «несколько активных» унифицировано:
  дубль-стоп «спроси Owner, какой вести» убран, норма — старейший (§2) с
  информационным докладом Owner.
- **Статусная машина (D6)** — `AGENTS.md` §2: «Порядок очереди» +=
  `Merged`; таблица переходов += строка
  `| `In review → In progress` | Coder | needs-fix (blocker/major у лейнов; возражения — в review-артефакте) |`.
  `docs/plans/README.md` синхронно: правило очереди += `Merged` (с
  оговоркой closeout), навигационная копия таблицы += та же строка
  (норма файла: копия §2 обновляется при правке §2).
- **needs-fix за Coder'ом (D7)** — `.zcode/commands/planfaktor-run.md`
  шаг 4 needs-fix-ветка: Manager статус не ставит, диспатчит Coder с
  TASK на fixes; Coder ставит `In progress` на intake fixes-итерации.
  `docs/roles/reviewer-contracts.md` Фаза 5,
  `docs/reviews/_template_review.md` Итог, `docs/lifecycle.md` In review:
  местоположение возражений — review-артефакт (findings ланов), упоминания
  «Objections log» в needs-fix-контексте убраны (по одному у каждого из
  трёх носителей; §5-перечень append-only и упоминание в контексте
  авто-перехода у lifecycle.md:95 сохранены — назначение §4/§5 не тронуто;
  `docs/roles/coder.md` «статус обратно» не менялся — уже канон).
- **Роль-доки к канону (D8)** — `docs/roles/architect.md`,
  `docs/roles/planner.md`, `docs/roles/coder.md`: первая строка
  receipt-блока с TS-префиксом
  `- YYYY-MM-DD HH:MM:SS — (Role CENSOR) OK: ...` (форма §4 дословно);
  на секциях CENSOR-проход — пометка
  `> DUPLICATE OF AGENTS.md §4 — синхронизировать при правке.`. Все 5
  роль-доков (включая `reviewer-risk.md`, `reviewer-contracts.md`):
  Intake-секция упоминает contract-строку
  `Intake (YYYY-MM-DD HH:MM:SS): AGENTS.md@<8hex> <role>.md@<8hex>` как
  носитель миграции §3 п.7; у ревьюеров DUPLICATE-пометок нет (CENSOR-блока
  нет).
- **Обёртка reviewer-contracts (D9)** —
  `.zcode/agents/planfaktor-reviewer-contracts.md`: ветка «при
  отсутствии артефакта — создать из шаблона» заменена стоп-лайном
  «артефакта нет → стоп, вопрос Manager'у: risk-лайн создаёт артефакт,
  его отсутствие = сбой последовательности лейнов»; остальные 4 обёртки
  `.zcode/agents/` не тронуты.
- **Кураторские черновики (D10)** — `AGENTS.md` §1: write-surface +=
  (g) — черновик секций внешней (кураторской) сессии по прямому указанию
  Owner, только `Draft`, до первого intake роли, роли перепринимают зоны,
  создание — Evidence-записью; §10: симметричная оговорка — кураторская
  сессия не трогает планы вне `Draft` и статусы.
- **Пост-ребилд честность (D11, D12)** — Evidence этого плана: 3
  компенсирующие записи (AGENTS.md, planfaktor-status.md, — «вне
  конвейера, санитизация/пересборка 2026-11-13»; _template_review.md —
  «вне конвейера, дрейф до пересборки»). `README.md` + `CONTRIBUTING.md`:
  новая секция «История репозитория» с оговоркой «история пересобрана
  2026-11-13 из санитизированного архива; коммиты до 34481ff —
  воспроизведение работы, даты коммитов — время пересборки»;
  `docs/compliance/gost-r-56939-2024.md` 4.13: строка-оговорка «история
  VCS пересобрана 2026-11-13 … — воспроизводит работу, а не фиксирует
  её в реальном времени».
- **Идентификаторы Q&A (D13)** — `AGENTS.md` §3 п.4: грамматика
  `Q(<роль>#<n>)` / `A(<кто>#<n>)` + открытость Q#n без парной A#n +
  переходный период (позиционное чтение до 261113_2121); §2
  (авто-переход) синхронизирован на пары Q#n→A#n; комментарий Q&A-секции
  `docs/plans/_template.md`: формы `Q(<роль>#<n>)` / `A(<кто>#<n>)` +
  открытость по паре; механика чистого Q&A `.zcode/commands/planfaktor-run.md`:
  обе формы строк, пары Q#n→A#n, оговорка переходного периода (якорь
  `^- Q\(` и §3-форма `status=open` сохранены); шаг 2
  `.zcode/commands/planfaktor-status.md`: пары Q#n→A#n вместо голого
  `to=Owner` + позиционное чтение исторических планов;
  `docs/followups/backlog.md` `id=qa-lint`: примечание — будущий линт
  берёт машинную грамматику `Q(<роль>#<n>)` / `A(<кто>#<n>)` пар
  Q#n→A#n (Solution п.8).
- **Plan-ID-коллизия (D14)** — `.zcode/commands/planfaktor-plan.md` шаг 2:
  проверка «файл с таким Plan ID уже существует → следующая минута»;
  Plan ID созданного плана не меняется.
- **Миграции (D15)** — Evidence этого плана: 12 миграционных записей
  §3 п.7 по каждому изменённому контракту (старый@8hex → новый@8hex,
  одной строкой, с меткой времени) — AGENTS.md, _template.md,
  _template_review.md, 5 роль-доков, 3 команды .zcode/commands/*,
  обёртка planfaktor-reviewer-contracts.md.
- **Merge-рутина, needs-fix раунд 1 (D1/D4-текст — findings 1–2
  risk-лайна Round 1)** — `.zcode/commands/planfaktor-run.md` шаг 4,
  контроль (а): исключения обеих половин уточнены. Unstaged-половина
  (finding 1): `git diff --name-only` пуст, КРОМЕ дельты самого плана
  и его review-артефакта — append-only записи после финального
  стейджинга Coder'а (usage §1(f), intake ревьюеров, Evidence-узлы
  Manager'а) штатны, стейджатся шагом (в). Untracked-половина
  (finding 2): исключение расширено до Draft-черновиков других планов
  очереди (`docs/plans/[0-9]*.md` со статусом `Draft`; в merge-коммит
  не входят, перечисляются в докладе Owner информационно) —
  самоприменение D4 (merge без четырёх черновиков при их живом
  присутствии в дереве) достижимо по букве рутины. Стоп-ветка для иных
  нарушений и шаги (б)–(г) не менялись. DoD-текст D1 не правился (зона
  Planner): расширение исключений контроля — по вердикту risk-лайна
  needs-fix (review-артефакт Round 1, вердикт-строка).
- **Merge-рутина, needs-fix раунд 2 (D2-текст — finding 1 risk-лайна
  Round 2; промоушен предложения Coder'а из Suggestions log 00:16:44)** —
  `.zcode/commands/planfaktor-run.md` шаг 4(г): сверка состава
  merge-коммита (`git show --stat`) с дословным Итог-списком
  `git diff --cached --name-only` дополнена оговоркой — санкционированные
  шагом (в) добавления (явный `git add` плана и review-артефакта;
  review-артефакт на момент contracts-вердикта не staged, ревьюеры не
  стейджат, в списке Итога его нет) расхождением не считаются; иное
  расхождение = захвачено постороннее — fail loud сохранён. Ложный
  fail loud на штатном merge (21-й файл — review-артефакт) устранён,
  канонизация состава (D2) не ослаблена: посторонний файл в коммите
  остаётся стопом. Шаги (а)–(в) не менялись (подтверждены ланом Round 2
  в редакции раунда 1); DoD-текст не правился (зона Planner).

## Evidence (chronological, append-only)
<!-- owner: все роли + CENSOR; событийные записи с датой и локальным временем `- YYYY-MM-DD HH:MM:SS — <кто>: <текст>`; CENSOR-receipt по формату конституции -->

- 2026-11-13 21:21:47 — Manager: план создан из шаблона по указанию Owner (итог разбора внешнего аудита конвейера, верифицированного субагентами); исполняется ПЕРВЫМ в очереди из пяти черновиков — переход в `Ready for Planner` до остальных (управление очередью через переходы: §2 выбирает среди `Ready for *`; остальные четыре остаются Draft)
- 2026-11-13 21:32:19 — Architect: фаза начата, контракты прочитаны
- 2026-11-13 23:27:16 — Manager: fresh-диспатч Architect (PHASE=work) по §7 — handle итерации 21:32:19 потерян (intake записан, handoff нет); контракты неизменны с 21:32:19 (AGENTS.md@7ec6d0f4 architect.md@73ace930), Owner-указание: вести этот план первым из пяти черновиков
- 2026-11-13 23:33:00 — Architect: фаза завершена (fresh-диспатч после потери handle итерации 21:32:19, §7), зоны переприняты не rubber-stamp: «Как я понял задачу» переписан от своего лица; Problem 1–9 / Solution 1–9 / Scope / Out of scope приняты после самостоятельной сверки с текущим деревом — подтверждено grep/shasum/git: run.md:135 (`git add -A`) и селекция :14–17 (таблица :23/:28, строки Planning нет), §2-таблица AGENTS.md:57–64 без `In review → In progress`, receipt-блоки architect.md:52/planner.md:64/coder.md:70 без TS-префикса против канона AGENTS.md:141 и гейта run.md:81, инцидент 0427:395/406/436, обёртка агента :20–21 против стоп-лайна роль-дока :72–73 и lifecycle:58–62, Objections log пуст во всех 12 планах, дрейфы AGENTS.md@34563f1a→@7ec6d0f4 (значение появляется в fdef7a2) и status.md@55a9284f→@28731042, _template_review.md@a3452456 = диску (прецедент 2236:301, не живой дрейф), backlog:13/:18 (qa-lint, merge-untracked-guard), planfaktor-plan.md:8 без проверки коллизии (1943/1944 существуют), все носители Scope существуют (followups/index.md, plans/README.md:27). Два счётных расхождения аудита с текущим деревом исправлены в зоне: Problem п.1 (unstaged-правок сейчас 0, не 8) и п.6 («кураторск» 41/12, не 30/11). Intake — Q&A log 23:33:00; открытых вопросов к Owner нет. Handoff: **Status:** Ready for Planner
- 2026-11-13 23:35:00 — (Role CENSOR) OK: Ready for Planner validated; current=true
Censor dispatch id: censor:architect:261113_233406
Observations:
- Second opinion: шапка перечитана с диска — `**Status:** Ready for Planner` на строке 4 и единственная (grep `^\*\*Status` → 1 строка); PRE_STATUS_LINE конверта совпал; Plan ID 261113_2121 согласован с именем файла (строки 3/9). Свои секции сверены с первым чтением до правок: «Как я понял задачу» — мой текст (6 смысловых строк, в лимите 3–7 шаблона); Problem 1–9 / Solution 1–9 / Scope / Out of scope структурно не смещены, точечные правки вошли только в Problem п.1 (строки 42–45: счёт unstaged с честной исторической оговоркой) и п.6 (95–99: «кураторск» 41/12). Вопросов к Owner не ставилось и не потерялось: `grep -cE '^- Q\('` → 0. Чужие зоны нетронуты: DoD — плейсхолдер шаблона, Tests/Changes пусты, Suggestions/Objections/Follow-ups пусты, Token usage — только две строки Manager'а (21:32:19, 23:34:06).
- Counterfactuals considered: (1) контракты могли измениться между work-итерацией и CENSOR — shasum пересчитан: AGENTS.md@7ec6d0f4 / architect.md@73ace930 совпали с intake 23:33:00, §3 п.7 расхождений нет; (2) мои шесть Edit'ов могли задеть соседние секции — план перечитан целиком: 14 заголовков `## ` в порядке шаблона `_template.md`, ownership-комментарии целы, хронология Evidence монотонна (21:21:47 → 21:32:19 → 23:27:16 → 23:33:00 → 23:35:00); (3) мои записи могли создать ложные якоря для будущих grep'ов — `^- Q\(` → 0 (упоминания Q-форм в Solution п.8 и комментарии Q&A-секции не с начала строки), `^\*\*Status` → 1 (встречание «Handoff: **Status:** …» в середине Evidence-строки прецедентно — 0217:208, grep Manager'а идёт с `^`); (4) счётные правки могли противоречить Solution/Scope — сверено: «5 untracked (четыре Draft + этот)» ↔ Solution п.1 «четыре Draft-черновика не захватываются», «коммит 5ec7287» в блоке понимания ↔ «88926a2/5ec7287» в Problem п.1, историческое «30 в 11» живёт только в оговорке п.6.
- Addendum (new angle): сверено согласование «Как я понял задачу» с телом плана: «девять дефектов в трёх классах» ↔ метки S1/S2/S3 в Problem; «первым из пяти черновиков» ↔ Evidence 21:21:47 и Solution п.2; «промоутится из backlog» ↔ Solution п.1/Scope; «компенсирующие записи, без пересборки» ↔ Solution п.7/Out of scope п.1 — противоречий нет. Дополнительно: свежесть факта Evidence 23:33:00 «tracked-дерево чисто» повторным git status не перепроверялась — запись датирована моментом сверки 23:31 и не претендует на текущее состояние; контроли merge-шага по Solution п.1 в любом случае переснимаются заново в момент коммита.
- Fixes: ничего — дефектов в собственной зоне не нашёл.
- Final censor verdict: OK
- 2026-11-13 23:37:10 — Manager: CENSOR Architect OK (grep-валидация: маркер+TS, dispatch id censor:architect:261113_233406, Observations непустые) — переход Draft → Ready for Planner подтверждён; ретрансляция Owner'у блока «Как я понял задачу» и границ Scope (дословно, информационно) и диспатч Planner (PHASE=work)
- 2026-11-13 23:47:43 — Planner: фаза завершена. Заполнено: `## Acceptance criteria / DoD` — 16 пунктов D1–D16 строго по Solution 1–9 и Scope (D1–D4 merge-рутина Solution п.1, D5–D6 селекция п.2, D7 needs-fix п.3, D8 роль-доки п.4, D9 обёртка п.5, D10 кураторские черновики п.6, D11–D12 пост-ребилд честность п.7, D13 Q&A-идентификаторы п.8, D14 Plan-ID-коллизия п.9, D15 миграционные записи §3 п.7, D16 регрессионный линт-инвариант); `## Tests / Commands` — 17 строк T1–T17, каждая с метками (Dn), ожидаемым результатом и снятой базой (все различающие якоря проверены grep'ом по текущему дереву 23:44–23:47, паттерн T17 валидирован на фактических именах файлов). Q&A: открытых вопросов нет — Q-строк в логе не было, переносить нечего. Scope уточнён в зоне Planner двумя дополнениями без смены решений (право — комментарий секции): `docs/plans/README.md` (назван носителем в Solution п.2; норма файла требует синхронизации копии §2) и `_template_review.md` п.3 (строка Итога противоречит Solution п.3 — возражения в Objections log). `## Follow-ups`: NO FOLLOW-UPS — why: out-of-scope-backlog. Handoff: **Status:** Ready for Coder
- 2026-11-13 23:49:30 — (Role CENSOR) OK: Ready for Coder validated; current=true
Censor dispatch id: censor:planner:261113_234805
Observations:
- Second opinion: шапка перечитана с диска — `**Status:** Ready for Coder` на строке 4 и единственная (`grep -c '^\*\*Status'` → 1); PRE_STATUS_LINE конверта совпал; Plan ID 261113_2121 согласован с именем файла (строки 3/9). DoD проверяем: 16 пунктов (`grep -cE '^- \[ \] D[0-9]+ '` → 16), каждый — утверждение с носителем и grep/осмотр-якорем, без «по необходимости»/«и т.д.». Tests покрывают DoD: 17 строк, метки (Dn) во всех T1–T17, покрытие D1–D16 полное (D4 ← T4+T17), у каждой команды — ожидаемый результат и снятая база. Q&A: `grep -cE '^- Q\('` → 0 — открытых вопросов нет, переносить нечего (зафиксировано в intake 23:44:31 и Evidence 23:47:43). `## Follow-ups` заполнен: «NO FOLLOW-UPS — why: out-of-scope-backlog». Чужие секции: Problem 1–9 / Solution 1–9 / Out of scope / «Как я понял задачу» перечитаны — идентичны первому чтению work-итерации; мои записи — только DoD, Tests, два помеченных planner-дополнения в Scope, Follow-ups, Q&A intake, Evidence-строка фазы и статусная строка (право перехода §2).
- Counterfactuals considered: (1) контракты могли дрейфнуть между work и CENSOR — shasum пересчитан: AGENTS.md@7ec6d0f4 / planner.md@9afeff0a неизменны с 23:44:31, §3 п.7 расхождений нет; (2) мои Edit'ы могли задеть чужие зоны — план перечитан целиком: 14 заголовков `## ` в порядке шаблона, ownership-комментарии целы, хронология Evidence монотонна 21:21:47 → 23:47:43 (последующие 4 строки — Token usage, своя секция); (3) мои записи могли создать ложные якоря — `^- Q\(` → 0 (упоминания Q-форм в D13/Solution п.8 не с начала строки), `^\*\*Status` → 1 («Handoff: **Status:**» в Evidence 23:47:43 — середина строки, прецедент 0217:208), intake-строка 23:44:31 — C5-валидна (проверена grep'ом точной формы); (4) счётные ожидания тестов хрупки при иной группировке записей — T11 «→ 3» и T15 «≥15» корректны при формате D15 «по каждому файлу одной строкой» (§3 п.7), T3-арифметика сверена по backlog.md: 12 строк `status=open` − 1 промоушен = «открытых — 11, закрытых — 1»; (5) паттерн T17 мог задеть сам план — перепроверен на фактических именах: 261113_2121 → 0, 1642/261112_261111-планы → 1, README.md → 0.
- Addendum (new angle): сверена полнота покрытия Solution → DoD: S1→D1–D4 (контроли+список, промоушен, самоприменение), S2→D5–D6 (включая plans/README через T6), S3→D7, S4→D8, S5→D9, S6→D10, S7→D11–D12, S8→D13, S9→D14, миграции→D15, регресс→D16 — все девять решений имеют проверяемые критерии, ключевые фразы D6/D8/D10/D13 сверены с текстом Solution п.2–4/6/8. Planner-уточнения Scope проверены на scope-creep: `docs/plans/README.md` прямо назван носителем в Solution п.2, синхронизация таблицы — норма самого файла; `_template_review.md` п.3 — устранение прямого противоречия строки Итога Solution п.3 при файле уже в Scope по п.1; оба дополнения решения Architect не меняют. Остаточное наблюдение (не дефект): лексические якоря T2 «Итог» и T7 «не ставит статус» предполагают формулировки D2/D7 — интерпретационный зазор для Coder мал, DoD даёт требуемую лексику дословно.
- Fixes: ничего — дефектов в собственной зоне не нашёл.
- Final censor verdict: OK
- 2026-11-13 23:49:52 — Manager: CENSOR Planner OK (grep: маркер+TS 23:49:30, dispatch id censor:planner:261113_234805, Observations непустые, verdict OK) — переход Ready for Coder → In progress подтверждён
- 2026-11-13 23:49:52 — Manager: Q&A чист, открытых вопросов к Owner нет, статус In progress; диспатч Coder (PHASE=work)
- 2026-11-13 23:59:10 — Coder: компенсирующая пост-ребилд запись (§3 п.7; Solution п.7, D11): AGENTS.md: @34563f1a → @7ec6d0f4 — вне конвейера, санитизация/пересборка 2026-11-13 (живой дрейф: последняя конвейерная миграция — 0217 Evidence 12:36:55; значение на диске появилось в rebuilt-истории fdef7a2)
- 2026-11-13 23:59:10 — Coder: компенсирующая пост-ребилд запись (§3 п.7; Solution п.7, D11): .zcode/commands/planfaktor-status.md: @55a9284f → @28731042 — вне конвейера, санитизация/пересборка 2026-11-13 (живой дрейф: последняя конвейерная миграция — 0217, Evidence 12:19:45/12:21:35)
- 2026-11-13 23:59:10 — Coder: компенсирующая пост-ребилд запись (§3 п.7; Solution п.7, D11): docs/reviews/_template_review.md: @0d20454a → @a3452456 — вне конвейера, дрейф до пересборки (смена записана в Evidence 261112_2236:301 и совпадает с диском; здесь — прецедентная запись события аудита, не живой дрейф)
- 2026-11-13 23:59:10 — Coder: миграция контракта (§3 п.7, D15): AGENTS.md: @7ec6d0f4 → @eb9cffe8
- 2026-11-13 23:59:10 — Coder: миграция контракта (§3 п.7, D15): docs/plans/_template.md: @d0ff48bb → @4efaf201
- 2026-11-13 23:59:10 — Coder: миграция контракта (§3 п.7, D15): docs/reviews/_template_review.md: @a3452456 → @0c995bb3
- 2026-11-13 23:59:10 — Coder: миграция контракта (§3 п.7, D15): docs/roles/architect.md: @73ace930 → @e34627dc
- 2026-11-13 23:59:10 — Coder: миграция контракта (§3 п.7, D15): docs/roles/planner.md: @9afeff0a → @d390e46a
- 2026-11-13 23:59:10 — Coder: миграция контракта (§3 п.7, D15): docs/roles/coder.md: @942a3f82 → @976c292b
- 2026-11-13 23:59:10 — Coder: миграция контракта (§3 п.7, D15): docs/roles/reviewer-risk.md: @607292b4 → @b58755ea
- 2026-11-13 23:59:10 — Coder: миграция контракта (§3 п.7, D15): docs/roles/reviewer-contracts.md: @8d1efb83 → @a7bcfdfa
- 2026-11-13 23:59:10 — Coder: миграция контракта (§3 п.7, D15): .zcode/commands/planfaktor-run.md: @84a182ce → @18445945
- 2026-11-13 23:59:10 — Coder: миграция контракта (§3 п.7, D15): .zcode/commands/planfaktor-status.md: @28731042 → @2e49b029
- 2026-11-13 23:59:10 — Coder: миграция контракта (§3 п.7, D15): .zcode/commands/planfaktor-plan.md: @6b72c500 → @3d1283f4
- 2026-11-13 23:59:10 — Coder: миграция контракта (§3 п.7, D15): .zcode/agents/planfaktor-reviewer-contracts.md: @a98a3190 → @41f01027
- 2026-11-14 00:02:40 — Coder: прогоны T1–T17 (T4 — гейт-действие Manager, регламент теста: в Coder-фазе только факт текста рутины по T1/T2): все 16 прогнанных строк PASS — числа в ## Tests / Commands (факты прогонов, финальный срез 00:01). Два промежуточных якорь-фиккса по находкам прогонов до финального среза: T6 — подстрока `In review → In progress` была разорвана бэктиками в ячейках таблицы (строка переписана одним код-спаном `` `In review → In progress` `` в AGENTS.md и docs/plans/README.md); T14 — фраза «уже существует» разорвана переносом строки в planfaktor-plan.md (переформатирована в одну строку). Регрессионные инварианты T16: `corpus: clean`, `selftest: 15/15 caught` — после всех правок контрактов и записей Evidence. Стейджинг: 20 файлов Scope застейджины (`git add`), `git diff --cached --name-only | sort` — ровно состав Scope, T17-паттерн → 0, коммита нет (§8: коммитит Manager)
- 2026-11-14 00:02:40 — Coder: фаза завершена. Реализованы D1–D16: D1/D2 merge-рутина по явному списку + канонизация состава; D3 промоушен merge-untracked-guard (backlog + пересборка index); D4 — текст рутины (гейт-исполнение — Manager на merge-шаге); D5/D6 селекция += Merged, Draft-резюма, строка Planning, унификация «несколько активных», строка needs-fix в §2 (AGENTS.md + plans/README синхронно); D7 needs-fix за Coder'ом (run.md, reviewer-contracts.md, lifecycle.md, _template_review.md); D8 роль-доки к канону (TS-префикс, DUPLICATE-пометки, contract-строка intake); D9 стоп-лайн обёртки; D10 §1(g) + §10; D11/D12 пост-ребилд записи и оговорки (README, CONTRIBUTING, compliance 4.13); D13 грамматика `#<n>` (AGENTS.md §3 п.4, _template.md, run.md, status.md, qa-lint-примечание); D14 Plan-ID-коллизия; D15 — 12 миграционных записей выше (23:59:10); D16 линт-инвариант. Изменения стейджнуты, unstaged-дрейф отсутствует. Handoff: **Status:** In review
- 2026-11-14 00:06:00 — (Role CENSOR) OK: In review validated; current=true
Censor dispatch id: censor:coder:261114_000207
Observations:
- Second opinion: шапка перечитана с диска — `**Status:** In review` на строке 4 и единственная (`grep -c '^\*\*Status'` → 1); PRE_STATUS_LINE конверта censor:coder:261114_000207 совпал; Plan ID 261113_2121 (строка 3) согласован с префиксом имени файла. DoD не тронут: 16 незакрытых чекбоксов (`grep -cE '^- \[ \] D[0-9]+ '` → 16) — закрытие чекбоксов зона Planner. Каждый D1–D16 отражён в `## Changes (by area)` (11 областей с носителями); выборочная сверка Changes↔файлы: run.md merge-рутина (а)–(г) с `git status --porcelain` и сверкой с Итогом — дословно на диске; AGENTS.md §1(g) «черновик секций внешней (кураторской) сессии… только в статусе `Draft`»; coder.md receipt-пример с TS-префиксом `- YYYY-MM-DD HH:MM:SS — (Role CENSOR) OK: In review validated` + DUPLICATE-пометка (1); обёртка «артефакта нет → стоп… risk-лайн создаёт артефакт». Tests-факты T1–T17 в секции (срез 00:01); контрольный переснимок при CENSOR: T1 `git add -A` → 0, T6 → 1, T15 → 15, T17 → 0; T16 прогнан повторно сейчас — `corpus: clean`, `selftest: 15/15 caught`. Стейджинг: staged = 20 файлов, состав = Scope; чужие секции не тронуты — якоря Problem/Solution целы («Merge-шаг слеп к посторонним файлам» → 1, «Merge-коммит по явному списку» → 1), 14 заголовков секций в порядке шаблона, хронология Evidence монотонна 21:21:47 → 00:02:40, ранние записи дословно на месте. `## Follow-ups` заполнен (NO FOLLOW-UPS — why: out-of-scope-backlog). TODO/отладочного мусора нет; плейсхолдеры `<файл 1>/<файл 2>` в Итоге _template_review.md — шаблонные (одного класса с `<PlanID>` шапки), не мусор.
- Counterfactuals considered: (1) контракты могли дрейфнуть после handoff — shasum всех 12 контрактов пересчитан и совпал с «новыми» значениями миграционных записей 23:59:10 (AGENTS.md@eb9cffe8 … planfaktor-reviewer-contracts.md@41f01027) — незафиксированного дрейфа нет; (2) мои правки run.md могли задеть CENSOR-гейт Manager'а (шаг 3) — шаг 3 не правился: строки `grep -n '(Role CENSOR)'` / `Censor dispatch id:` / TS-строка на месте (снято sed-вырезкой шага 3); (3) правка механики Q&A (D13) могла потерять якорь `^- Q\(` — якорь на месте (1), якорная §3-форма `status=open` Q-строки сохранена (3 вхождения); (4) staged мог дрейфнуть после фазы — проверено: 20 файлов, T17-паттерн → 0; unstaged-дельта ровно одна строка — usage-строка Manager 00:02:07 (зона §1(f), записана после финального стейджинга фазы), устранена в Fixes; (5) DUPLICATE-пометки и TS-примеры в роль-доках могли создать ложные срабатывания чужих проверок — C4/C8 линта читают только планы и шаблоны планов, роль-доки вне скоупа обеих; C9 не задет (все пути в правках либо allowlist-формы `docs/plans/<PlanID>_<topic>.md`/`docs/reviews/<PlanID>_review.md`, либо не пути) — `corpus: clean` подтверждает.
- Addendum (new angle): сверена согласованность новой merge-рутины с будущим merge-гейтом этого плана: контроль D1(а) «`git diff --name-only` пуст» лёг бы ложным срабатыванием на любой записи Manager'а после моего финального стейджинга (usage/Evidence-узлы пишутся позже) — рутина (в) сама делает явный `git add` плана, но уже после контроля (а); хвост устранён упреждающе (Fixes) — к merge-гейту unstaged-дрейф отсутствует, четыре Draft-черновика в staged не попадали (T17 → 0). Дополнительно: комментарий Q&A-секции самого плана остался в старой форме без `#<n>` — проверено на дефектность: Scope исключает правку планов-историй, D13-носитель — шаблон `_template.md`; Q-строк в этом плане нет ни одной, позиционная неоднозначность не возникает — не дефект, а корректный переходный период.
- Fixes: повторный `git add docs/plans/261113_2121_integrity_critical_fixes.md` — застейджена unstaged-дельта плана (usage-строка Manager 00:02:07 + настоящий receipt и intake CENSOR): стейджинг — зона Coder (§8), записи Manager'а не правились; после него unstaged = 0, staged = 20, состав неизменен. Дефектов собственной зоны в handoff не нашёл.
- Final censor verdict: OK
- 2026-11-14 00:19:07 — Coder: fixes-раунд 1 начат (needs-fix по risk-вердикту review-артефакта Round 1): intake записан, статус `In progress` (§2, строка needs-fix — собственная норма этого плана). Устранены findings 1–2: контроль (а) merge-рутины `run.md` переформулирован — unstaged-половина получила исключение для самого плана и его review-артефакта (append-only записи после финального стейджинга Coder'а штатны, стейджатся шагом (в)); untracked-половина — исключение для Draft-черновиков других планов очереди (в коммит не входят, доклад Owner информационно). Шаги (б)–(г) и стоп-ветка не менялись. Подробно — ## Changes (by area), раунд-1 bullet
- 2026-11-14 00:19:07 — Coder: миграция контракта (§3 п.7, D15 — правка fixes-раунда 1): .zcode/commands/planfaktor-run.md: @18445945 → @90cc3434
- 2026-11-14 00:19:07 — Coder: прогоны fixes-итерации — T1/T2/T5/T7/T13(run.md)/T17 PASS, раунд-1 адресные PASS (факты — ## Tests / Commands). Отклонение (fail loud): T16 `./scripts/check_corpus.sh` → `corpus: 1 failures` — FAIL C7 review-artifacts на `docs/reviews/261113_2121_review.md` (Contracts-вердикт — плейсхолдер шаблона `pass | needs-fix`: артефакт в промежуточном состоянии раунда, contracts-лан ещё не заполнял); `--selftest` → `baseline failed` (требует чистый baseline). Вне зоны Coder: корпус C7 — только docs/reviews/[0-9]*.md, правки раунда (run.md, план) туда не входят; артефакт создан risk-лайном 00:09:45 — позже последнего чистого T16 (CENSOR 00:06); иных FAIL в выводе нет. Ожидаемое закрытие — Contracts-вердикт раунда 2 (regex C7 удовлетворяется); если раунд 2 закроется без чистого corpus — Manager обязан зафиксировать отклонение до merge-гейта
- 2026-11-14 00:19:07 — Coder: дополнительно к findings (не правка, регистрация): шаг 4(г) merge-рутины — буквальное сравнение merge-коммита с Итог-списком staged даст гарантированное расхождение на санкционированном (в) review-артефакте (на момент contracts-вердикта не staged); вне findings Round 1, предложено в ## Suggestions log — триаж Manager/раунд 2
- 2026-11-14 00:20:10 — Coder: fixes-итерация завершена. Findings 1–2 risk-лайна устранены правкой контроля (а) merge-рутины (`run.md` @90cc3434); вердиктные строки T-батарей и staged-контроль — PASS, единственное отклонение T16 (C7, промежуточное состояние review-артефакта, вне зоны Coder) зафиксировано fail loud выше и в ## Tests / Commands. Стейджинг: `git add` run.md + план; unstaged-дрейф отсутствует, staged = 20 файлов Scope, untracked — 4 Draft-черновика (все статус Draft, сверено) + review-артефакт — оба класса в исключениях нового контроля (а); коммита нет (§8). Handoff: **Status:** In review
- 2026-11-14 00:23:11 — (Role CENSOR) OK: In review validated; current=true
Censor dispatch id: censor:coder:261114_002120
Observations:
- Second opinion: шапка перечитана с диска — `**Status:** In review` на строке 4 и единственная (`grep -c '^\*\*Status'` → 1); PRE_STATUS_LINE конверта censor:coder:261114_002120 совпал; Plan ID 261113_2121 согласован с именем файла. Раунд-1 bullet `## Changes (by area)` сверен с диском дословно: контроль (а) run.md на диске — обе половины с исключениями (unstaged: план + review-артефакт с обоснованием append-only; untracked: файлы мерджимого плана + Draft-черновики очереди с информационным докладом), стоп-ветка и шаги (б)–(г) сохранены. Закрытие findings проверено на текущем дереве: `git diff --name-only` → пусто (finding 1: живой пруф находки устранён, класс ложного стопа выведен в исключение), untracked = ровно 4 Draft-черновика (все `**Status:** Draft`, сверены grep'ом) + review-артефакт — оба класса в исключениях (finding 2: самоприменение D4 достижимо по букве). Контрольный переснимок T-якорей: T1 `git add -A` → 0 / `porcelain` → 1 / `--name-only` → 2; T15 пар `@8hex → @8hex` в Evidence → 16 (≥15; 12 миграционных D15 + 3 компенсирующих D11 + 1 миграция fixes-раунда `@18445945 → @90cc3434`); T17 staged = 20 файлов, паттерн → 0. Внешняя дельта с handoff — одна usage-строка Manager 00:21:20 (§1(f), не тронута). Отклонение T16 перепроверено прогоном: `corpus: 1 failures`, единственный FAIL — C7 на плейсхолдере Contracts-вердикта review-артефакта (создан 00:09:45, contracts-лан не заполнял); артефакт не тронут (untracked, плейсхолдер на месте).
- Counterfactuals considered: (1) контракты могли дрейфнуть после handoff — shasum: AGENTS.md@eb9cffe8 / coder.md@976c292b неизменны с fixes-intake 00:16:44, run.md@90cc3434 = значению миграционной записи; (2) новые исключения могли выхолостить контроль — перечитан: unstaged-исключение только план+review-артефакт, untracked-исключение только файлы мерджимого плана и Draft-статусные планы очереди, «иное нарушение — стоп fail loud» сохранён; контроль остаётся содержательным (любой иной unstaged/untracked файл — стоп); (3) мой новый текст run.md мог сломать C9 (пути) — повторный прогон: FAIL ровно один (C7), C9 прошёл — формы `docs/plans/<PlanID>_<topic>.md` и `docs/reviews/<PlanID>_review.md` в allowlist, `docs/plans/[0-9]*.md` обрезается токенизатором до существующего каталога, голый `<PlanID>*.md` не токенизируется; (4) fixes-итерация могла задеть чужие зоны — перечитаны правки раунда: статусная строка (×2, право перехода §2), Q&A intake, строка Suggestions log, bullet Changes, факты Tests, записи Evidence — всё зона Coder; DoD не тронут (16 незакрытых чекбоксов `^- \[ \] D` → 16), Problem/Solution/Scope целы; (5) вторая миграция run.md могла сломать счётные якоря — T15 → 16 при пороге ≥15, буква D15 «по каждому изменённому контракту — 12 файлов» остаётся истинной (run.md менялся дважды, две записи), T11 → 3 не задет (новая пара не входит в паттерн).
- Addendum (new angle): сверено соответствие вердикт-строки risk-лайна («уточнение исключений контроля (а) до merge») исполнению — устранены оба названных класса ложных стопов, состав коммита по-прежнему канонизируется списком Итога (шаг (г) не менялся). Отклонение от буквы D1(а) («`git diff --name-only` пуст» без исключений) задокументировано в Changes/Evidence как санкционированное вердиктом needs-fix — явно для видимости contracts-лана раунда 2. Условие самолечения C7 перепроверено по regex проверки: строка `### Contracts verdict: (pass|needs-fix)` с опциональным `superseded (round N)` — заполнение вердикта в раунде 2 закрывает FAIL без правок линта.
- Fixes: повторный `git add docs/plans/261113_2121_integrity_critical_fixes.md` — застейджена unstaged-дельта плана (intake CENSOR + настоящий receipt; стейджинг — зона Coder, §8); после него unstaged = 0, staged = 20, состав неизменен. Дефектов собственной зоны в handoff не нашёл.
- Final censor verdict: OK
- 2026-11-14 00:34:10 — Coder: fixes-раунд 2 начат (needs-fix по риск-вердикту Round 2): intake записан, статус `In progress`. Устранён finding 1 Round 2 (major) — шаг (г) merge-рутины: санкционированные шагом (в) добавления (план/review-артефакт) выведены из «расхождения = захвачено постороннее» с сохранением fail loud на иное расхождение; находка — промоушен собственного предложения Coder'а (Suggestions log 00:16:44, закрыто строкой 00:33:07). Шаги (а)–(в) не менялись. Подробно — ## Changes (by area), раунд-2 bullet
- 2026-11-14 00:34:10 — Coder: миграция контракта (§3 п.7, D15 — правка fixes-раунда 2): .zcode/commands/planfaktor-run.md: @90cc3434 → @2a6176bd
- 2026-11-14 00:34:10 — Coder: прогоны fixes-итерации раунда 2 — T1/T2/T5/T7/T13(run.md)/T17 PASS, раунд-2 адресный PASS (факты — ## Tests / Commands). Отклонение T16 неизменно с раунда 1 (fail loud, раунд-1 запись 00:19:07): единственный FAIL C7 — плейсхолдер Contracts-вердикта review-артефакта (contracts-лан не заполнял), правки раунда вне корпуса C7, новых FAIL нет; закроется Contracts-вердиктом текущего раунда
- 2026-11-14 00:34:20 — Coder: fixes-итерация раунда 2 завершена. Finding 1 Round 2 устранён (шаг (г), `run.md` @2a6176bd); T-батареи и staged-контроль PASS, отклонение T16 — неизменное с раунда 1, задокументировано. Стейджинг: `git add` run.md + план; unstaged-дрейф отсутствует, staged = 20 файлов Scope, T17-паттерн → 0, staged run.md = @2a6176bd (миграция выше); коммита нет (§8). Handoff: **Status:** In review
- 2026-11-14 00:36:32 — (Role CENSOR) OK: In review validated; current=true
Censor dispatch id: censor:coder:261114_003450
Observations:
- Second opinion: шапка перечитана с диска — `**Status:** In review` на строке 4 и единственная (`grep -c '^\*\*Status'` → 1); PRE_STATUS_LINE конверта censor:coder:261114_003450 совпал; Plan ID согласован с именем файла. Раунд-2 bullet `## Changes (by area)` сверен с (г) на диске дословно: санкционированные шагом (в) добавления (план/review-артефакт) выведены из расхождения с обоснованием (review-артефакт не staged на момент contracts-вердикта), «иное расхождение = захвачено постороннее: fail loud» сохранён. Контрольный переснимок якорей: T1 `git add -A` → 0 / `porcelain` → 1 / `--name-only` → 2; `Итог` → 3 (рост 2→3 от новой оговорки отражён в фактах Tests раунда 2, порог T2 ≥1); T15 пар в Evidence → 18 при пороге ≥15 (15 базовых + миграции r1/r2 + инлайн-цитата пары в r1-receipt); T17 staged = 20, паттерн → 0; staged run.md @2a6176bd = миграционной записи 00:34:10 = диску. Corpus перепрогнан: `corpus: 1 failures` — тот же единственный C7 на плейсхолдере Contracts-вердикта (артефакт не менялся, вне зоны Coder), новых FAIL нет. Внешняя дельта с handoff — одна usage-строка Manager 00:34:50 (§1(f), не тронута).
- Counterfactuals considered: (1) оговорка (г) могла выхолостить канонизацию состава — перечитано: исключение только именованные (в)-добавления (план/review-артефакт), любой иной файл в коммите сверх Итог-списка остаётся fail loud — D2 не ослаблен; (2) новая фраза могла сломать C9 — новых путей не внесено (имена файлов в код-спанах уже существующих allowlist-форм), corpus-прогон выше подтверждает: FAIL только C7; (3) комментарий Итога шаблона `_template_review.md` («Manager сверяет merge-коммит с этим списком») мог противоречить новой (г) — перечитан: шаблон не определяет семантику расхождения (не содержит «захвачено постороннее»), её определяет run.md (г) — противоречия нет, синхронная правка шаблона не требуется; (4) staged мог дрейфнуть после handoff — проверено: 20 файлов, паттерн T17 → 0, unstaged до Fixes — только план (intake CENSOR); (5) DoD мог быть затронут раундом — чекбоксы D1–D16 не тронуты (16 незакрытых, закрытие — зона Planner), правки раунда 2: статусная строка (×2), Q&A intake, строка закрытия Suggestions, bullet Changes, факты Tests, записи Evidence — всё зона Coder.
- Addendum (new angle): сверена траектория промоушена предложения: Suggestions log 00:16:44 → триаж risk-лайна (intake раунда 2, Q&A) → finding 1 Round 2 → фикс 00:33–00:34 → закрытие Suggestions строкой 00:33:07 — цикл «предложение → finding → fix» прошёл без правки чужих зон и без дублирования сущности в плане. T15-счёт 18 задокументирован честно с разложением (инлайн-цитата r1-receipt — легитимная пара-подобная строка, порог Tests не задаёт верхнюю границу).
- Fixes: повторный `git add docs/plans/261113_2121_integrity_critical_fixes.md` — застейджена unstaged-дельта плана (intake CENSOR + настоящий receipt; стейджинг — зона Coder, §8); после него unstaged = 0, staged = 20, состав неизменен. Дефектов собственной зоны в handoff не нашёл.
- Final censor verdict: OK
- 2026-11-14 00:49:23 — Manager: ревью Round 3 завершено — Risk pass (00:38:20) + Contracts pass (00:47:30), Итог: pass → открыт Owner-гейт merge; свежий линт собственным прогоном: corpus: clean, selftest: 15/15 caught; выжимка доложена Owner'у (вердикты, staged-список 20, lint). Ожидание ответа Owner (owner-silence, §6)
- 2026-11-14 01:24:15 — Manager: reconciliation с кураторской сессией мониторинга — гейт-отчёт 00:49 не был виден монитору; состояние перепроверено по дискам (вердикты Round 3, staged 20, corpus: clean), диспатч contracts не терялся, fresh-диспатч по §7 не требуется; гейт остаётся открытым, выжимка повторена
- 2026-11-14 01:40:18 — Manager: Owner-«да» на merge-гейте («мержим»); контроли (а) пройдены — unstaged: только план (append-only-дельта, штатное исключение), untracked: 4 Draft-черновика очереди (все `**Status:** Draft`, сверено) + review-артефакт (оба класса в исключениях), staged = 20, свежий линт: corpus: clean, selftest: 15/15 caught; статус Merged, merge-коммит по явному списку из Итога (самоприменение Solution п.1)

## Token usage (append-only)
<!-- owner: manager; dispatch-форма: `- YYYY-MM-DD HH:MM:SS — usage: <role>.<work|censor|rN> <N|unknown (why=...)> tokens — <dispatch|sendmessage|unknown>`; чекпоинт-форма: `- YYYY-MM-DD HH:MM:SS — usage: manager-context checkpoint ~<N> tokens-left — approximate`; числа — учёт харнесса ZCode (subagent_tokens), приближение, не биллинг провайдера; пишет только Manager из tool-результата вызова -->

- 2026-11-13 21:32:19 — usage: architect.work 1408769 tokens — dispatch
- 2026-11-13 23:34:06 — usage: architect.work 624603 tokens — dispatch
- 2026-11-13 23:36:31 — usage: architect.censor 486682 tokens — sendmessage
- 2026-11-13 23:48:05 — usage: planner.work 3840831 tokens — dispatch
- 2026-11-13 23:49:52 — usage: planner.censor 1288060 tokens — sendmessage
- 2026-11-14 00:02:07 — usage: coder.work 4447154 tokens — dispatch
- 2026-11-14 00:06:04 — usage: coder.censor 1358131 tokens — sendmessage
- 2026-11-14 00:10:49 — usage: reviewer-risk.work 792116 tokens — dispatch
- 2026-11-14 00:21:20 — usage: coder.r1 2564214 tokens — dispatch
- 2026-11-14 00:24:13 — usage: coder.censor 1254326 tokens — sendmessage
- 2026-11-14 00:31:44 — usage: reviewer-risk.r1 1461983 tokens — sendmessage
- 2026-11-14 00:34:50 — usage: coder.r2 2870169 tokens — sendmessage
- 2026-11-14 00:37:15 — usage: coder.censor 1553894 tokens — sendmessage
- 2026-11-14 00:43:13 — usage: reviewer-risk.r2 1179726 tokens — sendmessage
- 2026-11-14 00:49:23 — usage: reviewer-contracts.work 1939633 tokens — dispatch
- 2026-11-14 00:49:23 — usage: manager-context checkpoint ~14948080 tokens-left — approximate

## Q&A log (chronological, append-only)
<!-- owner: все роли; intake: `Intake (YYYY-MM-DD HH:MM:SS): AGENTS.md@<8hex> <role>.md@<8hex>` (локальное время) + NO QUESTIONS / NO SUGGESTIONS / NO OBJECTIONS; вопросы `Q(<роль>): ... to=Owner|to=<роль>, blocker: yes|no, needs_owner: yes|no, status=open`; закрытие `A(<кто>): ... status=closed, перенесено в <секция>` -->

- Intake (2026-11-13 21:32:19): AGENTS.md@7ec6d0f4 architect.md@73ace930
  (digest'ы сверены `shasum -a 256` — совпали с брифом; план прочитан целиком, статус Draft сверен; вся bootstrap-литература прочитана: AGENTS.md §1–§10, роли, команды, lifecycle, README/CONTRIBUTING, backlog merge-untracked-guard/closeout-tail-convention, образец плотности 261113_0217; анти-false-gap: все 9 пунктов перепроверены grep'ом/shasum по текущему дереву — кураторские фиксы сегодня в Problem не входят; единственное расхождение с брифом — `_template_review.md`: запись миграции 0d20454a→a3452456 существует в 2236:301 и совпадает с диском, отражено в Problem п.7/Solution п.7 как прецедент, не живой дрейф)
- architect: NO QUESTIONS (бриф Owner закрывает все развилки, включая отклонение write-tree-альтернативы с обоснованием, состав компенсирующих записей и границы соседних черновиков)
- architect: NO SUGGESTIONS (плотность и решения брифа сверены с фактическим состоянием репо; дополнительных дефектов класса S1/S2 в зоне плана не найдено)
- architect: NO OBJECTIONS (практика кураторских черновиков, легализуемая п.6, — моё собственное происхождение в этом плане; перепринятие зон выполнено этой итерацией по существу, не rubber-stamp)
- Intake (2026-11-13 23:33:00): AGENTS.md@7ec6d0f4 architect.md@73ace930
  (digest'ы сверены `shasum -a 256`, совпали с Evidence Manager 23:27:16 — контракты неизменны с итерации 21:32:19; план перечитан целиком, статус Draft сверен с PRE_STATUS_LINE конверта; fresh-диспатч по §7: результаты сверки итерации 21:32:19 не наследуются, перепринятие выполнено заново — все 9 пунктов Problem подтверждены по текущему дереву, два счётных факта обновлены: unstaged-правок 0 (Problem п.1), «кураторск» 41/12 (п.6))
- architect: NO QUESTIONS (бриф Owner в Evidence 21:21:47 закрывает все развилки: очередь из пяти черновиков, отклонение write-tree-альтернативы, состав компенсирующих записей, границы соседних черновиков)
- architect: NO SUGGESTIONS (дополнительных дефектов класса S1/S2/S3 в зоне плана при сверке не найдено; плотность решений соответствует образцу 0217)
- architect: NO OBJECTIONS (кураторская практика, легализуемая Solution п.6, — происхождение этого плана; перепринятие зон выполнено этой итерацией по существу)
- Intake (2026-11-13 23:35:00): AGENTS.md@7ec6d0f4 architect.md@73ace930
  (CENSOR-итерация; digest'ы пересчитаны `shasum -a 256` — контракты неизменны с intake 23:33:00; план перечитан с диска целиком, статус сверен с PRE_STATUS_LINE конверта; «Как я понял задачу» перечитан — актуален с рабочей итерации, изменения понимания нет)
- architect: NO QUESTIONS (конверт CENSOR однозначен: сверка собственного handoff с файлами, не с памятью)
- architect: NO SUGGESTIONS (дефектов собственной зоны по чек-листу роль-дока не найдено)
- architect: NO OBJECTIONS (handoff-статус Ready for Planner подтверждён сверкой с диском)
- Intake (2026-11-13 23:44:31): AGENTS.md@7ec6d0f4 planner.md@9afeff0a
  (digest'ы пересчитаны `shasum -a 256`; план перечитан с диска целиком, статус Ready for Planner сверен с PRE_STATUS_LINE конверта — совпал; Q-строк в логе нет, переносить в секции нечего — Owner-ответов после Architect-фазы не поступало; единственный пробел синхронности Solution↔Scope — `docs/plans/README.md` назван носителем в Solution п.2, но отсутствует в списке Scope — закрывается уточнением Scope в зоне Planner без смены решений)
- planner: NO QUESTIONS (решения Architect полны и внутренне непротиворечивы: Solution 1–9 ↔ Scope согласованы по существу; все файлы-носители существуют в дереве)
- planner: NO SUGGESTIONS (дополнительных улучшений вне решений Architect в зоне детализации не найдено)
- planner: NO OBJECTIONS (несоответствий канону §1–§10 в решениях Architect не найдено; пробел docs/plans/README.md — не противоречие, а пропуск списка, устраняется уточнением Scope)
- Intake (2026-11-13 23:48:47): AGENTS.md@7ec6d0f4 planner.md@9afeff0a
  (CENSOR-итерация; digest'ы пересчитаны `shasum -a 256` — контракты неизменны с work-intake 23:44:31; план перечитан с диска целиком, статус Ready for Coder сверен с PRE_STATUS_LINE конверта — совпал)
- planner: NO QUESTIONS (конверт CENSOR однозначен: сверка собственного handoff с файлами, не с памятью)
- planner: NO SUGGESTIONS (дефектов собственной зоны по чек-листу роль-дока при сверке не найдено)
- planner: NO OBJECTIONS (handoff-статус Ready for Coder подтверждён сверкой с диском)
- Intake (2026-11-13 23:50:20): AGENTS.md@7ec6d0f4 coder.md@942a3f82
  (digest'ы сняты `shasum -a 256` в момент чтения контрактов; план перечитан с диска целиком, статус In progress сверен с PRE_STATUS_LINE конверта — совпал; DoD D1–D16 и Tests T1–T17 прочитаны, T4 зафиксирован как гейт-действие Manager — в Coder-фазе только текст рутины по T1/T2)
- coder: NO QUESTIONS (DoD полон и проверяем, каждая D-строка развёрнута из Solution дословно; все файлы-носители Scope названы по именам; развилка T4 «гейт vs рутина» закрыта самим Tests-текстом)
- coder: NO SUGGESTIONS (дополнительных улучшений вне решений Architect в зоне реализации не найдено)
- coder: NO OBJECTIONS (несоответствий канону §1–§10 в решениях не найдено; planner-уточнения Scope помечены в зоне Planner и решения не меняют)
- Intake (2026-11-14 00:05:30): AGENTS.md@eb9cffe8 coder.md@976c292b
  (CENSOR-итерация; digest'ы пересчитаны `shasum -a 256` — оба контракта изменены моей work-фазой, смена зафиксирована миграционными записями §3 п.7 в Evidence 23:59:10 — норма п.7, повторный диспатч не нужен; план перечитан с диска целиком, статус In review сверен с PRE_STATUS_LINE конверта — совпал)
- coder: NO QUESTIONS (конверт CENSOR однозначен: сверка собственного handoff с файлами, не с памятью)
- coder: NO SUGGESTIONS (дефектов собственной зоны по чек-листу роль-дока при сверке не найдено)
- coder: NO OBJECTIONS (handoff-статус In review подтверждён сверкой с диском)
- Intake (2026-11-14 00:06:38): AGENTS.md@eb9cffe8 reviewer-risk.md@b58755ea
  (digest'ы сняты `shasum -a 256` в момент чтения; оба контракта изменены Coder-фазой этого плана — смены зафиксированы миграционными записями §3 п.7 в Evidence 23:59:10 (AGENTS.md @7ec6d0f4 → @eb9cffe8; reviewer-risk.md @607292b4 → @b58755ea), норма п.7, повторный диспатч не нужен; план перечитан с диска целиком, статус In review сверен с PRE_STATUS_LINE конверта — совпал)
- reviewer-risk: NO QUESTIONS (конверт PHASE=review однозначен; предмет ревью — staged-изменения против HEAD, артефакт отсутствует — создаю из шаблона как первый лан)
- reviewer-risk: NO SUGGESTIONS (на этапе intake; находки — в review-артефакт по итогам чтения diff)
- reviewer-risk: NO OBJECTIONS (противоречий плана самому себе при сплошном чтении не найдено)
- Intake (2026-11-14 00:16:44): AGENTS.md@eb9cffe8 coder.md@976c292b
  (fixes-итерация, needs-fix раунд 1 — риск-вердикт review-артефакта `docs/reviews/261113_2121_review.md`; digest'ы сняты `shasum -a 256` — оба контракта неизменны с миграционных значений Evidence 23:59:10, повторный диспатч по §3 п.7 не нужен; план и review-артефакт перечитаны с диска целиком, статус In review сверен с PRE_STATUS_LINE конверта — совпал; findings 1–2 risk-лайна и вердикт прочитаны: оба — контроль (а) merge-рутины run.md; по конверту ставлю `In progress` на intake fixes-итерации, §2)
- coder: NO QUESTIONS (вердикт risk-лайна однозначен — «уточнение исключений контроля (а) до merge»; обе находки закрываются правкой `.zcode/commands/planfaktor-run.md` шаг 4(а) — файл в Scope п.1 «merge по явному списку + контроли»; DoD-текст не правится — зона Planner)
- coder: SUGGESTIONS (1): шаг 4(г) merge-рутины — буквальное сравнение `git show --stat` merge-коммита с дословным Итог-списком staged даст гарантированное расхождение на санкционированном (в) review-артефакте (на момент contracts-вердикта он не staged — ревьюеры не стейджат); вне findings Round 1, в fixes-раунде не правлю (дисциплина needs-fix — возражения из артефакта) — перенесено в ## Suggestions log
- coder: NO OBJECTIONS (needs-fix-механика по канону §2/D7: Coder ставит In progress на intake, работает по findings review-артефакта строго в рамках Scope)
- Intake (2026-11-14 00:22:12): AGENTS.md@eb9cffe8 coder.md@976c292b
  (CENSOR-итерация fixes-раунда 1; digest'ы пересчитаны `shasum -a 256` — оба контракта неизменны с fixes-intake 00:16:44; план перечитан с диска целиком, статус In review сверен с PRE_STATUS_LINE конверта censor:coder:261114_002120 — совпал; внешняя дельта с handoff — одна usage-строка Manager 00:21:20, зона §1(f), не правится)
- coder: NO QUESTIONS (конверт CENSOR однозначен: сверка собственного handoff fixes-итерации с файлами, не с памятью)
- coder: NO SUGGESTIONS (дефектов собственной зоны по чек-листу роль-дока при сверке не найдено)
- coder: NO OBJECTIONS (handoff-статус In review подтверждается сверкой с диском — receipt в Evidence)
- Intake (2026-11-14 00:30:09): AGENTS.md@eb9cffe8 reviewer-risk.md@b58755ea
  (digest'ы пересчитаны `shasum -a 256` — оба контракта неизменны с моего intake Round 1 (00:06:38); run.md изменён fixes-итерацией @18445945 → @90cc3434 — смена зафиксирована миграционной записью §3 п.7 в Evidence 00:19:07, норма п.7, повторный диспатч не нужен; план перечитан с диска целиком, статус In review сверен с PRE_STATUS_LINE конверта — совпал; fixes-дельта Round 1 изучена: run.md staged-версия шага 4 перечитана, findings 1–2 закрыты — проверка в review-артефакте Round 2)
- reviewer-risk: NO QUESTIONS (конверт раунда 2 однозначен: проверка устранения findings Round 1, Round 2 в том же артефакте с superseded-разметкой)
- reviewer-risk: NO SUGGESTIONS (на этапе intake; находки раунда 2 — в review-артефакт; предложение Coder'а из Suggestions log 00:16:44 по шагу (г) триажируется в этом раунде как finding-кандидат)
- reviewer-risk: NO OBJECTIONS (противоречий плана самому себе при сплошном повторном чтении не найдено; статусная механика fixes-раунда — In review → In progress → In review — соответствует новой строке §2)
- Intake (2026-11-14 00:33:12): AGENTS.md@eb9cffe8 coder.md@976c292b
  (fixes-итерация, needs-fix раунд 2 — риск-вердикт Round 2 review-артефакта; digest'ы пересчитаны `shasum -a 256` — оба контракта неизменны с fixes-intake раунда 1 (00:16:44), run.md@90cc3434 = миграционной записи 00:19:07; план и review-артефакт перечитаны с диска целиком: Round 2 — единственная находка 1 major, шаг (г) merge-рутины (мой кандидат из Suggestions log 00:16:44, триажирован risk-лайном в finding); findings 1–2 Round 1 ланом подтверждены закрытыми; внешняя дельта с моего CENSOR-receipt — usage-строки Manager и intake reviewer-risk раунда 2 (их зоны, не правились); по конверту ставлю `In progress`)
- coder: NO QUESTIONS (находка единственна и однозначна — санкционированные шагом (в) добавления не считаются расхождением в (г); оба контраргумента лана отклонены в самом finding'е, развилок нет)
- coder: NO SUGGESTIONS (новых кандидатов вне finding'а при повторном сплошном чтении merge-рутины не найдено — шаги (а)–(в) подтверждены ланом в новой редакции)
- coder: NO OBJECTIONS (правка в пределах Scope п.1 «merge по явному списку + контроли»; DoD-текст не правится — D2 сохраняет сверку со списком Итога, исключение санкционировано вердиктом Round 2)
- Intake (2026-11-14 00:35:29): AGENTS.md@eb9cffe8 coder.md@976c292b
  (CENSOR-итерация fixes-раунда 2; digest'ы пересчитаны `shasum -a 256` — оба контракта неизменны с fixes-intake 00:33:12, run.md@2a6176bd = миграционной записи 00:34:10; план перечитан с диска целиком, статус In review сверен с PRE_STATUS_LINE конверта censor:coder:261114_003450 — совпал; внешняя дельта с handoff — одна usage-строка Manager 00:34:50, зона §1(f), не правится)
- coder: NO QUESTIONS (конверт CENSOR однозначен: сверка собственного handoff fixes-итерации раунда 2 с файлами, не с памятью)
- coder: NO SUGGESTIONS (дефектов собственной зоны по чек-листу роль-дока при сверке не найдено)
- coder: NO OBJECTIONS (handoff-статус In review подтверждается сверкой с диском — receipt в Evidence)
- Intake (2026-11-14 00:38:20): AGENTS.md@eb9cffe8 reviewer-risk.md@b58755ea
  (digest'ы пересчитаны `shasum -a 256` — оба контракта неизменны с моего intake Round 1/2; run.md изменён fixes-итерацией раунда 2 @90cc3434 → @2a6176bd — смена зафиксирована миграционной записью §3 п.7 в Evidence 00:34:10, норма п.7, повторный диспатч не нужен; план перечитан с диска целиком, статус In review сверен с PRE_STATUS_LINE конверта — совпал; staged-версия шага (г) перечитана — проверка finding 1 Round 2 в review-артефакте Round 3)
- reviewer-risk: NO QUESTIONS (конверт раунда 3 однозначен: проверка устранения finding Round 2, Round 3 с superseded-разметкой)
- reviewer-risk: NO SUGGESTIONS (на этапе intake; находки раунда 3 — в review-артефакт; Suggestions log закрыт строкой 00:33:07 — открытым предложение Coder'а не висит)
- reviewer-risk: NO OBJECTIONS (противоречий плану самому себе при сплошном повторном чтении не найдено; траектория In review → In progress → In review fixes-раунда 2 соответствует строке needs-fix §2)
- Intake (2026-11-14 00:44:40): AGENTS.md@eb9cffe8 reviewer-contracts.md@a7bcfdfa
  (contracts-лан Round 3; digest'ы сняты `shasum -a 256` в момент чтения — оба контракта неизменны с миграционных значений Evidence 23:59:10 (AGENTS.md @7ec6d0f4 → @eb9cffe8; reviewer-contracts.md @8d1efb83 → @a7bcfdfa), незафиксированного дрейфа нет; план перечитан с диска целиком, статус In review сверен с PRE_STATUS_LINE конверта — совпал; review-артефакт прочитан: Risk lane Round 3 заполнен, вердикт pass — последовательность лейнов risk → contracts соблюдена, Итог собирать можно)
- reviewer-contracts: NO QUESTIONS (конверт PHASE=review однозначен: сверка staged против плана — DoD D1–D16, Scope, ничего лишнего; предмет — staged 20 файлов, риски — зона risk-лайна)
- reviewer-contracts: NO SUGGESTIONS (на этапе intake; находки раунда 3 — в таблицу Contracts lane review-артефакта)
- reviewer-contracts: NO OBJECTIONS (противоречий плана самому себе при сплошном чтении не найдено; дельта раунда 3 — оговорка шага (г) merge-рутины, санкционирована вердиктом Round 2, DoD-тексты не правились)

## Suggestions log (chronological, append-only)
<!-- owner: все роли; несрочные улучшения -->

- 2026-11-14 00:16:44 — Coder: merge-рутина `.zcode/commands/planfaktor-run.md` шаг 4(г): сравнение состава merge-коммита (`git show --stat`) с дословным Итог-списком `git diff --cached --name-only` даёт гарантированное расхождение на merge-гейте любого плана — review-артефакт добавляется в коммит шагом (в), но на момент contracts-вердикта (снимок Итога) не staged (ревьюеры не стейджат); буквальное «расхождение = захвачено постороннее» ложно сработает на санкционированном файле. Предложение: уточнить (г) — добавленные шагом (в) план/review-артефакт расхождением не считаются. Не правлю в fixes-раунде 1 — why: вне findings Round 1 risk-лайна (ланы (г) не поднимали), дисциплина needs-fix; триаж — Manager/раунд 2.
- 2026-11-14 00:33:07 — Coder: закрыто — предложение выше промотировано risk-лайном в finding 1 Round 2 (major) и устранено fixes-итерацией раунда 2: шаг (г) run.md дополнен оговоркой «санкционированные шагом (в) добавления … расхождением не считаются» (run.md @2a6176bd, миграция в Evidence).

## Objections log (chronological, append-only)
<!-- owner: все роли; `### <Role> objections`; строка на возражение, blocker: при блокере -->

## Follow-ups (deferred)
<!-- owner: coder/planner при CENSOR; незакрытые хвосты: <описание> — why: <почему сейчас не в скоупе>; обязательна запись `NO FOLLOW-UPS — why: <код_причины>` при отсутствии -->

- NO FOLLOW-UPS — why: out-of-scope-backlog — все отложенные классы уже живут в `docs/followups/backlog.md` (qa-lint — с примечанием о грамматике `#<n>` по D13; ci-v2-static, lint-robustness — Out of scope п.4); самоприменение D4 — гейт-действие Manager внутри этого плана, не хвост; детализация Planner'а новых незакрытых классов не вскрыла.

