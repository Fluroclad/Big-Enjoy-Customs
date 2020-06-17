import json
import flask
from flask import request, g

import database
from database import Database

import env_variables

app = flask.Flask(__name__)
app.config["DEBUG"] = True

@app.before_request
def before_request():
    if "db" not in g:
        g.db = Database()

        g.db.connect(env_variables.DB.user,
                    env_variables.DB.password,
                    env_variables.DB.host,
                    env_variables.DB.port,
                    env_variables.DB.name)
        g.db.set_cursor(True)

@app.after_request
def after_request(response):
    g.db.exit()

    return response

@app.route("/", methods=["GET"])
def home():
    return "Big Enjoy Customs API"

@app.route("/player", methods=["POST"])
def add_player():
    json_data = request.get_json()
    
    # Validate JSON POST
    #validate.add_player(json_data)

    result = g.db.add_player(json_data)

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

@app.route("/player/<name>", methods=["GET"])
def get_player(name):
    result = g.db.get_player(name)

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

@app.route("/match", methods=["POST"])
def add_match():
    json_data = request.get_json()
    result = g.db.add_match(json_data)
    
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
