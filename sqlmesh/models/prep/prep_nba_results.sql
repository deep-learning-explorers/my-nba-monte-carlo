MODEL (
  name nba.prep_results,
  kind VIEW
);

WITH cte_base AS (
  SELECT
    *
  FROM nba.raw_results
), cte_base2 AS (
  SELECT
    STRPTIME("date", '%a %b %-d %Y')::DATE AS "date",
    "start (et)" AS "start_time",
    "visitor/neutral" AS "visTm",
    pts::INT AS visiting_team_score,
    "home/neutral" AS "homeTm",
    pts1::INT AS home_team_score,
    attend AS attend,
    arena AS arena,
    notes AS notes
  FROM cte_base
)
SELECT
  *,
  CASE WHEN visiting_team_score > home_team_score THEN visTm ELSE homeTm END AS Winner,
  CASE WHEN visiting_team_score > home_team_score THEN homeTm ELSE visTm END AS Loser,
  CASE
    WHEN visiting_team_score > home_team_score
    THEN visiting_team_score
    ELSE home_team_score
  END AS Winner_Pts,
  CASE
    WHEN visiting_team_score > home_team_score
    THEN home_team_score
    ELSE visiting_team_score
  END AS Loser_Pts
FROM cte_base2