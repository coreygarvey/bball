setwd('/Users/cgarvey/Documents/NBA/bball/')
library(plyr)
library(ggplot2)
library(scatterplot3d)
library(reshape)
library(gridExtra)

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

# Filter data to get the PLAYER attribute of Duncan and Garnett from basketball-reference.com.
duncan_box = subset(boxscores, PLAYER=="duncati01")
garnett_box = subset(boxscores, PLAYER=="garneke01")
both_box = subset(boxscores, PLAYER=="duncati01"|PLAYER=="garneke01")

# Check out that the filter was shows what I expect, every regular season game boxscore.
head(duncan_box) 

# Let's look at some career data using the player_per_game table.
both_career = subset(player_per_game, PLAYER=="duncati01"|PLAYER=="garneke01")
head(both_career)

# Look at height and weight
head(player_info)
both_info = subset(player_info, id=="duncati01"|id=="garneke01")
head(both_info)

# Duncan has almost 30 pounds on Garnett, which helps explain the edge in rebounds and blocks.
# Filter for first 5 years, 1998-2002 for Duncan and 1996-2000 for Garnett, using the boxscore data then get averages for those first five years.
head(both_box)

# Merge with salaries
head(player_salaries_by_season)
both_salary = subset(player_salaries_by_season, id=="duncati01"|id=="garneke01")
head(both_salary,40)

total_salaries = ddply(both_salary, .(id), summarize, feq=length(id), total=sum(salary))
head(total_salaries)
data, .(Y), summarize, freq=length(Y), tot=sum(income)

# Let's break data down for first 5 seasons and add salaries
both_first_five_box = subset(both_box, PLAYER=="duncati01" & SEASON<2003 | PLAYER=="garneke01" & SEASON<2001)
both_first_five_by_season = ddply(both_first_five_box, .(PLAYER, SEASON), numcolwise(mean, na.rm = TRUE))
player_first_five <- merge(both_first_five_by_season, both_salary, by.x=c("PLAYER", "SEASON"), by.y=c("id", "season"))
head(player_first_five, 10)

# A few interesting points here. First, Duncan was a maniac right out of the gate, averaging 21 points, 12 boards and 2.7 assists as a rookie. The next 4 years simply confirmed his place in the NBA elite.
# Next, look at the year 4 salary jump. Amazingly, Garnett didn't average 20 points or 10 rebounds in any of his first three years in the league, a feat Duncancan accomplished his first 8 seasons. Garnett's DRtg is the big differentiator, an outstanding 108 his rookie year. Minnesota paid Garnett $14 milliion, 43% of their $25 million salary. San Antonio paid Duncan $9.6 million, 16% of their $57 million. 
a <- ggplot(data = player_first_five, aes(x = SEASON, y = PTS, col = PLAYER))
a <- a + geom_point(size = 5)
a <- a + xlab("Season") + ylab("Pts") + ggtitle("Points by season")
a

b <- ggplot(data = player_first_five, aes(x = SEASON, y = TRB, col = PLAYER))
b <- b + geom_point(size = 5)
b <- b + xlab("Season") + ylab("Rebs") + ggtitle("Rebs by season")
b

c <- ggplot(data = player_first_five, aes(x = SEASON, y = DRtg, col = PLAYER))
c <- c + geom_point(size = 5)
c <- c + xlab("Season") + ylab("DRtg") + ggtitle("DRtg by season")
c

grid.arrange(a, b, c,  ncol=2)

# We can also take a look at their teams success in that time by merging the team_stats_by_season dataset.
head(team_stats_by_season)
player_first_five_team <- merge(player_first_five, team_stats_by_season, by.x=c("team", "SEASON"), by.y=c("team", "season"))
head(player_first_five_team)

d <- ggplot(data = player_first_five_team, aes(x = SEASON, y = percent_w, col = PLAYER))
d <- d + geom_point(size = 5)
d <- d + xlab("Season") + ylab("Team Wins") + ggtitle("Team Wins by season")
d

grid.arrange(a, b, c, d, ncol=2)









head(player_first_five_team, 10)


first_five_w_salaries <- merge(ppg_first_five, both_salary, by.x=c("PLAYER", "SEASON"), by.y=c("id", "season"))
head(first_five_w_salaries)
both_by_season = ddply(both_box, .(PLAYER, SEASON), numcolwise(mean, na.rm = TRUE))
head(both_by_season,50)


boxscores_2014 = subset(boxscores[order(-boxscores$PTS),], SEASON==2014)


