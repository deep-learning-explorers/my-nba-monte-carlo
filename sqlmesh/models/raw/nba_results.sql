MODEL (
  name nba.raw_results,
  kind SEED (
    path '../../../data/nba/nba_results.csv'
  ),
  audits (
    NUMBER_OF_ROWS(threshold = 1)
  )
)