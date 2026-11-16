# Follow-ups — index

Derived-сводка открытых follow-ups из `docs/followups/backlog.md`.
Пересобирается после каждого изменения backlog.md; при чтении руками
не правится. Формат строк носителя — row-грамматика
`docs/followups/_template.md`.

Счётчик: открытых — 12, закрытых (promoted/handled/cancelled) — 9
(состояние на 2026-11-16).

## Открытые по приоритетам

### P1 (1)

| id | P | summary | to | plan | status |
| --- | --- | --- | --- | --- | --- |
| token-budgets | P1 | Бюджеты/алерты/лимиты расхода токенов на план | Owner | none | open |

### P2 (1)

| id | P | summary | to | plan | status |
| --- | --- | --- | --- | --- | --- |
| stale-intake-digest | P2 | Edge «Всегда»: протухший intake-digest после зафиксированной смены контракта не ловится | Architect | none | open |

### P3 (10)

| id | P | summary | to | plan | status |
| --- | --- | --- | --- | --- | --- |
| hex-typo-t4 | P3 | Hex-опечатка a2c2faf8 → a2c2faf9 в Tests-цитате T4 | Coder | none | open |
| history-secret-audit | P3 | History secret audit: периодический gitleaks detect по всей git-истории (C14 — только рабочее дерево) | Architect | none | open |
| lint-robustness | P3 | Робастность check_corpus.sh: heredoc-раскрытие, cwd-чувствительность, не заявленный awk | Architect | none | open |
| ai-gate-policy-config | P3 | ai_gate policy-as-config: вынесение правил ИИ-гейта в конфигурацию | Architect | none | open |
| ci-incremental-lint | P3 | Incremental lint CI: прогон линта по изменённым файлам / diff-базе | Architect | none | open |
| install-tree-reshoot | P3 | Пересъёмка 01-install-tree.png (кадр отстал от четвёртой команды /planfaktor-init) | Owner | none | open |
| init-grep-stderr | P3 | /planfaktor-init: идемпотентный grep без 2>/dev/null (init.md:27) — stderr-шум на пустой очереди | Coder | none | open |
| release-notes-lint | P3 | Машинная проверка релиз-нот и тег↔файл (кандидат C15/v2; включает finding R2 плана 261115_2252) | Architect | none | open |
| release-automation | P3 | Автоматизация выпуска: релиз-скрипт, автогенерация нот/матрицы (кандидат v2) | Architect | none | open |
| supply-chain-pinning | P3 | Supply-chain hardening CI: SHA-пиннинг checkout + checksum бинарников (вкл. finding R1 плана 261115_2254) | Architect | none | open |

## Закрытые

- closeout-tail-convention — P1 — status=handled — plan=261115_1610 (Конвенция closeout-хвоста: решение (а) принято Owner 2026-11-12 (Evidence 261112_0111:276) — внесена в AGENTS.md §8; disposition — merge 9ebcd8a; терминально закрыто при closeout 2026-11-15)
- merge-untracked-guard — P2 — status=handled — plan=261113_2121 (Merge-рутина: контроль посторонних untracked; merge-коммит по явному списку + контроли; disposition — merge 720519f; терминально закрыто 2026-11-15)
- ci-hygiene — P3 — status=handled — plan=261113_1944 (CI-гигиена: checkout@v5, permissions, concurrency, матрица ОС, таймаут; disposition — merge 6596b7f, `.github/workflows/corpus.yml`; терминально закрыто при closeout 2026-11-15)
- release-node — P2 — status=handled — plan=261115_2252 (Релизный узел конвейера: конвенция тегов/сборок/release-notes и статус released в реестре; disposition — merge c5371e7; терминально закрыто при closeout 2026-11-16)
- ci-v2-static — P2 — status=handled — plan=261115_2254 (CI v2 static-джоба: shellcheck + actionlint + smoke `--smoke`; disposition — merge 62563c7; терминально закрыто при closeout 2026-11-16)
- lint-v2-digest-verify — P2 — status=handled — plan=261116_1321 (Corpus lint v2: digest-verify intake-цитат — чек C15; disposition — merge 579863f; терминально закрыто при closeout 2026-11-16)
- qa-lint — P2 — status=handled — plan=261116_1321 (Q&A-линт: пары Q#n→A#n — чек C16; disposition — merge 579863f; терминально закрыто при closeout 2026-11-16)
