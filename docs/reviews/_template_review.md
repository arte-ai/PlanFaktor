# Review — <PlanID>

**Plan:** docs/plans/<PlanID>_<topic>.md
**Reviewed:** staged-изменения против HEAD (`git diff --cached`; при пустом — `git diff`)
**Status плана на момент review:** In review
**Created:** YYYY-MM-DD HH:MM:SS
**Round:** 1
**Lanes:** risk → contracts (последовательно; contracts читает секцию risk)

> Повторный раунд (после needs-fix), N ≥ 2: `**Round:**` +1 дописывается
> в этот же файл; в шапку дописывается строка
> `**Round <N> started:** YYYY-MM-DD HH:MM:SS` (append, не перезапись —
> история раундов видна); findings/вердикты прошлого раунда помечаются
> `superseded (round N)`, где N — номер нового (текущего) раунда.
> Действителен только последний Round. Раунд ≥ 2 живёт с грамматикой
> доверия: risk-лейн объявляет `**Rerun mode:**` при открытии раунда
> (см. поля в его секции); необъявленный режим — process gap, Manager
> возвращает артефакт fail loud.
> Stale/Rerun note: при возврате needs-fix Manager дописывает Evidence-
> строку в план — прошлый вердикт относится к пред-фиксному diff,
> реран ревью обязателен (до рерана артефакт не терминален).
> Обязательные поля артефакта: контент либо `N/A (why=...)` — если у
> поля нет специализированной формы отсутствия. Специализированные
> формы старше общей, не дублируются и не заменяются ею: no-findings-
> форма пустых таблиц лейнов/Итога, `Fixes: none (NO FINDINGS; ...)`
> цензорного receipt, `NO FOLLOW-UPS — why:` плана и другие по §5
> конституции. `TBD`/пусто/`UNCONFIRMED` невалидны как класс.

## Findings — Risk lane
<!-- owner: reviewer-risk -->

| # | Серьёзность (blocker/major/minor) | Файл:строка | Суть | Почему риск |
|---|---|---|---|---|
| 1 | | | | |

**Coverage:** <покрытые домены risk-лейна, одна строка, токены через
«; », без дублей>
<домены risk-лейна: regression-behavior — регрессии поведения соседних
областей; edge-cases — границы, пустые значения, ошибки, повторные
запуски; data-integrity-secrets — целостность данных, секреты,
приватные следы; command-reproducibility — воспроизводимость команд
и честность фактов Evidence; brittleness — хрупкость формы/якорей
к будущим правкам>

**No findings reason:** <только при пустой таблице находок: почему
находок нет — текстом; пустая таблица — нормальный исход, но с причиной;
при непустой таблице строка удаляется>

**Rerun mode:** incremental | full
<только Round ≥ 2 — объявляет risk-лейн при открытии раунда; Round 1
строку не пишет; incremental допустим только если последний pass-раунд
закрыл исходный scope и требует всех четырёх полей доверия ниже;
full — реран по всему diff, прежние раунды только history, поля доверия
ниже не пишутся>

**Baseline artifact:** <incremental: какой раунд/вердикт — база рерана>
**Rerun scope:** <incremental: что реранится — дельта fixes и задетые поверхности>
**Trusted unaffected surfaces:** <incremental: что не реранится и почему доверяем — diff не затрагивает файлы, неизменные digest'ы, инварианты линта>
**Reused evidence:** <incremental: какие findings/факты базового раунда переиспользуются>

### Risk verdict: pass | needs-fix
<одно предложение: за что вердикт; needs-fix — при находках, претендующих
на канонизацию live S1 (см. ## Итог); S2/S3 merge не блокируют —
материализация фиксом в текущем раунде либо follow-up>
<метка времени записи вердикта: YYYY-MM-DD HH:MM:SS — локальное время>

## Findings — Contracts lane
<!-- owner: reviewer-contracts -->

| # | Серьёзность (blocker/major/minor) | Проверка (DoD-пункт / Scope-граница) | Статус (ok/violation) | Комментарий |
|---|---|---|---|---|
| 1 | | | | |

Трассируемость (дополнительная проверка лана): все R-метки `[R: <ID>]`
плана существуют в реестре `docs/requirements/registry.md`; каждый
R-DoD закрыт — его метка Dn покрыта Tests-строкой и evidence
(семантическая проверка, второй угол к C12(а)/(в)
`scripts/check_corpus.sh`).

**Coverage:** <покрытые домены contracts-лейна, одна строка, токены через
«; », без дублей>
<домены contracts-лейна: constitution-compliance — соответствие конституции
§1–§10; canon-drift — канон-дрифт между носителями: AGENTS/шаблоны/роли/
команды/линт; artifact-grammar — целостность форматов и грамматик
плана/review/линта; review-artifact-truthfulness — правдивость
review-артефакта и Evidence против файлов; scope-dod-boundaries — границы
Scope/DoD: всё из Scope сделано, ничего лишнего; tests-evidence-trace —
Tests/Commands покрыты DoD-метками, факты в Evidence>

**No findings reason:** <только при пустой таблице находок — текстом>

### Contracts verdict: pass | needs-fix
<одно предложение: все ли DoD-пункты закрыты, есть ли выход за Scope;
needs-fix — при находках, претендующих на канонизацию live S1>
<метка времени записи вердикта: YYYY-MM-DD HH:MM:SS — локальное время>

## Итог
<!-- owner: reviewer-contracts собирает; итог действителен только при двух записанных вердиктах выше -->

- Risk: pass | needs-fix
- Contracts: pass | needs-fix
- **Итоговый вердикт:** pass → Owner-гейт merge | needs-fix → маршрут
  по Loop signal: вердикт с Loop signal (повторный по lineage блокер)
  идёт Architect'у — reopened-классификация и reroute-переход
  (`Ready for Coder` при same-contract reroute; `Ready for Planner`
  при real scope expansion; de-scoped follow-up — в Follow-ups/backlog
  без статусного перехода); без Loop signal — возврат Coder'у: Coder
  ставит `In progress` на intake fixes-итерации; возражения — findings
  лейнов в этом артефакте
- **Artifact state:** current_green | historical_reconciled |
  current_red | needs_reviewer_rerun
  <ставит contracts-лейн при сборе Итога: current_green — последний раунд
  pass против актуального diff; historical_reconciled — блокеры
  урегулированы историей раундов; current_red и needs_reviewer_rerun —
  нетерминальные, блокируют closeout (`Merged → Done`); incremental-pass
  даёт current_green только вместе с обоснованными полями доверия — без
  них артефакт остаётся needs_reviewer_rerun>

Судьбы находок (текущий раунд, все находки обоих лейнов):
- Finding R<n> | C<n> → accepted_blocker | accepted_non_blocking_followup | accepted_risk | dismissed | superseded → #B<N> | —
  <строка на каждую находку лейнов; canonical_ref `#B<N>` обязателен для
  accepted_blocker; accepted_blocker → B-блок `Current state: open`
  (итоговый needs-fix — при Severity S1); accepted_non_blocking_followup
  → материализация в `## Follow-ups (deferred)` плана / backlog;
  accepted_risk → зафиксированный trade-off без действия; dismissed →
  отклонение с обоснованием; superseded → поглощено/вытеснено раундом;
  при rerane прежние судьбы помечаются `— superseded (round N)` —
  конвенция раундов>
- При отсутствии находок у обоих лейнов судьбы не пишутся, Итог несёт
  плейсхолдер: coverage-домены (строки `**Coverage:**` лейнов выше) +
  `**No findings reason:**` текстом — пустого молчания нет

**No findings reason:** <плейсхолдер Итога: только при отсутствии
находок у обоих лейнов — почему, текстом>

### B<N>
<только при live-блокерах; B-блок — единственная легальная форма
live-блокера: на него ссылаются план, классификация и линт
(`<путь_ревью>#B<N>`); лейны пишут findings с локальными ID — канонизация
в `### B<N>` происходит здесь, в синтезе Итога; findings-таблицы
blocker/major/minor остаются плотным перечнем находок — две оси
сосуществуют; поля — значения из enum'ов, значение вне enum'а роняет
линт C13>

Current state: open | historical-fixed | superseded
Severity: S1 | S2 | S3
<S1 — контракт/данные/безопасность/несоответствие плану, включая
регрессии поведения соседних областей (regression-behavior); S2 —
техдолг/edge-cases; S3 — стиль; merge-гейт — только live S1: итоговый
needs-fix ⇔ есть блок Current state: open и Severity: S1; S2/S3 merge
не блокируют, но обязаны материализоваться (фикс либо follow-up)>
Primary owner gap: <зона-источник дефекта — чьё упущение:
architect | planner | coder | reviewer-risk | reviewer-contracts | manager>

Loop signal: <обязателен у live-блока, чей ID присутствует в
superseded-контенте того же артефакта (машинный маркер переиспользования
— `#B<N>` в строках с лейблом `superseded (round ...)`): lineage —
ID переиспользован, из какого раунда; повтор без Loop signal = process
miss Reviewer'а — Manager возвращает артефакт fail loud; при reroute ID
переиспользуется, новый ID — только при real scope expansion или новом
независимом дефекте>
Root cause class: stale-evidence | same-contract-reroute | closed-baseline-split | real-scope-expansion | de-scoped-followup
<соответствие классам: stale-evidence — ревью смотрело неактуальный
diff (исторический артефакт/рассинхрон); same-contract-reroute — контракт
не менялся, возврат в тот же скоуп; closed-baseline-split — закрытая
базовая часть + живая часть блокера выделены; real-scope-expansion —
требуется реальное расширение скоупа; de-scoped-followup — выведено
в follow-up>
Next owner: <architect | planner | coder | reviewer-risk | reviewer-contracts | manager>

- **Состав staged (канонизация merge-состава):** дословный вывод
  `git diff --cached --name-only` на момент contracts-вердикта, один
  файл на строку; Manager сверяет merge-коммит с этим списком
  (notice ≠ mutation truth)

  <файл 1>
  <файл 2>
