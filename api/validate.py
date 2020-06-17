from typing import Dict
from pydantic import BaseModel, ValidationError, validator

import database
import riotapi


# TODO: Change preferences and ratings to TypedDict when Pydantic adds suppport.
class Player(BaseModel):
    player_name: str = ...
    summoner_name: str = ...
    preferences: Dict[str, int]
    ratings: Dict[str, int]

    @validator("player_name", "summoner_name")
    def check_player_name(cls, v):
        if len(v.strip()) == 0:
            raise ValueError("must not be empty.")
        return v

    @validator("player_name")
    def player_name_exists(cls, v):
        return v

    @validator("summoner_name")
    def summoner_name_exists(cls, v):
        return v

preference = {}
preference["top"]     = "0"
preference["jungle"]  = "1"
preference["middle"]  = "2"
preference["bottom"]  = "3"
preference["support"] = "4"

rating = {}
rating["top"]     = 1100
rating["jungle"]  = 1200
rating["middle"]  = 1300
rating["bottom"]  = 1400
rating["support"] = 1500

try:
    player = Player(player_name="", summoner_name = "",
        preferences = preference, ratings = rating)
except ValidationError as e:
    print(e.errors())

