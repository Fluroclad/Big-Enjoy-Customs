import json
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
    result = database.getPlayer(name)
    
    # Check result has data in it
    if bool(result):
        status = 200
    else:
        status = 404
        result = {}
        result["error_msg"] = "Player not found!"
        result["status_code"] = status
        result = json.dumps(result)

    return app.response_class(response = result,
                                status = status,
                                mimetype = "application/json")

@app.route("/player/add", methods=["POST"])
def addPlayer():
    json_data = request.get_json()
    
    # Validate JSON POST
    #validate.add_player(json_data)

    result = database.addPlayer(json_data)

    if result == True:
        status = 201
        message = {}
        message["status_code"] = status
    else:
        status = 409
        message = {}
        message["status_code"] = status
        message["error"] = "Bad request"

    return app.response_class(response = message,
                                status = status,
                                mimetype = "application/json")

@app.route("/match/add", methods=["POST"])
def addMatch():
    json_data = request.get_json()
    result = database.addMatch(json_data)
    
    if result == True:
        status = 201
        message = {}
        message["status_code"] = status
    else:
        status = 409
        message = {}
        message["status_code"] = status
        message["error"] = "Bad request"
    
    return app.response_class(response = message,
                                status = status,
                                mimetype = "application/json")

app.run(host='0.0.0.0', port=81)
