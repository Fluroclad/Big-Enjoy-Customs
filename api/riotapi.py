import urllib.request, json
import os

riotAPI = "https://euw1.api.riotgames.com/"

def getMatch(id):
    matchAPI = "/lol/match/v4/matches/" + str(id)

    with urllib.request.urlopen(riotAPI + matchAPI + "?api_key=" + os.environ.get('RIOTAPI_TOKEN')) as url:
        data = json.loads(url.read().decode())
    
    return data

def getAccountID(summoner_name):
    playerAPI = "/lol/summoner/v4/summoners/by-name/" + summoner_name.replace(" ", "+")

    with urllib.request.urlopen(riotAPI + playerAPI + "?api_key=" + os.environ.get('RIOTAPI_TOKEN')) as url:
        data = json.loads(url.read().decode())
    return data["accountId"]
