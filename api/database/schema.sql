/* CREATE DATABASE big_enjoy_customs; */

DROP TYPE IF EXISTS game_role CASCADE;
CREATE TYPE game_role AS ENUM ('TOP', 'JUNGLE', 'MIDDLE', 'BOTTOM', 'SUPPORT');

DROP TYPE IF EXISTS game_side CASCADE;
CREATE TYPE game_side as ENUM ('BLUE', 'RED');

/* Create tables */
DROP TABLE IF EXISTS players CASCADE;
CREATE TABLE players (
    riot_player_id VARCHAR(56) NOT NULL,
    player_name VARCHAR(16) UNIQUE NOT NULL,
    PRIMARY KEY (player_name),
    UNIQUE (riot_player_id)
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
    PRIMARY KEY (player_name),
    FOREIGN KEY (player_name) REFERENCES players (player_name) ON UPDATE CASCADE
);

DROP TABLE IF EXISTS player_role_preferences CASCADE;
CREATE TABLE player_role_preferences (
    player_name VARCHAR(16),
    "top"   SMALLINT NOT NULL,
    jungle  SMALLINT NOT NULL,
    middle  SMALLINT NOT NULL,
    bottom  SMALLINT NOT NULL,
    support SMALLINT NOT NULL,
    PRIMARY KEY (player_name),
    FOREIGN KEY (player_name) REFERENCES players (player_name) ON UPDATE CASCADE,
    CHECK ("top" BETWEEN 0 and 10),
    CHECK (jungle BETWEEN 0 and 10),
    CHECK (middle BETWEEN 0 and 10),
    CHECK (bottom BETWEEN 0 and 10),
    CHECK (support BETWEEN 0 and 10)
);

DROP TABLE IF EXISTS games CASCADE;
CREATE TABLE games (
    riot_game_id BIGINT NOT NULL,
    game_duration INT NOT NULL,
    game_version VARCHAR(50) NOT NULL,
    game_date BIGINT NOT NULL,
    winner game_side NOT NULL,
    first_tower game_side NOT NULL,
    first_inhibitor game_side NOT NULL,
    first_dragon game_side NOT NULL,
    first_baron game_side NOT NULL,
    first_rift_herald game_side NOT NULL,
    PRIMARY KEY (riot_game_id)
);

DROP TABLE IF EXISTS game_team_stats CASCADE;
CREATE TABLE game_team_stats (
    game_id BIGINT NOT NULL,
    side game_side NOT NULL,
    tower_kills INT NOT NULL,
    inhibitor_kills INT NOT NULL,
    dragon_kills INT NOT NULL,
    baron_kills INT NOT NULL,
    rift_herald_kills INT NOT NULL,
    FOREIGN KEY (game_id) REFERENCES games (riot_game_id),
    PRIMARY KEY (game_id, side)
);

DROP TABLE IF EXISTS game_bans CASCADE;
CREATE TABLE game_bans (
    game_id BIGINT NOT NULL,
    side game_side NOT NULL,
    champion_id INT NOT NULL,
    pick_turn INT NOT NULL,
    CHECK (pick_turn BETWEEN 1 and 5),
    FOREIGN KEY (game_id) REFERENCES games (riot_game_id),
    PRIMARY KEY (game_id, side, pick_turn)
);


DROP TABLE IF EXISTS game_participants CASCADE;
CREATE TABLE game_participants (
    game_id BIGINT NOT NULL,
    player_name VARCHAR(16) NOT NULL,
    "role" game_role NOT NULL,
    side game_side NOT NULL,
    champion_id INT NOT NULL,
    spell1_id INT NOT NULL,
    spell2_id INT NOT NULL,
    item0 INT NOT NULL,
    item1 INT NOT NULL,
    item2 INT NOT NULL,
    item3 INT NOT NULL,
    item4 INT NOT NULL,
    item5 INT NOT NULL,
    item6 INT NOT NULL,
    kills INT NOT NULL,
    deaths INT NOT NULL,
    assists INT NOT NULL,
    longest_time_alive INT NOT NULL,
    largest_killing_spree INT NOT NULL,
    largest_multi_kill INT NOT NULL,
    killing_sprees INT NOT NULL,
    double_kills INT NOT NULL,
    triple_kills INT NOT NULL,
    quadra_kills INT NOT NULL,
    penta_kills INT NOT NULL,
    total_damage_dealt INT NOT NULL,
    magic_damage_dealt INT NOT NULL,
    physical_damage_dealt INT NOT NULL,
    true_damage_dealt INT NOT NULL,
    largest_critical_strike INT NOT NULL,
    total_damage_to_champs INT NOT NULL,
    magic_damage_to_champs INT NOT NULL,
    physical_damage_to_champs INT NOT NULL,
    true_damage_to_champs INT NOT NULL,
    damage_dealt_to_objectives INT NOT NULL,
    damage_dealt_to_turrets INT NOT NULL,
    total_heal INT NOT NULL,
    total_units_healed INT NOT NULL,
    damage_self_mitigated INT NOT NULL,
    time_ccing_others INT NOT NULL,
    total_damage_taken INT NOT NULL,
    magic_damage_taken INT NOT NULL,
    physical_damage_taken INT NOT NULL,
    true_damage_taken INT NOT NULL,
    gold_earned INT NOT NULL,
    gold_spent INT NOT NULL,
    turret_kills INT NOT NULL,
    inhibitor_kills INT NOT NULL,
    total_minions_killed INT NOT NULL,
    neutral_minions_killed INT NOT NULL,
    neutral_minions_killed_team_jungle INT NOT NULL,
    neutral_minions_killed_enemy_jungle INT NOT NULL,
    total_time_crowd_control_dealt INT NOT NULL,
    champion_level INT NOT NULL,
    vision_score INT NOT NULL,
    vision_wards_bought INT NOT NULL,
    wards_placed INT NOT NULL,
    wards_killed INT NOT NULL,
    first_blood_kill BOOLEAN NOT NULL,
    first_blood_assist BOOLEAN NOT NULL,
    first_tower_kill BOOLEAN NOT NULL,
    first_tower_assist BOOLEAN NOT NULL,
    first_inhibitor_kill BOOLEAN NOT NULL,
    first_inhibitor_assist BOOLEAN NOT NULL,
    perk0 INT NOT NULL,
    perk0_var1 INT NOT NULL,
    perk0_var2 INT NOT NULL,
    perk0_var3 INT NOT NULL,
    perk1 INT NOT NULL,
    perk1_var1 INT NOT NULL,
    perk1_var2 INT NOT NULL,
    perk1_var3 INT NOT NULL,
    perk2 INT NOT NULL,
    perk2_var1 INT NOT NULL,
    perk2_var2 INT NOT NULL,
    perk2_var3 INT NOT NULL,
    perk3 INT NOT NULL,
    perk3_var1 INT NOT NULL,
    perk3_var2 INT NOT NULL,
    perk3_var3 INT NOT NULL,
    perk4 INT NOT NULL,
    perk4_var1 INT NOT NULL,
    perk4_var2 INT NOT NULL,
    perk4_var3 INT NOT NULL,
    perk5 INT NOT NULL,
    perk5_var1 INT NOT NULL,
    perk5_var2 INT NOT NULL,
    perk5_var3 INT NOT NULL,
    perk_primary_style INT NOT NULL,
    perk_sub_style INT NOT NULL,
    stat_perk0 INT NOT NULL,
    stat_perk1 INT NOT NULL,
    stat_perk2 INT NOT NULL,
    FOREIGN KEY (game_id) REFERENCES games (riot_game_id),
    FOREIGN KEY (player_name) REFERENCES players (player_name) ON UPDATE CASCADE,
    UNIQUE (game_id, player_name), /* One player per game id */
    UNIQUE (game_id, "role", side) /* Ensures 1 role per side to make sure 10 players per game id */
);