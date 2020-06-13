import flask

app = flask.Flask(__name__)
app.config["DEBUG"] = True

@app.route("/", methods=["GET"])
def home():
    return "Big Enjoy Web App"

@app.route("/player/<name>", methods=["GET"])
def getPlayer(name):
    return "Player name is: " + name


app.run(host='0.0.0.0')
