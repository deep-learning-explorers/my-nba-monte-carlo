MODEL (
  name nba.raw_schedule,
  kind SEED (
    path '../../../data/nba/nba_schedule.csv'
  ),
  audits (
    NUMBER_OF_ROWS(threshold = 1)
  )
)