SET timezone = 'UTC-3';

--1
drop function hello();

CREATE OR REPLACE FUNCTION hello(name VARCHAR)
RETURNS VARCHAR
language plpgsql AS
    $$
    begin
        RETURN CONCAT('Hello ',name,' ', CURRENT_TIMESTAMP);
    end;
$$;

select hello('Amir');

--2
drop function two_numbers_math(DOUBLE PRECISION, DOUBLE PRECISION);

CREATE OR REPLACE FUNCTION two_numbers_math(a DOUBLE PRECISION, b DOUBLE PRECISION)
RETURNS TABLE (Sum NUMERIC,
               Multiplication NUMERIC,
               Difference NUMERIC,
               Division NUMERIC)
language plpgsql AS
    $$
    begin
        RETURN QUERY
            SELECT ROUND ((a+b):: NUMERIC, 2) AS Sum,
                   ROUND ((a*b):: NUMERIC, 2) AS multiplication,
                   ROUND((CASE WHEN b>a THEN b-a ELSE a-b END):: NUMERIC, 2) AS Difference,
                   ROUND((CASE WHEN b=0 THEN NULL ELSE a/b END):: NUMERIC ,2) AS DIVISION;
    end;
$$;

select * from two_numbers_math(2.3,-0.12);

--3
drop function return_small_number_of_2(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION return_small_number_of_2(a INTEGER, b INTEGER)
RETURNS TEXT
language plpgsql AS
    $$
    begin
        IF a=b THEN
            RETURN 'Two numbers are the same!';
        ELSE
            RETURN (CASE WHEN a>b THEN b ELSE a END);
        END IF;
    end;
$$;

SELECT return_small_number_of_2(1,900);

--4
drop function return_small_number_of_3;

CREATE OR REPLACE function return_small_number_of_3 (a INTEGER, b INTEGER, c INTEGER)
RETURNS TEXT
language plpgsql AS
$$
    begin
        IF a=b AND  a=c THEN
            RETURN 'Numbers are the same!';
        ELSE
            RETURN
                (Case
                    WHEN a<=b AND a<=c THEN a
                    WHEN b<=a AND b<=c THEN b
                    ELSE c
                END)::TEXT;
        END IF;
    end;
    $$;

SELECT return_small_number_of_3(1,2,3);
SELECT return_small_number_of_3(2,1,3);
SELECT return_small_number_of_3(3,2,1);
SELECT return_small_number_of_3(1,1,3);
SELECT return_small_number_of_3(1,2,2);

-- OR:
CREATE OR REPLACE function return_small_number_of_3 (a INTEGER, b INTEGER, c INTEGER)
RETURNS TEXT
language plpgsql AS
$$
    begin
        IF a=b AND  a=c THEN
            RETURN 'Numbers are the same!';
        ELSE
            RETURN
                'The Smallest Number is: ' ||  LEAST(a,b,c);
        END IF;
    end;
    $$;
    ]/

SELECT return_small_number_of_3(1,2,2);

--5
drop function random_max_min ();

CREATE OR REPLACE function random_max_min (max INTEGER, min INTEGER)
RETURNS INTEGER
language plpgsql AS
    $$
    begin
        RETURN floor(RANDOM()*(max-min+1))+min;
    end;
        $$;

select random_max_min(1,82);

--6
drop function book_statistics;

CREATE OR REPLACE function book_statistics ()
RETURNS TABLE(min_price DOUBLE PRECISION, max_price DOUBLE PRECISION, avg_price DOUBLE PRECISION, quantity_of_books INTEGER)
language plpgsql AS
    $$
    begin
        RETURN QUERY
            SELECT  min(b.price) AS min_price,
                    max(b.price) AS max_price,
                    avg(b.price) AS avg_price,
                    COUNT(*):: INTEGER AS quantity_of_books
            FROM books b;
    end;
    $$;

SELECT * FROM book_statistics();

--7
drop function max_books_by_author;

CREATE OR REPLACE function max_books_by_author()
RETURNS TABLE (author TEXT, number_of_books INTEGER)
language plpgsql AS
    $$
    begin
        RETURN QUERY
            SELECT a.name, COUNT(b.id)::INTEGER
            FROM authors a
            JOIN books b ON a.id = b.author_id
            GROUP BY a.name
            HAVING COUNT(b.id) =
                   (SELECT MAX(book_count)
                    FROM (SELECT COUNT (b.id) AS book_count
                    FROM books b
                    GROUP BY b.author_id) AS subquery);
    end;
$$;


SELECT * FROM max_books_by_author();

--8
drop function cheapest_book;

CREATE OR REPLACE function cheapest_book()
RETURNS TABLE (title TEXT, price DOUBLE PRECISION)
language plpgsql AS
    $$
    begin
        RETURN QUERY
            SELECT b.title, b.price
            FROM books b
            WHERE b.price = (SELECT MIN(b.price)
                             FROM books b);
    end;
$$;

SELECT * FROM cheapest_book();

--9
drop function avg_rows_num;

CREATE OR REPLACE function avg_rows_num()
RETURNS DOUBLE PRECISION
language plpgsql AS
    $$
    DECLARE
        count_authors INTEGER;
        count_books INTEGER;
        average DOUBLE PRECISION;
    begin
        SELECT COUNT(*) INTO count_authors FROM authors;
        SELECT COUNT(*) INTO count_books FROM books;
        average := (count_authors+count_books)/2.0;
        RETURN average;
    end;
$$;

SELECT * FROM avg_rows_num();

--10

drop function new_book_id;

CREATE OR REPLACE function new_book_id(new_title TEXT, new_release_date DATE)
RETURNS INTEGER
language plpgsql AS
    $$
    DECLARE new_id INTEGER;
    begin
        INSERT INTO books (title,release_date) VALUES (new_title,new_release_date) RETURNING id INTO new_id;
        RETURN new_id;
    end;
$$;

SELECT new_book_id('Brave New World', '1932-09-01');

--11

drop function new_author_id;

CREATE OR REPLACE function new_author_id(new_author TEXT)
RETURNS INTEGER
language plpgsql AS
    $$
    DECLARE new_id INTEGER;
    begin
        INSERT INTO authors (name) VALUES (new_author) RETURNING id INTO new_id;
        RETURN new_id;
    end;
$$;

SELECT new_author_id('Ken Follett');

--12
drop function average_books_per_author();

CREATE OR REPLACE FUNCTION average_books_per_author()
RETURNS TABLE(author_name TEXT, average_number_of_books INTEGER)
language plpgsql AS
    $$
begin
    RETURN QUERY
    SELECT a.name AS author_name, COALESCE(AVG(b.book_count)::INTEGER,0) AS average_number_of_books
    FROM authors a
    LEFT JOIN
        (SELECT author_id, COUNT(*) AS book_count
         FROM books
         GROUP BY author_id) b
    ON a.id = b.author_id
        GROUP BY a.name;
end;
$$ ;

SELECT * FROM average_books_per_author();

--13
drop PROCEDURE update_book;

CREATE OR REPLACE PROCEDURE update_book(target_book_id INTEGER, new_title TEXT, new_release_date DATE, new_price DOUBLE PRECISION, new_author_id INTEGER)
language plpgsql AS
    $$
begin
    UPDATE books
    SET title = new_title, release_date = new_release_date, price = new_price, author_id = new_author_id
    WHERE id = target_book_id;
end;
$$ ;

CALL update_book(1,'Under The Dome','2009-11-10',79.9, 6)

--14

drop PROCEDURE update_author;

CREATE OR REPLACE PROCEDURE update_author(target_author_id INTEGER, new_author_name TEXT)
language plpgsql AS
    $$
begin
    UPDATE authors
    SET name = new_author_name
    WHERE id = target_author_id;
end;
$$ ;

CALL update_author(1,'Yuval Noah Harari');

--15

drop function books_between_min_and_max_price;

CREATE OR REPLACE FUNCTION books_between_min_and_max_price(min_price DOUBLE PRECISION, max_price DOUBLE PRECISION)
RETURNS TABLE (book_id BIGINT, book_title TEXT, book_price DOUBLE PRECISION)
language plpgsql AS
    $$
begin
    RETURN QUERY
        SELECT id, title, price FROM books
            WHERE price BETWEEN min_price AND max_price;
end;
$$ ;

SELECT * FROM books_between_min_and_max_price(39.9,59.9);

--16
drop function books_not_by_authors;

CREATE OR REPLACE FUNCTION books_not_by_authors(author1 TEXT, author2 TEXT)
RETURNS TABLE (book_id BIGINT, book_title TEXT, author TEXT)
LANGUAGE plpgsql AS
$$
begin
    RETURN QUERY
    WITH BOOKS_AUTH1 AS
        (SELECT b.id
         FROM books b
        JOIN authors a
        ON b.author_id = a.id
        WHERE a.name = author1),
    BOOKS_AUTH2 AS
        (SELECT b.id
         FROM books b
        JOIN authors a
        ON b.author_id = a.id
        WHERE a.name = author2)
    SELECT b.id, b.title, a.name
    FROM books b
    JOIN authors a
    ON b.author_id = a.id
    WHERE b.id NOT IN (SELECT id FROM BOOKS_AUTH1)
      AND b.id NOT IN (SELECT id FROM BOOKS_AUTH2);
END;
$$;

SELECT * FROM books_not_by_authors('Stephen King', 'Haruki Murakami');

--17
drop function upsert_new_book;

ALTER TABLE books
ADD CONSTRAINT book_unique_title_author UNIQUE (title, author_id);

CREATE OR REPLACE function upsert_new_book(book_title TEXT, book_release_date DATE, book_author_id BIGINT, book_price NUMERIC)
RETURNS BIGINT
language plpgsql AS
    $$
    DECLARE
        book_id BIGINT;
    begin
        INSERT INTO books (title,release_date,author_id,price)
        VALUES (book_title,book_release_date, book_author_id, book_price)
        ON CONFLICT (title, author_id) DO UPDATE
        SET release_date = EXCLUDED.release_date
        RETURNING id INTO book_id;

        RETURN book_id;
    end;
$$;

SELECT upsert_new_book('A Game of Thrones', '1996-08-06',11,999.99);

select * from books where title = 'A Game of Thrones';

--18
drop function books_details_with_text_parameter;

CREATE OR REPLACE FUNCTION books_details_with_text_parameter (parameter TEXT)
RETURNS TABLE (book_id BIGINT, book_title TEXT, date_or_author TEXT)
language plpgsql AS
    $$
    begin
        IF parameter = 'D' THEN
            RETURN QUERY
                SELECT b.id, b.title, b.release_date::TEXT
                FROM books b;
        ELSE
            RETURN QUERY
                SELECT b.id, b.title, a.name
                FROM books b
                JOIN authors a
                ON b.author_id=a.id;
        END IF;
    end;
$$;

SELECT * FROM books_details_with_text_parameter ('D');
SELECT * FROM books_details_with_text_parameter ('d');
SELECT * FROM books_details_with_text_parameter ('So postreSQL IS case-sensitive??');

--19
drop function with_or_without_discount;

CREATE OR REPLACE FUNCTION with_or_without_discount(
    discount BOOLEAN,
    book_title TEXT,
    discount_percentage DOUBLE PRECISION DEFAULT 0.0
)
RETURNS TABLE (
    the_books_title TEXT,
    original_price DOUBLE PRECISION,
    with_discount TEXT,
    applied_discount_percentage DOUBLE PRECISION,
    new_price DOUBLE PRECISION
)
LANGUAGE plpgsql AS
$$
DECLARE
    original_price DOUBLE PRECISION;
    new_price DOUBLE PRECISION;
    book_exists BOOLEAN;
begin
    SELECT EXISTS(SELECT 1 FROM books WHERE title = book_title) INTO book_exists;
    IF NOT book_exists THEN
        RAISE EXCEPTION 'This book does not exist';
    END IF;
    SELECT price INTO original_price FROM books WHERE title = book_title;
    IF discount THEN
        IF discount_percentage = 0.0 THEN
            discount_percentage := 0.5;
        END IF;
        new_price := ROUND((original_price - (original_price * discount_percentage))::NUMERIC, 2);
        RETURN QUERY
            SELECT book_title AS the_books_title, original_price, 'Yes' AS with_discount, discount_percentage AS applied_discount_percentage, new_price;
    ELSE
        RETURN QUERY
            SELECT book_title AS the_books_title, original_price, 'No' AS with_discount, 0::DOUBLE PRECISION AS applied_discount_percentage, original_price AS new_price;
    END IF;
end;
$$;

SELECT * FROM with_or_without_discount(TRUE, 'Harry Potter and the Prisoner of Azkaban', 0.5);
SELECT * FROM with_or_without_discount(FALSE, 'Harry Potter and the Prisoner of Azkaban', 0.1);
SELECT * FROM with_or_without_discount(TRUE, 'Harry Potter and the Prisoner of Azkaban');
SELECT * FROM with_or_without_discount(FALSE, 'Harry Potter and the Prisoner of Azkaban');
