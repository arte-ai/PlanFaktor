# Жизненный цикл плана Planfaktor

Справочник для человека: путь плана от Draft до Done; точные правила и форматы —
в конституции `AGENTS.md` (§§1–8).

## Карта цикла

```
Draft → Ready for Planner → Planning → Ready for Coder → In progress
      → In review → Merged → Done          (+ Superseded в любой момент)
```

Истина маршрутизации — `**Status:**` в шапке плана (§2): Manager перечитывает
файлы, а не память чата. Активный план один; очередь = сортировка имён.

| Статус | Кто действует | Что ждёт Owner |
|---|---|---|
| Draft | Architect: понимание, Problem/Solution/Scope | Ответы на Q&A; вопрос `to=Owner, blocker:` останавливает работу |
| Ready for Planner | — | Ничего: Architect CENSOR пройден, план ждёт Planner |
| Planning | Planner: AC/DoD, Tests/Commands | Ответы на Q&A |
| Ready for Coder | Manager: авто-переход при чистом Q&A, диспатч Coder | Ничего — кроме открытых вопросов |
| In progress | Coder: реализация, evidence, staged-изменения | Ничего — кроме blocker |
| In review | Reviewer-risk, затем Reviewer-contracts | Гейт merge: явное да после двух pass |
| Merged | Manager: коммит сделан, идёт closeout | Ничего |
| Done / Superseded | — | Ничего: план закрыт |

## Фазы плана

### Draft → Ready for Planner

Architect понимает задачу и заполняет решения: «Как я понял задачу», Problem,
Solution/Decisions, Scope/Out of scope; вопросы к Owner — строками в
`## Q&A log`. Растёт сам план (из `_template.md`). После handoff-статуса —
Architect CENSOR (§4). Гейт Owner: нет; блокирующий вопрос = стоп (§6).
При переходе Manager ретранслирует Owner'у блок «Как я понял задачу»
и границы Scope (дословно, информационно, без подтверждения) — точка
чтения человека.

### Planning

Planner переносит ответы Q&A в секции, пишет Acceptance criteria/DoD и
Tests/Commands, уточняет Scope, готовит handoff Coder. Растут секции плана:
DoD, Tests/Commands. До простановки статуса — finalize completion-pass:
второй проход «глазами Coder и Reviewer» (что им придётся угадывать;
нет ли implicit-доказательств без материального носителя), исход —
append-only запись в Evidence (§2). После `Ready for Coder` — Planner
CENSOR (§4).
Гейт Owner: нет — переход `Ready for Coder` → `In progress` Manager
делает автоматически: перечитывает `## Q&A log` (пары Q→A, якорный
`grep -E '^- Q\('`); открытый вопрос к Owner — стоп (§6), чистый Q&A —
перевод и диспатч Coder.

### In progress

Coder реализует по плану: до правок по каждому DoD-пункту фиксирует
исход AC-to-test из закрытого набора (`explicit assertion` |
`existing proof` | `N/A (why=...)` | `reroute` — стоп-линия без
расширения скоупа; фиксация в Evidence до Changes); допущения — строками
`Assumption:` в Q&A log, влияющие на Scope/DoD/контракты — стоп
и возврат на Planner (§5). Изменения стейджит, но не коммитит; факты — в
`## Changes (by area)`, прогоны тестов — в Evidence. Растут рабочее дерево
и Evidence. После `In review` — Coder CENSOR (§4). Гейт Owner: нет;
блокер — стоп-лайн (§6).

### In review

Manager диспатчит лейны; risk-лайн создаёт review-артефакт
`docs/reviews/<PlanID>_review.md` из шаблона при отсутствии. Лейны идут
последовательно: risk → contracts, contracts читает секцию risk. Итог
действителен только при двух записанных вердиктах; contracts ставит
`**Artifact state:**` артефакта при сборе Итога. needs-fix с Loop signal
(повторный по lineage блокер — B-блок с Loop-подблоком) — Manager
диспатчит Architect'а (reroute) до любого перевода статуса:
same-contract reroute → `Ready for Coder`, real scope expansion →
`Ready for Planner`, de-scoped follow-up — Follow-ups/backlog без
перехода; needs-fix без Loop signal — план возвращается Coder'у (Coder
ставит `In progress` на intake fixes-итерации; возражения — в
review-артефакте: findings ланов); Manager дописывает Stale/Rerun note
в Evidence плана: прошлый вердикт относится к пред-фиксному diff,
реран обязателен. Раунд ≥ 2 объявляет `**Rerun mode:** incremental |
full`. Гейт Owner: merge — после двух pass; CENSOR у ревьюеров нет (§4).

### Merged → Done

Manager коммитит (`type(PlanID): summary`, §8) и делает closeout:
секция `## Follow-ups` плана заполнена, review-артефакт в терминальном
состоянии (`**Artifact state:**` = `current_green` /
`historical_reconciled`; нетерминальные `current_red` /
`needs_reviewer_rerun` closeout блокируют — терминальность проверена
гейтом мерджа до Owner-«да», повторное срабатывание = пост-мердж-
аномалия: стоп, Owner + ручной плейбук; диспатч ревью из `Merged`
контрактом статусов не предусмотрен, ревьюеры работают в `In review`)
и harvest-инвентарь de-scoped хвостов пройден: инвентаризируются три
источника (`## Follow-ups (deferred)`; открытые Q&A/suggestions/
objections; пункты `## Out of scope` класса «removed from active
scope / отдельно потом» — candidate de-scoped debt), каждый candidate
получает судьбу (`promoted` / `open` / `handled` /
`already-tracked-elsewhere`; судьбы переиспользуют row-грамматику
followups; дедуп по canonical ref `id=`/`source_ref`/`#B<N>`);
candidate без судьбы = `lost follow-up during harvest` — стоп-код,
`Done` не ставится (§2) — статус `Done`.

## Артефакты

| Артефакт | Где | Шаблон | Примечание |
|---|---|---|---|
| План | `docs/plans/YYMMDD_HHMM_topic.md` | `docs/plans/_template.md` — единственный | Шапка — parser-контракт, формат не менять |
| Review | `docs/reviews/<PlanID>_review.md` | `docs/reviews/_template_review.md` | Один на план (раунды дописываются в тот же файл); два лейна-вердикта; live-блокеры — B-блокы `### B<N>` в Итоге; состояния артефакта: `current_green` / `historical_reconciled` (терминальные, разрешают closeout), `current_red` / `needs_reviewer_rerun` (нетерминальные, блокируют closeout) |
| Роли-доки | `docs/roles/<role>.md` | — | architect, planner, coder, reviewer-risk, reviewer-contracts |
| Snapshot-рестарт Manager | `docs/playbooks/manager_snapshot_restart.md` | — | Упреждающий контекст-чекпоинт между сессиями (history/handover, не source of truth); носитель `.tmp/snapshots/`, не коммитится |
| Invariant map правки контрактов | `docs/playbooks/contract_edit_invariant_map.md` | — | Классификатор hard invariant / role-specific delta / procedural noise; обязателен перед gardening/sweep и правкой контрактов |
| Doc gardening | `docs/playbooks/doc_gardening.md` | — | Регламентный GC канона: правила в рецепты, минус дубли; запуск по решению Owner |
| Canon sweep | `docs/playbooks/docs_canon_sweep.md` | — | Уплотнение канона после merge-волны: «коротко + pointers», новых правил не создаёт |

Каждая секция плана несёт ownership-метку `<!-- owner: ... -->`: Architect,
Planner, Coder пишут только в свои зоны, цензор-проход не трогает чужие
поля (§1) — нарушение зоны = FAIL. Логи плана (Evidence, Q&A, Suggestions,
Objections, Token usage) — append-only, историю не переписывают (§5).

## Гейты Owner

Один гейт, зафиксированный в шапке плана строкой `Owner gates`; сверх
гейта Owner дёргается точечно — открытыми вопросами `to=Owner` в
`## Q&A log` (пока вопрос открыт, конвейер ждёт, §6):

1. **Merge** — `In review` → `Merged`: два pass-вердикта review + явное да;
   коммит делается в рамках этого гейта.

Переход `Ready for Coder` → `In progress` — не гейт: Manager переводит
сам при чистом `## Q&A log` (перечитывание секции, пары Q→A; открытый
вопрос к Owner — стоп, §6). Точка перехода смотрит только Q&A log —
Objections log блокиратором авто-перехода не является (роль сама
стопается по §6) — осознанное решение. Точка чтения человека —
ретрансляция «Как я понял задачу» + границ Scope при выходе Architect'а
(информационно).

Правило (§8): коммит делает только Manager и только после явного Owner-«да»
на merge-гейте; молчание Owner ничего не двигает (`owner-silence`, §6).

## Роль CENSOR

Выжимка §4; формат конверта и receipt — в конституции.

- После ключевой фазы (Architect, Planner, Coder) Manager шлёт CENSOR-проход
  в тот же живой субагент-хендл — «второй угол обзора» по файлам.
- Итог — append-only receipt в `## Evidence` плана: маркер `(Role CENSOR)`,
  dispatch id, Observations, вердикт `OK | FAIL`. `Fixes:` обязателен
  всегда: контент либо `Fixes: none (NO FINDINGS; <контент-факты>)`;
  rN-проходы (fixes-итерации Coder'а) несут метку
  `Review verdict seen: <Round, вердикт>`. Manager подтверждает
  переход grep'ом receipt, а не словами роли.
- FAIL: роль сама откатывает handoff-статус, фиксирует причину в
  `### <Role> objections`, правит и повторяет; два FAIL подряд — эскалация
  Owner. Малый план допускает `Censor hint: skip (why=...)` вместо receipt —
  максимум два skip'а подряд.
- У ревьюеров CENSOR нет.

## Завершение

- **Done.** После merge Manager делает closeout: `## Follow-ups` заполнен
  (хвосты с `why` либо `NO FOLLOW-UPS`) — ставится `Done`.
- **Superseded.** С любого статуса, когда план заменён; остаётся строка-ссылка
  на преемника (§2).
- **Планы не удаляются** (§8): закрываются статусом, история остаётся в
  `docs/plans/`. Новый артефакт — только из шаблона (§9).
