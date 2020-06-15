import flask
from flask import request
import database
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
        connection = pg.connect(user = os.environ.get('POSTGRES_USER'),
                                password = os.environ.get('POSTGRES_PASSWORD'),
                                host = os.environ.get('POSTGRES_HOST'),
                                port = os.environ.get('POSTGRES_PORT'),
                                )

    return connection

app = flask.Flask(__name__)
app.config["DEBUG"] = True

@app.route("/", methods=["GET"])
def home():
    return "Big Enjoy Customs API"

@app.route("/player/<name>", methods=["GET"])
def getPlayer(name):
    result = database.getPlayer(name)

    if bool(result):
        response = app.response_class(response=result,
                                  status=200,
                                  mimetype='application/json')
        return response
    else:
        return flask.Response(status=400)

@app.route("/player/add", methods=["POST"])
def addPlayer():
    json_data = request.get_json()
    
    result = database.addPlayer(json_data)
    
    if result == True:
        return flask.Response(status=200)
    else:
        return flask.Response(status=400)

@app.route("/match/add", methods=["POST"])
def addMatch():
    json_data = request.get_json()

    result = database.addMatch(json_data)
    
    if result == True:
        return flask.Response(status=200)
    else:
        return flask.Response(status=400)

app.run(host='0.0.0.0')
