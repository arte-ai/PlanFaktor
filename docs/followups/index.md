# Follow-ups — index

Derived-сводка открытых follow-ups из `docs/followups/backlog.md`.
Пересобирается после каждого изменения backlog.md; при чтении руками
не правится. Формат строк носителя — row-грамматика
`docs/followups/_template.md`.

Счётчик: открытых — 12, закрытых (promoted/handled/cancelled) — 4
(состояние на 2026-11-15).

## Открытые по приоритетам

### P1 (1)

| id | P | summary | to | plan | status |
| --- | --- | --- | --- | --- | --- |
| token-budgets | P1 | Бюджеты/алерты/лимиты расхода токенов на план | Owner | none | open |

### P2 (5)

| id | P | summary | to | plan | status |
| --- | --- | --- | --- | --- | --- |
| lint-v2-digest-verify | P2 | Corpus lint v2 — сверка digest-цитат с shasum | Architect | none | open |
| qa-lint | P2 | Q&A-линт: пары Q#n→A#n (грамматика 261113_2121) | Architect | none | open |
| stale-intake-digest | P2 | Edge «Всегда»: протухший intake-digest после зафиксированной смены контракта не ловится | Architect | none | open |
| release-node | P2 | Релизный узел конвейера: конвенция тегов/сборок/release-notes и статус released в реестре | Architect | none | open |
| ci-v2-static | P2 | CI v2 static-джоба: shellcheck (POSIX) + actionlint + smoke-тест инстанцирования шаблона плана | Architect | none | open |

### P3 (7)

| id | P | summary | to | plan | status |
| --- | --- | --- | --- | --- | --- |
| hex-typo-t4 | P3 | Hex-опечатка a2c2faf8 → a2c2faf9 в Tests-цитате T4 | Coder | none | open |
| history-secret-audit | P3 | History secret audit: периодический gitleaks detect по всей git-истории (C14 — только рабочее дерево) | Architect | none | open |
| lint-robustness | P3 | Робастность check_corpus.sh: heredoc-раскрытие, cwd-чувствительность, не заявленный awk | Architect | none | open |
| ai-gate-policy-config | P3 | ai_gate policy-as-config: вынесение правил ИИ-гейта в конфигурацию | Architect | none | open |
| ci-incremental-lint | P3 | Incremental lint CI: прогон линта по изменённым файлам / diff-базе | Architect | none | open |
| install-tree-reshoot | P3 | Пересъёмка 01-install-tree.png (кадр отстал от четвёртой команды /planfaktor-init) | Owner | none | open |
| init-grep-stderr | P3 | /planfaktor-init: идемпотентный grep без 2>/dev/null (init.md:27) — stderr-шум на пустой очереди | Coder | none | open |

## Закрытые

- closeout-tail-convention — P1 — status=handled — plan=261115_1610 (Конвенция closeout-хвоста: решение (а) принято Owner 2026-11-12 (Evidence 261112_0111:276) — внесена в AGENTS.md §8; disposition — merge 9ebcd8a; терминально закрыто при closeout 2026-11-15)
- merge-untracked-guard — P2 — status=handled — plan=261113_2121 (Merge-рутина: контроль посторонних untracked; merge-коммит по явному списку + контроли; disposition — merge 720519f; терминально закрыто 2026-11-15)
- ci-hygiene — P3 — status=handled — plan=261113_1944 (CI-гигиена: checkout@v5, permissions, concurrency, матрица ОС, таймаут; disposition — merge 6596b7f, `.github/workflows/corpus.yml`; терминально закрыто при closeout 2026-11-15)
