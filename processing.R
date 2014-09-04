setwd('/Users/cgarvey/Documents/NBA/bball/')
library(plyr)
library(ggplot2)
library(scatterplot3d)

basicdata_raw = read.csv("raw/basic.csv")
advdata_raw = read.csv("raw/advanced.csv")

# Remove DNPs
basicdata = basicdata_raw[ !( grepl("DNP", basicdata_raw$FG) ), ]
advdata = advdata_raw[ !( grepl("DNP", advdata_raw$TS.) ), ]

# Change numeric columns to numeric
# basic
for(i in 3:21) {
  basicdata[,i] <- as.numeric(as.character(basicdata[,i]))
}
# advanced
for(i in 3:14) {
  advdata[,i] <- as.numeric(as.character(advdata[,i]))
}

# Change string columns to character
for(i in c(1:2,22:ncol(basicdata))) {
  basicdata[,i] <- as.character(basicdata[,i])
}
for(i in c(1:2,15:ncol(advdata))) {
  advdata[,i] <- as.character(advdata[,i])
}

# Summary data
lapply(advdata, class)
nrow(advdata)
nrow(basicdata)
head(basicdata)
tail(advdata[,2])

# Remove extra parts of time
remove_end <- function(time){
  pattern <- "^([0-5][0-9]:[0-5][0-9])"
  short_time = regexpr(pattern, time)
  regmatches(time, short_time)
}
basicdata[,2] <- sapply(basicdata[,2], function(x) ifelse(nchar(x)>5, remove_end(x), x))

# Extract the minutes and seconds from the MP column and create new columns for minutes and seconds
get_minutes <- function(time){
  minutes_pattern = "^([0-9]{1,2})"
  minutes = regexpr(minutes_pattern, time)
  regmatches(time, minutes)
}
get_seconds <- function(time){
  seconds_pattern = "([0-9]{1,2})$"
  seconds = regexpr(seconds_pattern, time)
  regmatches(time, seconds)
}
basicdata$seconds <- apply(basicdata,1,function(row) sum(as.numeric(get_minutes(row[2]))*60, as.numeric(get_seconds(row[2]))))
basicdata$minutes <- basicdata$seconds / 60
basicdata$ppm <- basicdata$PTS/basicdata$minutes
basicdata$playergame <- paste(basicdata$PLAYER, basicdata$GAME)
advdata$playergame <- paste(advdata$PLAYER, advdata$GAME)

# Drop columns in advanced data that will be redundant
advdrops <- c("PLAYER","GAME","HOME.AWAY", "MP", "OPP", "SEASON", "TEAM")
advdata <- advdata[,!(names(advdata) %in% advdrops)]

#Join basic and advanced data to get table of total information
fulldata = merge(basicdata, advdata, by="playergame")
nrow(fulldata)
nrow(advdata)
nrow(basicdata)
head(fulldata) 
names(fulldata)

# All Boxscores
boxscores = fulldata
head(boxscores,10)
# Player stats per game
player_per_game = ddply(fulldata, .(PLAYER), numcolwise(mean, na.rm = TRUE))
head(player_per_game)


# All Players
players <- player_per_game[,1]
head(players, 50)

# Player stats per game by season
player_per_game_by_season = ddply(fulldata, .(PLAYER, SEASON), numcolwise(mean, na.rm = TRUE))
player_games_by_season = ddply(fulldata, .(PLAYER, SEASON), summarize, games=length(PLAYER))
player_per_game_by_season <- merge(player_per_game_by_season, player_games_by_season, by=c("PLAYER", "SEASON"))
head(player_per_game_by_season, 10)

player_per_game_by_season_team = ddply(fulldata, .(PLAYER, SEASON, TEAM), numcolwise(mean, na.rm = TRUE))
player_games_by_season_team = ddply(fulldata, .(PLAYER, SEASON, TEAM), summarize, games=length(PLAYER))
player_per_game_by_season_team <- merge(player_per_game_by_season_team, player_games_by_season_team, by=c("PLAYER", "SEASON", "TEAM"))
head(player_per_game_by_season_team, 10)


# Team stats per game
team_per_game = ddply(fulldata, .(TEAM), numcolwise(mean, na.rm = TRUE))

# Team stats per game by season
team_per_game_by_season = ddply(fulldata, .(TEAM, SEASON), numcolwise(mean, na.rm = TRUE))

# Home vs Away
home_v_away_per_game = ddply(fulldata, .(HOME.AWAY), numcolwise(mean, na.rm = TRUE))

# Home vs Away
home_v_away_per_game_by_season = ddply(fulldata, .(HOME.AWAY, SEASON), numcolwise(mean, na.rm = TRUE))

# Player Info
player_info = read.csv("raw/playerInfo.csv")

# Player salaries by season
player_salaries_by_season = read.csv("raw/playerSalaries.csv")
head(player_salaries_by_season)

# Player salaries
player_salaries = ddply(player_salaries_by_season, .(id), summarise, mean_salary = mean(salary, na.rm = TRUE), total_salary = sum(salary, na.rm = TRUE))
playerdrops <- c("season")
player_salaries <- player_salaries[,!(names(player_salaries) %in% playerdrops)]
head(player_salaries)

# Team salaries by season
team_salaries_by_season = ddply(player_salaries_by_season, .(team, season), summarise, 
                                mean_salary = mean(salary, na.rm = TRUE), 
                                total_salary = sum(salary, na.rm = TRUE),
                                sd_salary = sd(salary, na.rm = TRUE)
                                )
head(team_salaries_by_season, 50)

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


# Team salaries
team_salaries = ddply(player_salaries_by_season, .(team), summarise,
                      mean_salary = mean(salary, na.rm = TRUE), 
                      total_salary = sum(salary, na.rm = TRUE),
                      sd_salary = sd(salary, na.rm = TRUE),
                      checks_paid = length(salary),
                      players_paid = length(unique(id))
                      )
team_salaries$avg_seasons <- team_salaries$checks_paid/team_salaries$players_paid
teamdrops <- c("season")
team_salaries <- team_salaries[,!(names(team_salaries) %in% teamdrops)]
head(team_salaries[order(team_salaries$avg_seasons),])

# Player salaries by season
salaries = merge(player_salaries_by_season, team_salaries_by_season, by=c("team","season"))
head(salaries)
salaries$percent <- salaries$salary/salaries$total_salary
head(subset(salaries[order(-salaries$percent),], season==2014), 50)

# Team stats by season
team_stats_by_season = read.csv("raw/teams.csv")
team_stats_by_season$percent_w <- team_stats_by_season$w/(team_stats_by_season$w+team_stats_by_season$l)
head(team_stats_by_season)

# Team salary and wins analysis
team_analysis = merge(team_stats_by_season, team_salaries_by_season, by=c("team","season"))
team_keeps = c("season", "team", "percent_w", "total_salary", "sd_salary")
team_analysis = team_analysis[team_keeps]
head(team_analysis, 30)
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

# Team
team_per_game = ddply(fulldata, .(TEAM), numcolwise(mean, na.rm = TRUE))
head(team_per_game)
team_per_game



# Datsets
head(boxscores)
head(player_per_game)
head(player_per_game_by_season)
head(team_per_game)
head(team_per_game_by_season)
head(home_v_away_per_game)
head(home_v_away_per_game_by_season)
head(player_info)
head(player_salaries)
head(player_salaries_by_season)
head(team_salaries)
head(team_salaries_by_season)

write.csv(player_per_game, file = "stats/player_per_game.csv")
write.csv(player_per_game_by_season, file = "stats/player_per_game_by_season.csv")
write.csv(player_per_game_by_season_team, file = "stats/player_per_game_by_season_team.csv")
write.csv(team_per_game, file = "stats/team_per_game.csv")
write.csv(team_per_game_by_season, file = "stats/team_per_game_by_season.csv")
write.csv(home_v_away_per_game, file = "stats/home_v_away_per_game.csv")
write.csv(home_v_away_per_game_by_season, file = "stats/home_v_away_per_game_by_season.csv")
write.csv(player_salaries, file = "stats/player_salaries.csv")
write.csv(team_salaries_by_season, file = "stats/team_salaries_by_season.csv")
write.csv(team_salaries, file = "stats/team_salaries.csv")
write.csv(salaries, file = "stats/player_salaries_by_season.csv")
write.csv(team_stats_by_season, file = "stats/team_stats_by_season.csv")
write.csv(team_analysis, file = "stats/team_analysis.csv")