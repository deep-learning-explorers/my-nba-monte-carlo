MODEL (
  name nba.raw_xf_series_to_seed,
  kind SEED (
    path '../../../data/nba/xf_series_to_seed.csv'
  ),
  audits (
    number_of_rows(threshold=1)
  )
);