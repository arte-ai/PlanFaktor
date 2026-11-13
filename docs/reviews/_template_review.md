# Review — <PlanID>

**Plan:** docs/plans/<PlanID>_<topic>.md
**Reviewed:** staged-изменения против HEAD (`git diff --cached`; при пустом — `git diff`)
**Status плана на момент review:** In review
**Lanes:** risk → contracts (последовательно; contracts читает секцию risk)

## Findings — Risk lane
<!-- owner: reviewer-risk -->

| # | Серьёзность (blocker/major/minor) | Файл:строка | Суть | Почему риск |
|---|---|---|---|---|
| 1 | | | | |

### Risk verdict: pass | needs-fix
<одно предложение: за что вердикт; needs-fix → обязательно blocker/major выше>

## Findings — Contracts lane
<!-- owner: reviewer-contracts -->

| # | Серьёзность (blocker/major/minor) | Проверка (DoD-пункт / Scope-граница) | Статус (ok/violation) | Комментарий |
|---|---|---|---|---|
| 1 | | | | |

### Contracts verdict: pass | needs-fix
<одно предложение: все ли DoD-пункты закрыты, есть ли выход за Scope>

## Итог
<!-- owner: reviewer-contracts собирает; итог действителен только при двух записанных вердиктах выше -->

- Risk: pass | needs-fix
- Contracts: pass | needs-fix
- **Итоговый вердикт:** pass → Owner-гейт merge | needs-fix → вернуть Coder'у (статус `In progress`, возражения в Objections log плана)
