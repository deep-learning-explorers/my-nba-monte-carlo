SELECT 
    game_id,
    date,
    home_team,
    home_team_elo_rating,
    visiting_team,
    visiting_team_elo_rating,
    home_team_win_probability,
    winning_team,
    include_actuals,
    COUNT(*) AS occurances,
    {{ american_odds( 'home_team_win_probability/10000' ) }} AS american_odds,
    type
FROM {{ ref( 'reg_season_simulator' ) }} S
    GROUP BY ALL