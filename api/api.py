import flask

app = flask.Flask(__name__)
app.config["DEBUG"] = True

@app.route('/', methods=["GET"])
def home():
    return "Big Enjoy Customs API"

app.run()
