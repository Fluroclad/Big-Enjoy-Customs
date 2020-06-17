import sys
import json
import psycopg2 as pg
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT
import psycopg2.extras

import riotapi

# TEMP
import env_variables

class Database:
    def connect(self, user, password, host, port, db):
        try:
            if db:
                self.connection = pg.connect(user = user,
                                            password = password,
                                            host = host,
                                            port = port,
                                            dbname = db)

            else:
                self.connection = pg.connect(user = user,
                                            password = password,
                                            host = host,
                                            port = port)

        except Exception as e:
            raise e
    
    # Dict = True (Use Dictionary Cursor)
    def set_cursor(self, dict):
        if dict == True:
            self.cursor = self.connection.cursor(cursor_factory=pg.extras.DictCursor)
        else:
            self.cursor = self.connection.cursor()

    # Clean up resources
    def exit(self):
        try:
            self.cursor.close()
        except:
            print("No cursor attribute")
        self.connection.commit()
        self.connection.close()

    ## Players
    def get_player(self, player_name):
        try:
            self.cursor.callproc("get_player", [player_name])
            result = self.cursor.fetchone()
            json_data = {}
            
            if result:
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

            else:
                return False

        except Exception as e:
            print(e)
            self.connection.rollback()
            return False
    
    def add_player(self, player_data):
        try:
            result = riotapi.getAccount(player_data["summoner_name"])
            
            if result.status_code == 200:
                # Call pgsql function
                player_data["riot_account_id"] = result.json()["accountId"]
                self.cursor.callproc("add_player", [json.dumps(player_data)])
                return True

            else:
                return False
    
        except Exception as e:
            print(e)
            self.connection.rollback()
            return False

    ## Matches
    def add_match(self, match_data):
        try:
            # Request match data from Riot API
            result = riotapi.getMatch(match_data["match_id"])
            
            if result.status_code == 403 or result.status_code == 404:
                return False

            elif result.status_code == 200:
                # Call pgsql function
                self.cursor.callproc("add_game", [json.dumps(result.json()),json.dumps(match_data)])
                return True
        
        except Exception as e:
            print(e)
            self.connection.rollback()
            return False

def install(schema = "database/schema.sql"):
    # Connect to database server and create database
    try: 
        db = Database()
        db.connect(env_variables.DB.user, env_variables.DB.password,
                    env_variables.DB.host, env_variables.DB.port, False)
        db.connection.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        db.set_cursor(False)
        
        # Check if database already exists
        db.cursor.execute("SELECT 1 FROM pg_catalog.pg_database WHERE datname = '" + env_variables.DB.name + "';")
        
        if db.cursor.fetchone():
            result = input ("Delete database and recreate (Y/N)? ")

            if result == "Y" or result == "y":
                print("Dropping " + env_variables.DB.name)
                db.cursor.execute("DROP DATABASE IF EXISTS " + env_variables.DB.name + ";")
                print("Creating " + env_variables.DB.name)
                db.cursor.execute("CREATE DATABASE " + env_variables.DB.name + ";")

            else:
                # exit out of function
                print("Doing nothing")
                return 0

        else:
            print("Creating " + env_variables.DB.name)
            db.cursor.execute("CREATE DATABASE " + env_variables.DB.name + ";")

    except Exception as e:
        raise e

    finally:
        if (db.connection):
            db.cursor.close()
            db.connection.commit()
            db.connection.close()

    # Read Table file
    print("Reading sql schema")
    with open(schema, "r") as f:
        sql = f.read()

    try:
        # Connect to database server
        db.connect(env_variables.DB.user, env_variables.DB.password,
                    env_variables.DB.host, env_variables.DB.port, env_variables.DB.name)
        db.set_cursor(False)

        print("Running sql schema")
        db.cursor.execute(sql)
        db.connection.commit()
        print("Finished running sql schema")

    except Exception as e:
        db.connection.rollback()
        raise e

    finally:
        if (db.connection):
            db.cursor.close()
            db.connection.commit()
            db.connection.close()

    # General install functions from sql file
    reinstallFunctions()

def reinstallFunctions(functions = "database/functions.sql"):
    print("Reading functions sql")
    with open(functions, "r") as f:
        sql = f.read()

    try:
        db = Database()

        # Connect to database server
        db.connect(env_variables.DB.user, env_variables.DB.password,
                    env_variables.DB.host, env_variables.DB.port, env_variables.DB.name)
        db.set_cursor(False)

        print("Running functions sql")
        db.cursor.execute(sql)
        db.connection.commit()
        print("Finished running functions sql")

    except Exception as e:
        db.connection.rollback()
        raise e

    finally:
        if (db.connection):
            db.cursor.close()
            db.connection.commit()
            db.connection.close()   

if __name__ == '__main__':
    globals()[sys.argv[1]]()