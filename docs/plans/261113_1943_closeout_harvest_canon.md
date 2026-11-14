# Closeout-контур и канон: snapshot-рестарт, harvest, fan-out инвентарь, гигиена канона

**Plan ID:** 261113_1943
**Status:** Merged
**Created:** 2026-11-13
**Owner gates:** merge (`In review` → `Merged`); вопросы `to=Owner` — по мере возникновения

> Шапка — parser-контракт: строки выше grep'аются Manager'ом. Не менять формат.
> Имя файла: `261113_1943_closeout_harvest_canon.md`.

## Как я понял задачу
<!-- owner: architect; 3–7 строк; обязательна при Architect intake -->

Конвейер закрывает план merge'ем, но контур вокруг закрытия слеп: контекст
Manager-сессии не переживает её смерть, closeout инвентаризует только
Follow-ups и терминальность review-артефакта (механика 1642 уже в §2),
не видя Q&A/objections/Out-of-scope хвостов, «нет хвостов» записывается
произвольным кодом причины, а план, меняющий shared-контракт, не обязан
доказывать полноту затронутых поверхностей. Переносим из модели предков
(приватные первоисточники, ссылки исключены из публичного репо)
closeout-контур и гигиену канона: snapshot-плейбук межсессионного
рестарта (history/handover, не source of truth; носитель — некоммитимый
`.tmp`), harvest-инвентарь de-scoped хвостов с обязательной судьбой
каждого пункта (дедуп `#B<N>` активен — 1642 смержен), закрытый enum
причин `NO FOLLOW-UPS`, bounded fan-out inventory для контрактных планов,
два регламентных плейбука гигиены канона (gardening и sweep) под
классификатор инвариантов правки контрактов, правило «Done/Superseded
не оживляем» с критериями нового плана и принцип чтения темы «самый
поздний план + канон». План процессный: правятся контракты, шаблоны
и плейбуки против текущего дерева (C1–C13, selftest 26/26); кода и новых
чеков линта нет. Кураторские зоны переприняты Architect'ом по существу
против контрактов после трёх мерджей (2121/1642/1644), не rubber-stamp.

## Problem
<!-- owner: architect; пронумерованные пункты -->

1. **Контекст Manager-сессии не переживает её завершение.** Manager-сессии
   недолговечны (простаивающие рвутся; возобновление = свежая сессия с
   полным handoff). Routing truth переживает смерть сессии (статусы в
   файлах, §2), но рабочий контекст — что уже прогоняли, working set,
   Branch/HEAD, грабли-инварианты, следующие микро-шаги — теряется целиком
   и восстанавливается повторным чтением корпуса без протокола. §7 покрывает
   потерю субагент-хендла (fresh-диспатч) и ручное терминальное
   восстановление, но не упреждающий контекст-чекпоинт самой
   Manager-сессии. База: `grep -rniE 'snapshot|чекпоинт|контекст.*(рестарт|восстановление)'`
   по AGENTS.md, docs, .zcode, README → 0 совпадений вне черновиков
   (совпадения «чекпоинт» в planfaktor-run/status — только token-учётный
   смысл секции `## Token usage`, не контекст-протокол; перепроверено
   против дерева после трёх мерджей 2026-11-14).
2. **Closeout слеп к хвостам вне `## Follow-ups (deferred)`.** Условие
   `Merged → Done` в текущем §2 (после мерджа 261113_1642) проверяет
   заполненность `## Follow-ups` и терминальность review-артефакта
   (`/planfaktor-run`, шаг `Merged` — «заполнен или `NO FOLLOW-UPS — why:`»
   + `**Artifact state:**`), но инвентаризирует только эти две точки:
   открытые Q&A/suggestions/objections и пункты `## Out of scope`
   с формулировками «removed from active scope / отдельно потом»
   (candidate de-scoped debt) не инвентаризируются:
   `grep -rniE 'de-scoped|harvest|судьб'` по канону → совпадения только
   reroute-класса `de-scoped-followup` (классификация review-возвратов,
   план 1642), инвентаризации closeout-хвостов нет. Хвосты попадали
   в backlog точечной ручной дисциплиной (строки `release-node`,
   `merge-untracked-guard` с source_ref на `#out-of-scope` плана
   261112_2236 — пойманы ручным аудитом), а не правилом closeout: без
   правила потеря молча легальна.
3. **`NO FOLLOW-UPS — why:` — произвольный код.** Комментарий шаблона
   допускает `<код_причины>` без перечня значений; `/planfaktor-run`
   принимает любой текст; plans/README называет форму только в перечне
   форм отсутствия §5 (раздел «Обязательные поля» — токен в списке,
   без грамматики значений), enum не описан нигде.
   Произвольный код не сводим и не проверяем: «нет хвостов» сегодня
   не доказуемая форма отсутствия.
4. **План, меняющий shared-контракт, не несёт инвентаря затронутых
   поверхностей.** §3 п.7 фиксирует факт смены digest'ов, но не полноту:
   какие проверки, доки и consumer-пути зависят от изменённого носителя.
   Формулировка «audit later» в Scope сегодня не план-гэп. База:
   `grep -rniE 'fan-out|инвентар.*(поверхност|проверк)|audit later'` → 0
   по текущему канону (перепроверено после мерджей 2121/1642/1644);
   смерженный план 261113_1642 (a53592b) перечислил затронутые носители
   в Scope добросовестно, но по собственной инициативе, не по правилу:
   дисциплины fan-out в §5 по-прежнему нет.
5. **У канона нет регламентной гигиены.** docs/playbooks/ содержит
   единственный плейбук (терминальное восстановление); §9 описывает каталог
   как «ручные восстановления». Канон растёт планами (каждый процессный
   план дописывает §2/§5/роль-доки), процедур переписывания правил
   в рецепты (trigger + скелет + проверка) и уплотнения после merge-волны
   нет: `grep -rniE 'garden|canon sweep|рецепт'` → 0. Линт держит
   грамматику (C1–C13), энтропию прозы не держит никто — C13
   (грамматика live-блокеров/review-артефактов) прозы не касается.
6. **Терминальность планов неполна.** §2 и plans/README («Финалы»)
   фиксируют «планы не удаляются, закрываются статусом», но жёсткого
   правила «Done/Superseded не оживляем» нет (`grep -rniE 'не ожив|реаним'`
   → 0), как и критериев создания нового плана (смена Goal/deliverable,
   расползание скоупа, улучшения после Done, arch-ревью с невалидацией
   DoD) и сигналов разбиения (>1500 строк / 10+ блоков изменений).
7. **Правка контрактов обходится без классификатора инвариантов.**
   Конституцию и роль-доки правят планами; правила «не удаляй блок,
   меняющий routing/review route/authority/safety» и классификатора
   hard invariant | role-specific delta | procedural noise нет
   (`grep -rniE 'invariant map|классификатор.*инвариант'` → 0). Риск
   реализуется с появлением гигиены (п.5): уплотнение «дублей» без
   классификатора может срезать routing/authority/safety-блок.
8. **Не канонизировано чтение темы.** Правила чтения «тема контура =
   самый поздний план + канон; ранние планы — только по ссылкам» нет
   (`grep -rniE 'effective spec|самый поздний план'` → 0): при разборе
   темы нет запрета пересказывать историю и реставрировать правила
   из ранних планов вместо чтения актуального состояния.

## Solution / Decisions
<!-- owner: architect; решения уровня «что и почему», без детализации -->

1. **Snapshot-checkpoint — плейбук, не второй канон.** Новый
   `docs/playbooks/manager_snapshot_restart.md`: секция «0. Быстрый
   рестарт» (где мы / кому передаём / Next 1–3 / команды copy-paste /
   working set / Branch-HEAD / что уже прогоняли / грабли-инварианты),
   контейнеры FACT/DECISION/CONSTRAINT/NEXT/OPEN, протокол `UNCONFIRMED`
   (не додумывать), маскирование выхлопов `[MASKED: ...]` + команда
   воспроизведения, грабли по схеме Repro → Root cause → Fix → Regression
   test, цепочка Previous snapshot. Жёсткая граница: snapshot —
   history/handover, не source of truth и не cited pointer; durable факт
   промоутируется в план/канон/followups, ссылка на snapshot из канона
   запрещена. Граница vs §7: §7 остаётся владельцем аварийного
   восстановления (потеря хендла, терминальный ступор), snapshot —
   упреждающий контекст-чекпоинт; §7 получает одну строку-указатель,
   дублей механики нет.
2. **Носитель snapshot — `.tmp/snapshots/YYYYMMDD_HHMM_manager_<topic>.md`,
   не коммитится.** Обоснование: `.tmp/` уже исключён из git как «рабочие
   материалы, не входящие в канон» (.gitignore); репо публичный — сессионный
   контекст (working set, маскированные выхлопы, локальные детали) не
   должен входить в публичную историю; §10 one-writer — один активный
   Manager на одной машине, перенос между машинами не нужен; коммит создал
   бы теневой источник истины, противоречащий границе п.1. Потеря `.tmp`
   при чистке допустима: durable факты уже обязаны быть промоучены в корпус.
3. **Harvest-инвентарь closeout (de-scoped debt guard).** Условие
   `Merged → Done` расширяется: перед переходом Manager инвентаризирует
   (а) `## Follow-ups (deferred)`; (б) открытые Q&A/suggestions/objections;
   (в) пункты `## Out of scope` с формулировками класса «removed from
   active scope / отдельно потом» — candidate de-scoped debt. Каждый
   candidate обязан получить судьбу: `promoted` (существует план,
   backlog-строка с `plan=<PlanID>`) | `open` (строка backlog
   `status=open`) | `handled` (закрыт в текущем merge, disposition —
   ссылка на коммит/файл) | `already-tracked-elsewhere` (literal указатель
   на существующую строку backlog/план/канон). Candidate без судьбы =
   `lost follow-up during harvest`: Manager фиксирует это в Evidence,
   `Done` не ставится. Дедуп — по canonical ref (существующие
   `id=`/`source_ref` backlog-грамматики; `#B<N>` из review-артефакта —
   план 261113_1642 смержен a53592b, грамматика live-блокеров уже
   в корпусе и активна), не по формулировке. Судьбы
   `promoted | open | handled` переиспользуют статусы row-грамматики
   followups (`open|promoted|handled|cancelled`,
   `docs/followups/_template.md`); `already-tracked-elsewhere` — исход
   инвентаризации, а не статус строки: literal указатель на существующую
   строку/план/канон, новую строку backlog не порождает. Новая грамматика
   статусов не вводится.
4. **`NO FOLLOW-UPS — why:` — закрытый enum.** `{handled-in-followup |
   already-tracked-elsewhere (с literal указателем) | canon-sync-closed |
   no-remaining-actionable-debt}` вместо произвольного кода; значение вне
   enum невалидно. Носители: комментарий секции `docs/plans/_template.md`,
   грамматика `docs/plans/README.md`, closeout-шаг `/planfaktor-run`.
   Enum — специализированная форма отсутствия для Follow-ups; универсальная
   `N/A (why=...)` (§5 «Явная форма отсутствия», доставлена смерженным
   планом 261113_1644) её не поглощает — §5 канона уже закрепляет
   старшинство специализированных форм («не дублируются и не заменяются
   общей»), enum лишь достраивает перечень значений самой формы
   `NO FOLLOW-UPS — why:`.
5. **Bounded fan-out inventory — дисциплина §5.** План, меняющий
   shared-контракт (AGENTS.md, docs/roles/*, шаблоны,
   `.zcode/commands/*`, `scripts/check_corpus.sh`), до handoff несёт
   в `## Scope` инвентарь: изменяемый носитель + зависимые проверки +
   зависимые доки + известные consumer-пути. Формулировки «audit
   later»/«dependents потом» = plan-gap (стоп-матрица). Архитектор
   поднимает триггер и не отдаёт `Ready for Planner` без инвентаря;
   Planner переносит инвентарь в DoD; Planner CENSOR сверяет наличие.
   Дополняет миграционную запись §3 п.7: та фиксирует факт смены digest,
   инвентарь — полноту затронутых поверхностей.
6. **Invariant map для правки контрактов.** Новый
   `docs/playbooks/contract_edit_invariant_map.md`: классификатор
   hard invariant (routing truth, ownership-зоны, CENSOR/Owner-гейты,
   append-only, one-writer, границы приватности) | role-specific delta |
   procedural noise; правило «не удаляй блок, меняющий
   routing/review route/authority/safety»; сомнение → блок оставить
   и зафиксировать в Evidence плана, почему проза остаётся. Обязателен
   перед gardening/sweep и в планах, правящих контракты.
7. **Doc gardening — регламентный GC.** Новый
   `docs/playbooks/doc_gardening.md`: одна тема, один раздел канона, не
   более 3 файлов правок за сессию (иначе — план); каждое правило
   переписывается в рецепт trigger + скелет + проверка; выход — один
   entrypoint, покрывающий 80% кейсов, минус дубли; всплывшие работы —
   1–3 строки backlog; «сначала рецепт, потом ужесточение линта». Запуск —
   периодический, по решению Owner.
8. **Canon sweep — уплотнение после merge-волны.** Новый
   `docs/playbooks/docs_canon_sweep.md`: после серии мерджей одного
   контура канон (секции конституции, plans/README, lifecycle, роль-доки)
   приводится к «коротко + pointers»: без истории обсуждений,
   Decision/Constraint → 1–5 буллетов + pointer в план/backlog/канон
   (не в snapshot); sweep не создаёт новых правил — только уплотнение,
   изменение правил = план. Линт держит грамматику, энтропию прозы держат
   gardening/sweep.
9. **«Done/Superseded не оживляем» + критерии нового плана.** Новый раздел
   plans/README: терминальный план не реанимируется — продолжение отдельным
   планом со ссылкой на предшественника (для Superseded ссылка уже
   обязательна строкой §2); новый план создаётся, если сменился
   Goal/deliverable, скоуп расползся, после Done появились улучшения,
   arch-ревью потребовал переосмысления (DoD/евиденции невалидны →
   Superseded); сигналы разбиения: >1500 строк / 10+ блоков изменений.
   Имена остаются в общей грамматике `YYMMDD_HHMM_topic.md`
   (таймстемп-очередь сохраняет порядок), связь продолжения — ссылкой
   в тексте нового плана; суффиксы-маркеры не вводятся.
10. **Effective spec — принцип чтения темы.** plans/README: тема контура
    читается из самого позднего плана по этой теме + канона; ранние планы
    открываются только по ссылкам при неясности; история не пересказывается,
    правила не реставрируются из старых планов. Sweep/gardening-плейбуки
    ссылаются на принцип как на норму чтения.
11. **Corpus lint не расширяется.** Новых чеков нет (C13 уже в корпусе —
    доставлен смерженным планом 1642, selftest 26/26; safety-scan — зона
    плана 1944; расширение линта — backlog lint-v2). Совместимость
    с C1–C13: правятся только тексты комментариев шаблона
    (C3/C8-формы секций и owner-меток не трогаются); новые пути плейбуков,
    на которые ссылаются AGENTS.md/README, создаются тем же изменением
    (C9), имена файлов — латиницей; полный прогон линта остаётся зелёным —
    регрессионный инвариант.
12. **Самоприменение.** План сам меняет shared-контракты → сам несёт
    fan-out инвентарь (в Scope) и миграционные записи §3 п.7 по каждому
    изменённому файлу (старый@8hex → новый@8hex, зона Coder).

## Scope
<!-- owner: architect (границы), planner (уточняет); список изменений; пункты, реализующие внешние требования, несут метку [R: <ID>] (ID — из docs/requirements/registry.md) -->

- `AGENTS.md` — §2 (условие `Merged → Done`: harvest-инвентарь, судьбы,
  `lost follow-up during harvest`), §5 (дисциплина bounded fan-out
  inventory), §7 (строка-указатель на snapshot-плейбук: упреждающий
  контекст-чекпоинт, дополнение к recovery), §9 (описание
  `docs/playbooks/` — «ручные восстановления и регламентная гигиена
  канона»).
- `docs/plans/_template.md` — комментарий `## Follow-ups (deferred)`:
  enum причин; комментарий `## Scope`: fan-out инвентарь для планов,
  меняющих shared-контракты.
- `docs/plans/README.md` — closeout-грамматика (инвентарь, судьбы, запрет
  немого de-scope), enum, раздел «Когда создавать новый план» (критерии,
  «не оживляем», сигналы разбиения), принцип чтения темы (п.10).
- `.zcode/commands/planfaktor-run.md` — closeout-шаг: чек-лист
  инвентаризации + enum (новых диспатч-гейтов нет).
- `docs/lifecycle.md` — фаза Merged → Done (инвентарь и судьбы), таблица
  артефактов (+4 плейбука).
- `docs/playbooks/manager_snapshot_restart.md` — новый (п.1–2).
- `docs/playbooks/contract_edit_invariant_map.md` — новый (п.6).
- `docs/playbooks/doc_gardening.md` — новый (п.7).
- `docs/playbooks/docs_canon_sweep.md` — новый (п.8).
- `README.md` — «Куда дальше»: строки новых плейбуков (синхронно с их
  созданием, C9).
- Fan-out инвентарь самого плана (самоприменение п.5): изменяемые
  носители — перечислены выше; зависимые проверки —
  `scripts/check_corpus.sh` полный прогон зелёный (чек не меняется);
  зависимые доки — `README.md`, `docs/lifecycle.md` (в этом же скоупе);
  известные consumer-пути — `/planfaktor-run` (closeout), живой шаблон
  плана (новые планы наследуют enum с момента merge), row-грамматика
  `docs/followups/_template.md` (судьбы `promoted|open|handled`
  переиспользуют существующие статусы, `already-tracked-elsewhere`
  новых строк не порождает; грамматика не меняется).
- Миграционные записи §3 п.7 по каждому изменённому контракту (зона
  Coder).
- Носители: этот план + review-артефакт `docs/reviews/261113_1943_review.md`.

## Out of scope
<!-- owner: architect -->

- Механики плана 261113_1642 (смержен a53592b, статус Done): B<N>/S1–S3,
  Loop signal, reroute-классы, терминальные состояния review-артефакта,
  C13, классы повторных остановок — не вводятся и не меняются; дедуп
  harvest по `#B<N>` активен с merge 1642 (грамматика live-блокеров
  в корпусе), параллельно с `id=`/`source_ref`; расширение условия
  `Merged → Done` композиционально: терминальность артефакта уже
  в текущем §2 (доставлена 1642), harvest-инвентарь ложится поверх
  актуального текста третьим конъюнктом; общие носители (AGENTS.md §2/§5,
  шаблоны, команда) правятся последовательно по очереди планов против
  актуального дерева (то же правило покрывает и более поздние черновики,
  включая 261114_0151).
- Механики плана 261113_1644 (смержен 8274d86, статус Done):
  completion-pass, AC-to-test,
  Assumption-протокол, универсальная `N/A (why=...)`, `Review verdict
  seen`, untrusted specialist input, intake-чеклист — `NO FOLLOW-UPS —
  why=<enum>` остаётся специализированной формой отсутствия, пересечений
  механик нет, только общие носители.
- Механики плана 261113_1944 (SECURITY, safety-scan, pre-merge verify,
  CI): маскирование `[MASKED: ...]`/`<REDACTED>` в snapshot-плейбуке —
  собственная дисциплина плейбука, не замена и не дубль сканера.
- Corpus lint: новые чеки не вводятся; машинная валидация
  судеб/enum/инвентаря — кандидат backlog lint-v2
  (`lint-v2-digest-verify`, `qa-lint`), closeout проверяет Manager по
  чек-листу.
- Роль-доки `docs/roles/*` и агент-обёртки `.zcode/agents/*` — новых
  фазовых механик ролей нет, наследуют из конституции (анти-дрейф).
  Синхронизация роль-док однострочными указателями fan-out отклонена:
  fan-out — сквозная дисциплина уровня §5 двух ролей с носителем
  в грамматике `## Scope` плана, обязанности читаются из конституции
  на каждом intake (§3 п.1), а наличие инвентаря в Scope покрывает
  генерический чек-лист CENSOR «свои секции заполнены
  и непротиворечивы»; асимметрия с 261113_1644 осознана —
  completion-pass это фазовый чек-лист одной роли (носитель —
  роль-док), fan-out — конвейерная дисциплина (носитель — конституция
  + грамматика планов).
- Исторические планы, review-артефакты и логи — append-only;
  ретроспективный harvest уже закрытых планов не проводится (правило п.3
  работает вперёд от merge этого плана).
- Автоматизация snapshot (триггеры, ротация, очистка `.tmp`) — плейбук
  ручной; конвенции хранения сверх цепочки Previous snapshot не вводятся.
- Новые статусы/переходы не вводятся; статусная машина §2 и механика
  Superseded не меняются (дополняется только правилом чтения в
  plans/README).
- Aggregator-планы не вводятся: единый носитель техдолга — существующий
  `docs/followups/backlog.md`.

## Acceptance criteria / DoD
<!-- owner: planner; чек-лист проверяемых исходов; каждый пункт = проверяемое утверждение; пункты, реализующие внешние требования, несут метку [R: <ID>] (ID — из docs/requirements/registry.md) -->

Применяемость (уточнение Planner, смены решений нет): AC-to-test (§5,
план 1644) для этой итерации Coder'а обязателен — до правок по каждому
Dn фиксируется исход из закрытого набора в Evidence. R-DoD: пунктов
с R-метками нет — R-метки в Scope отсутствуют, внешних требований план
не реализует. Все команды — из корня репо. Правки исторических планов,
review-артефактов и append-only логов не выполняются (Out of scope);
harvest-инвентарь и enum работают вперёд от merge этого плана.

- [ ] **D1. AGENTS.md §2 — harvest-инвентарь closeout.** Условие
  `Merged → Done` в таблице §2 расширено третьим конъюнктом поверх
  существующих (Follow-ups заполнен; терминальность артефакта — зона
  1642 не тронута): перед переходом Manager инвентаризирует (а)
  `## Follow-ups (deferred)`; (б) открытые Q&A/suggestions/objections;
  (в) пункты `## Out of scope` с формулировками класса «removed from
  active scope / отдельно потом» — candidate de-scoped debt. Три
  источника перечислены в §2 явно.
- [ ] **D2. AGENTS.md §2 — судьбы candidates.** Текст §2 задаёт
  закрытый набор судеб: `promoted` (существует план, backlog-строка с
  `plan=<PlanID>`) | `open` (строка backlog `status=open`) | `handled`
  (закрыт в текущем merge, disposition — ссылка на коммит/файл) |
  `already-tracked-elsewhere` (literal указатель на существующую строку
  backlog/план/канон); судьбы `promoted|open|handled` переиспользуют
  статусы row-грамматики followups (`open|promoted|handled|cancelled`,
  docs/followups/_template.md), новая грамматика статусов не вводится;
  `already-tracked-elsewhere` — исход инвентаризации, не статус строки:
  новую строку backlog не порождает.
- [ ] **D3. AGENTS.md §2 — lost-код и дедуп.** Candidate без судьбы =
  `lost follow-up during harvest`: Manager фиксирует это в Evidence,
  `Done` не ставится. Дедуп — по canonical ref (`id=`/`source_ref`
  backlog-грамматики, `#B<N>` review-артефакта — план 1642 смержен),
  не по формулировке.
- [ ] **D4. Enum `NO FOLLOW-UPS — why:` — закрытый перечень.**
  `{handled-in-followup | already-tracked-elsewhere (с literal
  указателем) | canon-sync-closed | no-remaining-actionable-debt}`;
  значение вне enum невалидно. Грамматика значений описана во всех
  трёх носителях Solution п.4: комментарий `## Follow-ups (deferred)`
  docs/plans/_template.md, docs/plans/README.md, closeout-шаг
  .zcode/commands/planfaktor-run.md. Роль-доки не правятся (Out of
  scope): их ссылка на форму `NO FOLLOW-UPS — why: <код>` наследует
  значения из enum после merge; универсальная `N/A (why=...)` enum не
  поглощает (старшинство специализированных форм §5 канона уже
  закреплено — новых формулировок о старшинстве не требуется).
- [ ] **D5. AGENTS.md §5 — bounded fan-out inventory.** Новая дисциплина
  §5: план, меняющий shared-контракт (перечень: AGENTS.md,
  docs/roles/*, шаблоны, `.zcode/commands/*`, `scripts/check_corpus.sh`),
  до handoff несёт в `## Scope` инвентарь: изменяемый носитель +
  зависимые проверки + зависимые доки + известные consumer-пути;
  формулировки «audit later»/«dependents потом» = plan-gap (стоп-матрица).
  Дополняет миграционную запись §3 п.7 (та фиксирует факт смены digest,
  инвентарь — полноту затронутых поверхностей).
- [ ] **D6. AGENTS.md §7 — строка-указатель на snapshot-плейбук.** Ровно
  одна строка-указатель на docs/playbooks/manager_snapshot_restart.md
  (упреждающий контекст-чекпоинт, дополнение к recovery); дублей
  механики §7 нет: потеря хендла (fresh-диспатч) и терминальное
  восстановление остаются единственной зоной §7.
- [ ] **D7. AGENTS.md §9 — описание каталога playbooks.** Каталог
  `docs/playbooks/` описан как «ручные восстановления и регламентная
  гигиена канона» (существующее «ручные восстановления» не вырезается).
- [ ] **D8. docs/playbooks/manager_snapshot_restart.md — новый
  (Solution п.1–2).** Содержит: секцию «0. Быстрый рестарт» (где мы;
  кому передаём; Next 1–3; команды copy-paste; working set; Branch/HEAD;
  что уже прогоняли; грабли-инварианты); контейнеры
  FACT/DECISION/CONSTRAINT/NEXT/OPEN; протокол `UNCONFIRMED` (не
  додумывать); маскирование выхлопов `[MASKED: ...]` + команда
  воспроизведения; грабли по схеме Repro → Root cause → Fix →
  Regression test; цепочка Previous snapshot. Границы зафиксированы:
  snapshot — history/handover, не source of truth и не cited pointer;
  durable факт промоутируется в план/канон/followups; ссылка на
  snapshot из канона запрещена. Носитель:
  `.tmp/snapshots/YYYYMMDD_HHMM_manager_<topic>.md`, не коммитится
  (`.tmp/` уже в .gitignore — правилка .gitignore не требуется), потеря
  при чистке допустима. Имя файла латиницей (C9).
- [ ] **D9. docs/playbooks/contract_edit_invariant_map.md — новый
  (Solution п.6).** Содержит классификатор `hard invariant` (routing
  truth, ownership-зоны, CENSOR/Owner-гейты, append-only, one-writer,
  границы приватности) | `role-specific delta` | `procedural noise`;
  правило «не удаляй блок, меняющий routing/review route/authority/
  safety»; сомнение → блок оставить и зафиксировать в Evidence плана,
  почему проза остаётся; обязателен перед gardening/sweep и в планах,
  правящих контракты.
- [ ] **D10. docs/playbooks/doc_gardening.md — новый (Solution п.7).**
  Содержит: одна тема — один раздел канона; не более 3 файлов правок
  за сессию (иначе — план); каждое правило переписывается в рецепт
  trigger + скелет + проверка; выход — один entrypoint, покрывающий
  80% кейсов, минус дубли; всплывшие работы — 1–3 строки backlog;
  «сначала рецепт, потом ужесточение линта»; запуск — периодический,
  по решению Owner.
- [ ] **D11. docs/playbooks/docs_canon_sweep.md — новый (Solution п.8).**
  Содержит: применяется после серии мерджей одного контура; канон
  (секции конституции, plans/README, lifecycle, роль-доки) приводится
  к «коротко + pointers»: без истории обсуждений; Decision/Constraint →
  1–5 буллетов + pointer в план/backlog/канон (не в snapshot); sweep
  новых правил не создаёт — только уплотнение, изменение правил = план;
  ссылается на принцип чтения темы (effective spec, D14) как на норму.
- [ ] **D12. docs/plans/README.md — closeout-грамматика harvest.**
  Синхронно §2/D1–D3: инвентарь трёх источников, судьбы с семантикой
  D2, дедуп по canonical ref, запрет немого de-scope (пункт Out of
  scope не может молча потеряться — без судьбы closeout не проходит),
  `lost follow-up during harvest` — стоп-код.
- [ ] **D13. docs/plans/README.md — раздел «Когда создавать новый
  план» (Solution п.9).** Терминальные планы (`Done`/`Superseded`) не
  реанимируются — продолжение отдельным планом со ссылкой на
  предшественника; критерии нового плана: смена Goal/deliverable,
  расползание скоупа, улучшения после Done, arch-ревью с невалидацией
  DoD/евиденции (→ Superseded); сигналы разбиения: >1500 строк /
  10+ блоков изменений; имена остаются в общей грамматике
  `YYMMDD_HHMM_topic.md` (таймстемп-очередь), связь продолжения —
  ссылкой в тексте нового плана; суффиксы-маркеры не вводятся.
- [ ] **D14. docs/plans/README.md — принцип чтения темы (effective
  spec, Solution п.10).** Тема контура = самый поздний план по этой
  теме + канон; ранние планы открываются только по ссылкам при
  неясности; история не пересказывается, правила не реставрируются из
  старых планов. Носители ссылок на принцип: doc_gardening.md и
  docs_canon_sweep.md (D10/D11).
- [ ] **D15. .zcode/commands/planfaktor-run.md — closeout-чеклист.**
  Строка `Merged` routing-таблицы (шаг 2) дополнена чек-листом
  инвентаризации (три источника D1, судьбы D2, дедуп D3, lost-код)
  и enum-грамматикой D4; существующие элементы строки (терминальность
  `**Artifact state:**`, пост-мердж-аномалия, плейбук
  manual_terminal_recovery.md, Evidence-формат `Done`) сохранены;
  новых диспатч-гейтов нет — строка остаётся одной ячейкой таблицы.
- [ ] **D16. docs/lifecycle.md — фаза closeout и артефакты.** Фаза
  `### Merged → Done` описывает инвентарь и судьбы (синхронно
  §2/D1–D3); таблица `## Артефакты` покрывает 4 новых плейбука по
  имени файла (manager_snapshot_restart, contract_edit_invariant_map,
  doc_gardening, docs_canon_sweep).
- [ ] **D17. README.md — «Куда дальше».** По одной строке на каждый из
  4 новых плейбуков (синхронно с их созданием — C9); существующая
  строка manual_terminal_recovery.md сохранена.
- [ ] **D18. Corpus lint не расширяется (Solution п.11).**
  scripts/check_corpus.sh не изменён (дельта HEAD пуста); новых чеков
  нет; полный прогон зелёный: `corpus: clean`, selftest
  `selftest: 26/26 caught`; C3/C8-формы секций и owner-меток шаблона
  не затронуты (правятся только тексты комментариев).
- [ ] **D19. Границы Out of scope соблюдены.** Не изменены: роль-доки
  docs/roles/*, агент-обёртки .zcode/agents/*,
  docs/followups/_template.md и backlog.md,
  docs/reviews/_template_review.md; статусная машина §2 не расширяется
  (набор статусов и переходов прежний — 13 строк таблицы);
  исторические планы/review-артефакты/логи — append-only.
- [ ] **D20. Миграции §3 п.7 (зона Coder).** В `## Evidence` этого
  плана записана смена digest'ов по каждому изменённому контракту
  §3 п.7 (AGENTS.md, docs/plans/_template.md,
  .zcode/commands/planfaktor-run.md) формой
  `<файл>: <старый>@8hex → <новый>@8hex` с меткой времени; старые =
  базе T0; новые = фактическому `shasum -a 256` после правок.
- [ ] **D21. Самоприменение (Solution п.12).** Fan-out инвентарь
  остаётся в `## Scope` до merge (4 компонента: носители/проверки/
  доки/consumer-пути — присутствует, не удаляется); миграционные
  записи D20 — часть самоприменения.

## Tests / Commands
<!-- owner: planner (задаёт), coder (заполняет факт); каждый DoD-пункт (Dn) покрывается строкой с меткой (Dn); R-DoD — обязательно; при переименованиях/миграциях терминологии — narrow + broad proof: narrow — exact-паттерн нового wording (база «сейчас 0», если якорь различающий), broad — prose-drift старого токена по всем активным носителям с классификацией вхождений (исторические планы и append-only артефакты исключены — там старое имя остаётся вечно) -->

Все команды — из корня репо. T0 прогоняется до правок (база миграций
D20; расхождение с фактом = контракт изменился вне Evidence — стоп
и вопрос Manager'у, §3 п.7); T1–T21 — после правок, до стейджинга
(кроме оговорённых осмотров). Базы «сейчас» сняты Planner'ом
2026-11-14 18:52:29 (Evidence). AC-to-test: Coder фиксирует исход по
каждому Dn до правок (§5). R-Tests: не заданы — R-DoD отсутствуют.

- **(D20) T0 — база digest'ов до правок:**
  `shasum -a 256 AGENTS.md README.md docs/plans/_template.md docs/plans/README.md docs/lifecycle.md .zcode/commands/planfaktor-run.md scripts/check_corpus.sh`
  → 7 строк; первые 8 hex совпадают с: AGENTS.md@3b937eed,
  README.md@3e858258, docs/plans/_template.md@f7d468cd,
  docs/plans/README.md@a170ba70, docs/lifecycle.md@8292798e,
  .zcode/commands/planfaktor-run.md@409b3afa,
  scripts/check_corpus.sh@8cf01b9f (последний — контрольный, не
  меняется: D18). «Старые» для Evidence-миграций D20 — первые шесть.
- **(D1) T1:** `awk '/^## 2/,/^## 3/' AGENTS.md | grep -c 'harvest'` → ≥1 (база 0);
  same-диапазон `grep -c 'Out of scope'` → ≥1 (база 0);
  `grep -c 'suggestions'` → ≥1 (база 0);
  `grep -c 'objections'` → ≥1 (база 0);
  `grep -cF 'Follow-ups (deferred)'` → ≥1 (база 1 — остаётся).
- **(D2) T2:** в `awk '/^## 2/,/^## 3/' AGENTS.md`:
  `grep -c 'promoted'` → ≥1 (база 0);
  `grep -c 'handled'` → ≥1 (база 0);
  `grep -c 'already-tracked-elsewhere'` → ≥1 (база 0);
  `grep -cF 'plan=<PlanID>'` → ≥1 (база 0);
  `grep -c 'followups'` → ≥1 (база 1 — переиспользование row-грамматики упомянуто).
- **(D3) T3:** в §2-диапазоне AGENTS.md:
  `grep -c 'lost follow-up during harvest'` → ≥1 (база 0);
  `grep -c 'source_ref'` → ≥1 (база 0);
  `grep -cF '#B<N>'` → ≥1 (база 0).
- **(D4) T4:** `for f in docs/plans/_template.md docs/plans/README.md .zcode/commands/planfaktor-run.md; do for t in handled-in-followup already-tracked-elsewhere canon-sync-closed no-remaining-actionable-debt; do grep -q -- "$t" "$f" || echo "MISSING: $t in $f"; done; done; echo 'enum OK'`
  → вывод ровно `enum OK` (база всех 12 пар — 0);
  роль-доки не тронуты: `grep -c 'NO FOLLOW-UPS' docs/roles/planner.md` → 1 и `grep -c 'NO FOLLOW-UPS' docs/roles/coder.md` → 1 (базы 1/1).
- **(D5) T5:** `awk '/^## 5/,/^## 6/' AGENTS.md | grep -c 'fan-out'` → ≥1 (база 0);
  same-диапазон `grep -c 'audit later'` → ≥1 (база 0);
  `grep -c 'check_corpus'` → ≥1 (база 0);
  `grep -c 'инвентар'` → ≥1 (база 0).
- **(D6) T6:** `awk '/^## 7/,/^## 8/' AGENTS.md | grep -c 'manager_snapshot_restart'` → ровно 1 (одна строка-указатель; база 0);
  same-диапазон `grep -c 'fresh-диспатч'` → 2 (база 2 — механика §7 не задублирована и не вырезана).
- **(D7) T7:** `awk '/^## 9/,/^## 10/' AGENTS.md | grep -c 'регламентная гигиена'` → ≥1 (база 0);
  same-диапазон `grep -c 'ручные восстановления'` → ≥1 (база 1).
- **(D8) T8:** `test -f docs/playbooks/manager_snapshot_restart.md` → exit 0;
  `for t in 'Быстрый рестарт' FACT DECISION CONSTRAINT NEXT OPEN UNCONFIRMED Repro 'Root cause' 'Regression test' 'Previous snapshot' '.tmp/snapshots' 'source of truth' 'промоут'; do grep -q -- "$t" docs/playbooks/manager_snapshot_restart.md || echo "MISSING: $t"; done; echo 'snapshot OK'` → вывод ровно `snapshot OK`;
  `grep -qF '[MASKED:' docs/playbooks/manager_snapshot_restart.md` → exit 0;
  `grep -n '.tmp' .gitignore` → непусто (база — `.tmp/` уже исключён; правка .gitignore не требуется).
- **(D9) T9:** `test -f docs/playbooks/contract_edit_invariant_map.md` → exit 0;
  `for t in 'hard invariant' 'role-specific delta' 'procedural noise' 'routing' 'append-only' 'gardening' 'sweep' 'Evidence' 'сомнени'; do grep -q -- "$t" docs/playbooks/contract_edit_invariant_map.md || echo "MISSING: $t"; done; echo 'invariant OK'` → вывод ровно `invariant OK`.
- **(D10) T10:** `test -f docs/playbooks/doc_gardening.md` → exit 0;
  `for t in 'рецепт' 'trigger' 'скелет' 'проверк' 'entrypoint' '80%' 'не более 3' 'backlog' 'ужесточение' 'Owner'; do grep -q -- "$t" docs/playbooks/doc_gardening.md || echo "MISSING: $t"; done; echo 'gardening OK'` → вывод ровно `gardening OK`.
- **(D11) T11:** `test -f docs/playbooks/docs_canon_sweep.md` → exit 0;
  `for t in 'указател' '1–5' 'новых правил' 'merge' 'plans/README'; do grep -q -- "$t" docs/playbooks/docs_canon_sweep.md || echo "MISSING: $t"; done; echo 'sweep OK'` → вывод ровно `sweep OK`;
  ссылка на норму чтения из gardening: `grep -q 'plans/README' docs/playbooks/doc_gardening.md` → exit 0 (принцип effective spec — D14).
- **(D12) T12:** `grep -c 'harvest' docs/plans/README.md` → ≥1 (база 0);
  `grep -c 'candidate' docs/plans/README.md` → ≥1 (база 0);
  `grep -c 'promoted' docs/plans/README.md` → ≥1 (база 0);
  `grep -c 'судьб' docs/plans/README.md` → ≥2 (база 2 — вхождения 1642 сохраняются, closeout-текст добавляет);
  `grep -c 'молча' docs/plans/README.md` → ≥1 (база 0 — запрет немого de-scope).
- **(D13) T13:** `grep -c 'не оживляем' docs/plans/README.md` → ≥1 (база 0);
  `grep -c '1500'` → ≥1 (база 0);
  `grep -c '10+'` → ≥1 (база 0);
  `grep -c 'Superseded'` → ≥2 (база 2);
  `grep -c 'YYMMDD_HHMM'` → ≥2 (база 2).
- **(D14) T14:** `grep -c 'самый поздний план' docs/plans/README.md` → ≥1 (база 0);
  `grep -c 'Loop signal' docs/plans/README.md` → 7 (база 7 — блок live-блокеров 1642 не тронут).
- **(D15) T15:** `grep 'Closeout: проверь' .zcode/commands/planfaktor-run.md` → ровно 1 строка (routing-ячейка `Merged`); на этой строке:
  `grep -c 'инвентар'` → ≥1 (база 0);
  `grep -c 'судьб'` → ≥1 (база 0);
  `grep -c 'harvest'` → ≥1 (база 0);
  `grep -c 'canon-sync-closed'` → ≥1 (база 0);
  `grep -c 'Artifact state'` → 1 (база 1);
  `grep -c 'manual_terminal_recovery'` → 1 (база 1);
  `grep -c 'NO FOLLOW-UPS'` → 1 (база 1);
  новых диспатч-гейтов нет: `grep -c 'Review verdict seen' .zcode/commands/planfaktor-run.md` → 1 (база 1 — прочий текст команды не разросся диспатчами; осмотр diff Coder'ом — в Changes).
- **(D16) T16:** `sed -n '/^### Merged → Done/,/^## Артефакты/p' docs/lifecycle.md | grep -c 'судьб'` → ≥1 (база 0);
  same-диапазон `grep -c 'инвентар'` → ≥1 (база 0);
  `for n in manager_snapshot_restart contract_edit_invariant_map doc_gardening docs_canon_sweep; do sed -n '/^## Артефакты/,/^## Гейты/p' docs/lifecycle.md | grep -q "$n" || echo "MISSING: $n"; done; echo 'artifacts OK'` → вывод ровно `artifacts OK` (база 0).
- **(D17) T17:** `for n in manager_snapshot_restart contract_edit_invariant_map doc_gardening docs_canon_sweep; do sed -n '/^## Куда дальше/,$p' README.md | grep -q "$n" || echo "MISSING: $n"; done; echo 'readme OK'` → вывод ровно `readme OK` (база 0);
  `sed -n '/^## Куда дальше/,$p' README.md | grep -c 'manual_terminal_recovery'` → 1 (база 1).
- **(D18) T18:** `git diff --name-only HEAD -- scripts/check_corpus.sh` → пустой вывод;
  `scripts/check_corpus.sh` → последняя строка `corpus: clean`, exit 0;
  `scripts/check_corpus.sh --selftest` → последняя строка `selftest: 26/26 caught`, exit 0.
- **(D19) T19:** `git diff --name-only HEAD` на момент handoff Coder'а (до пост-стейджинговых append-only записей Manager'а/ревьюеров) → ровно 11 путей: AGENTS.md, README.md, docs/plans/_template.md, docs/plans/README.md, docs/lifecycle.md, .zcode/commands/planfaktor-run.md, docs/playbooks/manager_snapshot_restart.md, docs/playbooks/contract_edit_invariant_map.md, docs/playbooks/doc_gardening.md, docs/playbooks/docs_canon_sweep.md, docs/plans/261113_1943_closeout_harvest_canon.md;
  `git diff --name-only HEAD -- docs/roles .zcode/agents docs/followups docs/reviews/_template_review.md` → пустой вывод;
  `awk '/^## 2/,/^## 3/' AGENTS.md | grep -c '^|'` → 13 (база 13 — статусная машина не расширяется; дельта строки `Merged → Done` — расширение условия, не новый переход; осмотр `git diff HEAD -- AGENTS.md` в Changes).
- **(D20) T20:** `grep -nE '@[0-9A-Fa-f]{8}[^0-9A-Fa-f]*→[^0-9A-Fa-f]*@[0-9A-Fa-f]{8}' docs/plans/261113_1943_closeout_harvest_canon.md` → ≥3 строк в `## Evidence`, каждая несёт имя контракта (AGENTS.md, _template.md, planfaktor-run.md) и метку времени;
  повторный `shasum -a 256 AGENTS.md docs/plans/_template.md .zcode/commands/planfaktor-run.md` → все 3 значения отличаются от базы T0 и совпадают с «новыми» из Evidence-миграций.
- **(D21) T21:** `awk '/^## Scope/,/^## Out of scope/' docs/plans/261113_1943_closeout_harvest_canon.md | grep -c 'Fan-out инвентарь'` → ≥1 (база 1 — инвентарь самоприменения не удалён до merge).

Факты прогонов (Coder, 2026-11-14, все команды — из корня репо, выводы сняты с диска):

- (T0) до правок (19:04:18): 7/7 digest совпали с базой Planner'а — AGENTS.md@3b937eed, README.md@3e858258, docs/plans/_template.md@f7d468cd, docs/plans/README.md@a170ba70, docs/lifecycle.md@8292798e, .zcode/commands/planfaktor-run.md@409b3afa, контрольный scripts/check_corpus.sh@8cf01b9f; дрейфа нет.
- (T1) §2 AGENTS.md: harvest=2, Out of scope=2, suggestions=1, objections=1, Follow-ups (deferred)=3 — все ≥1.
- (T2) §2 AGENTS.md: promoted=3, handled=3, already-tracked-elsewhere=2, plan=<PlanID>=1, followups=3 — все ≥1.
- (T3) §2 AGENTS.md: lost follow-up during harvest=1, source_ref=1, #B<N>=1 — все ≥1.
- (T4) вывод ровно `enum OK` (0 строк MISSING из 12 пар токен×носитель); роль-доки не тронуты: planner.md=1, coder.md=1.
- (T5) §5 AGENTS.md: fan-out=1, audit later=1, check_corpus=1, инвентар=4 — все ≥1.
- (T6) §7 AGENTS.md: manager_snapshot_restart=1 (ровно 1), fresh-диспатч=2 (ровно 2).
- (T7) §9 AGENTS.md: регламентная гигиена=1, ручные восстановления=1 — оба ≥1.
- (T8) `test -f` exit 0; вывод ровно `snapshot OK` (14/14 якорей); `grep -qF '[MASKED:'` exit 0; `grep -n '.tmp' .gitignore` → строка 2 `.tmp/` (правка .gitignore не потребовалась).
- (T9) `test -f` exit 0; вывод ровно `invariant OK` (9/9 якорей; потребовалась 1 итерация — якорь «сомнени» изначально был с заглавной, формулировка правила переписана в своей зоне).
- (T10) `test -f` exit 0; вывод ровно `gardening OK` (10/10 якорей; 1 итерация — «не более 3» переведён из начала строки внутрь).
- (T11) `test -f` exit 0; вывод ровно `sweep OK` (5/5 якорей); `grep -q 'plans/README' docs/playbooks/doc_gardening.md` exit 0.
- (T12) docs/plans/README.md: harvest=2, candidate=1, promoted=4, судьб=5 (≥2), молча=1.
- (T13) docs/plans/README.md: не оживляем=1, 1500=1, 10+=1, Superseded=5 (≥2), YYMMDD_HHMM=3 (≥2).
- (T14) docs/plans/README.md: самый поздний план=1; Loop signal=7 (ровно 7 — блок live-блокеров 1642 не тронут).
- (T15) `grep 'Closeout: проверь'` → ровно 1 строка; на ней: инвентар=1, судьб=1, harvest=1, canon-sync-closed=1, Artifact state=1, manual_terminal_recovery=1, NO FOLLOW-UPS=1; файл: Review verdict seen=1 (диспатч-гейты не разрослись).
- (T16) диапазон `### Merged → Done`..`## Артефакты`: судьб=3, инвентар=1; вывод ровно `artifacts OK` (4/4 плейбука в таблице артефактов).
- (T17) вывод ровно `readme OK` (4/4 плейбука в «Куда дальше»); manual_terminal_recovery=1.
- (T18) `git diff --name-only HEAD -- scripts/check_corpus.sh` → пусто; `scripts/check_corpus.sh` → `corpus: clean`, exit 0 (OK C1–C13); `scripts/check_corpus.sh --selftest` → `selftest: 26/26 caught`, exit 0.
- (T19) осмотр до стейджинга: дельта AGENTS.md — 37 вставок/2 замены (строка таблицы `Merged → Done` и строка §9 каталога; расширение условия, не новый переход — строк таблицы §2 `^\|` = 13), дельта .zcode/commands/planfaktor-run.md — 1 вставка/1 замена (только routing-строка `Merged`, новых диспатч-гейтов нет); после стейджинга `git diff --name-only HEAD` → ровно 11 путей, запретные зоны (docs/roles, .zcode/agents, docs/followups, docs/reviews/_template_review.md) — пусто (полные списки в Evidence).
- (T20) `grep -nE '@[0-9A-Fa-f]{8}[^0-9A-Fa-f]*→[^0-9A-Fa-f]*@[0-9A-Fa-f]{8}'` → 3 миграционные строки в `## Evidence` (AGENTS.md, _template.md, planfaktor-run.md, с метками времени); повторный `shasum -a 256`: AGENTS.md@e6c8eec4, docs/plans/_template.md@14fa8cbe, .zcode/commands/planfaktor-run.md@ccf9685b — все 3 отличаются от базы T0 и совпадают с Evidence-миграциями.
- (T21) `awk '/^## Scope/,/^## Out of scope/' … | grep -c 'Fan-out инвентарь'` → 1 (≥1 — инвентарь самоприменения в Scope, не удалён).

## Changes (by area)
<!-- owner: coder; фактические изменения по областям; заполняется в ходе работы -->

- **AGENTS.md** — §2: строка таблицы `Merged → Done` дополнена конъюнктом
  «harvest-инвентарь de-scoped хвостов пройден — все candidates с судьбой
  (механика ниже)» (расширение условия, не новый переход — строк таблицы
  по-прежнему 13, осмотр diff: 37 вставок/2 замены); после
  reroute-классификационного абзаца добавлен абзац «Harvest-инвентарь
  closeout» — три источника (Follow-ups (deferred); открытые
  Q&A/suggestions/objections; пункты `## Out of scope` класса «removed
  from active scope / отдельно потом»), судьбы promoted/open/handled/
  already-tracked-elsewhere с переиспользованием row-грамматики followups,
  дедуп по canonical ref (id=/source_ref/#B<N>), lost-код. §5: новый
  пункт «Bounded fan-out inventory» (перечень shared-контрактов, 4
  компонента инвентаря, «audit later» = plan-gap, роли
  Architect/Planner, связь с §3 п.7). §7: одна строка-указатель на
  docs/playbooks/manager_snapshot_restart.md (последний пункт; механика
  §7 не задублирована — fresh-диспатч остаётся ровно 2 вхождения). §9:
  описание каталога playbooks расширено до «ручные восстановления
  и регламентная гигиена канона».
- **docs/plans/_template.md** — правлены только тексты комментариев:
  `## Scope` дополнен требованием fan-out инвентаря для планов, меняющих
  shared-контракты (перечень носителей, 4 компонента, «audit later» =
  plan-gap); `## Follow-ups (deferred)` дополнен enum-грамматикой
  `NO FOLLOW-UPS — why:` (4 значения, ссылка на грамматику в
  plans/README, невалидность вне enum). C3/C8-формы секций и
  owner-метки не тронуты.
- **docs/plans/README.md** — «Обязательные поля»: новый абзац с закрытым
  enum `NO FOLLOW-UPS — why:` (4 значения с краткой семантикой; старшинство
  специализированных форм сохранено). Новый раздел «Closeout: harvest
  de-scoped хвостов» (инвентарь трёх источников, судьбы, дедуп по
  canonical ref, запрет немого de-scope, lost-код, работа вперёд).
  Новый раздел «Когда создавать новый план» («не оживляем», 4 критерия,
  сигналы разбиения >1500 строк/10+ блоков, имена без суффиксов,
  связь ссылкой в тексте). Новый раздел «Чтение темы: effective spec»
  (самый поздний план + канон; ссылки на gardening/sweep-плейбуки).
  Блок live-блокеров 1642 не тронут (Loop signal = 7).
- **.zcode/commands/planfaktor-run.md** — routing-строка `Merged` (ячейка
  `Closeout: проверь`) расширена enum-грамматикой `NO FOLLOW-UPS — why:`
  и harvest-чек-листом (три источника, судьбы с семантикой, дедуп,
  lost-код, запрет немого de-scope); сохранены: терминальность
  `**Artifact state:**` (1 вхождение в строке), пост-мердж-аномалия,
  плейбук manual_terminal_recovery.md, Evidence-формат `Done`. Осмотр
  diff: дельта файла — ровно 1 вставка/1 замена (только эта строка),
  новых диспатч-гейтов и внетабличного текста нет; pipes внутри ячеек
  не используются (разделители enum — запятые).
- **docs/lifecycle.md** — фаза `### Merged → Done` дополнена
  harvest-инвентарём и судьбами (синхронно §2/D1–D3); таблица
  `## Артефакты` — 4 новые строки (manager_snapshot_restart,
  contract_edit_invariant_map, doc_gardening, docs_canon_sweep).
- **docs/playbooks/manager_snapshot_restart.md** — новый плейбук (D8):
  секция «0. Быстрый рестарт» (где мы/кому передаём/Next 1–3/команды
  copy-paste/working set/Branch-HEAD/что уже прогоняли/грабли),
  контейнеры FACT/DECISION/CONSTRAINT/NEXT/OPEN, протокол UNCONFIRMED,
  маскирование `[MASKED: ...]` + команда воспроизведения, грабли по
  схеме Repro → Root cause → Fix → Regression test, цепочка Previous
  snapshot, границы (history/handover, не source of truth, запрет
  cited pointer, промоушен durable-фактов), носитель `.tmp/snapshots/`,
  не коммитится.
- **docs/playbooks/contract_edit_invariant_map.md** — новый плейбук (D9):
  классификатор hard invariant (routing truth, ownership-зоны,
  CENSOR/Owner-гейты, append-only, one-writer, границы приватности) |
  role-specific delta | procedural noise; правило «не удаляй блок,
  меняющий routing/review route/authority/safety»; при сомнении блок
  остаётся + фиксация в Evidence; обязателен перед gardening/sweep
  и в планах, правящих контракты. Одна итерация в своей зоне: якорь
  «сомнени» переведён в строчный регистр перепиской формулировки
  (первоначально «Сомнение» с заглавной — T9 не матчился).
- **docs/playbooks/doc_gardening.md** — новый плейбук (D10): одна тема —
  один раздел; не более 3 файлов правок за сессию (иначе план); рецепт
  trigger + скелет + проверка; один entrypoint на 80% кейсов, минус
  дубли; всплывшие работы — 1–3 строки backlog; «сначала рецепт, потом
  ужесточение линта»; запуск — только по решению Owner; ссылки на
  effective spec (plans/README) и invariant map. Итерация: «не более 3»
  переведён внутрь строки (регистр якоря T10).
- **docs/playbooks/docs_canon_sweep.md** — новый плейбук (D11): после
  серии merge одного контура; «коротко + pointers» без истории
  обсуждений; Decision/Constraint → 1–5 буллетов + pointer (не в
  snapshot); новых правил не создаёт — только уплотнение, изменение
  правил = план; effective spec как норма чтения; границы (invariant
  map, линт до/после, append-only не трогается).
- **README.md** — «Куда дальше»: 4 новые строки-плейбука (синхронно
  с созданием, C9); строка manual_terminal_recovery.md сохранена.
- **docs/plans/261113_1943_closeout_harvest_canon.md** (сам план):
  intake-записи в Q&A log, AC-to-test в Evidence (до Changes), факты
  прогонов T0–T21 в Tests (своя зона — тексты T-команд Planner'а не
  переписаны), миграции §3 п.7 (3 контракта), Changes (эта секция),
  Evidence-записи, статус `In review`. DoD-чекбоксы не тронуты (зона
  Planner — закрывает по фактам); секции Architect/Planner не правлены;
  fan-out инвентарь самоприменения остался в Scope (D21).

## Evidence (chronological, append-only)
<!-- owner: все роли + CENSOR; событийные записи с датой и локальным временем `- YYYY-MM-DD HH:MM:SS — <кто>: <текст>`; CENSOR-receipt по формату конституции -->

- 2026-11-13 19:43:42 — Manager: план создан из шаблона по указанию Owner (черновик; сравнение с дополнительными источниками проведено куратором, механики отобраны)
- 2026-11-13 19:46:45 — Architect: фаза начата, контракты прочитаны
- 2026-11-13 21:26:25 — Architect: добавка по итогам аудита черновиков — уточнение судеб в Solution п.3 (already-tracked-elsewhere — исход инвентаризации, не статус row-грамматики) и оговорка о несинхронизации роль-док в Out of scope
- 2026-11-14 18:33:21 — Manager: Owner-резюма Draft — диспатч Architect (PHASE=work) на перепринятие кураторских зон по существу, не rubber-stamp; контракты изменились тремя мерджами (720519f/2121, a53592b/1642, 8274d86+2d0a9f5+ec358f4/1644: AGENTS.md@7ec6d0f4→3b937eed, architect.md@73ace930→f6cd38e4 — смены зафиксированы Evidence тех планов, §3 п.7): свежий intake по текущим digest'ам; устаревшие факты зон (ссылки на «соседние черновики 1642/1644», «последний чек C12», «дедуп #B<N> после merge 1642») сверить против текущего дерева — 1642/1644 смержены, C13 существует
- 2026-11-14 18:38:23 — Architect: перепринятие кураторских зон против текущего дерева — свержка фактов по мерджам подтверждена (git log: 720519f/a53592b+closeout/8274d86+2d0a9f5+ec358f4; статусы 2121/1642/1644 = Done, 1944 = Draft; C13 в check_corpus.sh, selftest 26/26; `#B<N>` — живая грамматика review-шаблона/plans/README; `.tmp/` в .gitignore; playbooks — один файл). Исправлены устаревшие факты своих секций: Problem п.1 (уточнение «чекпоинт» = token-учёт), Problem п.2 (§2 уже с терминальностью 1642; grep-база de-scoped уточнена до reroute-класса), Problem п.4 (1642 смержен, дисциплины fan-out в §5 нет), Solution п.3 (`#B<N>` активен, не «после мерджа»), Solution п.4 (N/A — канон §5, старшинство специализированных форм закреплено), Solution п.11 (C13 в корпусе, C1–C13, selftest 26/26), Out of scope п.1 (дедуп активен; композиция поверх текущего §2; очередь покрывает и 261114_0151), п.2 (1644 смержен). Решения и границы не изменены — состав механик устоял сверку
- 2026-11-14 18:38:23 — Architect: фаза завершена — понимание/проблема/решения/границы заполнены и переприняты; открытых вопросов к Owner нет; handoff: **Status:** Ready for Planner
- 2026-11-14 18:41:55 — (Role CENSOR) OK: Ready for Planner validated; current=true
Censor dispatch id: censor:architect:261114_183945
Observations:
- Second opinion: план перечитан с диска (не из памяти): шапка `**Status:** Ready for Planner` (строка 4) = PRE_STATUS_LINE конверта; Plan ID 261113_1943 согласован с именем файла; Q&A log: три intake + девять явных ответов, открытых Q(...) нет; свои секции заполнены. Контрсверка цитат зон против дерева: plans/README:75 действительно называет `NO FOLLOW-UPS — why:` в перечне форм отсутствия §5 (без грамматики значений) — претензия Problem п.3 «вообще не описывает» была неточна; check_corpus.sh — C1–C13, selftest 26/26 (строки 27, 63–70) — «(C1–C12)» в Problem п.5 было устаревшим; Solution п.3 (`#B<N>` активен: review-шаблон:120–121,134 + plans/README «Грамматика live-блокеров»:130–135), Solution п.4 (§5 «Явная форма отсутствия» — дословное старшинство специализированных форм), Solution п.11, Out of scope п.1–2 (a53592b/8274d86 в git log; 1642/1644 = Done) — подтверждены без правок
- Counterfactuals considered: (а) мог ли рабочий проход пропустить ещё дрейф после мерджей — да, пропустил ровно два места (Problem п.3, п.5): grep по плану на `C12|соседн|черновик|после мерджа` выявил их и подтвердил, что остальные совпадения — исторические append-only записи Evidence/Q&A и осознанные ссылки на живые черновики (1944, 261114_0151); (б) мог ли я задеть чужие зоны — плейсхолдеры DoD/Tests/Changes и Token usage сверены построчно: нет записей Architect вне моих секций; (в) могла ли правка зон сломать lint — полный прогон после fixes повторён: corpus clean; (г) противоречие Solution п.4 (enum) с §5 — проверено дословно: §5 перечисляет `NO FOLLOW-UPS — why:` среди специализированных форм и объявляет их старше общей — конфликтов нет, enum лишь достраивает значения
- Addendum (new angle): сверена полнота самоприменения — fan-out инвентарь в Scope присутствует (носители/проверки/доки/consumer-пути) и покрывает все четыре новых плейбука + три контракта; проверено, что «Как я понял задачу» не обещает ничего вне Solution/Scope (терминология сверена: судьбы/enum/инвентарь/плейбуки — совпадает носителями); форматная машинная читаемость шапки после правок не менялась (строки 1–9 не тронуты)
- Fixes: Problem п.3 — «plans/README форму вообще не описывает» заменено точной фактикой (называет токен в перечне §5 без грамматики значений, enum не описан нигде); Problem п.5 — «(C1–C12)» → «(C1–C13)» с оговоркой, что C13 прозы не касается; косметическая опечатка «свержка» в Evidence 18:38:23 не правится — лог append-only
- Final censor verdict: OK
- 2026-11-14 18:52:29 — Planner: intake записан, статус Planning (§2); сняты базы «сейчас» для инвариантных якорей Tests (untrusted-сверка утверждений Architect против дерева: followups/_template.md — `status=open|promoted|handled|cancelled`, already-tracked-elsewhere среди статусов нет — подтверждено; check_corpus.sh — C1–C13, selftest 26/26; строка closeout `/planfaktor-run` — routing-таблица, ячейка `Merged`; `.gitignore` — `.tmp/`; playbooks — один файл): digest'ы до правок — AGENTS.md@3b937eed, README.md@3e858258, docs/plans/_template.md@f7d468cd, docs/plans/README.md@a170ba70, docs/lifecycle.md@8292798e, .zcode/commands/planfaktor-run.md@409b3afa (контрольный неизменяемый — scripts/check_corpus.sh@8cf01b9f); grep-базы — §2 AGENTS: harvest=0, Out of scope=0, suggestions=0, objections=0, promoted=0, handled=0, already-tracked-elsewhere=0, lost follow-up during harvest=0, source_ref=0, #B<N>=0, plan=<PlanID>=0, строк таблицы `^\|`=13, fresh-диспатч=2; §5: fan-out=0, audit later=0, check_corpus=0, инвентар=0; §7: snapshot=0, manager_snapshot_restart=0; §9: регламентная гигиена=0, ручные восстановления=1; _template.md: 4 enum-токена=0, fan-out=0, NO FOLLOW-UPS=1; plans/README: enum-токены=0, не ожив=0, 1500=0, 10+=0, самый поздний план=0, harvest=0, candidate=0, молча=0, Loop signal=7, судьб=2, Superseded=2, YYMMDD_HHMM=2; planfaktor-run closeout-строка (`Closeout: проверь`): инвентар=0, harvest=0, судьб=0, enum=0, Artifact state=1, manual_terminal_recovery=1, NO FOLLOW-UPS=1, Review verdict seen (файл)=1; lifecycle `### Merged → Done`: судьб=0, инвентар=0, `## Артефакты`: имена 4 плейбуков=0; README «Куда дальше»: имена 4 плейбуков=0, manual_terminal_recovery=1; git: HEAD ec358f4, untracked — 3 Draft-плана очереди (штатно). Базы воспроизведены в T0–T21
- 2026-11-14 18:57:11 — Planner: finalize completion-pass (§2, до простановки статуса) — второй проход по DoD/Tests «глазами Coder и Reviewer». Вопрос 1 (что придётся угадывать / где блокер переживёт handoff): контент всех правок задан дословно Solution 1–12 (enum-значения, судьбы, составы плейбуков, критерии); микро-структура (ячейка таблицы vs абзац в §2, позиция раздела в plans/README, форма строки таблицы артефактов) — зона Coder'а по 1644-позитивной зоне, тесты T1–T3/T12–T16 сформулированы по §-диапазонам и именам, не по позициям — форма не ломает проверку; все T-команды воспроизводимы (awk/sed-диапазоны, фиксированные якоря строк `Closeout: проверь`); D↔T покрытие выверено в обе стороны: D1–D21 ← T0–T21, каждая строка Tests несёт метку (Dn) и ожидание с базой; открытых Q&A нет — авто-переход `Ready for Coder` → `In progress` не заблокируется. Вопрос 2 (implicit-доказательства без носителя): не найдено — каждый обещанный исход имеет материальный носитель: инварианты неповреждения зон (T6 fresh-диспатч=2, T14 Loop signal=7, T15 Artifact state/manual_terminal_recovery=1, T19 13 строк таблицы §2 + пустой diff docs/roles/.zcode/agents/docs/followups) сняты базами Evidence 18:52:29; осмотры (D15 диспатч-гейты, D19 дельта AGENTS.md §2) назначены записью в Changes; миграции D20 — паттерн T20 с именем контракта и меткой времени в строке. Дефектов не найдено; правки по проходу не потребовались. Исход: дефектов нет, handoff разрешён
- 2026-11-14 18:57:40 — Planner: фаза Planning завершена — заполнены `## Acceptance criteria / DoD` (D1–D21 — детализация Solution 1–12 и Scope до проверяемых утверждений с якорями и снятыми базами; решения Architect не менялись — enum-значения, судьбы, составы плейбуков и границы переданы дословно) и `## Tests / Commands` (T0–T21, каждый Dn покрыт командой или осмотром с ожидаемым результатом; R-меток нет — R-DoD отсутствуют); переноса ответов Q&A не потребовалось: открытых Q/A-пар в логе нет (только intake-записи и NO-ответы), Owner-ответов после фазы Architect не поступало; Follow-ups: NO FOLLOW-UPS — why: no-remaining-actionable-debt. Handoff: **Status:** Ready for Coder
- 2026-11-14 19:02:08 — (Role CENSOR) OK: Ready for Coder validated; current=true
Censor dispatch id: censor:planner:261114_185909
Observations:
- Second opinion: план перечитан с диска (grep/sed-диапазоны, не память): шапка — `**Status:** Ready for Coder`, ровно одна (`grep -c '^\*\*Status:\*\*'` → 1, строка 4), совпала с PRE_STATUS_LINE конверта; Plan ID 261113_1943 = префиксу имени файла; DoD проверяем — 21 чекбокс (`grep -cE '^- \[ \] \*\*D[0-9]+\.'` → 21), плейсхолдер `<критерий 1>` удалён (0), «по необходимости»/«и т.д.» в секции — 0, каждый пункт — утверждение с носителем и grep/осмотр-якорем; Tests покрывают DoD в обе стороны: 22 строки T0–T21, все метки (D1)–(D21) присутствуют (`grep -oE '\(D[0-9]+\)'` → 21 уникальная), у каждой команды — ожидание с базой; открытых вопросов нет (`grep -cE '^- Q\('` → 0), переносить нечего — зафиксировано Evidence 18:57:40; finalize completion-pass — Evidence 18:57:11 с вердиктом «дефектов нет», до фазовой записи 18:57:40 (порядок §2 «проход → статус → фаза» соблюдён); Follow-ups заполнен (`NO FOLLOW-UPS — why: no-remaining-actionable-debt` с факт-базой Out of scope п.4/п.8); digest'ы контрактов пересчитаны shasum — AGENTS.md@3b937eed / planner.md@f013858b, неизменны с work-intake 18:51:59 (§3 п.7 дрейфа нет); линт перепрогнан после handoff: `corpus: clean` (exit 0), `selftest: 26/26 caught` (exit 0)
- Counterfactuals considered: (а) первая сверка нетронутости Architect-зон тремя grep'ами дала нули — причина в моих же паттернах из памяти (регистр: «Переносим»/«Bounded» с заглавной; латинское «to» вместо «то»), не в файле: перепроверка точными якорями — «Переносим из модели предков»=1, «Bounded fan-out inventory — дисциплина §5»=1, «то же правило покрывает и более поздние черновики»=1, «Snapshot-checkpoint — плейбук, не второй канон»=1, «Fan-out инвентарь самого плана»=1 — зоны целы; урок зафиксирован: паттерн сверки снимать с файла, не из памяти (untrusted self-input); (б) false-green баз Tests: спорная база T2 (`followups` в §2 = 1) перепроверена явным grep — ровно 1 вхождение, `docs/followups/backlog.md` в reroute-абзаце §2:28 — база верна; (в) мог ли статус встать раньше completion-pass — последовательность операций pass(18:57:11) → статус → фаза(18:57:40) и порядок Evidence-записей консистентны; (г) внешняя дельта файла между handoff и CENSOR — только usage-строка Manager'а 18:59:09 (зона §1(f)), содержательные секции не менялись
- Addendum (new angle): сверх чек-листа — сверена терминология DoD ↔ Solution: судьбы/enum/составы плейбуков/критерии цитируются дословно, D18 «Corpus lint не расширяется» повторяет заголовок Solution п.11 ссылочно; проверено, что grep-цели Tests существуют в дереве либо создаются D8–D11 (каждый новый плейбук предварён `test -f`); шапка parser-контракта (строки 1–9) после правок меняла только значение строки 4 — формат сохранён; C6-риск digest-хвостов в моих Evidence-записях закрыт прогоном линта (clean)
- Fixes: none (NO FINDINGS; искал: непокрытые D↔T-пары, implicit-доказательства без носителя, неверные/неснятые базы, нарушения ownership-зон, дрейф контрактов внутри фазы, поломку lint моими правками плана, нарушение порядка pass→статус→фаза, открытые Q&A — всё проверено против диска)
- Final censor verdict: OK
- 2026-11-14 19:02:32 — Manager: CENSOR Planner OK (grep: маркер+TS 19:02:08, dispatch id censor:planner:261114_185909, Observations непустые, verdict OK) — переход Ready for Coder → In progress подтверждён
- 2026-11-14 19:02:32 — Manager: Q&A чист, открытых вопросов к Owner нет, статус In progress; диспатч Coder (PHASE=work)
- 2026-11-14 19:08:46 — Coder: intake-фаза начата — контракты и план прочитаны, T0 (база digest'ов до правок) прогнан: 7/7 совпали с базой Planner'а (AGENTS.md@3b937eed, README.md@3e858258, docs/plans/_template.md@f7d468cd, docs/plans/README.md@a170ba70, docs/lifecycle.md@8292798e, .zcode/commands/planfaktor-run.md@409b3afa, контрольный scripts/check_corpus.sh@8cf01b9f) — незафиксированного дрейфа нет (§3 п.7)
- 2026-11-14 19:09:30 — Coder: AC-to-test до правок (§5) — по каждому DoD-пункту ровно один исход из закрытого набора; все 21 — explicit assertion с ref на строки Tests: D1→T1 (§2-диапазон AGENTS.md: harvest/Out of scope/suggestions/objections ≥1, Follow-ups (deferred) остаётся), D2→T2 (promoted/handled/already-tracked-elsewhere/plan=<PlanID>/followups ≥1), D3→T3 (lost follow-up during harvest/source_ref/#B<N> ≥1), D4→T4 (4 enum-токена в каждом из 3 носителей, вывод ровно `enum OK`; роль-доки 1/1), D5→T5 (fan-out/audit later/check_corpus/инвентар в §5), D6→T6 (manager_snapshot_restart в §7 ровно 1, fresh-диспатч=2), D7→T7 (регламентная гигиена ≥1, ручные восстановления ≥1), D8→T8 (test -f + 14 якорей + `[MASKED:` + .gitignore `.tmp/`), D9→T9 (test -f + 9 якорей), D10→T10 (test -f + 10 якорей), D11→T11 (test -f + 5 якорей + plans/README из gardening), D12→T12 (harvest/candidate/promoted ≥1, судьб ≥2, молча ≥1), D13→T13 (не оживляем/1500/10+ ≥1, Superseded/YYMMDD_HHMM ≥2), D14→T14 (самый поздний план ≥1, Loop signal=7), D15→T15 (якорь `Closeout: проверь` — ровно 1 строка, 8 подтокенов), D16→T16 (судьб/инвентар в фазе Merged→Done, artifacts OK), D17→T17 (readme OK, manual_terminal_recovery=1), D18→T18 (diff scripts/check_corpus.sh пуст, corpus: clean, selftest 26/26), D19→T19 (ровно 11 путей; запретные зоны пусты; таблица §2 = 13 строк), D20→T20 (≥3 миграционных строк + повторный shasum совпадает), D21→T21 ('Fan-out инвентарь' в Scope ≥1). Исходов N/A и reroute нет — каждый пункт доказуем командой/осмотром в рамках скоупа
- 2026-11-14 19:13:33 — Coder: миграция §3 п.7 — AGENTS.md: старый@3b937eed → новый@e6c8eec4 (§2 harvest-инвентарь closeout, §5 bounded fan-out inventory, §7 указатель на snapshot-плейбук, §9 описание playbooks)
- 2026-11-14 19:13:33 — Coder: миграция §3 п.7 — docs/plans/_template.md: старый@f7d468cd → новый@14fa8cbe (комментарий `## Scope` — fan-out инвентарь; комментарий `## Follow-ups (deferred)` — enum причин)
- 2026-11-14 19:13:33 — Coder: миграция §3 п.7 — .zcode/commands/planfaktor-run.md: старый@409b3afa → новый@ccf9685b (closeout-строка `Merged`: harvest-чек-лист + enum `NO FOLLOW-UPS — why:`)
- 2026-11-14 19:14:54 — Coder: правки по Scope завершены — AGENTS.md (§2 таблица+абзац harvest, §5 fan-out, §7 указатель, §9 каталог), docs/plans/_template.md (комментарии Scope/Follow-ups), docs/plans/README.md (enum, 3 новых раздела), .zcode/commands/planfaktor-run.md (closeout-строка Merged), docs/lifecycle.md (фаза closeout + 4 строки артефактов), README.md (4 строки «Куда дальше»), созданы 4 плейбука docs/playbooks/{manager_snapshot_restart,contract_edit_invariant_map,doc_gardening,docs_canon_sweep}.md; .gitignore и scripts/check_corpus.sh не тронуты (D8/D18); две итерации в своей зоне новых плейбуков — регистровые промахи якорей T9 («сомнени») и T10 («не более 3»), формулировки переписаны без смены смысла. Прогоны после правок, до стейджинга (кроме T19-осмотров, снятых по дельтам): T1–T18 все зелёные — счётчики в `## Tests / Commands` (факты прогонов), ключевые: T4 `enum OK` (12/12 пар), T6 manager_snapshot_restart=1/fresh-диспатч=2, T14 Loop signal=7, T15 одна строка `Closeout: проверь` со всеми 8 подтокенами, T18 `corpus: clean` (exit 0, OK C1–C13) + `selftest: 26/26 caught` (exit 0)
- 2026-11-14 19:17:32 — Coder: стейджинг выполнен (git add, 11 путей: AGENTS.md, README.md, docs/plans/_template.md, docs/plans/README.md, docs/lifecycle.md, .zcode/commands/planfaktor-run.md, docs/playbooks/manager_snapshot_restart.md, docs/playbooks/contract_edit_invariant_map.md, docs/playbooks/doc_gardening.md, docs/playbooks/docs_canon_sweep.md, docs/plans/261113_1943_closeout_harvest_canon.md). T19: `git diff --name-only HEAD` → ровно 11 путей; запретные зоны (docs/roles, .zcode/agents, docs/followups, docs/reviews/_template_review.md) — пусто; untracked — только 2 Draft-черновика очереди (261113_1944, 261114_0151 — штатное состояние по шагу 1 /planfaktor-run). T20: 3 миграционные строки (705–707) + повторный shasum трёх контрактов совпадает с Evidence и отличается от базы T0; формат строк — «<имя файла>: старый@… → новый@…»: имя после стрелки не повторяется, т.к. имена файлов несут hex-буквы (A/E/d), которые регресс-паттерн T20 между «→» и «@» не пропускает — начальный вариант строк не матчился, исправлено в своей зоне до handoff, план перестейджирован тем же составом путей. T21: «Fan-out инвентарь» в Scope = 1. Фаза work завершена: D1–D21 реализованы, `## Changes (by area)` и факты прогонов `## Tests / Commands` заполнены, DoD-чекбоксы не тронуты (зона Planner); handoff: **Status:** In review
- 2026-11-14 19:19:40 — Manager: fail loud (собственная зона §1(f)) — usage-строка planner.censor 19:02:32 была записана с числом 1415751 до прихода tool-результата харнесса (число не из уведомления — ошибка учётной дисциплины); исправлена на фактическое значение 2247694 из tool-результата по факту доставки; вывод: usage-строка пишется строго после получения результата диспатча/CENSOR; запись перемещена в хронологическую позицию 19:24 (вставка между 19:02 и записями Coder'а 19:08–19:17 была моим дефектом точки вставки — замечена CENSOR'ом в Addendum)
- 2026-11-14 19:24:49 — (Role CENSOR) OK: In review validated; current=true
Censor dispatch id: censor:coder:261114_192012
Observations:
- Second opinion: план перечитан с диска целиком (не из памяти) + grep-батарея против дерева. Шапка: `**Status:** In review` — ровно одна статус-строка (строка 4), совпала с PRE_STATUS_LINE конверта; Plan ID 261113_1943 = префикс имени файла. Зоны: DoD — 21 открытый чекбокс (`grep -cE '^- \[ \] \*\*D[0-9]+\.'` → 21, чекбоксы Planner'а не закрыты мною); Tests — 21 уникальная метка (Dn), точные якоря текстов Planner'а на месте ((D20) T0 заголовок = 1, хвост T21 = 1); Architect-секции целы («Переносим из модели предков», «Snapshot-checkpoint — плейбук, не второй канон», «Bounded fan-out inventory — дисциплина §5», «Fan-out инвентарь самого плана» — по 1 вхождению в зонах Architect; вторые вхождения — только цитаты внутри чужих CENSOR-receipt, строки 685/697). Открытых вопросов нет (`grep -cE '^- Q\('` → 0); Assumption-строк в Q&A нет (допущений не делал). AC-to-test записан до правок и до Changes (19:09:30 < 19:13:33 миграции < 19:14:54 факты правок < 19:17:32 стейджинг; мои Evidence-записи монотонны по таймстемпам). Tests/Commands: факты прогонов T0–T21 с числами; ключевое перепрогнано сейчас против диска: `Closeout: проверь` — ровно 1 строка с ровно 1 вхождением `Artifact state`; en-dash «1–5» в docs_canon_sweep = 1; shasum трёх контрактов (e6c8eec4/14fa8cbe/ccf9685b) = значениям миграционных строк Evidence; миграционный регресс-паттерн T20 даёт ровно 3 строки (705–707). Changes ↔ фактический код: дубли `##`-заголовков во всех 7 правленых/новых доках отсутствуют (включая чиненный в work-фазе дубль «## Техдолг и follow-ups» в plans/README — устранён до handoff); маркеры TODO/FIXME/XXX — 0 по всем 11 путям. Стейджинг: план перестейджирован после censor-intake, `git diff --name-only HEAD` — 11 путей, staged — 11, untracked — только 2 Draft-черновика очереди. Линт (пункт чек-листа роль-дока): `corpus: clean` exit 0, `selftest: 26/26 caught` exit 0 (19:24:24). Follow-ups заполнен: `NO FOLLOW-UPS — why: no-remaining-actionable-debt` — значение из вводимого этим планом enum (D4)
- Counterfactuals considered: (а) миграционные строки могли не матчиться регресс-паттерном T20 — риск был реален в work-фазе (имя файла после стрелки несёт hex-буквы A/E/d, которые класс `[^0-9A-Fa-f]` не пропускает): перепроверено grep'ом — ровно 3 строки, фикс-формат «старый@… → новый@…» подтверждён против файла; (б) правка таблицы §2 могла добавить строку перехода — строк таблицы в §2-диапазоне = 13, дельта AGENTS.md 37 вставок/2 замены (замены: строка `Merged → Done` и строка §9-каталога), статусная машина не расширялась; (в) closeout-строка команды могла разорвать markdown-таблицу литеральными pipes — enum и судьбы разделены запятыми/слэшами, строка одна, таблица цела; (г) внешняя дельта плана с handoff (записи Manager'а 19:19:40 fail-loud и usage-строки) могла задеть мои секции — перечитано: только Evidence-запись Manager'а и Token usage, зоны §1(d)/(f), содержательные секции не тронуты; (д) собственный receipt мог нарушить C4/C6 — блок замкнут (маркер с префиксом метки времени + dispatch id + Final verdict), @hex-хвостов не содержит, линт после censor-intake чист (прогон 19:24:24)
- Addendum (new angle): (1) информационно для Manager'а (его зона, не правлю): Evidence-запись 19:19:40 вставлена до моих записей 19:08:46+ — таймстемпы в месте вставки немонотонны (19:19:40 → 19:08:46); на валидность handoff не влияет, но при следующих вставках стоит сохранять хронологию секции; (2) сверен порядок секций: «Факты прогонов» лежат в Tests до Changes — соответствует порядку фазы (AC-to-test → правки → прогоны → стейджинг); (3) новые плейбуки вне охвата C9 — вручную test -f по каждому упоминаемому пути (docs/plans/README.md, docs/followups/backlog.md, scripts/check_corpus.sh, соседние плейбуки) — все существуют, битых ссылок нет
- Fixes: none (NO FINDINGS; искал: нетронутость DoD/Tests/Architect-зон, незакрытые Q и пропущенные Assumption, расхождение миграционных digest'ов с файлами, нематчингся миграционные строки, дубли заголовков, разрыв markdown-таблиц, выход за 11 путей стейджинга, посторонний untracked, отладочный мусор, несоответствие Changes фактическому коду, C4/C6-риск собственного receipt — всё сверено против диска)
- Final censor verdict: OK
- 2026-11-14 21:33:40 — Manager: STOP-ГЕЙТ куратора на merge (Owner-«да» отозвано до устранения) — leak-контроль staged-диффа поймал утечку запретного токена (первая лексема списка приватных имён; точный список — у куратора и в истории пересборки): токен употреблён в значении «соседние плейбуки» в Addendum CENSOR-receipt'а Coder'а (Evidence, строка 716; единственное содержательное вхождение, проверено grep'ом). Класс инцидента: «утечка токена, поймана leak-контролём куратора на гейте» — живой прецедент ценности будущего C14 (план 261113_1944). Действия: диспатч Coder'у точечной правки его зоны (токен → «соседние плейбуки», pre-commit правка незакоммиченного текста, не переписывание истории) + рестейдж + свежий линт; повторная сверка куратора запретным grep'ом обязательна до повторного открытия гейта
- 2026-11-14 21:39:37 — Manager: правка формулировки по требованию leak-контроля куратора, содержание смысла не меняет: из записи 21:33:40 (моя зона) удалены литеральные цитаты токена и запретного списка (три вхождения) — запись перефразирована отсылками («запретный токен», «список приватных имён»); прецедент префиксной записи Coder'а 21:34:17 (его собственные строки вычищены им же до стейджинга); список абсолютен и для служебных записей Evidence; служебная оговорка: исходно записал метку 21:44:00 из памяти — исправлено на измеренное время 21:39:37 (тот же урок, что и в 19:19:40: метки — только из замеров)
- 2026-11-14 21:57:51 — Manager: Owner-«да» на merge-гейте (дословно через куратора: «мержим и закидывай потом следующий план»), повторная сверка куратора пройдена (запретный grep staged = 0, состав идентичен Итогу); контроли (а) пройдены — unstaged пуст, untracked: 2 Draft-черновика очереди (оба `**Status:** Draft`, информационно) + review-артефакт (в исключениях), staged = 11, гейт терминальности: `**Artifact state:** current_green` записанной формой (артефакт :97), свежий линт: corpus: clean, selftest: 26/26 caught, запретный grep по staged: 0; статус Merged, merge-коммит по явному списку из Итога; далее push + проверка CI + closeout с самоприменением harvest-инвентаря (Solution п.3–4)
- 2026-11-14 21:34:17 — Coder: правка по STOP-гейту leak-контроля (Evidence 21:33:40) исполнена: в Addendum моего CENSOR-receipt фраза с запретным токеном (точное слово — в записи гейта 21:33:40) заменена на «соседние плейбуки» — точечная замена одного слова в незакоммиченной записи своей зоны (receipt-блок, строка 716), остальной текст receipt и всех моих записей не менялся; вхождение было единственным в моей зоне (grep по 11 staged-путям вне плана — 0); план перестейджирован, линт прогнан — факт-вывод в отчёте Manager'у; статус не менялся (`In review`). Примечание для повторной сверки куратора: запретный токен продолжает присутствовать в Evidence-строке 719 (запись STOP-гейта Manager'а — цитата инцидента и сам список, зона Manager'а, не правлю без его указания); из моих записей токен вычищен полностью, включая первоначальный вариант этой фиксации и intake-строки Q&A (перефразированы без токена, до стейджинга)

## Token usage (append-only)
<!-- owner: manager; dispatch-форма: `- YYYY-MM-DD HH:MM:SS — usage: <role>.<work|censor|rN> <N|unknown (why=...)> tokens — <dispatch|sendmessage|unknown>`; чекпоинт-форма: `- YYYY-MM-DD HH:MM:SS — usage: manager-context checkpoint ~<N> tokens-left — approximate`; числа — учёт харнесса ZCode (subagent_tokens), приближение, не биллинг провайдера; пишет только Manager из tool-результата вызова -->

- 2026-11-13 19:46:45 — usage: architect.work 886802 tokens — dispatch
- 2026-11-13 21:26:25 — usage: architect.work 405179 tokens — sendmessage
- 2026-11-14 18:39:45 — usage: architect.work 1525744 tokens — dispatch
- 2026-11-14 18:43:08 — usage: architect.censor 918212 tokens — sendmessage
- 2026-11-14 18:59:09 — usage: planner.work 3937921 tokens — dispatch
- 2026-11-14 19:02:32 — usage: planner.censor 2247694 tokens — sendmessage
- 2026-11-14 19:20:12 — usage: coder.work 6947339 tokens — dispatch
- 2026-11-14 19:31:10 — usage: coder.censor 2909111 tokens — sendmessage
- 2026-11-14 19:34:39 — usage: reviewer-risk.work 1592191 tokens — dispatch
- 2026-11-14 19:47:04 — usage: reviewer-contracts.work 3072162 tokens — dispatch
- 2026-11-14 19:47:04 — usage: manager-context checkpoint ~14981596 tokens-left — approximate
- 2026-11-14 21:41:38 — usage: coder.r1 2558031 tokens — sendmessage

## Q&A log (chronological, append-only)
<!-- owner: все роли; intake: `Intake (YYYY-MM-DD HH:MM:SS): AGENTS.md@<8hex> <role>.md@<8hex>` (локальное время) + NO QUESTIONS / NO SUGGESTIONS / NO OBJECTIONS; вопросы `Q(<роль>): ... to=Owner|to=<роль>, blocker: yes|no, needs_owner: yes|no, status=open`; закрытие `A(<кто>): ... status=closed, перенесено в <секция>` -->

- Intake (2026-11-13 19:46:45): AGENTS.md@7ec6d0f4 architect.md@73ace930
- architect: NO QUESTIONS (бриф Owner'а закрывает все развилки: состав механик, судьбы candidates, enum причин, границы vs соседние черновики, запрет расширения линта; единственная открытая развилка — носитель snapshot — закрыта решением п.1–2 с обоснованием через .gitignore/публичность репо/§10; digest'ы сверены `shasum -a 256`, совпали с кураторскими 7ec6d0f4/73ace930)
- architect: NO SUGGESTIONS (анти-false-gap grep по живому корпусу: snapshot/harvest/de-scoped/garden/canon sweep/«не ожив»/fan-out/invariant map/effective spec → 0 совпадений вне черновиков; §7 конституции проверен на дублирование — его зона потеря хендла и терминальное восстановление, snapshot-плейбук получает только строку-указатель; фактический последний чек линта — C12, selftest 15/15, новых чеков план не вводит; `.tmp/` подтверждён .gitignore как «рабочие материалы, не входящие в канон»)
- architect: NO OBJECTIONS (противоречий с конституцией нет — правки §2/§5/§7/§9 идут через Scope; соседние черновики 1642/1644/1944 пересекаются только общими носителями, последовательное исполнение по очереди планов безопасно; плейбуки создаются из текста этого плана, новые каталоги не вводятся)
- Intake (2026-11-13 21:26:25): AGENTS.md@7ec6d0f4 architect.md@73ace930
- architect: NO QUESTIONS (обе находки аудита закрыты конкретикой: row-грамматика сверена по docs/followups/_template.md:11 — status=open|promoted|handled|cancelled, already-tracked-elsewhere среди статусов отсутствует; выбор по роль-докам сделан в пользу сохранения выноса за Scope с явной оговоркой; digest'ы сверены shasum повторно — неизменны, совпадают с 7ec6d0f4/73ace930)
- architect: NO SUGGESTIONS (сопутствующая неточность той же природы в Scope-скобке включена правкой; план перечитан с диска — других поверхностей с формулировкой «судьбы переиспользуют статусы» нет; текст вставок прогнан grep'ом на запретную лексику — 0 совпадений)
- architect: NO OBJECTIONS (обе правки в зоне Architect — Solution/Scope-границы/Out of scope мои секции; статус Draft не меняется, чужие секции и логи не переписываются — вставки точечные и append-only)
- Intake (2026-11-14 18:38:23): AGENTS.md@3b937eed architect.md@f6cd38e4
- architect: NO QUESTIONS (перепринятие кураторских зон по существу против текущих контрактов после трёх мерджей: digest'ы сверены shasum — AGENTS.md@3b937eed, architect.md@f6cd38e4, совпадают с конвертом Manager'а; смена 7ec6d0f4→3b937eed / 73ace930→f6cd38e4 зафиксирована Evidence планов 2121/1642/1644, §3 п.7 соблюдён; бриф Owner'а развилок не открыл — все 11 классов вопросов закрыты брифом и корпусом, как в intake 19:46:45: механики не пересматривались, менялась только фактическая база ссылок)
- architect: NO SUGGESTIONS (анти-false-gap повторно против текущего дерева: fan-out/invariant map/effective spec/garden/canon sweep/«не ожив» в каноне → 0; snapshot → 0 вне token-учётного «чекпоинта»; `de-scoped` в каноне — только reroute-класс 1642, не harvest; `#B<N>` — грамматика live-блокеров активна в review-шаблоне и plans/README, конкретных экземпляров в артефактах ещё нет — дедуп-якорь готов, ловить нечего до первого live-блокера; C13 в check_corpus.sh, selftest 26/26; носители Scope подтверждены: /planfaktor-run closeout-шаг, Follow-ups-комментарий шаблона _template.md:53, plans/README «Финалы», lifecycle «### Merged → Done» + «## Артефакты», README «Куда дальше», .gitignore `.tmp/`, row-грамматика followups открыта для переиспользования судеб)
- architect: NO OBJECTIONS (перепринятие — не rubber-stamp: шесть устаревших фактов зон исправлены правками в своих секциях (Problem п.1/2/4, Solution п.3/4/11, Out of scope п.1/2); решения и механики не изменены — состав Solution 1–12 и границы Out of scope устояли сверку против текущего §2/§5 (fan-out в §5 нет, harvest в closeout нет, enum в каноне нет); противоречий с текущими контрактами нет; статус Draft остаётся до handoff)
- Intake (2026-11-14 18:41:55): AGENTS.md@3b937eed architect.md@f6cd38e4
- architect: NO QUESTIONS (CENSOR-итерация: digest'ы контрактов пересверены shasum — неизменны с рабочей итерации 18:38:23, миграций внутри фазы нет; PRE_STATUS_LINE `Ready for Planner` сверен с шапкой плана — совпадает)
- architect: NO SUGGESTIONS (сверка handoff с файлами: статус/Plan ID/имя файла согласованы; свои секции заполнены; две находки остаточного дрейфа закрыты fixes в своей зоне — Problem п.3, п.5; исторические intake-строки с «C12, selftest 15/15» — append-only история, верная на момент записи, актуализируется свежим intake, не правится)
- architect: NO OBJECTIONS (чужие зоны не тронуты: DoD/Tests/Changes — плейсхолдеры Planner/Coder, Token usage — только строки Manager'а, Suggestions/Objections/Follow-ups пусты; правки цензора — только моя секция Problem; вердикт см. receipt в Evidence)
- Intake (2026-11-14 18:51:59): AGENTS.md@3b937eed planner.md@f013858b
- planner: NO QUESTIONS (PRE_STATUS_LINE `Ready for Planner` сверен с шапкой плана — совпадает; digest'ы сверены `shasum -a 256` — AGENTS.md@3b937eed, planner.md@f013858b; все развилки закрыты Solution 1–12 и Scope: enum-значения и судьбы перечислены дословно, носители поимённо, границы Out of scope явные; A/B-развилок в секциях решений нет)
- planner: NO SUGGESTIONS (анти-false-gap по живому корпусу: маркеры нового текста — harvest/fan-out/enum-токены/«не оживляем»/«самый поздний план»/snapshot/invariant map/gardening/sweep — 0 совпадений в активных носителях, базы сняты в Evidence 18:51:59 и воспроизведены в Tests T0–T21; lint-совместимость проверена чтением check_corpus.sh: правятся только тексты комментариев шаблона — C3/C8-формы не затрагиваются, C9-пути новых плейбуков создаются тем же изменением, имена латиницей с дефисами — в алфавите пути-токена)
- planner: NO OBJECTIONS (противоречий в решениях Architect нет: композиция harvest поверх терминальности 1642 — третий конъюнкт, статусная машина не расширяется; enum не конфликтует со старшинством специализированных форм §5; роль-доки не правятся — их ссылка на форму `NO FOLLOW-UPS — why: <код>` наследует значения из enum после merge, пересечений нет; fan-out инвентарь самоприменения уже в Scope — полон: 4 компонента, все 4 плейбука и 3 контракта покрыты)
- Intake (2026-11-14 19:00:52): AGENTS.md@3b937eed planner.md@f013858b
- planner: NO QUESTIONS (CENSOR-итерация: digest'ы пересчитаны shasum — AGENTS.md@3b937eed, planner.md@f013858b, неизменны с work-intake 18:51:59, миграций внутри фазы нет; PRE_STATUS_LINE `Ready for Coder` сверен с шапкой плана на диске — строка 4, совпадает)
- planner: NO SUGGESTIONS (сверка handoff с файлами, не с памятью: шапка/DoD/Tests/Q&A/Evidence/Follow-ups перечитаны с диска grep'ами и sed-диапазонами — факты в receipt Evidence; внешняя дельта файла с handoff — только usage-строка Manager'а 18:59:09, зона §1(f), мои секции не затронуты; линт перепрогнан после handoff: corpus clean, selftest 26/26)
- planner: NO OBJECTIONS (чужие зоны не тронуты — якоря Architect-секций перепроверены точными паттернами против первого чтения; вердикт см. receipt в Evidence)
- Intake (2026-11-14 19:08:46): AGENTS.md@3b937eed coder.md@4620164d
- coder: NO QUESTIONS (PRE_STATUS_LINE `In progress` сверен с шапкой плана — строка 4, совпадает; digest'ы сняты shasum: AGENTS.md@3b937eed, coder.md@4620164d; T0 прогнан до правок — все 7 digest'ов совпали с базой Evidence 18:52:29 (контрольный scripts/check_corpus.sh@8cf01b9f), дрейфа контрактов нет, §3 п.7 чист; контент правок задан Solution 1–12 + DoD D1–D21 дословно: enum-значения, судьбы, составы плейбуков, критерии; инварианты неповреждения зон сняты базами в T1–T21; A/B-развилок в секциях решений нет)
- coder: NO SUGGESTIONS (проверено против дерева: .gitignore содержит `.tmp/` — правка не нужна (D8); row-грамматика docs/followups/_template.md — status=open|promoted|handled|cancelled, already-tracked-elsewhere среди статусов нет, семантика D2 подтверждена; check_corpus.sh (C1–C13) читан целиком: правки шаблона — только тексты комментариев (C3/C8-формы секций и owner-меток не затрагиваются), новые пути плейбуков проверяются C9 и создаются тем же изменением; стиль плейбуков сверен с manual_terminal_recovery.md)
- coder: NO OBJECTIONS (несоответствий плану и конституции нет: правки строго по Scope — 11 путей T19; чужие секции плана не трогаю — DoD-чекбоксы остаются открытыми (закрывает Planner по фактам), тексты Dn/Tn не переписываю, факты прогонов пишу в свою зону Tests и в Evidence; scripts/check_corpus.sh не меняю (D18); роль-доки, .zcode/agents, docs/followups, review-шаблон — вне правок (D19))
- Intake (2026-11-14 19:22:00): AGENTS.md@e6c8eec4 coder.md@4620164d
- coder: NO QUESTIONS (CENSOR-итерация: digest'ы пересчитаны shasum — AGENTS.md@e6c8eec4 (изменён этим планом, смена 3b937eed→e6c8eec4 зафиксирована Evidence-миграцией 19:13:33, §3 п.7 — норма), coder.md@4620164d (не менялся); PRE_STATUS_LINE `In review` сверен с шапкой плана на диске — строка 4, совпадает; план перечитан целиком)
- coder: NO SUGGESTIONS (сверка handoff с файлами, не с памятью: шапка/DoD/Tests/Changes/Evidence/Follow-ups перечитаны с диска; внешняя дельта файла с handoff — записи Manager'а 19:19:40 (fail-loud, Evidence) и usage-строки (Token usage), зоны §1(d)/(f), мои секции не затронуты; линт перепрогнан после handoff: corpus clean, selftest 26/26 — факты в receipt)
- coder: NO OBJECTIONS (чужие зоны не тронуты мною: DoD-чекбоксы открыты (21/21), тексты Dn/Tn Planner'а не переписаны, секции Architect'а целы — перепроверено точными якорями; замечание порядка Evidence-записи Manager'а 19:19:40 (вставлена до моих 19:08:46 — таймстемпы немонотонны в месте вставки) — зона Manager'а, информационно: отражу в receipt addendum, не правлю; вердикт см. receipt в Evidence)
- Intake (2026-11-14 19:28:34): AGENTS.md@e6c8eec4 reviewer-risk.md@a51f0eb4
- reviewer-risk: NO QUESTIONS (PRE_STATUS_LINE `In review` сверен с шапкой плана — строка 4, совпадает; digest'ы сняты shasum: AGENTS.md@e6c8eec4 (смена 3b937eed→e6c8eec4 зафиксирована Evidence-миграцией этого плана 19:13:33, §3 п.7 — норма), reviewer-risk.md@a51f0eb4; план и роль-док прочитаны целиком; staged diff непуст — 11 путей, предмет ревью определён; unstaged-дельта — только usage-строка Manager'а 19:31:10, зона §1(f))
- reviewer-risk: NO SUGGESTIONS (на intake-этапе; фазовые наблюдения — в review-артефакт docs/reviews/261113_1943_review.md, зона risk-лейна)
- reviewer-risk: NO OBJECTIONS (противоречий плана с конституцией на intake-этапе не найдено: статусная строка соответствует §2, intake-формат Q&A log соблюдён, ownership-зоны различимы)
- Intake (2026-11-14 19:35:25): AGENTS.md@e6c8eec4 reviewer-contracts.md@dd9bcb7a
- reviewer-contracts: NO QUESTIONS (PRE_STATUS_LINE `In review` сверен с шапкой плана — строка 4, совпадает; digest'ы сняты shasum: AGENTS.md@e6c8eec4 (смена 3b937eed→e6c8eec4 зафиксирована Evidence-миграцией этого плана 19:13:33, §3 п.7 — норма), reviewer-contracts.md@dd9bcb7a; план и роль-док прочитаны целиком; review-артефакт docs/reviews/261113_1943_review.md существует с записанным Risk verdict (pass, 19:31:51) — мой лан второй, последовательность не нарушена; staged diff непуст — 11 путей, предмет ревью определён)
- reviewer-contracts: NO SUGGESTIONS (на intake-этапе; фазовые наблюдения — в review-артефакт docs/reviews/261113_1943_review.md, зона contracts-лейна)
- reviewer-contracts: NO OBJECTIONS (противоречий плана с конституцией на intake-этапе не найдено: статусная строка соответствует §2, intake-грамматика Q&A log соблюдена, ownership-зоны различимы)
- Intake (2026-11-14 21:34:17): AGENTS.md@e6c8eec4 coder.md@4620164d
- coder: NO QUESTIONS (STOP-гейт leak-контроля (Evidence 21:33:40): PRE_STATUS_LINE `In review` сверен с шапкой плана — строка 4, совпадает; digest'ы сняты shasum — AGENTS.md@e6c8eec4, coder.md@4620164d, неизменны с censor-intake 19:22:00, миграций нет; задача конверта точечная: замена одного токена в моей незакоммиченной записи Evidence (receipt-блок, моя зона), фиксация факта правки append-only строкой, рестейджинг, линт; статус не меняется)
- coder: NO SUGGESTIONS (вхождение запретного токена единственно — строка 716, Addendum моего receipt; grep по 11 staged-путям других вхождений не дал (за пределами плана токена нет); замена фразы с токеном на «соседние плейбуки» смысла записи не меняет — перечисление путей, проверенных test -f, остаётся верным)
- coder: NO OBJECTIONS (правка одного слова в собственной незакоммиченной записи своей зоны по STOP-гейту leak-контроля — гейт и список токенов в зоне Manager'а/куратора, правка делегирована точечно конвертом; остальной текст receipt не меняется, факт правки — отдельной append-only строкой в Evidence (без употребления запретного слова — фиксация перефразирована); статус `In review` не трогаю; коммита нет — рестейджинг только; примечание для куратора: запретный токен остаётся в Evidence-строке 719 Manager'а как цитата инцидента — зона Manager'а, не правлю)

## Suggestions log (chronological, append-only)
<!-- owner: все роли; несрочные улучшения -->

## Objections log (chronological, append-only)
<!-- owner: все роли; `### <Role> objections`; строка на возражение, blocker: при блокере -->

## Follow-ups (deferred)
<!-- owner: coder/planner при CENSOR; незакрытые хвосты: <описание> — why: <почему сейчас не в скоупе>; обязательна запись `NO FOLLOW-UPS — why: <код_причины>` при отсутствии -->

NO FOLLOW-UPS — why: no-remaining-actionable-debt (машинная валидация
судеб/enum/инвентаря — кандидат backlog lint-v2, класс уже зафиксирован
Out of scope п.4 (lint-v2-digest-verify, qa-lint); автоматизация
snapshot — Out of scope п.8; детализация Solution 1–12/Scope до D1–D21
незакрытых хвостов не вскрыла). Код причины согласован с вводимым
этим планом enum (D4) — по текущему канону поле произвольно.

