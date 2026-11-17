# Установка и первый запуск

Planfaktor — не устанавливаемый продукт: нет пакетов, зависимостей и
сервисов. «Установка» — положить контракты конвейера в репозиторий
вашего проекта; после этого конвейер запускается задачей в чате ZCode.
Эта страница — пошаговый путь от пустого репозитория до первого
merge-коммита. Что такое конвейер и как читать планы — в
[быстром старте](../README.md).

## Что понадобится

- **ZCode** — агентская среда с чатом и субагентами (рабочая станция
  macOS / Linux / Windows);
- **git-репозиторий проекта**, в котором будет работать конвейер;
- **клон репозитория Planfaktor** — оттуда копируются контракты
  (обозначим путь переменной `$PF`).

Ничего больше: ни сервера, ни базы данных, ни очередей — процесс
исполняют сами агенты, а репозиторий помнит всё.

## Шаг 1. Положить контракты в репозиторий

Из клона Planfaktor в корень вашего репозитория копируется канон-каркас
конвейера — контракты и справочники канона целиком, но без артефактов
исполнения Planfaktor:

| Что | Откуда в `$PF` | Зачем |
| --- | --- | --- |
| Корневые контракты | `AGENTS.md`, `README.md`, `CONTRIBUTING.md`, `SECURITY.md` | Конституция, быстрый старт, правила контрибьюции, security-политика |
| Справочники | `docs/getting_started.md`, `docs/lifecycle.md`, `docs/model_run.md` | Этот гайд, путь плана по статусам, модель прогонов |
| Канон `docs/` | `plans/` (README + `_template.md` + канон-пример-план `261111_2243_corpus_lint_ci.md`), `reviews/_template_review.md`, `roles/*.md`, `playbooks/*.md`, `releases/*.md`, `reference/*.md`, `compliance/*.md` | Шаблоны артефактов, роль-доки, плейбуки, релизный узел, бюджеты, комплаенс |
| Пустые носители | `requirements/` (README + пустые `registry.md`, `matrix.md`), `followups/` (`_template.md` + пустые `backlog.md`, `index.md`) | Реестр требований и техдолг стартуют пустыми — строки появятся вашими задачами |
| Инфраструктура | `scripts/check_corpus.sh`, `.github/workflows/corpus.yml` | Corpus-линт и CI: свежий `corpus: clean` — инвариант pre-merge verify (§8) |
| Конфигурация ZCode | `.zcode/commands/planfaktor-*.md`, `.zcode/agents/planfaktor-*.md` | `/planfaktor-init`, `/planfaktor-plan`, `/planfaktor-run`, `/planfaktor-status` и субагенты пяти ролей |

Команды для копирования (из корня вашего репозитория):

```bash
mkdir -p docs/plans docs/reviews docs/roles docs/playbooks docs/releases \
         docs/requirements docs/reference docs/compliance docs/followups \
         scripts .github/workflows .zcode/commands .zcode/agents
cp "$PF/AGENTS.md" "$PF/README.md" "$PF/CONTRIBUTING.md" "$PF/SECURITY.md" .
cp "$PF"/docs/getting_started.md "$PF"/docs/lifecycle.md "$PF"/docs/model_run.md docs/
cp "$PF"/docs/plans/README.md "$PF"/docs/plans/_template.md \
   "$PF"/docs/plans/261111_2243_corpus_lint_ci.md docs/plans/
cp "$PF"/docs/reviews/_template_review.md docs/reviews/
cp "$PF"/docs/roles/*.md docs/roles/
cp "$PF"/docs/playbooks/*.md docs/playbooks/
cp "$PF"/docs/releases/*.md docs/releases/
cp "$PF"/docs/requirements/README.md docs/requirements/
cp "$PF"/docs/reference/*.md docs/reference/
cp "$PF"/docs/compliance/*.md docs/compliance/
cp "$PF"/docs/followups/_template.md docs/followups/
cp "$PF/scripts/check_corpus.sh" scripts/
cp "$PF/.github/workflows/corpus.yml" .github/workflows/
cp "$PF"/.zcode/commands/*.md .zcode/commands/
cp "$PF"/.zcode/agents/*.md .zcode/agents/
cat > docs/requirements/registry.md <<'EOF'
# Реестр внешних требований

Единый носитель внешних требований; row-грамматика —
`docs/requirements/README.md`, машинные инварианты — линт C12.

## Требования
EOF
cat > docs/requirements/matrix.md <<'EOF'
# Матрица трассируемости — derived view

Производная поверхность над `docs/requirements/registry.md` и корпусом
планов; руками не ведётся, пересобирается при изменении реестра.
EOF
cat > docs/followups/backlog.md <<'EOF'
# Follow-ups backlog

Единый носитель техдолга между планами; row-грамматика —
`docs/followups/_template.md`.

## Follow-ups (backlog)
EOF
cat > docs/followups/index.md <<'EOF'
# Follow-ups — index

Derived-сводка открытых follow-ups из `docs/followups/backlog.md`;
пересобирается после каждого изменения backlog.md.

Счётчик: открытых — 0, закрытых (promoted/handled/cancelled) — 0
EOF
```

Первый линт — сразу после копирования, из корня вашего репозитория:

```bash
sh scripts/check_corpus.sh
```

Ожидаемый итог — `corpus: clean`: линт машинно проверяет грамматику
скопированных контрактов (шапки планов, статусную машину, логи).
Каркас самодостаточен для линта: `corpus: clean` достигается сразу
после копирования, до создания первых планов. Эта же команда — часть
merge-рутины конвейера: перед каждым merge-коммитом конституция (§8)
требует свежий green-прогон `corpus: clean` в целевом репозитории.

Опционально — справочник [`docs/lifecycle.md`](lifecycle.md)
(путь плана по статусам) и плейбук
[терминального восстановления](playbooks/manual_terminal_recovery.md)
(что делать, если конвейер встал). Артефакты исполнения Planfaktor —
планы вне шаблона и канон-примера, ревью, строки техдолга и требований,
иллюстрации `img/` — в каркас не входят: планы и ревью создаст конвейер
вашего репозитория, носители строк стартуют пустыми.

![Файлы конвейера в репозитории проекта](img/getting_started/01-install-tree.png)

После копирования закоммитьте контракты — с этого момента конвейер
живёт в истории вашего репозитория, как и код.

## Шаг 2. Открыть ZCode в корне проекта

Откройте ZCode так, чтобы корень репозитория был рабочим каталогом
сессии. Дальше всё подхватывается само:

- `AGENTS.md` в корне — инструкция проекта: сессия-Manager читает её
  как конституцию;
- `.zcode/agents/` — в сессии появляются субагенты пяти ролей;
- `.zcode/commands/` — в чате работают четыре команды Manager'а:
  `/planfaktor-init`, `/planfaktor-plan`, `/planfaktor-run`,
  `/planfaktor-status`.

Первое действие — `/planfaktor-init`: разовая инициализация
Manager-сессии (Manager перечитает контракты с диска и настроит
режим сессии).

Проверка без ожидания: выполните `/planfaktor-status` — Manager
перечитает `docs/plans/`, найдёт планов нет и отчитается пустой
очередью. Это и есть первый контакт с конвейером.

## Шаг 3. Первая задача — до merge-коммита

1. **Опишите задачу в чате обычными словами** — как коллеге: что нужно
   и зачем. Никаких форм и шаблонов от вас не требуется.
2. **`/planfaktor-plan`** — Manager создаст план из шаблона: имя вида
   `docs/plans/YYMMDD_HHMM_topic.md`, ваш бриф — дословно в Evidence,
   статус `Draft`. Дальше план читает Architect.
3. **Ответьте на вопросы.** Если в задаче есть неоднозначность,
   Architect спросит строкой `to=Owner` в Q&A log плана. Пока вопрос
   открыт — конвейер стоит; ваш ответ Manager перенесёт в план
   дословно.
4. **`/planfaktor-run`** — один шаг конвейера по старейшему активному
   плану. Команду можно давать сколько угодно раз: каждый вызов —
   диспатч очередной роли, CENSOR-проход или перевод статуса.
5. **Гейт merge.** После двух pass-вердиктов ревью Manager покажет
   выжимку и спросит «мержим?». Ваше явное «да» — и только оно —
   открывает merge-коммит.

![Шапка плана и вопросы к Owner](img/getting_started/02-plan-head.png)

## Что появляется в репозитории

Каждая задача оставляет след — его видно в файлах, без чата:

- `docs/plans/<PlanID>_topic.md` — план: статус в шапке, решения,
  критерии приёмки, Q&A log, Evidence, учёт токенов;
- `docs/reviews/<PlanID>_review.md` — вердикты двух лейнов по раундам;
- merge-коммит `type(PlanID): summary` — после вашего «да»;
- закрытый план остаётся в истории навсегда (статус `Done`).

## Команды Manager'а

| Команда | Что делает |
| --- | --- |
| `/planfaktor-init` | Разовый старт Manager-сессии: свежее чтение контрактов, режим сессии |
| `/planfaktor-plan` | Создаёт план из вашего брифа |
| `/planfaktor-run` | Один шаг конвейера по старейшему активному плану |
| `/planfaktor-status` | Статусы планов и очередь работ — без изменений |

![Доклад /planfaktor-status по реальной очереди планов](img/getting_started/03-status-report.png)

## Частые вопросы первого запуска

- **Конвейер «ничего не делает».** Смотрите строку `**Status:**` в
  шапке плана и открытые вопросы `to=Owner` в Q&A log — почти всегда
  конвейер ждёт именно вашего ответа.
- **Где мой план?** `docs/plans/`, имя — дата и время создания. Имя
  менять нельзя: по нему строится очередь.
- **Задача переросла план.** Скажите об этом: Architect переведёт план
  в `Superseded` со ссылкой на преемника.
- **Хочу понять, почём задача.** Секция `## Token usage` в плане:
  usage-строка на каждый диспатч роли и CENSOR-проход.
- **Конвейер встал намертво.** Плейбук ручного восстановления —
  [терминальное восстановление](playbooks/manual_terminal_recovery.md).

## Что дальше

- [Быстрый старт Owner'а](../README.md) — роли, гейты, чтение планов;
- [Конституция](../AGENTS.md) — все правила конвейера;
- [Жизненный цикл плана](lifecycle.md) — путь статусов
  от Draft до Done.
