import flask
import sys
import os
import psycopg2 as pg
from psycopg2.extensions import ISOLATION_LEVEL_AUTOCOMMIT

def connect(name):
    if name:
        connection = pg.connect(user = os.environ.get('POSTGRES_USER'),
                                password = os.environ.get('POSTGRES_PASSWORD'),
                                host = os.environ.get('POSTGRES_HOST'),
                                port = os.environ.get('POSTGRES_PORT'),
                                dbname = name)
    else:
        connection = pg.connect(user = env_variables.DB.user,
                                password = env_variables.DB.password,
                                host = env_variables.DB.host,
                                port = env_variables.DB.port,
                                )

    return connection

def get_player_ratings(name):
    try: 
        conn = connect(os.environ.get('POSTGRES_DB'))
        conn.set_isolation_level(ISOLATION_LEVEL_AUTOCOMMIT)
        cur = conn.cursor()
        
        cur.execute("SELECT * FROM player_ratings WHERE player_name = %s;", (name,))
        row = cur.fetchone()
        if row:
            return f"Ratings for player: {name} </br> Global: {row[1]} </br> Top: {row[2]} </br> Jungle: {row[3]} </br> Mid: {row[4]} </br> Bottom: {row[5]} </br> Support: {row[6]}"
        else:
            return "No player with name " + name

    except Exception as e:
        raise e
    finally:
        if conn:
            cur.close()
            conn.close()

app = flask.Flask(__name__)
app.config["DEBUG"] = True

@app.route("/", methods=["GET"])
def home():
    return "Big Enjoy Customs API"

@app.route("/player/<name>", methods=["GET"])
def getPlayer(name):
    return "Player name is: " + name

@app.route("/player-ratings/<name>", methods=["GET"])
def getPlayerRatings(name):
    return get_player_ratings(name) 

app.run(host='0.0.0.0')
