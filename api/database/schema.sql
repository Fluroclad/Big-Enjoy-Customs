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
    UNIQUE ("role", side) /* Ensures 1 role per side to make sure 10 players per game id */
);

/* FUNCTIONS */
CREATE OR REPLACE FUNCTION get_player(player TEXT)
RETURNS TABLE (player_name VARCHAR,
                pref_top SMALLINT,
                pref_jungle SMALLINT,
                pref_middle SMALLINT,
                pref_bottom SMALLINT,
                pref_support SMALLINT,
                rating_global SMALLINT,
                rating_top SMALLINT,
                rating_jungle SMALLINT,
                rating_middle SMALLINT,
                rating_bottom SMALLINT,
                rating_support SMALLINT) AS
$$
BEGIN
    RETURN QUERY
    SELECT  players.player_name,
            player_role_preferences.top,
            player_role_preferences.jungle,
            player_role_preferences.middle,
            player_role_preferences.bottom,
            player_role_preferences.support,
            player_ratings.global,
            player_ratings.top,
            player_ratings.jungle,
            player_ratings.middle,
            player_ratings.bottom,
            player_ratings.support
    FROM players
    INNER JOIN player_role_preferences ON players.player_name=player_role_preferences.player_name
    INNER JOIN player_ratings ON players.player_name=player_ratings.player_name
    WHERE players.player_name = player;
END
$$
LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION add_player(player JSON)
RETURNS VOID AS
$$
BEGIN
    INSERT INTO players (player_name)
    VALUES ((player->>'player_name')::TEXT);

    INSERT INTO player_role_preferences (player_name, "top", jungle, middle, bottom, support)
    VALUES ((player->>'player_name')::TEXT,
            (player#>>'{preferences,top}'::TEXT[])::INT,
            (player#>>'{preferences,jungle}'::TEXT[])::INT,
            (player#>>'{preferences,middle}'::TEXT[])::INT,
            (player#>>'{preferences,bottom}'::TEXT[])::INT,
            (player#>>'{preferences,support}'::TEXT[])::INT);
    
    INSERT INTO player_ratings (player_name, "global", "top", jungle, middle, bottom, support)
    VALUES ((player->>'player_name')::TEXT,
            (player#>>'{ratings,global}'::TEXT[])::INT,
            (player#>>'{ratings,top}'::TEXT[])::INT,
            (player#>>'{ratings,jungle}'::TEXT[])::INT,
            (player#>>'{ratings,middle}'::TEXT[])::INT,
            (player#>>'{ratings,bottom}'::TEXT[])::INT,
            (player#>>'{ratings,support}'::TEXT[])::INT);
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
CREATE OR REPLACE FUNCTION add_game_participants(riot JSON, players JSON)
RETURNS VOID AS $$
DECLARE
    l_player_counter INT := 0;
    m_field TEXT;
    m_player TEXT;
    m_player_name TEXT;
    m_player_role TEXT;
    m_stats TEXT;
    m_team TEXT;
    m_side game_side;

    m_champ TEXT;
    m_spell1 TEXT;
    m_spell2 TEXT;

    m_item0 TEXT;
    m_item1 TEXT;
    m_item2 TEXT;
    m_item3 TEXT;
    m_item4 TEXT;
    m_item5 TEXT;
    m_item6 TEXT;

    m_kills TEXT;
    m_deaths TEXT;
    m_assists TEXT;
    m_longest_time_alive TEXT;
    m_largest_killing_spree TEXT;
    m_multi_kill TEXT;
    m_killing_sprees TEXT;
    m_double TEXT;
    m_triple TEXT;
    m_quadra TEXT;
    m_penta TEXT;

    m_total_damage_dealt TEXT;
    m_magic_damage_dealt TEXT;
    m_physical_damage_dealt TEXT;
    m_true_damage_dealt TEXT;
    m_largest_critical_strike TEXT;
    m_total_damage_to_champs TEXT;
    m_magic_damage_to_champs TEXT;
    m_physical_damage_to_champs TEXT;
    m_true_damage_to_champs TEXT;

    m_damage_dealt_to_objectives TEXT;
    m_damage_dealt_to_turrets TEXT;
    m_total_heal TEXT;
    m_total_units_healed TEXT;
    m_damage_self_mitigated TEXT;
    m_time_ccing_others TEXT;
    m_total_damage_taken TEXT;
    m_magic_damage_taken TEXT;
    m_physical_damage_taken TEXT;
    m_true_damage_taken TEXT;
    m_gold_earned TEXT;
    m_gold_spent TEXT;
    
    m_turret_kills TEXT;
    m_inhibitor_kills TEXT;
    m_total_minions_killed TEXT;
    m_neutral_minions_killed TEXT;
    m_neutral_minions_killed_team_jungle TEXT;
    m_neutral_minions_killed_enemy_jungle TEXT;
    m_total_time_crowd_control_dealt TEXT;

    m_champion_level TEXT;
    m_vision_score TEXT;
    m_vision_wards_bought TEXT;
    m_wards_placed TEXT;
    m_wards_killed TEXT;

    m_first_blood_kill TEXT;
    m_first_blood_assist TEXT;
    m_first_tower_kill TEXT;
    m_first_tower_assist TEXT;
    m_first_inhibitor_kill TEXT;
    m_first_inhibitor_assist TEXT;

    m_perk0 TEXT;
    m_perk0_var1 TEXT;
    m_perk0_var2 TEXT;
    m_perk0_var3 TEXT;
    m_perk1 TEXT;
    m_perk1_var1 TEXT;
    m_perk1_var2 TEXT;
    m_perk1_var3 TEXT;
    m_perk2 TEXT;
    m_perk2_var1 TEXT;
    m_perk2_var2 TEXT;
    m_perk2_var3 TEXT;
    m_perk3 TEXT;
    m_perk3_var1 TEXT;
    m_perk3_var2 TEXT;
    m_perk3_var3 TEXT;
    m_perk4 TEXT;
    m_perk4_var1 TEXT;
    m_perk4_var2 TEXT;
    m_perk4_var3 TEXT;
    m_perk5 TEXT;
    m_perk5_var1 TEXT;
    m_perk5_var2 TEXT;
    m_perk5_var3 TEXT;
    m_perk_primary_style TEXT;
    m_perk_sub_style TEXT;
    m_stat_perk0 TEXT;
    m_stat_perk1 TEXT;
    m_stat_perk2 TEXT;

BEGIN
    LOOP
        EXIT WHEN l_player_counter = 10;
        
        m_field         := '{participants,' || l_player_counter::TEXT || ',';
        m_stats         := m_field || 'stats,';
        m_team          := m_field || 'teamId}';

        m_player        := '{players,' || l_player_counter::TEXT || ',';
        m_player_name   := m_player || 'player_name}';
        m_player_role   := m_player || 'role}';

        SELECT side((riot#>>m_team::TEXT[])::INT) INTO m_side;

        m_champ     := m_field || 'championId}';
        m_spell1    := m_field || 'spell1Id}';
        m_spell2    := m_field || 'spell2Id}';

        m_item0 := m_stats || 'item0}';
        m_item1 := m_stats || 'item1}';
        m_item2 := m_stats || 'item2}';
        m_item3 := m_stats || 'item3}';
        m_item4 := m_stats || 'item4}';
        m_item5 := m_stats || 'item5}';
        m_item6 := m_stats || 'item6}';

        m_kills     := m_stats || 'kills}';
        m_deaths    := m_stats || 'deaths}';
        m_assists   := m_stats || 'assists}';
        m_longest_time_alive := m_stats || 'longestTimeSpentLiving}';
        m_largest_killing_spree := m_stats || 'largestKillingSpree}';
        m_multi_kill := m_stats || 'largestMultiKill}';
        m_killing_sprees := m_stats || 'killingSprees}';
        m_double := m_stats || 'doubleKills}';
        m_triple := m_stats || 'tripleKills}';
        m_quadra := m_stats || 'quadraKills}';
        m_penta := m_stats || 'pentaKills}';

        m_total_damage_dealt        := m_stats || 'totalDamageDealt}';
        m_magic_damage_dealt        := m_stats || 'magicDamageDealt}';
        m_physical_damage_dealt     := m_stats || 'physicalDamageDealt}';
        m_true_damage_dealt         := m_stats || 'trueDamageDealt}';
        m_largest_critical_strike   := m_stats || 'largestCriticalStrike}';
        m_total_damage_to_champs    := m_stats || 'totalDamageDealtToChampions}';
        m_magic_damage_to_champs    := m_stats || 'magicDamageDealtToChampions}';
        m_physical_damage_to_champs := m_stats || 'physicalDamageDealtToChampions}';
        m_true_damage_to_champs     := m_stats || 'trueDamageDealtToChampions}';

        m_damage_dealt_to_objectives    := m_stats || 'damageDealtToObjectives}';
        m_damage_dealt_to_turrets       := m_stats || 'damageDealtToTurrets}';
        m_total_heal                    := m_stats || 'totalHeal}';
        m_total_units_healed            := m_stats || 'totalUnitsHealed}';
        m_damage_self_mitigated         := m_stats || 'damageSelfMitigated}';
        m_time_ccing_others             := m_stats || 'timeCCingOthers}';
        m_total_damage_taken            := m_stats || 'totalDamageTaken}';
        m_magic_damage_taken            := m_stats || 'magicalDamageTaken}';
        m_physical_damage_taken         := m_stats || 'physicalDamageTaken}';
        m_true_damage_taken             := m_stats || 'trueDamageTaken}';
        m_gold_earned                   := m_stats || 'goldEarned}';
        m_gold_spent                    := m_stats || 'goldSpent}';
        
        m_turret_kills                      := m_stats || 'turretKills}';
        m_inhibitor_kills                   := m_stats || 'inhibitorKills}';
        m_total_minions_killed              := m_stats || 'totalMinionsKilled}';
        m_neutral_minions_killed            := m_stats || 'neutralMinionsKilled}';
        m_neutral_minions_killed_team_jungle := m_stats || 'neutralMinionsKilledTeamJungle}';
        m_neutral_minions_killed_enemy_jungle := m_stats || 'neutralMinionsKilledEnemyJungle}';
        m_total_time_crowd_control_dealt    := m_stats || 'totalTimeCrowdControlDealt}';

        m_champion_level := m_stats || 'champLevel}';
        m_vision_score := m_stats || 'visionScore}';
        m_vision_wards_bought := m_stats || 'visionWardsBoughtInGame}';
        m_wards_placed := m_stats || 'wardsPlaced}';
        m_wards_killed := m_stats || 'wardsKilled}';

        m_first_blood_kill := m_stats || 'firstBloodKill}';
        m_first_blood_assist := m_stats || 'firstBloodAssist}';
        m_first_tower_kill := m_stats || 'firstTowerKill}';
        m_first_tower_assist := m_stats || 'firstTowerAssist}';
        m_first_inhibitor_kill := m_stats || 'firstInhibitorKill}';
        m_first_inhibitor_assist := m_stats || 'firstInhibitorAssist}';

        m_perk0         := m_stats || 'perk0}';
        m_perk0_var1    := m_stats || 'perk0Var1}';
        m_perk0_var2    := m_stats || 'perk0Var2}';
        m_perk0_var3    := m_stats || 'perk0Var3}';
        m_perk1         := m_stats || 'perk0}';
        m_perk1_var1    := m_stats || 'perk1Var1}';
        m_perk1_var2    := m_stats || 'perk1Var2}';
        m_perk1_var3    := m_stats || 'perk1Var3}';
        m_perk2         := m_stats || 'perk2}';
        m_perk2_var1    := m_stats || 'perk2Var1}';
        m_perk2_var2    := m_stats || 'perk2Var2}';
        m_perk2_var3    := m_stats || 'perk2Var3}';
        m_perk3         := m_stats || 'perk3}';
        m_perk3_var1    := m_stats || 'perk3Var1}';
        m_perk3_var2    := m_stats || 'perk3Var2}';
        m_perk3_var3    := m_stats || 'perk3Var3}';
        m_perk4         := m_stats || 'perk4}';
        m_perk4_var1    := m_stats || 'perk4Var1}';
        m_perk4_var2    := m_stats || 'perk4Var2}';
        m_perk4_var3    := m_stats || 'perk4Var3}';
        m_perk5         := m_stats || 'perk5}';
        m_perk5_var1    := m_stats || 'perk5Var1}';
        m_perk5_var2    := m_stats || 'perk5Var2}';
        m_perk5_var3    := m_stats || 'perk5Var3}';
        m_perk_primary_style    := m_stats || 'perkPrimaryStyle}';
        m_perk_sub_style        := m_stats || 'perkSubStyle}';
        m_stat_perk0            := m_stats || 'statPerk0}';
        m_stat_perk1            := m_stats || 'statPerk1}';
        m_stat_perk2            := m_stats || 'statPerk2}';

        INSERT INTO game_participants ( game_id,
                                        player_name,
                                        "role",
                                        side,
                                        champion_id,
                                        spell1_id,
                                        spell2_id,
                                        item0,
                                        item1,
                                        item2,
                                        item3,
                                        item4,
                                        item5,
                                        item6,
                                        kills,
                                        deaths,
                                        assists,
                                        longest_time_alive,
                                        largest_killing_spree,
                                        largest_multi_kill,
                                        killing_sprees,
                                        double_kills,
                                        triple_kills,
                                        quadra_kills,
                                        penta_kills,
                                        total_damage_dealt,
                                        magic_damage_dealt,
                                        physical_damage_dealt,
                                        true_damage_dealt,
                                        largest_critical_strike,
                                        total_damage_to_champs,
                                        magic_damage_to_champs,
                                        physical_damage_to_champs,
                                        true_damage_to_champs,
                                        damage_dealt_to_objectives,
                                        damage_dealt_to_turrets,
                                        total_heal,
                                        total_units_healed,
                                        damage_self_mitigated,
                                        time_ccing_others,
                                        total_damage_taken,
                                        magic_damage_taken,
                                        physical_damage_taken,
                                        true_damage_taken,
                                        gold_earned,
                                        gold_spent,
                                        turret_kills,
                                        inhibitor_kills,
                                        total_minions_killed,
                                        neutral_minions_killed,
                                        neutral_minions_killed_team_jungle,
                                        neutral_minions_killed_enemy_jungle,
                                        total_time_crowd_control_dealt,
                                        champion_level,
                                        vision_score,
                                        vision_wards_bought,
                                        wards_placed,
                                        wards_killed,
                                        first_blood_kill,
                                        first_blood_assist,
                                        first_tower_kill,
                                        first_tower_assist,
                                        first_inhibitor_kill,
                                        first_inhibitor_assist,
                                        perk0,
                                        perk0_var1,
                                        perk0_var2,
                                        perk0_var3,
                                        perk1,
                                        perk1_var1,
                                        perk1_var2,
                                        perk1_var3,
                                        perk2,
                                        perk2_var1,
                                        perk2_var2,
                                        perk2_var3,
                                        perk3,
                                        perk3_var1,
                                        perk3_var2,
                                        perk3_var3,
                                        perk4,
                                        perk4_var1,
                                        perk4_var2,
                                        perk4_var3,
                                        perk5,
                                        perk5_var1,
                                        perk5_var2,
                                        perk5_var3,
                                        perk_primary_style,
                                        perk_sub_style,
                                        stat_perk0,
                                        stat_perk1,
                                        stat_perk2)
        VALUES ((riot->>'gameId')::BIGINT,
                (players#>>m_player_name::TEXT[])::TEXT,
                (players#>>m_player_role::TEXT[])::game_role,
                m_side,
                (riot#>>m_champ::TEXT[])::INT,
                (riot#>>m_spell1::TEXT[])::INT,
                (riot#>>m_spell2::TEXT[])::INT,

                (riot#>>m_item0::TEXT[])::INT,
                (riot#>>m_item1::TEXT[])::INT,
                (riot#>>m_item2::TEXT[])::INT,
                (riot#>>m_item3::TEXT[])::INT,
                (riot#>>m_item4::TEXT[])::INT,
                (riot#>>m_item5::TEXT[])::INT,
                (riot#>>m_item6::TEXT[])::INT,

                (riot#>>m_kills::TEXT[])::INT,
                (riot#>>m_deaths::TEXT[])::INT,
                (riot#>>m_assists::TEXT[])::INT,
                (riot#>>m_longest_time_alive::TEXT[])::INT,
                (riot#>>m_largest_killing_spree::TEXT[])::INT,
                (riot#>>m_multi_kill::TEXT[])::INT,
                (riot#>>m_killing_sprees::TEXT[])::INT,
                (riot#>>m_double::TEXT[])::INT,
                (riot#>>m_triple::TEXT[])::INT,
                (riot#>>m_quadra::TEXT[])::INT,
                (riot#>>m_penta::TEXT[])::INT,

                (riot#>>m_total_damage_dealt::TEXT[])::INT,
                (riot#>>m_magic_damage_dealt::TEXT[])::INT,
                (riot#>>m_physical_damage_dealt::TEXT[])::INT,
                (riot#>>m_true_damage_dealt::TEXT[])::INT,
                (riot#>>m_largest_critical_strike::TEXT[])::INT,
                (riot#>>m_total_damage_to_champs::TEXT[])::INT,
                (riot#>>m_magic_damage_to_champs::TEXT[])::INT,
                (riot#>>m_physical_damage_to_champs::TEXT[])::INT,
                (riot#>>m_true_damage_to_champs::TEXT[])::INT,

                (riot#>>m_damage_dealt_to_objectives::TEXT[])::INT,
                (riot#>>m_damage_dealt_to_turrets::TEXT[])::INT,
                (riot#>>m_total_heal::TEXT[])::INT,
                (riot#>>m_total_units_healed::TEXT[])::INT,
                (riot#>>m_damage_self_mitigated::TEXT[])::INT,
                (riot#>>m_time_ccing_others::TEXT[])::INT,
                (riot#>>m_total_damage_taken::TEXT[])::INT,
                (riot#>>m_magic_damage_taken::TEXT[])::INT,
                (riot#>>m_physical_damage_taken::TEXT[])::INT,
                (riot#>>m_true_damage_taken::TEXT[])::INT,
                (riot#>>m_gold_earned::TEXT[])::INT,
                (riot#>>m_gold_spent::TEXT[])::INT,

                (riot#>>m_turret_kills::TEXT[])::INT,
                (riot#>>m_inhibitor_kills::TEXT[])::INT,
                (riot#>>m_total_minions_killed::TEXT[])::INT,
                (riot#>>m_neutral_minions_killed::TEXT[])::INT,
                (riot#>>m_neutral_minions_killed_team_jungle::TEXT[])::INT,
                (riot#>>m_neutral_minions_killed_enemy_jungle::TEXT[])::INT,
                (riot#>>m_total_time_crowd_control_dealt::TEXT[])::INT,

                (riot#>>m_champion_level::TEXT[])::INT,
                (riot#>>m_vision_score::TEXT[])::INT,
                (riot#>>m_vision_wards_bought::TEXT[])::INT,
                (riot#>>m_wards_placed::TEXT[])::INT,
                (riot#>>m_wards_killed::TEXT[])::INT,

                (riot#>>m_first_blood_kill::TEXT[])::BOOLEAN,
                (riot#>>m_first_blood_assist::TEXT[])::BOOLEAN,
                (riot#>>m_first_tower_kill::TEXT[])::BOOLEAN,
                (riot#>>m_first_tower_assist::TEXT[])::BOOLEAN,
                (riot#>>m_first_inhibitor_kill::TEXT[])::BOOLEAN,
                (riot#>>m_first_inhibitor_assist::TEXT[])::BOOLEAN,

                (riot#>>m_perk0::TEXT[])::INT,
                (riot#>>m_perk0_var1::TEXT[])::INT,
                (riot#>>m_perk0_var2::TEXT[])::INT,
                (riot#>>m_perk0_var3::TEXT[])::INT,
                (riot#>>m_perk1::TEXT[])::INT,
                (riot#>>m_perk1_var1::TEXT[])::INT,
                (riot#>>m_perk1_var2::TEXT[])::INT,
                (riot#>>m_perk1_var3::TEXT[])::INT,
                (riot#>>m_perk2::TEXT[])::INT,
                (riot#>>m_perk2_var1::TEXT[])::INT,
                (riot#>>m_perk2_var2::TEXT[])::INT,
                (riot#>>m_perk2_var3::TEXT[])::INT,
                (riot#>>m_perk3::TEXT[])::INT,
                (riot#>>m_perk3_var1::TEXT[])::INT,
                (riot#>>m_perk3_var2::TEXT[])::INT,
                (riot#>>m_perk3_var3::TEXT[])::INT,
                (riot#>>m_perk4::TEXT[])::INT,
                (riot#>>m_perk4_var1::TEXT[])::INT,
                (riot#>>m_perk4_var2::TEXT[])::INT,
                (riot#>>m_perk4_var3::TEXT[])::INT,
                (riot#>>m_perk5::TEXT[])::INT,
                (riot#>>m_perk5_var1::TEXT[])::INT,
                (riot#>>m_perk5_var2::TEXT[])::INT,
                (riot#>>m_perk5_var3::TEXT[])::INT,
                (riot#>>m_perk_primary_style::TEXT[])::INT,
                (riot#>>m_perk_sub_style::TEXT[])::INT,
                (riot#>>m_stat_perk0::TEXT[])::INT,
                (riot#>>m_stat_perk1::TEXT[])::INT,
                (riot#>>m_stat_perk1::TEXT[])::INT);

        l_player_counter := l_player_counter + 1;
    END LOOP;
END;
$$
LANGUAGE 'plpgsql';

/* Riot Game parser to add to database */
CREATE OR REPLACE FUNCTION add_game(riot JSON, players JSON)
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
    EXECUTE add_game_participants(riot, players);
END;
$$
LANGUAGE 'plpgsql';