# Planfaktor — конституция конвейера

Planfaktor — plan-driven конвейер ролей, целиком в ZCode, без рантайма.
Manager — основная ZCode-сессия; роли — субагенты; Owner — человек в чате.
Routing truth — статусы в файлах планов. Память чата — только reconciliation.


## 1. Роли и зоны

| Роль | Носитель | Зона | Ключевые запреты |
|---|---|---|---|
| Owner | человек в чате | Гейты: старт кодинга, merge; ответы на Q&A | Не пишет план/код |
| Manager | основная сессия, `/planfaktor-run` | Роутинг, диспатчи, CENSOR-гейты, коммиты после «да» | Не пишет план/код; решения — только по файлам |
| Architect | субагент `planfaktor-architect` | Понимание, решения, Problem/Solution/Scope, Q&A с Owner | Не детализирует до DoD; не пишет код |
| Planner | субагент `planfaktor-planner` | AC/DoD, Tests/Commands, перенос ответов Q&A в секции, handoff для Coder | Не меняет решения Architect; не пишет код |
| Coder | субагент `planfaktor-coder` | Реализация по плану, evidence, staged-изменения | Не выходит за Scope; стоп-лайн при блокере |
| Reviewer-risk | субагент `planfaktor-reviewer-risk` | Риски, регрессии, edge cases, безопасность изменений | Не правит код; вердикт — в review-артефакт |
| Reviewer-contracts | субагент `planfaktor-reviewer-contracts` | Соответствие плану: Scope/DoD/AC выполнены, ничего лишнего | Не правит код; вердикт — в review-артефакт |

**Ownership-зоны.** Роль не заполняет чужие секции плана и не правит чужие
артефакты: Coder не правит DoD, Planner не меняет решения Architect,
цензор-проход роли не заполняет поля другой роли. Нарушение зоны = FAIL.

**Write-surface Manager'а.** Запрет Manager'у «писать план» (строка «Не
пишет план/код» в таблице ролей) означает содержательные секции —
ownership-зоны ролей. Manager вправе писать в плане только закрытый список
служебного: (a) Evidence-узлы по §5 (создание плана, гейт-переходы
`In progress`/`Merged`, merge-коммит, closeout `Done`); (b) дословный
Owner-бриф в `## Evidence` при создании плана; (c) строки `A(owner)` —
перенос ответов Owner из чата в Q&A log; (d) служебные fail-loud записи
отклонений в Evidence; (e) Evidence-записи о событиях собственной зоны
Manager'а по §1 (роутинг, диспатчи, CENSOR-гейты, Owner-гейты) сверх
обязательных узлов §5: grep-валидация CENSOR-перехода и диспатч следующей
роли, открытие/ожидание Owner-гейта (owner-silence), возврат needs-fix
со статусом и составом возврата. Статусная строка `**Status:**` — не
секция плана: право её менять определяет §2 (кто ставит переход, тот
и пишет строку); write-surface её не ограничивает. Всё вне списка —
содержательные секции (ownership-зоны ролей); запись Manager'а
в содержательной секции вне write-surface = нарушение §1.

## 2. Routing truth и статусная машина

Истина маршрутизации — строка `**Status:**` в шапке плана
(`docs/plans/YYMMDD_HHMM_topic.md`). Manager перед каждым шагом перечитывает
статусы файлов; решения ссылаются на файл, не на память чата.

```
Draft → Ready for Planner → Planning → Ready for Coder → In progress
      → In review → Merged → Done          (+ Superseded в любой момент)
```

| Переход | Кто ставит | Условие |
|---|---|---|
| `Draft` → `Ready for Planner` | Architect | Фаза + intake завершены; Architect CENSOR OK |
| `Ready for Planner` → `Planning` | Planner | Intake Planner записан в плане |
| `Planning` → `Ready for Coder` | Planner | DoD/Tests заполнены; Planner CENSOR OK |
| `Ready for Coder` → `In progress` | Manager | **Owner-гейт «стартуем»** |
| `In progress` → `In review` | Coder | Реализация + evidence; Coder CENSOR OK |
| `In review` → `Merged` | Manager | Оба ревью-вердикта pass; **Owner-гейт merge**; коммит сделан |
| `Merged` → `Done` | Manager | Closeout: `## Follow-ups` плана заполнен |
| `*` → `Superseded` | Architect/Owner | План заменён другим; строка-ссылка на преемника |

Порядок CENSOR (раздел 4): роль ставит handoff-статус → Manager шлёт
CENSOR-проход в тот же субагент → OK подтверждает переход, FAIL — откат
статуса той же ролью. Manager не двигает план дальше без валидного CENSOR.

Именование планов: `YYMMDD_HHMM_topic.md` (тема — латиницей, слова через
`_`). Порядок очереди = сортировка имён; следующий к исполнению — старейший
план в статусе `Ready for *` / `In progress` / `In review`. Один план в
активной работе одновременно.

## 3. Intake — обязательный префикс итерации роли

Каждая итерация роли (включая CENSOR-проход) начинается с intake:

1. Прочитать `AGENTS.md` (этот файл) и свою `docs/roles/<role>.md`.
2. Прочитать план целиком.
3. Записать в `## Q&A log` contract-строку: `Intake (YYYY-MM-DD HH:MM:SS):
   AGENTS.md@<8 hex sha256> <role>.md@<8 hex sha256>` (локальное время
   машины) — подтверждение, что прочитаны именно текущие версии контрактов
   (Manager волен сверить: `shasum -a 256 AGENTS.md docs/roles/<role>.md`).
4. Зафиксировать в `## Q&A log` три явных ответа: `NO QUESTIONS` /
   `NO SUGGESTIONS` / `NO OBJECTIONS` — или конкретные списки. Формат
   вопроса: `Q(<роль>): <текст> to=Owner|to=<роль>, blocker: yes|no,
   needs_owner: yes|no, status=open`. Не-блокирующий вопрос, который
   решает только Owner (`needs_owner: yes`), роль сама не закрывает;
   закрытие — только ответной строкой `A(<кто>): <ответ> status=closed,
   перенесено в <секция>`. Ответ в чате закрытием не считается.
5. Architect дополнительно пишет/обновляет `## Как я понял задачу` (3–7 строк).
6. Только после этого — работа по фазе.
7. **Миграция контрактов внутри фазы.** Правило миграции: план, меняющий
   контракты (`AGENTS.md`, `docs/roles/*`, шаблоны, `.zcode/commands/*`),
   фиксирует в `## Evidence` смену digest'ов по каждому изменённому файлу
   (старый@8hex → новый@8hex, с меткой времени). Роли при следующем intake
   перечитывают изменённые контракты (п.1) и записывают актуальные
   digest'ы; расхождение digest'ов между итерациями одной фазы — норма,
   если смена зафиксирована в Evidence планом; незафиксированное
   расхождение — стоп и повторный диспатч.

Manager не диспатчит работу роли, если intake-записи текущей итерации нет
в плане (contract-строка + три ответа). Intake — запись в плане, отдельного
статуса нет.

## 4. CENSOR — same-subagent second opinion

После завершения ключевой фазы роли, до запуска следующей роли, Manager
отправляет CENSOR-проход **в тот же живой субагент-хендл** (контекст
сохранён — это «второй угол обзора»: роль перепроверяет собственную работу).

Точки: Architect (после `Ready for Planner`), Planner (после
`Ready for Coder`), Coder (после `In review`). У ревьюеров CENSOR нет.

CENSOR-конверт (SendMessage в тот же handle):

```
PASS: censor
DISPATCH_ID: censor:<role>:<YYMMDD_HHMMSS>
PRE_STATUS_LINE: **Status:** <текущий handoff-статус>
Задача: сверка собственного handoff с файлами (не с памятью); append-only
receipt в ## Evidence.
```

Receipt (ровно одна append-only запись в `## Evidence` плана):

```
- YYYY-MM-DD HH:MM:SS — (Role CENSOR) OK: <handoff-статус> validated; current=true
Censor dispatch id: censor:<role>:<YYMMDD_HHMMSS>
Observations:
- Second opinion: <что перепроверено, с цитатами из файлов>
- Counterfactuals considered: <что могло сломаться и проверено; обязательно при «дефектов не нашёл»>
- Addendum (new angle): <что посмотрено сверх чек-листа; обязательно при «дефектов не нашёл»>
- Fixes: <что исправлено / ничего>
- Final censor verdict: OK | FAIL
```

Правила:
- Гейт Manager: grep-проверка маркера `(Role CENSOR)`, вердикта, dispatch id
  и непустых Observations; строка маркера `(Role CENSOR)` обязана нести
  префикс `- YYYY-MM-DD HH:MM:SS — ` (единая метка времени Evidence, §5).
  Нет валидного receipt — переход не считается подтверждённым, план
  не двигается.
- FAIL: роль откатывает handoff-статус, фиксирует причину в
  `### <Role> objections`, правит и повторяет фазу. Максимум 2 FAIL подряд,
  дальше — Owner (стоп-матрица).
- Skip: маленький план допускает `Censor hint: skip (why=<причина>)` одной
  строкой в `## Evidence` вместо receipt; максимум 2 skip'а подряд.
- CENSOR не меняет решения и не заполняет чужие зоны: только сверка,
  мелкие исправления своей зоны и вердикт.

## 5. Дисциплины конвейера

- **Envelope-only диспатч.** Manager шлёт субагенту конверт путей, не
  пересказ задачи:

  ```
  ROLE: <роль>
  PLAN_PATH: docs/plans/<PlanID>_<topic>.md
  PRE_STATUS_LINE: **Status:** <статус на момент диспатча>
  ROLE_DOC: docs/roles/<роль>.md
  TASK: <одно предложение>
  ```

  Субагент читает все файлы сам.
- **PRE_STATUS_LINE** — anti-memory anchor: роль обязана сверить текущий
  статус плана с конвертом; расхождение — стоп и вопрос Manager'у.
- **Notice ≠ mutation truth.** Успех доказывается повторным чтением файла,
  а не словами роли. Manager верит grep'у, не отчёту.
- **Память чата = только reconciliation.** Всё существенное из обсуждения
  обязано попасть в план (Q&A, решения, evidence). Чего нет в файлах —
  не существует.
- **Ответ роли — никогда не одобрение Owner.** `Next: Owner` от роли —
  требование остановиться и спросить человека, не разрешение продолжать.
- **Append-only логи.** `## Evidence`, `## Q&A log`, `## Suggestions log`,
  `## Objections log` — только дописывание; историю не переписываем.
- **Единая метка времени Evidence.** Событийные записи плана несут
  локальное время машины в формате `- YYYY-MM-DD HH:MM:SS — <кто>: <текст>`;
  Manager фиксирует Evidence-узлы: создание плана, гейт-переходы
  (`In progress`, `Merged`), merge-коммит, closeout (`Done`).
- **Fail loud.** Отклонение от шаблона/процесса Manager фиксирует явно и
  возвращает роли; чинить молча чужую работу нельзя.

## 6. Стоп-матрица

| Класс | Признак | Действие |
|---|---|---|
| blocker | Роли нужен ответ для продолжения | Вопрос в `## Q&A log` строкой `to=Owner, blocker:`; работа остановлена |
| plan-gap | План неполон/противоречив | Intake-objections или CENSOR FAIL; откат статуса; докрутка автором секции |
| loop | Одинаковый FAIL/blocker ≥ 2 раз без прогресса | Новый артефакт или закрытый блокер сбрасывает счётчик; иначе — стоп, эскалация Owner с выжимкой |
| scope-creep | Работа требует выхода за Scope | Стоп, вопрос в Q&A; расширение Scope решает Architect (+Owner) |
| broken-evidence | Проверки падают, причина неясна | Стоп, blocker с логом в Evidence |
| lost-handle | Субагент-хендл недоступен | Fresh-диспатч той же роли: план перечитывается, consumed authorization не наследуется |
| owner-silence | Гейт без ответа Owner | Ожидание; ничего не трогать |

## 7. Recovery

- Потерянный handle субагента → не resend: fresh-диспатч с тем же конвертом;
  роль перечитывает план и продолжает с текущего статуса.
- Повторный диспатч не наследует прошлых обещаний роли: истина — только то,
  что записано в файлах.
- Один fresh-диспатч на роль за recovery-цикл; повторный сбой спавна —
  стоп, Owner (blocker: `spawn failed`).
- Ручное терминальное восстановление (когда конвейер встал намертво) —
  Owner-плейбук `docs/playbooks/manual_terminal_recovery.md`.

## 8. Коммиты и ветки

- Коммит делает только Manager и только после явного Owner-«да» на гейте.
- Формат: `type(PlanID): summary`, где type ∈ `feat|fix|docs|chore`,
  PlanID = `YYMMDD_HHMM` из имени плана. Пример: `feat(261111_0315): add review template`.
- Работа идёт в рабочем дереве main (MVP); изменения стейджит Coder, не
  коммитит. Ревью смотрит staged-изменения против HEAD.
- План после merge не удаляется: закрывается статусом `Done`.

## 9. Каталоги и шаблоны

```
docs/plans/     планы (YYMMDD_HHMM_topic.md) + _template.md — единственный шаблон
docs/reviews/   review-артефакты: <PlanID>_review.md + _template_review.md
docs/roles/     роли-доки: architect, planner, coder, reviewer-risk, reviewer-contracts
docs/playbooks/ ручные восстановления
```

Новый артефакт создаётся только из шаблона. Отступление от шаблона —
fail loud, возврат роли.

## 10. One-writer

В репо работает одна активная Manager-сессия. Параллельные сессии не
трогают планы и статусы. Coder — единственный, кто правит код; Manager —
единственный, кто коммитит.
