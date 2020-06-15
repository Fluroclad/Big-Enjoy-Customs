import flask
from flask import request
import database

app = flask.Flask(__name__)
app.config["DEBUG"] = True

@app.route("/", methods=["GET"])
def home():
    return "Big Enjoy Customs API"

@app.route("/player/<name>", methods=["GET"])
def getPlayer(name):
    return "Player name is: " + name

@app.route("/player/add", methods=["POST"])
def addPlayer():
    json_data = request.get_json()

    result = database.addPlayer(json_data)
    
    if result == True:
        return flask.Response(status=201)
    else:
        return flask.Response(status=400)

@app.route("/match/add", methods=["POST"])
def addMatch():
    json_data = request.get_json()

    result = database.addMatch(json_data)
    
    if result == True:
        return flask.Response(status=201)
    else:
        return flask.Response(status=400)

app.run(host='0.0.0.0', port=81)
