

WITH  __dbt__cte__ratings as (


SELECT team,
    team_long,
    conf,
    elo_rating::int as elo_rating
FROM '/tmp/storage/raw_team_ratings/*.parquet' S
GROUP BY ALL
),  __dbt__cte__schedules as (


SELECT 
    S.key::int AS game_id,
    S.type,
    S.series_id,
    V.conf AS visiting_conf,
    V.team AS visiting_team,
    V.elo_rating::int AS visiting_team_elo_rating,
    H.conf AS home_conf,
    H.team AS home_team,
    H.elo_rating::int AS home_team_elo_rating
FROM '/tmp/storage/raw_schedule/*.parquet' S
    LEFT JOIN __dbt__cte__ratings V ON V.team_long = S.visitorneutral
    LEFT JOIN __dbt__cte__ratings H ON H.team_long = S.homeneutral 
WHERE S.type = 'reg_season'
GROUP BY ALL
UNION ALL
SELECT S.key::int AS game_id,
    S.type,
    s.series_id,
    NULL AS visiting_conf,
    S.visitorneutral AS visiting_team,
    NULL AS visiting_team_elo_rating,
    NULL AS home_conf,
    S.homeneutral AS home_team,
    NULL AS home_team_elo_rating
FROM '/tmp/storage/raw_schedule/*.parquet' S
WHERE S.type <> 'reg_season'
GROUP BY ALL
),  __dbt__cte__playin_sim_r1 as (
-- depends-on: "main"."main"."random_num_gen"
-- depends-on: "main"."main"."reg_season_end"




SELECT
    R.scenario_id,
    S.game_id,
    EV.conf AS conf,
    EV.winning_team AS visiting_team,
    EV.elo_rating AS visiting_team_elo_rating,
    EH.winning_team AS home_team,
    EH.elo_rating AS home_team_elo_rating,
    ( 1 - (1 / (10 ^ (-( S.visiting_team_elo_rating - S.home_team_elo_rating )::real/400)+1))) * 10000 AS home_team_win_probability,
    R.rand_result,
    CASE 
        WHEN ( 1 - (1 / (10 ^ (-( S.visiting_team_elo_rating - S.home_team_elo_rating )::real/400)+1))) * 10000 >= R.rand_result THEN EH.winning_team
        ELSE EV.winning_team
    END AS winning_team 
FROM __dbt__cte__schedules S
    LEFT JOIN '/tmp/storage/random_num_gen.parquet' R ON R.game_id = S.game_id
    LEFT JOIN '/tmp/storage/reg_season_end.parquet' EH ON S.home_team = EH.seed AND R.scenario_id = EH.scenario_id
    LEFT JOIN '/tmp/storage/reg_season_end.parquet' EV ON S.visiting_team = EV.seed AND R.scenario_id = EV.scenario_id
WHERE S.type = 'playin_r1'
),cte_playin_details AS (
    SELECT S.scenario_id,
        S.game_id,
        S.winning_team,
        CASE
            WHEN S.winning_team = S.home_team THEN S.home_team_elo_rating
            ELSE S.visiting_team_elo_rating
        END AS winning_team_elo_rating, 
        S.conf AS conf,
        CASE 
            WHEN S.winning_team = S.home_team THEN S.visiting_team
            ELSE S.home_team
        END AS losing_team,
        CASE
            WHEN S.winning_team = S.home_team THEN S.visiting_team_elo_rating
            ELSE S.home_team_elo_rating
        END AS losing_team_elo_rating, 
        CASE 
            WHEN S.game_id IN (1231,1234) THEN 'winner advance'
            WHEN S.game_id IN (1232,1235) THEN 'loser eliminated'
        END AS result 
  FROM __dbt__cte__playin_sim_r1 S
)
SELECT *,
        CASE
            WHEN game_id IN (1231,1234) THEN losing_team
            WHEN game_id IN (1232,1235) THEN winning_team
        END AS remaining_team 
FROM cte_playin_details