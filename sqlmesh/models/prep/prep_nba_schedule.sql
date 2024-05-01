MODEL (
  name nba.prep_schedule,
  kind FULL
);

SELECT
  id,
  type,
  CASE
    WHEN type = 'reg_season'
    THEN STRPTIME("Year"::INT || "Date", '%Y %b %-d')::DATE
    ELSE NULL
  END AS "date",
  "Start (ET)",
  "Visitor/Neutral" AS "VisTm",
  "Home/Neutral" AS "HomeTm",
  "Attend" AS attend,
  arena,
  notes,
  series_id
FROM nba.raw_schedule