/* CREATE DATABASE big_enjoy_customs; */

DROP TYPE IF EXISTS game_role CASCADE;
CREATE TYPE game_role AS ENUM ('TOP', 'JUNGLE', 'MIDDLE', 'BOTTOM', 'SUPPORT');

DROP TYPE IF EXISTS game_side CASCADE;
CREATE TYPE game_side as ENUM ('BLUE', 'RED');

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
    FOREIGN KEY (game_id) REFERENCES games (riot_game_id) ON UPDATE CASCADE,
    PRIMARY KEY (game_id, side)
);

DROP TABLE IF EXISTS game_bans CASCADE;
CREATE TABLE game_bans (
    game_id BIGINT NOT NULL,
    side game_side NOT NULL,
    champion_id INT NOT NULL,
    pick_turn INT NOT NULL,
    CHECK (pick_turn BETWEEN 1 and 5),
    FOREIGN KEY (game_id) REFERENCES games (riot_game_id) ON UPDATE CASCADE,
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
    largest_killing_spree INT NOT NULL,
    largest_multi_kill INT NOT NULL,
    killing_sprees INT NOT NULL,
    longest_time_alive INT NOT NULL,
    double_kills INT NOT NULL,
    triple_kills INT NOT NULL,
    quadra_kills INT NOT NULL,
    penta_kills INT NOT NULL,
    total_damage_dealt INT NOT NULL,
    magic_damage_dealt INT NOT NULL,
    physical_damage_dealt INT NOT NULL,
    true_damage_dealt INT NOT NULL,
    largest_critical_strike INT NOT NULL,
    total_damage_to_champions INT NOT NULL,
    magic_damage_to_champions INT NOT NULL,
    physical_damage_to_champions INT NOT NULL,
    true_damage_to_champs INT NOT NULL,
    total_heal INT NOT NULL,
    total_units_healed INT NOT NULL,
    damage_self_mitigated INT NOT NULL,
    damage_dealt_to_objectives INT NOT NULL,
    damage_dealt_to_turrets INT NOT NULL,
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
    UNIQUE (game_id, player_name), /* One player per game id */
    UNIQUE ("role", side) /* Ensures 1 role per side to make sure 10 players per game id */
);

/* FUNCTIONS */
CREATE OR REPLACE FUNCTION add_player(  p_name varchar(16),
                                        r_pref_top INT,
                                        r_pref_jungle INT,
                                        r_pref_middle INT,
                                        r_pref_bottom INT,
                                        r_pref_support INT)
RETURNS VOID AS
$$
BEGIN
    INSERT INTO players (player_name)
    VALUES (p_name);

    INSERT INTO player_role_preferences (player_name, "top", jungle, middle, bottom, support)
    VALUES (p_name, r_pref_top, r_pref_jungle, r_pref_middle, r_pref_bottom, r_pref_support);
END
$$
LANGUAGE 'plpgsql';

/* Work out whether Blue or Red side got particular objectives */
CREATE OR REPLACE FUNCTION side(riot JSON, field TEXT)
RETURNS game_side AS $$
DECLARE
    array_field TEXT;
BEGIN
    array_field := '{teams,0,' || field || '}';
    
    IF field = 'win' THEN
        IF (riot#>>'{teams,0,teamId}')::INT = 100 AND riot#>>array_field::TEXT[] = 'Win' THEN
            RETURN 'BLUE'::game_side;
        ELSE
            RETURN 'RED'::game_side;
        END IF;
    END IF;

    IF (riot#>>'{teams,0,teamId}')::INT = 100 AND (riot#>>array_field::TEXT[])::BOOLEAN = TRUE THEN
        RETURN 'BLUE'::game_side;
    ELSE
        RETURN 'RED'::game_side;
    END IF;
END;
$$
LANGUAGE 'plpgsql';

/* Return blue or red game_side */
CREATE OR REPLACE FUNCTION side(team_id INT)
RETURNS game_side AS $$
BEGIN
    IF team_id = 100 THEN
        RETURN 'BLUE'::game_side;
    ELSE
        RETURN 'RED'::game_side;
    END IF;
END;
$$
LANGUAGE 'plpgsql';

/* Add game team stats */
CREATE OR REPLACE FUNCTION add_game_team_stats(riot JSON)
RETURNS VOID AS $$
DECLARE
    l_counter INT := 0;
    m_field TEXT;
    m_team TEXT;
    m_side game_side;
    m_tower TEXT;
    m_inhibitor TEXT;
    m_dragon TEXT;
    m_baron TEXT;
    m_herald TEXT;
BEGIN
    LOOP
        EXIT WHEN l_counter = 2;
        
        m_field := '{teams,' || l_counter::TEXT || ',';
        m_tower     := m_field || 'towerKills}';
        m_inhibitor := m_field || 'inhibitorKills}';
        m_dragon    := m_field || 'dragonKills}';
        m_baron     := m_field || 'baronKills}';
        m_herald    := m_field || 'riftHeraldKills}';
        m_team      := m_field || 'teamId}';

        /* get team side */
        SELECT side((riot#>>m_team::TEXT[])::INT) INTO m_side;

        INSERT INTO game_team_stats (game_id, side, tower_kills, inhibitor_kills, dragon_kills, baron_kills, rift_herald_kills)
        VALUES ((riot->>'gameId')::BIGINT,
                m_side,
                (riot#>>m_tower::TEXT[])::INT,
                (riot#>>m_inhibitor::TEXT[])::INT,
                (riot#>>m_dragon::TEXT[])::INT,
                (riot#>>m_baron::TEXT[])::INT,
                (riot#>>m_herald::TEXT[])::INT);
        

        l_counter := l_counter + 1;
    END LOOP;
END
$$
LANGUAGE 'plpgsql';

/* Add game bans */
CREATE OR REPLACE FUNCTION add_game_bans(riot JSON)
RETURNS void AS $$
DECLARE
    l_team_counter INT := 0;
    l_ban_counter INT := 0;
    m_field TEXT;
    m_team TEXT;
    m_side game_side;
    m_ban TEXT;
    m_champ TEXT;
    m_pick TEXT;
BEGIN
    LOOP 
        EXIT WHEN l_team_counter = 2;

        m_field := '{teams,' || l_team_counter::TEXT || ',';
        m_team  := m_field || 'teamId}';
        SELECT side((riot#>>m_team::TEXT[])::INT) INTO m_side;
        
        /* Reset counter for second team */
        l_ban_counter := 0;

        /* Banned champs loop */
        LOOP
            EXIT WHEN l_ban_counter = 5;
            m_ban   := m_field || 'bans,' || l_ban_counter || ',';
            m_champ := m_ban || 'championId}';
            m_pick  := m_ban || 'pickTurn}';


            /* Cause team 2 has pickorder 6 instead of 5 account for this and fix it */
            IF (riot#>>m_pick::TEXT[])::INT = 5 OR (riot#>>m_pick::TEXT[])::INT = 6 THEN
                INSERT INTO game_bans (game_id, side, champion_id, pick_turn)
                VALUES ((riot->>'gameId')::BIGINT,
                        m_side,
                        (riot#>>m_champ::TEXT[])::INT,
                        5);
            ELSE
                INSERT INTO game_bans (game_id, side, champion_id, pick_turn)
                VALUES ((riot->>'gameId')::BIGINT,
                        m_side,
                        (riot#>>m_champ::TEXT[])::INT,
                        (riot#>>m_pick::TEXT[])::INT);
            END IF;
            
            
            l_ban_counter := l_ban_counter + 1;
        END LOOP;

        l_team_counter := l_team_counter + 1;
    END LOOP;
END;
$$
LANGUAGE 'plpgsql';

/* Add game participant */
CREATE OR REPLACE FUNCTION add_game_participants(riot JSON, players TEXT[10])
RETURNS VOID AS $$
DECLARE
    l_player_counter INT := 0;
    m_field TEXT;
    m_team TEXT;
    m_side game_side;
BEGIN
    LOOP
        EXIT WHEN l_player_counter = 10;
        
        m_field := '{teams,' || l_team_counter::TEXT || ',';
        m_team  := m_field || 'teamId}';
        SELECT side((riot#>>m_team::TEXT[])::INT) INTO m_side;

            


        l_player_counter := l_player_counter + 1;
    END LOOP;
END;
$$
LANGUAGE 'plpgsql';

/* Riot Game parser to add to database */
CREATE OR REPLACE FUNCTION add_game(riot JSON)
RETURNS VOID AS $$
DECLARE
    m_winner    game_side;
    m_blood     game_side;
    m_tower     game_side;
    m_inhibitor game_side;
    m_dragon    game_side;
    m_baron     game_side;
    m_herald    game_side;
BEGIN
    /* Work out side first objectives */
    SELECT side(riot, 'win') INTO m_winner;
    SELECT side(riot, 'firstTower') INTO m_tower;
    SELECT side(riot, 'firstInhibitor') INTO m_inhibitor;
    SELECT side(riot, 'firstDragon') INTO m_dragon;
    SELECT side(riot, 'firstBaron') INTO m_baron;
    SELECT side(riot, 'firstRiftHerald') INTO m_herald;

    /* Insert initial game */
    INSERT INTO games (riot_game_id, game_duration, game_version, winner, first_tower, first_inhibitor, first_dragon, first_baron, first_rift_herald)
    VALUES ((riot->>'gameId')::BIGINT, (riot->>'gameDuration')::INT, riot->>'gameVersion', m_winner, m_tower, m_inhibitor, m_dragon, m_baron, m_herald);

    /* Insert game team stats */
    EXECUTE add_game_team_stats(riot);

    /* Insert game bans */
    EXECUTE add_game_bans(riot);

    /* Insert game participants */
END;
$$
LANGUAGE 'plpgsql';