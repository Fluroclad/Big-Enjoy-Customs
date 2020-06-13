import psycopg2

# Test Database connection

try:
    connection = psycopg2.connect(  user = "postgres",
                                    password = "admin",
                                    host = "localhost",
                                    port = "5432",
                                    database = "postgres")

    c = connection.cursor()

    print(connection.get_dsn_parameters(), "\n")

    c.execute("SELECT version();")
    record = c.fetchone()
    print("You are connected to - ", record, "\n")

except(Exception, psycopg2.Error) as error:
    print("Error while connecting to PostgreSQL", error)

finally:
    if(connection):
        c.close()
        connection.close()
        print("PostgreSQL connection is closed")
