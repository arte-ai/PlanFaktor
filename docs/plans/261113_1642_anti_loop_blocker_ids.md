# Анти-луп: классификация повторных блокеров и канонические ID ревью

**Plan ID:** 261113_1642
**Status:** Merged
**Created:** 2026-11-13
**Owner gates:** merge (`In review` → `Merged`); вопросы `to=Owner` — по мере возникновения

> Шапка — parser-контракт: строки выше grep'аются Manager'ом. Не менять формат.
> Имя файла: `261113_1642_anti_loop_blocker_ids.md`.

## Как я понял задачу
<!-- owner: architect; 3–7 строк; обязательна при Architect intake -->

Конвейер умеет возвращать план по needs-fix, но не умеет замечать, что ходит
по кругу: повторный блокер каждый раунд выглядит как новый, ревью молчит о
причине повтора, маршрут возврата один — Coder'у (§2, run.md:176).
Переносим анти-луп-контур из модели предков (приватные первоисточники,
ссылки исключены из публичного репо): live-блокер получает канонический
ID `B<N>` (Current state + Severity S1–S3, merge блокирует только live S1;
регрессии поведения соседних областей — S1), повтор по lineage несёт
Loop signal с классом корневой причины из закрытого enum'а; вернувшийся
план классифицирует Architect — same-contract reroute идёт сразу Coder'у,
реальное расширение скоупа — Planner'у, выведенное — в follow-ups;
стоп-матрица различает ре-луп и прогресс, слепой реран запрещён, CENSOR
в подтверждаемом файлами лупе не вправе ответить «дефектов не нашёл».
Артефакт получает реран-жизнь в том же файле (Rerun mode incremental|full
с грамматикой доверия), судьбы находок в Итоге, терминальные состояния,
блокирующие closeout; линт — чек C13. Зоны переприняты против текущих
контрактов (AGENTS.md@eb9cffe8, architect.md@e34627dc; merge 720519f
плана 261113_2121): механики 2121 — Q#<n>-грамматика Q&A, формальный
переход `In review → In progress` (ставит Coder), «Состав staged» в Итоге —
не конфликтуют, согласованы в п.4/п.12; артефакт 261113_2121_review.md
(Plan ID ≥ cutoff, старая грамматика) закрыт exclude-листом C13 (п.8),
самоприменение — этот план живёт по C13 с Round 1 (п.9).

## Problem
<!-- owner: architect; пронумерованные пункты -->

1. Повторный блокер неотличим от нового. Review-артефакт каждого раунда
   перечисляет findings заново: нет канонических ID блокеров, состояния
   (жив / закрыт / поглощён) и происхождения повторов —
   `grep -rniE 'loop.signal|root.cause|current.state|lineage'` по AGENTS.md,
   роль-докам, обоим шаблонам и check_corpus.sh → 0 совпадений. Все 8
   существующих артефактов `docs/reviews/` (7 старее cutoff 261113_1642 +
   `261113_2121_review.md`, созданный merge 720519f уже после фиксации
   cutoff) живут только механикой Round N + `superseded (round N)` (C7):
   lineage блокера между раундами теряется — живой пруф сам артефакт
   261113_2121: раунды 1→2→3, повторный дефект-класс Round 2 связан
   с Round 1 («тот же класс дефекта, что findings 1–2 Round 1») только
   прозой автора, грамматической связи (ID, состояние, lineage) нет.
2. Возврат needs-fix слеп. §2 конституции (после 720519f — строка
   `In review → In progress`, ставит Coder) и шаг 4
   `.zcode/commands/planfaktor-run.md` (строка 176: «needs-fix → Manager
   статус не ставит: диспатчи Coder») дают единственный маршрут —
   `In progress` Coder'у; блокер, чей корень лежит в скоупе или контракте,
   снова и снова уходит Coder'у (reroute не существует:
   `grep -rniE 'reroute|scope expansion|de-scoped'` по корпусу → 0).
3. Стоп-матрица §6 (`loop`) — счётчик без классификации: «одинаковый
   FAIL/blocker ≥ 2 раз без прогресса» не различает транзиент, семантический
   блокер, прогресс с артефактом и ре-луп; blocker lineage и запрет слепого
   рерана не определены.
4. CENSOR проходит луп пустым. Формат receipt §4 (Observations /
   Counterfactuals / Addendum) не требует разбора повтора: «дефектов не
   нашёл» при repo-backed повторном FAIL не запрещён
   (`grep -rniE 'NO FINDINGS|extraordinary'` → 0) — луп выживает именно там,
   где второй угол обзора подтверждает «всё сходится».
5. Ревью-вердикт не привязан к состоянию diff. После fixes или
   пост-вердиктных правок прошлый pass/needs-fix описывает уже неактуальный
   staged; терминальных состояний артефакта нет, closeout (`Merged → Done`)
   согласованности артефакта не проверяет (`grep -rniE 'current_green|
   needs_reviewer_rerun|rerun|stale.note'` → 0). Транзиент-прецедент:
   261113_0217, Evidence 12:36:55 — артефакт в промежуточном состоянии
   раунда ронял линт.
6. Одна ось серьёзности без разделения природы дефекта. Findings несут
   blocker/major/minor, и merge блокирует любой blocker/major (шаблон
   ревью; роль-доки: «needs-fix → в findings минимум один blocker/major»):
   техдолг/edge-cases и стиль держат merge так же, как
   контракт/данные/безопасность. Модель предков требует merge-гейт только по
   S1 с обязательной материализацией S2/S3.
7. Линт не знает грамматики блокеров. `scripts/check_corpus.sh`: C7 —
   единственная проверка review-артефактов (шапка, вердикт-строки,
   superseded-лейблы); фактический последний чек — C12, selftest 15/15;
   грамматики live-блокеров, Loop signal и терминальных состояний нет ни в
   одном чеке. Граница действия нового чека не сводится к cutoff по
   Plan ID: `261113_2121_review.md` (Plan ID 261113_2121 ≥ cutoff
   261113_1642) создан по старой грамматике до введения чека — без
   явного исключения чек ложно уронит исторически-легальный артефакт.

## Solution / Decisions
<!-- owner: architect; решения уровня «что и почему», без детализации -->

1. **Канонические Blocker ID.** Live-блокер в review-артефакте оформляется
   секцией `### B<N>` с обязательными полями: `Current state:` из enum
   {open; historical-fixed; superseded}, `Severity:` из enum {S1; S2; S3}
   (S1 — контракт/данные/безопасность/несоответствие плану, включая
   regression-behavior (регрессии поведения соседних областей); S2 —
   техдолг/edge-cases; S3 — стиль), `Primary owner gap:` — зона-источник
   дефекта (чьё упущение). Таблицы findings (файл:строка,
   blocker/major/minor) остаются плотным перечнем находок; B-блок —
   единственная легальная форма live-блокера, на которую ссылаются план,
   классификация и линт (кросс-ссылка `<путь_ревью>#B<N>`). Почему: ID +
   состояние дают lineage, который переживает раунды; маркировка прошлых
   блоков — тот же приём, что уже принятый `superseded (round N)`.
   Аудит-дополнение: regression-behavior назван в S1 явно — регрессия без
   буквального «несоответствия плану» де-факто уходила в S2/non-blocking,
   что противоречило роли reviewer-risk («Риски, регрессии…», AGENTS.md:17);
   Severity-типаж (этот пункт) и первый обязательный домен coverage (п.11)
   согласованы, следствие для п.2: регрессия → live S1 → needs-fix → merge
   заблокирован.
2. **Merge-гейт — только live S1.** Вердикт needs-fix ⇔ есть блок с
   `Current state: open` и `Severity: S1`. S2/S3 merge не блокируют, но
   обязаны материализоваться: фикс в текущем раунде либо строка в
   `## Follow-ups (deferred)` плана / `docs/followups/backlog.md`
   (row-грамматика уже существует) — «замолчанный» S2/S3 не теряется,
   closeout видит судьбу каждого блока. Почему: ревью перестаёт душить
   merge техдолгом и стилем, не теряя их из корпуса.
3. **Loop signal — обязательство Reviewer'а.** Блокер, повторяющий по
   lineage блокер прошлого раунда (ID переиспользован), обязан нести
   Loop-блок: `Loop signal`, `Root cause class` из закрытого enum
   {stale evidence / historical artifact mismatch; same-contract reroute;
   closed baseline + live blocker split; real scope expansion; de-scoped
   follow-up}, `Next owner`, явное различение «same-contract reroute vs
   scope gap». Повтор без Loop signal = process miss Reviewer'а: Manager
   возвращает артефакт fail loud. При reroute ID переиспользуется; новый
   ID — только при real scope expansion или новом независимом дефекте.
   Почему: повтор — это информация о процессе, а не ещё один finding;
   молчаливый повтор — топливо лупа.
4. **Reopened-классификация Architect'а и новые переходы §2.** При needs-fix
   с Loop signal Manager диспатчит Architect'а до любого перевода статуса:
   штатный возврат `In review → In progress` (формализован merge 720519f —
   статус ставит Coder на intake fixes-итерации) остаётся маршрутом
   раунда без Loop signal. Architect до любого переписывания скоупа
   классифицирует
   вернувшийся блокер тем же enum'ом (запись в `## Evidence` плана с
   grep-якорем `Reopened classification:`) и ставит переход:
   `same-contract reroute` (контракт не менялся) → `Ready for Coder`,
   минуя Planner; `real scope expansion` → `Ready for Planner`;
   `de-scoped follow-up` → Follow-ups (deferred)/backlog. Классы
   `stale evidence` и `closed baseline + live blocker split` — диагностики
   ревью: stale evidence → реран по актуальному diff (вердикт
   пересматривается до любого маршрута), split → закрытая часть блока
   получает historical-fixed, живая — собственный B-блок со своим классом.
   Роль-док Architect'а при этом теряет запрет «статусы дальше Ready for
   Planner» в части двух новых переходов из `In review`.
5. **Same-file rerun lifecycle.** Реран после фикса живёт в том же файле
   артефакта (новая шапка/вердикт раунда — механика Round N уже так
   делает); прежний блокер → `historical-fixed`/`superseded`. До рерана
   план несёт Stale note / Rerun note (Evidence-строка Manager'а при
   возврате needs-fix: прошлый вердикт относится к пред-фиксному diff,
   реран обязателен). Артефакт получает терминальные состояния
   `current_green` (последний раунд pass против актуального diff) и
   `historical_reconciled` (блокеры урегулированы историей); `current_red`
   и `needs_reviewer_rerun` — нетерминальные, блокируют closeout: условие
   перехода `Merged → Done` дополняется требованием терминального
   состояния review-артефакта. Состояние ставит contracts-лейн при сборе
   `## Итог` (он уже собирает итог из двух вердиктов).
6. **Стоп-матрица §6 — классификация повторных остановок.** Строка `loop`
   заменяется классами {operational_retry; semantic_blocker;
   progress_with_artifact; real_loop; unknown}; класс повтора фиксируется в
   Evidence при каждом повторе. `real_loop` = тот же активный пункт + тот
   же статус + тот же blocker lineage (B-ID) + нет нового артефакта → стоп
   и эскалация Owner с выжимкой, слепой реран запрещён.
   progress_with_artifact (новый артефакт или закрытый блокер) сбрасывает
   счётчик; unknown — осторожный дефолт: сначала классифицируй, потом
   действуй. Почему: повтор сам по себе не грех — грех неразличимый повтор.
7. **CENSOR deadlock-режим §4.** При repo-backed повторном loop (повтор
   подтверждается файлами, а не памятью чата) цензору запрещён «пустой»
   результат: receipt обязан нести `Loop signal`, «why previous rerun did
   not break the loop» и «extraordinary action» (что сделано сверх обычного
   чек-листа). Почему: луп выживает на «перепроверил — всё сходится»;
   принуждение объяснить, почему прошлый реран не помог, ломает этот
   паттерн.
8. **Corpus lint C13** (следующий свободный номер после C12; selftest
   15/15 → 15+N с кейсами C13). POSIX-грамматика блокеров в
   review-артефактах с Plan ID ≥ cutoff 261113_1642 минус явный
   exclude-лист артефактов, созданных по старой грамматике до введения
   чека — первое имя `261113_2121_review.md` (Plan ID ≥ cutoff, но создан
   merge 720519f до правки шаблона: базовую часть чека не роняет —
   B-блоков нет, отсутствие B-блоков не дефект; роняет расширенная —
   раунды 2–3 без rerun-полей, Итог без судеб/coverage). Механика:
   cutoff C4/C5/C7 + явный список исключений, а не чистое число — Plan ID
   не монотонен по времени создания артефакта, и сдвиг cutoff выше
   261113_1642 сломал бы самоприменение п.9. Форма live `### B<N>`
   (Current state из enum, Severity из S1–S3, ID без дублей и дыр в
   пределах артефакта), Loop signal обязателен у live-блока, чей ID
   присутствует в superseded-раунде того же артефакта. Исторические
   артефакты excluded: 7 файлов < cutoff — по прецеденту cutoff C4/C5/C7;
   `261113_2121_review.md` — через exclude-лист выше.
   Транзиент-безопасность (прецедент C7-транзиента 261113_0217): C13
   проверяет форму присутствующих блоков, отсутствие B-блоков — не дефект
   (раунд без блокеров — норма), поэтому промежуточное состояние артефакта
   между лейнами линт не роняет.
9. **Самоприменение и переходный стейт.** Живой шаблон
   `docs/reviews/_template_review.md` правит Coder в `In progress`;
   review-артефакт ЭТОГО плана создаётся уже из нового шаблона и живёт по
   C13 с Round 1 (Round 1 — не повторный раунд: Loop signal не требуется до
   переиспользования ID). Аналог самоприменения шапки шаблона в плане
   261113_0217 (D3/D10).
10. Все контракты из Scope → миграционные записи §3 п.7 (смена digest'ов,
    старый@8hex → новый@8hex, в Evidence этого плана).
11. **Coverage domains + No findings reason.** Каждый лейн review-артефакта
    обязан перечислить покрытые домены из фиксированного enum и при
    отсутствии находок записать `No findings reason:` текстом — пустого
    молчания больше нет. Enum'ы под docs-конвейер фиксируются в
    `docs/reviews/_template_review.md` и роль-доках ревьюеров:
    **risk-лейн** — {regression-behavior (регрессии поведения соседних
    областей); edge-cases (границы, пустые значения, ошибки, повторные
    запуски); data-integrity-secrets (целостность данных, секреты,
    приватные следы); command-reproducibility (воспроизводимость команд и
    честность фактов Evidence); brittleness (хрупкость формы/якорей к
    будущим правкам)}; **contracts-лейн** — {constitution-compliance
    (соответствие конституции §1–§10); canon-drift (канон-дрифт между
    носителями: AGENTS/шаблоны/роли/команды/линт); artifact-grammar
    (целостность форматов и грамматик плана/review/линта);
    review-artifact-truthfulness (правдивость review-артефакта и Evidence
    против файлов); scope-dod-boundaries (границы Scope/DoD: всё из Scope
    сделано, ничего лишнего); tests-evidence-trace (Tests/Commands покрыты
    DoD-метками, факты в Evidence)}. Существующий прецедент «Находок нет —
    таблица остаётся пустой, это нормальный исход»
    (`docs/roles/reviewer-risk.md:47–48`; в первой редакции плана :43 —
    сдвинуто intake-блоком плана 261113_2121, merge 720519f) сохраняется,
    но получает контент: причина и перечень доменов. Почему: «нет находок» — тоже факт,
    требующий носителя; это прямое усиление контент-требования «явная
    форма отсутствия» соседнего черновика 261113_1644 (honest handoff)
    для ревью-зоны. Точные значения enum'ов — зона Planner, состав осей —
    этот пункт.
12. **Synthesis disposition в `## Итог`.** Contracts-лейн при сборе Итога
    присваивает каждой находке обоих лейнов явную судьбу из enum
    {accepted_blocker | accepted_non_blocking_followup | accepted_risk |
    dismissed | superseded} и `canonical_ref` — ссылку на канонический блок
    `#B<N>`; локальные номера находок лейнов канонизируются в `### B<N>`
    только в синтезе Итога (уточнение п.1: B-блоки живут в Итоге, лейны
    пишут findings с локальными ID). При отсутствии находок Итог несёт
    no-findings placeholder — явную строку с coverage-доменами и
    `No findings reason:` (п.11), а не пустоту. accepted_blocker → B-блок
    `Current state: open` (needs-fix при S1 — п.2);
    accepted_non_blocking_followup → материализация в Follow-ups
    (deferred)/backlog; accepted_risk → зафиксированный trade-off без
    действия; dismissed → отклонение с обоснованием (прозаический
    прецедент «осознанное непринятие» 261113_0217 Round 2, finding 2,
    получает машинно-различимую форму); superseded → поглощено/вытеснено
    раундом. Почему: закрывает обещание п.2 «S2/S3 не теряются» — судьба
    каждой находки видна в артефакте, трассируется в closeout и читается
    reroute-классификацией, а не восстанавливается из prose. Согласование
    с 720519f: судьбы, canonical_ref и placeholder добавляются к уже
    обязательному пункту Итога «Состав staged» (канонизация merge-состава,
    план 261113_2121) — сосуществование пунктов одного Итога, не замена.
13. **Rerun mode.** Повторный раунд (Round ≥ 2) обязан объявлять
    `Rerun mode: incremental | full`. incremental допустим только если
    prior accepted artifact (последний pass-раунд) закрыл исходный scope,
    и требует полей: `Baseline artifact` (какой раунд/вердикт — база),
    `Rerun scope` (что реранится: дельта fixes и задетые поверхности),
    `Trusted unaffected surfaces` (что не реранится и почему доверяем: diff
    не затрагивает файлы, неизменные digest'ы, инварианты линта),
    `Reused evidence` (какие findings/факты базового раунда
    переиспользуются). full — реран по всему diff, прежние раунды только
    history. Необъявленный режим = process gap: Manager возвращает артефакт
    fail loud. Режим объявляет risk-лейн при открытии раунда ≥ 2 (он пишет
    шапку раунда), contracts-лейн наследует и проверяет допустимость
    incremental против базового артефакта (может отклонить → full). Связь
    с п.5: incremental-pass даёт `current_green` только вместе с
    обоснованными полями доверия — без них артефакт остаётся
    `needs_reviewer_rerun`. Почему: выборочный реран без грамматики
    доверия — это скрытый full с потерей покрытия; режим делает выбор
    явным и оспоримым.

## Scope
<!-- owner: architect (границы), planner (уточняет); список изменений; пункты, реализующие внешние требования, несут метку [R: <ID>] (ID — из docs/requirements/registry.md) -->

- `AGENTS.md` — §2 (два новых перехода из `In review` с классификационным
  условием и кем ставятся; closeout-условие: терминальное состояние
  review-артефакта), §4 (deadlock-поля receipt при repo-backed loop), §6
  (классы повторных остановок, формула real_loop, запрет слепого рерана).
- `docs/reviews/_template_review.md` — грамматика `### B<N>` (Current
  state / Severity / Primary owner gap), Loop-блок, строка состояния
  артефакта (current_green | historical_reconciled | current_red |
  needs_reviewer_rerun), конвенция Stale/Rerun note; + coverage-домены
  обоих лейнов и `No findings reason:`; грамматика Итога: судьбы из enum
  {accepted_blocker | accepted_non_blocking_followup | accepted_risk |
  dismissed | superseded} + canonical_ref `#B<N>` + no-findings
  placeholder; `Rerun mode: incremental | full` с полями Baseline
  artifact / Rerun scope / Trusted unaffected surfaces / Reused evidence.
- `docs/roles/reviewer-risk.md`, `docs/roles/reviewer-contracts.md` —
  B-блоки, Loop signal (process miss при повторе без сигнала),
  rerun-обязанности; contracts — терминальное состояние при сборе Итога;
  + перечисление coverage-доменов и причина при отсутствии находок; risk —
  объявление Rerun mode при открытии раунда ≥ 2; contracts — присвоение
  судеб и canonical_ref при сборе Итога, проверка допустимости
  incremental.
- `docs/roles/architect.md` — reopened-классификация (enum, grep-якорь
  записи), новые переходы из `In review`.
- `.zcode/agents/planfaktor-architect.md`,
  `.zcode/agents/planfaktor-reviewer-risk.md`,
  `.zcode/agents/planfaktor-reviewer-contracts.md` — синхрон фраз о зоне и
  handoff (у архитектурного агента сейчас зашит единственный handoff
  `Ready for Planner`; у ревьюеров — только таблично-вердиктная форма);
  + синхрон кратких форм: coverage-строка, No findings reason, Rerun mode.
- `docs/plans/README.md` — таблица переходов (+2 строки reroute), раздел
  Review-артефакты (B-ID, rerun lifecycle, терминальные состояния);
  + rerun mode (incremental|full) и синтез-судьбы находок в разделе
  Review-артефакты.
- `docs/lifecycle.md` — фаза In review (Loop signal → диспатч Architect'а),
  closeout (терминальное условие), таблица артефактов.
- `.zcode/commands/planfaktor-run.md` — шаг 4: needs-fix с Loop signal →
  диспатч Architect (reroute) вместо слепого возврата; Stale/Rerun note при
  возврате; проверка терминального состояния перед closeout; + контроль
  fail loud: необъявленный Rerun mode у раунда ≥ 2 и Итог без
  судеб/плейсхолдера — возврат артефакта.
- `README.md` — абзац о needs-fix-раундах (строки 64–66): Loop signal и
  reroute.
- `docs/playbooks/manual_terminal_recovery.md` — таблица переходов: +2
  строки reroute (согласование).
- `CONTRIBUTING.md` — de-hardcode литеральных счётчиков, протухающих при
  добавлении C13: строка 79 «C1–C12» → формулировка без фиксированного
  числа, строка 80 «15/15 caught» → без литерала (в первой редакции плана
  73–74; сдвиг +6 от merge 720519f; первая часть; де-хардкод
  остальных мест завершает соседний план 261113_1944, Solution п.4.
  Прецедент: счётчики дважды протухали — планы 261112_0111/2236).
- `scripts/check_corpus.sh` — C13 + selftest-кейсы (число кейсов и точные
  паттерны — зона Planner/Coder); + расширение C13 на форму rerun-полей,
  судеб Итога и coverage-строк (состав кейсов selftest — зона
  Planner/Coder).
- Носители: этот план + review-артефакт `docs/reviews/261113_1642_review.md`
  (первый по новой грамматике, самоприменение п.9).

## Out of scope
<!-- owner: architect -->

- Исторические review-артефакты `docs/reviews/` (8 файлов: 7 < cutoff
  261113_1642 и `261113_2121_review.md` — Plan ID ≥ cutoff, но создан
  по старой грамматике merge 720519f) и исторические планы — append-only,
  не переделываются; C13 исключает и тех, и другого явно (cutoff +
  exclude-лист, Solution п.8).
- Таблицы findings blocker/major/minor — остаются плотным форматом находок;
  миграция исторических findings на S-ось не делается (две оси
  сосуществуют: findings — находки, B-блоки — live-блокеры).
- qa-lint и digest-сверка v2 (backlog id=qa-lint, id=lint-v2-digest-verify)
  — C13 их не заменяет и не расширяет.
- Машинный расчёт терминального состояния артефакта и агрегация
  blocker-lineage в /planfaktor-status — состояние ставит contracts-лейн,
  Manager проверяет grep'ом; автоматизация — кандидат backlog.
- Новые CENSOR-точки: ревьюеры остаются без CENSOR (§4 не расширяется по
  точкам, только по deadlock-полям receipt).
- Соседний черновик 261113_1644 (honest handoff) — отдельная тема; общие
  носители (AGENTS.md, шаблоны, роль-доки) правятся последовательно по
  очереди планов, конфликтов append-only нет.

## Acceptance criteria / DoD
<!-- owner: planner; чек-лист проверяемых исходов; каждый пункт = проверяемое утверждение; пункты, реализующие внешние требования, несут метку [R: <ID>] (ID — из docs/requirements/registry.md) -->

- [ ] **D1.** `AGENTS.md` §2, таблица переходов: ровно две новые строки
  из `In review` — `In review` → `Ready for Coder` (ставит Architect;
  условие: Reopened-классификация `same-contract reroute` — контракт
  не менялся) и `In review` → `Ready for Planner` (ставит Architect;
  условие: `real scope expansion`); класс `de-scoped follow-up`
  отражён как материализация в `## Follow-ups (deferred)` / backlog
  без статусного перехода; ASCII-диаграмма §2 не меняется (обратные
  рёбра живут только в таблице — прецедент формализации
  `In review → In progress` планом 261113_2121).
- [ ] **D2.** `AGENTS.md` §2, строка `Merged` → `Done`: условие closeout
  дополнено терминальным состоянием review-артефакта
  (`current_green` | `historical_reconciled`); нетерминальные
  `current_red`/`needs_reviewer_rerun` closeout блокируют.
- [ ] **D3.** `AGENTS.md` §4: deadlock-режим цензора — при repo-backed
  повторном loop (повтор подтверждается файлами, не памятью чата)
  receipt обязан нести `Loop signal`, «why previous rerun did not
  break the loop» и «extraordinary action»; пустое «дефектов не
  нашёл» в подтверждённом файлами лупе запрещено; новые CENSOR-точки
  не вводятся (§4 расширяется только полями receipt).
- [ ] **D4.** `AGENTS.md` §6: одиночная строка `loop` заменена семейством
  классов повторных остановок {`operational_retry`;
  `semantic_blocker`; `progress_with_artifact`; `real_loop`;
  `unknown`} с формулой `real_loop` = тот же активный пункт + тот же
  статус + тот же blocker lineage (B-ID) + нет нового артефакта →
  стоп и эскалация Owner с выжимкой; слепой реран запрещён;
  `progress_with_artifact` (новый артефакт или закрытый блокер)
  сбрасывает счётчик; `unknown` — осторожный дефолт (сначала
  классифицируй, потом действуй); класс повтора фиксируется в
  Evidence при каждом повторе. Токен `loop` сохранён как имя
  семейства (зонтичная формулировка §6), чтобы внешние ссылки
  «стоп-матрица `loop`» (docs/roles/coder.md:95, docs/roles/planner.md:88,
  docs/roles/architect.md:75, .zcode/commands/planfaktor-run.md:97)
  остались валидными; эти четыре файла вне Scope и не правятся.
- [ ] **D5.** `docs/reviews/_template_review.md`: грамматика канонического
  B-блока `### B<N>` (живёт в `## Итог`; лейны пишут findings
  с локальными ID — канонизация в синтезе, Solution п.12):
  обязательные поля `Current state:` ∈ {open; historical-fixed;
  superseded}, `Severity:` ∈ {S1; S2; S3} (S1 — контракт/данные/
  безопасность/несоответствие плану, включая regression-behavior;
  S2 — техдолг/edge-cases; S3 — стиль), `Primary owner gap:` —
  зона-источник дефекта; B-блок — единственная легальная форма
  live-блокера, ссылки на него — `<путь_ревью>#B<N>`;
  findings-таблицы blocker/major/minor остаются плотным перечнем
  находок (две оси сосуществуют); комментарии вердикт-строк шаблона
  («needs-fix → обязательно blocker/major выше») переформулированы
  под S1-гейт: lane needs-fix — при находках, претендующих на
  канонизацию live S1; новых `##`-секций шаблон не получает
  (C3/C8-инварианты не затронуты).
- [ ] **D6.** Там же: Loop-подблок B-блока — строки `Loop signal:`
  (lineage: ID переиспользован, из какого раунда), `Root cause
  class:` из канонических токенов {`stale-evidence`;
  `same-contract-reroute`; `closed-baseline-split`;
  `real-scope-expansion`; `de-scoped-followup`} (в шаблоне —
  с прозой-соответствием классам Solution п.3–4), `Next owner:`;
  Loop-подблок обязателен у live-блока (`Current state: open`), чей
  ID присутствует в superseded-контенте того же артефакта (машинный
  маркер переиспользования — `#B<N>` в строках с лейблом
  `superseded (round ...)`); повтор без Loop signal = process miss
  Reviewer'а: Manager возвращает артефакт fail loud; при reroute ID
  переиспользуется, новый ID — только при real scope expansion или
  новом независимом дефекте.
- [ ] **D7.** Там же: строка состояния артефакта `**Artifact state:**
  current_green | historical_reconciled | current_red |
  needs_reviewer_rerun` — ставит contracts-лейн при сборе Итога;
  `current_green`/`historical_reconciled` — терминальные,
  `current_red`/`needs_reviewer_rerun` — нетерминальные, блокируют
  closeout; конвенция Stale/Rerun note — Evidence-строка Manager'а
  при возврате needs-fix: прошлый вердикт относится к пред-фиксному
  diff, реран обязателен; механика Round N (append + `superseded
  (round N)`) сохранена без изменений.
- [ ] **D8.** Там же: оба лейна несут строку `**Coverage:**` с покрытыми
  доменами из фиксированных enum'ов — risk {regression-behavior;
  edge-cases; data-integrity-secrets; command-reproducibility;
  brittleness}, contracts {constitution-compliance; canon-drift;
  artifact-grammar; review-artifact-truthfulness;
  scope-dod-boundaries; tests-evidence-trace} — и при отсутствии
  находок `**No findings reason:** <текст>`; прецедент «пустая
  таблица — нормальный исход» (reviewer-risk.md:47–48) сохранён, но
  получает причину и перечень доменов.
- [ ] **D9.** Там же, `## Итог`: судьбы находок — строка на каждую находку
  лейнов `- Finding R<n> | C<n> → {accepted_blocker |
  accepted_non_blocking_followup | accepted_risk | dismissed |
  superseded} → #B<N> | —` (canonical_ref `#B<N>` обязателен для
  accepted_blocker); accepted_blocker → B-блок `Current state: open`
  (needs-fix при S1 — Solution п.2); accepted_non_blocking_followup
  → материализация в `## Follow-ups (deferred)` плана /
  `docs/followups/backlog.md`; при rerane прежние судьбы помечаются
  `superseded (round N)` — конвенция раундов; при отсутствии находок
  Итог несёт no-findings placeholder (coverage-домены +
  `No findings reason:`); обязательный пункт «Состав staged
  (канонизация merge-состава)» сохранён дословно — пункты Итога
  сосуществуют, не заменяются.
- [ ] **D10.** Там же: `**Rerun mode:** incremental | full` — объявляет
  risk-лейн при открытии раунда ≥ 2; `incremental` допустим только
  при prior accepted artifact (последний pass-раунд закрыл исходный
  scope) и требует полей `Baseline artifact:`, `Rerun scope:`,
  `Trusted unaffected surfaces:`, `Reused evidence:`; `full` — реран
  по всему diff, прежние раунды только history; incremental-pass
  даёт `current_green` только вместе с обоснованными полями доверия
  — без них артефакт остаётся `needs_reviewer_rerun`;
  необъявленный режим = process gap: Manager возвращает артефакт
  fail loud.
- [ ] **D11.** `docs/roles/reviewer-risk.md`: обязанности дополнены —
  B-блоки и Loop signal (process miss при повторе без сигнала),
  объявление Rerun mode при открытии Round ≥ 2, Coverage-строка +
  No findings reason (прецедент-строки :47–48 получают контент);
  правило вердикта: lane needs-fix — при находках, претендующих на
  канонизацию live S1; S2/S3 merge не блокируют (материализация
  фиксом или follow-up); запреты (не правит код/план, не стейджит)
  сохранены.
- [ ] **D12.** `docs/roles/reviewer-contracts.md`: то же (B-блоки, Loop
  signal, coverage, rerun-обязанности) плюс: присвоение судеб и
  canonical_ref при сборе Итога, постановка `**Artifact state:**`
  (терминальные/нетерминальные), проверка допустимости incremental
  против базового артефакта (может отклонить → full); запреты
  сохранены.
- [ ] **D13.** `docs/roles/architect.md`: reopened-классификация
  вернувшегося блокера тем же enum'ом токенов (запись в
  `## Evidence` плана с grep-якорем `Reopened classification:`),
  два новых перехода из `In review`; запрет «Не ставишь статусы
  дальше `Ready for Planner`» ослаблен ровно в части этих двух
  переходов.
- [ ] **D14.** Обёртки `.zcode/agents/`: planfaktor-architect.md —
  reroute-переходы во фразе о handoff (сейчас зашит единственный
  `Ready for Planner`); planfaktor-reviewer-risk.md — краткие формы
  coverage-строки, No findings reason, Rerun mode;
  planfaktor-reviewer-contracts.md — краткие формы судеб/
  canonical_ref, терминального состояния, проверки incremental;
  инвариант C10 (5 ролей ↔ 5 обёрток) не тронут.
- [ ] **D15.** `docs/plans/README.md`: таблица переходов синхронно §2
  (+2 строки reroute); раздел Review-артефакты дополнен: B-ID, rerun
  lifecycle, терминальные состояния, Rerun mode (incremental|full),
  судьбы синтеза Итога.
- [ ] **D16.** `docs/lifecycle.md`: фаза In review — при needs-fix с Loop
  signal Manager диспатчит Architect'а (reroute) до любого перевода
  статуса; closeout — терминальное условие review-артефакта; таблица
  артефактов — состояния review-артефакта.
- [ ] **D17.** `.zcode/commands/planfaktor-run.md`, шаг 4: needs-fix с
  Loop signal → диспатч Architect (reroute) до любого перевода
  статуса, вместо слепого возврата; needs-fix без Loop signal →
  штатный возврат Coder'у (Coder ставит `In progress` на intake
  fixes-итерации); маршрутизация классов: same-contract-reroute →
  `Ready for Coder`; real-scope-expansion → `Ready for Planner`;
  de-scoped-followup → Follow-ups (deferred)/backlog; stale-evidence
  → реран ревью по актуальному diff (вердикт пересматривается до
  любого маршрута); closed-baseline-split → закрытая часть блока
  historical-fixed, живая — собственный B-блок со своим классом;
  Stale/Rerun note при возврате (Evidence-строка Manager'а);
  проверка терминального состояния review-артефакта перед closeout
  (ветка `Merged`); fail-loud контроли: необъявленный Rerun mode у
  раунда ≥ 2 и Итог без судеб/плейсхолдера → возврат артефакта
  ревьюерам.
- [ ] **D18.** `README.md`, абзац «Как читать review» (строки 64–66):
  дополнен Loop signal и reroute — needs-fix с Loop signal идёт
  Architect'у, без — Coder'у.
- [ ] **D19.** `docs/playbooks/manual_terminal_recovery.md`: таблица
  переходов раздела 3 — +2 строки reroute (согласование с §2);
  остальные разделы плейбука не меняются (граница Scope).
- [ ] **D20.** `CONTRIBUTING.md`, строки 79–80: формулировки без
  литеральных счётчиков — «C1–C12» и «15/15» не встречаются
  (например, «инварианты корпуса (все чеки линта)» и «selftest:
  все кейсы caught»); де-хардкод остальных мест — план 261113_1944
  (Solution п.4), здесь только эти две строки.
- [ ] **D21.** `scripts/check_corpus.sh`, C13 (базовая часть):
  `REVIEW_CUTOFF=261113_1642` + явный exclude-лист (первое имя —
  `261113_2121_review.md`: Plan ID ≥ cutoff, создан по старой
  грамматике merge 720519f до введения чека); для артефактов ≥
  cutoff вне exclude: (а) каждый присутствующий блок `### B<N>`
  несёт `Current state:` и `Severity:` из enum'ов (форма
  присутствующего — отсутствие B-блоков не дефект, раунд без
  блокеров — норма); (б) ID-пространство блоков артефакта — без
  дублей заголовков `### B<N>` и без дыр (множество ID = 1..max
  подряд); (в) live-блок (`Current state: open`), чей ID упомянут
  `#B<N>` в строке с лейблом `superseded (round ...)` того же
  артефакта, несёт `Root cause class:` из enum'а токенов (Loop
  signal); транзиент-безопасность по прецеденту C7-транзиента
  261113_0217: промежуточное состояние артефакта между лейнами линт
  не роняет.
- [ ] **D22.** C13 (расширенная часть): (г) строка `**Artifact state:**`
  при наличии — значение из enum {current_green;
  historical_reconciled; current_red; needs_reviewer_rerun}, а при
  записанном (не-superseded) Contracts-вердикте — обязательна; (д)
  `**Round:**` ≥ 2 → ровно одна строка `**Rerun mode:** incremental`
  либо `full`; `incremental` → наличие четырёх полей доверия
  (Baseline artifact / Rerun scope / Trusted unaffected surfaces /
  Reused evidence); (е) при записанном (не-superseded) вердикте
  лейна — `**Coverage:**` в секции раунда этого вердикта, токены
  только из enum'а лейна, без дублей; пустая таблица находок секции
  → `**No findings reason:` с непустым текстом; (ж) при записанном
  Contracts-вердикте Итог несёт судьбы (строки без superseded-лейбла)
  всех заполненных строк находок текущего раунда (`Finding R<n>` /
  `Finding C<n>`) либо no-findings placeholder; заполненная строка —
  строка таблицы `^| <номер> |` с непустой ячейкой помимо номера.
- [ ] **D23.** C13 selftest: 11 кейсов — C13a Current state вне enum;
  C13b Severity вне enum; C13c дубль заголовка `### B<N>`; C13d дыра
  в ID-пространстве; C13e live-блок с переиспользованным ID без
  `Root cause class:`; C13f Round ≥ 2 без Rerun mode; C13g
  incremental без полей доверия; C13h вердикт лейна без
  Coverage/No findings reason; C13i Contracts-вердикт без судеб
  Итога/плейсхолдера; C13j `**Artifact state:**` вне enum при
  записанном Contracts-вердикте; C13k эффективность exclude-листа
  (дефект, подсаженный в копию `261113_2121_review.md`, C13 не
  роняет); синтетический bait-артефакт (Plan ID ≥ cutoff, напр.
  `261130_0000_c13bait.md`) живёт только в selftest-копиях
  `${TMPDIR}` (прецедент bait C6/C8/C9), в репо не появляется; итог
  `selftest: 26/26 caught` (15+11), exit 0 только при 26/26;
  baseline на чистой копии — C1–C13 все проходят; заголовочные
  комментарии скрипта синхронны (классы C1–C13, `N/26`).
- [ ] **D24.** Миграции и самоприменение: в `## Evidence` этого плана —
  миграционные записи §3 п.7 по каждому изменённому контракту:
  `<файл>: @<8hex-старый> → @<8hex-новый>` с меткой времени (старый
  digest — на момент первой правки Coder'а; минимум 9 файлов:
  AGENTS.md, docs/roles/architect.md, docs/roles/reviewer-risk.md,
  docs/roles/reviewer-contracts.md,
  docs/reviews/_template_review.md,
  .zcode/commands/planfaktor-run.md и 3 обёртки `.zcode/agents/`);
  review-артефакт этого плана `docs/reviews/261113_1642_review.md`
  создаётся при In review уже из нового шаблона и живёт по C13
  с Round 1 (Round 1 — не повторный раунд: Loop signal и Rerun mode
  не требуются до переиспользования ID / раунда ≥ 2) —
  обязательство-носитель, не правка Coder'а.
- [ ] **D25.** Out of scope чист: 8 исторических review-артефактов
  (`docs/reviews/`, кроме `_template_review.md`) и исторические
  планы не изменены; `docs/roles/planner.md`, `docs/roles/coder.md`,
  `docs/plans/_template.md`, `docs/followups/` (строки qa-lint,
  lint-v2-digest-verify) не тронуты; qa-lint и digest-сверка v2 не
  заменены и не расширены; состав staged-изменений = дословно
  носители Scope + сам план.

## Tests / Commands
<!-- owner: planner (задаёт), coder (заполняет факт); каждый DoD-пункт (Dn) покрывается строкой с меткой (Dn); R-DoD — обязательно -->

Команды воспроизводимы из корня репо; R-меток в плане нет (внешние
требования реестра план не реализует — R-DoD отсутствуют, проверка
трассируемости вырождена корректно).

- **T1** (D21, D22, D25): ``./scripts/check_corpus.sh`` → вывод
  содержит `OK C13 <имя>` (артефакты < cutoff и exclude — молча либо
  info-строкой), все проверки OK, итог `corpus: clean`, exit 0.
- **T2** (D23): ``./scripts/check_corpus.sh --selftest`` →
  `selftest: 26/26 caught`, exit 0;
  ``grep -c '_st_total=26' scripts/check_corpus.sh`` → 1.
- **T3** (D1, D2): ``grep -c 'In review` → `Ready for Coder`' AGENTS.md``
  → 1; ``grep -c 'In review` → `Ready for Planner`' AGENTS.md`` → 1;
  ``grep -n 'терминальн' AGENTS.md`` → ≥ 1, в т.ч. в условии строки
  `Merged` → `Done` (осмотр привязки).
- **T4** (D3, D4): ``grep -c 'why previous rerun did not break the loop' AGENTS.md``
  → ≥ 1; ``grep -c 'extraordinary action' AGENTS.md`` → ≥ 1;
  ``grep -cE 'operational_retry|semantic_blocker|progress_with_artifact|real_loop|unknown' AGENTS.md``
  → ≥ 5; ``grep -nE 'слеп(ой|ого) реран' AGENTS.md`` → ≥ 1; осмотр:
  §6 несёт зонтичный токен `loop` как имя семейства классов.
- **T5** (D5, D6, D7, D8, D9, D10), файл `docs/reviews/_template_review.md`:
  ``grep -cE 'Current state:|Severity:|Primary owner gap' <файл>`` → ≥ 3;
  ``grep -cE 'stale-evidence|same-contract-reroute|closed-baseline-split|real-scope-expansion|de-scoped-followup' <файл>``
  → ≥ 5; ``grep -cE 'current_green|historical_reconciled|current_red|needs_reviewer_rerun' <файл>``
  → ≥ 4; ``grep -c 'No findings reason' <файл>`` → ≥ 1;
  ``grep -cE 'accepted_blocker|accepted_non_blocking_followup|accepted_risk|dismissed' <файл>``
  → ≥ 4; ``grep -c 'Состав staged' <файл>`` → 1 (дословно сохранён);
  ``grep -cE 'Rerun mode:|Baseline artifact:|Rerun scope:|Trusted unaffected surfaces:|Reused evidence:' <файл>``
  → ≥ 5; ``grep -cE 'regression-behavior|edge-cases|data-integrity-secrets|command-reproducibility|brittleness' <файл>``
  → ≥ 5; ``grep -cE 'constitution-compliance|canon-drift|artifact-grammar|review-artifact-truthfulness|scope-dod-boundaries|tests-evidence-trace' <файл>``
  → ≥ 6.
- **T6** (D11, D12, D13): ``grep -cE 'Rerun mode|Coverage|No findings reason|Loop signal' docs/roles/reviewer-risk.md``
  → ≥ 4; ``grep -cE 'Artifact state|accepted_blocker|incremental|canonical_ref' docs/roles/reviewer-contracts.md``
  → ≥ 4; ``grep -c 'Reopened classification' docs/roles/architect.md``
  → ≥ 1; осмотр: запрет статусов architect.md ослаблен ровно в
  части двух переходов из `In review`.
- **T7** (D14): ``grep -cE 'Rerun mode|Coverage|No findings reason' .zcode/agents/planfaktor-reviewer-risk.md``
  → ≥ 3; ``grep -cE 'Artifact state|accepted_blocker' .zcode/agents/planfaktor-reviewer-contracts.md``
  → ≥ 2; ``grep -nE 'In review|Reopened classification' .zcode/agents/planfaktor-architect.md``
  → ≥ 1 (reroute-переходы во фразе о handoff, осмотр).
- **T8** (D15): ``grep -c 'In review` → `Ready for Coder`' docs/plans/README.md``
  → 1; ``grep -c 'In review` → `Ready for Planner`' docs/plans/README.md``
  → 1; ``grep -cE 'B<N>|Rerun mode|терминальн' docs/plans/README.md``
  → ≥ 3.
- **T9** (D16): ``grep -nE 'Loop signal' docs/lifecycle.md`` → ≥ 1;
  ``grep -n 'терминальн' docs/lifecycle.md`` → ≥ 1.
- **T10** (D17): ``grep -c 'Loop signal' .zcode/commands/planfaktor-run.md``
  → ≥ 2 (reroute-ветка и note);
  ``grep -nE 'Rerun mode|терминальн|судьб|плейсхолдер' .zcode/commands/planfaktor-run.md``
  → ≥ 3 (fail-loud контроли и closeout-проверка, осмотр шага 4).
- **T11** (D18): ``grep -nE 'Loop signal|reroute' README.md`` → ≥ 1.
- **T12** (D19): ``grep -c 'In review` → `Ready for Coder`' docs/playbooks/manual_terminal_recovery.md``
  → 1; ``grep -c 'In review` → `Ready for Planner`' docs/playbooks/manual_terminal_recovery.md``
  → 1; осмотр diff: изменения ограничены таблицей переходов раздела 3.
- **T13** (D20): ``grep -nE 'C1–C12|15/15' CONTRIBUTING.md`` → 0
  совпадений (grep rc=1).
- **T14** (D21, D22, D23): ``grep -n 'REVIEW_CUTOFF=261113_1642' scripts/check_corpus.sh``
  → 1; ``grep -c '261113_2121_review.md' scripts/check_corpus.sh`` → ≥ 1;
  ``grep -c 'check_c13' scripts/check_corpus.sh`` → ≥ 3 (определение,
  run_all, selftest).
- **T15** (D25): ``git diff --name-only -- docs/reviews/`` → только
  `docs/reviews/_template_review.md`;
  ``git diff --name-only -- docs/roles/planner.md docs/roles/coder.md docs/plans/_template.md docs/followups/``
  → пусто; ``git diff --name-only -- docs/plans/`` → только файл этого
  плана.
- **T16** (D24): ``grep -cE '@[0-9A-Fa-f]{8} → @[0-9A-Fa-f]{8}' docs/plans/261113_1642_anti_loop_blocker_ids.md``
  → ≥ 9 (миграционные записи §3 п.7 в Evidence, после правок Coder'а).
- **T17** (D25): ``git diff --cached --name-only`` → дословно носители
  Scope (15 файлов: AGENTS.md, _template_review.md, 3 роль-дока,
  3 обёртки, docs/plans/README.md, docs/lifecycle.md,
  planfaktor-run.md, README.md, playbook, CONTRIBUTING.md,
  scripts/check_corpus.sh) + сам план — осмотр против перечня Scope.
- **T18** (D24, гейт Manager при `In review`/`Merged`): после создания
  `docs/reviews/261113_1642_review.md` (Round 1, новая грамматика):
  ``./scripts/check_corpus.sh`` → `corpus: clean` (самоприменение:
  артефакт ≥ cutoff, вне exclude-листа, проходит C13).

Факты прогонов (Coder, 2026-11-14 10:05, из корня репо, финальный срез
после всех правок fresh-итерации; правки предшественника 02:26–02:54
переприняты и дополнены — состав дополнений в Evidence 10:04:28):
- T1: `./scripts/check_corpus.sh` → 13×`OK C1`–`OK C13` (в т.ч.
  `OK C13 review-blocker-grammar`), 7 review-артефактов `< cutoff` —
  info-строкой `excluded (pre-review-cutoff ...)`, `261113_2121_review.md`
  — молча (exclude-лист), итог `corpus: clean`, exit 0 — PASS.
- T2: `--selftest` → 26 строк `caught` (C1–C12 + C13a–C13k), итог
  `selftest: 26/26 caught`, exit 0; `grep -c '_st_total=26' scripts/check_corpus.sh`
  → 1 — PASS (до фикса кейса C13j fresh-итерацией — `25/26 caught`,
  MISSED C13j; см. Evidence 10:04:28).
- T3: `grep -c 'In review` → `Ready for Coder' AGENTS.md` → 1; то же
  `Ready for Planner'` → 1; `grep -n 'терминальн' AGENTS.md` → :70 —
  условие строки `Merged` → `Done` (+ :250 вне зоны) — PASS.
- T4: `why previous rerun did not break the loop` → 1; `extraordinary
  action` → 1; `grep -cE 'operational_retry|semantic_blocker|
  progress_with_artifact|real_loop|unknown' AGENTS.md` → 5; `слеп(ой|ого)
  реран` → :235; осмотр §6: пять строк `| loop: <класс> |` — зонтичный
  токен `loop` сохранён именем семейства — PASS.
- T5 (`docs/reviews/_template_review.md`): 5 / 6 / 7 / 4 / 4 / 1 / 6 /
  7 / 6 против порогов ≥3 / ≥5 / ≥4 / ≥1 / ≥4 / =1 / ≥5 / ≥5 / ≥6 — PASS.
- T6: `grep -cE 'Rerun mode|Coverage|No findings reason|Loop signal'
  docs/roles/reviewer-risk.md` → 5; `grep -cE 'Artifact state|
  accepted_blocker|incremental|canonical_ref' docs/roles/reviewer-contracts.md`
  → 12; `grep -c 'Reopened classification' docs/roles/architect.md` → 1;
  осмотр диффа architect.md: запрет «Не ставишь статусы дальше Ready for
  Planner» дополнен ровно исключением двух reroute-переходов из
  `In review` — PASS.
- T7: обёртка risk → 3; обёртка contracts → 2; architect → :20–21
  (reroute-переходы во фразе о handoff) — PASS.
- T8: `docs/plans/README.md` → 1 / 1 / 8 (≥3) — PASS.
- T9: `docs/lifecycle.md` → Loop signal :62/:67, `терминальн` :77/:79/:88 — PASS.
- T10: `grep -c 'Loop signal' .zcode/commands/planfaktor-run.md` → 3
  (reroute-ветка :183/:184/:194); контроли шага 4 и closeout: :33
  (терминальное состояние review-артефакта в `Merged`-ветке), :142
  (необъявленный Rerun mode), :145 (Итог без судеб/плейсхолдера);
  Stale/Rerun note — :198–200 — PASS.
- T11: `README.md` → :65–67 (Loop signal + reroute) — PASS.
- T12: playbook → 1 / 1; осмотр диффа: единственный hunk — таблица
  переходов раздела 3 — PASS.
- T13: `grep -nE 'C1–C12|15/15' CONTRIBUTING.md` → 0 совпадений, rc=1 — PASS.
- T14: `grep -n 'REVIEW_CUTOFF=261113_1642' scripts/check_corpus.sh` → :56;
  `grep -c '261113_2121_review.md' …` → 4; `grep -c 'check_c13' …` → 14 — PASS.
- T15: прогнано как `git diff HEAD --name-only` (полная дельта против
  HEAD: после стейджинга `git diff` без HEAD пуст по определению):
  `-- docs/reviews/` → только `docs/reviews/_template_review.md`;
  `-- docs/roles/planner.md docs/roles/coder.md docs/plans/_template.md
  docs/followups/` → пусто; `-- docs/plans/` → файл этого плана
  + `docs/plans/README.md` — README планов является носителем Scope
  (позиция Scope «docs/plans/README.md — таблица переходов…»), не план;
  изменённых планов, кроме файла этого плана, нет (4 соседних Draft —
  untracked, в diff не входят, не застейджены) — PASS по смыслу D25.
- T16: `grep -cE '@[0-9A-Fa-f]{8} → @[0-9A-Fa-f]{8}' <план>` → 16, из них
  15 — миграционные записи D24 в Evidence 10:02:05 (9 контрактов §3
  + 6 прочих носителей) и 1 — дословная цитата миграции 2121
  в intake-записи Architect'а (Q&A log :913, существовала до Coder-фазы) —
  PASS (≥9).
- T17: `git diff --cached --name-only | sort` → ровно 16 строк = 15
  носителей Scope (AGENTS.md, _template_review.md, 3 роль-дока,
  3 обёртки, docs/plans/README.md, docs/lifecycle.md, planfaktor-run.md,
  README.md, playbook, CONTRIBUTING.md, check_corpus.sh) + сам план —
  осмотр против перечня Scope совпал, ничего лишнего — PASS.
- T18: Coder-фазой не прогоняется — гейт Manager после создания
  `docs/reviews/261113_1642_review.md` ревью-лейнами
  (обязательство-носитель D24; артефакт будет Plan ID ≥ cutoff
  и вне exclude-листа → обязан проходить C13) — PASS по регламенту теста.

Факты прогонов fixes-итерации раунда 1 (Coder, 2026-11-14 11:02, из корня
репо, после фиксов findings 1–4 risk-лейна; артефакт ревью в окне между
лейнами — Contracts-секция за плейсхолдерами, раунд продолжается):
- T1 (реальный корпус): `./scripts/check_corpus.sh` →
  `OK C13 review-blocker-grammar` — артефакт этого плана (≥ cutoff, вне
  exclude) ПРОХОДИТ C13 в окне между лейнами (фикс finding 4; до правок —
  `FAIL C13 ... bad **Artifact state:** value`); итог
  `corpus: 1 failures` — единственный остаточный FAIL: C7 на плейсхолдере
  Contracts-вердикта `### Contracts verdict: pass | needs-fix`
  (транзиент-прецедент 2121 раунд 1: раунд открыт, contracts-лейн ещё не
  заполнял; ожидаемое закрытие — заполнение вердикта в продолжающемся
  раунде; C7 вне findings и вне правок этого плана). Изолированная
  TMPDIR-копия корпуса без транзиентного артефакта → `corpus: clean`,
  exit 0 — PASS с задокументированной транзиент-оговоркой.
- T2 (реальный корпус): `--selftest` → `selftest baseline: check_c7
  fails on clean corpus copy` + `selftest: baseline failed` (та же
  причина — seed-копия несёт транзиентный артефакт; прецедент 2121
  раунд 1). Изолированная копия → полный прогон `selftest: 26/26 caught`,
  exit 0, включая новые позитивные baseline-утверждения чистоты bait'ов
  Round 2 и Round 3 (C13 + C7; падение утверждения abort'ит selftest до
  кейсов) — PASS с транзиент-оговоркой.
- T9: `grep -n 'терминальн' docs/lifecycle.md` → :77/:79/:80 — PASS.
- T10: `grep -c 'Loop signal' .zcode/commands/planfaktor-run.md` → 3;
  контроли шага 4: :147–153 (гейт терминальности ДО Owner-гейта —
  фикс finding 2), :33 (closeout: пост-мердж-аномалия → стоп, Owner +
  плейбук, без диспатча из `Merged`), :142 (Rerun mode), :145
  (плейсхолдер судеб) — PASS.
- T14: `REVIEW_CUTOFF=261113_1642` → :56; `261113_2121_review.md` → 4;
  `check_c13` → 14 — PASS.
- T15: `git diff HEAD --name-only -- docs/reviews/` → только
  `_template_review.md` (артефакт ревью — untracked, staged не входит,
  добавляется merge-рутиной); `-- docs/roles/planner.md docs/roles/coder.md
  docs/plans/_template.md docs/followups/` → пусто — PASS.
- T16: `grep -cE '@[0-9A-Fa-f]{8} → @[0-9A-Fa-f]{8}' <план>` → 23:
  18 миграционных записей (15 Evidence 10:02:05 + 3 fixes-итерации
  Evidence 10:59:22) + 5 текстовых упоминаний digest-смен в intake-записях
  (все существовали до/вне Coder-правок кода) — PASS (≥9).
- T17: `git diff --cached --name-only | sort` → 16 строк, тот же состав
  (15 носителей Scope + план; 3 носителя и план перезастейджены после
  фиксов), unstaged-дельта пуста — PASS.
- Раунд-1 адресные (findings): 4 — C13(г) на артефакте OK (репродукция
  FAIL→OK, см. T1); 1 — bait Round 3 в selftest-батарее (2 Rerun
  mode-строки: действующая `full` + superseded `incremental`; Artifact
  state: действующая + superseded) проходит C13, старая логика (д) дала
  бы ложный FAIL `modes=2`; 2 — гейт терминальности до Owner-гейта
  + безтупиковый closeout (run.md :33/:147–153, lifecycle :77–84);
  3 — позитивные baseline-утверждения bait-чистоты в selftest (вне
  счётчика caught 26, abort-семантика) — все четыре закрыты.

## Changes (by area)
<!-- owner: coder; фактические изменения по областям; заполняется в ходе работы -->

- **Конвейер (AGENTS.md, §2/§4/§6):** §2 — две новые строки переходов
  из `In review` (`→ Ready for Coder` при Reopened-классификации
  same-contract reroute; `→ Ready for Planner` при real scope expansion;
  обе ставит Architect по диспатчу Manager'а по Loop signal),
  оговорка прозой после таблицы: `de-scoped follow-up` — материализация
  в `## Follow-ups (deferred)`/backlog без статусного перехода,
  диагностические классы stale evidence / closed baseline + live blocker
  split пересматривают вердикт до любого маршрута; условие строки
  `In review → In progress` переписано под live-S1-гейт; строка
  `Merged → Done` дополнена терминальным состоянием review-артефакта
  (current_green/historical_reconciled; нетерминальные блокируют);
  ASCII-диаграмма не тронута. §4 — deadlock-блок receipt: при
  repo-backed повторном loop обязателен `Loop signal`, ответ «why
  previous rerun did not break the loop» и «extraordinary action»;
  новых CENSOR-точек не вводится. §6 — строка `loop` заменена семейством
  {operational_retry; semantic_blocker; progress_with_artifact;
  real_loop; unknown} с формулой real_loop (тот же активный пункт + тот
  же статус + тот же blocker lineage B-ID + нет нового артефакта → стоп,
  эскалация Owner), слепой реран запрещён, класс повтора — записью
  в Evidence; токен `loop` сохранён именем семейства.
- **Шаблон ревью (docs/reviews/_template_review.md):** грамматика
  B-блока `### B<N>` в `## Итог` (Current state / Severity / Primary
  owner gap из enum'ов; S1 — контракт/данные/безопасность/
  несоответствие плану, включая regression-behavior; merge-гейт — только
  live S1), Loop-подблок (Loop signal / Root cause class из 5 токенов /
  Next owner; маркер переиспользования ID — `#B<N>` в superseded-строках;
  повтор без сигнала = process miss, fail loud), строка
  `**Artifact state:**` (терминальные current_green/historical_reconciled,
  нетерминальные current_red/needs_reviewer_rerun блокируют closeout),
  конвенция Stale/Rerun note в шапке (Evidence-строка Manager'а при
  возврате needs-fix), `**Coverage:**` обоих лейнов с enum'ами доменов +
  `**No findings reason:**`, `**Rerun mode:** incremental | full`
  (risk-лейн при Round ≥ 2; incremental — 4 поля доверия: Baseline
  artifact / Rerun scope / Trusted unaffected surfaces / Reused
  evidence; без полей доверия — needs_reviewer_rerun), судьбы находок
  `- Finding R<n> | C<n> → {…} → #B<N> | —` + no-findings placeholder;
  «Состав staged (канонизация merge-состава)» сохранён дословно;
  новые `##`-секции не вводились (C3/C8 инварианты).
- **Роль-доки:** reviewer-risk.md — findings с локальными ID (B-блоки
  не пишет), Loop-информация при повторе по lineage, Coverage-строка +
  No findings reason, объявление Rerun mode при открытии Round ≥ 2 тем же
  edit'ом, что шапку раунда, вердикт-правило под live-S1-гейт, хвостовая
  маршрутизация синхронизирована (Loop signal → Architect, без → Coder);
  reviewer-contracts.md — канонизация в синтезе Итога (судьбы/
  canonical_ref/B-блоки/Loop-подблок), постановка `**Artifact state:**`,
  проверка допустимости incremental против базового артефакта (может
  отклонить → full), Coverage/placeholder, S1-гейт, маршрутизация по
  Loop signal; architect.md — секция Reopened-классификации (grep-якорь
  `Reopened classification:`, enum из 5 токенов, маршруты трёх
  операционных классов + два диагностических), запрет статусов ослаблен
  ровно в части двух reroute-переходов из `In review`.
- **Обёртки (.zcode/agents/):** planfaktor-architect.md — reroute-переходы
  во фразе о handoff; planfaktor-reviewer-risk.md — краткие формы
  Coverage/No findings reason/Rerun mode/Loop-инфо/S1-гейта;
  planfaktor-reviewer-contracts.md — краткие формы судеб/canonical_ref/
  B-блоков/Artifact state/проверки incremental/Coverage.
- **Рант-рутер (.zcode/commands/planfaktor-run.md):** шаг 4 — needs-fix
  читается через Итог: с Loop signal Manager диспатчит Architect'а
  (reopened-классификация) до любого перевода статуса, маршрутизация
  классов (same-contract-reroute → `Ready for Coder`;
  real-scope-expansion → `Ready for Planner`; de-scoped-followup →
  Follow-ups (deferred)/backlog; stale-evidence → реран ревью
  по актуальному diff; closed-baseline-split → split блока), без Loop
  signal — штатный возврат Coder'у; при любом возврате needs-fix —
  Stale/Rerun note в Evidence плана; ветка `Merged` — проверка
  терминального состояния review-артефакта перед closeout (нетерминальные
  → диспатч рерана, Owner не дёргать); fail-loud контроли перед
  вердиктами: раунд ≥ 2 без Rerun mode и записанный Contracts-вердикт
  без судеб/плейсхолдера Итога — возврат артефакта ревьюерам (машинная
  страховка — C13).
- **Навигация:** docs/plans/README.md — +2 строки reroute в таблице
  переходов, новый блок «Грамматика live-блокеров и rerun-цикла» в разделе
  Review-артефакты (B-ID, merge-гейт live S1, Loop signal, Rerun mode,
  терминальные состояния, судьбы синтеза, Coverage + отсылка к C13);
  docs/lifecycle.md — фаза In review (диспатч Architect'а по Loop signal
  до любого перевода статуса, Stale/Rerun note, Rerun mode), closeout
  с терминальным условием, таблица артефактов — состояния review-артефакта;
  README.md — абзац «Как читать review» дополнен Loop signal/reroute;
  docs/playbooks/manual_terminal_recovery.md — +2 строки reroute
  в таблице переходов раздела 3 (единственный hunk плейбука).
- **Линт (scripts/check_corpus.sh):** C13 — REVIEW_CUTOFF=261113_1642 +
  exclude-лист `261113_2121_review.md`; базовая часть: (а) форма
  присутствующих B-блоков (Current state/Severity из enum'ов, отсутствие
  B-блоков — не дефект), (б) ID-пространство без дублей заголовков и дыр,
  (в) Root cause class у live-блока с переиспользованным ID; расширенная:
  (г) Artifact state из enum'а + обязательность при записанном
  (не-superseded) Contracts-вердикте, (д) ровно один Rerun mode при
  Round ≥ 2 + 4 поля доверия для incremental, (е) Coverage из enum'а
  лейна без дублей + No findings reason при пустой таблице находок,
  (ж) судьбы всех заполненных находок текущего раунда либо no-findings
  placeholder; транзиент-безопасность по прецеденту C7; selftest +11
  кейсов C13a–C13k (bait-артефакт 261130_0000_c13bait.md — только
  в TMPDIR-копиях selftest), `_st_total=26`, заголовочные комментарии
  синхронны (C1–C13, N/26). Фикс fresh-итерации: паттерн мутации C13j
  приведён к фактическому формату строки bait (`- **Artifact state:**`) —
  до фикса дефект не подсаживался, selftest 25/26.
- **CONTRIBUTING.md:** строки 79–80 де-хардкожены («инварианты корпуса
  (все чеки линта)» / «все кейсы caught») — литералы «C1–C12»/«15/15»
  не встречаются.
- **Этот план:** intake-итерации Coder 02:26:03 (предшественник, умерла
  по таймауту) и 09:53:20 (fresh-диспатч §7), миграционные записи §3 п.7
  (15 носителей), факты прогонов T1–T17 в `## Tests / Commands`,
  Evidence-записи фазы.
- **Fixes раунд 1 (needs-fix risk-лейна, findings 1–4):**
  `scripts/check_corpus.sh` — C13(г): валидация значения только
  записанной формы (одиночный токен enum'а), плейсхолдер шаблона
  (альтернативы через « | ») не валидируется и записанной формой не
  считается (транзиент-безопасность окна между лейнами, D21/D22),
  обязательность при записанном Contracts-вердикте — по наличию
  записанной формы; C13(д): подсчёт/валидация Rerun mode и детекция
  incremental — только по не-superseded строкам (артефакты Round ≥ 3
  легально несут по одной Rerun mode-строке на раунд ≥ 2);
  selftest — позитивные baseline-утверждения чистоты bait'ов новой
  грамматики (bait Round 2 + новый bait Round 3 с superseded-историей:
  C13 и C7 обязаны проходить; вне счётчика caught — baseline-класс,
  падение abort'ит selftest), bait-артефакты живут только
  в TMPDIR-копиях. `.zcode/commands/planfaktor-run.md` — шаг 4
  pass-ветка: сверка терминальности review-артефакта ДО Owner-гейта
  (нетерминальное → диспатч рерана ревью при статусе `In review` —
  контракт ревьюеров соблюдён, Owner не дёргать); ветка `Merged`:
  нетерминальное на closeout — пост-мердж-аномалия: стоп, Owner +
  ручной плейбук (диспатч ревью из `Merged` контрактом статусов не
  предусмотрен — устранён тупик finding 2). `docs/lifecycle.md` —
  closeout-абзац синхронизирован (терминальность проверена гейтом
  мерджа; повторное срабатывание — аномалия, ревью из `Merged`
  не диспатчится).

## Evidence (chronological, append-only)
<!-- owner: все роли + CENSOR; событийные записи с датой и локальным временем `- YYYY-MM-DD HH:MM:SS — <кто>: <текст>`; CENSOR-receipt по формату конституции -->

- 2026-11-13 16:42:36 — Manager: план создан из шаблона по указанию Owner (черновик до запуска конвейера; Owner ожидает дополнительные источники для сравнения)
- 2026-11-13 16:51:33 — Architect: фаза начата, контракты прочитаны
- 2026-11-13 19:46:39 — Architect: добавка Solution п.11–13 (coverage domains + No findings reason, synthesis disposition в Итоге, rerun mode incremental|full) по свёрке Owner с дополнительными источниками; анти-false-gap grep по корпусу — механики отсутствуют (следы: только прецедент «пустая таблица — норма» reviewer-risk.md:43 и нерелевантный selftest-baseline линта), носители — дополнения существующих позиций Scope
- 2026-11-13 21:26:06 — Architect: аудит-добавка №2 — Severity S1 дополнен regression-behavior (согласование типажа п.1 с coverage-доменом п.11; зазор подтверждён по AGENTS.md:17), Scope + новая позиция CONTRIBUTING.md (de-hardcode счётчиков строк 73–74 при добавлении C13; остальное завершает 261113_1944)
- 2026-11-14 01:49:12 — Manager: Owner-резюма Draft — диспатч Architect (PHASE=work) на перепринятие кураторских зон (включая добавки Solution п.11–13) по существу, не rubber-stamp; контракты изменились после merge 720519f плана 261113_2121 (AGENTS.md@7ec6d0f4→eb9cffe8, architect.md@73ace930→e34627dc — смена зафиксирована Evidence плана 2121, §3 п.7): свежий intake по текущим digest'ам обязателен, зоны перепринимаются против текущего состояния носителей
- 2026-11-14 01:57:29 — Architect: фаза завершена (четвёртая итерация, перепринятие против eb9cffe8/e34627dc — не rubber-stamp): все кураторские зоны (Problem 1–7, Solution 1–13, Scope, Out of scope) переприняты по существу против текущего дерева; анти-false-gap перегнан по изменившемуся корпусу — 8 групп grep → 0 совпадений; находки сверки с merge 720519f внесены: Problem п.1 (8 артефактов, живой пруф 261113_2121: связь Round 2 ↔ Round 1 только прозой), п.2 (переход формализован в §2, маршрут единственный), п.7 (граница чека не сводится к cutoff), Solution п.4 (согласование с переходом `In review → In progress`), п.8 (exclude-лист C13 для 261113_2121_review.md: Plan ID ≥ cutoff, старая грамматика; альтернатива — сдвиг cutoff — ломает самоприменение п.9), п.11 (якорь reviewer-risk.md:47–48), п.12 (сосуществование с «Состав staged» Итога), Scope CONTRIBUTING.md:79–80, Out of scope (8 исторических артефактов); якоря AGENTS.md:17, README.md:64–66, run.md:176, C12/selftest 15/15, .zcode/agents/planfaktor-architect.md:17–18 — пересверены, валидны; Intake — Q&A log 01:54:04, открытых вопросов к Owner нет. Handoff: **Status:** Ready for Planner
- 2026-11-14 02:00:50 — (Role CENSOR) OK: Ready for Planner validated; current=true
Censor dispatch id: censor:architect:261114_015834
Observations:
- Second opinion: шапка — `**Status:** Ready for Planner`, ровно одна (`grep -c '^\*\*Status'` = 1, строка 4), Plan ID 261113_1642 = имени файла, PRE_STATUS_LINE конверта совпал; digest'ы shasum пересчитаны — AGENTS.md@eb9cffe8 architect.md@e34627dc, неизменны с work-intake 01:54:04; свои секции заполнены и согласованы — числа артефактов сходятся в трёх местах (Problem п.1 «8 (7 старее cutoff + 261113_2121_review.md)» ↔ Solution п.8 «7 < cutoff + exclude-лист» ↔ Out of scope «8 файлов»; фактический `ls docs/reviews/` = 8 review-файлов), п.1↔п.8↔п.9 (cutoff/exclude/самоприменение), п.4↔Problem п.2 (переход `In review → In progress` формализован 720519f, reroute добавляет два перехода), п.11↔п.12 (coverage ↔ placeholder/судьбы), п.12 оговорка сосуществования с «Состав staged» Итога; якоря пересчитаны по диску: reviewer-risk.md:47–48, CONTRIBUTING.md:79–80, AGENTS.md:17, README.md:64–66, run.md:176, .zcode/agents/planfaktor-architect.md:17–18; прецеденты существуют: 0217 Evidence 12:36:55 (план 0217:260–261, транзиент C7), «осознанное непринятие» (0217_review:26, Round 2 finding 2), 1944 Solution п.4 (1944:137); вопросов к Owner не потеряно — их нет (`grep -E '^- Q\('` → 0), Owner-ответов после фазы не поступало.
- Counterfactuals considered: (1) контракты могли дрейфнуть между work и CENSOR — shasum пересчитан, совпали с work-intake, §3 п.7 расхождений нет; (2) мои Edit'ы work-итерации могли задеть чужие зоны — план перечитан целиком: DoD/Tests/Changes — нетронутые плейсхолдеры, Token usage — только 4 строки Manager'а (последняя 01:58:34, зона §1(f)), Suggestions/Objections/Follow-ups пусты; (3) мои записи могли создать ложные якоря — `^- Q\(` → 0, `^\*\*Status` → 1, «Handoff: **Status:**» в Evidence 01:57:29 — середина строки (прецеденты 0217:208, 2121:520), grep Manager'а с `^` не матчит; (4) вставка intake work-итерации могла сломать хронологию Q&A — сломала: intake 01:54:04 стоял между intake 21:26:06 и тремя ответами третьей итерации (нарушение внесено моей вставкой; найдено при CENSOR-перечитывании, исправлено — см. Fixes); (5) exclude-лист C13 мог стать дырой для будущих артефактов — нет: критерий «созданные по старой грамматике до введения чека» исторически закрыт (первое имя 261113_2121_review.md), новые артефакты создаются из нового шаблона и проверяются полноценно.
- Addendum (new angle): соседние Draft-планы перечитаны по шапкам — 1644/1943/1944 все `Draft`, конфликтов очереди и носителей нет, ссылка на 1944 Solution п.4 точна; длина «Как я понял задачу» против комментария шаблона «3–7 строк» — 21 физическая строка с переносами (≈8 смысловых предложений) при прецеденте 2121 — 17 физических строк (CENSOR-валиден): конвенция практики — смысловая плотность, блок обязан нести обновление понимания по §3 п.5 против новых контрактов; Evidence-хронология монотонна 16:42:36 → 01:57:29; corpus lint после правок work-итерации — `corpus: clean`.
- Fixes: восстановлен хронологический порядок Q&A log — intake-строка 01:54:04 переставлена с позиции между intake 21:26:06 и ответами третьей итерации на позицию после этих ответов (нарушение порядка внесено моей же вставкой в work-итерации; все перемещённые строки — мои записи текущей фазы, содержание дословно сохранено, только порядок; append-only не нарушен — ни одна запись не удалена и не переписана по содержанию); опечатки в собственной CENSOR-intake записи исправлены в два прохода («открытыQ-строк» → «открытых Q-строк», «итерции» → «итерации»).
- Final censor verdict: OK
- 2026-11-14 02:02:48 — Manager: CENSOR Architect OK (grep: маркер+TS 02:00:50, dispatch id censor:architect:261114_015834, Observations непустые, verdict OK; corpus: clean) — переход Draft → Ready for Planner подтверждён; ретрансляция Owner'у блока «Как я понял задачу» и границ Scope (дословно, информационно) и диспатч Planner (PHASE=work)
- 2026-11-14 02:16:37 — Planner: фаза Planning завершена: заполнены `## Acceptance criteria / DoD` (D1–D25 — детализация Solution 1–13 и Scope до проверяемых утверждений; решения Architect не менялись — точные токены Root cause class, форма C13 базовая/расширенная с cutoff 261113_1642 + exclude-листом и состав 11 selftest-кейсов зафиксированы в зоне Planner по Solution п.11 и Scope) и `## Tests / Commands` (T1–T18, каждый Dn покрыт командой или осмотром с ожидаемым результатом; R-меток нет — R-DoD отсутствуют); переноса ответов Q&A не требовалось: открытых Q/A-пар в логе нет, только intake-записи; Follow-ups: NO FOLLOW-UPS. Handoff: **Status:** Ready for Coder
- 2026-11-14 02:21:52 — (Role CENSOR) OK: Ready for Coder validated; current=true
Censor dispatch id: censor:planner:261114_021816
Observations:
- Second opinion: шапка — `**Status:** Ready for Coder`, ровно одна (`grep -c '^\*\*Status'` = 1, строка 4), Plan ID 261113_1642 = имени файла, PRE_STATUS_LINE конверта совпал; digest'ы пересчитаны — AGENTS.md@eb9cffe8 planner.md@d390e46a, неизменны с work-intake 02:15:05; DoD перечитан с диска: D1–D25 — каждый пункт утверждение с файлом/полями/enum'ами/числом, проверяемое прогоном или осмотром; Tests покрывают DoD буквально: все 25 меток Dn присутствуют в T-строках (механическая сверка `[( ]D<n>[,)–: ]` по всем T-меткам — 25/25 после разворота T5), у каждой из 18 команд ожидаемый результат; открытых вопросов нет (`grep -E '^- Q\('` → 0), перенос Q&A не требовался; Follow-ups: `NO FOLLOW-UPS — why: covered-by-out-of-scope`; чужие зоны не тронуты — Problem/Solution/Scope/Out of scope/«Как я понял задачу» перечитаны, нетронуты, Token usage — только строки Manager'а (зона §1(f)), Suggestions/Objections пусты, Changes — нетронутый плейсхолдер; числа согласованы: T17 «15 файлов + план» = пересчёт по буллетам Scope, D24 «минимум 9» = §3-класс контрактов из них (AGENTS.md + 3 роль-дока + _template_review.md + run.md + 3 обёртки); токены D6 ↔ Solution п.3–4 (5 классов 1:1) и enum'ы D8 ↔ Solution п.11 — дословная канонизация, решения Architect не изменены.
- Counterfactuals considered: (1) контракты могли дрейфнуть между work и CENSOR — shasum пересчитан, совпали, §3 п.7 расхождений нет; (2) мои Edit'ы work-итерации могли задеть чужие зоны — план перечитан целиком, все анкеры правок лежали в моих зонах/плейсхолдерах; (3) диапазонная метка `(D5–D10)` могла оставить D6–D9 без буквального якоря в Tests — подтверждено grep'ом (4 «NOT COVERED» ложных + 5 реальных), исправлено разворотом в перечисление — см. Fixes; (4) мой Evidence-хвост «Handoff: **Status:** Ready for Coder» мог создать ложную C1-цель — нет: середина строки, `^`-якорь C1 не матчит (прецедент 2121:520); (5) 2 вхождения `[R: ` в плане — только в `<!--`-комментариях секций Scope/DoD (C12 исключает комментарии, линт чист), фактических R-тегов нет, вырожденность оговорена в преамбуле Tests; (6) T16-паттерн `@8hex → @8hex` с пробелами мог поймать чужие записи — нет: миграционная строка Manager'а 01:49:10 без пробелов (`@7ec6d0f4→eb9cffe8`), ожидание ≥9 считают только записи Coder'а в формате D24; (7) самоприменение: Plan ID 261113_1642 ≥ REVIEW_CUTOFF — включён сравнением `<` строго, T18 корректен.
- Addendum (new angle): трассировка Problem→DoD — все 7 пунктов Problem закрыты (п.1→D5/D6, п.2→D1/D2/D17, п.3→D4, п.4→D3, п.5→D7/D22(г)/D2, п.6→D5+D11/D12 S1-гейт, п.7→D20–D23); транзиент-безопасность C13 прослежена по фазам жизни артефакта: создание без вердиктов (требуется только форма присутствующих B-блоков), risk записан/contracts нет (contracts-требования дремлют), Round ≥ 2 открыт (Rerun mode пишется risk-лейном тем же edit'ом, что и шапка раунда), Итог+state пишутся contracts одной итерацией — окно разрыва между правками и требованием линта отсутствует; DoD не требует новых файлов сверх Scope и не расширяет Out of scope; финальный `./scripts/check_corpus.sh` после всех правок CENSOR — `corpus: clean` (прогон выполнен в ходе сверки, результат — в настоящем receipt'е).
- Fixes: метка T5 развёрнута из диапазона `(D5–D10)` в явное перечисление `(D5, D6, D7, D8, D9, D10)` — буквальная машинная сверка покрытия всех Dn метками Tests (исправление своей зоны, содержание команд и ожиданий не затронуто); опечатка в собственной Addendum-строке исправлена («controllo-строкой» → точная формулировка про прогон сверки); других исправлений нет.
- Final censor verdict: OK
- 2026-11-14 02:24:05 — Manager: CENSOR Planner OK (grep: маркер+TS 02:21:52, dispatch id censor:planner:261114_021816, Observations непустые, verdict OK) — переход Ready for Coder → In progress подтверждён
- 2026-11-14 02:24:05 — Manager: Q&A чист, открытых вопросов к Owner нет, статус In progress; диспатч Coder (PHASE=work). Служебная оговорка: две записи этого узла ошибочно попали в `## Token usage` и в течение минуты перемещены в `## Evidence` (содержание дословно, дубликатов не осталось)
- 2026-11-14 09:50:35 — Manager: ночное делегирование Owner через кураторскую сессию — merge-гейт этого плана (и очереди 1644/1943/1944/0151) делегирован на ночь 2026-11-14: «да» на merge-гейте Manager ставит самостоятельно после обязательных контролей (свежий corpus green, staged по явному списку, сверка (г), push + CI green); Q-вопросы to=Owner, blocker'ы, стоп-матрица §6, needs-fix-лупы — стоп до утра; цитата: «следи за планом. как закончит - проверяй и мержить. потом ставь в очередь новый план»
- 2026-11-14 09:50:35 — Manager: recovery Coder — диспатч 02:26:03 оборван таймаутом хендла 600 с (~02:54, usage 6746932), SendMessage-резюм 03:01:59 в старый хендл умер тихо за ночь (Evidence-записей после 02:24:05 нет, handoff не наступил; правки предшественника — 15 unstaged-файлов, corpus: clean / selftest: 26/26); fresh-диспатч Coder (PHASE=work, продолжение с текущего статуса и дерева, §7) — последний в этом recovery-цикле; повторный сбой — стоп до утра
- 2026-11-14 10:02:05 — Coder: миграционные записи §3 п.7 по контрактам этого плана (старые digest'ы — HEAD = момент первой правки Coder'а 02:26:03; новые — финальное состояние после правок обеих Coder-итераций, сняты shasum после всех правок fresh-итерации):
  контракты §3 — AGENTS.md: @eb9cffe8 → @ae39388a
  docs/roles/architect.md: @e34627dc → @65060cee
  docs/roles/reviewer-risk.md: @b58755ea → @a51f0eb4
  docs/roles/reviewer-contracts.md: @a7bcfdfa → @dd9bcb7a
  docs/reviews/_template_review.md: @0c995bb3 → @160496a2
  .zcode/commands/planfaktor-run.md: @2a6176bd → @fec9b9d9
  .zcode/agents/planfaktor-architect.md: @1d353cfc → @3f6db307
  .zcode/agents/planfaktor-reviewer-risk.md: @fec7067f → @cffc8129
  .zcode/agents/planfaktor-reviewer-contracts.md: @41f01027 → @13b1f313
  прочие носители Scope (документация/линт, вне класса §3, зафиксированы для полноты) — docs/plans/README.md: @0d604f84 → @21c4a62f
  docs/lifecycle.md: @c128fc6d → @72b8b478
  README.md: @7ff99e4d → @3e858258
  docs/playbooks/manual_terminal_recovery.md: @f4b47e8c → @b552319b
  CONTRIBUTING.md: @53214fa0 → @0889b296
  scripts/check_corpus.sh: @24b84406 → @1fa1c3f4
- 2026-11-14 10:04:28 — Coder: fresh-итерация §7 — перепринятие правок предшественника по существу (все 15 диффов осмотрены против D1–D25), выявлены и закрыты 4 пробела: (1) D7 — конвенция Stale/Rerun note отсутствовала в шапке `_template_review.md`, дописана; (2) канон-синк хвостовой маршрутизации needs-fix в `reviewer-risk.md` (:97–98) и `reviewer-contracts.md` (:117–119): осталась безусловная фраза «возврат Coder'у через Manager», противоречащая reroute §2 (canon-drift), заменена на маршрут по Loop signal; (3) `AGENTS.md` §4 — фраза «why previous rerun did not break the loop» была разорвана переносом строки, буквальный паттерн T4 давал 0 совпадений, абзац переформатирован (текст не менялся, только переносы); (4) `scripts/check_corpus.sh` selftest-кейс C13j: паттерн мутации `^\*\*Artifact state:\*\*` не совпадал с фактическим форматом строки bait (`- **Artifact state:**` с префиксом списка) — дефект не подсаживался, selftest падал `25/26 caught, MISSED C13j` (заявленные Manager'ем «selftest: 26/26» на момент смерти предшественника в текущем дереве не воспроизводились), паттерн приведён к формату строки, после фикса — `selftest: 26/26 caught`, exit 0. Прогоны: `./scripts/check_corpus.sh` → 13×OK C1–C13, `corpus: clean`, exit 0 (дважды: до и после правок fresh-итерации); `--selftest` → `26/26 caught`, exit 0; T3–T14 — все ожидания совпали (факты в `## Tests / Commands`)
- 2026-11-14 10:07:22 — Coder: фаза work завершена. Реализация D1–D25: правки предшественника переприняты по существу и дополнены (4 пробела — Evidence 10:04:28); все 15 носителей Scope изменены по DoD, Out of scope чист (T15: planner.md/coder.md/_template.md/followups и 8 исторических review-артефактов не тронуты; 4 соседних Draft-плана untracked и не застейджены). Прогоны: T1–T17 — PASS с фактами в `## Tests / Commands`; T18 — гейт Manager (обязательство-носитель D24). Стейджинг: `git add` 16 файлов — 15 носителей Scope + этот план; `git diff --cached --name-only` = 16 строк (T17). Финальные контроли после всех правок: `./scripts/check_corpus.sh` → `corpus: clean` (exit 0), `--selftest` → `selftest: 26/26 caught` (exit 0). Коммит не делался (§8). Handoff: **Status:** In review — ожидание CENSOR-прохода
- 2026-11-14 10:43:14 — Manager: reconciliation recovery-гонки — «мёртвый» резюм 03:01:59 завершился в 10:37:20 (7,6 ч): корректный стоп по расхождению PRE_STATUS_LINE, нулевое действие, открытый Q(coder#1) закрыт ответом A(manager#1) (действия от того хендла не требуются); usage 3823567 дописан к сохранённой append-only unknown-строке этого же вызова. Risk-лейн Round 1 — needs-fix (1 blocker S1 + 2 major + 1 minor, артефакт 261113_1642_review.md): диспатч Coder (рабочий хендл fresh-итерации) на fixes раунда 1
- 2026-11-14 10:11:15 — Manager: ночная делегация ОТМЕНЕНА утренним будильником кураторской сессии (Owner на месте, гейты снова живые, автономная очередь черновиков отменена) — merge-гейт снова требует живого Owner-«да», ход завершается «GATE: мержим?»; запись восстановлена 11:05:39 из повреждения коллизией параллельных правок (приклеенный хвост записи Coder 10:07:22 удалён — дубликат, оригинал цел; вставка 10:11 в середину лога и коллизия — мои дефекты, первый замечен CENSOR'ом, второй зафиксирован fail-loud Coder'ом в Evidence 10:59:22)
- 2026-11-14 10:14:31 — (Role CENSOR) OK: In review validated; current=true
Censor dispatch id: censor:coder:261114_100930
Observations:
- Second opinion: шапка — `**Status:** In review`, ровно одна (`grep -c '^\*\*Status'` = 1, строка 4), Plan ID 261113_1642 = имени файла, PRE_STATUS_LINE конверта совпал; DoD↔Changes — все D1–D25 отражены после фикса: D17 (`.zcode/commands/planfaktor-run.md`) в Changes отсутствовал (`grep -c 'planfaktor-run'` в секции → 0), дополнен пунктом «Рант-рутер» → теперь 1; Tests — факты T1–T18 с якорями в секции, T1/T2 перепрогнаны в CENSOR свежим прогоном: `./scripts/check_corpus.sh` → `corpus: clean` (exit 0), `--selftest` → `selftest: 26/26 caught` (exit 0); стейджинг — `git diff --cached --name-only` = 16 (15 носителей Scope + план), unstaged до перестейджинга — только план (Manager-дописи 10:09:30 usage §1(f) и A(owner) 10:11, их зоны), у 15 носителей unstaged-дельта пуста; шаблон — 3 `##`-секции как в HEAD (C3/C8), «Состав staged» — 1 дословно; мусор — `git diff --cached | grep -cE 'TODO|FIXME|XXX|console\.log|DEBUG'` → 0; Follow-ups — `NO FOLLOW-UPS — why: covered-by-out-of-scope` (Planner), Coder-хвостов нет; чужие секции (Problem/Solution/Scope/Out of scope/DoD/Tests-ожидания) перечитаны — нетронуты.
- Counterfactuals considered: (1) носители могли дрейфнуть после снятия миграционных digest'ов 10:02:05 — все 9 пересверены shasum (65060cee / a51f0eb4 / dd9bcb7a / 160496a2 / fec9b9d9 / 3f6db307 / cffc8129 / 13b1f313 / 1fa1c3f4) — совпали с записями Evidence, дрейфа нет; (2) staged-снимок мог разойтись с деревом — разошёлся только план (Manager-дописи), перестейджен вместе с CENSOR-правками, носители совпадали; (3) переформатирование §4 AGENTS.md могло изменить смысл — дифф сверен: менялись только переносы строк, текст дословно (grep-фраза T4 теперь цельная, → 1); (4) migration-строки могли не матчиться T16-паттерном — `grep -cE '@[0-9A-Fa-f]{8} → @[0-9A-Fa-f]{8}'` → 16: 15 моих + 1 дословная цитата миграции 2121 в intake Architect'а (:913, существовала до Coder-фазы), ≥ 9 выполнено; (5) selftest-кейсы C13 могли ловить дефекты чужими чеками — изоляция сохранена: baseline гоняет все C1–C13 на чистой копии, дефекты подсаживаются по одному (mutate), C1–C12 не менялись; (6) bait-артефакт мог попасть в репо — `ls docs/reviews/` = 9 (8 артефактов + шаблон), `261130_*` → 0; (7) claim конверта «selftest: 26/26» не воспроизводился (25/26, MISSED C13j) — разобран в Evidence 10:04:28 и закрыт фиксом паттерна мутации, сейчас 26/26; (8) T15 `-- docs/plans/` показывает и README планов (носитель Scope, не план) — факт задокументирован в Tests с интерпретацией по смыслу D25, изменённых планов кроме этого нет.
- Addendum (new angle): сверена новая A(owner)-запись 10:11 (отмена ночной делегации merge-гейта): гейт снова требует живого Owner-«да» — на мой handoff не влияет, Owner-гейт дальше по конвейеру; наблюдение чужой зоны (не правлю): Manager-запись 10:11:15 вставлена в середину Evidence-лога между записями 09:50:35 (не в хвост) — append-only по содержанию (ничего не переписано/удалено), семантическая близость к отменяемой делегации понятна, но хронологический порядок секции нарушен; exclude-лист C13 перепроверен на дыру — критерий «созданные по старой грамматике до введения чека» исторически закрыт (единственное имя 261113_2121_review.md), будущие артефакты ≥ cutoff проверяются полноценно, самоприменение T18 (артефакт этого плана ≥ cutoff, вне exclude) остаётся обязанностью ревью-лейнов/Manager'а.
- Fixes: Changes дополнен пунктом «Рант-рутер (.zcode/commands/planfaktor-run.md)» — D17 не был отражён в `## Changes (by area)` (найдено CENSOR-сверкой DoD↔Changes, до фикса grep → 0, после → 1); план перестейджен (включая Manager-дописи 10:09:30/10:11 и CENSOR-правки); других исправлений нет.
- Final censor verdict: OK
- 2026-11-14 10:37:20 — Coder: возобновлённый хендл (итерация 02:26:03) получил конверт «продолжи, PRE_STATUS_LINE=In progress»; сверка с файлами показала устаревание конверта (recovery-гонка): статус `In review` с 10:07:22 (fresh-итерация 09:53:20), Coder CENSOR OK 10:14:31, staged = 16 файлов, reviewer-risk intake 10:19:47. Действий этим хендлом не выполнялось (правок/стейджинга/статуса) — дублирование закрытой фазы рискнуло бы затоптать append-only записи и staged-снимок идущего ревью; контрольный прогон на финальном дереве: `./scripts/check_corpus.sh` → `corpus: clean` (exit 0), `--selftest` → `selftest: 26/26 caught` (exit 0). Стоп-лайн PRE_STATUS_LINE (роль-док, §5): вопрос Manager'у — Q(coder#1) в Q&A log
- 2026-11-14 10:59:22 — Coder: fixes раунд 1 (findings 1–4 risk-лейна, `docs/reviews/261113_1642_review.md`). Репродукция до правок: `./scripts/check_corpus.sh` → `FAIL C13 review-blocker-grammar` на артефакте этого плана (bad **Artifact state:** value — плейсхолдер шаблона в окне между лейнами) + `FAIL C7` (malformed verdict — плейсхолдер Contracts-вердикта; транзиент-прецедент 2121 раунд 1, вне findings, закроется заполнением вердикта contracts-лейном). Фиксы: (4/1) `scripts/check_corpus.sh` C13(г) — валидация значения только записанной формы (одиночный токен enum'а; плейсхолдер шаблона с альтернативами « | » не валидируется и записанной формой не считается; обязательность при записанном Contracts-вердикте — по наличию записанной формы) и C13(д) — подсчёт/валидация `**Rerun mode:**` и детекция incremental только по не-superseded строкам (Round ≥ 3 легально несёт по одной строке на раунд ≥ 2); (3) selftest — позитивные baseline-утверждения чистоты bait'ов новой грамматики: bait Round 2 + новый bait Round 3 (2 Rerun mode-строки, 1 superseded; старая Artifact state-строка superseded) — C13 и C7 обязаны проходить, падение abort'ит selftest; вне счётчика caught (26), bait'и только в TMPDIR-копиях; (2) `.zcode/commands/planfaktor-run.md` — pass-ветка шага 4: сверка терминальности review-артефакта ДО Owner-гейта (нетерминальное → диспатч рерана при статусе `In review`, контракт ревьюеров соблюдён, Owner не дёргать); ветка `Merged`: нетерминальное на closeout — пост-мердж-аномалия → стоп, Owner + ручной плейбук (диспатч ревью из `Merged` контрактом статусов не предусмотрен — тупик устранён); `docs/lifecycle.md` — closeout-абзац синхронизирован. Прогоны после правок: реальный корпус → `OK C13 review-blocker-grammar`, `corpus: 1 failures` (единственный остаточный FAIL — C7-транзиент на незаполненном Contracts-вердикте, ожидаемое закрытие — продолжение лейнов); изолированная TMPDIR-копия корпуса без транзиентного артефакта → `corpus: clean` (exit 0) и `--selftest` → `selftest: 26/26 caught` (exit 0). Контрфактика: bait Round 3 на старой логике (д) дал бы modes=2 → ложный FAIL — изъятие держит; кейс C13j по-прежнему ловит мутацию `green` (значение без « | » → bad value). Наблюдение чужой зоны (fail loud, не правлю): перемещённая строка Manager'а 10:11:15 несёт приклеенный дублированный хвост записи Coder 10:07:22 («...(замечена CENSOR'ом)D, Out of scope чист … ожидание CENSOR-прохода») — похоже на повреждение коллизией параллельных правок; оригинальная запись 10:07:22 цела, дубликат в строке Manager'а оставлен нетронутым
- 2026-11-14 10:59:22 — Coder: миграционные записи §3 п.7 fixes-итерации (старые digest'ы — значения из Evidence 10:02:05, новые — после фиксов раунда 1):
  scripts/check_corpus.sh: @1fa1c3f4 → @8cf01b9f
  .zcode/commands/planfaktor-run.md: @fec9b9d9 → @d66fac0a
  docs/lifecycle.md: @72b8b478 → @809aa974
- 2026-11-14 11:03:36 — Coder: fixes-итерация раунда 1 завершена. Findings 1–4 risk-лейна закрыты (адресные факты — `## Tests / Commands`, фиксы — Evidence 10:59:22): (4) C13(г) — валидация только записанной формы, плейсхолдер шаблона в окне между лейнами tolerated (репродукция FAIL→OK на артефакте этого плана); (1) C13(д)/(г) — superseded-изъятие (Round ≥ 3), регрессионная защита — bait Round 3 в selftest; (2) гейт терминальности до Owner-гейта + безтупиковый closeout (run.md, lifecycle); (3) позитивные baseline-утверждения чистоты bait'ов (selftest, abort-семантика). Правки: scripts/check_corpus.sh, .zcode/commands/planfaktor-run.md, docs/lifecycle.md (все — Scope); review-артефакт не тронут (зона ревьюеров). Стейджинг: 16 файлов (3 носителя и план перезастейджены), unstaged пуст. Остаточный red реального корпуса — единственный известный транзиент C7 (плейсхолдер Contracts-вердикта открытого раунда, прецедент 2121 раунд 1; закроется заполнением вердикта contracts-лейном); изолированная копия без транзиентного артефакта — `corpus: clean` (exit 0), `selftest: 26/26 caught` (exit 0). Миграционные строки fixes-итерации — выше (10:59:22). Коммит не делался (§8). Handoff: **Status:** In review — ревью-лейны продолжают раунд 1 (Contracts-секция артефакта за плейсхолдерами)
- 2026-11-14 11:07:29 — (Role CENSOR) OK: In review validated; current=true
Censor dispatch id: censor:coder:261114_110539
Observations:
- Second opinion: шапка — `**Status:** In review`, ровно одна (строка 4), Plan ID 261113_1642 = имени файла, PRE_STATUS_LINE конверта совпал; fixes-handoff сверен с файлами: findings 1–4 закрыты и отражены — Changes-бюллетень «Fixes раунд 1», факты fixes-итерации в `## Tests / Commands` с якорями (run.md :33/:142/:145/:147–153; lifecycle :77–84; bait Round 2/3), Evidence 10:59:22 (фиксы + миграции) и 11:03:36 (завершение); digest'ы трёх правленных носителей пересчитаны shasum — check_corpus.sh@8cf01b9f / run.md@d66fac0a / lifecycle@809aa974, совпадают с миграционными записями 10:59:22, дрейфа нет; стейджинг — 16 staged / 0 unstaged; review-артефакт не тронут (risk verdict 10:44:10 на месте, файл untracked, в staged не входит); мусор в код-диффе — 0 (единственное совпадение паттерна — дословная цитата самого паттерна в моём прошлом receipt'е внутри плана, ложное); Follow-ups — заполнен Planner'ом, fixes-итерация новых хвостов не породила (все findings закрыты в раунде). Свежие прогоны в ходе сверки (11:07): реальный корпус → `OK C13 review-blocker-grammar` на артефакте этого плана + единственный `FAIL C7` (транзиент плейсхолдера Contracts-вердикта открытого раунда, прецедент 2121 раунд 1) → `corpus: 1 failures`; изолированная TMPDIR-копия без транзиентного артефакта → `corpus: clean`, `--selftest` → `selftest: 26/26 caught`.
- Counterfactuals considered: (1) толерантность плейсхолдера в (г) могла открыть дыру для мусорных мульти-значений — нет: при записанном Contracts-вердикте обязательность требует чистую записанную форму, «|»-строка записанной формой не считается; между лейнами пропуск — задизайненная D21/D22 транзиент-безопасность; (2) superseded-изъятие в (д) могло пропустить неотмеченную старую Rerun mode-строку — наоборот: две несуперседенные строки дают FAIL счётчика, неотмеченная старая строка = process miss маркировки, ловится; (3) перестейджинг плана мог захватить чужие правки — дельта содержала только ремонт Manager'а собственной строки 10:11:15 (11:05:39, их зона, оба дефекта признаны в самой записи); (4) bait Round 3 мог противоречить конвенции C7 — проверено прогоном: C7 на bait'е проходит (лейблы `superseded (round 3)` совпадают с `**Round:** 3`, вердикт-строки валидны); (5) правки run.md могли сломать T10-якоря — перепроверено: `Loop signal` ×3, контроли на местах; (6) мой прошлый receipt в staged-диффе плана мог дать ложные C1/C4-якоря — нет: статусные/вердиктные строки в нём не с начала строки, `^`-якоря C1/C4 не матчат (линт чист по свежему прогону).
- Addendum (new angle): сверена закрытая пара Q(coder#1)/A(manager#1) — reconciliation recovery-гонки полон, действий от мёртвого хендла не требуется; сверено, что Manager-ремонт 11:05:39 удалил только дублированный хвост (полный текст моей записи 10:07:22 цел, grep'ом подтверждён); изолированный прогон подтверждает реальное исполнение новых позитивных assertions (selftest дошёл до кейсов, abort-семантика не сработала).
- Fixes: ничего (дефектов своей зоны в fixes-handoff не найдено; план перестейджен с Manager-ремонтом 11:05:39 — хаускипинг).
- Final censor verdict: OK
- 2026-11-14 15:24:49 — Manager: Owner-«да» на merge-гейте («мержим»); контроли (а) пройдены — unstaged: только план (append-only-дельта), untracked: 4 Draft-черновика очереди (все `**Status:** Draft`, информационно) + review-артефакт (оба класса в исключениях), staged = 16, гейт терминальности: `**Artifact state:** current_green` записанной формой (артефакт :115), свежий линт: corpus: clean, selftest: 26/26 caught; статус Merged, merge-коммит по явному списку из Итога

## Token usage (append-only)
<!-- owner: manager; dispatch-форма: `- YYYY-MM-DD HH:MM:SS — usage: <role>.<work|censor|rN> <N|unknown (why=...)> tokens — <dispatch|sendmessage|unknown>`; чекпоинт-форма: `- YYYY-MM-DD HH:MM:SS — usage: manager-context checkpoint ~<N> tokens-left — approximate`; числа — учёт харнесса ZCode (subagent_tokens), приближение, не биллинг провайдера; пишет только Manager из tool-результата вызова -->

- 2026-11-13 16:55:45 — usage: architect.work 1017480 tokens — dispatch
- 2026-11-13 19:46:39 — usage: architect.work 424757 tokens — sendmessage
- 2026-11-13 21:26:06 — usage: architect.work 459820 tokens — sendmessage
- 2026-11-14 01:58:34 — usage: architect.work 2537348 tokens — dispatch
- 2026-11-14 02:02:48 — usage: architect.censor 1175938 tokens — sendmessage
- 2026-11-14 02:18:16 — usage: planner.work 1837999 tokens — dispatch
- 2026-11-14 02:24:05 — usage: planner.censor 2232663 tokens — sendmessage
- 2026-11-14 03:01:59 — usage: coder.work 6746932 tokens — dispatch
- 2026-11-14 09:50:35 — usage: coder.work unknown (why=резюм 03:01:59 в старый хендл после таймаута умер тихо за ночь — результата/usage харнесс не вернул) tokens — sendmessage
- 2026-11-14 10:09:30 — usage: coder.work 5602966 tokens — dispatch
- 2026-11-14 10:19:40 — usage: coder.censor 2291034 tokens — sendmessage
- 2026-11-14 10:43:14 — usage: coder.work 3823567 tokens — sendmessage
- 2026-11-14 10:43:14 — usage: reviewer-risk.work 3125123 tokens — dispatch
- 2026-11-14 11:05:39 — usage: coder.r1 7154799 tokens — sendmessage
- 2026-11-14 11:29:47 — usage: coder.censor 3121815 tokens — sendmessage
- 2026-11-14 15:05:17 — usage: reviewer-risk.r1 3119978 tokens — sendmessage
- 2026-11-14 15:18:13 — usage: reviewer-contracts.r1 2609536 tokens — dispatch
- 2026-11-14 15:18:13 — usage: manager-context checkpoint ~14966018 tokens-left — approximate

## Q&A log (chronological, append-only)
<!-- owner: все роли; intake: `Intake (YYYY-MM-DD HH:MM:SS): AGENTS.md@<8hex> <role>.md@<8hex>` (локальное время) + NO QUESTIONS / NO SUGGESTIONS / NO OBJECTIONS; вопросы `Q(<роль>): ... to=Owner|to=<роль>, blocker: yes|no, needs_owner: yes|no, status=open`; закрытие `A(<кто>): ... status=closed, перенесено в <секция>` -->

- Intake (2026-11-13 16:51:33): AGENTS.md@7ec6d0f4 architect.md@73ace930
- architect: NO QUESTIONS (бриф Owner'а закрывает все развилки — enum, маршруты reroute, S1-гейт merge, терминальные состояния, cutoff; digest'ы сверены `shasum -a 256` — совпали с кураторскими 7ec6d0f4/73ace930)
- architect: NO SUGGESTIONS (анти-false-gap grep по текущему корпусу: loop-signal / reroute / B-ID-грамматика / терминальные состояния / классы повторов / CENSOR-deadlock-поля / чек C13 — 0 совпадений, дублирования существующих механик нет; фактический последний чек линта — C12, selftest 15/15, следующий свободный номер — C13)
- architect: NO OBJECTIONS (противоречий с конституцией план не содержит — правки §2/§4/§6 идут через Scope; соседний черновик 261113_1644 пересекается только общими носителями, последовательное исполнение по очереди планов безопасно)
- Intake (2026-11-13 19:46:39): AGENTS.md@7ec6d0f4 architect.md@73ace930
  (повторная итерация фазы по конверту добавки; контракты не менялись — digest'ы сверены `shasum -a 256`, совпали 7ec6d0f4/73ace930; план перечитан с диска целиком: секции фазы внесены куратором дословно, Evidence/Q&A/Token usage дописаны после 16:51:33; Status Draft сверен с PRE_STATUS_LINE конверта)
- architect: NO QUESTIONS (бриф добавки закрывает состав всех трёх механик; единственная свобода — конкретные значения enum'а доменов, зафиксированы в п.11 и уточняются Planner'ом)
- architect: NO SUGGESTIONS (анти-false-gap: coverage/No findings reason — в корпусе только прецедент пустой таблицы без причины (reviewer-risk.md:43), disposition/canonical_ref — 0 совпадений, Rerun mode/incremental/Trusted/Reused — 0 релевантных; добавки усиливают существующее, дублирования нет)
- architect: NO OBJECTIONS (п.12 уточняет п.1 без противоречия — канонизация B<N> живёт в синтезе Итога; п.13 расширяет п.5 связкой incremental-pass → current_green; новые файлы в Scope не требуются — все носители уже перечислены; пересечение с соседним черновиком 261113_1644 по общим носителям решается последовательным исполнением по очереди планов)
- Intake (2026-11-13 21:26:06): AGENTS.md@7ec6d0f4 architect.md@73ace930
  (третья итерация фазы по конверту аудит-добавки; контракты не менялись —
  digest'ы сверены shasum, совпали 7ec6d0f4/73ace930; план перечитан
  с диска: вставки п.11–13 и дополнения Scope от добавки №1 внесены
  дословно; PRE_STATUS_LINE=Draft сверен с шапкой)
- architect: NO QUESTIONS (обе правки заданы конвертом дословно; соседний
  261113_1944 существует, его Solution п.4 покрывает остаток де-хардкода —
  ссылка точна)
- architect: NO SUGGESTIONS (анти-false-gap: CONTRIBUTING.md:73/74 несут
  литералы «C1–C12»/«15/15 caught» — подтверждено grep; до правки
  regression назван в плане только в coverage-домене п.11 и rerun-п.13 —
  в Severity-типаже п.1 отсутствовал; дублирования нет)
- architect: NO OBJECTIONS (правка п.1 внутрисекционная и согласована
  с п.2 и ролью reviewer-risk по AGENTS.md:17; нумерация чеков с соседним
  261113_1944 не конфликтует — он ориентируется на следующий за C13 чек;
  Status Draft, конвейер не запущен)
- Intake (2026-11-14 01:54:04): AGENTS.md@eb9cffe8 architect.md@e34627dc
  (четвёртая итерация — перепринятие кураторских зон по существу, не
  rubber-stamp, основание §1(g) + конверт Manager'а 01:49:12; digest'ы
  сверены shasum — совпали с конвертом; смена контрактов с
  7ec6d0f4/73ace930 легальна по §3 п.7: миграционные записи есть
  в Evidence плана 261113_2121 (23:59:10, `AGENTS.md: @7ec6d0f4 →
  @eb9cffe8`, `architect.md: @73ace930 → @e34627dc`); план перечитан
  целиком, Status Draft сверен с PRE_STATUS_LINE; новые вопросы при
  возникновении — в грамматике Q#<n>/A#<n> контракта eb9cffe8)
- architect: NO QUESTIONS (перепринятие против eb9cffe8/e34627dc: все
  развилки закрыты — смена контрактов задокументирована миграциями 2121
  (§3 п.7), изменения 2121 не заняли механики плана (анти-false-gap ниже),
  единственная новая развилка — артефакт 261113_2121_review.md с Plan ID
  ≥ cutoff по старой грамматике — решена в зоне Architect: граница
  действия линта (cutoff + exclude-лист) есть архитектурное решение,
  защищающее замысел cutoff от ложных срабатываний; вопросов к Owner нет)
- architect: NO SUGGESTIONS (анти-false-gap перегнан по текущему корпусу
  восемью группами grep — loop.signal/root.cause/current.state/lineage,
  reroute/scope expansion/de-scoped, NO FINDINGS/extraordinary,
  current_green/needs_reviewer_rerun/rerun/stale.note, B-грамматика/S1–S3,
  coverage/No findings reason, rerun mode/incremental/Trusted/Reused,
  accepted_blocker/canonical_ref/synthesis — все по AGENTS.md, роль-докам,
  обоим шаблонам, check_corpus.sh, run.md, lifecycle.md, plans/README.md
  → 0 совпадений; механики 2121 (Q#<n>-грамматика, формальный переход
  `In review → In progress`, «Состав staged» в Итоге) не дублируют план —
  совместимы, согласования внесены в Solution п.4/п.8/п.12; дублирования
  нет, дополнений сверх зафиксированных не предлагаю)
- architect: NO OBJECTIONS (противоречий с конституцией eb9cffe8 нет:
  §1(g) легализует кураторский черновик и перепринятие; §2-строка
  `In review → In progress` (720519f) согласована — reroute добавляет два
  перехода, не заменяет; п.12 сосуществует с обязательным «Состав staged»
  Итога; якоря своей зоны пересверены и обновлены — reviewer-risk.md:47–48
  (было :43, сдвиг intake-блоком 2121), CONTRIBUTING.md:79–80 (было
  73–74, сдвиг +6), AGENTS.md:17 и README.md:64–66 валидны; check_corpus.sh
  — последний чек C12, selftest 15/15, C13 остаётся свободным номером)
- Intake (2026-11-14 02:00:50): AGENTS.md@eb9cffe8 architect.md@e34627dc
  (CENSOR-итерация, dispatch censor:architect:261114_015834; digest'ы
  пересчитаны shasum — контракты неизменны с work-intake 01:54:04, §3 п.7
  расхождений нет; план перечитан с диска целиком, статус Ready for
  Planner сверен с PRE_STATUS_LINE конверта — совпал; «Как я понял задачу»
  перечитан — актуален с рабочей итерации 01:54:04)
- architect: NO QUESTIONS (CENSOR-сверка не породила вопросов: все
  развилки закрыты в work-итерации, открытых Q-строк к Owner нет —
  `grep -E '^- Q\('` → 0)
- architect: NO SUGGESTIONS (сверх исправления порядка Q&A-записей своей
  зоны — см. Fixes receipt'а — дополнений не предлагаю: чек-лист роль-дока
  и контрфактические проверки покрыты, содержания это не меняет)
- architect: NO OBJECTIONS (к собственному handoff — после сверки с файлами
  и одного исправления порядка записей; детали — receipt в Evidence)
- Intake (2026-11-14 02:15:05): AGENTS.md@eb9cffe8 planner.md@d390e46a
- planner: NO QUESTIONS (все развилки закрыты Solution 1–13 и Scope;
  детализации, оставленные Architect'ом зоне Planner, — точные токены
  Root cause class, форма C13 и состав selftest-кейсов — зафиксированы
  в DoD D6/D21–D23; вопросов к Owner нет)
- planner: NO SUGGESTIONS (носители Scope перечитаны по факту, якоря
  подтверждены чтением: CONTRIBUTING.md:79–80, README.md:64–66,
  run.md:176, reviewer-risk.md:47–48, 8 артефактов docs/reviews/
  (7 < cutoff + 261113_2121_review.md), последний чек C12/selftest
  15/15; новых механик сверх решений Architect не предлагаю)
- planner: NO OBJECTIONS (противоречий в решениях нет; единственный
  риск — ссылки «стоп-матрица `loop`» в coder.md:95 и planner.md:88
  (файлы вне Scope) при замене строки `loop` классами — снят
  формулировкой D4: токен `loop` сохраняется именем семейства классов,
  правка файлов вне Scope не требуется)
- Intake (2026-11-14 02:21:52): AGENTS.md@eb9cffe8 planner.md@d390e46a
  (CENSOR-итерация, dispatch censor:planner:261114_021816; digest'ы
  пересчитаны shasum — контракты неизменны с work-intake 02:15:05,
  §3 п.7 расхождений нет; план перечитан с диска целиком, статус
  Ready for Coder сверен с PRE_STATUS_LINE конверта — совпал)
- planner: NO QUESTIONS (CENSOR-сверка не породила вопросов: все
  развилки закрыты в work-итерации, открытых Q-строк к Owner нет —
  `grep -E '^- Q\('` → 0)
- planner: NO SUGGESTIONS (сверх одного исправления своей зоны —
  разворот диапазонной метки T5, см. Fixes receipt'а — дополнений
  не предлагаю: чек-лист роль-дока и контрфактические проверки
  покрыты, содержания это не меняет)
- planner: NO OBJECTIONS (к собственному handoff — после сверки
  с файлами и одного исправления метки T5; детали — receipt в Evidence)
- Intake (2026-11-14 02:26:03): AGENTS.md@eb9cffe8 coder.md@976c292b
  (digest'ы сверены shasum; план перечитан с диска целиком, Status
  `In progress` сверен с PRE_STATUS_LINE конверта — совпал; рабочее
  дерево чистое от правок контрактов, старые digest'ы всех 15 носителей
  Scope зафиксированы до первой правки)
- coder: NO QUESTIONS (все развилки закрыты DoD D1–D25 и Tests T1–T18:
  точные токены enum'ов, состав 11 selftest-кейсов C13a–C13k, границы
  Scope/Out of scope, свобода линта — только форма паттернов POSIX)
- coder: NO SUGGESTIONS (носители Scope перечитываются по факту перед
  правкой; дополнений сверх DoD не предлагаю — решения зафиксированы
  зонами Architect/Planner)
- coder: NO OBJECTIONS (правки идут строго через Scope; Changes/Evidence/
  Tests-факты — мои зоны; Out of scope-файлы не трогаю)
- A(owner): merge-гейт делегирован кураторской сессии на ночь 2026-11-14, дословная цитата Owner — «следи за планом. как закончит - проверяй и мержить. потом ставь в очередь новый план» — status=closed, перенесено в Evidence
- A(owner): ночная делегация ОТМЕНЕНА утренним будильником кураторской сессии 2026-11-14 10:11 (Owner на месте, гейты снова живые; автономная очередь 1644/1943/1944/0151 также отменена) — merge-гейт снова требует живого Owner-«да», ход завершается «GATE: мержим?» — status=closed, перенесено в Evidence
- Intake (2026-11-14 09:53:20): AGENTS.md@f155be52 coder.md@976c292b
  (fresh-диспатч по §7 после смерти хендла предшественника; digest'ы сверены
  shasum: coder.md@976c292b совпадает с intake 02:26:03, AGENTS.md изменён
  правками самого плана — старый@eb9cffe8 = HEAD, смена будет закрыта
  миграционной записью D24 в Evidence; план перечитан с диска целиком,
  Status `In progress` сверен с PRE_STATUS_LINE конверта — совпал; в дереве
  15 unstaged-файлов предшественника + план untracked, Corpus/Tests пока
  не заполнялись)
- coder: NO QUESTIONS (DoD D1–D25 и Tests T1–T18 задают все развилки:
  точные токены enum'ов, 11 selftest-кейсов C13a–C13k, cutoff
  261113_1642 + exclude-лист, границы Scope/Out of scope; правки
  предшественника перепринимаются по существу против DoD, не rubber-stamp)
- coder: NO SUGGESTIONS (дополнений сверх DoD не предлагаю — решения
  зафиксированы зонами Architect/Planner; недостающее в правках
  предшественника дополняю в рамках тех же пунктов DoD)
- coder: NO OBJECTIONS (работа продолжается строго в Scope; Changes/
  Evidence/Tests-факты — мои зоны; Out of scope-файлы не трогаю)
- Intake (2026-11-14 10:14:31): AGENTS.md@ae39388a coder.md@976c292b
  (CENSOR-итерация, dispatch censor:coder:261114_100930; digest'ы
  пересчитаны shasum — coder.md неизменен с work-intake 09:53:20;
  AGENTS.md сменился @f155be52 → @ae39388a правкой моей же work-итерации
  (переформатирование §4, цельность фразы T4) — смена закрыта
  миграционной записью Evidence 10:02:05 (@eb9cffe8 → @ae39388a),
  §3 п.7 соблюдён; план перечитан с диска после Manager-дописей
  10:09:30/10:11, статус `In review` сверен с PRE_STATUS_LINE конверта —
  совпал)
- coder: NO QUESTIONS (CENSOR-сверка вопросов не породила: открытых
  Q-строк к Owner нет — `grep -E '^- Q\('` → 0)
- coder: NO SUGGESTIONS (сверх одного исправления своей зоны — пункт
  D17/run.md в Changes, см. Fixes receipt'а — дополнений не предлагаю)
- coder: NO OBJECTIONS (к собственному handoff — после сверки с файлами
  и одного исправления Changes; детали — receipt в Evidence)
- Intake (2026-11-14 10:19:47): AGENTS.md@ae39388a reviewer-risk.md@a51f0eb4
  (digest'ы пересчитаны shasum -a 256; план перечитан с диска целиком,
  1072 строки; Status `In review` сверен с PRE_STATUS_LINE конверта —
  совпал; расхождение digest'ов с итерациями прошлых фаз — правки этого
  же плана, закрыты миграционными записями Evidence 10:02:05, §3 п.7
  соблюдён; review-артефакт 261113_1642_review.md отсутствует — будет
  создан из _template_review.md@160496a2)
- reviewer-risk: NO QUESTIONS (конверт и D24/T18 задают задачу однозначно:
  Round 1 — Loop signal и Rerun mode не требуются до переиспользования ID /
  раунда ≥ 2; предмет — staged-изменения `git diff --cached` против HEAD)
- reviewer-risk: NO SUGGESTIONS (фаза review; несрочные улучшения сверх
  findings в фазе не предлагаются)
- reviewer-risk: NO OBJECTIONS (противоречий плана с конституцией ae39388a
  и роль-доком a51f0eb4 не вижу; статус сверен)
- Intake (2026-11-14 10:37:20): AGENTS.md@ae39388a coder.md@976c292b
  (возобновлённый хендл Coder-итерации 02:26:03 по конверту «продолжи
  с In progress»; контракты и план перечитаны с диска; фактический статус
  `In review` — РАСХОЖДЕНИЕ с PRE_STATUS_LINE конверта, стоп по роль-доку
  и §5; смена AGENTS.md @f155be52 → @ae39388a и все кодовые правки —
  работа fresh-итерации 09:53:20, закрыта миграционными записями
  Evidence 10:02:05, §3 п.7 соблюдён)
- coder: NO QUESTIONS (мандат конверта исчерпан фактом: фаза work закрыта
  fresh-итерацией — 10:07:22 `In review`, Coder CENSOR OK 10:14:31;
  вопросов по существу закрытой фазы нет)
- coder: NO SUGGESTIONS (дерево финально и проверено контрольным прогоном
  10:37:20: `corpus: clean` (exit 0), `selftest: 26/26 caught` (exit 0);
  дополнений не предлагаю)
- coder: NO OBJECTIONS (к работе fresh-итерации претензий нет; этот хендл
  действий не выполнял — ни правок, ни стейджинга, ни статуса)
- Q(coder#1): Конверт PRE_STATUS_LINE=`In progress` разошёлся с фактом: статус `In review` (с 10:07:22), Coder CENSOR OK (10:14:31), 16 файлов staged, reviewer-risk intake 10:19:47 — фаза Coder закрыта параллельной fresh-итерацией (recovery-гонка: конверт отправлен до её завершения). Дублировать закрытую фазу и трогать staged-снимок ревью не стал. Подтверди: действия от этого хендла не требуются. to=manager, blocker: yes, needs_owner: no, status=open
- A(manager#1): Подтверждаю — действия от хендла итерации 02:26:03 не требуются: фаза work закрыта fresh-итерацией 09:53:20 (Evidence 10:07:22) и валидирована CENSOR 10:14:31; твой стоп по расхождению PRE_STATUS_LINE корректен, нулевое действие — правильный исход; рекомендации по needs-fix Round 1 пойдут рабочему хендлу fresh-итерации. status=closed, перенесено в Evidence
- Intake (2026-11-14 10:44:16): AGENTS.md@ae39388a coder.md@976c292b
  (fixes-итерация раунда 1 по needs-fix risk-лейна (10:44:10) без Loop
  signal; digest'ы сверены shasum — контракты неизменны с CENSOR-intake
  10:14:31 (смена AGENTS.md @f155be52 → @ae39388a закрыта миграцией
  Evidence 10:02:05); план целиком и review-артефакт
  `docs/reviews/261113_1642_review.md` (Round 1: findings 1–4 risk-лейна,
  Contracts-секция за плейсхолдерами — лейны продолжает Manager после
  fixes) перечитаны с диска; статус `In review` сверен с PRE_STATUS_LINE
  конверта — совпал; ставлю `In progress` по §2/D17 — статус fixes-
  итерации ставит Coder на intake)
- coder: NO QUESTIONS (findings 1–4 воспроизведены прогоном до правок:
  `FAIL C13 ... bad **Artifact state:** value` на артефакте этого плана
  (окно между лейнами) + `FAIL C7` на плейсхолдере Contracts-вердикта —
  известный транзиент-прецедент 2121 раунд 1, вне findings; фиксы —
  в границах Scope: scripts/check_corpus.sh, planfaktor-run.md,
  docs/lifecycle.md; review-артефакт — зона ревьюеров, не трогаю)
- coder: NO SUGGESTIONS (минимальные фиксы по finding'ам: 4/1 — C13(г)
  толерантность плейсхолдера + гейтирование на записанную форму,
  C13(д)/(г) superseded-изъятие; 2 — гейт терминальности до Owner-гейта
  + безтупиковый closeout; 3 — позитивные baseline-утверждения чистоты
  bait'ов Round 2/3 вне счётчика caught 26)
- coder: NO OBJECTIONS (фиксы реализуют DoD-намерение D21/D22
  «промежуточное состояние артефакта между лейнами линт не роняет»;
  тайминг-наблюдение: репродукция findings выполнялась после intake —
  порядок work-действий итерации соблюдён)
- Intake (2026-11-14 11:07:29): AGENTS.md@ae39388a coder.md@976c292b
  (CENSOR-итерация fixes-раунда 1, dispatch censor:coder:261114_110539;
  digest'ы пересчитаны shasum — контракты неизменны с fixes-intake
  10:44:16; план перечитан с диска (включая ремонт Manager'а своей
  строки 10:11:15 в 11:05:39), статус `In review` сверен
  с PRE_STATUS_LINE конверта — совпал)
- coder: NO QUESTIONS (CENSOR-сверка вопросов не породила: открытых
  Q-строк без закрывающих A нет — Q(coder#1) закрыт A(manager#1))
- coder: NO SUGGESTIONS (сверх перестейджинга плана после Manager-
  ремонта 11:05:39 дополнений не предлагаю)
- coder: NO OBJECTIONS (к собственному fixes-handoff — после сверки
  с файлами; детали — receipt в Evidence)
- Intake (2026-11-14 11:32:40): AGENTS.md@ae39388a reviewer-risk.md@a51f0eb4
  (Round 2 — реран после fixes раунда 1; digest'ы пересчитаны shasum —
  оба контракта неизменны с Round-1 intake 10:19:47; носитель
  .zcode/commands/planfaktor-run.md сменился фиксом раунда 1
  @fec9b9d9 → @d66fac0a — миграция закрыта Evidence 10:59:22, §3 п.7
  соблюдён; план перечитан: fixes-факты Tests 11:02, Evidence 10:59:22/
  11:03:36 + CENSOR 11:07:29, Q&A-хвост; Status `In review` сверен
  с PRE_STATUS_LINE конверта — совпал; review-артефакт Round 1 мой,
  Contracts-секция за плейсхолдерами)
- reviewer-risk: NO QUESTIONS (Round 1 вердикт needs-fix без Loop
  signal — сигнал не требуется, ID не переиспользуются; Rerun mode
  Round 2 обязан быть full: инкрементальному режиму нужен prior pass-
  раунд, Round 1 — needs-fix)
- reviewer-risk: NO SUGGESTIONS (фаза review; несрочные улучшения сверх
  findings в фазе не предлагаются)
- reviewer-risk: NO OBJECTIONS (противоречий с конституцией ae39388a
  и роль-доком a51f0eb4 не вижу; статус сверен)
- Intake (2026-11-14 15:06:22): AGENTS.md@ae39388a reviewer-contracts.md@dd9bcb7a
  (Round 2 — contracts-лейн, второй лан после рерана risk-лейна; digest'ы
  пересчитаны shasum -a 256: reviewer-contracts.md@dd9bcb7a совпадает
  с миграционной записью Evidence 10:02:05 (@a7bcfdfa → @dd9bcb7a — правка
  Coder'а), AGENTS.md@ae39388a неизменен с risk-intake 10:19:47; план
  перечитан с диска целиком, Status `In review` сверен с PRE_STATUS_LINE
  конверта — совпал; staged = 16 файлов = 15 носителей Scope + план,
  unstaged-дельта — только план (intake-записи лейнов), носители чисты)
- reviewer-contracts: NO QUESTIONS (предмет фазы задан конвертом и роль-доком
  однозначно: тот же staged diff против HEAD, сверка по D1–D25 и границам
  Scope/Out of scope; порядок ланов risk → contracts соблюдён — risk-лейн
  Round 1 записан 10:44:10, Round 2 идёт передо мной)
- reviewer-contracts: NO SUGGESTIONS (фаза review; несрочные улучшения
  сверх findings в фазе не предлагаются)
- reviewer-contracts: NO OBJECTIONS (противоречий плана с конституцией
  ae39388a и роль-доком dd9bcb7a не вижу; статус сверен)

## Suggestions log (chronological, append-only)
<!-- owner: все роли; несрочные улучшения -->

## Objections log (chronological, append-only)
<!-- owner: все роли; `### <Role> objections`; строка на возражение, blocker: при блокере -->

## Follow-ups (deferred)
<!-- owner: coder/planner при CENSOR; незакрытые хвосты: <описание> — why: <почему сейчас не в скоупе>; обязательна запись `NO FOLLOW-UPS — why: <код_причины>` при отсутствии -->

NO FOLLOW-UPS — why: covered-by-out-of-scope (хвосты — qa-lint, lint-v2-digest-verify, автоматизация terminal state в /planfaktor-status — уже зафиксированы в Out of scope плана и/или docs/followups/backlog.md; остаток де-хардкода CONTRIBUTING — соседний план 261113_1944, Solution п.4).

