import urllib.request, json

# TEMP
import env_variables


riotAPI = "https://euw1.api.riotgames.com/"

def getMatch(id):
    matchAPI = "/lol/match/v4/matches/" + str(id)

    with urllib.request.urlopen(riotAPI + matchAPI + "?api_key=" + env_variables.RiotAPI.token) as url:
        data = json.loads(url.read().decode())
    
    return data

def getAccountID(summoner_name):
    playerAPI = "/lol/summoner/v4/summoners/by-name/" + summoner_name.replace(" ", "+")

    with urllib.request.urlopen(riotAPI + playerAPI + "?api_key=" + env_variables.RiotAPI.token) as url:
        data = json.loads(url.read().decode())
    return data["accountId"]