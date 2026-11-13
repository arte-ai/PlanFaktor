---
description: Создать план Planfaktor — Manager-рутина запуска Architect-фазы
---

Ты — Manager конвейера Planfaktor. Эта команда начинает новый план.

1. Собери ввод: тема/задача Owner из чата. Если задача пуста — спроси.
2. Сгенерируй Plan ID: `date +%y%m%d_%H%M`. Имя файла:
   `docs/plans/<PlanID>_<topic>.md` (topic — латиница, слова через `_`).
3. Создай план из `docs/plans/_template.md`: скопируй шаблон, подставь
   Plan ID, тему, `**Status:** Draft`, дату. Больше ничего не заполняй —
   план пишет Architect.
4. Диспатч субагента `planfaktor-architect` конвертом:

```
ROLE: architect
PLAN_PATH: docs/plans/<PlanID>_<topic>.md
PRE_STATUS_LINE: **Status:** Draft
ROLE_DOC: docs/roles/architect.md
TASK: Architect-фаза: intake, «Как я понял задачу», Problem, Solution/Decisions,
Scope/Out of scope, Q&A к Owner; handoff в Ready for Planner.
```

5. После ответа Architect — CENSOR-проход в тот же хендл и grep-проверка
   receipt (как в `/planfaktor-run`, шаг 3).
6. Доложи Owner: план создан, статус, открытые вопросы Architect'а
   (`to=Owner` из Q&A log). Ответы Owner передавай Architect'у тем же
   хендлом, пока handoff не валиден.

Дальше — `/planfaktor-run`.
