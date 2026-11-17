# Owner quickstart README

**Plan ID:** 261111_0427
**Status:** Done
**Created:** 2026-11-11
**Owner gates:** старт кодинга (`Ready for Coder`), merge (`In review` → `Merged`)

> Шапка — parser-контракт: строки выше grep'ются Manager'ом. Не менять формат.
> Имя файла: `YYMMDD_HHMM_topic.md` (тема латиницей, слова через `_`).

## Как я понял задачу
<!-- owner: architect; 3–7 строк; обязательна при Architect intake -->

- Переписать корневой `README.md` (сейчас — визитка эпохи бутстрапа, 631 байт)
  в быстрый старт Owner: что такое Planfaktor, роли и два гейта Owner, три
  команды, как читать план и review-артефакт.
- Аудитория — человек в чате (Owner), не разработчик конвейера: минимум
  теории, максимум «что запустить и где посмотреть».
- Сквозное требование брифа — проверяемость: каждая команда/агент/файл,
  упомянутые в README, обязаны существовать в репо; проверяемую форму DoD
  формализует Planner.
- README — входная дверь, не второй справочник: детали цикла остаются
  в `docs/lifecycle.md`, правила — в `AGENTS.md`; README на них ссылается.
- Меняется только `README.md`; остальные артефакты корпуса не трогаем.

## Problem
<!-- owner: architect; пронумерованные пункты -->

1. Текущий `README.md` — заготовка бутстрапа: метафора, статусный лозунг
   «сутки на первый рабочий прогон», заметка про `.tmp/`. Он не отвечает
   на вопросы Owner-новичка: что это за система, что в ней делаю я,
   какими командами, где смотреть состояние и вопросы к себе.
2. У корпуса нет единой входной точки для человека: `AGENTS.md` — плотная
   конституция для ролей, `docs/lifecycle.md` — справочник цикла; короткого
   пути «три команды + два гейта + как читать план/review» нет нигде.
3. Риск рассинхрона документации: README, перечисляющий команды, агентов
   и файлы, со временем ссылается на переименованное/удалённое. Отсюда
   требование брифа — grep-проверяемость каждого упомянутого имени.
4. Статусный лозунг «сутки на первый рабочий прогон» стареет и не несёт
   quickstart-ценности — README должен быть вечным входом, не чек-поинтом
   валидации.

## Solution / Decisions
<!-- owner: architect; решения уровня «что и почему», без детализации -->

1. **Полная перезапись `README.md`** вместо расширения существующего текста:
   склейка quickstart'а с бутстрап-визиткой даст два голоса в одном файле.
   Альтернатива «отдельный `docs/quickstart.md`» отклонена: Owner входит
   в репо с корня, README — естественная дверь.
2. **Структура README (уровень блоков):**
   - «Что такое Planfaktor» — 2–3 строки (plan-driven конвейер ролей, целиком
     в ZCode, без рантайма; истина маршрутизации — статусы в файлах планов)
     + явная ссылка на `AGENTS.md` как конституцию;
   - «Роли и два гейта» — компактный список ролей из §1 конституции
     (Owner, Manager, Architect, Planner, Coder, Reviewer-risk,
     Reviewer-contracts) и выделенные два гейта Owner: старт кодинга
     (`Ready for Coder` → `In progress`) и merge (`In review` → `Merged`);
   - «Три команды» — по одной строке на `/planfaktor-plan` (создать план),
     `/planfaktor-run` (шаг конвейера), `/planfaktor-status` (обзор без
     изменений);
   - «Как читать план» — шапка = parser-контракт, строка `**Status:**`
     как истина маршрутизации, ownership-метки секций, append-only логи;
     отдельно показать Owner, где его вопросы: строки `to=Owner`
     в `## Q&A log`;
   - «Как читать review» — артефакт `docs/reviews/<PlanID>_review.md`,
     лейны risk → contracts, вердикты, актуален только последний
     `**Round:**`;
   - «Куда дальше» — `docs/lifecycle.md` (жизненный цикл), `docs/decisions.md`
     (журнал решений), `docs/playbooks/manual_terminal_recovery.md`
     (ручное восстановление).
3. **Канонический список упоминаемого** (всё существует в репо на момент
   плана; это и есть объект grep-проверки): команды `.zcode/commands/`
   (`planfaktor-plan.md`, `planfaktor-run.md`, `planfaktor-status.md`), субагенты
   `.zcode/agents/` (`planfaktor-architect.md`, `planfaktor-planner.md`,
   `planfaktor-coder.md`, `planfaktor-reviewer-risk.md`,
   `planfaktor-reviewer-contracts.md`), `AGENTS.md`, `docs/lifecycle.md`,
   `docs/decisions.md`, `docs/plans/_template.md`,
   `docs/reviews/_template_review.md`, `docs/roles/`,
   `docs/playbooks/manual_terminal_recovery.md`. Примеры имён планов —
   только паттерном `YYMMDD_HHMM_topic.md`, без хардкода текущих имён
   (чтобы README не старел вместе с очередью).
4. **Что не переносим из старого README:** статусный лозунг «сутки на первый
   рабочий прогон» и заметку про `.tmp/` — валидационный чек-поинт, не
   quickstart. Метафора молевого сплава — максимум одна строка идентичности
   в вводном блоке, не отдельная секция.
5. **Язык — русский**, как во всём корпусе. Альтернатива (англ. README)
   отклонена: разрыв языка с конституцией и ролями.
6. **README компактный** (качественный ориентир «экран-полтора»), не
   дублирует таблицы `AGENTS.md`/`docs/lifecycle.md` дословно — иначе
   появятся три рассинхронизируемых справочника.

## Scope
<!-- owner: architect (границы), planner (уточняет); список изменений -->

- Полная перезапись `/README.md` (один файл) как Owner-quickstart по
  структуре из Solution/Decisions п.2.
- Все упоминаемые в README команды/агенты/пути — из фактического состава
  репо (канонический список — Solution/Decisions п.3).

## Out of scope
<!-- owner: architect -->

- Правки любых других файлов: `AGENTS.md`, `docs/lifecycle.md`,
  `docs/decisions.md`, `docs/plans/*` (включая `_template.md`),
  `docs/reviews/*`, `docs/roles/*`, `.zcode/commands/*`, `.zcode/agents/*`.
- Создание новых файлов/шаблонов, англоязычная версия README, бейджи,
  инструкции по установке (устанавливать нечего — репо и есть конвейер).
- Изменение формата шапок планов/команд или статуса соседних планов.
- Материалы валидации в `.tmp/`.

## Acceptance criteria / DoD
<!-- owner: planner; чек-лист проверяемых исходов; каждый пункт = проверяемое утверждение -->

- [ ] D1. `README.md` переписан целиком: статусный лозунг «сутки на
  первый рабочий прогон» и упоминание `.tmp/` отсутствуют (Solution
  п.4); метафора молевого сплава — максимум одна строка идентичности
  в вводном блоке; текст на русском (технические имена — команды,
  статусы, пути — как есть).
- [ ] D2. Шесть смысловых блоков из Solution п.2 присутствуют и следуют
  в порядке: «Что такое Planfaktor» → «Роли и два гейта» → «Три команды»
  → «Как читать план» → «Как читать review» → «Куда дальше»; таблицы
  `AGENTS.md`/`docs/lifecycle.md` не дублируются дословно (Solution
  п.6).
- [ ] D3. Вводный блок: 2–3 строки о том, что такое Planfaktor (plan-driven
  конвейер ролей, целиком в ZCode, без рантайма; истина маршрутизации —
  статусы в файлах планов) + явная ссылка на `AGENTS.md` как
  конституцию.
- [ ] D4. Блок «Роли и два гейта»: названы все 7 ролей §1 конституции
  (Owner, Manager, Architect, Planner, Coder, Reviewer-risk,
  Reviewer-contracts); выделены оба гейта Owner — старт кодинга
  («стартуем», `Ready for Coder` → `In progress`) и merge («мержим»,
  `In review` → `Merged`) — обе пары статусов присутствуют дословно
  (A(owner) из Q&A log).
- [ ] D5. Блок «Три команды»: `/planfaktor-plan` (создать план),
  `/planfaktor-run` (шаг конвейера), `/planfaktor-status` (обзор без
  изменений) — по одной строке на команду с назначением.
- [ ] D6. Блок «Как читать план»: шапка = parser-контракт; строка
  `**Status:**` — истина маршрутизации; ownership-метки секций;
  append-only логи; явно указано, где вопросы Owner: строки `to=Owner`
  в `## Q&A log`.
- [ ] D7. Блок «Как читать review»: путь артефакта
  `docs/reviews/<PlanID>_review.md`; лейны risk → contracts; вердикты;
  актуален только последний `**Round:**`.
- [ ] D8. Блок «Куда дальше»: ссылки на `docs/lifecycle.md` (жизненный
  цикл), `docs/decisions.md` (журнал решений),
  `docs/playbooks/manual_terminal_recovery.md` (ручное восстановление).
- [ ] D9. Полнота по каноническому списку (Solution п.3): в README
  упомянуты все 15 позиций — команды `/planfaktor-plan`, `/planfaktor-run`,
  `/planfaktor-status` (слэш-имёнами), субагенты Architect, Planner,
  Coder, Reviewer-risk, Reviewer-contracts (именами ролей),
  `AGENTS.md`, `docs/lifecycle.md`, `docs/decisions.md`,
  `docs/plans/_template.md`, `docs/reviews/_template_review.md`,
  `docs/roles/`, `docs/playbooks/manual_terminal_recovery.md`.
- [ ] D10. Инвариант существования (ядро брифа): каждый путь вида
  `docs/...`/`.zcode/...`, упомянутый в README, существует в репо
  (плейсхолдеры-паттерны `YYMMDD_HHMM*` — исключение); каждая слэш-команда
  `/planfaktor-*` из README имеет файл `.zcode/commands/<имя>.md`.
- [ ] D11. Инвариант свежести: конкретные имена планов (вида
  `NNNNNN_NNNN_<тема>`, цифрами) в README отсутствуют; примеры имён
  планов — только паттерном `YYMMDD_HHMM_topic.md` (Solution п.3).
- [ ] D12. Компактность (Solution п.6): `wc -l README.md` — не более
  100 строк; связный кириллический текст — не менее 20 строк с
  кириллицей.
- [ ] D13. Границы: `git status --porcelain` показывает только `README.md`
  и записи планов `docs/plans/*` (сам план
  `261111_0427_owner_quickstart_readme.md` и пред-существующая правка
  closeout `docs/plans/261111_0320_pipeline_timing.md` — зона Manager'а,
  Coder'ом не трогается и не стейджится); изменений других файлов нет;
  Coder стейджит `README.md`, не коммитит (§8).

## Tests / Commands
<!-- owner: planner (задаёт), coder (заполняет факт); что прогнать и что должно получиться -->

Команды прогоняются из корня репо. Ожидаемый результат — обязательный
критерий прохождения; Coder вписывает факт прогона под каждой командой
и дублирует в `## Evidence`. Нумерация T<i> ссылается на пункты DoD
в порядке их следования.

T1 (DoD: D1 — вычистка старого; D2 — структура; D12 — компактность)

```sh
grep -n 'сутки на первый рабочий прогон' README.md; grep -n '\.tmp' README.md
grep -n '^#' README.md
wc -l README.md; grep -c '[А-Яа-яЁё]' README.md
```

Ожидание: первые два grep — пусты (exit 1); `grep -n '^#'` — заголовки
шести блоков Solution п.2 в порядке «Что такое Planfaktor» → «Роли и два
гейта» → «Три команды» → «Как читать план» → «Как читать review» →
«Куда дальше»; `wc -l` ≤ 100; строк с кириллицей ≥ 20. Осмотр: метафора
сплава ≤ 1 строки; таблицы AGENTS.md/docs/lifecycle.md не скопированы
дословно.

Факт (2026-11-11 04:55): оба grep пусты (exit 1 — лозунга и `.tmp` нет);
`grep -n '^#'`: `# Planfaktor` (1) + шесть H2 в порядке — «Что такое Planfaktor»
(6) → «Роли и два гейта» (13) → «Три команды» (32) → «Как читать план»
(38) → «Как читать review» (53) → «Куда дальше» (61); `wc -l` = 66 ≤ 100;
кириллица на 47 строках ≥ 20. Осмотр: метафора сплава — одна строка
(строка 9, вводный блок); таблиц в README нет — роли списком. Ожидание
выполнено.

T2 (DoD: D3 — вводный блок; D4 — роли и гейты)

```sh
grep -n 'AGENTS.md' README.md
for role in Owner Manager Architect Planner Coder Reviewer-risk Reviewer-contracts; do grep -q "$role" README.md || echo "MISSING ROLE: $role"; done
grep -n 'Ready for Coder' README.md; grep -n 'In progress' README.md; grep -n 'In review' README.md; grep -n 'Merged' README.md
```

Ожидание: ссылка на `AGENTS.md` — ≥1 строка во вводном блоке; цикл
ролей — пустой вывод (все 7 названы); четыре grep статусов — непустые,
обе пары переходов (`Ready for Coder` → `In progress`;
`In review` → `Merged`) читаются в блоке «Роли и два гейта». Осмотр:
гейты поименованы («стартуем»/«мержим» или равнозначно «старт
кодинга»/«merge»).

Факт (2026-11-11 04:55): `AGENTS.md` — строки 11, 15 (обе упоминают
конституцию, 11 — внутри вводного блока «Что такое Planfaktor»); цикл ролей —
пустой вывод, MISSING нет (все 7 названы: Owner — 17, Manager — 18,
Architect — 19, Planner — 20, Coder — 21, Reviewer-risk — 22,
Reviewer-contracts — 23); статусы:
`Ready for Coder` и `In progress` — строка 28, `In review` и `Merged` —
строка 29, обе пары переходов — в блоке «Роли и два гейта»; гейты
поименованы «стартуем» (28, «старт кодинга») и «мержим» (29, «merge»).
Ожидание выполнено.

T3 (DoD: D5 — три команды)

```sh
grep -n '/planfaktor-plan\|/planfaktor-run\|/planfaktor-status' README.md
grep -oE '/planfaktor-[a-z]+' README.md | sort -u
```

Ожидание: первый grep — ≥3 строк (по строке на команду с назначением);
второй — ровно 3 строки: `/planfaktor-plan`, `/planfaktor-run`,
`/planfaktor-status`, иных `/planfaktor-*` имён нет.

Факт (2026-11-11 04:55): первый grep — 3 строки (34–36), на каждой команда
и назначение; `sort -u` — ровно 3 строки: `/planfaktor-plan`, `/planfaktor-run`,
`/planfaktor-status`, иных нет. Ожидание выполнено.

T4 (DoD: D6 — как читать план)

```sh
grep -n '\*\*Status:\*\*' README.md; grep -n 'to=Owner' README.md; grep -n 'Q&A' README.md
```

Ожидание: все три grep — непустые: строка `**Status:**` (дословный
маркер), указание «вопросы Owner — строки `to=Owner`», упоминание
`## Q&A log`. Осмотр: шапка-parser-контракт, ownership-метки секций,
append-only — упомянуты.

Факт (2026-11-11 04:55): `**Status:**` — строка 44 (дословный маркер);
`to=Owner` — строка 50; `Q&A` — строки 48, 50 (`## Q&A log`). Осмотр:
шапка = parser-контракт — строка 42, ownership-метки — строка 46,
append-only — строка 48. Ожидание выполнено.

T5 (DoD: D7 — как читать review)

```sh
grep -n 'docs/reviews' README.md; grep -n 'Round' README.md
```

Ожидание: оба grep — непустые (путь артефакта
`docs/reviews/<PlanID>_review.md`, «актуален последний `**Round:**`»).
Осмотр: лейны risk → contracts и вердикты упомянуты.

Факт (2026-11-11 04:55): `docs/reviews` — строки 55, 56
(`docs/reviews/<PlanID>_review.md` и шаблон
`docs/reviews/_template_review.md`); `Round` — строка 59
(«действителен только последний `**Round:**`»). Осмотр: лейны
«risk → contracts» — строки 56–57; вердикты `pass`/`needs-fix` —
строка 57. Ожидание выполнено.

T6 (DoD: D8 — куда дальше)

```sh
grep -n 'docs/lifecycle.md' README.md; grep -n 'docs/decisions.md' README.md; grep -n 'docs/playbooks/manual_terminal_recovery.md' README.md
```

Ожидание: все три grep — непустые, ссылки в блоке «Куда дальше».

Факт (2026-11-11 04:55): `docs/lifecycle.md` — строка 63,
`docs/decisions.md` — 64, `docs/playbooks/manual_terminal_recovery.md` —
65; все три — в блоке «Куда дальше» (заголовок на строке 61).
Ожидание выполнено.

T7 (DoD: D9 — полнота канонического списка, Solution п.3)

```sh
for name in '/planfaktor-plan' '/planfaktor-run' '/planfaktor-status' 'Architect' 'Planner' 'Coder' 'Reviewer-risk' 'Reviewer-contracts' 'AGENTS.md' 'docs/lifecycle.md' 'docs/decisions.md' 'docs/plans/_template.md' 'docs/reviews/_template_review.md' 'docs/roles' 'docs/playbooks/manual_terminal_recovery.md'; do grep -q -- "$name" README.md || echo "MISSING IN README: $name"; done
```

Ожидание: вывод пуст — все 15 позиций канонического списка упомянуты
в README.

Факт (2026-11-11 04:56): вывод пуст — MISSING IN README нет, все 15
позиций канонического списка найдены в README (команды — слэш-имёнами
строки 34–36; роли Architect/Planner/Coder/Reviewer-risk/
Reviewer-contracts — строки 19–23; `AGENTS.md` — 11; `docs/roles/` — 15;
`docs/plans/_template.md` — 41; `docs/reviews/_template_review.md` — 56;
`docs/lifecycle.md` — 63; `docs/decisions.md` — 64;
`docs/playbooks/manual_terminal_recovery.md` — 65). Ожидание выполнено.

T8 (DoD: D10 — инвариант существования: всё упомянутое существует)

```sh
grep -oE '(docs|\.zcode)/[A-Za-z0-9_/.-]+' README.md | sed 's/[.,;:)]*$//' | sort -u | grep -v 'YYMMDD_HHMM' | while read -r p; do test -e "$p" || echo "MISSING IN REPO: $p"; done
grep -oE '/planfaktor-[a-z]+' README.md | sed 's/^\///' | sort -u | while read -r c; do test -e ".zcode/commands/$c.md" || echo "MISSING COMMAND FILE: $c.md"; done
```

Ожидание: оба конвейера — пустой вывод: каждый упомянутый путь
`docs/...`/`.zcode/...` существует в репо (паттерн-плейсхолдеры
`YYMMDD_HHMM*` исключены — им не обязан соответствовать файл), каждая
слэш-команда имеет файл `.zcode/commands/<имя>.md`.

Факт (2026-11-11 04:56): оба конвейера пусты — MISSING IN REPO и
MISSING COMMAND FILE нет. Упомянутые пути существуют:
`docs/plans/`, `docs/plans/_template.md`, `docs/reviews/`,
`docs/reviews/_template_review.md`, `docs/roles/`, `docs/lifecycle.md`,
`docs/decisions.md`, `docs/playbooks/manual_terminal_recovery.md`;
плейсхолдер `docs/plans/YYMMDD_HHMM_topic.md` исключён фильтром;
`AGENTS.md` — корень (ссылкой); файлы команд —
`.zcode/commands/planfaktor-{plan,run,status}.md` (3/3). Ожидание
выполнено.

T9 (DoD: D11 — инвариант свежести: без хардкода имён планов)

```sh
grep -nE '[0-9]{6}_[0-9]{4}_[a-z0-9_]+' README.md
```

Ожидание: пусто (exit 1) — конкретных имён планов нет; осмотр: примеры
имён планов (если приводятся) — только паттерном
`YYMMDD_HHMM_topic.md` (буквами, этим grep не матчатся).

Факт (2026-11-11 04:56): вывод пуст, exit 1 — конкретных имён планов
нет; единственный пример имени плана — паттерн `YYMMDD_HHMM_topic.md`
буквами (строка 40). Ожидание выполнено.

T10 (DoD: D13 — границы изменений)

```sh
git status --porcelain
```

Ожидание: ровно три записи — `M README.md`, `??
docs/plans/261111_0427_owner_quickstart_readme.md` и пред-существовавший
до старта Coder `M docs/plans/261111_0320_pipeline_timing.md` (closeout
Manager'а плана 261111_0320 — вне Scope, Coder'ом не правится
и не стейджится); ничего сверх. После прогона всех тестов Coder
стейджит `README.md` (`git add README.md`), не коммитит (§8).

Факт (2026-11-11 04:58:52): до стейджинга — ровно три записи: `M README.md`,
`M docs/plans/261111_0320_pipeline_timing.md`,
`?? docs/plans/261111_0427_owner_quickstart_readme.md`. После
`git add README.md` — те же три записи на те же файлы (`M  README.md`
стейджнут; `git diff --cached --stat`: единственный файл README.md,
+62/−6); closeout-правка 0320 и план 0427 не стейджнуты; коммит не
выполнялся (§8). Ожидание выполнено.

## Changes (by area)
<!-- owner: coder; фактические изменения по областям; заполняется в ходе работы -->

- `README.md` — полная перезапись (было 10 строк бутстрап-визитки → 66 строк
  Owner-quickstart): H1-вводка + шесть блоков по Solution п.2 в каноническом
  порядке — «Что такое Planfaktor» (идентичность, метафора сплава одной строкой,
  ссылка на конституцию `AGENTS.md`), «Роли и два гейта» (все 7 ролей списком
  без дублирования таблиц конституции; оба гейта Owner — «стартуем»
  (`Ready for Coder` → `In progress`) и «мержим» (`In review` → `Merged`)),
  «Три команды» (`/planfaktor-plan`, `/planfaktor-run`, `/planfaktor-status` — по
  строке с назначением), «Как читать план» (шапка = parser-контракт,
  `**Status:**` как истина маршрутизации, ownership-метки, append-only логи,
  вопросы Owner = `to=Owner` в `## Q&A log`), «Как читать review»
  (`docs/reviews/<PlanID>_review.md`, лейны risk → contracts, вердикты,
  актуален последний `**Round:**`), «Куда дальше» (`docs/lifecycle.md`,
  `docs/decisions.md`, `docs/playbooks/manual_terminal_recovery.md`).
  Удалены статусный лозунг «сутки на первый рабочий прогон» и заметка про
  `.tmp/` (Solution п.4); имена планов — только паттерном
  `YYMMDD_HHMM_topic.md`. Канонический список Solution п.3 покрыт полностью
  (15/15, факт T7).
- `docs/plans/261111_0427_owner_quickstart_readme.md` (зона Coder): intake
  в `## Q&A log`; факт-прогоны T1–T10 в `## Tests / Commands`; эта секция
  `## Changes (by area)`; Evidence-записи фазы; статус `In review`.

## Evidence (chronological, append-only)
<!-- owner: все роли + CENSOR; событийные записи с датой и локальным временем `- YYYY-MM-DD HH:MM:SS — <кто>: <текст>`; CENSOR-receipt по формату конституции -->

- 2026-11-11 04:27:18 — Manager: план создан из шаблона по `/planfaktor-plan`. Owner-бриф (передан ночной кураторской сессией): «Owner quickstart README». Суть: переписать `README.md` в корне как быстрый старт Owner: что такое Planfaktor, роли и два гейта, три команды, как читать план и review. DoD — grep-проверяемый: каждая команда/агент/файл, упомянутые в README, существуют в репо.
- 2026-11-11 04:30:19 — Architect: фаза завершена; заполнены «Как я понял задачу», Problem, Solution/Decisions (структура README + канонический список упоминаемого), Scope/Out of scope; открытых вопросов к Owner нет (intake: NO QUESTIONS / NO SUGGESTIONS / NO OBJECTIONS); статус Ready for Planner.
- 2026-11-11 04:33:10 — Manager (fail loud на себя): план создан из устаревшей копии `_template.md` в контексте Manager'а (прочитанной до merge-коммита 782971a плана 261111_0320, обновившего шаблон) — комментарии секций Evidence/Q&A несли старый формат; Architect'а это ввело в заблуждение: intake-строка записана без HH:MM:SS. Комментарии приведены к текущему шаблону; конверт возвращается Architect'у для переоформления intake по §3 (append-only). Трение dogfood: `/planfaktor-plan` предписывает копию шаблона, но не перечтение шаблона с диска в момент создания.
- 2026-11-11 04:35:24 — Architect: intake переоформлен корректной contract-строкой по §3 (HH:MM:SS, AGENTS.md@b5b5cdf8; прежняя строка сохранена по append-only с пояснением). Аудит остальных своих записей против текущих комментариев шаблона: Evidence-строка 04:30:19 уже с полной меткой `YYYY-MM-DD HH:MM:SS — <кто>:`; «Как я понял задачу» (5 пунктов из 3–7), Problem (пронумерован), Solution/Decisions, Scope/Out of scope — формату соответствуют; иных влияний устаревших комментариев не найдено. Статус не менялся: Ready for Planner.
- 2026-11-11 04:37:05 — Architect: CENSOR-проход (сверка handoff с файлами; receipt ниже).

(Role CENSOR) OK: Ready for Planner validated; current=true
Censor dispatch id: censor:architect:261111_043613
Observations:
- Second opinion: шапка — `**Status:** Ready for Planner` (строка 4), Plan ID `261111_0427` согласован с именем файла `261111_0427_owner_quickstart_readme.md`; Evidence-строка 04:30:19 заявляет тот же handoff-статус — файл и запись совпадают. Секции архитектора заполнены и непротиворечивы: «Как я понял задачу» (5 пунктов), Problem (п.1–4), Solution/Decisions (п.1–6, у каждого «что и почему», нетривиальные альтернативы — с обоснованием отказа), Scope (один файл `/README.md`), Out of scope (4 пункта). Открытых вопросов к Owner нет и потерянных нет: в Q&A log единственный закрытый `A(owner)` и intake-записи. Intake актуальной итерации канонический: `Intake (2026-11-11 04:35:24): AGENTS.md@b5b5cdf8 architect.md@73ace930` с пояснением коррекции (старая строка сохранена по append-only).
- Counterfactuals considered: (а) канонический список Solution п.3 мог ссылаться на несуществующее — факт-проверка диска: все 15 позиций существуют (команды 3/3 в `.zcode/commands/`, субагенты 5/5 в `.zcode/agents/`, `AGENTS.md`, `docs/lifecycle.md`, `docs/decisions.md`, оба шаблона, `docs/roles/`, плейбук); (б) «631 байт» в «Как я понял задачу» мог устареть — `wc -c README.md` даёт 631; (в) бриф говорит «три команды» — в `.zcode/commands/` ровно три, список не неполон и не избыточен; (г) две intake-строки могли создать двусмысленность «какая текущая» — последняя канонического формата §3 и с явным пояснением, текущей признана она; (д) корректирующая правка могла задеть чужую зону — DoD/Tests/Changes остались нетронутыми плейсхолдерами шаблона, шапка не менялась.
- Addendum (new angle): сверил хэши контрактов на момент CENSOR (AGENTS.md@b5b5cdf8, architect.md@73ace930) — не менялись с intake, решения принимались по действующей конституции; сверил связку Problem п.1/п.4 ↔ Solution п.4 («что не переносим») — противоречий нет; проверил непересечение моего Scope с посторонней правкой `docs/plans/261111_0320_pipeline_timing.md` в рабочем дереве — не пересекается.
- Fixes: ничего — дефектов в своей зоне не найдено.
- Final censor verdict: OK
- 2026-11-11 04:39:05 — Manager: Architect CENSOR OK подтверждён grep'ом (маркер, dispatch id censor:architect:261111_043613, вердикт OK, Observations непустые); переход Draft → Ready for Planner валиден. Зафиксированное отклонение (dogfood-находка, не блокер): receipt записан без префикса `- YYYY-MM-DD HH:MM:SS — ` на строке маркера — метка времени есть соседней строкой (04:37:05), grep-гейт Manager'а префикс не проверяет, пропуск состоялся; риск-уровень косметический. Диспатч Planner.
- 2026-11-11 04:52:30 — Manager: Planner CENSOR OK подтверждён grep'ом (dispatch id censor:planner:261111_044825, вердикт OK, Observations непустые, receipt с меткой времени); переход Planning → Ready for Coder валиден. Гейт «стартуем» пройден по предаторизации Owner'ом (Q&A log, первая запись, status=closed); статус In progress; диспатч Coder.
- 2026-11-11 04:47:35 — Planner: intake сверен (PRE_STATUS_LINE=Ready for Planner совпадал с шапкой; AGENTS.md@b5b5cdf8, planner.md@97f968d8), статус Planning; фаза завершена — DoD заполнен 13 проверяемыми критериями (D1–D13: перезапись и запреты старого, структура шести блоков, роли/гейты, три команды, чтение плана и review, ссылки, полнота канонического списка из 15 позиций, grep-инварианты существования/свежести, компактность, границы), Tests/Commands заданы (T1–T10: команда + ожидаемый результат, покрытие DoD полное: D1/D2/D12→T1, D3/D4→T2, D5→T3, D6→T4, D7→T5, D8→T6, D9→T7, D10→T8, D11→T9, D13→T10); механика T8/T9 калибрована прогоном на синтетическом примере (хвостовая пунктуация, плейсхолдер YYMMDD_HHMM, хардкод имени плана); перенос Q&A: A(owner) о гейтах — имена «стартуем»/«мержим» и пары переходов закреплены в DoD D4, процессная часть (предаторизация) — зона Manager'а, отражена шапкой Owner gates; открытых вопросов в Q&A log нет; состав репо сверен с каноническим списком фактом (3 команды, 5 агентов, все доки существуют); T10 учитывает пред-существовавший M docs/plans/261111_0320_pipeline_timing.md (closeout Manager'а, вне Scope); статус Ready for Coder.
- 2026-11-11 04:51:00 — (Role CENSOR) OK: Ready for Coder validated; current=true
Censor dispatch id: censor:planner:261111_044825
Observations:
- Second opinion: шапка перечитана — `**Status:** Ready for Coder` (строка 4), Plan ID `261111_0427` согласован с именем файла `261111_0427_owner_quickstart_readme.md`, PRE_STATUS_LINE конверта censor:planner:261111_044825 совпал; Evidence-строка 04:47:35 заявляет тот же handoff — файл и запись совпадают. DoD перечитан (D1–D13, строки 114–169): каждый пункт — утверждение, проверяемое прогоном или осмотром, без «по необходимости»/«и т.д.»; Tests T1–T10 перечитаны — у каждой команды «Ожидание», покрытие DoD полное (D1/D2/D12→T1, D3/D4→T2, D5→T3, D6→T4, D7→T5, D8→T6, D9→T7, D10→T8, D11→T9, D13→T10). Перенос Q&A сверен: A(owner) — имена гейтов и пары переходов в DoD D4, процессная часть (предаторизация) — шапка Owner gates; открытых `to=Owner`-вопросов в Q&A log нет. Чужие зоны: «Как я понял задачу» (5 пунктов), Problem (1–4), Solution/Decisions (1–6), Scope (2 позиции), Out of scope (4), Changes (пуст, зона Coder), логи Suggestions/Objections/Follow-ups — не тронуты. Контракты по shasum — AGENTS.md@b5b5cdf8, planner.md@97f968d8, совпадают с рабочей итерацией 04:43:16.
- Counterfactuals considered: (а) T2/T7 ищут имена ролей с заглавной ('Coder' не заматчит 'planfaktor-coder') — сверено с Solution п.2 и D4/D9: роли в README именуются с заглавной, требование согласовано, не дыра; (б) T8 мог дать ложный MISSING на плейсхолдере `docs/plans/YYMMDD_HHMM_topic.md` — исключение `grep -v 'YYMMDD_HHMM'` калибровано прогоном; конструкция `docs/reviews/<PlanID>_review.md` обрежет захват до существующего каталога `docs/reviews/`, ложного MISSING не даст; (в) T1-лозунг в текущем README стоит одной строкой — grep ловит дословно; вариант с переносом внутри фразы покрывается осмотром D1/D2; (г) T10 «ровно три записи»: план 261111_0427 untracked — append'ы Coder'а (Tests-факты, Evidence, intake) не меняют его `??`-статус; review-артефакт возникает позже и вне Coder-фазы (прецедент — 0320); (д) T3 «ровно 3 строки»: дубли слэш-имён схлопываются `sort -u`, без-слэшные упоминания не запрещены (обязательна слэш-форма — D5/D9).
- Addendum (new angle): сверх чек-листа найден и исправлен 1 дефект своей зоны — T4-команда слабее собственного ожидания (`grep 'Status'` пропустил бы «Status» без маркера; D6 требует дословный `**Status:**`) — см. Fixes; пересчитана арифметика канонического списка: 3 команды + 5 агентов + 7 путей = 15 позиций, D9/T7 в точности соответствуют Solution п.3; сверено, что фикс T4 не разрушил карту покрытия (D6→T4) и порядок нумерации T<i> по DoD; прогнан прогон исправленного паттерна на синтетике: находит `` `**Status:**` ``, игнорирует «Status» без звёздочек.
- Fixes: T4 усилен — `grep -n 'Status'` → `grep -n '\*\*Status:\*\*' README.md` с уточнённым ожиданием (дословный маркер); правка в зоне Tests, до подтверждения handoff, статус не менялся.
- Final censor verdict: OK
- 2026-11-11 04:56:00 — Coder: прогнаны T1–T9 (факты под каждой командой
  в ## Tests / Commands): T1 — лозунг и `.tmp` отсутствуют (оба grep exit 1),
  шесть H2-блоков в порядке (6→13→32→38→53→61), 66 ≤ 100 строк, кириллица
  на 47 строках; T2 — 7/7 ролей, `AGENTS.md` во вводном блоке (11), обе пары
  гейтов дословно (28, 29) с именами «стартуем»/«мержим»; T3 — ровно 3
  слэш-команды (34–36, sort -u без лишних); T4 — дословный `**Status:**`
  (44), `to=Owner` (50), `## Q&A log` (48, 50); T5 — `docs/reviews` (55, 56),
  последний `**Round:**` (59), лейны risk → contracts; T6 — три ссылки
  «Куда дальше» (63–65); T7 — 15/15 канонического списка, MISSING нет; T8 —
  инвариант существования: все упомянутые пути в репо есть, файлы
  `.zcode/commands/planfaktor-{plan,run,status}.md` 3/3; T9 — хардкода имён
  планов нет (exit 1), пример — только паттерном `YYMMDD_HHMM_topic.md` (40).
  Все ожидания выполнены.
- 2026-11-11 04:58:52 — Coder: T10 (границы) и стейджинг: `git status
  --porcelain` до/после `git add README.md` — ровно три записи на ожидаемые
  файлы; staged-дифф — только README.md (+62/−6); closeout-правка
  `docs/plans/261111_0320_pipeline_timing.md` и план 0427 не стейджнуты;
  коммит не выполнялся (§8).
- 2026-11-11 05:00:08 — Coder: фаза завершена — README.md переписан строго
  по Scope (один файл), DoD D1–D13 закрыты фактами T1–T10, Changes
  заполнены, README.md стейджнут; handoff: статус In review, готов
  к CENSOR-проходу.
- 2026-11-11 05:04:53 — (Role CENSOR) OK: In review validated; current=true
Censor dispatch id: censor:coder:261111_050134
Observations:
- Second opinion: шапка перечитана с диска — `**Status:** In review` (строка 4), Plan ID `261111_0427` согласован с именем файла `261111_0427_owner_quickstart_readme.md`, PRE_STATUS_LINE конверта censor:coder:261111_050134 совпал; Evidence-строка 05:00:08 заявляет тот же handoff — файл и запись совпадают. DoD перечитан (D1–D13) и закрыт фактами Tests: D1/D2/D12 → T1 (оба grep exit 1; H2-блоки 6→13→32→38→53→61; 66 ≤ 100; кириллица 47), D3/D4 → T2 (`AGENTS.md` — 11; роли Owner-17 … Reviewer-contracts-23; гейты «стартуем»/«мержим» — 28–29 с парами `Ready for Coder` → `In progress`, `In review` → `Merged` дословно), D5 → T3 (34–36; `sort -u` — ровно 3), D6 → T4 (`**Status:**` — 44, `to=Owner` — 50, `## Q&A log` — 48/50), D7 → T5 (55–59), D8 → T6 (63–65), D9 → T7 (15/15), D10 → T8 (пути/команды существуют), D11 → T9 (exit 1), D13 → T10 (три записи porcelain). Повторные прогоны grep'ом подтверждают факты: заголовки 1/6/13/32/38/53/61, маркеры 44/50, сплав — одна строка (9), слэш-команды — ровно 3. Changes соответствуют фактическому README (перезапись 10 → 66 строк, шесть блоков, удаления лозунга/`.tmp`, 15/15). Стейджинг сверен: `git diff --cached --name-only` — только `README.md` (+62/−6), closeout-правка 0320 и план 0427 не стейджнуты, коммита нет. Чужие зоны не тронуты: DoD-чекбоксы остались `[ ]` (DoD — зона Planner; закрытие пунктов доказано фактами Tests/Evidence), Problem/Solution/Scope/Out of scope и чужие Evidence-записи — без правок; TODO/FIXME и отладочного мусора нет (grep exit 1).
- Counterfactuals considered: (а) номера строк в Tests-фактах могли разъехаться после до-handoff-правок фактов T2/T7 — ключевые grep'ы перегнаны заново, все номера совпали; (б) staged-дифф мог протухнуть или содержать лишнее — `git diff --cached --name-only` перечитан: единственный файл README.md; (в) лозунг/`.tmp`/TODO могли вернуться при правках — повторный grep пуст (exit 1), метафора встречается один раз (строка 9); (г) правки фактов T2/T7 до handoff могли нарушить append-only — Evidence не переписывался (только дописывался), факты Tests правились до стейджинга и handoff, прецедент — Fixes T4 у Planner CENSOR; (д) D3 «2–3 строки» при буквальном подсчёте физических переносов даёт 4 строки (8–11) — прочитано как смысловой объём: три содержательные строки (определение с метафорой / истина маршрутизации / конституция-ссылка) + явная ссылка `AGENTS.md`, что и требует D3; проверяемая форма T2 (ссылка во вводном блоке) проходит; правка текста после handoff не делалась — это не мелкий фикс; (е) «ровно 3 строки» T10 при стейджинге — porcelain показывает одну запись на файл (`M  README.md` staged), три записи на три ожидаемых файла, сверх — ничего.
- Addendum (new angle): сверх чек-листа — план перечитан с диска целиком после своих Edit (целостность секций, хронология Evidence: мои записи 04:56:00/04:58:52/05:00:08 идут после Planner CENSOR без переписывания чужих); дайджесты контрактов сверены shasum — не менялись с рабочей итерацией 04:53:38 (AGENTS.md@b5b5cdf8, coder.md@8336c2f1), работа шла по действующей конституции; заполнен `## Follow-ups` записью NO FOLLOW-UPS — обязанность Coder при CENSOR по комментарию секции, в прецеденте 0320 этот пропуск дошёл до closeout Manager'а; сверена согласованность Changes ↔ README ↔ Tests-факты по всем 15 позициям канонического списка.
- Fixes: в своей зоне при сверке — заполнение `## Follow-ups` (NO FOLLOW-UPS) и intake-строка этой итерации; дефектов handoff не найдено.
  - Final censor verdict: OK
- 2026-11-11 05:15:10 — Manager: Coder CENSOR OK подтверждён grep'ом (dispatch id censor:coder:261111_050134); ревью Round 1 валидно (Risk pass, Contracts pass, Итог pass — сверено чтением docs/reviews/261111_0427_review.md). Merge-гейт пройден по предаторизации Owner'ом (Q&A log, первая запись, status=closed). Переход In review → Merged; merge-коммит `docs(261111_0427): rewrite README as owner quickstart` делается сразу после этой записи (запись до события, без хеша — принятый trade-off, см. план 261111_0320 review Round 2 minor №2).
- 2026-11-11 05:16:20 — Manager: merge-коммит 3c93628 (`docs(261111_0427): rewrite README as owner quickstart`, 4 файла — README.md, план, review-артефакт, closeout-правки плана 261111_0320) выполнен; сверено git log. Closeout: ## Follow-ups уже заполнен Coder'ом при CENSOR (NO FOLLOW-UPS); переход Merged → Done. Запись Done каузально вне merge-коммита — принятый trade-off; уйдёт в следующий коммит очереди.
- 2026-11-17 20:59:00 — Coder: резолвинг merge-хеша после пересборки публичной истории 2026-11-13: 3c93628 → 51447d4 (docs(261111_0427): rewrite README as owner quickstart); цитата 782971a в fail loud-записи — то же соответствие, что в плане 261111_0320 (782971a → 7a668f0, feat(261111_0320): add HH:MM:SS timing marks and phase durations); исторические строки не правятся — append-only (волна 261117_2002, D2).

## Q&A log (chronological, append-only)
<!-- owner: все роли; intake: `Intake (YYYY-MM-DD HH:MM:SS): AGENTS.md@<8hex> <role>.md@<8hex>` (локальное время) + NO QUESTIONS / NO SUGGESTIONS / NO OBJECTIONS; вопросы `Q(<роль>): ... to=Owner, blocker: yes|no, needs_owner: yes|no, status=open`; закрытие `A(<кто>): ... status=closed, перенесено в <секция>` -->

- A(owner): Гейты «стартуем» и «мержим» предаторизованы Owner'ом 2026-11-11 (передано через кураторскую сессию), status=closed
- 2026-11-11 — Intake (architect): AGENTS.md@b5b5cdf8 architect.md@73ace930
- 2026-11-11 — architect: NO QUESTIONS
- 2026-11-11 — architect: NO SUGGESTIONS
- 2026-11-11 — architect: NO OBJECTIONS
- Intake (2026-11-11 04:35:24): AGENTS.md@b5b5cdf8 architect.md@73ace930
  (корректирующая запись той же итерации: contract-строка выше записана без
  HH:MM:SS по устаревшему комментарию секции из старой копии шаблона —
  fail loud Manager 04:33:10; лог append-only, старая строка не
  переписывается, актуальна эта)
- architect: NO QUESTIONS
- architect: NO SUGGESTIONS
- architect: NO OBJECTIONS
- Intake (2026-11-11 04:37:05): AGENTS.md@b5b5cdf8 architect.md@73ace930
  (итерация CENSOR-прохода, dispatch censor:architect:261111_043613)
- architect: NO QUESTIONS
- architect: NO SUGGESTIONS
- architect: NO OBJECTIONS
- Intake (2026-11-11 04:43:16): AGENTS.md@b5b5cdf8 planner.md@97f968d8
  (PRE_STATUS_LINE=Ready for Planner сверен с шапкой, строка 4 — совпал)
- planner: NO QUESTIONS (решения Architect полны для детализации:
  структура README из шести блоков, канонический список упоминаемого
  из 15 позиций, запреты на перенос старого — Solution п.1–6; состав
  репо сверён с каноническим списком фактом: 3 команды в
  .zcode/commands/, 5 агентов в .zcode/agents/, все доки существуют;
  текущий README.md — 631 байт/10 строк, соответствует «Как я понял
  задачу»; посторонняя правка docs/plans/261111_0320_pipeline_timing.md
  в рабочем дереве — closeout Manager'а (Merged → Done + Follow-ups),
  с Zone этого плана не пересекается)
- planner: NO SUGGESTIONS
- planner: NO OBJECTIONS
- Intake (2026-11-11 04:48:54): AGENTS.md@b5b5cdf8 planner.md@97f968d8
  (итерация CENSOR-прохода, dispatch censor:planner:261111_044825;
  PRE_STATUS_LINE=Ready for Coder сверен с шапкой, строка 4 — совпал;
  дайджесты совпали с рабочей итерацией 04:43:16)
- planner: NO QUESTIONS (сверка handoff с файлом, не с памятью)
- planner: NO SUGGESTIONS
- planner: NO OBJECTIONS
- Intake (2026-11-11 04:53:38): AGENTS.md@b5b5cdf8 coder.md@8336c2f1
  (PRE_STATUS_LINE=In progress сверен с шапкой, строка 4 — совпал;
  Owner-гейт «стартуем» пройден — Evidence 04:52:30)
- coder: NO QUESTIONS
- coder: NO SUGGESTIONS
- coder: NO OBJECTIONS
- Intake (2026-11-11 05:04:53): AGENTS.md@b5b5cdf8 coder.md@8336c2f1
  (итерация CENSOR-прохода, dispatch censor:coder:261111_050134;
  PRE_STATUS_LINE=In review сверен с шапкой, строка 4 — совпал; дайджесты
  совпали с рабочей итерацией 04:53:38; план перечитан с диска целиком)
- coder: NO QUESTIONS (сверка handoff с файлом, не с памятью)
- coder: NO SUGGESTIONS
- coder: NO OBJECTIONS
- Intake (2026-11-11 05:06:51): AGENTS.md@b5b5cdf8 reviewer-risk.md@39591bfe
  (PRE_STATUS_LINE=In review сверен с шапкой, строка 4 — совпал;
  staged-дифф = только README.md +62/−6, unstaged-правка 0320 — closeout
  Manager'а, вне зоны ревью)
- reviewer-risk: NO QUESTIONS
- reviewer-risk: NO SUGGESTIONS
- reviewer-risk: NO OBJECTIONS
- Intake (2026-11-11 05:11:36): AGENTS.md@b5b5cdf8 reviewer-contracts.md@18e2bfb0
  (PRE_STATUS_LINE=In review сверен с шапкой, строка 4 — совпал;
  staged-дифф = только README.md +62/−6; Risk-вердикт в
  docs/reviews/261111_0427_review.md записан — лан contracts второй)
- reviewer-contracts: NO QUESTIONS
- reviewer-contracts: NO SUGGESTIONS
- reviewer-contracts: NO OBJECTIONS

## Suggestions log (chronological, append-only)
<!-- owner: все роли; несрочные улучшения -->

## Objections log (chronological, append-only)
<!-- owner: все роли; `### <Role> objections`; строка на возражение, blocker: при блокере -->

## Follow-ups (deferred)
<!-- owner: coder/planner при CENSOR; незакрытые хвосты: <описание> — why: <почему сейчас не в скоупе>; обязательна запись `NO FOLLOW-UPS — why: <код_причины>` при отсутствии -->

- NO FOLLOW-UPS — why: план одно-файловый (Scope — только README.md),
  DoD D1–D13 закрыты фактами T1–T10, дефектов и незакрытых хвостов
  при CENSOR-сверке не найдено; зафиксировано Coder'ом при CENSOR
  (в отличие от прецедента 0320, где Follow-ups дошёл до closeout
  Manager'а).
