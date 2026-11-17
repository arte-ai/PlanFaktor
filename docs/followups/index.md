# Follow-ups — index

Derived-сводка открытых follow-ups из `docs/followups/backlog.md`.
Пересобирается после каждого изменения backlog.md; при чтении руками
не правится. Формат строк носителя — row-грамматика
`docs/followups/_template.md`.

Счётчик: открытых — 16, закрытых (promoted/handled/cancelled) — 18
(состояние на 2026-11-17).

## Открытые по приоритетам

### P2 (2)

| id | P | summary | to | plan | status |
| --- | --- | --- | --- | --- | --- |
| stale-intake-digest | P2 | Edge «Всегда»: протухший intake-digest после зафиксированной смены контракта не ловится | Architect | none | open |
| docs-wave2-contract-layer | P2 | Docs wave 2: контрактный слой F5–F9 + S3.1–8 (отдельный план) | Owner | none | open |

### P3 (14)

| id | P | summary | to | plan | status |
| --- | --- | --- | --- | --- | --- |
| history-secret-audit | P3 | History secret audit: периодический gitleaks detect по всей git-истории (C14 — только рабочее дерево) | Architect | none | open |
| ai-gate-policy-config | P3 | ai_gate policy-as-config: вынесение правил ИИ-гейта в конфигурацию | Architect | none | open |
| ci-incremental-lint | P3 | Incremental lint CI: прогон линта по изменённым файлам / diff-базе | Architect | none | open |
| install-tree-reshoot | P3 | Пересъёмка 01-install-tree.png (кадр отстал от четвёртой команды /planfaktor-init) | Owner | none | open |
| release-notes-lint | P3 | Машинная проверка релиз-нот и тег↔файл (кандидат C17/v2; вкл. finding R2 261115_2252) | Architect | none | open |
| release-automation | P3 | Автоматизация выпуска: релиз-скрипт, автогенерация нот/матрицы (кандидат v2) | Architect | none | open |
| supply-chain-pinning | P3 | Supply-chain hardening CI: SHA-пиннинг checkout + checksum бинарников (вкл. finding R1 плана 261115_2254) | Architect | none | open |
| c15-shallow-fail-loud | P3 | C15: явная диагностика shallow-истории (fetch-depth) вместо каскада not-in-set | Architect | none | open |
| role-tier-norming | P3 | Нормирование расхода по ролям/проходам (per-role тиры; harvest 261117_0221) | Owner | none | open |
| index-counter-consistency | P3 | Машинная сверка счётчика index со списком/носителем (3-й drift: 8a1d2fa, v0.1.0, 1419) | Architect | none | open |
| qa-format-lint | P3 | Q&A-format-lint: формат Q/A-строк (v3; резолвинг F3 harvest 1321) | Architect | none | open |
| site-redeploy | P3 | Редеплой сайта после обеих волн ревью доков (F13) | Owner | none | open |
| guides-link-lint | P3 | Машинная проверка ссылок гайдов (кандидат C19/v3) | Architect | none | open |
| guides-img-renders | P3 | img-ссылки гайдов вне каркаса — рендер без иллюстраций (suggestion 2002) | Architect | none | open |

## Закрытые

- closeout-tail-convention — P1 — status=handled — plan=261115_1610 (Конвенция closeout-хвоста: решение (а) принято Owner 2026-11-12 (Evidence 261112_0111:276) — внесена в AGENTS.md §8; disposition — merge 9ebcd8a; терминально закрыто при closeout 2026-11-15)
- merge-untracked-guard — P2 — status=handled — plan=261113_2121 (Merge-рутина: контроль посторонних untracked; merge-коммит по явному списку + контроли; disposition — merge 720519f; терминально закрыто 2026-11-15)
- ci-hygiene — P3 — status=handled — plan=261113_1944 (CI-гигиена: checkout@v5, permissions, concurrency, матрица ОС, таймаут; disposition — merge 6596b7f, `.github/workflows/corpus.yml`; терминально закрыто при closeout 2026-11-15)
- release-node — P2 — status=handled — plan=261115_2252 (Релизный узел конвейера: конвенция тегов/сборок/release-notes и статус released в реестре; disposition — merge c5371e7; терминально закрыто при closeout 2026-11-16)
- ci-v2-static — P2 — status=handled — plan=261115_2254 (CI v2 static-джоба: shellcheck + actionlint + smoke `--smoke`; disposition — merge 62563c7; терминально закрыто при closeout 2026-11-16)
- token-budgets — P1 — status=handled — plan=261117_0221 (Токен-бюджеты: тиры warn=28M/discuss=42M, бюджетные заметки на гейтах; disposition — merge 812d860; терминально закрыто при closeout 2026-11-17)
- lint-v2-digest-verify — P2 — status=handled — plan=261116_1321 (Corpus lint v2: digest-verify intake-цитат — чек C15; disposition — merge 579863f; терминально закрыто при closeout 2026-11-16)
- qa-lint — P2 — status=handled — plan=261116_1321 (Q&A-линт: пары Q#n→A#n — чек C16; disposition — merge 579863f; терминально закрыто при closeout 2026-11-16)
- hex-typo-t4 — P3 — status=handled — plan=261117_1419 (Hex-опечатка T4: правка :493 плана 261111_1455; disposition — merge 9ed4cf1; терминально закрыто при closeout 2026-11-17)
- lint-robustness — P3 — status=handled — plan=261117_1419 (Робастность линта: cwd-фикс C9 + awk в шапке; heredoc-часть опровергнута верификацией; disposition — merge 9ed4cf1; терминально закрыто при closeout 2026-11-17)
- init-grep-stderr — P3 — status=handled — plan=261117_1419 (Инверсия носителя: run.md без 2>/dev/null + find-guard; disposition — merge 9ed4cf1; терминально закрыто при closeout 2026-11-17)
- s2-coder-status-contract — P2 — status=handled — plan=261117_1419 (S2-контракт Coder: оба легальных PRE-статуса; disposition — merge 9ed4cf1; терминально закрыто при closeout 2026-11-17)
- c6-hex-nick-threshold — P3 — status=handled — plan=261117_1419 (C6-порог @{7,}; disposition — merge 9ed4cf1; терминально закрыто 2026-11-17)
- c12-desc-separator — P3 — status=handled — plan=261117_1419 (C12-диагностика + selftest-кейс; disposition — merge 9ed4cf1; терминально закрыто 2026-11-17)
- pass-censor-notation — P3 — status=handled — plan=261117_1419 (PASS: censor ×5; disposition — merge 9ed4cf1; терминально закрыто 2026-11-17)
- reroute-notation-anchor — P3 — status=handled — plan=261117_1419 (Reroute-якорь AGENTS §2; disposition — merge 9ed4cf1; терминально закрыто 2026-11-17)
- status-cmd-link — P3 — status=handled — plan=261117_1419 (status.md:49 — факт переноса; disposition — merge 9ed4cf1; терминально закрыто 2026-11-17)
- ci-pr-dedup — P3 — status=handled — plan=261117_1419 (CI-триггеры раздельно; disposition — merge 9ed4cf1; терминально закрыто 2026-11-17)
