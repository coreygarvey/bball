setwd('/Users/cgarvey/Documents/NBA/bball/')
library(plyr)
library(ggplot2)
library(scatterplot3d)
library(reshape)
library(gridExtra)

article_name = "duncanvsgarnett"
player1 = "duncati01"
player2 = "garneke01"

# Look at player details.
player_info = read.csv("data/stats/player_info.csv")
head(player_info)
both_info = subset(player_info, id==player1|id==player2)
# Which columns?
names(both_info)
columns = c("name","shoots","heightft","heightin","weight","bmonth","bday","byear","bcity","bstate","bcountry","hs","hscity","hsstate","college","draftteam","draftoverall","draftyear")
both_info = both_info[,columns]
head(both_info)

# Filter data to get the PLAYER attribute of Duncan and Garnett from basketball-reference.com.
boxscores = read.csv("data/stats/boxscores.csv")
player1_box = subset(boxscores, PLAYER==player1)
player2_box = subset(boxscores, PLAYER==player2)
both_box = subset(boxscores, PLAYER==player1|PLAYER==player2)
head(both_box)

# Check out that the filter was shows what I expect, every regular season game boxscore.
head(player1_box) 

# Let's look at some career data using the player_per_game table.
player_per_game = read.csv("data/stats/player_per_game.csv")
both_career = subset(player_per_game, PLAYER==player1|PLAYER==player2)
head(both_career)
names(both_career)
columns = c("PLAYER","FG","FGA","FG.","X3P","X3PA","X3P.","FT","FTA","FT.","ORB","DRB","TRB","AST","STL","BLK","TOV","PF","PTS","minutes")
both_career = both_career[,columns]
head(both_career)
both_career[,-1] <-round(both_career[,-1],1)
head(both_career)


# Duncan has almost 30 pounds on Garnett, which helps explain the edge in rebounds and blocks.
# Filter for first 5 years, 1998-2002 for Duncan and 1996-2000 for Garnett, using the boxscore data then get averages for those first five years.
head(both_box)

# Players
players <- player_info[,c("id","name")]
head(players, 50)
names(players)

# Merge players with salaries
player_salaries_by_season = read.csv("data/stats/player_salaries_by_season.csv")
head(player_salaries_by_season)
both_salaries = subset(player_salaries_by_season, id==player1|id==player2)
both_salaries = merge(players, both_salaries, by=c("id"))
both_salaries["salary"] = round(both_salaries["salary"]/1000000,2)
head(both_salaries)
player1_salary = subset(both_salaries, id==player1)
player2_salary = subset(both_salaries, id==player2)
head(both_salary,40)
names(both_salary)

# Get name, season, team and salary columns for blog
player1_salary_out = player1_salary[,c("name","season", "team", "salary")]
player1_salary_out = player1_salary_out[ order(player1_salary_out[,2]),]
player2_salary_out = player2_salary[,c("name","season", "team", "salary")]
player2_salary_out = player2_salary_out[ order(player2_salary_out[,2]),]

head(player1_salary_out)

colnames(player2_salary_out)=c("Name","Season","Team","Salary (millions)")
colnames(player1_salary_out)=c("Name","Season","Team","Salary (millions)")
head(player1_salary_out)
head(player2_salary_out)

# Save Files
dir.create(sprintf("data/stats/articles/%s", article_name), showWarnings = TRUE, recursive = FALSE)
write.csv(player1_salary_out, file = sprintf("data/stats/articles/%s/%s.csv", article_name, player1), row.names=FALSE)
write.csv(player2_salary_out, file = sprintf("data/stats/articles/%s/%s.csv", article_name, player2), row.names=FALSE)

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




player_per_game_by_season = read.csv("data/stats/player_per_game_by_season.csv")
player_per_game_by_season_team = read.csv("data/stats/player_per_game_by_season_team.csv")
team_per_game = read.csv("data/stats/team_per_game.csv")
team_per_game_by_season = read.csv("data/stats/team_per_game_by_season.csv")
home_v_away_per_game = read.csv("data/stats/home_v_away_per_game.csv")
home_v_away_per_game_by_season = read.csv("data/stats/home_v_away_per_game_by_season.csv")

player_salaries = read.csv("data/stats/player_salaries.csv")

team_salaries = read.csv("data/stats/team_salaries.csv")
team_salaries_by_season = read.csv("data/stats/team_salaries_by_season.csv")
team_stats_by_season = read.csv("data/stats/team_stats_by_season.csv")
