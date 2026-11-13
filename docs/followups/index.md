# Follow-ups — index

Derived-сводка открытых follow-ups из `docs/followups/backlog.md`.
Пересобирается после каждого изменения backlog.md; при чтении руками
не правится. Формат строк носителя — row-грамматика
`docs/followups/_template.md`.

Счётчик: открытых — 12, закрытых (promoted/handled/cancelled) — 0
(состояние на 2026-11-13).

## Открытые по приоритетам

### P1 (2)

| id | P | summary | to | plan | status |
| --- | --- | --- | --- | --- | --- |
| closeout-tail-convention | P1 | Конвенция closeout-хвоста: решение (а) принято Owner 2026-11-12 (Evidence 261112_0111:276) — внести в AGENTS.md §8 | Owner | none | open |
| token-budgets | P1 | Бюджеты/алерты/лимиты расхода токенов на план | Owner | none | open |

### P2 (6)

| id | P | summary | to | plan | status |
| --- | --- | --- | --- | --- | --- |
| lint-v2-digest-verify | P2 | Corpus lint v2 — сверка digest-цитат с shasum | Architect | none | open |
| qa-lint | P2 | Q&A-линт (status=open без закрытия) | Architect | none | open |
| stale-intake-digest | P2 | Edge «Всегда»: протухший intake-digest после зафиксированной смены контракта не ловится | Architect | none | open |
| release-node | P2 | Релизный узел конвейера: конвенция тегов/сборок/release-notes и статус released в реестре | Architect | none | open |
| merge-untracked-guard | P2 | Merge-рутина: контроль посторонних untracked перед git add -A (инцидент при merge 261112_2236) | Architect | none | open |
| ci-v2-static | P2 | CI v2 static-джоба: shellcheck (POSIX) + actionlint + smoke-тест инстанцирования шаблона плана | Architect | none | open |

### P3 (4)

| id | P | summary | to | plan | status |
| --- | --- | --- | --- | --- | --- |
| hex-typo-t4 | P3 | Hex-опечатка a2c2faf8 → a2c2faf9 в Tests-цитате T4 | Coder | none | open |
| ci-hygiene | P3 | CI-гигиена: actions/checkout@v5 + миграция ubuntu-latest | Coder | none | open |
| history-secret-audit | P3 | History secret audit: периодический gitleaks detect по всей git-истории (C14 — только рабочее дерево) | Architect | none | open |
| lint-robustness | P3 | Робастность check_corpus.sh: heredoc-раскрытие, cwd-чувствительность, не заявленный awk | Architect | none | open |

## Закрытые

- нет
