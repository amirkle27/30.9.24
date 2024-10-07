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

SELECT * FROM average_books_per_author()
