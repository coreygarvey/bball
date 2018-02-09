LOAD DATA LOCAL INFILE 'data/raw/players.csv'
INTO TABLE players
FIELDS TERMINATED BY ','
    ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id,name,fullname,nickname,twitter,born,position,shoots,heightft,heightin,weight,bmonth,bday,byear,bcity,bstate,bcountry,hs,hscity,hsstate,college,draftteam,draftround,draftroundpick,draftoverall,draftyear,hofyear)