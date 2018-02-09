#!/usr/bin/env python
import dbconfig
import requests

# Define various headers for tables
basic_headers = ["PLAYER", "MP", "FG", "FGA", "FG%", "3P", "3PA", "3P%", "FT", "FTA", "FT%", "ORB", "DRB", "TRB", "AST", "STL", "BLK", "TOV", "PF", "PTS", "+/-", "GAME", "HOME/AWAY", "TEAM", "OPP", "SEASON"]
adv_headers = ["PLAYER", "MP", "TS%", "eFG%", "ORB%", "DRB%", "TRB%", "AST%", "STL%", "BLK%", "TOV%", "USG%", "ORtg", "DRtg", "GAME", "HOME/AWAY", "TEAM", "OPP", "SEASON"]

# Define database variables
db_host  = dbconfig.host
db_user  = dbconfig.user
db_pswd  = dbconfig.pswd
db_name = dbconfig.name

print "host"+db_host
print "user"+db_user
print "pswd"+db_pswd
print "name"+db_name