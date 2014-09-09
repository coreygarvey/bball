setwd('/Users/cgarvey/Documents/NBA/bball/')
library(plyr)
library(ggplot2)
library(scatterplot3d)
library(reshape)

boxscores = read.csv("stats/boxscores.csv")
player_per_game = read.csv("stats/player_per_game.csv")
player_per_game_by_season = read.csv("stats/player_per_game_by_season.csv")
player_per_game_by_season_team = read.csv("stats/player_per_game_by_season_team.csv")
team_per_game = read.csv("stats/team_per_game.csv")
team_per_game_by_season = read.csv("stats/team_per_game_by_season.csv")
home_v_away_per_game = read.csv("stats/home_v_away_per_game.csv")
home_v_away_per_game_by_season = read.csv("stats/home_v_away_per_game_by_season.csv")
player_info = read.csv("stats/player_info.csv")
player_salaries = read.csv("stats/player_salaries.csv")
player_salaries_by_season = read.csv("stats/player_salaries_by_season.csv")
team_salaries = read.csv("stats/team_salaries.csv")
team_salaries_by_season = read.csv("stats/team_salaries_by_season.csv")
team_stats_by_season = read.csv("stats/team_stats_by_season.csv")

names(player_info)
names(player_per_game_by_season_team)
names(player_salaries_by_season)
names(team_per_game_by_season)

head(boxscores, 10)
head(player_per_game, 10)
head(player_per_game_by_season, 10)
head(player_per_game_by_season_team, 10)
head(team_per_game, 10)
head(team_per_game_by_season, 10)
head(home_v_away_per_game, 10)
head(home_v_away_per_game_by_season, 10)
head(player_info, 10)
head(player_salaries, 10)
head(player_salaries_by_season, 10)
head(team_salaries, 10)
head(team_salaries_by_season, 10)
head(team_stats_by_season, 10)

# Isolate player games
player_games_by_season = player_per_game_by_season[,c("PLAYER", "SEASON", "games")]
head(player_games_by_season,10)

# Stat calculations
boxscores_2014 = subset(boxscores[order(-boxscores$PTS),], SEASON==2014)
head(boxscores_2014)
total_points = sum(boxscores_2014$PTS)
total_assists = sum(boxscores_2014$AST)
total_rebounds = sum(boxscores_2014$TRB)
total_steals = sum(boxscores_2014$STL)
total_minutes = sum(boxscores_2014$minutes)

# Salary calculations
player_salaries_2014 = subset(player_salaries_by_season[order(-player_salaries_by_season$salary),], season==2014)
total_salary = sum(player_salaries_2014$salary)
cash_per_pt = total_salary/total_points
cash_per_ast = total_salary/total_assists
cash_per_trb = total_salary/total_rebounds
cash_per_stl = total_salary/total_steals
cash_per_min = total_salary/total_minutes
cash_per_stat = total_salary/sum(total_points,total_assists,total_rebounds,total_steals)
cash_per_stat

# 2014 team and player stats
team_stats_2014 = subset(team_stats_by_season, season==2014)
player_per_game_team_2014 = subset(player_per_game_by_season_team, SEASON==2014)
player_per_game_2014 = subset(player_per_game_by_season, SEASON==2014)

# PLAYER - Join data sets and drop columns we don't want
player_per_game_2014 <- merge(player_per_game_2014, player_salaries_by_season, by.x=c("PLAYER", "SEASON"), by.y=c("id", "season"))
salarydrops <- c("X.x","X.y","mean_salary")
player_per_game_2014 <- player_per_game_2014[,!(names(player_per_game_2014) %in% salarydrops)]
head(player_per_game_2014,10)

# Payout by stat
player_per_game_2014$pts_payout <- player_per_game_2014$PTS*cash_per_pt
player_per_game_2014$ast_payout <- player_per_game_2014$AST*cash_per_ast
player_per_game_2014$trb_payout <- player_per_game_2014$TRB*cash_per_trb
player_per_game_2014$stl_payout <- player_per_game_2014$STL*cash_per_stl
player_per_game_2014$stat_payout <- (player_per_game_2014$PTS+player_per_game_2014$AST+player_per_game_2014$TRB+player_per_game_2014$STL)*cash_per_stat
player_per_game_2014$min_payout <- player_per_game_2014$minutes*cash_per_min
player_per_game_2014$salary_per <- player_per_game_2014$salary*player_per_game_2014$games

# Isolate important stats, get player relative value (diff) measured as money earned vs money paid

head(player_per_game_2014)
payouts_2014 = player_per_game_2014[,c("PLAYER", "salary", "PTS", "AST", "TRB", "STL", "minutes", "pts_payout", "ast_payout", "trb_payout", "stl_payout", "min_payout", "stat_payout", "salary_per")]
payouts_2014$pts_diff <- payouts_2014$pts_payout - payouts_2014$salary_per
payouts_2014$ast_diff <- payouts_2014$ast_payout - payouts_2014$salary_per
payouts_2014$trb_diff <- payouts_2014$trb_payout - payouts_2014$salary_per
payouts_2014$stl_diff <- payouts_2014$stl_payout - payouts_2014$salary_per
payouts_2014$min_diff <- payouts_2014$min_payout - payouts_2014$salary_per
payouts_2014$stat_diff <- payouts_2014$stat_payout - payouts_2014$salary_per

# PLAYER-TEAM - Join data sets and drop columns we don't want
player_per_game_team_2014 <- merge(player_per_game_team_2014, player_salaries_by_season, by.x=c("PLAYER", "SEASON"), by.y=c("id", "season"))
salarydrops <- c("X.x","X.y","mean_salary")
player_per_game_team_2014 <- player_per_game_team_2014[,!(names(player_per_game_team_2014) %in% salarydrops)]
player_per_game_team_2014 <- merge(player_per_game_team_2014, player_games_by_season, by=c("PLAYER", "SEASON"))
player_per_game_team_2014$eff_salary <- player_per_game_team_2014$salary*(player_per_game_team_2014$games.x/player_per_game_team_2014$games.y)
head(player_per_game_team_2014,10)

head(payouts_2014[order(-payouts_2014$pts_diff),])
head(payouts_2014[order(-payouts_2014$ast_diff),])
head(payouts_2014[order(-payouts_2014$trb_diff),])
head(payouts_2014[order(-payouts_2014$stl_diff),])
head(payouts_2014[order(-payouts_2014$min_diff),])
head(payouts_2014[order(payouts_2014$stat_diff),])
head(player_per_game_2014)



library(MASS)
library(ISLR)

players_2014 = player_per_game_2014
head(players_2014, 5)
names(boxscores_2014)
head(player_salaries_2014)
stats <- merge(boxscores_2014, player_salaries_2014, by.x=c("PLAYER"), by.y=c("id"))
stats_drops <- c("X.x","MP")
stats <- stats[,!(names(stats) %in% stats_drops)]
top_players_2014 = subset(players_2014, PTS>10)
top_players_2014 = top_players_2014[1]
top_list <- top_players_2014[,1]
top_stats_2014 = subset(stats, stats$PLAYER %in% top_list)

head(top_stats_2014)
names(top_stats_2014)
attach(top_stats_2014)
plot(percent,PTS)
identify(percent, PTS, labels = stats$PLAYER, plot=FALSE)
head(stats)
persp(FG.,percent,seconds,theta=30,phi=20)
scatterplot3d(FG.,percent,seconds, main="3D Scatterplot")

lm.fit=lm(PTS~percent*FG.+seconds, data=stats)
lm.fit
names(stats)
summary(stats)
names(lm.fit)
summary(lm.fit)
plot(PTS,AST)
coef(lm.fit)
confint(lm.fit)
predict(lm.fit,data.frame(), interval="confidence")
plot(players_2014$AST,players_2014$PTS)
abline(lm.fit)
par(mfrow=c(2,2))
plot(lm.fit)
plot(predict(lm.fit), residuals(lm.fit))
plot(predict(lm.fit), rstudent(lm.fit))
plot(hatvalues(lm.fit))
which.max(hatvalues(lm.fit))
lm.fit=lm(PTS~X3PA+TRB+FT., data=players_2014)
summary(lm.fit)
library(car)
vif(lm.fit)
lm.fit2=lm(PTS~X3PA+TRB*FTA, data=players_2014)
vif(lm.fit2)
summary(lm.fit2)
lm.fit3=lm(PTS~X3PA+TRB+I(minutes^2), data=players_2014)
summary(lm.fit3)
lm.fit=lm(PTS~X3PA+TRB+minutes, data=players_2014)
summary(lm.fit)
anova(lm.fit,lm.fit3)
plot(players_2014$minutes,players_2014$PTS)
lm.fit=lm(PTS~AST+TRB+STL+AST:team,data=players_2014)
summary(lm.fit)

names(players_2014)
contrasts(players_2014$team)

# Team stats and remove X column
team_stats_by_season = read.csv("raw/teams.csv")
teamstatsdrops <- c("X")
team_stats_by_season <- team_stats_by_season[,!(names(team_stats_by_season) %in% teamstatsdrops)]

lapply(team_stats_by_season, class)
summary(team_stats_by_season$playoffs)

# Replace playoff results with round
team_stats_by_season[,12]= sub("^$", "0", team_stats_by_season[,12])
team_stats_by_season[,12]= sub(".*1st.*", "1", team_stats_by_season[,12])
team_stats_by_season[,12]= sub(".*Semis", "2", team_stats_by_season[,12])
team_stats_by_season[,12]= sub(".*Conf\\.\\sFinals", "3", team_stats_by_season[,12])
team_stats_by_season[,12]= sub("Lost\\sFinals", "4", team_stats_by_season[,12])
team_stats_by_season[,12]= sub("Won.*", "5", team_stats_by_season[,12])
head(team_stats_by_season[order(-team_stats_by_season$w),])
head(team_salaries_by_season, 40)

# League salaries
total_salaries <- ddply(teams_with_salaries, c("season"), summarise, 
                        league_salary = sum(as.numeric(total_salary)))
head(total_salaries)

# Join league salaries with team
team_salaries_by_season <- merge(team_salaries_by_season, total_salaries, by=c("season"))
team_salaries_by_season$salary_percentage <- team_salaries_by_season$total_salary/team_salaries_by_season$league_salary*100
head(team_salaries_by_season)

# Remove x from salaries and join Salaries with Stats
teamsalarydrops <- c("X")
team_salaries_by_season <- team_salaries_by_season[,!(names(team_salaries_by_season) %in% teamsalarydrops)]
head(team_salaries_by_season)
teams_with_salaries <- merge(team_salaries_by_season, team_stats_by_season, by=c("team", "season"))
head(teams_with_salaries)

# Filter for playoff teams
playoff_teams = subset(teams_with_salaries, playoffs>0)

#teams_with_salaries$success = team_stats_by_season$percent_w + max(team_stats_by_season$percent_w)*as.numeric(team_stats_by_season$playoffs)/5
playoff_teams$success = playoff_teams$percent_w + max(playoff_teams$percent_w)*as.numeric(playoff_teams$playoffs)/5
head(playoff_teams)
playoff_teams$salary_skew = playoff_teams$sd_salary/playoff_teams$mean_salary
playoff_teams$identifier = paste(playoff_teams$season,playoff_teams$team)
head(playoff_teams)

head(playoff_teams[order(-playoff_teams$salary_skew),])

attach(playoff_teams)
plot(playoff_teams$salary_percentage, playoff_teams$success)

playoffdata <- ddply(playoff_teams, c("season", "playoffs"), summarise, 
                     mean_w = mean(percent_w),
                     mean_salary = mean(total_salary))
head(playoffdata)

lm.fit=lm(success~salary_percentage+salary_skew, data=playoff_teams)
summary(lm.fit)
abline(lm.fit)

# Breakdowns by advancement in the playoffs
teams_first = subset(playoff_teams, playoffs==1)
teams_second = subset(playoff_teams, playoffs==2)
teams_third = subset(playoff_teams, playoffs==3)
teams_fourth = subset(playoff_teams, playoffs==4)
teams_fifth = subset(playoff_teams, playoffs==5)

par(mfrow=c(1,1))
plot(teams_first$percent_w, teams_first$salary_percentage)
identify(teams_first$season,teams_first$'1',labels=teams_first$identifier)
plot(teams_second$percent_w, teams_second$salary_percentage)
plot(teams_third$percent_w, teams_third$salary_percentage)
plot(teams_fourth$percent_w, teams_fourth$salary_percentage)
plot(teams_fifth$percent_w, teams_fifth$salary_percentage)

seasons_first = subset(playoffdata, playoffs==1)
seasons_second = subset(playoffdata, playoffs==2)
seasons_third = subset(playoffdata, playoffs==3)

plot(seasons_first$mean_w, seasons_first$mean_salary)
plot(seasons_second$mean_w, seasons_second$mean_salary)
plot(seasons_third$mean_w, seasons_third$mean_salary)

playoffmeans <- cast(playoffdata, season~playoffs, value="mean_w")
head(playoffmeans, 29)

plot(playoffmeans$season,playoffmeans$'1')

plot(playoffmeans$season,playoffmeans$'2')
plot(playoffmeans$season,playoffmeans$'3')
plot(playoffmeans$season,playoffmeans$'4')
plot(playoffmeans$season,playoffmeans$'5')



# EXTRA from processing

team_salaries_2014 = subset(team_salaries_by_season[order(-team_salaries_by_season$mean_salary),], season==2014)
team_salaries_2012 = subset(team_salaries_by_season[order(-team_salaries_by_season$mean_salary),], season==2012)
team_salaries_1995 = subset(team_salaries_by_season[order(-team_salaries_by_season$mean_salary),], season==1995)
team_salaries_1996 = subset(team_salaries_by_season[order(-team_salaries_by_season$mean_salary),], season==1996)
team_salaries_1997 = subset(team_salaries_by_season[order(-team_salaries_by_season$mean_salary),], season==1997)


head(team_salaries_2014)
coef(lm(sd_salary ~ total_salary, data = team_salaries_2014))
ggplot(NULL, aes(team_salaries_2014$total_salary,team_salaries_2014$sd_salary))+geom_point(data = team_salaries_2014, col="red")+geom_text(aes(label=team_salaries_2014$team),hjust=0, vjust=0)+stat_smooth(method="lm", se=FALSE)
ggplot(NULL, aes(team_salaries_2012$total_salary,team_salaries_2012$sd_salary))+geom_point(data = team_salaries_2012, col="red")+geom_text(aes(label=team_salaries_2012$team),hjust=0, vjust=0)+stat_smooth(method="lm", se=FALSE)
ggplot(NULL, aes(team_salaries_1995$total_salary,team_salaries_1995$sd_salary))+geom_point(data = team_salaries_1995, col="red")+geom_text(aes(label=team_salaries_1995$team),hjust=0, vjust=0)+stat_smooth(method="lm", se=FALSE)
ggplot(NULL, aes(team_salaries_1996$total_salary,team_salaries_1996$sd_salary))+geom_point(data = team_salaries_1996, col="red")+geom_text(aes(label=team_salaries_1996$team),hjust=0, vjust=0)+stat_smooth(method="lm", se=FALSE)
ggplot(NULL, aes(team_salaries_1997$total_salary,team_salaries_1997$sd_salary))+geom_point(data = team_salaries_1997, col="red")+geom_text(aes(label=team_salaries_1997$team),hjust=0, vjust=0)+stat_smooth(method="lm", se=FALSE)



teams_2014 = subset(team_analysis, season==2014)
ggplot(NULL, aes(teams_2014$percent_w,teams_2014$sd_salary))+geom_point(data = teams_2014, col="red")+geom_text(aes(label=teams_2014$team),hjust=0, vjust=0)+stat_smooth(method="lm", se=FALSE)
teams_2013 = subset(team_analysis, season==2013)
ggplot(NULL, aes(teams_2013$percent_w,teams_2013$sd_salary))+geom_point(data = teams_2013, col="red")+geom_text(aes(label=teams_2014$team),hjust=0, vjust=0)+stat_smooth(method="lm", se=FALSE)

# Klay Thompson Data
klay_per_game = subset(player_per_game[order(player_per_game$PTS),], PLAYER=="thompkl01")
klay_full = subset(basicdata[order(basicdata$PTS),], PLAYER=="thompkl01")
nrow(klay)
head(klay)
player_by_ppg = player_per_game[with(player_per_game, order(-PTS)), ]
head(player_by_ppg)

# Games ordered by points
player_by_pts = basicdata[order(-basicdata$PTS),]
head(player_by_pts)

# Games ordered by plus minus
player_by_plus = basicdata[order(-basicdata$PLUS),]
head(player_by_plus)

# Games above 10 min ordered by points per minute
player_by_ppm = subset(basicdata[order(-basicdata$ppm),], minutes>10)
head(player_by_ppm)

# Carmelo Anthony data
melo_full = subset(basicdata[order(basicdata$PTS),], PLAYER=="anthoca01")
nrow(melo_full)
head(melo_full)
# Basic Scatter Plot
qplot(FG, FGA, data=melo_full, color=92)
ggplot(NULL, aes(melo_full$FG,melo_full$FGA))+geom_point(data = melo_full, col="red")
# 3D Scatterplot
scatterplot3d(melo_full$FGA,melo_full$FG,melo_full$ppm, main="3D Scatterplot")

