setwd('/Users/cgarvey/Documents/NBA/bball/')
library(plyr)
library(ggplot2)
library(scatterplot3d)

boxscores = read.csv("stats/boxscores.csv")
player_per_game = read.csv("stats/player_per_game.csv")
player_per_game_by_season = read.csv("stats/player_per_game_by_season.csv")
team_per_game = read.csv("stats/team_per_game.csv")
team_per_game_by_season = read.csv("stats/team_per_game_by_season.csv")
home_v_away_per_game = read.csv("stats/home_v_away_per_game.csv")
home_v_away_per_game_by_season = read.csv("stats/home_v_away_per_game_by_season.csv")
player_info = read.csv("stats/player_info.csv")
player_salaries = read.csv("stats/player_salaries.csv")
player_salaries_by_season = read.csv("stats/player_salaries_by_season.csv")
team_salaries = read.csv("stats/team_salaries.csv")
team_salaries_by_season = read.csv("stats/team_salaries_by_season.csv")

head(boxscores, 10)
head(player_per_game, 10)
head(player_per_game_by_season, 10)
head(team_per_game, 10)
head(team_per_game_by_season, 10)
head(home_v_away_per_game, 10)
head(home_v_away_per_game_by_season, 10)
head(player_info, 10)
head(player_salaries, 10)
head(player_salaries_by_season, 10)
head(team_salaries, 10)
head(team_salaries_by_season, 10)

boxscores_2014 = subset(boxscores[order(-boxscores$PTS),], SEASON==2014)
head(boxscores_2014)
total_points = sum(boxscores_2014$PTS)
total_assists = sum(boxscores_2014$AST)
total_rebounds = sum(boxscores_2014$TRB)
total_steals = sum(boxscores_2014$STL)
total_minutes = sum(boxscores_2014$minutes)

player_salaries_2014 = subset(player_salaries_by_season[order(-player_salaries_by_season$mean_salary),], season==2014)
total_salary = sum(player_salaries_2014$salary)
cash_per_pt = total_salary/total_points
cash_per_ast = total_salary/total_assists
cash_per_trb = total_salary/total_rebounds
cash_per_stl = total_salary/total_steals
cash_per_min = total_salary/total_minutes
cash_per_stat = total_salary/sum(total_points,total_assists,total_rebounds,total_steals)
cash_per_stat


player_per_game_2014 = subset(player_per_game_by_season, SEASON==2014)

# Join data sets and drop columns we don't want
player_per_game_2014 <- merge(player_per_game_2014, player_salaries_by_season, by.x=c("PLAYER", "SEASON"), by.y=c("id", "season"))
salarydrops <- c("X.x","X.y","mean_salary")
player_per_game_2014 <- player_per_game_2014[,!(names(player_per_game_2014) %in% salarydrops)]
player_per_game_2014$salary_per <- player_per_game_2014$salary/82

# Payout by stat
player_per_game_2014$pts_payout <- player_per_game_2014$PTS*cash_per_pt
player_per_game_2014$ast_payout <- player_per_game_2014$AST*cash_per_ast
player_per_game_2014$trb_payout <- player_per_game_2014$TRB*cash_per_trb
player_per_game_2014$stl_payout <- player_per_game_2014$STL*cash_per_stl
player_per_game_2014$stat_payout <- (player_per_game_2014$PTS+player_per_game_2014$AST+player_per_game_2014$TRB+player_per_game_2014$STL)*cash_per_stat
player_per_game_2014$min_payout <- player_per_game_2014$minutes*cash_per_min

# Isolate payouts
payouts_2014 = player_per_game_2014[,c("PLAYER", "salary", "PTS", "AST", "TRB", "STL", "minutes", "pts_payout", "ast_payout", "trb_payout", "stl_payout", "min_payout", "stat_payout", "salary_per")]
payouts_2014$pts_diff <- payouts_2014$pts_payout - payouts_2014$salary_per
payouts_2014$ast_diff <- payouts_2014$ast_payout - payouts_2014$salary_per
payouts_2014$trb_diff <- payouts_2014$trb_payout - payouts_2014$salary_per
payouts_2014$stl_diff <- payouts_2014$stl_payout - payouts_2014$salary_per
payouts_2014$min_diff <- payouts_2014$min_payout - payouts_2014$salary_per
payouts_2014$stat_diff <- payouts_2014$stat_payout - payouts_2014$salary_per

head(payouts_2014[order(-payouts_2014$pts_diff),])
head(payouts_2014[order(-payouts_2014$ast_diff),])
head(payouts_2014[order(-payouts_2014$trb_diff),])
head(payouts_2014[order(-payouts_2014$stl_diff),])
head(payouts_2014[order(-payouts_2014$min_diff),])
head(payouts_2014[order(payouts_2014$stat_diff),])
head(player_per_game_2014)
