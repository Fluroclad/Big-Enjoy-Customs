import flask
from flask import render_template
from flask import request
import json
import requests

app = flask.Flask(__name__)
app.config["DEBUG"] = True

@app.route("/", methods=["GET"])
def home():
    return "Big Enjoy Customs Web App"

@app.route("/player/<name>", methods=["GET"])
def getPlayer(name):
    return "Player name is: " + name

@app.route("/add-player", methods=["GET","POST"])
def addPlayer():
    if request.method == "GET":
        return render_template("add-player.html", title="Add Player")
    elif request.method == "POST":
        json_data = {}
        json_data["player_name"] = request.form.get("player_name")
        
        json_data["preferences"] = {}
        json_data["preferences"]["top"] = request.form.get("top_preference")
        json_data["preferences"]["jungle"] = request.form.get("jungle_preference")
        json_data["preferences"]["middle"] = request.form.get("middle_preference")
        json_data["preferences"]["bottom"] = request.form.get("bottom_preference")
        json_data["preferences"]["support"] = request.form.get("support_preference")

        requests.post("http://localhost:81/player/add", json = json_data)
        return render_template("test-json.html", data = json_data)

@app.route("/add-match", methods=["GET","POST"])
def addMatch():
    if request.method == "GET":
        return render_template("add-match.html", title="Add Match")
    elif request.method == "POST":
        json_data = {}
        json_data["match_id"] = int(request.form.get("match_id"))
        players = []

        for x in range(1,11):
            player_list = {}
            player_name = "player" + str(x)
            role_name = "role" + str(x)

            player_list["player_name"] = request.form.get(player_name)
            player_list["role"] = request.form.get(role_name)

            players.append(player_list)

        json_data["players"] = players

        requests.post("http://localhost:81/match/add", json = json_data)
        return render_template("test-json.html", data = json_data)

app.run(host="0.0.0.0", port=80)
