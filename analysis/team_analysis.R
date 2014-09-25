##### TEAM ANALYSIS #####
team_stats_by_season = read.csv("data/raw/teams.csv")
team_stats_2014 = subset(team_stats_by_season, season==2014)
head(team_stats_by_season, 30)
teamstatsdrops <- c("X")
team_stats_by_season <- team_stats_by_season[,!(names(team_stats_by_season) %in% teamstatsdrops)]

lapply(team_stats_by_season, class)
summary(team_stats_by_season$playoffs)

#### Replace playoff results with point values ####
team_stats_by_season[,12]= sub("^$", "0", team_stats_by_season[,12])
team_stats_by_season[,12]= sub(".*1st.*", "1", team_stats_by_season[,12])
team_stats_by_season[,12]= sub(".*Semis", "2", team_stats_by_season[,12])
team_stats_by_season[,12]= sub(".*Conf\\.\\sFinals", "3", team_stats_by_season[,12])
team_stats_by_season[,12]= sub("Lost\\sFinals", "4", team_stats_by_season[,12])
team_stats_by_season[,12]= sub("Won.*", "5", team_stats_by_season[,12])
team_stats_by_season$percent_w = team_stats_by_season$w/(team_stats_by_season$w+team_stats_by_season$l)
head(team_stats_by_season[order(-team_stats_by_season$w),])
head(team_stats_by_season, 30)

#### Load salaries ####
team_salaries_by_season = read.csv("data/stats/team_salaries_by_season.csv")
head(team_salaries_by_season, 40)

#### Remove x from salaries and join Salaries with Stats ####
teamsalarydrops <- c("X")
team_salaries_by_season <- team_salaries_by_season[,!(names(team_salaries_by_season) %in% teamsalarydrops)]
head(team_salaries_by_season)
teams_with_salaries <- merge(team_salaries_by_season, team_stats_by_season, by=c("team", "season"))
head(teams_with_salaries)

#### League salaries ####
total_salaries <- ddply(teams_with_salaries, c("season"), summarise, 
                        league_salary = sum(as.numeric(total_salary)))
head(total_salaries)

#### Join league salaries with team to find relative salary ####
team_salaries_by_season <- merge(teams_with_salaries, total_salaries, by=c("season"))
team_salaries_by_season$salary_percentage <- team_salaries_by_season$total_salary/team_salaries_by_season$league_salary*100
head(team_salaries_by_season)

#### Filter for playoff teams ####
playoff_teams = subset(team_salaries_by_season, playoffs>0)
head(playoff_teams, 30)


team_stats_by_season$success = team_stats_by_season$percent_w + max(team_stats_by_season$percent_w)*as.numeric(team_stats_by_season$playoffs)/5
playoff_teams$success = playoff_teams$percent_w + max(playoff_teams$percent_w)*as.numeric(playoff_teams$playoffs)/5
head(playoff_teams)
playoff_teams$cov = playoff_teams$sd_salary/playoff_teams$mean_salary
playoff_teams$identifier = paste(playoff_teams$season,playoff_teams$team)
head(playoff_teams)

head(playoff_teams[order(-playoff_teams$cov),])

attach(playoff_teams)
plot(playoff_teams$salary_percentage, playoff_teams$success)

playoffdata <- ddply(playoff_teams, c("season", "playoffs"), summarise, 
                     mean_w = mean(percent_w),
                     mean_salary = mean(total_salary))
head(playoffdata)

head(playoff_teams)
lm.fit=lm(success~cov+salary_percentage+rel_drtg+rel_ortg+rel_pace+srs+season, data=playoff_teams)
summary(lm.fit)

# Breakdowns by advancement in the playoffs
teams_first = subset(playoff_teams, playoffs==1)
teams_second = subset(playoff_teams, playoffs==2)
teams_third = subset(playoff_teams, playoffs==3)
teams_fourth = subset(playoff_teams, playoffs==4)
teams_fifth = subset(playoff_teams, playoffs==5)
head(teams_first)
par(mfrow=c(1,1))
plot(teams_first$percent_w, teams_first$salary_percentage)
identify(teams_first$percent_w,teams_first$salary_percentage,labels=teams_first$identifier,plot=TRUE)
plot(teams_second$percent_w, teams_second$salary_percentage)
identify(teams_second$percent_w,teams_second$salary_percentage,labels=teams_second$identifier,plot=TRUE)
plot(teams_third$percent_w, teams_third$salary_percentage)
identify(teams_third$percent_w,teams_third$salary_percentage,labels=teams_third$identifier,plot=TRUE)
plot(teams_fourth$percent_w, teams_fourth$salary_percentage)
identify(teams_fourth$percent_w,teams_fourth$salary_percentage,labels=teams_fourth$identifier,plot=TRUE)
plot(teams_fifth$percent_w, teams_fifth$salary_percentage)
identify(teams_fifth$percent_w,teams_fifth$salary_percentage,labels=teams_fifth$identifier,plot=TRUE)


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



teams_2014 = subset(teams_with_salaries, season==2014)
ggplot(NULL, aes(teams_2014$percent_w,teams_2014$sd_salary))+geom_point(data = teams_2014, col="red")+geom_text(aes(label=teams_2014$team),hjust=0, vjust=0)+stat_smooth(method="lm", se=FALSE)
teams_2013 = subset(teams_with_salaries, season==2013)
ggplot(NULL, aes(teams_2013$percent_w,teams_2013$sd_salary))+geom_point(data = teams_2013, col="red")+geom_text(aes(label=teams_2014$team),hjust=0, vjust=0)+stat_smooth(method="lm", se=FALSE)
