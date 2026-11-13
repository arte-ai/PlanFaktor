# Замер времени прохождения задач через конвейер

**Plan ID:** 261111_0320
**Status:** Done
**Created:** 2026-11-11
**Owner gates:** старт кодинга (`Ready for Coder`), merge (`In review` → `Merged`)

> Шапка — parser-контракт: строки выше grep'аются Manager'ом. Не менять формат.
> Имя файла: `YYMMDD_HHMM_topic.md` (тема латиницей, слова через `_`).

## Как я понял задачу
<!-- owner: architect; 3–7 строк; обязательна при Architect intake -->

Owner хочет видеть, сколько времени задачи проводят в каждой фазе конвейера.
Сейчас событийные записи несут максимум дату (CENSOR-receipt — вовсе без
времени): фазы за один день неотличимы, review-фаза без конца. Решение —
единая метка `YYYY-MM-DD HH:MM:SS` (локальное время) во всех записях:
Evidence (включая CENSOR-receipt) и intake-строки; Evidence-узлы Manager'а
(гейты, merge) как концы фаз; таблица длительностей в read-only
`/planfaktor-status`; правки конституции минимальны + запись в decisions.md.

## Problem
<!-- owner: architect; пронумерованные пункты -->

1. Событийные записи плана несут только дату (Evidence, intake-строки,
   строки завершения фаз в роль-доках), CENSOR-receipt — вообще без метки
   времени: при нескольких фазах за день восстановить длительность фазы
   невозможно.
2. Формат метки не формализован: Manager уже пишет минуты по привычке
   (`2026-11-11 03:21` — первая запись Evidence этого плана), роли — только
   дату; разбор и сверка недетерминированы.
3. Начала фаз не фиксируются: intake-строка роли — единственный формальный
   маркер старта итерации (конституция §3), но времени не несёт.
4. Концы фаз неполны: review-фаза (`In review`) заканчивается merge-гейтом,
   однако Manager не формализованно фиксирует в Evidence гейт-переходы
   и merge — у фазы нет конца.
5. `/planfaktor-status` не выводит временных характеристик: Owner не видит,
   сколько план стоит в текущей фазе и где конвейер простаивает.

## Solution / Decisions
<!-- owner: architect; решения уровня «что и почему», без детализации -->

1. **Единая метка времени.** Все событийные записи несут локальное время
   машины в формате `YYYY-MM-DD HH:MM:SS`: Evidence-записи — префиксом
   `- YYYY-MM-DD HH:MM:SS — <кто>: <текст>` (включая CENSOR-receipt и строки
   завершения фаз), intake-строки — `Intake (YYYY-MM-DD HH:MM:SS): ...`.
   Греп-маркеры Manager'а (`(Role CENSOR)`, `Censor dispatch id:`,
   `^\*\*Status:\*\*`, `to=Owner`) не меняются — правки обратно совместимы.
2. **Модель фазы: intake → завершение.** Начало фазы = intake-строка
   ведущей роли в Q&A log; конец = строка завершения фазы роли в Evidence
   либо Evidence-узел Manager'а (гейт/merge). Длительность = конец − начало.
   Зазоры между фазами (CENSOR, Owner-гейты, ожидание диспатча) в
   длительность фазы не входят и видны как разрывы меток. Повторные итерации
   (needs-fix-циклы) дают несколько пар меток: статус-рутина показывает
   последнюю итерацию, полная история остаётся в Evidence.
   Альтернатива «конец фазы N = начало фазы N+1» отклонена: смешивает время
   работы роли с ожиданием гейта.
3. **Evidence-узлы Manager'а.** Manager формализованно фиксирует в Evidence
   с меткой времени: создание плана, гейт-переходы (`In progress`,
   `Merged`), merge-коммит, closeout (`Done`) — закрывает концы всех фаз,
   включая review (формализация существующей практики: Manager уже записал
   создание этого плана, 03:21; сам `/planfaktor-plan` шага не предписывает —
   добавляется в Scope).
4. **`/planfaktor-status` остаётся read-only** и получает шаг: таблица фаз
   активного плана `Фаза | Начало | Конец | Длительность` из меток Evidence
   и Q&A log; для текущей незавершённой фазы — elapsed от её intake;
   отсутствующие метки (планы, созданные до этого решения) — прочерк.
   Без скриптов: чтение/grep.
5. **Ретроактивная конверсия запрещена** (append-only, §5): существующие
   записи не перезаписываются, их фазы показываются прочерком.
6. **Журнал решений.** Правка конституции сопровождается append-only
   записью в `docs/decisions.md` по формату журнала (§9).
7. **Соблюдение с этой итерации.** Новый формат применяется самим этим
   планом с момента принятия решения: intake-строка и строка завершения
   фазы Architect уже несут HH:MM:SS — план демонстрирует свою механику.

Отклонённые альтернативы (к п.1–2): отдельная секция `## Timing` в плане —
второй источник истины рядом с Evidence; метки в шапке плана — шапка
parser-контракт «один факт на строку», история переходов теряется; UTC —
одна рабочая машина Owner, локальное время читаемее человеку.

## Scope
<!-- owner: architect (границы), planner (уточняет); список изменений -->

- `AGENTS.md` — минимальные правки: §3 (intake-строка с датой и временем),
  §4 (метка времени у Evidence-записи CENSOR-receipt), единый формат метки
  Evidence-записей и Evidence-узлы Manager'а (одно предложение в §2/§5).
- `docs/plans/_template.md` — комментарии секций Evidence и Q&A log
  под новый формат меток.
- `docs/roles/architect.md`, `docs/roles/planner.md`, `docs/roles/coder.md` —
  «строка о завершении фазы с датой» → с датой и временем (локальное,
  HH:MM:SS); у Coder — также формулировка зоны Evidence. Intake-формат
  ревьюеров наследуется из §3 конституции, их доки не меняются.
- `.zcode/commands/planfaktor-status.md` — шаг вывода длительностей фаз
  активного плана из Evidence/Q&A-меток (только чтение).
- `.zcode/commands/planfaktor-run.md` — Evidence-записи Manager'а с меткой
  времени при гейт-переходах и merge (шаги 2 и 4).
- `.zcode/commands/planfaktor-plan.md` — Evidence-запись о создании плана
  с меткой времени (шаг 3).
- `docs/decisions.md` — append-only запись решения по формату журнала.
- `docs/plans/261111_0320_pipeline_timing.md` — собственные новые записи
  этого плана ведутся в новом формате (ретро-конверсии нет).

## Out of scope
<!-- owner: architect -->

- Ретроактивная конверсия существующих Evidence/Q&A-записей и логов старых
  планов (append-only, §5).
- Шапка плана: `**Created:**` остаётся `YYYY-MM-DD` — parser-контракт
  не расширяется.
- Скрипты, парсеры и рантайм-расчёт длительностей — только человек/grep.
- Агрегация метрик по всем планам (узкие места конвейера, история) —
  Suggestions log S1.
- Временные метки в review-артефактах `docs/reviews/*.md`.
- Часовые пояса и UTC-конверсия — фиксируется локальное время машины.
- `docs/lifecycle.md` — производный справочник, форматов записей
  не содержит, не трогаем.

## Acceptance criteria / DoD
<!-- owner: planner; чек-лист проверяемых исходов; каждый пункт = проверяемое утверждение -->

- [ ] AGENTS.md §3: intake-строка предписывает дату и время — формат
  `Intake (YYYY-MM-DD HH:MM:SS): AGENTS.md@<8hex> <role>.md@<8hex>`;
  подстрока-маркер `Intake (` сохранена.
- [ ] AGENTS.md §4: формат CENSOR-receipt дополнен меткой времени
  Evidence-записи (префикс `- YYYY-MM-DD HH:MM:SS — (Role CENSOR) OK: ...`);
  греп-маркеры `(Role CENSOR)` и `Censor dispatch id:` не изменены.
- [ ] AGENTS.md (одно предложение в §2 или §5): единый формат метки
  Evidence-записей `- YYYY-MM-DD HH:MM:SS — <кто>: <текст>` и Evidence-узлы
  Manager'а (создание плана, гейт-переходы `In progress` / `Merged`,
  merge-коммит, closeout `Done`).
- [ ] docs/plans/_template.md: комментарии секций Evidence и Q&A log
  описывают метку `YYYY-MM-DD HH:MM:SS` (событийные записи и intake).
- [ ] docs/roles/architect.md, docs/roles/planner.md, docs/roles/coder.md:
  указание о строке завершения фазы в `## Evidence` — «с датой и временем»;
  в docs/roles/coder.md формулировка зоны `## Evidence` и Evidence-запись
  прогона (шаг фазы 3) — также с датой и временем.
- [ ] .zcode/commands/planfaktor-status.md: новый шаг — таблица
  `Фаза | Начало | Конец | Длительность` активного плана из меток Evidence
  и Q&A log (начало = intake ведущей роли, конец = строка завершения фазы
  либо Evidence-узел Manager'а); для текущей незавершённой фазы — elapsed
  от её intake; отсутствующие метки — прочерк; команда остаётся read-only.
- [ ] .zcode/commands/planfaktor-run.md: шаг 2 предписывает Evidence-запись
  с меткой времени при гейт-переходе `In progress` и при closeout `Done`;
  шаг 4 — при merge-коммите и переходе `Merged`.
- [ ] .zcode/commands/planfaktor-plan.md: шаг 3 предписывает Evidence-запись
  о создании плана с меткой времени `YYYY-MM-DD HH:MM:SS` в `## Evidence`
  нового плана.
- [ ] docs/decisions.md: append-only запись по формату журнала (дата —
  решение — почему — альтернатива) о введении метки `YYYY-MM-DD HH:MM:SS`
  в событийных записях; прежние записи не изменены.
- [ ] docs/plans/261111_0320_pipeline_timing.md: собственные записи этого
  плана с момента решения Architect (Solution/Decisions п.7) ведутся
  с HH:MM:SS (intake-строки, Evidence, CENSOR-receipt); существующие записи
  (включая `- 2026-11-11 03:21 — Manager:` без секунд) не переписаны —
  ретро-конверсии нет.
- [ ] Обратная совместимость: греп-маркеры Manager'а (`(Role CENSOR)`,
  `Censor dispatch id:`, `^\*\*Status:\*\*`, `to=Owner`) находят вхождения
  в AGENTS.md и в живом плане; формулировки маркеров не изменены.
- [ ] Границы: `git status --porcelain` показывает только файлы из
  `## Scope` (+ сам план `docs/plans/261111_0320_pipeline_timing.md`);
  изменений вне Scope нет.

## Tests / Commands
<!-- owner: planner (задаёт), coder (заполняет факт); что прогнать и что должно получиться -->

Команды прогоняются из корня репо. Ожидаемый результат — обязательный
критерий прохождения; Coder вписывает факт прогона под каждой командой
и дублирует в `## Evidence`. Нумерация T<i> ссылается на пункты DoD
в порядке их следования.

T1 (DoD: AGENTS.md §3 — intake с датой и временем; AGENTS.md §4 — метка
receipt; AGENTS.md §2/§5 — единый формат)

```sh
grep -n 'YYYY-MM-DD HH:MM:SS' AGENTS.md
```

Ожидание: ≥3 строки — intake-формат (§3), метка Evidence-записи
CENSOR-receipt (§4), предложение о едином формате метки и Evidence-узлах
Manager'а (§2 или §5).

Факт (2026-11-11 03:50:14): grep — 3 строки: 62 (§3, `Intake
(YYYY-MM-DD HH:MM:SS):`), 102 (§4, `- YYYY-MM-DD HH:MM:SS —
(Role CENSOR) OK:`), 150 (§5, `- YYYY-MM-DD HH:MM:SS — <кто>: <текст>`).
Ожидание ≥3 выполнено.

T2 (DoD: обратная совместимость маркеров)

```sh
grep -n '(Role CENSOR)\|Censor dispatch id:' AGENTS.md
grep -n 'to=Owner' AGENTS.md
```

Ожидание: все маркеры присутствуют; формулировки не изменены
(«(Role CENSOR) OK:», «Censor dispatch id: censor:<role>:<YYMMDD_HHMMSS>»,
«to=Owner»).

Факт (2026-11-11 03:50:14): `(Role CENSOR)` — строки 102 (в шаблоне
receipt, с префиксом метки) и 113 (гейт-проверка Manager'а);
`Censor dispatch id: censor:<role>:<YYMMDD_HHMMSS>` — строка 103 дословно;
`to=Owner` — 2 вхождения (строки 68, 160 — формат Q&A и стоп-матрица).
Формулировки маркеров не изменены.

T3 (DoD: intake-формат в конституции и шаблоне)

```sh
grep -n 'Intake (' AGENTS.md docs/plans/_template.md
```

Ожидание: AGENTS.md — intake-формат с датой и временем; _template.md —
комментарий Q&A log с меткой `YYYY-MM-DD HH:MM:SS`; подстрока `Intake (`
сохранена в обоих.

Факт (2026-11-11 03:50:14): AGENTS.md:62 — `Intake (YYYY-MM-DD HH:MM:SS):`;
_template.md:41 — `Intake (YYYY-MM-DD HH:MM:SS):`. Подстрока `Intake (`
сохранена в обоих.

T4 (DoD: роль-доки)

```sh
grep -n 'с датой и временем' docs/roles/architect.md docs/roles/planner.md docs/roles/coder.md
```

Ожидание: во всех трёх — указание о строке завершения фазы «с датой
и временем»; в docs/roles/coder.md ≥2 вхождения (зона `## Evidence`
и Evidence-запись прогона в шаге фазы 3).

Факт (2026-11-11 03:50:14): architect.md:35 и planner.md:43 — по 1
вхождению («строку о завершении фазы с датой и временем»); coder.md —
3 вхождения: 14 (зона `## Evidence`), 42 (Evidence-запись прогона,
шаг фазы 3), 46 (строка завершения фазы, шаг фазы 5). ≥2 у Coder
выполнено.

T5 (DoD: шаблон плана)

```sh
grep -n 'HH:MM:SS' docs/plans/_template.md
```

Ожидание: ≥2 строки — комментарии секций Evidence и Q&A log.

Факт (2026-11-11 03:50:14): 2 строки — 38 (комментарий Evidence,
`- YYYY-MM-DD HH:MM:SS — <кто>: <текст>`) и 41 (комментарий Q&A log,
`Intake (YYYY-MM-DD HH:MM:SS)`).

T6 (DoD: planfaktor-status — таблица длительностей)

```sh
grep -n 'Длительность\|elapsed\|прочерк' .zcode/commands/planfaktor-status.md
```

Ожидание: шаг с таблицей `Фаза | Начало | Конец | Длительность`, elapsed
для текущей незавершённой фазы, прочерк при отсутствии меток. Осмотр:
новый шаг только читает файлы (команда остаётся read-only, «Никаких
изменений файлов» сохранено).

Факт (2026-11-11 03:50:14): строки 25 (`Фаза | Начало | Конец |
Длительность`), 29 (elapsed от intake), 30 (прочерк). Осмотр: новый
шаг 5 только читает метки Evidence/Q&A log; бывший шаг 5 стал шагом 6 —
«Никаких изменений файлов — только чтение и доклад Owner» сохранён;
команда read-only.

Факт (Round 1 fixes, 2026-11-11 04:09:25): после фикса major №1
(детерминизм выбора меток) — строки 25/39/41 (таблица, elapsed,
прочерк); правила выбора: 29–31 (начало = intake рабочей итерации,
первая intake фазы; CENSOR-intake началом не считается; при
needs-fix-повторах — последняя рабочая итерация), 32–34 (конец =
строка завершения фазы роли; Evidence-узлы Manager'а конец фазы роли
не закрывают), 35–38 (review: от строки завершения Coder'а до
merge-узла; `Merged`: от узла перехода `Merged` до closeout-узла
`Done`). Шаг 6 «Никаких изменений файлов» сохранён; команда
read-only.

T7 (DoD: planfaktor-run — Evidence-узлы Manager'а)

```sh
grep -n 'Evidence' .zcode/commands/planfaktor-run.md
```

Ожидание: предписания Evidence-записи с меткой времени в шаге 2
(гейт-переход `In progress`, closeout `Done`) и в шаге 4 (merge-коммит,
переход `Merged`).

Факт (2026-11-11 03:50:14): строка 25 — шаг 2, `In progress` после
Owner-«да»; строка 28 — шаг 2, closeout `Done`; строка 83 — шаг 4,
merge-коммит и гейт-переход `Merged`; все с меткой
`YYYY-MM-DD HH:MM:SS`. (Строка 54 — упоминание `## Evidence`
в CENSOR-конверте §3, вне правок этого плана.)

Факт (Round 1 fixes, 2026-11-11 04:09:25): после фикса minor №2 —
шаг 2 (строки 25/28) без изменений; шаг 4 (строки 81–86):
Evidence-записи (merge-коммит, гейт-переход `Merged`) и статус
`Merged` предписаны ДО `git add -A && git commit` — входят в
merge-коммит, рабочее дерево после коммита чистое.

T8 (DoD: planfaktor-plan — запись о создании плана)

```sh
grep -n 'Evidence' .zcode/commands/planfaktor-plan.md
```

Ожидание: шаг 3 предписывает Evidence-запись о создании плана с меткой
времени `YYYY-MM-DD HH:MM:SS`.

Факт (2026-11-11 03:50:14): строка 11 — шаг 3 предписывает запись
о создании в `## Evidence` нового плана с меткой
`- YYYY-MM-DD HH:MM:SS — Manager: план создан из шаблона по
/planfaktor-plan`; остальные секции не заполняются.

T9 (DoD: decisions.md)

```sh
grep -n 'HH:MM:SS' docs/decisions.md
tail -n 8 docs/decisions.md
```

Ожидание: grep находит новую запись о метке времени; tail показывает
её целиком в формате «дата — решение — почему — альтернатива» в конце
журнала; `git diff docs/decisions.md` — только добавление строк в конец,
прежние записи не тронуты.

Факт (2026-11-11 03:50:14): grep — строка 27 (`- 2026-11-11 — Единая
метка времени \`YYYY-MM-DD HH:MM:SS\`...`); tail -n 8 показывает запись
целиком (8 строк, первая — заголовок записи); git diff — только
плюс-строки, минус-строк нет (grep по `^-` пуст, exit 1).

T10 (DoD: ретро-конверсия запрещена — append-only собственного плана;
план — новый файл, в HEAD отсутствует, поэтому git diff по рабочему
дереву пуст; проверка через стейджинг + дословные якоря)

```sh
git diff --cached docs/plans/261111_0320_pipeline_timing.md | grep '^-' | grep -v '^---'
grep -n '03:21 — Manager: план создан\|03:27:41 — Architect: intake сверен\|03:31:44 — (Role CENSOR)\|03:34:10 — Manager: Architect CENSOR OK\|03:37:57 — Planner: intake сверен' docs/plans/261111_0320_pipeline_timing.md
```

Ожидание: первая команда (после `git add`) — пусто: файл идёт в стейдж
целиком как новый, минус-строк нет; вторая — ровно 5 строк (304–315):
все Evidence-записи, предшествующие фазе Coder'а, присутствуют дословно,
включая `- 2026-11-11 03:21 — Manager:` без секунд — не переписана
(ретро-конверсии нет); осмотр: intake-строки Q&A log не изменены.

Факт (2026-11-11 03:51:47): первая команда — пусто (exit 1, минус-строк
в `git diff --cached` нет, файл стейджится целиком как новый); вторая —
6 строк: 5 дословных якорей Evidence (строки 406, 407, 408, 416, 417 —
все записи, предшествующие фазе Coder'а, включая `- 2026-11-11 03:21 —
Manager:` без секунд, не переписана) + 1 сам-матч — строка 317, сам
grep-паттерн T10 в Tests/Commands совпадает с собственным текстом
(не Evidence-запись). Существо ожидания выполнено: 5 якорей дословно,
ретро-конверсии нет; осмотр: intake-строки Q&A log не изменены
(проверено чтением, правок Coder'а в них — только append intake
03:46:12 в конец).

T11 (DoD: собственный план — записи в новом формате)

```sh
grep -nE '^- [0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2} — ' docs/plans/261111_0320_pipeline_timing.md
grep -nE 'Intake \(2026-11-11 [0-9]{2}:[0-9]{2}:[0-9]{2}\)' docs/plans/261111_0320_pipeline_timing.md
```

Ожидание: все Evidence-записи и intake-строки, сделанные после решения
Architect (включая intake/handoff/CENSOR-receipt Planner'а и Coder'а),
несут HH:MM:SS; запись `- 2026-11-11 03:21 — Manager:` осталась в исходном
виде (без секунд) и не переписана.

Факт (2026-11-11 03:50:14): Evidence-записей с HH:MM:SS — 6 (03:27:41,
03:31:44, 03:34:10, 03:37:57, 03:41:13, 03:42:45; записи самой фазы
Coder'а добавляются ниже, тоже с HH:MM:SS); intake-строк с HH:MM:SS — 5
(03:26:59, 03:30:27, 03:36:55, 03:38:57, 03:46:12 Coder); запись
`- 2026-11-11 03:21 — Manager:` (строка 311) — в исходном виде,
без секунд.

T12 (DoD: границы изменений)

```sh
git status --porcelain
```

Ожидание: изменены только файлы из `## Scope`: AGENTS.md,
docs/plans/_template.md, docs/roles/architect.md, docs/roles/planner.md,
docs/roles/coder.md, .zcode/commands/planfaktor-status.md,
.zcode/commands/planfaktor-run.md, .zcode/commands/planfaktor-plan.md,
docs/decisions.md, docs/plans/261111_0320_pipeline_timing.md — и ничего
сверх. После прогона всех тестов Coder стейджит их (`git add`), не
коммитит (конституция §8).

Факт (2026-11-11 03:51:47): ровно 10 строк — `M` для AGENTS.md,
docs/plans/_template.md, docs/roles/{architect,planner,coder}.md,
.zcode/commands/{planfaktor-status,planfaktor-run,planfaktor-plan}.md,
docs/decisions.md; `A` для docs/plans/261111_0320_pipeline_timing.md
(новый файл). Ничего сверх Scope; всё стейджнуто (`git add`), коммита
нет.

Факт (Round 1 fixes, 2026-11-11 04:10:29): после повторного стейджинга —
те же 10 файлов Scope (9 `M` + `A` план), unstaged-диф пуст; единственный
не-Скоповский след — untracked `docs/reviews/261111_0320_review.md`
(review-артефакт ревью-фазы, зона ревьюеров/Manager'а — Coder'ом
не стейджнится и не правится). Коммита нет.

## Changes (by area)
<!-- owner: coder; фактические изменения по областям; заполняется в ходе работы -->

- AGENTS.md: §3 п.3 — intake-строка несёт дату и время:
  `Intake (YYYY-MM-DD HH:MM:SS): ...` (локальное время машины), маркер
  `Intake (` сохранён; §4 — первая строка шаблона CENSOR-receipt
  с префиксом метки: `- YYYY-MM-DD HH:MM:SS — (Role CENSOR) OK: ...`
  (остальные строки шаблона и греп-маркеры без изменений); §5 — новый
  пункт «Единая метка времени Evidence»: формат
  `- YYYY-MM-DD HH:MM:SS — <кто>: <текст>` и Evidence-узлы Manager'а
  (создание плана, гейт-переходы `In progress`/`Merged`, merge-коммит,
  closeout `Done`).
- docs/plans/_template.md: комментарий секции Evidence — событийные
  записи с меткой `- YYYY-MM-DD HH:MM:SS — <кто>: <текст>`; комментарий
  Q&A log — intake `Intake (YYYY-MM-DD HH:MM:SS)`.
- docs/roles/architect.md, docs/roles/planner.md: строка завершения
  фазы в Evidence — «с датой и временем (локальное, `HH:MM:SS`)»
  (шаг фазы 3 в обоих доках).
- docs/roles/coder.md: то же в шаге фазы 5 + зона `## Evidence`
  («записи с датой и временем») + Evidence-запись прогона в шаге фазы 3
  («с датой и временем»); итого 3 вхождения.
- .zcode/commands/planfaktor-status.md: новый шаг 5 — таблица
  `Фаза | Начало | Конец | Длительность` активного плана из меток
  Evidence/Q&A (начало = intake ведущей роли, конец = строка завершения
  фазы либо Evidence-узел Manager'а), elapsed для текущей незавершённой
  фазы, прочерк при отсутствии меток; бывший шаг 5 («Никаких изменений
  файлов») стал шагом 6 — команда остаётся read-only.
- .zcode/commands/planfaktor-run.md: шаг 2 (routing-таблица) — строки
  `Ready for Coder` и `Merged` предписывают Evidence-запись с меткой
  времени при гейт-переходе `In progress` и closeout `Done`; шаг 4 —
  после merge-коммита предписаны Evidence-записи с меткой времени о
  merge-коммите и гейт-переходе `Merged`.
- .zcode/commands/planfaktor-plan.md: шаг 3 — в `## Evidence` нового плана
  фиксируется запись о создании с меткой времени
  (`- YYYY-MM-DD HH:MM:SS — Manager: план создан из шаблона по
  /planfaktor-plan`); остальные секции не заполняются.
- docs/decisions.md: append-only запись от 2026-11-11 о единой метке
  `YYYY-MM-DD HH:MM:SS` (8 строк, формат «дата — решение — почему —
  альтернатива»); прежние записи не тронуты.
- docs/plans/261111_0320_pipeline_timing.md: intake Coder'а и
  Evidence-записи итерации — в новом формате HH:MM:SS; факты прогонов
  T1–T12 внесены в Tests/Commands; существующие записи не переписаны
  (03:21 — без секунд, как было).
- Fixes Round 1 (needs-fix по docs/reviews/261111_0320_review.md,
  2026-11-11 04:06–04:10): .zcode/commands/planfaktor-status.md — шаг 5
  дополнен детерминированным выбором меток (major №1): начало фазы
  роли = intake её рабочей итерации (первая intake фазы; CENSOR-intake
  началом не считается; при needs-fix-повторах — последняя рабочая
  итерация), конец = строка завершения фазы этой роли (Evidence-узлы
  Manager'а конец фазы роли не закрывают); фазы без ведущей роли:
  review — от строки завершения Coder'а до merge-узла, `Merged` —
  от узла перехода `Merged` до closeout-узла `Done`; elapsed/прочерк/
  read-only без изменений. .zcode/commands/planfaktor-run.md — шаг 4:
  порядок merge-шага обращён (minor №2): Evidence-записи (merge-коммит,
  переход `Merged`) и статус `Merged` ставятся до
  `git add -A && git commit` и входят в merge-коммит.

## Evidence (chronological, append-only)
<!-- owner: все роли + CENSOR; записи с датой; CENSOR-receipt по формату конституции -->

- 2026-11-11 03:21 — Manager: план создан из шаблона по `/planfaktor-plan`. Owner-бриф (передан ночной кураторской сессией, дословно по сути): «Замер времени прохождения задач через конвейер». Суть для Architect: добавить временные метки (локальное время HH:MM:SS, вместе с датой) в Evidence-записи ролей и строки завершения фаз (сейчас только даты), чтобы каждая фаза имела начало/конец; вывести в `/planfaktor-status`-рутину длительности фаз активного плана из Evidence-меток. Правки конституции минимальные, с append-only записью в `docs/decisions.md` (формат там). DoD — проверяемый.
- 2026-11-11 03:27:41 — Architect: intake сверен (PRE_STATUS_LINE=Draft совпадает с шапкой; AGENTS.md@34e1cecc, architect.md@0a898e56), фаза завершена — «Как я понял задачу», Problem, Solution/Decisions, Scope, Out of scope заполнены; открытых вопросов к Owner нет (S1 — в Suggestions log); статус Ready for Planner.
- 2026-11-11 03:31:44 — (Role CENSOR) OK: Ready for Planner validated; current=true
  Censor dispatch id: censor:architect:261111_032950
  Observations:
  - Second opinion: шапка перечитана — `**Status:** Ready for Planner` (строка 4), Plan ID 261111_0320 согласован с именем файла 261111_0320_pipeline_timing.md, PRE_STATUS_LINE конверта совпал; свои секции заполнены (Problem 1–5, Solution/Decisions 1–7 + отклонённые альтернативы, Scope 8 позиций, Out of scope 7); intake-ответы и S1 на месте, открытых `to=Owner`-вопросов в Q&A log нет; A(owner) о гейтах закрыт и отражён строкой Owner gates шапки; чужие секции (DoD/Tests/Changes/Follow-ups) — в состоянии шаблона, записи Manager'а не переписаны (append-only); контракты по shasum — AGENTS.md@34e1cecc, architect.md@0a898e56, совпадают с рабочей итерацией.
  - Counterfactuals considered: «дефектов не нашёл» было бы ложным — найдены и исправлены 2 дефекта своей зоны (см. Fixes); проверялось также, что новый intake-формат не ломает grep Manager'а по `Intake (` (подстрока сохранена), что отказ от времени в `**Created:**` не мешает метрикам (начало Draft-фазы = intake 03:26:59 + Evidence-запись Manager'а 03:21), и что ссылки Scope «шаги 2 и 4» для planfaktor-run верны (гейт-переход — шаг 2 routing-таблицы, merge — шаг 4).
  - Addendum (new angle): сверх чек-листа прогрепаны README.md и .zcode/commands на упоминания форматов записей (`Intake|Evidence|дата|время|с датой|завершении фазы`) — пусто, файлов вне Scope не пропущено; сверено фактическое соблюдение D7: intake-строка (03:26:59) и строка завершения фазы (03:27:41) несут HH:MM:SS.
  - Fixes: «Как я понял задачу» сжата с 8 до 7 строк (лимит §3 «3–7 строк»); в D3 неточная ссылка «см. planfaktor-plan» заменена на точную формулировку (практика — Evidence-запись Manager'а 03:21; сам шаг команды не предписывает, добавляется в Scope). Оба фикса — в своей зоне, статус не менялся.
  - Final censor verdict: OK
- 2026-11-11 03:34:10 — Manager: Architect CENSOR OK подтверждён grep'ом (маркер, dispatch id censor:architect:261111_032950, вердикт OK, непустые Observations); переход Draft → Ready for Planner валиден; диспатч Planner.
- 2026-11-11 03:37:57 — Planner: intake сверен (PRE_STATUS_LINE=Ready for Planner совпадал с шапкой; AGENTS.md@34e1cecc, planner.md@ce412609), статус Planning; фаза завершена — DoD заполнен 12 проверяемыми критериями по всем 8 позициям Scope (+сквозные: обратная совместимость маркеров, границы), Tests/Commands заданы (T1–T12: команда + ожидаемый результат, покрывают каждый пункт DoD); перенос Q&A: A(owner) о предаторизации гейтов уже отражён в шапке Owner gates, открытых вопросов в Q&A log нет, S1 остаётся в Suggestions log (вне скоупа по Out of scope); ссылки Scope сверены с файлами (planfaktor-run шаги 2/4, planfaktor-plan шаг 3); статус Ready for Coder.
- 2026-11-11 03:41:13 — (Role CENSOR) OK: Ready for Coder validated; current=true
  Censor dispatch id: censor:planner:261111_034026
  Observations:
  - Second opinion: шапка перечитана — `**Status:** Ready for Coder` (строка 4), Plan ID 261111_0320 согласован с именем файла, PRE_STATUS_LINE конверта censor:planner:261111_034026 совпал; DoD перечитан (12 пунктов, строки 122–162) — каждый пункт утверждение, проверяемое прогоном/осмотром, без «по необходимости»/«и т.д.»; Tests T1–T12 перечитаны — у каждой команды есть «Ожидание», покрытие DoD полное (DoD1→T1/T3, DoD2→T1/T2, DoD3→T1, DoD4→T3/T5, DoD5→T4, DoD6→T6, DoD7→T7, DoD8→T8, DoD9→T9, DoD10→T10/T11, DoD11→T2, DoD12→T12); открытых to=Owner-вопросов в Q&A log нет, A(owner) отражён в шапке Owner gates; чужие секции (Как я понял/Problem/Solution/Scope/Out of scope/Changes/Follow-ups) — в состоянии после Architect, записи Manager'а/Architect'а не переписаны (append-only); контракты по shasum — AGENTS.md@34e1cecc, planner.md@ce412609, совпадают с рабочей итерацией.
  - Counterfactuals considered: «дефектов не нашёл» было бы ложным — найдены и исправлены 2 дефекта своей зоны (см. Fixes); проверялось также, что формулировки DoD не меняют решений Architect (DoD6←Solution п.4, DoD7/DoD8←Solution п.3, DoD9←Solution п.6 — детализация без противоречий), что маркер-подстрока `Intake (` фигурирует в T3 и не разрушается новым форматом, и что T12-список точно равен 8 позициям Scope + сам план (10 файлов, reviewer-доки не входят).
  - Addendum (new angle): сверх чек-листа паттерны T10/T11 прогнаны по факту на текущем файле: Evidence-записей с HH:MM:SS — 4 (03:27:41/03:31:44/03:34:10/03:37:57), intake-строк с HH:MM:SS — 3 (03:26:59/03:30:27/03:36:55), все 5 дословных якорей T10 находятся (строки 304–315), запись 03:21 без секунд якорями не искажена; Coverage-заголовки T<i> после правок T9/T10 по-прежнему ссылаются на DoD в порядке следования.
  - Fixes: T10 переписан — git diff по untracked-плану возвращал 0 строк (проверено прогоном), проверка ретро-конверсии вырождалась в тривиально-пустую; заменено на git diff --cached после стейджинга + grep-якоря дословного присутствия 5 пред-Coder Evidence-записей. T9 усилен: grep 'HH:MM:SS' + tail -n 8 вместо tail -n 6 (мог срезать первую строку новой записи журнала). Оба фикса — в зоне Tests, до диспатча Coder'а, handoff-статус не менялся.
  - Final censor verdict: OK
- 2026-11-11 03:42:45 — Manager: Planner CENSOR OK подтверждён grep'ом (dispatch id censor:planner:261111_034026, Observations непустые); переход Planning → Ready for Coder валиден. Гейт «стартуем» пройден по предаторизации Owner'ом (Q&A log, первая запись, status=closed); статус In progress; диспатч Coder.
- 2026-11-11 03:51:25 — Coder: изменения по 8 позициям Scope внесены (детали — Changes (by area)): AGENTS.md §3/§4/§5, docs/plans/_template.md, docs/roles/architect.md|planner.md|coder.md, .zcode/commands/planfaktor-status.md|-run.md|-plan.md, docs/decisions.md (append-only, 8 строк). Тесты T1–T9 и T11 прогнаны (факт-строки в Tests/Commands, контрольный прогон 03:50:14): все ожидания выполнены; попутно исправлен собственный дефект — первая версия записи decisions.md (13 строк) срезалась tail -n 8, сжата до 8 строк без потери формата «дата — решение — почему — альтернатива». Дальше: стейджинг + T10/T12.
- 2026-11-11 03:52:37 — Coder: T10 — `git diff --cached` минус-строк нет, 5 дословных Evidence-якорей на месте (406–417), включая 03:21 без секунд; 6-е совпадение — сам-матч grep-паттерна T10 (строка 317), не Evidence-запись. T12 — `git status --porcelain`: ровно 10 файлов Scope, ничего сверх. Все T1–T12 прогнаны, факты — в Tests/Commands; изменения стейджнуты (`git add`), коммита нет (§8). Фаза завершена — DoD выполнен по всем 12 пунктам; статус In review.
- 2026-11-11 03:58:28 — (Role CENSOR) OK: In review validated; current=true
  Censor dispatch id: censor:coder:261111_035410
  Observations:
  - Second opinion: шапка перечитана — `**Status:** In review` (строка 4), Plan ID 261111_0320 согласован с именем файла, PRE_STATUS_LINE конверта censor:coder:261111_035410 совпал; план перечитан целиком; все 12 DoD перепроверены контрольным прогоном 03:57:51: T1 — 3 вхождения `YYYY-MM-DD HH:MM:SS` в AGENTS.md (62 §3 / 102 §4 / 150 §5); T2 — `(Role CENSOR)` строки 102/113, `Censor dispatch id: censor:<role>:<YYMMDD_HHMMSS>` строка 103 дословно, `to=Owner` строки 68/160; T3 — `Intake (` в AGENTS.md:62 и _template.md:41; T4 — architect.md:35, planner.md:43, coder.md 14/42/46 (≥2); T5 — _template.md 38/41; T6 — planfaktor-status 25/29/30, шаг 6 «Никаких изменений файлов» сохранён; T7 — planfaktor-run 25/28 (шаг 2: In progress, Done) и 83 (шаг 4: merge-коммит, Merged); T8 — planfaktor-plan:11; T9 — decisions.md:27, diff только плюс-строки (9/0); T10a — минус-строк в `git diff --cached` нет; T10b — 5 якорей дословно (свежие номера 424/425/426/434/435, включая 03:21 без секунд); T11 — 8 Evidence-записей и 5 intake-строк с HH:MM:SS; T12 — ровно 10 файлов Scope в `git status --porcelain`, unstaged-диф пуст, коммита нет. Факт-строки Tests/Commands соответствуют повторным прогонам; Changes (by area) соответствует фактическим правкам; чужие секции (Как я понял/Problem/Solution/Scope/Out of scope/DoD) и записи Manager'а/Architect'а/Planner'а не тронуты — правки Coder'а только append в Changes/Tests-факты/Evidence/Q&A.
  - Counterfactuals considered: могло пройти незамеченным: (1) сдвиг номеров строк — факт-записи 03:51:47/03:52:37 ссылались на якоря 406–417 и сам-матч 317, верные на момент прогона; после append'ов (факты T10/T12, Evidence, intake CENSOR) якоря сместились на 424–435, сам-матч остался на 317, — перепроверено свежим прогоном, содержание (дословное присутствие) истинно, задним числом факт-записи не правятся (§5 append-only); (2) «ровно 5 строк» T10b фактически даёт 6 — 6-я строка перепроверена: это сам grep-паттерн T10 в Tests/Commands, не Evidence-запись (задокументировано в факте); (3) дайджесты контрактов изменились внутри фазы (AGENTS.md 34e1cecc→b5b5cdf8, coder.md 7bc8bd13→8336c2f1) — обе правки входили в Scope и отражены в Changes, intake Coder'а 03:46:12 фиксировал дож правочные версии честно; (4) `git diff --cached docs/decisions.md` — 9 плюс-строк, 0 минус-строк: прежние записи журнала не переписаны; (5) junk-grep (TODO/FIXME/XXX/console.log/debugger) по всему стейджу — пуст, отладочного мусора нет.
  - Addendum (new angle): сверх чек-листа — стейджинг сверен с деревом после append receipt: план ре-стейджнут, `git diff --stat` пуст (дерево = стейдж), receipt попадает в стейдж; нумерация шагов planfaktor-status проверена на последовательность (1–6 без пропусков и дублей); в T7-факте строка 54 честно помечена как упоминание Evidence в CENSOR-конверте §3 вне правок; DoD-чекбоксы оставлены `[ ]` — отметку выполнения Coder не подделывает, вердикт по DoD — зона ревью.
  - Fixes: ничего — дефектов своей зоны, требующих правки, не найдено (единственные расхождения — устаревшие номера строк в собственных факт-записях — не правятся: append-only, актуальные номера зафиксированы в этом receipt).
  - Final censor verdict: OK
- 2026-11-11 04:06:10 — Manager: Coder CENSOR OK подтверждён grep'ом (dispatch id censor:coder:261111_035410); диспатч ревью-ланов. Risk-вердикт Round 1: needs-fix (1 major — недетерминизм выбора меток в шаге 5 /planfaktor-status; 1 minor — порядок коммит/Evidence в /planfaktor-run:83-84). Возражения — docs/reviews/261111_0320_review.md; статус In progress, диспатч Coder на fixes.
- 2026-11-11 04:10:29 — Coder: fixes Round 1 внесены (детали — Changes (by area), Fixes Round 1): major №1 — шаг 5 /planfaktor-status дополнен детерминированным выбором меток (рабочая intake — начало фазы роли; конец фазы роли = её строка завершения; Evidence-узлы Manager'а фазы роли не закрывают; review — от строки завершения Coder'а до merge-узла; Merged — от узла перехода Merged до closeout-узла Done); minor №2 — шаг 4 /planfaktor-run: Evidence-записи (merge-коммит, переход Merged) и статус Merged — до git add -A && git commit, входят в merge-коммит. T6/T7 перепрогнаны после фиксов (04:09:25, факты Round 1 в Tests/Commands); T12 — 10 файлов Scope стейджнуты (не считая untracked review-артефакта — зона ревьюеров, Coder'ом не стейджнится); коммита нет. Фаза fixes завершена; статус In review.
- 2026-11-11 04:12:27 — (Role CENSOR) OK: In review validated (fixes Round 1); current=true
  Censor dispatch id: censor:coder:261111_041130
  Observations:
  - Second opinion: шапка перечитана — `**Status:** In review` (строка 4), PRE_STATUS_LINE конверта censor:coder:261111_041130 совпал; review-артефакт Round 1 перечитан — оба findings закрыты: major №1 — planfaktor-status шаг 5 (строки 25–44) определяет начало фазы роли = intake рабочей итерации (29–31: первая intake фазы; CENSOR-intake, записанная после строки завершения фазы, началом не считается; при needs-fix-повторах — последняя рабочая итерация), конец фазы роли = её строка завершения (32–34: Evidence-узлы Manager'а конец фазы роли не закрывают — детерминизм вместо «либо»), фазы без ведущей роли (35–38: review — от строки завершения Coder'а до merge-узла; Merged — от узла перехода до closeout-узла Done); minor №2 — planfaktor-run шаг 4 (81–86): Evidence-записи и статус `Merged` предписаны до `git add -A && git commit`, входят в merge-коммит. T6/T7 перепрогнаны (сверено с фактами Round 1 в Tests/Commands: 25/29/31/32–34/35–38/39/41 и 81–86), T12 — 10 файлов Scope стейджнуты, unstaged-диф пуст, `?? docs/reviews/261111_0320_review.md` не тронут Coder'ом; Changes «Fixes Round 1» соответствует фактическим правкам; чужие секции и записи Manager'а/ревьюеров не тронуты.
  - Counterfactuals considered: могло пройти незамеченным: (1) фикс не должен менять решения Architect — сверено с Solution п.2: «повторные итерации дают несколько пар меток, рутина показывает последнюю» реализовано правилом «последняя рабочая итерация» (31), «зазоры (CENSOR, гейты) в длительность не входят» — правилами 29–30 и 32–34; это уточнение выбора, не смена модели; (2) DoD6 требует «elapsed от её intake» — шаг говорит «elapsed от её начала (правила выше)»: для текущей фазы роли начало = intake рабочей итерации, соответствие сохранено, обобщение корректно для фаз без intake; grep T6 (Длительность/elapsed/прочерк) проходит (25/39/41); (3) факт-строки первой итерации (03:50:14, строки 25/29/30) устарели по номерам после фикса — не правлены (append-only), факт Round 1 (04:09:25) фиксирует актуальные; (4) junk-grep по стейджу дал одно совпадение — слово «junk-grep» в моём прошлом CENSOR-receipt (строка 625 диффа), не отладочный мусор; (5) дайджесты контрактов стабильны между fixes- и CENSOR-итерациями (b5b5cdf8/8336c2f1) — правки фиксов касались только команд и плана.
  - Addendum (new angle): сверх чек-листа правило начала проверено на живых данных этого плана: рабочие intake 03:26:59/03:36:55/03:46:12/04:06:02 предшествуют строкам завершения своих фаз, CENSOR-intake 03:30:27/03:38:57/03:58:28 следуют после — правило даёт начало Coder-фазы 03:46:12 (не 03:58:28) и корректно считает 04:06:02 последней рабочей итерацией needs-fix-цикла; разбитая переносом команда `git add -A && git commit -m "type(PlanID): summary"` в шаге 4 читается однозначно (продолжение строки списка).
  - Fixes: ничего — дефектов своей зоны, требующих правки, не найдено.
  - Final censor verdict: OK
- 2026-11-11 04:25:30 — Manager: review Round 2 валиден (Risk pass, Contracts pass, Итог pass; Round 1 помечен superseded — сверено чтением артефакта docs/reviews/261111_0320_review.md). Merge-гейт пройден по предаторизации Owner'ом (Q&A log, первая запись, status=closed). Переход In review → Merged; merge-коммит `feat(261111_0320): add HH:MM:SS timing marks and phase durations` делается сразу после этой записи (запись до события, без хеша — принятый trade-off, review Round 2 minor №2).
- 2026-11-11 04:27:40 — Manager: merge-коммит 782971a (`feat(261111_0320): add HH:MM:SS timing marks and phase durations`, 11 файлов) выполнен; сверено git log. Closeout: ## Follow-ups заполнен (хвосты review Round 2 minor №1/№2 + S1); переход Merged → Done. Запись Done каузально вне merge-коммита — принятый trade-off (review Round 2 minor №2).

## Q&A log (chronological, append-only)
<!-- owner: все роли; intake: `Intake (<дата>): AGENTS.md@<8hex> <role>.md@<8hex>` + NO QUESTIONS / NO SUGGESTIONS / NO OBJECTIONS; вопросы `Q(<роль>): ... to=Owner, blocker: yes|no, needs_owner: yes|no, status=open`; закрытие `A(<кто>): ... status=closed, перенесено в <секция>` -->

- A(owner): Гейты «стартуем» и «мержим» предаторизованы Owner'ом 2026-11-11 (передано через кураторскую сессию), status=closed
- Intake (2026-11-11 03:26:59): AGENTS.md@34e1cecc architect.md@0a898e56
  (intake-строка уже в новом формате — Solution/Decisions п.7)
- Intake-ответы Architect (итерация 2026-11-11 03:26:59): NO QUESTIONS
  (бриф Owner в Evidence закрывает формат меток и границы) /
  SUGGESTIONS: 1 — см. Suggestions log S1 / NO OBJECTIONS.
- Intake (2026-11-11 03:30:27): AGENTS.md@34e1cecc architect.md@0a898e56
  (CENSOR-итерация; дайджесты совпали с рабочей итерацией)
- Intake-ответы Architect (CENSOR-итерация 2026-11-11 03:30:27):
  NO QUESTIONS / NO SUGGESTIONS / NO OBJECTIONS.
- Intake (2026-11-11 03:36:55): AGENTS.md@34e1cecc planner.md@ce412609
- Intake-ответы Planner (итерация 2026-11-11 03:36:55): NO QUESTIONS
  (решения полны для детализации: единый формат метки, модель фазы
  intake → завершение, Evidence-узлы Manager'а, read-only статус-рутина
  определены; ссылки Scope сверены с файлами: planfaktor-run шаг 2 — гейты
  и closeout, шаг 4 — merge; planfaktor-plan шаг 3 — создание плана) /
  NO SUGGESTIONS / NO OBJECTIONS.
- Intake (2026-11-11 03:38:57): AGENTS.md@34e1cecc planner.md@ce412609
  (CENSOR-итерация censor:planner:261111_034026; дайджесты совпали
  с рабочей итерацией)
- Intake-ответы Planner (CENSOR-итерация 2026-11-11 03:38:57):
  NO QUESTIONS / NO SUGGESTIONS / NO OBJECTIONS.
- Intake (2026-11-11 03:46:12): AGENTS.md@34e1cecc coder.md@7bc8bd13
- Intake-ответы Coder (итерация 2026-11-11 03:46:12): NO QUESTIONS
  (DoD полон — 12 проверяемых критериев, T1–T12 заданы с ожиданиями;
  решения Solution/Decisions 1–7 достаточны: единый формат метки, модель
  фазы, Evidence-узлы Manager'а, read-only статус-рутина; ссылки Scope
  сверены с файлами — AGENTS.md §3/§4/§2–§5, planfaktor-run шаги 2/4,
  planfaktor-plan шаг 3, статус плана In progress = PRE_STATUS_LINE) /
  NO SUGGESTIONS / NO OBJECTIONS.
- Intake (2026-11-11 03:58:28): AGENTS.md@b5b5cdf8 coder.md@8336c2f1
  (CENSOR-итерация censor:coder:261111_035410; дайджесты отличаются
  от рабочей итерации 03:46:12 ожидаемо — оба файла правились в рамках
  этого же плана по Scope: AGENTS.md §3/§4/§5, coder.md — формулировки
  «с датой и временем»; зафиксировано в Changes (by area))
- Intake-ответы Coder (CENSOR-итерация 2026-11-11 03:58:28):
  NO QUESTIONS (PRE_STATUS_LINE=In review совпадает с шапкой, строка 4;
  конверт и роль-док перечитаны) / NO SUGGESTIONS / NO OBJECTIONS.
- Intake (2026-11-11 04:00:22): AGENTS.md@b5b5cdf8 reviewer-risk.md@39591bfe
- Intake-ответы Reviewer-risk (итерация 2026-11-11 04:00:22): NO QUESTIONS
  (PRE_STATUS_LINE=In review совпадает с шапкой, строка 4; план прочитан
  целиком, самосогласован) / NO SUGGESTIONS / NO OBJECTIONS.
- Intake (2026-11-11 04:06:02): AGENTS.md@b5b5cdf8 coder.md@8336c2f1
  (fixes-итерация Round 1; дайджесты совпали с CENSOR-итерацией)
- Intake-ответы Coder (fixes-итерация 2026-11-11 04:06:02): NO QUESTIONS
  (review Round 1 прочитан: major №1 — детерминизм выбора меток в шаге 5
  /planfaktor-status (двойные intake при CENSOR, неоднозначное «либо» конца,
  фаза Merged без intake), minor №2 — порядок коммит/Evidence в шаге 4
  /planfaktor-run; оба фикса в границах позиций Scope «.zcode/commands/
  planfaktor-status.md» и «.zcode/commands/planfaktor-run.md»; PRE_STATUS_LINE=
  In progress совпадает с шапкой; наблюдение для Manager'а, не вопрос:
  Contracts lane артефакта Round 1 не заполнен — фиксы выполняю по Risk
  findings, как предписано TASK) / NO SUGGESTIONS / NO OBJECTIONS.
- Intake (2026-11-11 04:12:27): AGENTS.md@b5b5cdf8 coder.md@8336c2f1
  (CENSOR-итерация censor:coder:261111_041130 — сверка fixes Round 1;
  дайджесты совпали с fixes-итерацией)
- Intake-ответы Coder (CENSOR-итерация 2026-11-11 04:12:27):
  NO QUESTIONS (PRE_STATUS_LINE=In review совпадает с шапкой, строка 4) /
  NO SUGGESTIONS / NO OBJECTIONS.
- Intake (2026-11-11 04:13:52): AGENTS.md@b5b5cdf8 reviewer-risk.md@39591bfe
- Intake-ответы Reviewer-risk (Round 2, итерация 2026-11-11 04:13:52):
  NO QUESTIONS (PRE_STATUS_LINE=In review совпадает с шапкой, строка 4;
  дайджесты контрактов не изменились с Round 1) / NO SUGGESTIONS /
  NO OBJECTIONS.
- Intake (2026-11-11 04:20:39): AGENTS.md@b5b5cdf8 reviewer-contracts.md@18e2bfb0
  (Round 2; PRE_STATUS_LINE=In review совпадает с шапкой, строка 4)
- Intake-ответы Reviewer-contracts (Round 2, итерация 2026-11-11 04:20:39):
  NO QUESTIONS (Risk verdict Round 2 записан — pass, лан второй, Итог
  собирать можно) / NO SUGGESTIONS / NO OBJECTIONS.

## Suggestions log (chronological, append-only)
<!-- owner: все роли; несрочные улучшения -->

- S1 (2026-11-11, architect): агрегация длительностей фаз по закрытым
  (Done) планам для поиска узких мест конвейера — сейчас /planfaktor-status
  смотрит только активный план; why не в скоупе: бриф Owner ограничивает
  активным планом, а история пока пуста (первый план в работе).

## Objections log (chronological, append-only)
<!-- owner: все роли; `### <Role> objections`; строка на возражение, blocker: при блокере -->

## Follow-ups (deferred)
<!-- owner: coder/planner при CENSOR; незакрытые хвосты: <описание> — why: <почему сейчас не в скоупе>; обязательна запись `NO FOLLOW-UPS — why: <код_причины>` при отсутствии -->

- Квантификатор «последняя» для review-фазы в шаге 5 /planfaktor-status (после needs-fix две строки завершения Coder'а) — why: review Round 2 minor №1, вне вердиктного порога; целостное чтение шага неоднозначность снимает (docs/reviews/261111_0320_review.md, Round 2).
- Остаточные trade-off'ы merge-механики: closeout-запись Done каузально вне merge-коммита; запись о merge-коммите до события без хеша — why: review Round 2 minor №2,Accepted trade-off; требует решения уровня Architect (порядок событий и commits), не Coder.
- S1: агрегация длительностей фаз по Done-планам (узкие места конвейера) — why: бриф Owner ограничивает активным планом; Suggestions log S1.
- (Manager, closeout 2026-11-11 04:27): заполнено Manager'ом при closeout — CENSOR Coder'а Follow-ups не заполнил; хвосты взяты дословно из review-артефакта Round 2 и Suggestions log.
