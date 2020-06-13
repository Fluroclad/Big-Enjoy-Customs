import sys, env_variables
import psycopg2 as pg
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT

def connect(name):
    if name:
        connection = pg.connect(user = env_variables.DB.user,
                                password = env_variables.DB.password,
                                host = env_variables.DB.host,
                                port = env_variables.DB.port,
                                dbname = name)
    else:
        connection = pg.connect(user = env_variables.DB.user,
                                password = env_variables.DB.password,
                                host = env_variables.DB.host,
                                port = env_variables.DB.port,
                                )

    return connection

def install(schema = "database/schema.sql"):
    # Connect to database server
    # and create database
    try: 
        conn = connect("")
        conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        cur = conn.cursor()
        
        # Check if database already exists
        cur.execute("SELECT 1 FROM pg_catalog.pg_database WHERE datname = '" + env_variables.DB.name + "';")
        exists = cur.fetchone()
        if exists:
            result = input ("Delete database and recreate (Y/N)? ")

            if result == "Y" or result == "y":
                print("Dropping " + env_variables.DB.name)
                cur.execute("DROP DATABASE IF EXISTS " + env_variables.DB.name + ";")
                print("Creating " + env_variables.DB.name)
                cur.execute("CREATE DATABASE " + env_variables.DB.name + ";")

            else:
                # exit out of function
                print("Doing nothing")
                return 0
        else:
            print("Creating " + env_variables.DB.name)
            cur.execute("CREATE DATABASE " + env_variables.DB.name + ";")

    except Exception as e:
        raise e
    finally:
        if conn:
            cur.close()
            conn.close()

    print("Reading sql schema")
    with open(schema, "r") as f:
        sql = f.read()

    try:
        # Connect to database server
        conn = connect(env_variables.DB.name)
 
        with conn.cursor() as curs:
            print("Running sql schema")
            curs.execute(sql)
            conn.commit()
            print("Finished running sql schema")

    except Exception as e:
        conn.rollback()
        raise e

    return 0

if __name__ == '__main__':
    globals()[sys.argv[1]]()