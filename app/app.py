import flask, json, requests
from flask import render_template
from flask import request

# TEMP
import env_variables

app = flask.Flask(__name__)
app.config["DEBUG"] = True

@app.route("/", methods=["GET"])
def home():
    return "Big Enjoy Customs Web App"

@app.route("/player/<name>", methods=["GET"])
def getPlayer(name):
    r = requests.get(env_variables.apiURL + "/player/" + name)

    if r.status_code == 200:
        return render_template("test-json.html", data = r.json())
    elif r.status_code == 404:
        return render_template("test-json.html", data = r)

@app.route("/add-player", methods=["GET","POST"])
def addPlayer():
    if request.method == "GET":
        return render_template("add-player.html", title="Add Player")
    elif request.method == "POST":
        json_data = {}
        json_data["player_name"] = request.form.get("player_name")
        json_data["summoner_name"] = request.form.get("summoner_name")
        
        json_data["preferences"] = {}
        json_data["preferences"]["top"]     = request.form.get("top_preference")
        json_data["preferences"]["jungle"]  = request.form.get("jungle_preference")
        json_data["preferences"]["middle"]  = request.form.get("middle_preference")
        json_data["preferences"]["bottom"]  = request.form.get("bottom_preference")
        json_data["preferences"]["support"] = request.form.get("support_preference")

        json_data["ratings"] = {}
        json_data["ratings"]["global"]  = 1000
        json_data["ratings"]["top"]     = 1100
        json_data["ratings"]["jungle"]  = 1200
        json_data["ratings"]["middle"]  = 1300
        json_data["ratings"]["bottom"]  = 1400
        json_data["ratings"]["support"] = 1500

        requests.post(env_variables.apiURL + "/player", json = json_data)
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

        requests.post(env_variables.apiURL + "/match", json = json_data)
        return render_template("test-json.html", data = json_data)

app.run(host="0.0.0.0", port=80)
