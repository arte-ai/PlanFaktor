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
| Ready for Coder | — | Гейт «старт кодинга»: явное да |
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

### Planning

Planner переносит ответы Q&A в секции, пишет Acceptance criteria/DoD и
Tests/Commands, уточняет Scope, готовит handoff Coder. Растут секции плана:
DoD, Tests/Commands. После `Ready for Coder` — Planner CENSOR (§4).
Гейт Owner: «старт кодинга» — переход `Ready for Coder` → `In progress`
Manager делает только после явного да.

### In progress

Coder реализует по плану: изменения стейджит, но не коммитит; факты — в
`## Changes (by area)`, прогоны тестов — в Evidence. Растут рабочее дерево
и Evidence. После `In review` — Coder CENSOR (§4). Гейт Owner: нет;
блокер — стоп-лайн (§6).

### In review

Manager диспатчит лейны; risk-лайн создаёт review-артефакт
`docs/reviews/<PlanID>_review.md` из шаблона при отсутствии. Лейны идут
последовательно: risk → contracts, contracts читает секцию risk. Итог
действителен только при двух записанных вердиктах. needs-fix — план
возвращается Coder'у (`In progress`, возражения в Objections log). Гейт
Owner: merge — после двух pass; CENSOR у ревьюеров нет (§4).

### Merged → Done

Manager коммитит (`type(PlanID): summary`, §8) и делает closeout:
секция `## Follow-ups` плана заполнена — статус `Done`.

## Артефакты

| Артефакт | Где | Шаблон | Примечание |
|---|---|---|---|
| План | `docs/plans/YYMMDD_HHMM_topic.md` | `docs/plans/_template.md` — единственный | Шапка — parser-контракт, формат не менять |
| Review | `docs/reviews/<PlanID>_review.md` | `docs/reviews/_template_review.md` | Один на раунд ревью; два лейна-вердикта |
| Роли-доки | `docs/roles/<role>.md` | — | architect, planner, coder, reviewer-risk, reviewer-contracts |

Каждая секция плана несёт ownership-метку `<!-- owner: ... -->`: Architect,
Planner, Coder пишут только в свои зоны, цензор-проход не трогает чужие
поля (§1) — нарушение зоны = FAIL. Логи плана (Evidence, Q&A, Suggestions,
Objections) — append-only, историю не переписывают (§5).

## Гейты Owner

Два гейта, оба зафиксированы в шапке плана строкой `Owner gates`:

1. **Старт кодинга** — `Ready for Coder` → `In progress`: Owner даёт «стартуем».
2. **Merge** — `In review` → `Merged`: два pass-вердикта review + явное да;
   коммит делается в рамках этого гейта.

Правило (§8): коммит делает только Manager и только после явного Owner-«да»
на гейте; молчание Owner ничего не двигает (`owner-silence`, §6).

## Роль CENSOR

Выжимка §4; формат конверта и receipt — в конституции.

- После ключевой фазы (Architect, Planner, Coder) Manager шлёт CENSOR-проход
  в тот же живой субагент-хендл — «второй угол обзора» по файлам.
- Итог — append-only receipt в `## Evidence` плана: маркер `(Role CENSOR)`,
  dispatch id, Observations, вердикт `OK | FAIL`. Manager подтверждает
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
