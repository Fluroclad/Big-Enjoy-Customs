import sys, json
import psycopg2 as pg
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
import psycopg2.extras

import riotapi

# TEMP
import env_variables

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
        if (conn):
            cur.close()
            conn.commit()
            conn.close()

    # Read Table file
    print("Reading sql schema")
    with open(schema, "r") as f:
        sql = f.read()

    try:
        # Connect to database server
        conn = connect(env_variables.DB.name)
 
        with conn.cursor() as cur:
            print("Running sql schema")
            cur.execute(sql)
            conn.commit()
            print("Finished running sql schema")

    except Exception as e:
        conn.rollback()
        raise e
    finally:
        if (conn):
            cur.close()
            conn.commit()
            conn.close()

    # General install functions from sql file
    reinstallFunctions()

    return 0

def reinstallFunctions(functions = "database/functions.sql"):
    print("Reading functions sql")
    with open(functions, "r") as f:
        sql = f.read()

    try:
        # Connect to database server
        conn = connect(env_variables.DB.name)
 
        with conn.cursor() as cur:
            print("Running functions sql")
            cur.execute(sql)
            conn.commit()
            print("Finished running functions sql")

    except Exception as e:
        conn.rollback()
        raise e
    finally:
        if (conn):
            cur.close()
            conn.commit()
            conn.close()



def getPlayer(player_name):
    try:
        conn = connect(env_variables.DB.name)
        cur = conn.cursor(cursor_factory=pg.extras.DictCursor)
        cur.callproc("get_player",[player_name,])
        result = cur.fetchone()
        
        json_data = {}
        json_data["player_name"] = result["player_name"]

        json_data["preferences"] = {}
        json_data["preferences"]["top"]     = result["pref_top"]
        json_data["preferences"]["jungle"]  = result["pref_jungle"]
        json_data["preferences"]["middle"]  = result["pref_middle"]
        json_data["preferences"]["bottom"]  = result["pref_bottom"]
        json_data["preferences"]["support"] = result["pref_support"]

        json_data["ratings"] = {}
        json_data["ratings"]["global"]  = result["rating_global"]
        json_data["ratings"]["top"]     = result["rating_top"]
        json_data["ratings"]["jungle"]  = result["rating_jungle"]
        json_data["ratings"]["middle"]  = result["rating_middle"]
        json_data["ratings"]["bottom"]  = result["rating_bottom"]
        json_data["ratings"]["support"] = result["rating_support"]

        return json.dumps(json_data)
    except Exception as e:
        print(e)
        conn.rollback()
        return False
    finally:
        if (conn):
            cur.close()
            conn.commit()
            conn.close()

def addPlayer(player_data):
    try:
        conn = connect(env_variables.DB.name)
        cur = conn.cursor()
        result = riotapi.getAccount(player_data["summoner_name"])
        
        if result.status_code == 403 or result.status_code == 404:
            return False
        elif result.status_code == 200:
            # Call pgsql function
            player_data["riot_account_id"] = result.json()["accountId"]
            cur.callproc("add_player", [json.dumps(player_data)])
            return True
   
    except Exception as e:
        print(e)
        conn.rollback()
        return False
    finally:
        if(conn):
            cur.close()
            conn.commit()
            conn.close()

def addMatch(match_data):
    try:
        conn = connect(env_variables.DB.name)
        cur = conn.cursor()

        # Request match data from Riot API
        result = riotapi.getMatch(match_data["match_id"])
        
        if result.status_code == 403 or result.status_code == 404:
            return False
        elif result.status_code == 200:
            # Call pgsql function
            cur.callproc("add_game", [json.dumps(result.json()),json.dumps(match_data)])
            return True
    
    except Exception as e:
        print(e)
        conn.rollback()
        return False
    finally:
        if(conn):
            cur.close()
            conn.commit()
            conn.close()
        

if __name__ == '__main__':
    globals()[sys.argv[1]]()