/* CREATE DATABASE big_enjoy_customs; */

/* Create tables */
DROP TABLE IF EXISTS players CASCADE;
CREATE TABLE players (
    player_name VARCHAR(16) UNIQUE NOT NULL,
    PRIMARY KEY (player_name)
);

DROP TABLE IF EXISTS player_ratings CASCADE;
CREATE TABLE player_ratings (
    player_name VARCHAR(16) NOT NULL,
    "global"    SMALLINT NOT NULL,
    "top"       SMALLINT NOT NULL,
    jungle      SMALLINT NOT NULL,
    middle      SMALLINT NOT NULL,
    bottom      SMALLINT NOT NULL,
    support     SMALLINT NOT NULL,
    FOREIGN KEY (player_name) REFERENCES players (player_name)
);

DROP TABLE IF EXISTS player_role_preferences CASCADE;
CREATE TABLE player_role_preferences (
    player_name VARCHAR(16),
    "top"   SMALLINT NOT NULL,
    jungle  SMALLINT NOT NULL,
    middle  SMALLINT NOT NULL,
    bottom  SMALLINT NOT NULL,
    support SMALLINT NOT NULL,
    FOREIGN KEY (player_name) REFERENCES players (player_name)
);

DROP TABLE IF EXISTS games CASCADE;
CREATE TABLE games (
    riot_game_id BIGINT NOT NULL,
    game_duration BIGINT NOT NULL,
    game_version VARCHAR(50) NOT NULL
)