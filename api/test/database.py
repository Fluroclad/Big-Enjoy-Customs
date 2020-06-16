import sys, json, requests
import psycopg2 as pg

user = "postgres"
password = "admin"
host = "localhost"
port = "5432"
database = "big_enjoy_customs"
token = ""

# Test Database connection
def connection():
    try:
        conn = pg.connect(  user = user,
                            password = password,
                            host = host,
                            port = port,
                            dbname = database)

        cur = conn.cursor()

        print(conn.get_dsn_parameters(), "\n")

        cur.execute("SELECT version();")
        record = cur.fetchone()
        print("You are connected to - ", record, "\n")

    except(Exception, pg.Error) as error:
        print("Error while connecting to PostgreSQL", error)

    finally:
        if(conn):
            cur.close()
            conn.close()
            print("PostgreSQL connection is closed")

def db_function():
    try:
        conn = pg.connect(  user = user,
                            password = password,
                            host = host,
                            port = port,
                            dbname = database)

        cur = conn.cursor()
        
        playerName = input ("Player Name: ")
        topPref = input("Top (number 1-10 inclusive): ")
        junglePref = input("Jungle (number 1-10 inclusive): ")
        middlePref = input("Middle (number 1-10 inclusive): ")
        bottomPref = input("Bottom (number 1-10 inclusive): ")
        supportPref = input("Support (number 1-10 inclusive): ")
        cur.callproc("add_player", [playerName,topPref,junglePref,middlePref,bottomPref,supportPref])

    except(Exception, pg.Error) as error:
        print(error)

    finally:
        if(conn):
            cur.close()
            conn.commit()
            conn.close()
            print("PostgreSQL connection is closed")

def db_json_function(id = "4639995139"):
    riotAPI = "https://euw1.api.riotgames.com/"
    matchAPI = "/lol/match/v4/matches/" + str(id)

    r = requests.get(riotAPI + matchAPI + "?api_key=" + token)
    
    try:
        conn = pg.connect(  user = user,
                            password = password,
                            host = host,
                            port = port,
                            dbname = database)

        cur = conn.cursor()

        f = open("players.json", "r")
        players_list = f.read()

        cur.callproc("add_game", [json.dumps(r.json()),players_list])
    
    except(Exception, pg.Error) as error:
        print(error)

    finally:
        if(conn):
            cur.close()
            conn.commit()
            conn.close()
            print("PostgreSQL connection is closed")
    
def populateDB():
    try:
        conn = pg.connect(  user = user,
                            password = password,
                            host = host,
                            port = port,
                            dbname = database)

        cur = conn.cursor()

        print("Starting to populate database")
        
        print("Start players")
        players_list = json.load(open("players.json"))

        for player in players_list["players"]:
            cur.callproc("add_player", [json.dumps(player)])
        
        print("End players")

        print("Start matches")
        match = json.load(open("match.json"))
        match_players = json.load(open("match_players.json"))
        
        cur.callproc("add_game", [json.dumps(match),json.dumps(match_players)])
        
        print("End matches")

        print("Finished populating database")
    except Exception as e:
        print(e)
        conn.rollback()
    finally:
        if(conn):
            cur.close()
            conn.commit()
            conn.close()
            print("PostgreSQL connection is closed")



if __name__ == '__main__':
    globals()[sys.argv[1]]()