# Релизный узел конвейера: конвенция тегов/сборок/release-notes и статус released в реестре

**Plan ID:** 261115_2252
**Status:** Merged
**Created:** 2026-11-15
**Owner gates:** merge (`In review` → `Merged`); вопросы `to=Owner` — по мере возникновения

> Шапка — parser-контракт: строки выше grep'аются Manager'ом. Не менять формат.
> Имя файла: `261115_2252_release_node.md`.

## Как я понял задачу
<!-- owner: architect; 3–7 строк; обязательна при Architect intake -->

Owner продвинул backlog-строку id=release-node (P2): у конвейера нет релизного
узла — трасса реестра «требование → план → изменение → верификация → релиз»
разомкнута на последнем звене, тегов в репо нет. Статус `released` сознательно
не вводился планом 261112_2236 (валидация К3: не было уполномоченного писателя
и коммит-пути), комплаенс-маппинг несёт три честных «частично» (5.4, 5.5.3.3,
5.20). Продукт конвейера — сам корпус («целиком в ZCode, без рантайма»),
поэтому выпуск — это аннотированный тег semver + релиз-нота + переводы
`verified → released` в реестре, а «сборка» — верифицированный снапшот (свежие
линт/selftest/C14 на тегаемом коммите), не бинарный артефакт. Режет релиз
Manager по явному указанию Owner с тем же fresh-green инвариантом, что и
merge; релиз — событие вне статусной машины планов (§2 не меняется). Первый
выпуск `v0.1.0` — операционное решение Owner после merge, не DoD. Новые
требования G56939-5.4/5.20 засеяны в реестр на этом intake по регламенту
предъявления (docs/requirements/README.md).

## Problem
<!-- owner: architect; пронумерованные пункты -->

1. Трасса внешних требований разомкнута на финальном звене: шапка реестра
   обещает «…→ верификация → релиз», но носителя «релиз» нет — git-теги
   в репо отсутствуют (`git tag` пуст), понятие выпуска корпуса нигде
   не определено.
2. Реестр не может выразить выпуск: enum статусов `open|planned|verified`;
   `released` исключён до релизной конвенции (план 261112_2236, валидация
   К3 — не было уполномоченного писателя и коммит-пути). Расширение enum
   без конвенции = false-обещание клиенту.
3. Комплаенс-маппинг ГОСТ Р 56939-2024 несёт три «частично», закрытых именно
   релизным узлом: 5.4 (нет идентификации релизных версий), 5.5.3.3 (нет
   релизной версии ПО), 5.20 (не введён выпуск готовой версии: теги,
   release-notes, анализ перед выпуском) — клиенту предъявляется неполная
   трасса.
4. Процесс выпуска не формализован: не определено, кто и по чьему решению
   режет релиз, на каком коммите, с какой верификацией, где живут
   release-notes, какие требования и как переводятся в `released`. Пункты
   5.4 и 5.20 стандарта не представлены в реестре — трасса входа для них
   не начата.

## Solution / Decisions
<!-- owner: architect; решения уровня «что и почему», без детализации -->

1. **Релиз = аннотированный git-тег + релиз-нота.** Тег `vX.Y.Z` (semver)
   указывает на closeout-хвост последнего Done-плана либо коммит, явно
   указанный Owner. «Сборка» для корпуса без рантайма — верифицированный
   снапшот на тегаемом коммите: свежие `corpus: clean`, selftest caught
   и C14-чистота (тот же fresh-green инвариант, что у merge, §8); бинарных
   артефактов нет, публикация GitHub Releases опциональна при наличии remote
   и инвариантом не является. Честная граница: 5.12/5.13 (безопасная
   сборка/среда) остаются «вне скоупа конвейера».
2. **Носители:** `docs/releases/README.md` — конвенция (определение релиза,
   версии, процесс, полномочия, границы); `docs/releases/_template.md` —
   шаблон релиз-ноты (доктрина §9 по трактовке 261112_2236: класс
   повторяющейся структуры — шаблон обязателен); релиз-ноты —
   `docs/releases/vX.Y.Z.md`, по одной на выпуск. Состав ноты: версия/дата/
   тег/базовый коммит; вошедшие планы с прошлого тега (PlanID, тип, тема);
   требования → released (IDs и записи журнала); verification-evidence
   (факты линта/selftest/C14 на тегаемом коммите); известные ограничения
   (открытые backlog-хвосты) — честные границы предъявления.
   rejected alternative: единый CHANGELOG.md — ломает принцип «один выпуск =
   один артефакт» (прецедент планов/review/followups) и пер-выпускную
   верифицируемость.
3. **Версионирование:** старт `v0.1.0`; эпоха 0.x — стабилизация конституции,
   переход на `v1.0.0` — явное решение Owner; инкременты: MAJOR —
   несовместимые изменения контрактов (AGENTS.md/роли/шаблоны), MINOR — новые
   возможности (большинство merge-планов), PATCH — точечные фиксы без нового
   плана. rejected alternative: старт сразу `v1.0.0` — корпус ещё
   формируется, 0.x честно сигнализирует клиенту зрелость; версия любого
   конкретного выпуска остаётся решением Owner и конвенцией не предопределена.
4. **Полномочия и процесс:** релиз режет Manager по явному указанию Owner
   (версия и момент — решение Owner; тег — git-объект, единственный писатель
   git-объектов — Manager, §8). Конвейерный якорь — буллет в §8: сущность
   (тег + релиз-нота + переводы реестра), условие (явное указание Owner),
   инвариант (свежий green-прогон линта на тегаемом коммите), указатель на
   конвенцию. Релиз — событие вне статусной машины планов: §2 и Owner-гейты
   планов не меняются; молчание Owner ничего не режет (owner-silence, §6).
5. **Статус `released` в реестре:** enum `open|planned|verified|released`;
   переход `verified → released` при выпуске, содержащем реализацию
   требования: по умолчанию переводятся все rows в `verified` на момент
   выпуска (либо явный список Owner); переводит Manager, запись журнала
   `<ID>: verified → released — <тег>`. Уполномоченный писатель и путь
   определены — оговорка К3 плана 261112_2236 исчерпана. Линт: C12(б)
   расширяет enum-инвариант синхронно; selftest-посадка C12b
   статус-независима (фикс 261112_2236 не ломается); новые чеки и счётчики
   не вводятся (de-hardcode в CONTRIBUTING не затрагивается).
6. **Засев реестра (выполнен на этом intake по регламенту «Предъявление»):**
   rows `G56939-5.20` (приёмка/анализ перед выпуском/регламент приёмки; P1 —
   клиентский предъявляемый процесс) и `G56939-5.4` (идентификация релизных
   версий: теги + ноты + статус released; P2), `статус=open`, `plan=none`,
   предъявлено=2026-11-12 Owner (исходный бриф ГОСТ), принято=Architect
   2026-11-15; матрица — производные строки («предстоит»/«до merge»).
   Дальше по регламенту: `planned` на входе плана в работу, `verified`
   на merge, `released` на выпуске. 5.5.3.3 уже в реестре (verified) —
   закрываемый этим планом срез (релизная версия ПО) даёт второй план
   в матрице: честная трасса расширения.
7. **Синхронные поверхности:** регламент `docs/requirements/README.md` —
   правило перехода `released` (кто/когда/форма записи); шапка формата
   реестра — enum `+released`; `docs/requirements/matrix.md` — пересборка
   на кодинге (planned) и merge (verified); комплаенс-маппинг — строки
   5.4/5.5.3.3/5.20: «частично» → «реализовано (в границах конвейера)»
   с механизмом релизного узла; backlog — row `release-node` →
   `status=promoted, plan=261115_2252` + пересборка `docs/followups/index.md`;
   `README.md` — указатель на конвенцию в «Куда дальше».
8. **Границы:** план доставляет конвенцию и механизмы, не сам первый выпуск:
   резка `v0.1.0` — операционное решение Owner после merge; DoD проверяет
   конвенцию/реестр/линт/комплаенс, а не существование тега. Формат
   релиз-нот и соответствие тег↔файл машинно не проверяются (кандидат v2);
   5.12/5.13 и GitHub-публикация — вне инвариантов.

## Scope
<!-- owner: architect (границы), planner (уточняет); список изменений; пункты, реализующие внешние требования, несут метку [R: <ID>] (ID — из docs/requirements/registry.md); план, меняющий shared-контракт (AGENTS.md, docs/roles/*, шаблоны, .zcode/commands/*, scripts/check_corpus.sh), до handoff несёт в Scope fan-out инвентарь: изменяемый носитель + зависимые проверки + зависимые доки + известные consumer-пути (конституция §5; «audit later» = plan-gap) -->

- Новые: `docs/releases/README.md` (конвенция релизного узла: теги, сборка
  как верификация, процесс, версии, границы),
  `docs/releases/_template.md` (шаблон релиз-ноты). [R: G56939-5.20]
  [R: G56939-5.4]
- Реестр: rows `G56939-5.4`/`G56939-5.20` засеяны на Architect-intake
  (статус=open, plan=none; Evidence); кодинг-чейнджсет — перевод
  `open → planned` (`plan=261115_2252`) + записи журнала; шапка формата
  `registry.md` — enum `статус=<open|planned|verified|released>`.
  [R: G56939-5.4]
- Регламент: `docs/requirements/README.md` — «Отслеживание»: правило
  перехода `verified → released` (выпуск; Manager по указанию Owner;
  запись журнала с тегом). [R: G56939-5.20]
- Матрица: `docs/requirements/matrix.md` — производные строки засеяны
  на intake; пересборка на кодинге (planned/DoD/Tests) и merge
  (verified/коммиты).
- Линт: `scripts/check_corpus.sh` — C12(б): enum статусов rows `+released`;
  selftest не меняется (посадка C12b статус-независима).
- Конституция: `AGENTS.md` — §9 += строка `docs/releases/`; §8 += буллет
  «Релизы» (Manager по явному указанию Owner; fresh-green на тегаемом
  коммите; конвенция — docs/releases/README.md). Миграционные записи §3 п.7:
  `AGENTS.md`, `scripts/check_corpus.sh`.
- Комплаенс: `docs/compliance/gost-r-56939-2024.md` — строки 5.4, 5.5.3.3,
  5.20: «частично» → «реализовано (в границах конвейера)», механизм —
  релизный узел. [R: G56939-5.20] [R: G56939-5.4] [R: G56939-5.5.3.3]
- Followups: `docs/followups/backlog.md` — row `release-node`:
  `status=promoted`, `plan=261115_2252`; `docs/followups/index.md` —
  пересборка (derived).
- Доки: `README.md` — указатель на `docs/releases/README.md`
  в «Куда дальше».
- Носители: этот план + review-артефакт.
- **Fan-out инвентарь (§5; изменяемые shared-контракты — `AGENTS.md`,
  `scripts/check_corpus.sh`):**
  - `AGENTS.md` (§8+§9): изменяемый носитель — сам AGENTS.md; зависимые
    проверки — C9 (ссылки из AGENTS.md: docs/releases/README.md валиден
    с момента создания файла), C10 (roles↔agents — §8/§9 в сверку тождества
    не входят, полный прогон обязателен), C1 (шапки планов не затронуты);
    зависимые доки — `docs/lifecycle.md` (план-цикл и Owner-гейты не
    меняются: релиз вне машины планов), `CONTRIBUTING.md` (цитирует §8
    только в формате коммитов — не конфликтует), `README.md` (описание
    гейта merge — без изменений), `docs/roles/*` и `.zcode/commands/*`
    (grep-контроль: §8-релизы по содержанию не цитируются — формулировки
    остаются корректными); consumer-пути — run-рутина Manager'а
    (merge/closeout), CENSOR-гейты, Owner.
  - `scripts/check_corpus.sh` (C12): изменяемый носитель — сам скрипт;
    зависимые проверки — selftest (счётчики и `_st_total` не меняются —
    итог caught без правки формулировок), CI `.github/workflows/corpus.yml`
    (обе команды на push/PR), pre-merge verify §8; зависимые доки —
    `CONTRIBUTING.md` (de-hardcode инвариант: литеральные счётчики не
    реинтродьюсируются), `docs/reviews/_template_review.md` (contracts-лан
    про R-метки — без изменений; расширение enum обратно совместимо);
    consumer-пути — реестр/матрица (rows `released` валидны после
    расширения), регламент.

## Out of scope
<!-- owner: architect -->

- Резка первого выпуска (`v0.1.0`: тег + релиз-нота + переводы
  `verified → released`) — операционное решение Owner после merge; путь
  зафиксирован конвенцией (docs/releases/README.md), конвейер операцию
  не планирует.
- Машинная проверка формата релиз-нот и соответствия тег↔файл (кандидат
  C15/v2; сейчас — только enum-расширение C12(б)).
- Автоматизация выпуска (релиз-скрипт, автогенерация нот/матрицы) —
  кандидат v2 (прецедент: автогенерация матрицы — Follow-ups 261112_2236).
- Публикация GitHub Releases как инвариант (опциональна при наличии remote;
  корпус предъявим git-архивом).
- 5.12/5.13 (безопасная система/среда сборки) — чужие инструменты, «вне
  скоупа конвейера» в маппинге, без изменений.
- Разделение backlog на «недостатки»/«запросы на изменение» (5.5.3.4) — уже
  кандидат v2 (Follow-ups 261112_2236), здесь не пересматривается.

## Acceptance criteria / DoD
<!-- owner: planner; чек-лист проверяемых исходов; каждый пункт = проверяемое утверждение; пункты, реализующие внешние требования, несут метку [R: <ID>] (ID — из docs/requirements/registry.md) -->

- [ ] D1. Файл `docs/releases/README.md` существует и несёт конвенцию
  релизного узла (Solution п.1–4, п.8) всеми семью элементами: (а)
  определение релиза — аннотированный git-тег `vX.Y.Z` (semver) +
  релиз-нота `docs/releases/vX.Y.Z.md` + переводы `verified → released`
  в реестре; тег указывает на closeout-хвост последнего Done-плана либо
  коммит, явно указанный Owner; (б) «сборка» корпуса без рантайма —
  верифицированный снапшот на тегаемом коммите: свежие `corpus: clean`,
  selftest caught и C14-чистота (fresh-green инвариант, симметрично §8);
  бинарных артефактов нет, публикация GitHub Releases опциональна при
  наличии remote и инвариантом не является; (в) версионирование — старт
  `v0.1.0`, эпоха 0.x — стабилизация конституции, `v1.0.0` — явное
  решение Owner, инкременты MAJOR (несовместимые изменения контрактов) /
  MINOR (новые возможности) / PATCH (точечные фиксы без плана); (г)
  полномочия и процесс — релиз режет Manager по явному указанию Owner
  (версия и момент — решение Owner), релиз — событие вне статусной машины
  планов, молчание Owner ничего не режет (owner-silence §6); (д) состав
  релиз-ноты — семь блоков Solution п.2 (версия/дата/тег/базовый коммит;
  вошедшие планы с прошлого тега; требования → released; verification-
  evidence; известные ограничения) + правило «нота создаётся из
  `docs/releases/_template.md`» (доктрина §9); (е) переводы
  `verified → released` — по умолчанию все rows в `verified` на момент
  выпуска либо явный список Owner, запись журнала
  `<ID>: verified → released — <тег>`; (ж) честные границы — 5.12/5.13
  «вне скоупа конвейера». [R: G56939-5.20] [R: G56939-5.4]
- [ ] D2. Файл `docs/releases/_template.md` существует и является
  шаблоном релиз-ноты с секциями-заголовками `## `, покрывающими все
  пять блоков состава Solution п.2: шапка выпуска (версия, дата, тег,
  базовый коммит — плейсхолдеры), вошедшие планы с прошлого тега (PlanID,
  тип, тема), требования → released (IDs и записи журнала),
  verification-evidence (факты линта/selftest/C14 на тегаемом коммите),
  известные ограничения (открытые backlog-хвосты). [R: G56939-5.20]
  [R: G56939-5.4]
- [ ] D3. `AGENTS.md` изменён ровно в двух местах: (а) §8 — добавлен
  ровно один буллет, начинающийся литералом `- Релизы:`, внутри секции
  §8 (между заголовками `## 8.` и `## 9.`), несущий все четыре якорных
  элемента Solution п.4: сущность (аннотированный тег `vX.Y.Z` +
  релиз-нота + переводы реестра), условие (явное указание Owner),
  инвариант (свежий green-прогон corpus-линта на тегаемом коммите),
  указатель на конвенцию `docs/releases/README.md`; (б) §9 — в перечень
  каталогов добавлена ровно одна строка, начинающаяся литералом
  `docs/releases/` (релизные ноты + `_template.md`, указатель на
  конвенцию). Иных правок AGENTS.md нет; C9-валидность пути
  `docs/releases/README.md` из AGENTS.md обеспечена файлом D1.
- [ ] D4. `scripts/check_corpus.sh` — C12(б) расширен ровно одной
  строкой: enum-паттерн `статус=(open|planned|verified)` →
  `статус=(open|planned|verified|released)` (строка проверки поля
  `статус=` в check_c12); иных строк скрипта diff не затрагивает; selftest
  не менялся: счётчики и `_st_total` нетронуты, `--selftest` →
  `selftest: 33/33 caught`, exit 0 (посадка selftest C12b
  статус-независима — фикс 261112_2236 не ломается; de-hardcode инвариант
  CONTRIBUTING не затронут — новые счётчики не вводятся).
- [ ] D5. `docs/requirements/registry.md`: (а) rows G56939-5.4 и
  G56939-5.20 переведены `статус=open` → `статус=planned`,
  `plan=none` → `plan=261115_2252`, остальные 6 полей каждой row байтово
  неизменны; (б) «Журнал статусов» += ровно 2 записи формы
  `- <TS> — <ID>: open → planned — 261115_2252` (по одной на 5.4 и 5.20);
  (в) шапка формата синхронна новому enum: код-спан формулы row несёт
  `статус=<open|planned|verified|released>`, пояснение поля `статус=`
  перечисляет все четыре значения со ссылкой на конвенцию
  `docs/releases/README.md`; формулировка «статуса `released` нет до
  релизной конвенции (backlog `release-node`)» из файла ушла; (г) row
  G56939-5.5.3.3 не менялась — второй план отражается только матрицей
  (D8), поле `plan=` реестра остаётся `261112_2236`. [R: G56939-5.4]
- [ ] D6. `docs/requirements/README.md`, раздел «Отслеживание»: после
  ветки `verified` добавлена ветка статуса `released` — перевод при
  выпуске, содержащем реализацию требования: переводит Manager по
  явному указанию Owner на резке релиза; по умолчанию переводятся все
  rows в `verified` на момент выпуска, либо явный список Owner; запись
  журнала `<ID>: verified → released — <тег>`; другие разделы регламента
  (Предъявление/Предоставление/Критерии пересмотра) не менялись.
  [R: G56939-5.20]
- [ ] D7. `docs/compliance/gost-r-56939-2024.md`: строки трёх пунктов
  изменены «частично» → «реализовано (в границах конвейера)»: 5.4 —
  механизм расширен релизным узлом (аннотированные теги `vX.Y.Z`,
  release-notes `docs/releases/`, привязка требований статусом
  `released`; конвенция `docs/releases/README.md`), артефакт-носитель +=
  `docs/releases/`; 5.5.3.3 — «версия ПО» дополнена релизной версией
  (тег выпуска), носитель += `docs/releases/`; 5.20 — механизм расширен
  конвенцией выпуска: приёмка = fresh-green verify на тегаемом коммите +
  Owner-гейт, анализ перед выпуском = release-нота (verification-evidence
  + известные ограничения); упоминания «backlog `release-node`» из этих
  трёх строк ушли; строка 5.5.2.2–5.5.3.4 (разделение классов — кандидат
  v2) и прочие строки маппинга не менялись; «Версия документа» += строка
  об обновлении планом 261115_2252. [R: G56939-5.20] [R: G56939-5.4]
  [R: G56939-5.5.3.3]
- [ ] D8. `docs/requirements/matrix.md` пересобран по правилам раздела
  «Правила пересборки» (сами правила не менялись): (а) строки G56939-5.4
  и G56939-5.20 — статус `planned`, Планы = `261115_2252`, DoD/Tests =
  фактические метки этого плана (5.4: `D1, D2, D5, D7` / `T1, T2, T5,
  T7`; 5.20: `D1, D2, D6, D7` / `T1, T2, T6, T7`), Review = предстоит,
  Коммиты = до merge; (б) строка G56939-5.5.3.3 — Планы
  `261112_2236, 261115_2252`, DoD/Tests попарно по позиции
  (`D7, D7` / `T8, T7`); (в) заголовок состояния обновлён (дата,
  кодинг-чейнджсет 261115_2252: planned + проставленные метки);
  (г) примечания к связям актуализированы (фаза planned выполнена,
  вердикты/коммиты — до merge).
- [ ] D9. `docs/followups/backlog.md`: row id=release-node переведена
  в promoted по row-грамматике: `[ ]` → `[x]`, `status=open` →
  `status=promoted`, `plan=none` → `plan=261115_2252`; поля summary,
  `to=Architect`, `id`, `source_ref`, `why` байтово неизменны; других
  строк backlog правка не касается. `docs/followups/index.md` пересобран:
  release-node удалён из открытых P2 (заголовок «### P2 (5)» →
  «### P2 (4)») и добавлен ровно одной строкой в «## Закрытые»
  (`- release-node — P2 — status=promoted — plan=261115_2252 (<summary>)`);
  счётчик: «открытых — 12, закрытых (promoted/handled/cancelled) — 4
  (состояние на <дата правки>)»; сумма строк данных открытых таблиц = 12;
  счётчик закрытых равен фактическому числу строк «## Закрытые» = 4
  (3 handled — closeout-tail-convention, merge-untracked-guard, ci-hygiene;
  1 promoted — release-node). [fixes R1 review Round 1: прежняя редакция
  предписывала «— 5», закрепив сдвинутый инкремент 4→5 базы вне-
  конвейерного коммита 8a1d2fa (поднял закрытых 3→4 при фактических 3);
  пересчёт: закрытых = 4.]
- [ ] D10. `README.md`: в раздел «Куда дальше» добавлен ровно один
  буллет с указателем на `docs/releases/README.md` (релизная конвенция
  конвейера: теги, верифицированный снапшот, release-ноты); иных правок
  README.md нет.
- [ ] D11. Fan-out инвентарь §5 (перенос из Scope) исчерпан:
  (а) изменены ровно два shared-контракта — AGENTS.md (D3) и
  `scripts/check_corpus.sh` (D4); полный прогон
  `sh scripts/check_corpus.sh` → `OK C1`…`OK C14`, итог `corpus: clean`,
  exit 0 — C9 подтверждает валидность новых путей `docs/releases/…`
  из AGENTS.md и README.md, C10 полный прогон зелёный, C1 шапки планов
  не затронуты; (б) `sh scripts/check_corpus.sh --selftest` →
  `selftest: 33/33 caught`, exit 0; CI `.github/workflows/corpus.yml`
  не менялся (обе команды push/PR работают против расширенного C12);
  (в) миграционные записи §3 п.7 в `## Evidence` этого плана: смена
  digest по каждому изменённому контракту — AGENTS.md
  `dee70da5 → <новый@8hex>` и `scripts/check_corpus.sh`
  `1997893a → <новый@8hex>` (старые digest'ы — фактические на момент
  начала правок; база на момент Planning: dee70da5 / 1997893a), с меткой
  времени; (г) зависимые доки-парафразы не правились и противоречий
  не несут: `docs/lifecycle.md` (план-цикл и Owner-гейты не меняются —
  релиз вне машины планов), `CONTRIBUTING.md` (цитирует §8 только
  в формате коммитов; de-hardcode не затронут), `docs/roles/*` и
  `.zcode/commands/*` (grep-контроль: §8-релизы по содержанию
  не цитируются), `docs/reviews/_template_review.md` (R-метки лан —
  без изменений, расширение enum обратно совместимо); (д) broad-drift
  контроль: после правок упоминания идентификатора «release-node»
  отсутствуют во всех активных носителях, кроме исторических
  идентификаторов в why backlog-строки (D9) и примечаниях матрицы
  (D8): `grep -rn 'release-node' README.md CONTRIBUTING.md AGENTS.md
  docs/roles .zcode/commands docs/lifecycle.md docs/plans/README.md
  docs/plans/_template.md docs/reviews/_template_review.md
  docs/requirements/README.md` → 0 совпадений (база на момент
  Planning — 0, проверено 2026-11-15 23:24: буллет D10 и ветка D6
  идентификатор не заносят);
  `grep -c 'release-node' docs/requirements/registry.md` → 0 (база 1 —
  пояснение поля `статус=`, правится D5(в));
  `grep -c 'release-node' docs/compliance/gost-r-56939-2024.md` → 0
  (база 3 — строки 5.4/5.5.3.3/5.20, правятся D7); prose-якорь «нет
  до релизной конвенции» уходит из registry.md переписыванием
  пояснения (литеральный grep по фразе ненадёжен — разорвана
  переносом строки, поэтому якорь — идентификатор backlog).
- [ ] D12. Диф ограничен Scope и процессная дисциплина §5: staged-диф
  затрагивает ровно 11 файлов (AGENTS.md, README.md,
  scripts/check_corpus.sh, docs/compliance/gost-r-56939-2024.md,
  docs/followups/backlog.md, docs/followups/index.md,
  docs/releases/README.md, docs/releases/_template.md,
  docs/requirements/README.md, docs/requirements/matrix.md,
  docs/requirements/registry.md) — план и посторонние файлы не
  стейджированы; до начала правок по каждому D1–D11 в `## Evidence`
  зафиксирован ровно один исход AC-to-test (`explicit assertion` |
  `existing proof` | `N/A (why=…)` | `reroute`); по завершении
  `## Changes (by area)` заполнен и evidence-факты прогонов T1–T12
  записаны.

## Tests / Commands
<!-- owner: planner (задаёт), coder (заполняет факт); каждый DoD-пункт (Dn) покрывается строкой с меткой (Dn); R-DoD — обязательно; при переименованиях/миграциях терминологии — narrow + broad proof: narrow — exact-паттерн нового wording (база «сейчас 0», если якорь различающий), broad — prose-drift старого токена по всем активным носителям с классификацией вхождений (исторические планы и append-only артефакты исключены — там старое имя остаётся вечно) -->

- T1 (D1): `test -f docs/releases/README.md` → exit 0. Якорные
  литералы конвенции (каждый ≥ 1): `grep -c 'vX.Y.Z'
  docs/releases/README.md`; `grep -c 'v0.1.0' docs/releases/README.md`;
  `grep -cE 'MAJOR|MINOR|PATCH' docs/releases/README.md` (все три
  токена отдельно); `grep -c 'owner-silence' docs/releases/README.md`;
  `grep -c 'docs/releases/_template.md' docs/releases/README.md`;
  `grep -c 'closeout' docs/releases/README.md`; `grep -c
  'verified → released' docs/releases/README.md`; `grep -c 'C14'
  docs/releases/README.md`; `grep -cE '5\.12' docs/releases/README.md`;
  `grep -cE '5\.13' docs/releases/README.md`; `grep -ci 'github
  releases' docs/releases/README.md`. Осмотр: все семь элементов
  D1(а)–(ж) представлены, A/B-решения Solution п.2/п.3 отражены
  (per-release ноты; старт v0.1.0).
  - Факт (2026-11-15 23:41): test -f → exit 0; якорные счётчики:
    vX.Y.Z=3, v0.1.0=2, MAJOR=1, MINOR=1, PATCH=1, owner-silence=1,
    docs/releases/_template.md=2, closeout=2, «verified → released»=4,
    C14=3, 5.12=1, 5.13=1, github releases (-i)=1 — все ≥ 1. Осмотр
    семи элементов: (а) «Определение релиза» — тег+нота+переводы,
    closeout-хвост/коммит Owner; (б) «Сборка корпуса без рантайма» —
    fresh-green corpus:clean/selftest/C14, GitHub Releases опциональна;
    (в) «Версионирование» — v0.1.0, эпоха 0.x, v1.0.0 решением Owner,
    MAJOR/MINOR/PATCH; (г) «Полномочия и процесс» — Manager по указанию
    Owner, вне статусной машины, owner-silence; (д) «Состав релиз-ноты» —
    пять блоков + правило «из _template.md»; (е) «Переводы verified →
    released» — по умолчанию все/список Owner, форма записи журнала;
    (ж) «Границы конвенции» — 5.12/5.13 вне скоупа конвейера. Все семь
    представлены; A/B-решения отражены: per-release ноты (CHANGELOG.md
    отклонён в тексте конвенции), старт v0.1.0.
- T2 (D2): `test -f docs/releases/_template.md` → exit 0;
  `grep -c '^## ' docs/releases/_template.md` → ≥ 5 (пять блоков
  состава ноты Solution п.2); осмотр: шапка выпуска несёт плейсхолдеры
  версии/даты/тега/базового коммита; блоки «вошедшие планы»,
  «требования → released», «verification-evidence», «известные
  ограничения» различимы по заголовкам/подзаголовкам.
  - Факт (2026-11-15 23:41): test -f → exit 0; `grep -c '^## '` → 5
    («Шапка выпуска», «Вошедшие планы (с прошлого тега)», «Требования →
    released», «Verification-evidence (сборка = верифицированный
    снапшот)», «Известные ограничения»). Осмотр: шапка несёт
    плейсхолдеры версии (vX.Y.Z), даты (<YYYY-MM-DD HH:MM:SS>), тега
    (`vX.Y.Z`), базового коммита (<полный хэш> + closeout-хвост/коммит
    Owner); блоки планов/требований/verification/ограничений различимы
    по заголовкам.
- T3 (D3): `awk '/^## 8\./{f=1} /^## 9\./{f=0} f' AGENTS.md | grep -c
  '^- Релизы:'` → 1; `grep -c '^- Релизы:' AGENTS.md` → 1; в блоке
  буллета (осмотр `awk '/^- Релизы:/{f=1;print;next} /^- /{f=0} f'
  AGENTS.md` либо sed-диапазон §8) присутствуют литералы: `vX.Y.Z`,
  `Owner`, `green`, `docs/releases/README.md`, слово «нот» и
  «released»/«реестр»; `grep -c '^docs/releases/' AGENTS.md` → 1;
  `git diff -U2 -- AGENTS.md` → ровно два блока изменений (буллет §8 +
  строка каталога §9), иных правок нет.
  - Факт (2026-11-15 23:41): awk-счётчик §8 → 1; полнотекстовой
    счётчик `^- Релизы:` → 1; `^docs/releases/` → 1. Блок буллета (awk-вывод)
    несёт литералы: `vX.Y.Z` (тег), Owner (дважды), green
    («green-прогон»), docs/releases/README.md, «релиз-нота» (нот),
    «verified → released» и «реестре требований» (released/реестр).
    `git diff -U2` → ровно 2 hunk'а: @@ -345,4 +345,11 @@ (7 строк
    буллета) и @@ -361,4 +368,5 @@ (1 строка каталога); только
    вставки (8 insertions, 0 deletions).
- T4 (D4): `git diff -- scripts/check_corpus.sh` → ровно один hunk
  одной строки: `-`-строка с `статус=(open|planned|verified)` и
  `+`-строка с `статус=(open|planned|verified|released)`;
  `grep -c 'статус=(open|planned|verified|released)' scripts/check_corpus.sh` → 1;
  `sh scripts/check_corpus.sh --selftest` → итог
  `selftest: 33/33 caught`, exit 0.
  - Факт (2026-11-15 23:41): `git diff -- scripts/check_corpus.sh` →
    ровно один hunk @@ -757,7 +757,7 @@: `-`-строка
    `'^статус=(open|planned|verified)$'` / `+`-строка
    `'^статус=(open|planned|verified|released)$'`, иных правок нет;
    grep нового enum-паттерна → 1; selftest → `selftest: 33/33 caught`,
    EXIT=0 (счётчики и `_st_total` не тронуты — диф скрипта одной
    строкой).
- T5 (D5): `grep '^- G56939-5.4 ' docs/requirements/registry.md | grep -c
  'статус=planned — plan=261115_2252'` → 1; то же для `G56939-5.20` → 1;
  `grep -E '^- G56939-5\.(4|20) ' docs/requirements/registry.md | grep -cE
  'статус=open|plan=none'` → 0 (grep exit 1);
  `grep -c ': open → planned — 261115_2252' docs/requirements/registry.md` → 2;
  `grep -c 'статус=<open|planned|verified|released>' docs/requirements/registry.md` → 1;
  `grep -c 'release-node' docs/requirements/registry.md` → 0
  (база 1 — пояснение поля `статус=`; литеральный prose-якорь «нет до
  релизной конвенции» ненадёжен — разорван переносом строки);
  `git diff -- docs/requirements/registry.md` не затрагивает строку row
  G56939-5.5.3.3 (осмотр hunk'ов).
  - Факт (2026-11-15 23:42): rows 5.4/5.20 → `статус=planned —
    plan=261115_2252` по 1; остаточный паттерн `статус=open|plan=none`
    → 0 (exit 1); журнал `: open → planned — 261115_2252` → 2;
    код-спан `статус=<open|planned|verified|released>` → 1;
    `release-node` → 0. Осмотр дифа: строки `G56939-5.5.3.3`
    встречаются только как контекст (строк с префиксом +/-, несущих
    5.5.3.3, — 0); hunk'и: шапка-формула, пояснение `статус=` (уходит
    «нет до релизной конвенции … backlog release-node»), rows 5.4/5.20
    (вставка — засев Architect 23:03:25 + статусная часть кодинга),
    журнал += 2 записи (23:38:41).
- T6 (D6): `sed -n '/^## Отслеживание/,/^## Критерии/p'
  docs/requirements/README.md | grep -c 'released'` → ≥ 2;
  в разделе присутствуют литералы: `Manager`, `Owner`, форма записи
  `<ID>: verified → released — <тег>` (grep -F 'verified → released —
  <тег>' → 1); `git diff -- docs/requirements/README.md` ограничен
  разделом «Отслеживание».
  - Факт (2026-11-15 23:42): sed-диапазон «Отслеживание»: released → 2,
    Manager → 3, Owner → 3; grep -F формы записи → 1. Диф — один hunk
    @@ -53,6 +53,11 @@ (вставка ветки `released` после ветки
    `verified`, строки 53–58 файла — внутри раздела); разделы
    «Предъявление»/«Предоставление»/«Критерии пересмотра» не задеты.
- T7 (D7): для каждой из трёх строк: `grep -E '^\| 5\.4 \('
  docs/compliance/gost-r-56939-2024.md | grep -c 'реализовано'` → 1 и
  `… | grep -c 'частично'` → 0; `grep -E '^\| 5\.5\.3\.3 \|'
  docs/compliance/gost-r-56939-2024.md | grep -c 'реализовано'` → 1 и
  `частично` → 0; `grep -E '^\| 5\.20 \|'
  docs/compliance/gost-r-56939-2024.md | grep -c 'реализовано'` → 1 и
  `частично` → 0; `grep -c 'release-node'
  docs/compliance/gost-r-56939-2024.md` → 0; вхождения «частично» вне
  шапки документа — ровно 1 (строка 5.5.2.2–5.5.3.4, кандидат v2);
  `grep -c '261115_2252' docs/compliance/gost-r-56939-2024.md` → 1
  (строка «Версия документа»); в трёх строках упоминается
  `docs/releases/` (grep -c 'docs/releases/' по каждой → 1).
  - Факт (2026-11-15 23:43): все три строки — `реализовано`=1 и
    `частично`=0; `docs/releases/` в каждой → 1; `release-node` → 0;
    «частично» вне шапки — ровно 1 (строка 5.5.2.2–5.5.3.4, :49);
    `261115_2252` → 1 (строка «Версия документа» :92). Найден и
    исправлен дефект первой редакции: строка «Версия документа» несла
    слово «частично» в кавычках («„частично“ → „реализовано…“») —
    третье вхождение вне шапки против T7-базы «ровно 1»; переформулирована
    без токена («переведены в „реализовано (в границах конвейера)“»),
    повторный счёт — 1.
- T8 (D8): `grep -E '^\| G56939-5\.4 \|' docs/requirements/matrix.md`
  → строка содержит `261115_2252`, `D1, D2, D5, D7`, `T1, T2, T5, T7`,
  `planned`, `до merge`, `предстоит`; `grep -E '^\| G56939-5\.20 \|'
  docs/requirements/matrix.md` → строка содержит `261115_2252`,
  `D1, D2, D6, D7`, `T1, T2, T6, T7`, `planned`, `до merge`,
  `предстоит`; `grep -E '^\| G56939-5\.5\.3\.3 \|'
  docs/requirements/matrix.md | grep -c '261115_2252'` → 1; заголовок
  состояния содержит дату пересборки и `planned`;
  `git diff -- docs/requirements/matrix.md` не затрагивает «Правила
  пересборки» и grep-рецепт.
  - Факт (2026-11-15 23:43): строки 5.4 и 5.20 содержат
    `261115_2252` с метками `D1, D2, D5, D7` / `T1, T2, T5, T7` и
    `D1, D2, D6, D7` / `T1, T2, T6, T7` соответственно, обе с
    `предстоит | до merge | planned`; строка 5.5.3.3 — Планы
    `261112_2236, 261115_2252`, `D7, D7` / `T8, T7` попарно, Review
    «pass/pass; 261115_2252 — предстоит», Коммиты «merge-коммит;
    261115_2252 — до merge», счётчик `261115_2252` в строке → 1; статус
    verified (из row реестра — row не менялась, D5г). Заголовок
    состояния — дата 2026-11-15, «кодинг-чейнджсет плана 261115_2252 …
    planned». Диф: 3 hunk'а (заголовок, строки таблицы, примечание),
    «Правила пересборки» и grep-рецепт не задеты (grep по их содержимым
    строкам в дифе → 0); примечание 5.4/5.20 актуализировано — «фаза
    planned выполнена … вердикты/коммиты — до merge» (D8г);
    остаточные 2 «release-node» — исторические (заголовок +
    примечание).
- T9 (D9): `grep 'id=release-node' docs/followups/backlog.md` → ровно
  1 строка с `[x]`, `status=promoted`, `plan=261115_2252`;
  `grep 'id=release-node' docs/followups/backlog.md | grep -cE
  'status=open|plan=none|\[ \]'` → 0 (grep exit 1);
  `grep -n 'release-node' docs/followups/index.md` → ровно 1 строка
  в «## Закрытые» с `status=promoted — plan=261115_2252`;
  `grep -n '^### P2' docs/followups/index.md` → «### P2 (4)»;
  `grep -cE '^\| [a-z0-9-]+ \| P[123] \|' docs/followups/index.md` → 12;
  `grep -n 'Счётчик:' docs/followups/index.md` → «открытых — 12,
  закрытых (promoted/handled/cancelled) — 4»;
  `sed -n '/^## Закрытые/,$p' docs/followups/index.md | grep -c '^- '` → 4
  (3 handled + 1 promoted release-node — счётчик закрытых синхронен
  фактическому числу строк закрытой секции; якорь исправлен по R1 review
  Round 1: прежде предписывалось «— 5» — сдвинутый инкремент 4→5 базы
  вне-конвейерного коммита 8a1d2fa).
  - Факт (2026-11-15 23:43; скорректирован Planner 2026-11-16, fixes
    R1 review Round 1): row backlog — единственная строка
    `id=release-node`: `P2 [x] … status=promoted — plan=261115_2252 …`;
    регресс-паттерн `status=open|plan=none|\[ \]` → 0 (exit 1); summary,
    to, source_ref, why — байтово исходные (правка трёх полей). Index:
    `release-node` — ровно 1 строка (:45, «## Закрытые») с
    `status=promoted — plan=261115_2252`; «### P2 (4)» (:19); строк
    данных открытых таблиц → 12. Счётчик (:8) на прогоне 23:43 —
    «открытых — 12, закрытых (promoted/handled/cancelled) — 5» —
    дословно по тогдашнему литералу D9 (дефект якоря, не исполнения);
    пересчёт (R1, подтверждён Planner против репо 2026-11-16):
    «## Закрытые» — 4 строки (:42–:45), backlog `[x]` — 4, `[ ]` — 12 →
    закрытых = 4 (3 handled + 1 promoted release-node), значение «5»
    унаследовано инкрементом от вне-конвейерного коммита 8a1d2fa;
    якорь исправлен на «— 4», счётчик файла 5→4 — fixes-итерация r1
    Coder'а по исправленному D9/T9 (факт прогона будет вложен ниже).
    Другие строки backlog правкой не затронуты (диф — одна строка).
  - Факт r1 (2026-11-16 01:29, fixes R1 review Round 1): счётчик
    index.md:8 исправлен «— 5» → «— 4», дата состояния → 2026-11-16;
    все команды T9 перепрогнаны на исправленном файле: row backlog —
    единственная строка id=release-node: `P2 [x] … status=promoted —
    plan=261115_2252`; регресс-паттерн `status=open|plan=none|\[ \]`
    → 0 (exit 1); index: release-node — ровно 1 строка (:45,
    «## Закрытые») с `status=promoted — plan=261115_2252`; «### P2 (4)»
    (:19); строк данных открытых таблиц → 12; «Счётчик:» (:8) →
    «открытых — 12, закрытых (promoted/handled/cancelled) — 4
    (состояние на 2026-11-16)»; `sed -n '/^## Закрытые/,$p'
    docs/followups/index.md | grep -c '^- '` → 4. Контрольные суммы:
    backlog `[x]` → 4, `[ ]` → 12. Staged-диф index против HEAD-базы
    13/4 → 12/4: открытых 13→12 (вывод release-node из открытых),
    закрытых — 4 без инкремента; файл рестейджирован.
- T10 (D10): `grep -n 'docs/releases/README.md' README.md` → ровно 1
  строка внутри «## Куда дальше» (номер строки > номера `grep -n '^##
  Куда дальше' README.md`); `git diff -- README.md` → одна вставка
  буллета, иных правок нет.
  - Факт (2026-11-15 23:43): указатель — ровно 1 строка (:110), раздел
    «## Куда дальше» на :102 (110 > 102); диф — один hunk @@ -107,6
    +107,8 @@, вставка двухстрочного буллета (после буллета комплаенс-
    маппинга), иных правок нет.
- T11 (D11): `sh scripts/check_corpus.sh` → `OK C1`…`OK C14`, итог
  `corpus: clean`, exit 0; `sh scripts/check_corpus.sh --selftest` →
  `selftest: 33/33 caught`, exit 0; `git diff --stat --
  .github/workflows/corpus.yml` → пусто; осмотр `## Evidence` плана:
  две миграционные записи §3 п.7 с парами старый→новый digest (AGENTS.md
  dee70da5 → новый; scripts/check_corpus.sh 1997893a → новый) и метками
  времени; broad-drift: `grep -rn 'release-node' README.md
  CONTRIBUTING.md AGENTS.md docs/roles .zcode/commands
  docs/lifecycle.md docs/plans/README.md docs/plans/_template.md
  docs/reviews/_template_review.md docs/requirements/README.md` → 0
  совпадений (grep exit 1; база на момент Planning — 0);
  `grep -c 'release-node' docs/requirements/registry.md` → 0 (база 1);
  `grep -c 'release-node' docs/compliance/gost-r-56939-2024.md` → 0
  (база 3; остаточные 2 в docs/requirements/matrix.md — исторические
  примечания, допустимы по D8(г));
  `grep -rn 'Релизы:' docs/roles .zcode/commands docs/lifecycle.md` → 0
  (§8-релизы не цитируются зависимыми доками).
  - Факт (2026-11-15 23:43): полный прогон на изменённом дереве —
    OK C1 … OK C14 (C4/C5/C11/C13 с excluded-строками pre-cutoff
    планов), итог `corpus: clean`, EXIT=0: C9 подтверждает валидность
    `docs/releases/README.md` из AGENTS.md (:347 буллет, :370 каталог)
    и README.md (:110) — dangling paths нет; C10 (roles-vs-agents)
    полный прогон зелёный; C1 шапки планов не затронуты. Selftest —
    `selftest: 33/33 caught`, EXIT=0 (прогон T4, 23:41). CI
    `.github/workflows/corpus.yml` — диф пуст. Broad-drift: по чистым
    носителям (README.md, CONTRIBUTING.md, AGENTS.md, docs/roles,
    .zcode/commands, docs/lifecycle.md, docs/plans/README.md,
    docs/plans/_template.md, docs/reviews/_template_review.md,
    docs/requirements/README.md) → 0 совпадений (exit 1; база 0);
    registry.md → 0 (база 1); compliance → 0 (база 3); matrix.md → 2
    (исторические: заголовок + примечание, допустимы по D8г);
    `grep -rn 'Релизы:' docs/roles .zcode/commands docs/lifecycle.md`
    → 0 (exit 1). Миграционные записи §3 п.7 — в Evidence (две, с
    парами digest и метками времени).
- T12 (D12): `git diff --cached --stat` → ровно 11 записей: AGENTS.md,
  README.md, scripts/check_corpus.sh,
  docs/compliance/gost-r-56939-2024.md, docs/followups/backlog.md,
  docs/followups/index.md, docs/releases/README.md,
  docs/releases/_template.md, docs/requirements/README.md,
  docs/requirements/matrix.md, docs/requirements/registry.md;
  `git status --porcelain` — посторонние untracked не стейджированы;
  осмотр `## Evidence` (AC-to-test по каждому D1–D11 записан до правок)
  и `## Changes (by area)` заполнен.
  - Факт (2026-11-15 23:47): `git diff --cached --stat` → ровно 11
    записей: AGENTS.md (8+), README.md (2+), compliance (10 /8+2-),
    backlog (2: 1+/1-), index (6: 3+/3-), docs/releases/README.md (83+,
    new), docs/releases/_template.md (49+, new), requirements/README.md
    (5+), matrix (10: 8+/2-), registry (11: 9+/2-), check_corpus.sh
    (2: 1+/1-); итог «11 files changed, 175 insertions(+), 13
    deletions(-)». `git status --porcelain`: staged — только эти 11
    (M/A); untracked — только два плана (261115_2252_release_node.md,
    261115_2254_ci_v2_static.md), не стейджированы. AC-to-test записан
    в Evidence (23:35:10) до правок и до Changes; ## Changes (by area)
    заполнен; факты прогонов T1–T11 вложены выше.

## Changes (by area)
<!-- owner: coder; фактические изменения по областям; заполняется в ходе работы -->

- Релизный узел (новые носители, D1/D2): создан `docs/releases/README.md`
  — конвенция семью разделами (определение релиза: аннотированный тег
  `vX.Y.Z` + нота `docs/releases/vX.Y.Z.md` + переводы в реестре; сборка
  как верифицированный снапшот fresh-green; версионирование v0.1.0/
  MAJOR/MINOR/PATCH; полномочия Manager по указанию Owner, вне статусной
  машины, owner-silence; состав ноты из шаблона; переводы verified →
  released с формой журнальной записи; границы 5.12/5.13) и
  `docs/releases/_template.md` — шаблон ноты с пятью `## `-блоками и
  плейсхолдерами шапки выпуска.
- Конституция (D3): AGENTS.md — буллет «Релизы:» в §8 (сущность/условие/
  инвариант/указатель на конвенцию; без литерального пути нот — C9) и
  строка `docs/releases/` в §9; диф — ровно два блока вставок.
- Линт (D4): `scripts/check_corpus.sh` — единственная строка C12(б):
  enum `статус=(open|planned|verified|released)`; selftest не менялся.
- Реестр (D5): `docs/requirements/registry.md` — rows G56939-5.4/5.20 →
  `статус=planned — plan=261115_2252` (поверх засева Architect'а);
  журнал += 2 записи `open → planned — 261115_2252` (23:38:41); шапка
  формата — enum `+released` в код-спане и пояснении (ссылка на
  конвенцию), формулировка «нет до релизной конвенции (backlog
  release-node)» удалена; row 5.5.3.3 не тронута.
- Регламент требований (D6): `docs/requirements/README.md` — ветка
  статуса `released` в «Отслеживании» (Manager по указанию Owner;
  по умолчанию все verified rows / явный список; форма записи
  `<ID>: verified → released — <тег>`); диф ограничен разделом.
- Комплаенс (D7): `docs/compliance/gost-r-56939-2024.md` — строки
  5.4/5.5.3.3/5.20: «частично» → «реализовано (в границах конвейера)»,
  механизмы расширены релизным узлом, носители += `docs/releases/`,
  упоминания backlog `release-node` удалены; «Версия документа» +=
  строка об обновлении (без токена «частично» — инвариант T7);
  строка 5.5.2.2–5.5.3.4 не менялась.
- Матрица (D8): `docs/requirements/matrix.md` — пересборка: строки
  5.4/5.20 (planned, метки Dn/Tn, предстоит/до merge), 5.5.3.3 (два
  плана `261112_2236, 261115_2252`, `D7, D7`/`T8, T7`), заголовок
  состояния, примечания (фаза planned выполнена); «Правила пересборки»
  и grep-рецепт не задеты.
- Followups (D9): `docs/followups/backlog.md` — row release-node →
  `[x] status=promoted plan=261115_2252` (остальные поля байтово);
  `docs/followups/index.md` — P2(4), строка в «## Закрытые», счётчик
  12/4 (fixes r1 по R1 review Round 1: «— 5» → «— 4» — пересчёт
  закрытой стороны по исправленному D9/T9; дата состояния
  2026-11-16); других строк backlog правка не касается.
- Доки (D10): `README.md` — один буллет в «Куда дальше» с указателем
  на `docs/releases/README.md`.

## Evidence (chronological, append-only)
<!-- owner: все роли + CENSOR; событийные записи с датой и локальным временем `- YYYY-MM-DD HH:MM:SS — <кто>: <текст>`; CENSOR-receipt по формату конституции -->

- 2026-11-15 22:52:04 — Manager: план создан из шаблона по указанию Owner — промоушен backlog-строки id=release-node (P2: релизный узел конвейера — конвенция тегов/сборок/release-notes и статус released в реестре; source_ref=docs/plans/261112_2236_gost56939_traceability.md#out-of-scope; why: вне скоупа плана 261112_2236 Solution п.9, статус released в docs/requirements/registry.md не вводится до конвенции). Owner-бриф дословно: «release-node · ci-v2-static» (аргумент вызова `/planfaktor-run`; выбор двух строк из доклада Manager об открытом техдолге в ответ на вопрос Owner «какие у нас планы есть дальше?»); интерпретация Manager: два отдельных плана, данный — старейший, ведётся первым, id=ci-v2-static материализован отдельным планом очереди. Аргумент не путь/PlanID — отклонение от буквы 1a п.1 run-рутины зафиксировано здесь (fail-loud запись, §1(d)); сопроводительных спец-указаний нет
- 2026-11-15 23:03:25 — Architect: intake свёрстан (Q&A log); план и контракты прочитаны с диска, статус сверен с конвертом (Draft = PRE_STATUS_LINE). Засев реестра по регламенту предъявления (docs/requirements/README.md, раздел «Предъявление» — зона Architect на intake): docs/requirements/registry.md += rows G56939-5.4 (P2) и G56939-5.20 (P1), статус=open, plan=none, предъявлено=2026-11-12 Owner, принято=Architect 2026-11-15; docs/requirements/matrix.md += 2 производные строки («предстоит»/«до merge») + состояние заголовка; записей журнала нет (первоначальный статус — часть row). Синхронность enum не тронута: `+released` в шапке реестра/линте — реализация плана (Scope), не засев. Основание трассы: backlog id=release-node (source_ref 261112_2236#out-of-scope, Solution п.9); комплаенс-границы 5.4/5.5.3.3/5.20 («частично» именно из-за отсутствия релизного узла); registry.md:27 «статуса released нет до релизной конвенции». Свои секции заполнены: понимание, Problem 1–4, Solution 1–8 (два A/B-решения закрыты с rejected alternatives: per-release ноты против CHANGELOG.md; старт v0.1.0 против v1.0.0), Scope с fan-out инвентарём по обоим shared-контрактам (AGENTS.md, scripts/check_corpus.sh), Out of scope 6 пунктов. Открытых вопросов к Owner нет: чек-лист 11 классов закрыт брифом/корпусом/решениями. Фаза work завершена: handoff Ready for Planner.
- 2026-11-15 23:05:44 — Manager: СТОП по §10 One-writer — обнаружена параллельная активная Manager-сессия: создан не моей сессией план docs/plans/261115_2302_ci_v2_static.md (Evidence-строка создания 23:02:46 «Manager: план создан… промоушен backlog id=ci-v2-static», формат записи не мой), файл растёт в реальном времени (mtime 23:05, объём 15.8K — идёт Architect-фаза чужой сессии) — дублирует мой план 261115_2254_ci_v2_static.md (создан 22:54:11 по тому же Owner-брифу «release-node · ci-v2-static»). Risk-зона конкурентных правок: docs/requirements/registry.md и matrix.md (правит мой Architect 2252, потенциально и чужая сессия), backlog/index. Действия: Architect CENSOR по 2252 отложен (хендл сохранён), конвейер этой сессии заморожан до решения Owner — какой план ci-v2-static каноничен (2254 мой или 2302 чужой) и продолжать ли ведущую роль этой сессии по 2252; owner-silence, ничего не трогаю (§6)
- 2026-11-15 23:13:25 — Manager: резолюция Owner (чат, дословно): «261115_2302_ci_v2_static - убираем. 261115_2252_release_node - ведем первым как ты рекомендовал потом берем 261115_2254_ci_v2_static». Исполнено: 2302 удалён (untracked, не в git-истории; молчал с 23:05:24 — чужая сессия остановлена; конфликт дубля исчерпан); правки registry/matrix в дереве — от Architect'а этого плана (Evidence 23:03:25), чужих правок нет; конвейер разморожен — данный план ведущий, 2254 следующий в очереди (Draft). Продолжение: Architect CENSOR
- 2026-11-15 23:15:23 — (Role CENSOR) OK: Ready for Planner validated; current=true
Censor dispatch id: censor:architect:261115_231400
Observations:
- Second opinion: шапка сверена с конвертом — `**Status:** Ready for Planner` (строка 4) = PRE_STATUS_LINE, `**Plan ID:** 261115_2252` = префиксу имени файла; план и правки registry/matrix перечитаны с диска (git diff), не из памяти. Свои секции целостны: понимание (7 строк), Problem 1–4, Solution 1–8 (A/B-решения закрыты без дизъюнкций, оба rejected alternatives при них), Scope с R-метками (G56939-5.4, G56939-5.20, G56939-5.5.3.3 — все три ID существуют в реестре, C12(а) зелёный) и fan-out инвентарём по обоим shared-контрактам, Out of scope 6 пунктов. Q&A log — 2 intake, открытых Q нет, A-строк нет — терять нечего. Чужие зоны не тронуты: DoD/Tests/Changes пусты (Planner/Coder), Evidence между work и censor дописан только Manager'ом (23:05:44 заморозка §10, 23:13:25 резолюция Owner — его зона), Token usage — его строка. Регламентная база засева перепроверена: docs/requirements/README.md «Предъявление» назначает засев Architect-интейку; rows валидны (8 полей, enum, даты) — C12(б) зелёный.
- Counterfactuals considered: (1) чужая параллельная сессия (2302) могла править risk-зону registry/matrix — заявление Manager'а 23:13:25 «чужих правок нет» проверено против дерева, а не принято на веру: `git diff` registry/matrix несёт ровно мои правки (2 rows, 2 матричные строки, заголовок, примечание), следов 2302 нет, glob docs/plans/261115_23* пуст; (2) контракты могли уйти между work и censor — shasum пересчитаны: AGENTS.md@dee70da5, architect.md@f6cd38e4 неизменны, §3 п.7 чист; (3) мои intake/receipt-записи могли сломать C5/C6/C1 — полный прогон `./scripts/check_corpus.sh` → все чеки OK (14/14 построчно), `corpus: clean`, exit 0; (4) R-метки плана без rows валили бы C12(а) с момента handoff — засев на intake снял секвенирование, прогон подтверждает; (5) статусная строка могла задвоиться после заморозки — C1 валиден, ровно одна.
- Addendum (new angle): (1) неточность в собственных матричных строках найдена и исправлена: «R-метки в Scope/DoD» → «R-метки в Scope; DoD — Planner» (DoD — будущая зона Planner'а, на intake R-метки только в Scope; derived-строки — моя зона этой правкой); (2) очередь сверена с резолюцией Owner: 2252 Ready for Planner (ведущий), 2254 Draft (следующий) — §10-инцидент не оставил статусных следов; (3) единственность receipt — первая запись `(Role CENSOR)` в Evidence плана, дублей нет; (4) записи журнала реестра не тронуты: засев без записей — «первоначальный статус — часть row» (регламент), перевод open→planned останется кодинг-чейнджсету.
- Fixes: матричные строки docs/requirements/matrix.md уточнены (см. Addendum п.1) — точность derived-формулировки в своей зоне. Дефектов handoff'а сверх этого не найдено.
- Final censor verdict: OK
- 2026-11-15 23:28:31 — Planner: finalize completion-pass (роль-док planner.md п.3, до простановки статуса). Два дословных вопроса-самопроверки: (1) «что Coder/Reviewer будут угадывать?» — ничего содержательного: все развилки закрыты решениями Architect (A/B в Solution п.2/п.3 с rejected alternatives), точные якорные литералы заданы (D3 буллет `- Релизы:` + строка `docs/releases/`; D5 форма журнальной записи и код-спан enum; D7 точные построчные статусы «реализовано (в границах конвейера)»; D8 точные списки Dn/Tn по каждой row; D9 счётчики и заголовки index; D11 базы broad-drift и старые digest'ы dee70da5/1997893a); свобода Coder'а — только стилистика текста конвенции/шаблона в рамках заданных поэлементно составов (7 элементов D1, 5 блоков D2), что и есть реализация; (2) «implicit-доказательства?» — нет: каждый Dn покрыт ровно одним Tn с командой и ожидаемым результатом либо осмотром указанного носителя; материальные носители названы (## Evidence для AC-to-test и миграций §3 п.7, ## Changes для факта, git diff/grep для каждого файла). Дефект, найденный и починенный в проходе: слабый prose-якорь T5/D11(д) «нет до релизной конвенции» (в registry.md разорван переносом строки — grep давал 0 уже до правки) заменён на идентификаторный якорь `release-node` с зафиксированными базами (registry 1, compliance 3, matrix 2 — исторические, чистые носители 0; проверено 23:24); попутно при правке зафиксирован и откатнут собственный misplaced-edit (фрагмент D8(г) был ошибочно замещён текстом D11(д) — восстановлен, целостность подтверждена перечитыванием секции). Контрольный прогон `sh scripts/check_corpus.sh` на дереве с заполненными DoD/Tests → OK C1…C14, `corpus: clean`, exit 0 (R-метки DoD валидны по C12(а)). Вердикт: дефектов, переживающих handoff, нет.


- 2026-11-15 23:29:25 — Planner: фаза work завершена — handoff Ready for Coder. Intake свёрстан (23:22:39, Q&A log: NO QUESTIONS / NO SUGGESTIONS / NO OBJECTIONS), статус Planning поставлен, план и контракты прочитаны с диска, статус сверен с конвертом (Ready for Planner = PRE_STATUS_LINE). Заполнены свои секции: DoD D1–D12 (12 пунктов; R-метки: D1/D2 [R: G56939-5.20][R: G56939-5.4], D5 [R: G56939-5.4], D6 [R: G56939-5.20], D7 [R: G56939-5.20][R: G56939-5.4][R: G56939-5.5.3.3]; fan-out инвентарь §5 перенесён из Scope в D11 с базами digest'ов AGENTS.md@dee70da5 и check_corpus.sh@1997893a и broad-drift якорями), Tests T1–T12 (взаимно-однозначное покрытие Dn, команды с ожидаемыми результатами и зафиксированными базами), Follow-ups (deferred) — 4 хвоста с why. Решения Architect не менялись; Q&A без открытых вопросов — переносить нечего. Finalize completion-pass записан 23:28:31 до простановки статуса. Контрольный прогон линта на дереве с заполненными секциями → corpus: clean, exit 0.
- 2026-11-15 23:32:06 — (Role CENSOR) OK: Ready for Coder validated; current=true
Censor dispatch id: censor:planner:261115_233011
Observations:
- Second opinion: шапка сверена с конвертом — `**Status:** Ready for Coder` (строка 4) = PRE_STATUS_LINE, Plan ID = префиксу имени файла; план перечитан с диска целиком (обе страницы), не из памяти. DoD перечитан (D1–D12): каждый пункт — утверждение о состоянии конкретного файла с якорями (литералы `- Релизы:`/`docs/releases/` в D3, код-спан enum и форма журнальной записи в D5, построчные статусы комплаенса в D7, точные Dn/Tn-списки матрицы в D8, счётчики index в D9); R-метки D1/D2/D5/D6/D7 — все три ID существуют в реестре (C12(а) зелёный по прогону). Tests перечитаны (T1–T12): покрытие взаимно-однозначное — grep-счётчики с диска `^- [ ] D` → 12, `^- T[0-9]* (D` → 12; у каждой команды ожидаемый результат. Q&A log: 4 intake (последний — censor 23:31:52), Q-строк нет — переносить нечего, открытых вопросов нет. Finalize completion-pass в Evidence на месте (23:28:31, вердикт «дефектов, переживающих handoff, нет») и датирован до простановки статуса (23:29:25). `## Follow-ups (deferred)` заполнен: 4 хвоста с why. Чужие секции не тронуты: Problem/Solution/Scope/Out of scope перечитаны с диска — байтово идентичны прочтённому на work-intake (моих правок нет), шапка изменена только статусной строкой (§2 — переход ставит Planner), Manager-зоны (Evidence 22:52–23:13, Token usage) не трогались.
- Counterfactuals considered: (1) серийные Edit'ы work-фазы (два сбоя соответствия + misplaced-edit с замещением D8(г)) могли оставить битую структуру — перечитал DoD/Tests целиком: D8(г) восстановлен, D11 несёт (а)–(д) без потерь, счётчики 12/12, линт clean; (2) базы T-команд могли протухнуть между work и censor (параллельная сессия §10-инцидента) — git status по дереву: изменены только registry/matrix (зона Architect'а этого плана, подтверждена его CENSOR OK 23:15:23), план untracked, AGENTS.md/скрипт/README/compliance/backlog/index в дереве не менялись (mtime: AGENTS.md 21:18, check_corpus.sh 2026-11-14, registry 23:03, matrix 23:14); ключевые базы перепроверены прогонами: enum C12 строка 760 — старый трёхзначный, rows 5.4/5.20 — статус=open/plan=none (2), backlog release-node — open (1), docs/releases/ отсутствует; (3) контракты могли уйти между итерациями — shasum: AGENTS.md@dee70da5, planner.md@f013858b неизменны, §3 п.7 чист, миграционная база D11(в) (1997893a) соответствует неменявшемуся скрипту; (4) мой receipt мог нарушить C4 (дубль маркера) — валидный маркер `(Role CENSOR)` в Evidence один (architect, 23:15:23), второе вхождение — цитата внутри Addendum-строки 489, не в начале строки, C4 не матчит; настоящий receipt — единственная вторая запись по формату §4; (5) статусная строка могла задвоиться — C1 валиден, ровно одна.
- Addendum (new angle): (1) D8 сверен с грамматикой matrix.md: столбцы ID→Планы→DoD→Tests→Review→Коммиты→Статус и позиционные пары «261112_2236, 261115_2252 | D7, D7 | T8, T7» согласованы с «Правилами пересборки» файла; (2) проспективная проверка C12(в) на момент Done этого плана: каждая R-DoD-строка несёт метку Dn в начале (D1/D2/D5/D6/D7), парные `(Dn)` присутствуют в Tests (T1/T2/T5/T6/T7) — линт не упадёт при переходе плана в Done; (3) пустая строка между Evidence-записями 23:28:31 и 23:29:25 (артефакт вставки work-фазы) — не дефект формата (C4/C5 не чувствительны, линт зелёный), append-only историю не правлю; (4) явная форма отсутствия в моих секциях: TBD/пустых обязательных полей нет, Follow-ups несут why по грамматике.
- Fixes: none (NO FINDINGS; сверено с диска: статусная строка против конверта, 12 DoD-пунктов и 12 T-строк с 1:1 покрытием, R-метки DoD против реестра, базы шести ключевых T-команд повторными прогонами, digest'ы обоих контрактов, mtime девяти поверхностей, git-статус дерева, целостность D8/D11 после серийных правок, проспективный C12(в), полнота Follow-ups)
- Final censor verdict: OK
- 2026-11-15 23:33:37 — Manager: Q&A чист, открытых вопросов к Owner нет, статус In progress
- 2026-11-15 23:35:10 — Coder: AC-to-test зафиксирован до правок (§5), по каждому пункту DoD ровно один исход: D1 → explicit assertion (T1: test -f + 11 якорных grep-литералов конвенции + осмотр семи элементов); D2 → explicit assertion (T2: test -f + `grep -c '^## '` ≥ 5 + осмотр плейсхолдеров/блоков); D3 → explicit assertion (T3: awk/grep-литералы `- Релизы:` и `^docs/releases/` + git diff -U2 ровно два блока); D4 → explicit assertion (T4: git diff один hunk + grep нового enum → 1 + selftest 33/33); D5 → explicit assertion (T5: построчные grep rows/журнала/enum-шапки + git diff не трогает 5.5.3.3); D6 → explicit assertion (T6: sed-диапазон «Отслеживание» + grep -F формы записи + git diff ограничен разделом); D7 → explicit assertion (T7: построчные grep «реализовано»/«частично»/release-node/261115_2252/docs/releases/ по трём строкам); D8 → explicit assertion (T8: построчные grep matrix + осмотр заголовка/примечаний + git diff не трогает правила); D9 → explicit assertion (T9: grep row backlog + счётчики index P2(4)/12/закрытых 5); D10 → explicit assertion (T10: grep -n в «Куда дальше» + git diff одна вставка); D11 → explicit assertion (T11: полный линт corpus:clean + selftest + пустой diff CI + осмотр миграционных записей + broad-drift grep release-node по чистым носителям с базами 0/1/3); D12 → explicit assertion (T12: git diff --cached --stat ровно 11 файлов + git status + осмотр Evidence/Changes). Рeroute/N/A нет: каждый Dn имеет парную Tn-проверку с командой и ожидаемым результатом.
- 2026-11-15 23:43:35 — Coder: миграционная запись §3 п.7 — AGENTS.md@dee70da5 → AGENTS.md@822b4300 (правки D3: буллет «Релизы:» в §8 + строка docs/releases/ в §9; фактические digest'ы shasum -a 256 до/после правок; база на момент Planning — dee70da5, совпадение подтверждено на intake 23:34:31).
- 2026-11-15 23:43:35 — Coder: миграционная запись §3 п.7 — scripts/check_corpus.sh@1997893a → scripts/check_corpus.sh@fc95b37b (правка D4: единственная строка C12(б) enum `+released`; база на момент Planning — 1997893a, совпадение подтверждено на intake 23:34:31).
- 2026-11-15 23:44:10 — Coder: правки D1–D10 внесены (два новых файла docs/releases/{README.md,_template.md}; AGENTS.md, check_corpus.sh, registry.md, requirements/README.md, compliance, matrix.md, backlog.md, index.md, README.md); прогоны T1–T11 — все зелёные, факты с командами и результатами вложены в ## Tests / Commands (T1 23:41 … T11 23:43). Полный линт на изменённом дереве: OK C1…C14, `corpus: clean`, exit 0; selftest: 33/33 caught, exit 0. Один дефект найден и исправлен в ходе прогона T7 (строка «Версия документа» комплаенса несла токен «частично» — третье вхождение вне шапки против T7-инварианта «ровно 1»; переформулирована, повторный счёт — 1); до правок проверено C9-ограничение: литеральный путь `docs/releases/vX.Y.Z.md` в AGENTS.md дал бы dangling path — буллет §8 несёт тег `vX.Y.Z` без литерального пути нот (носители нот — каталог docs/releases/ в §9 и конвенция).
- 2026-11-15 23:47:00 — Coder: стейджинг по D12 — `git add` 11 файлов Scope (AGENTS.md, README.md, scripts/check_corpus.sh, docs/compliance/gost-r-56939-2024.md, docs/followups/backlog.md, docs/followups/index.md, docs/releases/README.md, docs/releases/_template.md, docs/requirements/README.md, docs/requirements/matrix.md, docs/requirements/registry.md); план и посторонние untracked (261115_2254) не стейджированы; `git diff --cached --stat` → ровно 11 записей.
- 2026-11-15 23:48:09 — Coder: фаза work завершена. Контрольный прогон линта после заполнения Tests-фактов/Changes/Evidence: OK C1…C14, `corpus: clean`, exit 0; selftest 33/33 caught, exit 0. Реализация D1–D12 в рамках Scope (11 файлов), T1–T12 прогнаны — факты и результаты в ## Tests / Commands; AC-to-test (explicit assertion × 12) зафиксирован до правок (23:35:10); миграционные записи §3 п.7 по обоим shared-контрактам внесены (23:43:35); ## Changes (by area) заполнен; ## Follow-ups (deferred) Planner'а актуальны (хвосты не менялись — терминальное закрытие release-node требует merge-коммита, вне staged-набора). Открытых вопросов/допущений нет. Handoff: **Status:** In review.
- 2026-11-15 23:53:05 — (Role CENSOR) OK: In review validated; current=true
Censor dispatch id: censor:coder:261115_234920
Observations:
- Second opinion: шапка сверена с конвертом — `**Status:** In review` (:4) = PRE_STATUS_LINE, Plan ID = префиксу имени файла; план перечитан с диска целиком (внешняя дельта с work-фазой — только usage-строка Manager'а 23:49:20, его зона). Каждый DoD-пункт сверен повторными прогонами против файлов, не памяти: D1/D2 — test -f оба exit 0, `grep -c '^## '` шаблона → 5, якорные литералы конвенции (vX.Y.Z=3, v0.1.0=2, MAJOR/MINOR/PATCH=1/1/1, owner-silence=1, docs/releases/_template.md=2, closeout=2, «verified → released»=4, C14=3, 5.12=1, 5.13=1, github releases -i=1), оба носителя docs/releases/ перечитаны с диска — семь элементов D1(а)–(ж) и пять блоков D2 представлены; D3 — `^- Релизы:`=1, `^docs/releases/`=1, git diff -U2 → ровно 2 hunk'а вставок; D4 — один hunk одной строки, grep нового enum = 1; D5 — журнал `: open → planned — 261115_2252` = 2, rows planned, `release-node` = 0, 5.5.3.3 в staged-дифе не задета (0 +/- строк с ней); D6 — один hunk внутри «Отслеживания»; D7 — три строки «реализовано»/без «частично», `261115_2252` = 1 (:92); D8 — метки `D1, D2, D5, D7`/`T1, T2, T5, T7` и `D1, D2, D6, D7`/`T1, T2, T6, T7` в строках матрицы, 5.5.3.3 — два плана попарно, «Правила пересборки» не задеты; D9 — row promoted, «### P2 (4)», строк данных открытых таблиц = 12, счётчик 12/5; D10 — указатель :110 внутри «Куда дальше» (:102); D11 — свежие прогоны: `sh scripts/check_corpus.sh` → OK C1…C14, `corpus: clean`, exit 0; `--selftest` → `selftest: 33/33 caught`, exit 0; broad-drift `release-node` по чистым носителям и registry/compliance → 0; миграционные записи несут фактические пары dee70da5→822b4300 / 1997893a→fc95b37b (digest'ы пересчитаны на censor-intake 23:50:03); D12 — `git diff --cached --stat` → ровно 11 файлов (175+/13-), untracked только два плана, staged == worktree (`git diff --stat` пуст). AC-to-test (23:35:10) датирован до правок и до Changes; Assumption-строк в Q&A нет; чужие секции (Problem/Solution/Scope/Out of scope/DoD, включая `[ ]`-маркеры DoD — зона Planner) не тронуты; TODO/FIXME/DEBUG по staged-дифу → 0; `## Follow-ups (deferred)` — 4 хвоста с why.
- Counterfactuals considered: (1) «verified → released» могло разрываться переносами и рвать grep-якоря — проверено построчно: 4 вхождения целиком в одной строке в конвенции; журнальная форма `<ID>: verified → released — <тег>` одной строкой в регламенте (D6) и шаблоне (D2); (2) литеральный путь нот мог проскочить в AGENTS.md и уронить C9 — блок буллета §8 grep'ом: только `docs/releases/README.md` (существует) и `vX.Y.Z` без пути; полный линт C9 link-integrity зелёный; (3) staged мог разойтись с рабочим деревом после T7-фикса (правка комплаенса после части стейджинга) — `git diff --stat` пуст: всё в staged; (4) мой receipt мог дать дубль C4-маркера — валидных строк `(Role CENSOR)` до меня две (architect 23:15:23, planner 23:32:06), обе с префиксом `- <TS> — `; внутристрочные цитаты маркера в Addendum/Counterfactuals прошлых receipt'ов не в начале строки, C4 не матчит; настоящий receipt — третья запись формата §4; (5) правка шаблона из Fixes могла сломать T2-инварианты и стейджинг — перепроверено: 5 блоков `^## `, «33/33» из шаблона ушло (0), файл рестейджирован, `git diff --stat` пуст, линт clean; (6) статусная строка могла задвоиться — C1 зелёный, ровно одна `**Status:** In review` (:4).
- Addendum (new angle): (1) de-hardcode-угол fan-out D11(б): в шаблоне нот литеральный итог `selftest: 33/33 caught` был скрытым захардкоженным счётчиком (протух бы при первой новой selftest-посадке) — обобщён плейсхолдером `selftest: <N/N> caught` (Fixes); (2) проспективный прогон C12 на future-rows `released`: regex скрипта `'^статус=(open|planned|verified|released)$'` принимает `статус=released` — первый перевод verified→released линт-правок не потребует; (3) консистентность «Версия документа» комплаенса (:92) с журналом реестра: обе записи ссылаются на план 261115_2252, конфликтов дат нет; (4) арифметика index: 1(P1)+4(P2)+7(P3)=12 строк данных = счётчику «открытых — 12», закрытых 5 (4 handled + 1 promoted) = сумме «## Закрытые».
- Fixes: docs/releases/_template.md — литерал `selftest: 33/33 caught` заменён плейсхолдером `selftest: <N/N> caught` (de-hardcode гигиена, зона Coder/D2); файл рестейджирован, инварианты перепроверены (5 блоков `^## `, staged == worktree, линт `corpus: clean` exit 0). Дефектов handoff'а сверх этого не найдено.
- Final censor verdict: OK
- 2026-11-16 00:20:00 — Manager: Owner-гейт merge — ответ Owner «сначала фикс R1» (чат; полная проверка Owner: вердикты pass/pass current_green подтверждены, staged 11 = Scope, линт/selftest зелёные, утечек 0; решение — fixes-раунд по R1 до merge, цитата: «Рекомендация: "сначала фикс R1"… он вернёт Coder'у needs-fix: правка D9/T9 + пересчёт счётчика, fixes-итерация + реран ревью (Round 2 с Rerun mode: incremental) → потом чистый гейт»). Loop signal в Итоге нет (R1 — первое появление, accepted_non_blocking_followup у ревьюеров; Owner на гейте повысил до fixes-обязательства) → штатный needs-fix-возврат без reopened-классификации. Маршрут по зонам: D9/T9 — зона Planner (AC-to-test reroute §5: DoD/Tests → владельцу), диспатч Planner на точечную правку первым; затем Coder (fixes-итерация r1: пересчёт счётчика index по исправленному D9/T9, ставит `In progress` на intake); затем реран ревью Round 2 incremental; Owner-гейт заново
- 2026-11-16 00:20:00 — Manager: Stale/Rerun note — вердикты Round 1 (pass/pass) относятся к пред-фиксному diff ( staged 11 файлов на 00:15 ); после fixes-итерации реран ревью обязателен, Round 1 не индульгенция
- 2026-11-16 01:23:04 — Planner: fixes-итерация по R1 review Round 1 (docs/reviews/261115_2252_review.md; диспатч Manager 00:20:00 — маршрут «D9/T9 → владельцу», статус плана не менялся: In review). Заявления ревью верифицированы против репо (untrusted input, §5): коммит 8a1d2fa (2026-11-15 22:47, 1 строка index.md) — база HEAD «открытых — 13, закрытых … — 4» при фактических 3 закрытых; staged-диф инкрементировал закрытых 4→5 по тогдашнему литералу D9. Фактический пересчёт (grep по дереву): «## Закрытые» index — 4 строки (:42–:45), backlog `[x]` — 4 / `[ ]` — 12, строк данных открытых таблиц — 12 → закрытых = 4 = 3 handled (closeout-tail-convention, merge-untracked-guard, ci-hygiene) + 1 promoted (release-node), открытых = 12 (открытая сторона счётчика верна). Исправлена своя секция: D9 — предписанный литерал счётчика «— 5» → «— 4» + инвариант равенства фактическим строкам «## Закрытые»; T9 — ожидание «— 4» + новая команда `sed -n '/^## Закрытые/,$p' docs/followups/index.md | grep -c '^- '` → 4 (прямая проверка закрытой стороны); T9-факт 23:43 скорректирован синхронно по явному диспатчу Manager'а — исходное наблюдение «5» сохранено внутри факта с аннотацией «дефект якоря, не исполнения». Контрольный прогон `sh scripts/check_corpus.sh` на дереве с исправленными секциями → OK C1…C14, `corpus: clean`, exit 0; строку «Счётчик:» линт не валидирует (grep по скрипту — 0) — конфликтов якоря нет. Файлы index.md/backlog.md не правил (зона Coder: пересчёт счётчика 5→4 — fixes-итерация r1 по исправленному D9/T9); решения Architect, чужие секции и append-only логи не тронуты; note: арифметика «закрытых 5 = 4 handled + 1 promoted» в Addendum п.4 CENSOR-receipt Coder'а 23:53:05 ошибочна (факт — 3 handled), receipt append-only не правится, авторитет — R1 и этот пересчёт
- 2026-11-16 01:26:43 — Coder: fixes-итерация r1 старт по диспатчу Manager'а (маршрут Evidence 00:20:00: «затем Coder — fixes-итерация r1: пересчёт счётчика index по исправленному D9/T9, ставит In progress на intake»). Intake свёрстан (Q&A log), статус сверен с конвертом (In review = PRE_STATUS_LINE), по §2 на intake fixes-итерации поставлен **Status:** In progress. AC-to-test r1 (до правок): D9 → explicit assertion (исправленный Planner'ом 01:23:04 T9 — построчные grep + новая прямая проверка закрытой стороны `sed -n '/^## Закрытые/,$p' docs/followups/index.md | grep -c '^- '` → 4); reroute/N/A нет. Зона фикса — docs/followups/index.md:8 (счётчик 5→4, дата состояния), якорь D9/T9 уже исправлен владельцем (Planner, Evidence 01:23:04) — сам якорь не трогаю
- 2026-11-16 01:29:10 — Coder: правка r1 внесена и проверена — docs/followups/index.md:8–9: «закрытых (promoted/handled/cancelled) — 5» → «— 4», дата состояния 2026-11-15 → 2026-11-16 (D9: «состояние на <дата правки>»); before-state верифицирован против R1/Planner до правки (счётчик 12/5, «## Закрытые» — 4 строки, backlog `[x]`=4/`[ ]`=12, HEAD-база 13/4). Повторный прогон T9 (все команды якоря) — зелёный: row promoted, регресс-паттерн 0/exit 1, release-node :45 в «## Закрытые», «### P2 (4)» :19, строк данных открытых таблиц 12, «Счётчик:» 12/4, sed-проверка закрытой стороны → 4; факт вложен в ## Tests / Commands (T9, «Факт r1»). Рестейджинг: `git add docs/followups/index.md`; `git diff --cached --stat` → ровно 11 файлов (176+/14−), staged == worktree. Контрольный линт: `sh scripts/check_corpus.sh` → OK C1…C14, `corpus: clean`, exit 0; `--selftest` → `selftest: 33/33 caught`, exit 0
- 2026-11-16 01:29:10 — Coder: fixes-итерация r1 завершена — R1 review Round 1 закрыт в зоне Coder (пересчёт счётчика закрытой стороны; R2 — вне диспатча, принят non-blocking и трассирован существующим хвостом плана Follow-ups п.2). ## Changes (by area) актуализирован (Followups: счётчик 12/4). Открытых вопросов/допущений нет; якорь D9/T9 не трогал (зона Planner, исправлен владельцем 01:23:04); чужие секции не тронуты. Handoff: **Status:** In review (§2; ожидается реран ревью Round 2 — Stale/Rerun note Manager'а 00:20:00)
- 2026-11-16 01:32:35 — (Role CENSOR) OK: In review validated; current=true
Censor dispatch id: censor:coder:261116_012959
Review verdict seen: Round 1, pass/pass → Owner-гейт «сначала фикс R1» (fixes-итерация r1 закрывала finding R1 major/S2 — счётчик «закрытых — 5» против 4 фактических; R2 minor/S3 — non-blocking, вне диспатча)
Observations:
- Second opinion: шапка сверена с конвертом — `**Status:** In review` (:4) = PRE_STATUS_LINE, Plan ID 261115_2252 = префиксу имени файла; контракты не ушли (AGENTS.md@822b4300, coder.md@4620164d — пересчитаны на этом intake, §3 п.7 чист; внешняя дельта с work-фазой r1 — только usage-строка Manager'а 01:29:59, его зона). Фикс r1 сверен с диска, не с памятью: docs/followups/index.md:8 — «открытых — 12, закрытых (promoted/handled/cancelled) — 4», дата состояния 2026-11-16 (D9 «состояние на <дата правки>»); staged-объект идентичен worktree (`git show :docs/followups/index.md` несёт 12/4/2026-11-16, `git diff` пуст); T9 перепрогнан в этом проходе целиком: закрытая сторона `sed -n '/^## Закрытые/,$p' … grep -c '^- '` → 4, строк данных открытых таблиц → 12, «### P2 (4)» (:19), release-node — ровно 1 строка (:45, вхождений вне :45 нет), row backlog `P2 [x] … status=promoted — plan=261115_2252`, регресс-паттерн → 0 (exit 1). T9-факт «Факт r1» вложен в Tests и совпадает с прогонами; Changes (Followups) несёт 12/4. Свежий линт (01:30:41): `sh scripts/check_corpus.sh` → OK C1…C14, `corpus: clean`, exit 0; `--selftest` → `selftest: 33/33 caught`, exit 0. Стейджинг: `git diff --cached --name-only` → ровно 11 файлов Scope (фильтр staged-списка по D12 → пусто), untracked — только два плана и review-артефакт, не стейджированы. AC-to-test r1 (D9 → explicit assertion) датирован 01:26:43 — до правки (01:29:10); Assumption-строк в Q&A нет (единственное вхождение «Assumption:» — грамматика комментария секции); чужие зоны не тронуты: якорь D9/T9 — редакция Planner'а 01:23:04, r1-правки плана — только статусная строка (§2 — моя на intake fixes-итерации), Q&A intake, Evidence, T9-факт, Changes; TODO/FIXME/DEBUG в r1-дифе index → 0
- Counterfactuals considered: (1) частичный фикс — число исправлено, дата состояния осталась 2026-11-15 (D9 требует дату правки): проверено в staged-объекте — 2026-11-16; (2) «исправил worktree, забыл рестейджировать» (notice ≠ mutation truth): staged-vs-worktree диф пуст, счётчик проверен именно в index-объекте стейджа, не только в рабочем файле; (3) правка счётчика могла сломать соседние T9-инварианты (задвоение release-node, срыв формата): весь T9-набор перепрогнан против диска — все зелёные, release-node вне :45 отсутствует (grep -v → exit 1); (4) r1 мог протащить лишнее в staged: фильтр 11-файлового списка D12 по staged → пусто (exit 1); (5) мой receipt мог уронить C4 (формат маркера): строк-записей `(Role CENSOR)` с валидным префиксом `- <TS> — ` до меня три (architect 23:15:23, planner 23:32:06, coder 23:53:05), настоящий — четвёртая запись формата §4; контрольный перепрогон линта после appending receipt выполнен (см. ниже)
- Addendum (new angle): (1) потребительская сторона счётчика: harvest-инвентарь closeout (§2) и читатели backlog читают счётчик и «## Закрытые» — теперь обе стороны сходятся (4 = 3 handled + 1 promoted), после merge дефектная цепочка 8a1d2fa → инкремент D9 канонизацией не закрепится; (2) изоляция r1-дельты: с прошлого цензорного прохода (23:53:05) staged-контент изменился ровно у одного файла — index.md (остальные 10 не правились; план — untracked), т.е. вердикты Round 1 по остальным поверхностям не протухли и пригодны базе доверия incremental-рерана; (3) R2 (minor/S3, `-m ...` в шаблоне) не правился — вне диспатча, трассирован существующим хвостом Follow-ups п.2; (4) арифметика Addendum п.4 моего receipt'а 23:53:05 («закрытых 5 = 4 handled + 1 promoted») опровергнута R1 (факт — 3 handled); тот receipt append-only не правится, настоящий фиксирует верное разложение 4 = 3 handled + 1 promoted
- Fixes: none (NO FINDINGS; сверено с диска: staged-объект счётчика против worktree, полный T9-набор повторным прогоном, свежий линт + selftest (01:30:41), фильтр staged по 11-файловому списку D12, release-node-вхождения по всему index, TODO/FIXME по r1-дифу, digest'ы обоих контрактов, дата AC-to-test против даты правки, подсчёт C4-маркеров, изоляция r1-дельты до одного файла)
- Final censor verdict: OK
- 2026-11-16 01:34:40 — Coder: контрольный перепрогон после appending CENSOR-receipt (Counterfactual п.5 того receipt): `sh scripts/check_corpus.sh` → 14×OK (C1…C14), `corpus: clean`, exit 0; `--selftest` → `selftest: 33/33 caught`, exit 0; строк-записей `(Role CENSOR)` с валидным префиксом — 4, дублей нет — C4 зелёный с настоящим receipt'ом
- 2026-11-16 02:13:35 — Manager: Owner-гейт merge (повторный, после fixes r1) — Owner ответил «мержим» (чат, дословно); контроли (а) пройдены: unstaged-дельта tracked пуста; untracked — файлы мерджимого плана и review-артефакта (санкционированы шагом (в)) и Draft-черновик очереди 261115_2254 (штатное состояние, в коммит не входит); staged ровно 11 файлов = дословный список Итога Round 2; свежий pre-merge verify `sh scripts/check_corpus.sh` → `corpus: clean`, EXIT=0 (C1–C14 OK); ручной leak-контроль запретных токенов по staged-диффу → 0 совпадений; review Round 2: Risk pass / Contracts pass / Итог pass / Artifact state current_green (R1 закрыт fixes r1, R2 non-blocking). Статус Merged

## Token usage (append-only)
<!-- owner: manager; dispatch-форма: `- YYYY-MM-DD HH:MM:SS — usage: <role>.<work|censor|rN> <N|unknown (why=...)> tokens — <dispatch|sendmessage|unknown>`; чекпоинт-форма: `- YYYY-MM-DD HH:MM:SS — usage: manager-context checkpoint ~<N> tokens-left — approximate`; числа — учёт харнесса ZCode (subagent_tokens), приближение, не биллинг провайдера; пишет только Manager из tool-результата вызова -->

- 2026-11-15 23:05:44 — usage: architect.work 1441347 tokens — dispatch
- 2026-11-15 23:16:38 — usage: architect.censor 1132808 tokens — sendmessage
- 2026-11-15 23:30:11 — usage: planner.work 4792037 tokens — dispatch
- 2026-11-15 23:33:37 — usage: planner.censor 1853888 tokens — sendmessage
- 2026-11-15 23:49:20 — usage: coder.work 9655532 tokens — dispatch
- 2026-11-15 23:54:07 — usage: coder.censor 2002793 tokens — sendmessage
- 2026-11-16 00:01:30 — usage: reviewer-risk.work 2020133 tokens — dispatch
- 2026-11-16 00:15:29 — usage: reviewer-contracts.work 2761881 tokens — dispatch
- 2026-11-16 00:15:29 — usage: manager-context checkpoint ~14970000 tokens-left — approximate
- 2026-11-16 01:24:25 — usage: planner.r1 1214125 tokens — dispatch
- 2026-11-16 01:29:59 — usage: coder.r1 1100869 tokens — dispatch
- 2026-11-16 01:35:06 — usage: coder.censor 965775 tokens — sendmessage
- 2026-11-16 01:53:53 — usage: reviewer-risk.r1 1749803 tokens — dispatch
- 2026-11-16 01:59:12 — usage: reviewer-risk.r1 484428 tokens — sendmessage
- 2026-11-16 02:09:14 — usage: reviewer-contracts.r1 1930338 tokens — dispatch
- 2026-11-16 02:09:14 — usage: manager-context checkpoint ~14975000 tokens-left — approximate

## Q&A log (chronological, append-only)
<!-- owner: все роли; intake: `Intake (YYYY-MM-DD HH:MM:SS): AGENTS.md@<8hex> <role>.md@<8hex>` (локальное время) + NO QUESTIONS / NO SUGGESTIONS / NO OBJECTIONS; вопросы `Q(<роль>#<n>): ... to=Owner|to=<роль>, blocker: yes|no, needs_owner: yes|no, status=open`; закрытие парной строкой по номеру `A(<кто>#<n>): ... status=closed, перенесено в <секция>`; открытость = Q#n, ниже которой нет парной A#n; допущения Coder'а — строки `Assumption: ...` (append-only; влияющее на Scope/DoD/контракты — стоп и возврат на Planner, §5) -->

- Intake (2026-11-15 23:03:25): AGENTS.md@dee70da5 architect.md@f6cd38e4
NO QUESTIONS
NO SUGGESTIONS
NO OBJECTIONS

- Intake (2026-11-15 23:15:23): AGENTS.md@dee70da5 architect.md@f6cd38e4
NO QUESTIONS
NO SUGGESTIONS
NO OBJECTIONS

- Intake (2026-11-15 23:22:39): AGENTS.md@dee70da5 planner.md@f013858b
NO QUESTIONS
NO SUGGESTIONS
NO OBJECTIONS

- Intake (2026-11-15 23:31:52): AGENTS.md@dee70da5 planner.md@f013858b
NO QUESTIONS
NO SUGGESTIONS
NO OBJECTIONS

- Intake (2026-11-15 23:34:31): AGENTS.md@dee70da5 coder.md@4620164d
NO QUESTIONS
NO SUGGESTIONS
NO OBJECTIONS

- Intake (2026-11-15 23:50:03): AGENTS.md@822b4300 coder.md@4620164d
NO QUESTIONS
NO SUGGESTIONS
NO OBJECTIONS

- Intake (2026-11-15 23:54:32): AGENTS.md@822b4300 reviewer-risk.md@a51f0eb4
NO QUESTIONS
NO SUGGESTIONS
NO OBJECTIONS

- Intake (2026-11-16 00:03:08): AGENTS.md@822b4300 reviewer-contracts.md@dd9bcb7a
NO QUESTIONS
NO SUGGESTIONS
NO OBJECTIONS

- Intake (2026-11-16 01:22:04): AGENTS.md@822b4300 planner.md@f013858b
NO QUESTIONS
NO SUGGESTIONS
NO OBJECTIONS

- Intake (2026-11-16 01:26:43): AGENTS.md@822b4300 coder.md@4620164d
NO QUESTIONS
NO SUGGESTIONS
NO OBJECTIONS

- Intake (2026-11-16 01:32:35): AGENTS.md@822b4300 coder.md@4620164d
NO QUESTIONS
NO SUGGESTIONS
NO OBJECTIONS

- Intake (2026-11-16 01:35:47): AGENTS.md@822b4300 reviewer-risk.md@a51f0eb4
NO QUESTIONS
NO SUGGESTIONS
NO OBJECTIONS

- Intake (2026-11-16 02:03:28): AGENTS.md@822b4300 reviewer-contracts.md@dd9bcb7a
NO QUESTIONS
NO SUGGESTIONS
NO OBJECTIONS

## Suggestions log (chronological, append-only)
<!-- owner: все роли; несрочные улучшения -->

## Objections log (chronological, append-only)
<!-- owner: все роли; `### <Role> objections`; строка на возражение, blocker: при блокере -->

## Follow-ups (deferred)
<!-- owner: coder/planner при CENSOR; незакрытые хвосты: <описание> — why: <почему сейчас не в скоупе>; обязательна запись `NO FOLLOW-UPS — why: <код>` при отсутствии; <код> — только из enum: handled-in-followup | already-tracked-elsewhere (с literal указателем) | canon-sync-closed | no-remaining-actionable-debt (грамматика — docs/plans/README.md), значение вне enum невалидно -->

- Терминальное закрытие backlog id=release-node (`status=handled`,
  disposition «конвенция внесена, merge <хэш>») — why: harvest-механика
  §2/closeout (как 261115_1610): disposition требует существующего
  merge-коммита; staged-набор плана фиксирует только промоушен (D9).
- Машинная проверка формата релиз-нот и соответствия тег↔файл (кандидат
  C15/v2) — why: Out of scope п.2 плана; потребность не возникла (ни
  одного выпуска ещё нет); до появления строки backlog отслеживается
  пунктом `## Out of scope`.
- Автоматизация выпуска (релиз-скрипт, автогенерация нот) и публикация
  GitHub Releases как инвариант — why: кандидаты v2 (Out of scope
  п.3–4); автогенерация матрицы — уже кандидат v2 плана 261112_2236
  (docs/plans/261112_2236_gost56939_traceability.md#follow-ups).
- Резка первого выпуска `v0.1.0` (тег + релиз-нота + переводы
  `verified → released`) — why: операционное решение Owner после merge
  (Out of scope п.1); путь зафиксирован конвенцией D1, конвейером
  не планируется.
