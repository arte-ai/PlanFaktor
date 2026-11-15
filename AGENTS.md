# Planfaktor — конституция конвейера

Planfaktor — plan-driven конвейер ролей, целиком в ZCode, без рантайма.
Manager — основная ZCode-сессия; роли — субагенты; Owner — человек в чате.
Routing truth — статусы в файлах планов. Память чата — только reconciliation.


## 1. Роли и зоны

| Роль | Носитель | Зона | Ключевые запреты |
|---|---|---|---|
| Owner | человек в чате | Гейт merge; ответы на Q&A | Не пишет план/код |
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
служебного: (a) Evidence-узлы по §5 (создание плана, переходы
`In progress`/`Merged`, merge-коммит, closeout `Done`); (b) дословный
Owner-бриф в `## Evidence` при создании плана; (c) строки `A(owner)` —
перенос ответов Owner из чата в Q&A log; (d) служебные fail-loud записи
отклонений в Evidence; (e) Evidence-записи о событиях собственной зоны
Manager'а по §1 (роутинг, диспатчи, CENSOR-гейты, Owner-гейты) сверх
обязательных узлов §5: grep-валидация CENSOR-перехода и диспатч следующей
роли, открытие/ожидание Owner-гейта (owner-silence), возврат needs-fix
со статусом и составом возврата; (f) usage-строки в `## Token usage`
(формат — комментарий шаблона `docs/plans/_template.md`) — зона Manager'а:
пишет только Manager, сразу после получения результата диспатча/CENSOR,
число — из tool-результата харнесса; (g) черновик секций внешней
(кураторской) сессии по прямому указанию Owner — только в статусе
`Draft`, до первого intake роли; роли перепринимают зоны
(не rubber-stamp); создание фиксируется Evidence-записью. Статусная
строка `**Status:**` — не
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
| `Planning` → `Ready for Coder` | Planner | DoD/Tests заполнены; finalize completion-pass записан; Planner CENSOR OK |
| `Ready for Coder` → `In progress` | Manager | Открытых вопросов к Owner нет (механика ниже) |
| `In progress` → `In review` | Coder | Реализация + evidence; Coder CENSOR OK |
| `In review → In progress` | Coder | needs-fix без Loop signal (итоговый needs-fix ⇔ live-блокер `Current state: open` + `Severity: S1`; возражения — в review-артефакте; Coder ставит статус на intake fixes-итерации) |
| `In review` → `Ready for Coder` | Architect | Reopened-классификация `same-contract reroute` — контракт не менялся; Manager диспатчит Architect по Loop signal до любого перевода статуса |
| `In review` → `Ready for Planner` | Architect | Reopened-классификация `real scope expansion`; Manager диспатчит Architect по Loop signal до любого перевода статуса |
| `In review` → `Merged` | Manager | Оба ревью-вердикта pass; **Owner-гейт merge**; коммит сделан |
| `Merged` → `Done` | Manager | Closeout: `## Follow-ups` плана заполнен; review-артефакт в терминальном состоянии (`current_green`/`historical_reconciled`); нетерминальные `current_red`/`needs_reviewer_rerun` closeout блокируют; harvest-инвентарь de-scoped хвостов пройден — все candidates с судьбой (механика ниже) |
| `*` → `Superseded` | Architect/Owner | План заменён другим; строка-ссылка на преемника |

Reroute-классификация reopened-плана: класс `de-scoped follow-up`
статусного перехода не имеет — Architect материализует его в
`## Follow-ups (deferred)` плана / `docs/followups/backlog.md` (механика
классификации — роль-док Architect'а). Диагностические классы
`stale evidence` и `closed baseline + live blocker split` пересматривают
вердикт ревью (реран по актуальному diff / split блока: закрытая часть —
`historical-fixed`, живая — собственный B-блок со своим классом) до
любого маршрута.

Harvest-инвентарь closeout (третий конъюнкт условия `Merged → Done`,
поверх заполненности `## Follow-ups (deferred)` и терминальности
review-артефакта): Manager инвентаризирует de-scoped хвосты плана по
трём источникам — (а) `## Follow-ups (deferred)`; (б) открытые
Q&A/suggestions/objections логов плана; (в) пункты `## Out of scope`
с формулировками класса «removed from active scope / отдельно потом» —
candidate de-scoped debt. Каждый candidate обязан получить судьбу из
закрытого набора: `promoted` (существует план, backlog-строка с
`plan=<PlanID>`) | `open` (строка backlog `status=open`) | `handled`
(закрыт в текущем merge, disposition — ссылка на коммит/файл) |
`already-tracked-elsewhere` (literal указатель на существующую строку
backlog/план/канон). Судьбы `promoted|open|handled` переиспользуют
статусы row-грамматики followups (`open|promoted|handled|cancelled`,
`docs/followups/_template.md`); `already-tracked-elsewhere` — исход
инвентаризации, не статус строки: новую строку backlog не порождает.
Дедуп — по canonical ref (`id=`/`source_ref` backlog-грамматики,
`#B<N>` review-артефакта), не по формулировке. Candidate без судьбы =
`lost follow-up during harvest`: Manager фиксирует это в Evidence,
`Done` не ставится — пункт `## Out of scope` не может молча потеряться.

Переход `Ready for Coder` → `In progress` — авто-переход Manager'а, без
Owner-гейта: Manager перечитывает `## Q&A log` плана (якорный
`grep -E '^- Q\(' <план>` навигирует по строкам-вопросам; открытость —
по парам Q#n→A#n, грамматика §3 п.4: Q-строки append-only вечны со своим
`status=open`, закрытие живёт в парной A-строке `status=closed`).
Открытый вопрос к Owner — Q#n с `to=Owner` или `needs_owner: yes`, ниже
которой нет парной A#n: стоп по §6; открытых нет — перевод. Вопросы
`to=<роль>` (не к Owner) переход не блокируют. Точка чтения человека —
выход Architect'а: при
переходе `Draft → Ready for Planner` Manager ретранслирует Owner'у блок
«Как я понял задачу» и границы Scope (дословно, информационно, без
подтверждения).

Порядок CENSOR (раздел 4): роль ставит handoff-статус → Manager шлёт
CENSOR-проход в тот же субагент → OK подтверждает переход, FAIL — откат
статуса той же ролью. Manager не двигает план дальше без валидного CENSOR.

Именование планов: `YYMMDD_HHMM_topic.md` (тема — латиницей, слова через
`_`). Порядок очереди = сортировка имён; следующий к исполнению — старейший
план в статусе `Ready for *` / `In progress` / `In review` / `Merged`
(Merged — closeout не откладывается). Один план в активной работе
одновременно.

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
   вопроса: `Q(<роль>#<n>): <текст> to=Owner|to=<роль>, blocker: yes|no,
   needs_owner: yes|no, status=open`; закрытие — парной строкой по
   номеру: `A(<кто>#<n>): <ответ> status=closed, перенесено в <секция>`.
   Открытый вопрос — Q#n, ниже которой нет парной A#n. Не-блокирующий
   вопрос, который решает только Owner (`needs_owner: yes`), роль сама
   не закрывает; закрытие — только ответной парной строкой. Ответ в чате
   закрытием не считается. Исторические планы (до 261113_2121) писались
   без `#<n>` — их открытость читается позиционно.
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
- Fixes: <что исправлено> | Fixes: none (NO FINDINGS; <контент-факты — что искал/проверил>)
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
- Receipt-поля отсутствия: `Fixes:` обязателен всегда — контент либо
  форма отсутствия; голое «ничего» и `NO FINDINGS` без контент-фактов
  (что искал/проверил) невалидны. Для цензорных проходов fixes-итераций
  Coder'а (rN — раунды `**Round:**` ≥ 2 review-артефакта) receipt обязан
  нести метку `Review verdict seen: <Round, вердикт>` — подтверждение,
  что цензор прочитал вердикт review-артефакта последнего Round, из
  которого вытекают fixes; обычные (доревьюерные) цензорные receipt
  метку не несут; сосуществует с deadlock-режимом ниже (подтверждённый
  файлами луп — отдельный случай, друг друга не заменяют).
- CENSOR не меняет решения и не заполняет чужие зоны: только сверка,
  мелкие исправления своей зоны и вердикт.
- Deadlock-режим: при repo-backed повторном loop (повтор подтверждается
  файлами, не памятью чата) пустой receipt запрещён — receipt обязан нести
  `Loop signal` (lineage повтора), ответ «why previous rerun did not break the loop»
  и «extraordinary action» (что сделано сверх обычного чек-листа);
  «дефектов не нашёл» без этих полей в подтверждённом файлами лупе не
  принимается. Новые CENSOR-точки не вводятся: §4 расширяется только
  полями receipt.

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
  `## Objections log`, `## Token usage` — только дописывание; историю
  не переписываем.
- **Единая метка времени Evidence.** Событийные записи плана несут
  локальное время машины в формате `- YYYY-MM-DD HH:MM:SS — <кто>: <текст>`;
  Manager фиксирует Evidence-узлы: создание плана, переходы
  (`In progress`, `Merged`), merge-коммит, closeout (`Done`).
- **Bounded fan-out inventory.** План, меняющий shared-контракт
  (AGENTS.md, `docs/roles/*`, шаблоны, `.zcode/commands/*`,
  `scripts/check_corpus.sh`), до handoff несёт в `## Scope` инвентарь
  затронутых поверхностей: изменяемый носитель + зависимые проверки +
  зависимые доки + известные consumer-пути. Формулировки «audit later»/
  «dependents потом» = plan-gap (стоп-матрица). Архитектор поднимает
  триггер и не отдаёт `Ready for Planner` без инвентаря; Planner
  переносит инвентарь в DoD; Planner CENSOR сверяет наличие.
  Дополняет миграционную запись §3 п.7: та фиксирует факт смены
  digest, инвентарь — полноту затронутых поверхностей.
- **AC-to-test (Coder).** До начала правок по каждому пункту DoD
  фиксируется ровно один исход из закрытого набора: `explicit assertion`
  (новая проверка, ref) | `existing proof` (уже есть в корпусе, ref) |
  `N/A (why=...)` | `reroute` (доказать нельзя без расширения скоупа —
  стоп-линия до правок: возврат роли-владельцу дефекта — DoD/Tests →
  Planner, решения → Architect, objection'ом/вопросом, не молчаливой
  заменой; разграничитель: reroute здесь — исход DoD-пункта у Coder'а
  до правок, не reopened-классификация ревью-возврата из §2). Фиксация —
  append-only в Evidence до заполнения Changes.
- **Assumption-протокол.** Любое допущение Coder'а — строка
  `Assumption: ...` в `## Q&A log` (append-only). Допущение, влияющее
  на Scope/DoD/контракты, — стоп и возврат на Planner (objection/вопрос),
  не молчаливая реализация.
- **Явная форма отсутствия.** Любое обязательное поле плана/ревью несёт
  контент или `N/A (why=...)`; `TBD`/пусто/`UNCONFIRMED` невалидны как
  класс. Специализированные формы отсутствия (`NO QUESTIONS`,
  `NO FOLLOW-UPS — why:`, `plan=none`, `No findings reason:`,
  `Fixes: none (NO FINDINGS; ...)` и другие) старше общей — не
  дублируются и не заменяются ею.
- **Untrusted specialist input.** Утверждения любой роли или субагента
  (цитаты, базы, «уже проверено», digest-значения) — untrusted input:
  не принимаются на веру, а верифицируются против репозитория/первичных
  артефактов тем, кто на них опирается; перенос чужого утверждения в
  свою секцию без сверки — дефект. Отличие от «Notice ≠ mutation truth»:
  то правило — Manager и мутации; это — все роли и любые утверждения,
  включая перепринятие черновиков и перенос ответов Q&A.
- **A/B-фиксация выбора.** Пока выбор между вариантами не сделан —
  развилка в секции решения — открытый Q&A (`status=open`); секция не
  вправе нести «либо/или». Выбор сделан — пункт секции-владельца
  переписывается в финальную формулировку без дизъюнкции (append-only
  логи Q&A/Evidence не переписываются — история выбора остаётся в
  Q&A-паре), отклонённая альтернатива фиксируется строкой
  `rejected alternative: <вариант> — why: <основание>`, добавляются
  1–2 acceptance-пункта, делающие решение проверяемым.
- **Fail loud.** Отклонение от шаблона/процесса Manager фиксирует явно и
  возвращает роли. Не чинить молча чужую зону — для любой роли: нашёл
  дефект чужой зоны — верни владельцу с objections; молчаливая правка
  или молчаливый обход чужой зоны запрещены.

## 6. Стоп-матрица

| Класс | Признак | Действие |
|---|---|---|
| blocker | Роли нужен ответ для продолжения | Вопрос в `## Q&A log` строкой `to=Owner, blocker:` (включая `needs_owner: yes` без закрытия); работа остановлена |
| plan-gap | План неполон/противоречив | Intake-objections или CENSOR FAIL; откат статуса; докрутка автором секции |
| loop: `operational_retry` | Повтор остановки транзиентен: сбой спавна/оверштатный retry, не связанный с содержанием работы | Повтор по §7 допустим; класс повтора фиксируется записью в Evidence |
| loop: `semantic_blocker` | Повтор того же блокера, требующего решения (ответ Owner/правка контракта), а не кода | Вопрос `to=Owner, blocker:`; класс повтора — в Evidence |
| loop: `progress_with_artifact` | Повтор с новым артефактом (review-раунд, фикс с evidence) или с закрытым блокером | Счётчик повторов сбрасывается; класс повтора — в Evidence |
| loop: `real_loop` | Тот же активный пункт + тот же статус + тот же blocker lineage (B-ID) + нет нового артефакта | Стоп, эскалация Owner с выжимкой; слепой реран запрещён |
| loop: `unknown` | Класс повтора не определён | Осторожный дефолт: сначала классифицируй, потом действуй |
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
- Упреждающий контекст-чекпоинт Manager-сессии — плейбук
  `docs/playbooks/manager_snapshot_restart.md`: snapshot между живыми
  сессиями (history/handover, не source of truth; носитель `.tmp/`,
  не коммитится); дополнение к recovery этого раздела — аварийное
  восстановление (потеря хендла, терминальный ступор) остаётся зоной §7.

## 8. Коммиты и ветки

- Коммит делает только Manager и только после явного Owner-«да» на merge-гейте.
- Closeout-хвост: «да» Owner на merge-гейте покрывает и хвост-коммит —
  отдельный коммит сразу после merge-коммита, несущий closeout плана
  (переход `Merged` → `Done` по §2: closeout Evidence-узлы, заполнение
  `## Follow-ups`, статус `Done`); дополнительный Owner-гейт на хвост
  не открывается. Формат: `chore(<PlanID>): closeout tail` — пример:
  `chore(261114_0151): closeout tail`.
- Инвариант pre-merge verify: merge-коммит делается только при свежем
  green-прогоне corpus-линта (`scripts/check_corpus.sh` → `corpus: clean`
  по актуальному дереву); green линта ≠ семантическая приёмка — семантику
  подтверждают два pass-вердикта review и Owner-гейт; текущий failure
  не глушится историческим green — прогон всегда свежий.
- Релизы: выпуск корпуса — аннотированный git-тег `vX.Y.Z` (semver) +
  релиз-нота и переводы `verified → released` в реестре требований;
  режет Manager по явному указанию Owner (версия и момент — решение
  Owner); инвариант — свежий green-прогон corpus-линта на тегаемом
  коммите (fresh-green, симметрично merge); конвенция —
  `docs/releases/README.md`. Релиз — событие вне статусной машины
  планов (§2): молчание Owner ничего не режет (owner-silence, §6).
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
docs/playbooks/ ручные восстановления и регламентная гигиена канона
docs/followups/ backlog техдолга (row-грамматика + derived index)
docs/requirements/  реестр внешних требований (row-грамматика + журнал статусов), регламент, derived-матрица трассируемости
docs/compliance/    комплаенс-маппинги стандартов (предъявляемые клиенту документы)
docs/releases/      релизные ноты (`vX.Y.Z.md` по одной на выпуск) + `_template.md`; конвенция релизного узла — `README.md`
```

Новый артефакт создаётся только из шаблона. Отступление от шаблона —
fail loud, возврат роли.

## 10. One-writer

В репо работает одна активная Manager-сессия. Параллельные сессии не
трогают планы и статусы; исключение — §1(g): кураторская (внешняя)
сессия пишет черновики секций только планов в статусе `Draft` и до
первого intake роли, планы вне `Draft` и статусы не трогает. Coder —
единственный, кто правит код; Manager — единственный, кто коммитит.
