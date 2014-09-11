require 'rubygems'
require 'mechanize' 
require 'nokogiri'
require 'csv'
require 'mysql'


agent = Mechanize.new


player_ids = ["thomptr01"]

player_headers = ["id", "name", "fullname", "nickname", "twitter", "born", "position", "shoots", "heightft", "heightin", "weight", "bmonth", "bday", "byear", "bcity", "bstate", "bcountry", "hs", "hscity", "hsstate", "college", "draftteam", "draftround", "draftroundpick","draftoverall", "draftyear", "hofyear"]
salary_headers = ["id","season","team","salary"]
@db_host  = "localhost"
@db_user  = "root"
@db_pass  = ""
@db_name = "nba"
client = Mysql.new(@db_host, @db_user, @db_pass, @db_name)
for id in player_ids
	first_letter = id[0,1]

	playerPage = agent.get("http://www.basketball-reference.com/players/#{first_letter}/#{id}.html")

	# id
	id = id
	# Name
	name = playerPage.search('h1').text.gsub("'", %q(\\'))
	# Info
	info = playerPage.search('#info_box').text
	# Name Info
	nameInfo = playerPage.search('#info_box .margin_top').text.gsub("'", %q(\\'))
	# Full Name
	fullname = playerPage.search('#info_box .margin_top .bold_text').text.gsub("'", %q(\\'))
	# Nickname
	if !nameInfo.scan( /[^\n]\((.*)\)/).last.nil?
		nickname = nameInfo.scan( /[^\n]\((.*)\)/).last.first.gsub("'", %q(\\'))
		puts "nickname " + nickname
	else
		nickname = ""
	end
	# Twitter
	if !nameInfo.scan( /Twitter:\s(.*)\n/).last.nil?
		twitter = nameInfo.scan( /Twitter:\s(.*)\n/).last.first
	else
		twitter = ""
	end
	# Born name
	if !nameInfo.scan( /\(born\s(.*)\)/).last.nil?
		born = nameInfo.scan( /\(born\s(.*)\)/).last.first.gsub("'", %q(\\'))
	else
		bornname = ""
	end
	# Position
	position = info.scan( /Position:\s(.*).{3}Shoots/).last.first
	# Shoots
	shoots = info.scan( /Shoots:\s(.*)Height:/).last.first
	if !shoots.scan( /(\s)/).last.nil?
		shoots = shoots.gsub(/\s+/m, ' ').strip.split(" ").last
	end
	# Height Feet
	heightft = info.scan( /Height:\s(.*)-/).last.first
	# Height Inches
	heightin = info.scan( /-(.*).{3}Weight:/).last.first
	# Weight
	weight = info.scan( /Weight:\s(.*)\slbs/).last.first
	# Birth Month
	bmonth = info.scan( /Born:\s(.*)\s[0-9]+,/).last.first
	# Birth Day
	bday = info.scan( /Born:\s.*\s([0-9]+),/).last.first
	puts bday
	# Birth Year
	byear = info.scan( /Born:\s.*\s[0-9]+,\s(19[0-9]{2})\s/).last.first
	# Birth City
	if !info.scan( /Born:.*[0-9]{4}\sin\s(.*),/).last.nil?
		bcity = info.scan( /[0-9]{4}\sin\s(.*),/).last.first.gsub("'", %q(\\'))
		# High School City
		bstate = nil
		bcountry = nil
		# Birth State and Country
		playerPage.search('#info_box p a:nth-child(9)').each {|nd|  
			birthInfo = nd['href'] 
			puts birthInfo
			# Birth State
			if birthInfo.scan( /&state=(.*)/).first
				bstate = birthInfo.scan( /&state=(.*)/).last.first
				if bstate.length == 0
					bstate = ""
				end
			else
				bstate = ""
			end
			# Birth Country
			bcountry = birthInfo.scan( /\.cgi\?country=(.*)&state/).last.first
			
		}
	end

	# High School
	if !info.scan( /School:\s(.*)/).last.nil?

		hs = info.scan( /School:\s(.*)\sin/).last.first.gsub("'", %q(\\'))
		# High School City
		hscity = info.scan( /School:\s.*\sin\s(.*),/).last.first.gsub("'", %q(\\'))
		# High School State
		hsstate = info.scan( /School:\s.*\sin\s.*,\s(.*)\n/).last.first
		if !hsstate.scan( /Canada(.*)/).last.nil?
			hsstate = "Canada"
		end
	else
		hs = ""
		hscity = ""
		hsstate = ""
	end

	# College
	if !info.scan( /College:\s(.*)\n/).first.nil?
		college = info.scan( /College:\s(.*)\n/).last.first.gsub("'", %q(\\'))
	else
		college = ""
	end


	# Draft
	if !info.scan( /Draft:\s(.*)\n/).last.nil?
		# Draft Team
		draftteam = "'"+info.scan( /Draft:\s([^,]*),/).last.first+"'"
		# Draft Round
		draftround = info.scan( /Draft:[^1-5]*,\s([0-9]{1,2})[a-z]{2}/).last.first
		# Draft Round Pick
		draftroundpick = info.scan( /round\s\(([0-9]{1,2})[a-z]{2}/).last.first
		# Draft Overall Pick
		draftoverall = info.scan( /pick,\s([0-9]{1,3})[a-z]{2}/).last.first
		# Draft Year
		draftyear = info.scan( /overall\),\s([0-9]{4})\s/).last.first
	else
		draftteam = 'NULL'
		draftround = 'NULL'
		draftroundpick = 'NULL'
		draftoverall = 'NULL'
		draftyear = 'NULL'
	end

	# Hall of Fame
	if !info.scan( /Fame:\s(.*)\n/).first.nil?
		hofyear = info.scan( /as\sPlayer\sin\s([0-9]{4})\s/).last.first
	else
		hofyear = 'NULL'
	end

	puts id
	puts bday
	puts shoots
	insert = client.query("insert into players
	  (id, name, fullname, nickname, twitter, born, position, shoots, heightft, heightin, weight, bmonth, bday, byear, bcity, bstate, bcountry, hs, hscity, hsstate, college, draftteam, draftround, draftroundpick,draftoverall, draftyear, hofyear)
	  values ('#{id}', '#{name}', '#{fullname}', '#{nickname}', '#{twitter}', '#{born}', '#{position}', '#{shoots}', #{heightft}, #{heightin}, #{weight}, '#{bmonth}', #{bday}, #{byear}, '#{bcity}', '#{bstate}', '#{bcountry}', '#{hs}', '#{hscity}', '#{hsstate}', '#{college}', #{draftteam}, #{draftround}, #{draftroundpick}, #{draftoverall}, #{draftyear}, #{hofyear})")



end




# Salaries


puts "Done!"




# create table players (id varchar(10), name varchar(30), fullname varchar(50), nickname varchar(70), twitter varchar(50), born varchar(60), position varchar(50), shoots varchar(5), heightft tinyint, heightin tinyint, weight int, bmonth varchar(10), bday tinyint, byear int, bcity varchar(50), bstate char(2), bcountry char(2), hs varchar(100), hscity varchar(30), hsstate varchar(40), college varchar(80), draftteam varchar(40), draftround tinyint, draftroundpick tinyint,draftoverall int, draftyear int, hofyear int)


