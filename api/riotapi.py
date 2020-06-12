import urllib.request, json, apiKey

riotAPI = "https://euw1.api.riotgames.com/"

def getMatch(id):
    matchAPI = "/lol/match/v4/matches/" + str(id)

    
    with urllib.request.urlopen(riotAPI + matchAPI + "?api_key=" + apiKey.token) as url:
        data = json.loads(url.read().decode())
    
    return data

print(getMatch(4639995139))