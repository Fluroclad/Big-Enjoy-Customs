import requests, json

# TEMP
import env_variables


riotAPI = "https://euw1.api.riotgames.com/"

def getMatch(id = "4639995139"):
    matchAPI = "/lol/match/v4/matches/" + str(id)
    r = requests.get(riotAPI + matchAPI, headers = riotApiHeader())

    return r

def getAccount(summoner_name = "Fluroclad"):
    playerAPI = "/lol/summoner/v4/summoners/by-name/" + summoner_name.replace(" ", "+")
    r = requests.get(riotAPI + playerAPI, headers = riotApiHeader())

    return r

def riotApiHeader():
    headers = {}
    headers["X-Riot-Token"] = env_variables.RiotAPI.token

    return headers