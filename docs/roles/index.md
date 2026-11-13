# Роли: индекс

Навигация по ролям Planfaktor. Канон — конституция `AGENTS.md` (§1): при
расхождении конституция старше, этот файл — только указатель. Роль-доки
лежат в `docs/roles/`, субагент-носители — в `.zcode/agents/`
(`planfaktor-<роль>.md`; reviewer-лайны могут сидеть на разных моделях —
см. frontmatter агентов).

| Роль | Носитель (роль-док / агент / команда) | Зона одной строкой | Ключевые запреты |
|---|---|---|---|
| Owner | человек в чате | Гейт merge; ответы на Q&A | Не пишет план/код |
| Manager | основная сессия, `/planfaktor-run` | Роутинг, диспатчи, CENSOR-гейты, коммиты после «да» | Не пишет план/код; решения — только по файлам |
| Architect | `architect.md` / `planfaktor-architect` | Понимание, решения, Problem/Solution/Scope, Q&A с Owner | Не детализирует до DoD; не пишет код |
| Planner | `planner.md` / `planfaktor-planner` | AC/DoD, Tests/Commands, перенос ответов Q&A, handoff Coder'у | Не меняет решения Architect; не пишет код |
| Coder | `coder.md` / `planfaktor-coder` | Реализация по плану, evidence, staged-изменения | Не выходит за Scope; стоп-лайн при блокере |
| Reviewer-risk | `reviewer-risk.md` / `planfaktor-reviewer-risk` | Риски, регрессии, edge cases, безопасность изменений | Не правит код; вердикт — в review-артефакт |
| Reviewer-contracts | `reviewer-contracts.md` / `planfaktor-reviewer-contracts` | Соответствие плану: Scope/DoD/AC выполнены, ничего лишнего | Не правит код; вердикт — в review-артефакт |

## Указатели

- Конституция и authority: `AGENTS.md` — §1 роли/зоны, §2 статусная
  машина, §4 CENSOR, §6 стоп-матрица.
- Жизненный цикл плана: `docs/lifecycle.md`.
- Грамматика планов: `docs/plans/README.md`; шаблон плана —
  `docs/plans/_template.md`.
- Новая роль: каркас `docs/roles/_template.md` (копировать; править
  существующие роль-доки — только планом, это контракт).

Правка этого индекса — вместе с правкой §1 конституции.
