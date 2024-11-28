-- Напишите SQL-запросы, возвращающие следующие данные:

-- 1. Все фамилии (LastName) читателей (Reader) из Москвы
SELECT LastName
FROM Reader
WHERE Address = 'Moscow';

-- 2. Все названия (Title) и авторов (Author) книг (Books), 
-- опубликованных издателями (Publisher) научной или 
-- справочной литературы (pubKind либо 'Science', либо 'Reference')
SELECT book.Title, book.Author
FROM Book book
JOIN Publisher p ON book.PubName = p.PubName
WHERE p.PubKind IN ('Science', 'Reference');

-- 3. Все названия (Title) и авторов (Author) книг (Books), которые брал Иван Иванов.
SELECT book.Title, book.Author
FROM Borrowing br
JOIN Book book ON br.ISBN = book.ISBN
JOIN Reader r ON br.ReaderNr = r.ID
WHERE r.LastName = 'Ivanov' AND r.FirstName = 'Ivan';

-- 4. Все идентификаторы (ISBN) книг (Book), относящихся к категории "Mountains", 
-- но не относящихся к категории "Travel". Подкатегории не учитывать.
SELECT book.ISBN
FROM Book book
JOIN BookCat bcat ON bcat.ISBN = book.ISBN
WHERE bcat.CategoryName = 'Mountains' AND NOT bcat.CategoryName = 'Travel';

-- 5. Все фамилии и имена читателей, которые вернули хотя бы одну книгу (Borrowing.ReturnDate is not null)
SELECT r.LastName, r.FirstName
FROM Reader r
JOIN Borrowing br ON r.ID = br.ReaderNr
WHERE br.ReturnDate is not null;

-- 6. Все фамилии и имена читателей, которые брали (Borrowing)  
-- хотя бы одну книгу (Book), которую брал Иван Иванов. 
-- Ответ не должен содержать самого Ивана Иванова.
SELECT DISTINCT r.LastName, r.FirstName
FROM Borrowing br
JOIN Reader r ON br.ReaderNr = r.ID
WHERE br.ISBN IN (
  SELECT br2.ISBN
  FROM Borrowing br2
  JOIN Reader r2 ON br2.ReaderNr = r2.ID
  WHERE r2.LastName = 'Ivanov' AND r2.FirstName = 'Ivan'
)
AND r.LastName != 'Ivanov' AND r.FirstName != 'Ivan';