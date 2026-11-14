# Plans — грамматика `docs/plans/*.md`

Каноны процесса — конституция `AGENTS.md`; этот файл — грамматика плана
как артефакта: именование, шапка, секции, логи, финалы. При расхождении
правится конституция, затем этот файл.

## План как контракт

План в `docs/plans/` — repo-backed контракт на реализацию: постановка,
решения, границы, DoD, факты и логи. Истина маршрутизации — строка
`**Status:**` в шапке (§2): Manager перед каждым шагом перечитывает файлы,
память чата — только reconciliation (§5).

Новый план создаётся только из `docs/plans/_template.md` — свежим чтением
с диска, не копированием старого плана: шаблон живой, грамматика старого
плана могла устареть. Отступление от шаблона — fail loud, возврат роли (§9).

## Именование

`YYMMDD_HHMM_topic.md` — пример: `261111_0320_pipeline_timing.md`.

- тема — латиницей, слова через `_`;
- Plan ID = `YYMMDD_HHMM` = префикс имени файла (коммит —
  `type(PlanID): summary`, §8);
- время в имени обязательно: несколько планов за день по одной теме —
  норма, сортировка имён должна отражать порядок работ;
- сортировка имён = очередь: следующий к исполнению — старейший план в
  `Ready for *` / `In progress` / `In review` / `Merged` (Merged —
  closeout не откладывается); один план в активной работе одновременно
  (§2).

## Шапка — parser-контракт

Четыре строки шапки из шаблона — `**Plan ID:**`, `**Status:**`,
`**Created:**`, `**Owner gates:**` — grep'аются Manager'ом и corpus-линтом;
формат строк не менять. Значения `**Status:**` — только из статусной
машины §2; Plan ID обязан совпадать с префиксом имени файла.

## Статусная машина

Канон — §2 `AGENTS.md`, единственный источник; таблица ниже —
навигационная копия, при правке §2 обновляется здесь же.

| Переход | Кто ставит | Условие |
|---|---|---|
| `Draft` → `Ready for Planner` | Architect | Фаза + intake завершены; CENSOR OK |
| `Ready for Planner` → `Planning` | Planner | Intake Planner записан в плане |
| `Planning` → `Ready for Coder` | Planner | DoD/Tests заполнены; finalize completion-pass записан; CENSOR OK |
| `Ready for Coder` → `In progress` | Manager | Открытых вопросов к Owner нет: перечитывание `## Q&A log`, пары Q→A |
| `In progress` → `In review` | Coder | Реализация + evidence; CENSOR OK |
| `In review → In progress` | Coder | needs-fix без Loop signal (возражения — в review-артефакте; Coder ставит статус на intake fixes-итерации) |
| `In review` → `Ready for Coder` | Architect | Reopened-классификация `same-contract reroute` (контракт не менялся); диспатч Architect по Loop signal |
| `In review` → `Ready for Planner` | Architect | Reopened-классификация `real scope expansion`; диспатч Architect по Loop signal |
| `In review` → `Merged` | Manager | Два pass-вердикта; Owner-гейт merge; коммит |
| `Merged` → `Done` | Manager | Closeout: `## Follow-ups` заполнен; review-артефакт в терминальном состоянии |
| `*` → `Superseded` | Architect/Owner | План заменён; строка-ссылка на преемника |

Порядок CENSOR: роль ставит handoff-статус → Manager шлёт CENSOR-проход
в тот же живой субагент → OK подтверждает переход, FAIL — откат статуса
той же ролью (§4).

## Секции и ownership

Каждая секция плана несёт метку `<!-- owner: ... -->`: роль пишет только
в свои секции, цензор-проход не заполняет чужие поля; нарушение зоны =
FAIL (§1). DoD-чекбоксы (`## Acceptance criteria / DoD`) — зона Planner:
формулирует проверяемые критерии и закрывает чекбоксы по фактам; Coder
DoD не правит — его зона `## Tests / Commands` (факты прогонов) и
`## Changes (by area)`.

## Обязательные поля: контент или явная форма отсутствия

Обязательное поле плана несёт контент либо `N/A (why=...)` — если у
поля нет специализированной формы отсутствия (`NO QUESTIONS`,
`NO FOLLOW-UPS — why:`, `plan=none` и другие по §5 конституции);
специализированные формы старше общей, не дублируются и не заменяются
ею; `TBD`/пусто/`UNCONFIRMED` невалидны как класс (§5).

A/B-выборы: пока выбор между вариантами не сделан, развилка — открытый
Q&A (`status=open`); секция решения не несёт «либо/или» — иначе Coder
получает развилку вместо решения. Закрытие выбора: пункт
секции-владельца переписывается в финальную формулировку без дизъюнкции
(append-only логи при этом не переписываются — история выбора остаётся
в Q&A-паре), отклонённая альтернатива фиксируется строкой
`rejected alternative: <вариант> — why: <основание>`, добавляются
1–2 acceptance-пункта, делающие решение проверяемым.

Переименования и миграции терминологии — narrow + broad proof в Tests:
narrow — exact-паттерн нового wording (с базой «сейчас 0», если якорь
различающий), broad — prose-drift старого токена по всем активным
носителям с классификацией вхождений (исторические планы и append-only
артефакты исключены — там старое имя остаётся вечно). Один narrow без
broad даёт false-green, один broad без narrow — false-red.

## Логи — append-only

`## Evidence`, `## Q&A log`, `## Suggestions log`, `## Objections log`,
`## Token usage` — только дописывание; историю не переписываем (§5).
Форматы строк — в комментариях `docs/plans/_template.md`.

## Финалы: планы не удаляются

План закрывается статусом: `Done` (после merge и closeout) или
`Superseded` (заменён; остаётся строка-ссылка на преемника). Файлы
остаются в `docs/plans/` (§8). Решения уровня «навсегда» — в
`## Evidence` плана, их реализующего (журнал решений упразднён); план —
не хранилище знаний.

## Техдолг и follow-ups

Не всё становится планом: техдолг и отложенные хвосты заводятся строкой
в `docs/followups/backlog.md` (`status=open, plan=none`), а не
tasks-only планом. Промоушен — отдельным планом: строка backlog получает
`plan=<PlanID>` и `status=promoted`, план стартует из шаблона как
обычно. Хвосты внутри активного плана — `## Follow-ups (deferred)`
с `why`.

## Review-артефакты

Ревью живёт в `docs/reviews/<PlanID>_review.md` — один артефакт на план,
создаётся из `docs/reviews/_template_review.md`. Лейны последовательно:
risk → contracts (contracts читает секцию risk); итог действителен
только при двух записанных вердиктах. Повторное ревью — новый
`**Round:** N` в том же артефакте (append + строка
`**Round N started:**`); вердикты прошлых раундов помечаются
`superseded (round N)`; действителен только последний Round.

Грамматика live-блокеров и rerun-цикла (план 261113_1642):

- **Канонические B-ID.** Live-блокер оформляется блоком `### B<N>`
  в `## Итог` (лейны пишут findings с локальными ID — канонизация
  в синтезе): `Current state:` ∈ {open; historical-fixed; superseded},
  `Severity:` ∈ {S1; S2; S3}, `Primary owner gap:`. B-блок — единственная
  легальная форма live-блокера; ссылки на него — `<путь_ревью>#B<N>`;
  findings-таблицы blocker/major/minor остаются плотным перечнем находок.
- **Merge-гейт — только live S1** (контракт/данные/безопасность/
  несоответствие плану, включая регрессии поведения соседних областей):
  итоговый needs-fix ⇔ есть блок `Current state: open` + `Severity: S1`;
  S2/S3 материализуются фиксом либо follow-up.
- **Loop signal.** Live-блок, чей ID переиспользован из superseded-раунда
  (маркер `#B<N>` в строках с `superseded (round ...)`), несёт
  Loop-подблок: `Loop signal:`, `Root cause class:` ∈ {stale-evidence;
  same-contract-reroute; closed-baseline-split; real-scope-expansion;
  de-scoped-followup}, `Next owner:`; повтор без Loop signal = process
  miss — Manager возвращает артефакт fail loud. needs-fix с Loop signal
  идёт Architect'у (reopened-классификация → reroute-переходы §2),
  без — Coder'у.
- **Rerun mode.** Раунд ≥ 2 объявляет `**Rerun mode:** incremental |
  full` (risk-лейн при открытии раунда): incremental — только от
  последнего pass-раунда, закрывшего исходный scope, с полями Baseline
  artifact / Rerun scope / Trusted unaffected surfaces / Reused evidence;
  full — реран по всему diff. Необъявленный режим = process gap.
- **Терминальные состояния.** `**Artifact state:**` (ставит contracts-лейн
  при сборе Итога): `current_green` / `historical_reconciled` —
  терминальные, разрешают closeout; `current_red` /
  `needs_reviewer_rerun` — нетерминальные, блокируют `Merged → Done`.
- **Судьбы синтеза.** Итог присваивает каждой находке судьбу
  {accepted_blocker | accepted_non_blocking_followup | accepted_risk |
  dismissed | superseded} с canonical_ref `#B<N>`; при отсутствии находок
  — no-findings placeholder (coverage-домены + причина), не пустота;
  при rerane прежние судьбы помечаются `— superseded (round N)`.
- **Coverage.** Секция раунда каждого лейна несёт `**Coverage:**`
  с доменами из enum'а лейна и при пустой таблице — `**No findings
  reason:**` текстом. Форма проверяется линтом C13 (`scripts/check_corpus.sh`,
  Plan ID ≥ 261113_1642 минус exclude-лист артефактов старой грамматики).
