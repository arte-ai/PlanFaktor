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
> Действителен только последний Round.

## Findings — Risk lane
<!-- owner: reviewer-risk -->

| # | Серьёзность (blocker/major/minor) | Файл:строка | Суть | Почему риск |
|---|---|---|---|---|
| 1 | | | | |

### Risk verdict: pass | needs-fix
<одно предложение: за что вердикт; needs-fix → обязательно blocker/major выше>
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

### Contracts verdict: pass | needs-fix
<одно предложение: все ли DoD-пункты закрыты, есть ли выход за Scope>
<метка времени записи вердикта: YYYY-MM-DD HH:MM:SS — локальное время>

## Итог
<!-- owner: reviewer-contracts собирает; итог действителен только при двух записанных вердиктах выше -->

- Risk: pass | needs-fix
- Contracts: pass | needs-fix
- **Итоговый вердикт:** pass → Owner-гейт merge | needs-fix → вернуть Coder'у (Coder ставит `In progress`; возражения — в этом review-артефакте: findings ланов)
- **Состав staged (канонизация merge-состава):** дословный вывод
  `git diff --cached --name-only` на момент contracts-вердикта, один
  файл на строку; Manager сверяет merge-коммит с этим списком
  (notice ≠ mutation truth)

  <файл 1>
  <файл 2>
