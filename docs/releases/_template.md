# Релиз vX.Y.Z — Planfaktor

<!-- Шаблон релиз-ноты (конвенция: docs/releases/README.md). Носитель
экземпляра: docs/releases/vX.Y.Z.md — по одному файлу на выпуск; создаёт
Manager при резке релиза. Плейсхолдеры <...> заменяются фактами выпуска. -->

## Шапка выпуска

- Версия: vX.Y.Z (semver; конвенция — docs/releases/README.md)
- Дата выпуска: <YYYY-MM-DD HH:MM:SS>
- Аннотированный git-тег: `vX.Y.Z` (`git tag -a vX.Y.Z -m ...`)
- Базовый коммит: <полный хэш> — closeout-хвост последнего Done-плана
  либо коммит, явно указанный Owner

## Вошедшие планы (с прошлого тега)

Планы, вошедшие в выпуск с предыдущего тега (первый выпуск — от начала
истории): PlanID, тип merge-коммита, тема.

| PlanID | Тип | Тема |
|---|---|---|
| <YYMMDD_HHMM> | <feat\|fix\|docs\|chore> | <тема плана> |

## Требования → released

Переводы `verified → released` в docs/requirements/registry.md (по
умолчанию — все rows в `verified` на момент выпуска, либо явный список
Owner); записи журнала реестра — по одной на требование:

- `<ID>: verified → released — vX.Y.Z`

## Verification-evidence (сборка = верифицированный снапшот)

Факты прогонов на тегаемом коммите (fresh-green инвариант; исполнитель
и локальное время — обязательны):

- `sh scripts/check_corpus.sh` → `corpus: clean`, exit 0 — <дата, время, кем>
- `sh scripts/check_corpus.sh --selftest` → итог `selftest: <N/N> caught`, exit 0 — <дата, время, кем>
- C14 (gitleaks по рабочему дереву) — чисто, находок нет — <дата, время, кем>

## Известные ограничения

Открытые backlog-хвосты на момент выпуска (docs/followups/index.md):

- <id> — <P> — <summary>

Честные границы: 5.12/5.13 (безопасная система/среда сборки) — вне скоупа
конвейера (docs/compliance/gost-r-56939-2024.md); GitHub Releases —
опциональная публикация, не инвариант.
