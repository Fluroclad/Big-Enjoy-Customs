import urllib.request, json, env_variables

riotAPI = "https://euw1.api.riotgames.com/"

def getMatch(id):
    matchAPI = "/lol/match/v4/matches/" + str(id)

    
    with urllib.request.urlopen(riotAPI + matchAPI + "?api_key=" + env_variables.RiotAPI.token) as url:
        data = json.loads(url.read().decode())
    
    return data

print(getMatch(4639995139))