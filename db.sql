CREATE TABLE authors (
    id bigserial NOT NULL PRIMARY KEY,
    name TEXT NOT NULL
);

CREATE TABLE books (
    id bigserial NOT NULL PRIMARY KEY,
    title TEXT,
    release_date DATE NOT NULL,
    price DOUBLE PRECISION DEFAULT 0 NOT NULL,
    author_id BIGINT REFERENCES authors
);

INSERT INTO authors (name) VALUES
('J.K. Rowling'),    -- 1
('George R.R. Martin'),  -- 2
('J.R.R. Tolkien'),  -- 3
('Agatha Christie'), -- 4
('Haruki Murakami'), -- 5
('Stephen King'),    -- 6
('Jane Austen'),     -- 7
('Isaac Asimov'),    -- 8
('Margaret Atwood'), -- 9
('Mark Twain');      -- 10

INSERT INTO books (title, release_date, price, author_id) VALUES
('Harry Potter and the Philosophers Stone', '1997-06-26', 39.99, 1),
('Harry Potter and the Chamber of Secrets', '1998-07-02', 34.99, 1),
('Harry Potter and the Prisoner of Azkaban', '1999-07-08', 40.99, 1),
('A Game of Thrones', '1996-08-06', 45.00, 2),
('A Clash of Kings', '1998-11-16', 47.99, 2),
('A Storm of Swords', '2000-08-08', 42.99, 2),
('The Hobbit', '1937-09-21', 30.50, 3),
('The Fellowship of the Ring', '1954-07-29', 35.00, 3),
('The Two Towers', '1954-11-11', 36.99, 3),
('The Return of the King', '1955-10-20', 39.50, 3),
('Murder on the Orient Express', '1934-01-01', 25.00, 4),
('The ABC Murders', '1936-01-06', 28.50, 4),
('And Then There Were None', '1939-11-06', 29.99, 4),
('Kafka on the Shore', '2002-09-12', 32.00, 5),
('Norwegian Wood', '1987-09-04', 31.00, 5),
('1Q84', '2009-05-29', 48.99, 5),
('The Shining', '1977-01-28', 29.99, 6),
('It', '1986-09-15', 35.99, 6),
('Pride and Prejudice', '1813-01-28', 24.99, 7),
('Sense and Sensibility', '1811-10-30', 23.50, 7),
('Foundation', '1951-06-01', 31.50, 8),
('I, Robot', '1950-12-02', 27.99, 8),
('The Handmaids Tale', '1985-08-17', 28.99, 9),
('Oryx and Crake', '2003-05-01', 34.00, 9),
('Adventures of Huckleberry Finn', '1884-12-10', 22.00, 10),
('The Adventures of Tom Sawyer', '1876-06-25', 20.50, 10);

