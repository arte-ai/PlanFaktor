---
description: Обзор конвейера Planfaktor — статусы планов и следующий шаг
---

Routine основной сессии (Manager). Только чтение: никаких изменений файлов.

1. Собери истину из файлов:

   ```sh
   grep -H '^\*\*Status:\*\*' docs/plans/[0-9]*.md
   ls docs/reviews/
   ```

2. Для каждого плана проверь `grep -n 'to=Owner' docs/plans/<файл>` и
   валидность CENSOR-receipt: `grep -n '(Role CENSOR)' docs/plans/<файл>`.

3. Выведи таблицу `План | Статус | Чья фаза | CENSOR-receipt | to=Owner`:
   «Чья фаза» — переход по таблице §2 AGENTS.md и кто ставит следующий;
   «CENSOR-receipt» — маркер, вердикт, dispatch id, непустые Observations;
   «to=Owner» — открытые вопросы, особенно `to=Owner, blocker:`.

4. Назови следующий шаг по routing-таблице `/planfaktor-run`: какой диспатч
   роли или какой гейт Owner ждать (старт / merge / ответ на Q&A).

5. Никаких изменений файлов — только чтение и доклад Owner.
