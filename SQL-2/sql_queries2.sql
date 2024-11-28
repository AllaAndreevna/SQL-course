-- Задание 1. 
-- Напишите SQL-запросы, возвращающие следующие данные:

-- 1. Вывести все названия (Title) книг (Book) вместе с названиями (PubName) их издателей (Publisher)
select Title, PubName from Book

-- 2. Вывести ISBN книги/всех книг (Book) с максимальным количеством страниц (PagesNum)
select ISBN from Book 
where PagesNum = (select max(PagesNum) from Book)

-- 3. Какие авторы (Author) написали больше пяти книг (Book)?
select Author from Book 
group by Author having count(*) > 5

-- 4. Вывести ISBN всех книг (Book), количество страниц (PagesNum) больше, 
-- чем в два раза больше среднего количества страниц во всех книгах
select ISBN from Book 
where PagesNum > 2 * (select avg(PagesNum) from Book)

-- 5. Вывести категории, в которых есть подкатегории.
select ParentCat from Category
where ParentCat is not null

-- 6. Вывести имена всех авторов (Author), написавших больше всех книг. Считать имена уникальными.
select Author from Book
group by Author having count(*) = (select max(cnt) from (select Author, count(*) as cnt  from Book group by Author) as subquery);

-- 7. Вывести номера читателей (ReaderNr), которые брали (Borrwing) все книги (Book, не Copy) Марка Твена.
select br.ReaderNr from Borrowing br
join Book book on br.ISBN = book.ISBN
where book.Author = 'Mark Twain'
group by br.ReaderNr having count(distinct book.ISBN) = (select count(distinct ISBN) from Book where Author = 'Mark Twain');

-- 8. У каких (ISBN) книг (Book) больше, чем одна копия (Copy)?
select copy.ISBN from Copy copy
group by copy.ISBN having count(CopyNumber) > 1

-- 9. Вывести 10 самых старых (по PubYear) книг. 
-- Если в самом древнем году 10 книг или больше, вывести их все. 
-- Если нет, вывести, сколько есть, и дальше выводить все книги из каждого предыдущего года, 
-- пока не наберется всего 10 или больше.
with RankedBooks as (
  select Title, PubYear,
  row_number() over (order by PubYear) as RowNum
  from Book
)
select Title from RankedBooks
where RowNum <= 10;

-- 10. Вывести все поддерево подкатегорий категории “Sports”.
with recursive SportsSubcategories as (
  select CategoryName, ParentCat
  from Category
  where CategoryName = 'Sports'
  union all
  select c.CategoryName, c.ParentCat
  from Category c
  inner join SportsSubcategories p on c.ParentCat = p.CategoryName
)
select CategoryName
from SportsSubcategories;   

-- Задание 2.
-- Напишите запросы для следующих действий:

-- 1. Добавить в таблицу Borrowing запись про то, 
-- что ‘John Johnson’ взял книгу c ISBN=123456 и CopyNumber=4.
insert into Borrowing (ReaderNr, ISBN, CopyNumber)
values ((select ID from Reader where FirstName = 'John' and LastName = 'Johnson'), '123456', 4);

-- 2. Удалить все книги с годом публикации больше, чем 2000.
delete from Book
where PubYear > 2000;

-- 3. Увеличить дату возврата на 30 дней (просто +30) 
-- для всех книг в категории "Databases",  у которых эта дата > '01.01.2022'.
update Borrowing
set ReturnDate = ReturnDate + INTERVAL '30 days'
where ISBN in (
    select ISBN from BookCat
    where CategoryName = 'Databases'
) and ReturnDate > '2022-01-01';