-- Упражнение 1: Основы обработки транзакций

-- Таблица `accounts`:

-- CREATE TABLE accounts (
--     account_id SERIAL PRIMARY KEY,
--     balance NUMERIC NOT NULL
-- );

-- INSERT INTO accounts (balance) VALUES (1000), (1500), (2000);

-- **Задача:**

-- Напишите транзакцию, которая переводит $200 с аккаунта 1 на аккаунт 2. 
-- Убедитесь, что транзакция является атомарной, то есть если 
-- какая-либо часть ее не выполнится, изменения не должны быть зафиксированы в базе данных.

BEGIN;

UPDATE accounts
SET balance = balance - 200
WHERE account_id = 1;


UPDATE accounts
SET balance = balance + 200
WHERE account_id = 2;


IF (SELECT balance FROM accounts WHERE account_id = 1) < 0 THEN
    ROLLBACK;  
ELSE
    COMMIT;  
END IF;

-- Упражнение 2: Обработка ошибок в транзакциях

-- Продолжение с таблицей `accounts` из Упражнения 1.

-- **Задача:**

-- Напишите транзакцию, которая пытается перевести 
-- $5000 с аккаунта 1 на аккаунт 3, но у аккаунта 1 недостаточно средств. 
-- Убедитесь, что транзакция откатывается в случае ошибки.

BEGIN;

UPDATE accounts
SET balance = balance - 5000
WHERE account_id = 1;

IF (SELECT balance FROM accounts WHERE account_id = 1) < 0 THEN
    ROLLBACK;  
    RAISE EXCEPTION 'Недостаточно средств на аккаунте 1 для перевода'; 
ELSE
    UPDATE accounts
    SET balance = balance + 5000
    WHERE account_id = 3;

    COMMIT;  
END IF;

-- Упражнение 3: Уровни изоляции и конкурентность

-- Используйте ту же таблицу `accounts`.

-- **Задача:**

-- На уровне изоляции `SERIALIZABLE` создайте две конкурентные транзакции, 
-- которые изменяют баланс одного и того же аккаунта. 
-- Опишите, как PostgreSQL обрабатывает эту ситуацию.

BEGIN;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
UPDATE accounts
SET balance = balance - 200
WHERE account_id = 1;
COMMIT;

BEGIN;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
UPDATE accounts
SET balance = balance + 300
WHERE account_id = 1;
COMMIT;

-- Когда две транзакции выполняются конкурентно на уровне изоляции SERIALIZABLE, PostgreSQL гарантирует, что результат будет таким же, как если бы транзакции были выполнены последовательно.

-- В этом случае, если две транзакции выполняются одновременно, PostgreSQL может обнаружить, что они конфликтуют, и откатить одну из них. Это происходит потому, что PostgreSQL использует механизм сериализации, который гарантирует, что результат будет последовательным.

-- Если первая транзакция уже подтвердила изменения, вторая транзакция будет откатана, и PostgreSQL выдаст ошибку could not serialize access due to concurrent update.

-- Если же обе транзакции еще не подтвердили изменения, PostgreSQL может откатить одну из них и повторить попытку выполнения.

-- В любом случае, PostgreSQL гарантирует, что результат будет последовательным и что данные будут целостными.


-- Упражнение 4: Точки сохранения

-- Та же таблица `accounts`.

-- **Задача:**

-- Создайте транзакцию, которая использует точку сохранения (savepoint) 
-- для частичного отката неудачной операции, сохраняя при этом результаты 
-- операций до точки сохранения.

BEGIN;

SAVEPOINT before_update;

UPDATE accounts
SET balance = balance - 300
WHERE account_id = 1;

UPDATE accounts
SET balance = balance - 200
WHERE account_id = 2;

SAVEPOINT after_first_updates; -- savepoint

UPDATE accounts
SET balance = balance + 5000
WHERE account_id = 3;

IF (SELECT balance FROM accounts WHERE account_id = 3) < 0 THEN
    ROLLBACK TO SAVEPOINT after_first_updates;  
    RAISE EXCEPTION 'Операция не удалась: недостаточно средств на аккаунте 3';  
END IF;

COMMIT;

-- Упражнение 5: Обнаружение и разрешение взаимных блокировок

-- Используйте ту же таблицу `accounts`.

-- **Задача:**

-- Организуйте ситуацию взаимной блокировки между двумя транзакциями и продемонстрируйте, 
-- как PostgreSQL обнаруживает и разрешает ее.


BEGIN;

UPDATE accounts
SET balance = balance - 100
WHERE account_id = 1;

-- ждем некоторое время, чтобы дать возможность второй транзакции начать
SELECT pg_sleep(5);  -- задержка на 5 секунд

UPDATE accounts
SET balance = balance + 100
WHERE account_id = 2;

COMMIT;

BEGIN;

UPDATE accounts
SET balance = balance - 100
WHERE account_id = 2;

SELECT pg_sleep(5);  

UPDATE accounts
SET balance = balance + 100
WHERE account_id = 1;

COMMIT;

-- Когда обе транзакции выполняются одновременно, они могут заблокировать друг друга:

-- Транзакция 1 заблокирует аккаунт 1 и ожидает разблокировки аккаунта 2.
-- Транзакция 2 заблокирует аккаунт 2 и ожидает разблокировки аккаунта 1.
-- В результате возникает взаимная блокировка.

-- PostgreSQL имеет механизм обнаружения взаимных блокировок, который периодически проверяет активные транзакции. Если он обнаруживает взаимную блокировку, он автоматически откатывает одну из транзакций (обычно ту, которая была начата позже), чтобы разблокировать ресурсы.

-- В результате, Когда одна из транзакций будет откатана, PostgreSQL выдаст сообщение об ошибке, например:
-- ERROR: deadlock detected
-- DETAIL: Process ... waits for ShareLock on transaction ...; blocked by process ...
-- HINT: See server log for query details.


-- Упражнение 6: Транзакция с несколькими таблицами

-- Используйте ту же таблицу "accounts". Добавьте новую таблицу с именем "transfers", содержащую следующие столбцы:

-- CREATE TABLE transfers (
--     id SERIAL PRIMARY KEY,
--     from_account_id INTEGER REFERENCES accounts(id),
--     to_account_id INTEGER REFERENCES accounts(id),
--     amount DECIMAL(10, 2)
-- );

-- **Задача:**
-- Напишите транзакцию, которая переводит $200 с аккаунта 1 на аккаунт 2 и вставляет запись об это переводе в таблицу "transfers".


BEGIN;

UPDATE accounts
SET balance = balance - 200
WHERE account_id = 1;

UPDATE accounts
SET balance = balance + 200
WHERE account_id = 2;

INSERT INTO transfers (from_account_id, to_account_id, amount)
VALUES (1, 2, 200.00);

-- проверка логичности
IF (SELECT balance FROM accounts WHERE account_id = 1) < 0 THEN
    ROLLBACK;  
ELSE
    COMMIT;  
END IF;










