# <Тема плана — человекочитаемо, по-русски>

**Plan ID:** YYMMDD_HHMM
**Status:** Draft
**Created:** YYYY-MM-DD
**Owner gates:** merge (`In review` → `Merged`); вопросы `to=Owner` — по мере возникновения

> Шапка — parser-контракт: строки выше grep'аются Manager'ом. Не менять формат.
> Имя файла: `YYMMDD_HHMM_topic.md` (тема латиницей, слова через `_`).

## Как я понял задачу
<!-- owner: architect; 3–7 строк; обязательна при Architect intake -->

## Problem
<!-- owner: architect; пронумерованные пункты -->

## Solution / Decisions
<!-- owner: architect; решения уровня «что и почему», без детализации -->

## Scope
<!-- owner: architect (границы), planner (уточняет); список изменений; пункты, реализующие внешние требования, несут метку [R: <ID>] (ID — из docs/requirements/registry.md) -->

## Out of scope
<!-- owner: architect -->

## Acceptance criteria / DoD
<!-- owner: planner; чек-лист проверяемых исходов; каждый пункт = проверяемое утверждение; пункты, реализующие внешние требования, несут метку [R: <ID>] (ID — из docs/requirements/registry.md) -->

- [ ] <критерий 1>

## Tests / Commands
<!-- owner: planner (задаёт), coder (заполняет факт); каждый DoD-пункт (Dn) покрывается строкой с меткой (Dn); R-DoD — обязательно; при переименованиях/миграциях терминологии — narrow + broad proof: narrow — exact-паттерн нового wording (база «сейчас 0», если якорь различающий), broad — prose-drift старого токена по всем активным носителям с классификацией вхождений (исторические планы и append-only артефакты исключены — там старое имя остаётся вечно) -->

## Changes (by area)
<!-- owner: coder; фактические изменения по областям; заполняется в ходе работы -->

## Evidence (chronological, append-only)
<!-- owner: все роли + CENSOR; событийные записи с датой и локальным временем `- YYYY-MM-DD HH:MM:SS — <кто>: <текст>`; CENSOR-receipt по формату конституции -->

## Token usage (append-only)
<!-- owner: manager; dispatch-форма: `- YYYY-MM-DD HH:MM:SS — usage: <role>.<work|censor|rN> <N|unknown (why=...)> tokens — <dispatch|sendmessage|unknown>`; чекпоинт-форма: `- YYYY-MM-DD HH:MM:SS — usage: manager-context checkpoint ~<N> tokens-left — approximate`; числа — учёт харнесса ZCode (subagent_tokens), приближение, не биллинг провайдера; пишет только Manager из tool-результата вызова -->

## Q&A log (chronological, append-only)
<!-- owner: все роли; intake: `Intake (YYYY-MM-DD HH:MM:SS): AGENTS.md@<8hex> <role>.md@<8hex>` (локальное время) + NO QUESTIONS / NO SUGGESTIONS / NO OBJECTIONS; вопросы `Q(<роль>#<n>): ... to=Owner, blocker: yes|no, needs_owner: yes|no, status=open`; закрытие парной строкой по номеру `A(<кто>#<n>): ... status=closed, перенесено в <секция>`; открытость = Q#n, ниже которой нет парной A#n; допущения Coder'а — строки `Assumption: ...` (append-only; влияющее на Scope/DoD/контракты — стоп и возврат на Planner, §5) -->

## Suggestions log (chronological, append-only)
<!-- owner: все роли; несрочные улучшения -->

## Objections log (chronological, append-only)
<!-- owner: все роли; `### <Role> objections`; строка на возражение, blocker: при блокере -->

## Follow-ups (deferred)
<!-- owner: coder/planner при CENSOR; незакрытые хвосты: <описание> — why: <почему сейчас не в скоупе>; обязательна запись `NO FOLLOW-UPS — why: <код_причины>` при отсутствии -->
