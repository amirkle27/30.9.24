import psycopg2
import psycopg2.extras

try:
    connection = psycopg2.connect(
        host="localhost",
        database="postgres",
        user="postgres",  # This is the default postgres admin user
        password="admin",  # Update with your password
        port="5432"  # Default port for PostgreSQL
    )
    cursor = connection.cursor(cursor_factory=psycopg2.extras.DictCursor)
###################################################
    # A -
# 1
    books_details = "SELECT * FROM books_details_with_text_parameter ('D');"
    print(f"With this SQL query: {books_details}")
    print("We get the book id, title, and release_date:")
    cursor.execute(books_details)

    records = cursor.fetchall()
    for record in records:
        print(record)

#2
    books_by_other_authors = "SELECT * FROM books_not_by_authors('Stephen King', 'Haruki Murakami');"
    print(f"With this SQL query: {books_by_other_authors}")
    print("We get all the books that were written by other authors, avoiding the two authors specified")
    cursor.execute(books_by_other_authors)

    records = cursor.fetchall()
    for record in records:
        print(record)

#3
    book_statistics = "SELECT * FROM book_statistics();"
    print(f"With this SQL query: {book_statistics}")
    print("We get statistics for the cheapest book, most expensive book, average price and total number of books")
    cursor.execute(book_statistics)

    records = cursor.fetchall()
    for record in records:
        print(record)

# B -
    most_expensive_book = """SELECT * FROM books
                            WHERE price = (SELECT MAX(price) FROM books)"""
    cursor.execute(most_expensive_book)

    records = cursor.fetchall()
    for record in records:
        print(f" most expensive book is: {record}")

    Updating_most_expensive = """UPDATE books
                                 SET price = price / 2
                                 WHERE price = (SELECT MAX(price) FROM books)
                                 """

    print(f"With this SQL query: {Updating_most_expensive}")
    print("The most expensive book's price is cut by 50%")
    cursor.execute(Updating_most_expensive)

    most_expensive_after_discount = """SELECT * FROM books
                                        WHERE id = 34"""

    print(f"With this SQL query: {most_expensive_after_discount}")
    print("We can now check that our update query (Updating_most_expensive) actually worked:")
    cursor.execute(most_expensive_after_discount)
    
    records = cursor.fetchall()
    for record in records:
        print(record)



########################################################
except Exception as e:
    print(f"An error occurred: {e}")

finally:
    # Ensure all resources are released properly
    if cursor:
        cursor.close()
    if connection:
        connection.close()
