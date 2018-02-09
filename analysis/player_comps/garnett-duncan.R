## Garnett vs. Duncan ##
## My first player analysis, set up to run on any other players ##
## This will begin with an exploration into some career numbers ##
## Will eventually looks a the relationship between each player's stats ##

### Set working directory and import necessary libraries ###
setwd('/Users/cgarvey/Documents/NBA/bball/')
library(plyr)
library(ggplot2)
library(scatterplot3d)
library(reshape)
library(gridExtra)

## PART I - Exploration ##

### All player information. Search for player ids ###
player_info = read.csv("data/stats/player_info.csv")
head(player_info)
player_find = subset(player_info, grepl('Duncan|Garnett', name))
player_find

### Article name for saving files and player ids ###
article_name = "duncanvsgarnett"
player1 = "duncati01"
player2 = "garneke01"

### Player Information ###
both_info = subset(player_info, id==player1|id==player2)

### Info for blog ###
columns = c("name","shoots","heightft","heightin","weight","bmonth","bday","byear","bcity","bstate","bcountry","hs","hscity","hsstate","college","draftteam","draftoverall","draftyear")
both_blog_info = both_info[,columns]
head(both_blog_info)

### Boxscores ###
boxscores = read.csv("data/stats/boxscores.csv")
player1_box = subset(boxscores, PLAYER==player1)
player2_box = subset(boxscores, PLAYER==player2)
both_box = subset(boxscores, PLAYER==player1|PLAYER==player2)

### Check ###
head(player1_box) 

### Career per game ###
player_per_game = read.csv("data/stats/player_per_game.csv")
both_career_raw = subset(player_per_game, PLAYER==player1|PLAYER==player2)
columns = c("PLAYER","FG","FGA","FG.","X3P","X3PA","X3P.","FT","FTA","FT.","ORB","DRB","TRB","AST","STL","BLK","TOV","PF","PTS","minutes")
both_career = both_career_raw[,columns]
both_career[,-1] <-round(both_career[,-1],2)
head(both_career, 40)

### Salaries ###
player_salaries_by_season = read.csv("data/stats/player_salaries_by_season.csv")
head(player_salaries_by_season)
both_salaries = subset(player_salaries_by_season, id==player1|id==player2)
both_info_salaries = merge(both_info, both_salaries, by=c("id"))

both_info_salaries["salary"] = round(both_info_salaries["salary"]/1000000,2)
head(both_info_salaries, 40)
player1_info_salaries = subset(both_info_salaries, id==player1)
player2_info_salaries = subset(both_info_salaries, id==player2)
head(both_info_salaries,40)

### Career total salary ###
total_salaries = ddply(both_salaries, .(id), summarize, feq=length(id), total=sum(salary))
head(total_salaries)

### Salaries for blog ###
player1_salary_out = player1_info_salaries[,c("name","season", "team", "salary")]
player1_salary_out = player1_salary_out[ order(player1_salary_out[,2]),]
player2_salary_out = player2_info_salaries[,c("name","season", "team", "salary")]
player2_salary_out = player2_salary_out[ order(player2_salary_out[,2]),]
head(player1_salary_out)
colnames(player2_salary_out)=c("Name","Season","Team","Salary (millions)")
colnames(player1_salary_out)=c("Name","Season","Team","Salary (millions)")
head(player1_salary_out)
head(player2_salary_out)

### Salary CSVs used in blog's html ###
directory = dir.create(sprintf("data/stats/articles/%s", article_name), showWarnings = TRUE, recursive = FALSE)
write.csv(player1_salary_out, file = sprintf("data/stats/articles/%s/%ssalaries.csv", article_name, player1), row.names=FALSE)
write.csv(player2_salary_out, file = sprintf("data/stats/articles/%s/%ssalaries.csv", article_name, player2), row.names=FALSE)


## Part II - Early Years ##

### Total Salaries ###
lapply(player1_salary_out, class)
player1_total = sum(player1_salary_out[,4])
player1_total
player2_total = sum(player2_salary_out[,4])
player2_total

# Duncan has almost 30 pounds on Garnett, which helps explain the edge in rebounds and blocks.
# Filter for first 5 years, 1998-2002 for Duncan and 1996-2000 for Garnett, using the boxscore data then get averages for those first five years.
head(both_box)
### First five years for each player adding year column ###
both_first_five_info = ddply(both_info_salaries, "id", function(x) head(x[order(x$season, decreasing = FALSE) , ], 5))
both_first_five_info = ddply(both_first_five_info, "id", transform, year = seq_along(season))
both_first_five_info

### Looking at first 5 years, subset boxscore data ###
both_first_five_box = subset(both_box, PLAYER=="duncati01" & SEASON<2003 | PLAYER=="garneke01" & SEASON<2001)
both_first_five_by_season = ddply(both_first_five_box, .(PLAYER, SEASON), numcolwise(mean, na.rm = TRUE))
player_first_five <- merge(both_first_five_by_season, both_first_five_info, by.x=c("PLAYER", "SEASON"), by.y=c("id", "season"))
head(player_first_five, 10)

### Add team data
team_stats_by_season = read.csv("data/raw/teams.csv")
team_stats_2014 = subset(team_stats_by_season, season==2014)
teamstatsdrops <- c("X")
team_stats_by_season <- team_stats_by_season[,!(names(team_stats_by_season) %in% teamstatsdrops)]
team_stats_by_season$playoff_score= sub("^$", "0", team_stats_by_season[,12])
team_stats_by_season$playoff_score= sub(".*1st.*", "1", team_stats_by_season[,12])
team_stats_by_season$playoff_score= sub(".*Semis", "2", team_stats_by_season[,12])
team_stats_by_season$playoff_score= sub(".*Conf\\.\\sFinals", "3", team_stats_by_season[,12])
team_stats_by_season$playoff_score= sub("Lost\\sFinals", "4", team_stats_by_season[,12])
team_stats_by_season$playoff_score= sub("Won.*", "5", team_stats_by_season[,12])
team_stats_by_season$percent_w = team_stats_by_season$w/(team_stats_by_season$w+team_stats_by_season$l)
first_five_full = merge(team_stats_by_season, player_first_five, by.x=c("team", "season"), by.y=c("team", "SEASON"))
head(first_five_full, 10)

### Isolate players, salaries and winning percentages ###
salary_v_winning = first_five_full[,c("PLAYER","year","season","name", "salary", "percent", "total_salary", "percent_w", "playoffs")]
salary_v_winning["percent_w"] = round(salary_v_winning["percent_w"]*100,2)
salary_v_winning["percent"] = round(salary_v_winning["percent"]*100,2)
salary_v_winning["total_salary"] = round(salary_v_winning["total_salary"]/1000000,2)
player1_salary_v_winning = subset(salary_v_winning, PLAYER==player1)
player2_salary_v_winning = subset(salary_v_winning, PLAYER==player2)
player1_salary_v_winning_out = player1_salary_v_winning[,c("year","season","name", "salary", "percent", "total_salary", "percent_w", "playoffs")]
player2_salary_v_winning_out = player2_salary_v_winning[,c("year","season","name", "salary", "percent", "total_salary", "percent_w", "playoffs")]

colnames(player1_salary_v_winning_out)=c("Year","Season", "Name", "Salary (mm)", "% of team Salary", "Team Salary (mm)", "Win %", "Playoff Result")
colnames(player2_salary_v_winning_out)=c("Year","Season", "Name", "Salary (mm)", "% of team Salary", "Team Salary (mm)", "Win %", "Playoff Result")
head(player1_salary_v_winning_out)
head(player2_salary_v_winning_out)

### Salary CSVs used in blog's html ###
write.csv(player1_salary_v_winning_out, file = sprintf("data/stats/articles/%s/%sfirst_5_salary_v_winning.csv", article_name, player1), row.names=FALSE)
write.csv(player2_salary_v_winning_out, file = sprintf("data/stats/articles/%s/%sfirst_5_salary_v_winning.csv", article_name, player2), row.names=FALSE)

player_first_five

# A few interesting points here. First, Duncan was a maniac right out of the gate, averaging 21 points, 12 boards and 2.7 assists as a rookie. The next 4 years simply confirmed his place in the NBA elite.
# Next, look at the year 4 salary jump. Amazingly, Garnett didn't average 20 points or 10 rebounds in any of his first three years in the league, a feat Duncancan accomplished his first 8 seasons. Garnett's DRtg is the big differentiator, an outstanding 108 his rookie year. Minnesota paid Garnett $14 milliion, 43% of their $25 million salary. San Antonio paid Duncan $9.6 million, 16% of their $57 million. 
a <- ggplot(data = player_first_five, aes(x = year, y = PTS, col = PLAYER))
a <- a + geom_point(size = 5)
a <- a + xlab("Year") + ylab("Pts") + ggtitle("Points by season")
a

b <- ggplot(data = player_first_five, aes(x = year, y = TRB, col = PLAYER))
b <- b + geom_point(size = 5)
b <- b + xlab("Year") + ylab("Rebs") + ggtitle("Rebounds by season")
b

c <- ggplot(data = player_first_five, aes(x = year, y = AST, col = PLAYER))
c <- c + geom_point(size = 5)
c <- c + xlab("Year") + ylab("Asts") + ggtitle("Assists by season")
c

grid.arrange(a, b, c, ncol=2)

### Standard Deviation calculations for first five years ###
both_first_five_by_season_sd = ddply(both_first_five_box, .(PLAYER, SEASON), numcolwise(sd, na.rm = TRUE))
both_first_five_by_season
both_first_five_by_season_cov = merge(player_first_five[,c("PLAYER","year", "SEASON","TRB","PTS", "AST")], both_first_five_by_season_sd[,c("PLAYER","SEASON","TRB","PTS", "AST")], by=c("PLAYER", "SEASON") )
attach(both_first_five_by_season_cov)
both_first_five_by_season_cov$PTS=both_first_five_by_season_cov$PTS.y/both_first_five_by_season_cov$PTS.x
both_first_five_by_season_cov$TRB=both_first_five_by_season_cov$TRB.y/both_first_five_by_season_cov$TRB.x
both_first_five_by_season_cov$AST=both_first_five_by_season_cov$AST.y/both_first_five_by_season_cov$AST.x

boxscores_2014 = subset(boxscores[order(-boxscores$PTS),], SEASON==2014)
player_per_game_by_season = read.csv("data/stats/player_per_game_by_season.csv")
mean_2014 = subset(player_per_game_by_season, SEASON==2014)
sd_2014 = ddply(boxscores_2014, .(PLAYER), numcolwise(sd, na.rm = TRUE))
cov_2014 = merge(mean_2014[,c("PLAYER", "TRB","PTS", "AST")], sd_2014[,c("PLAYER","TRB","PTS", "AST")], by=c("PLAYER") )
cov_2014$PTS=cov_2014$PTS.y/cov_2014$PTS.x
cov_2014$TRB=cov_2014$TRB.y/cov_2014$TRB.x
cov_2014$AST=cov_2014$AST.y/cov_2014$AST.x
head(cov_2014_analyze)
sapply(cov_2014_analyze, class)
cov_2014_analyze = cov_2014[,c("PTS","TRB","AST")]
#### Need to get averages of all, coming up NA with colMeans ####

d <- ggplot(data = both_first_five_by_season_cov, aes(x = year, y = PTS, col = PLAYER))
d <- d + geom_point(size = 5)
d <- d + xlab("Year") + ylab("Pts") + ggtitle("Points by season")
d

e <- ggplot(data = both_first_five_by_season_cov, aes(x = year, y = TRB, col = PLAYER))
e <- e + geom_point(size = 5)
e <- e + xlab("Year") + ylab("Rebs") + ggtitle("Rebounds by season")
e

f <- ggplot(data = both_first_five_by_season_cov, aes(x = year, y = AST, col = PLAYER))
f <- f + geom_point(size = 5)
f <- f + xlab("Year") + ylab("Asts") + ggtitle("Assists by season")
f

grid.arrange(d, e, f, ncol=2)

c <- ggplot(data = player_first_five, aes(x = year, y = DRtg, col = PLAYER))
c <- c + geom_point(size = 5)
c <- c + xlab("Year") + ylab("DRtg") + ggtitle("DRtg by season")
c

d <- ggplot(data = player_first_five, aes(x = year, y = minutes, col = PLAYER))
d <- d + geom_point(size = 5)
d <- d + xlab("Year") + ylab("Minutes") + ggtitle("Minutes by season")
d

# We can also take a look at their teams success in that time by merging the team_stats_by_season dataset.
team_stats_by_season = read.csv("data/stats/team_stats_by_season.csv")
head(team_stats_by_season)
player_first_five_team <- merge(player_first_five, team_stats_by_season, by.x=c("team", "SEASON"), by.y=c("team", "season"))
head(player_first_five_team)

e <- ggplot(data = player_first_five_team, aes(x = year, y = percent_w, col = PLAYER))
e <- e + geom_point(size = 5)
e <- e + xlab("Year") + ylab("Team Wins") + ggtitle("Team Wins by season")
e

grid.arrange(a, b, c, d, ncol=2)


player_per_game_by_season = read.csv("data/stats/player_per_game_by_season.csv")
player_per_game_by_season_team = read.csv("data/stats/player_per_game_by_season_team.csv")
team_per_game = read.csv("data/stats/team_per_game.csv")
team_per_game_by_season = read.csv("data/stats/team_per_game_by_season.csv")
home_v_away_per_game = read.csv("data/stats/home_v_away_per_game.csv")
home_v_away_per_game_by_season = read.csv("data/stats/home_v_away_per_game_by_season.csv")

player_salaries = read.csv("data/stats/player_salaries.csv")

team_salaries = read.csv("data/stats/team_salaries.csv")
team_salaries_by_season = read.csv("data/stats/team_salaries_by_season.csv")
