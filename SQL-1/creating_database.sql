CREATE TABLE Reader (
    ID INT PRIMARY KEY,
    LastName VARCHAR(50),
    FirstName VARCHAR(50),
    Address VARCHAR(100),
    BirthDate DATE
);


CREATE TABLE Book (
    ISBN VARCHAR(20) PRIMARY KEY,
    Title VARCHAR(100),
    Author VARCHAR(50),
    PagesNum INT,
    PubYear INT,
    PubName VARCHAR(50)
);


CREATE TABLE Publisher (
    PubName VARCHAR(50) PRIMARY KEY,
    PubKind VARCHAR(20)
);

CREATE TABLE Category (
    CategoryName VARCHAR(50) PRIMARY KEY,
    ParentCat VARCHAR(50)
);

CREATE TABLE Copy (
    ISBN VARCHAR(20),
    CopyNumber INT,
    Shelf VARCHAR(10),
    Position INT,
    PRIMARY KEY (ISBN, CopyNumber),
    FOREIGN KEY (ISBN) REFERENCES Book(ISBN)
);

CREATE TABLE Borrowing (
    ReaderNr INT,
    ISBN VARCHAR(20),
    CopyNumber INT,
    ReturnDate DATE,
    PRIMARY KEY (ReaderNr, ISBN, CopyNumber),
    FOREIGN KEY (ReaderNr) REFERENCES Reader(ID),
    FOREIGN KEY (ISBN, CopyNumber) REFERENCES Copy(ISBN, CopyNumber)
);

CREATE TABLE BookCat (
    ISBN VARCHAR(20),
    CategoryName VARCHAR(50),
    PRIMARY KEY (ISBN, CategoryName),
    FOREIGN KEY (ISBN) REFERENCES Book(ISBN),
    FOREIGN KEY (CategoryName) REFERENCES Category(CategoryName)
);



INSERT INTO Reader (ID, LastName, FirstName, Address, BirthDate)
VALUES
    (1, 'Ivanov', 'Ivan', 'Moscow', '1990-01-01'),
    (2, 'Petrov', 'Petr', 'St. Petersburg', '1992-02-02'),
    (3, 'Sidorov', 'Sidor', 'Moscow', '1995-03-03'),
    (4, 'Kuznetsov', 'Kuzma', 'Novosibirsk', '1998-04-04'),
    (5, 'Vasiliev', 'Vasiliy', 'Moscow', '2000-05-05');


INSERT INTO Book (ISBN, Title, Author, PagesNum, PubYear, PubName)
VALUES
    ('978-1234567890', 'Mount Everest', 'John Smith', 200, 2010, 'Science Pub'),
    ('978-2345678901', 'Travel to Europe', 'Jane Doe', 300, 2012, 'Reference Books'),
    ('978-3456789012', 'The Himalayas', 'Bob Johnson', 250, 2015, 'Science Pub'),
    ('978-4567890123', 'Python Programming', 'Ivan Ivanov', 400, 2018, 'Reference Books'),
    ('978-5678901234', 'The Alps', 'Alice Brown', 220, 2020, 'Science Pub');


INSERT INTO Publisher (PubName, PubKind)
VALUES
    ('Science Pub', 'Science'),
    ('Reference Books', 'Reference'),
    ('Fiction House', 'Fiction');


INSERT INTO Category (CategoryName, ParentCat)
VALUES
    ('Mountains', NULL),
    ('Travel', NULL),
    ('Science', NULL),
    ('Reference', NULL),
    ('Fiction', NULL),
    ('Geography', 'Science'),
    ('Adventure', 'Travel');


INSERT INTO Copy (ISBN, CopyNumber, Shelf, Position)
VALUES
    ('978-1234567890', 1, 'A1', 1),
    ('978-1234567890', 2, 'A1', 2),
    ('978-2345678901', 1, 'B2', 1),
    ('978-3456789012', 1, 'A1', 3),
    ('978-4567890123', 1, 'C3', 1),
    ('978-5678901234', 1, 'A1', 4);


INSERT INTO Borrowing (ReaderNr, ISBN, CopyNumber, ReturnDate)
VALUES
    (1, '978-1234567890', 1, '2022-01-01'),
    (1, '978-2345678901', 1, '2022-02-01'),
    (2, '978-3456789012', 1, null),
    (3, '978-4567890123', 1, '2022-04-01'),
    (1, '978-5678901234', 1, '2022-05-01'),
    (4, '978-1234567890', 2, null);


INSERT INTO BookCat (ISBN, CategoryName)
VALUES
    ('978-1234567890', 'Mountains'),
    ('978-2345678901', 'Travel'),
    ('978-3456789012', 'Mountains'),
    ('978-4567890123', 'Reference'),
    ('978-5678901234', 'Mountains');
    
    
    

