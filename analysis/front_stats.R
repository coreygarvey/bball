# Stat of the week on SlamStats

setwd('/Users/cgarvey/Documents/NBA/bball/')
library(plyr)
library(ggplot2)
library(scatterplot3d)
library(reshape)
require(data.table)

boxscores = read.csv("data/stats/boxscores.csv")
player_info = read.csv("data/stats/player_info.csv")
head(player_info)
box_short = boxscores[,c("PLAYER", "FG", "FGA","FG.","TEAM","SEASON")]
box_subset = subset(box_short, FGA > 15)
box_merge = merge(player_info, box_subset, by.x=c("id"), by.y=c("PLAYER"))
box_merge["FG."] = round(box_merge["FG."]*100,2)
box_order = box_merge[order(-box_merge$FG.),] 
box_out = box_order[,c("name", "FG", "FGA", "FG.", "TEAM", "SEASON", "hofyear")]
colnames(box_out)=c("Name","FG","FGA","FG%","TEAM","SEASON","HOF")


box_out = head(box_out, 12)

### FGP CSV used in html ###
write.csv(box_out, file = sprintf("data/stats/front_stats/fgp.csv"), row.names=FALSE)

