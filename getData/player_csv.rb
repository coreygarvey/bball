require 'rubygems'
require 'mechanize' 
require 'nokogiri'
require 'csv'
require 'mysql'


agent = Mechanize.new


player_ids = []
CSV.foreach("../data/raw/players.csv"){ |row| player_ids << row[1]}

player_headers = ["id", "name", "fullname", "nickname", "twitter", "born", "position", "shoots", "heightft", "heightin", "weight", "bmonth", "bday", "byear", "bcity", "bstate", "bcountry", "hs", "hscity", "hsstate", "college", "draftteam", "draftround", "draftroundpick","draftoverall", "draftyear", "hofyear"]
salary_headers = ["id","season","team","salary"]
for id in player_ids
	first_letter = id[0,1]

	playerPage = agent.get("http://www.basketball-reference.com/players/#{first_letter}/#{id}.html")	
	CSV.open("../data/raw/playerInfo.csv", 'a+', :write_headers => true, :headers => player_headers) do |csv|
	
		player_headers = nil
		row = [id]
		# id
		puts "id " + id
		# Name
		name = playerPage.search('h1').text
		puts "name " + name
		row << name
		# Info
		info = playerPage.search('#info_box').text
		puts "info " + info
		# Name Info
		nameInfo = playerPage.search('#info_box .margin_top').text
		puts "name Info " + nameInfo
		# Full Name
		fullName = playerPage.search('#info_box .margin_top .bold_text').text
		puts "full name " + fullName
		row << fullName
		# Nickname
		if !nameInfo.scan( /[^\n]\((.*)\)/).last.nil?
			nickname = nameInfo.scan( /[^\n]\((.*)\)/).last.first
			puts "nickname " + nickname
			row << nickname
		else
			nickname = ""
			row << nickname
		end
		# Twitter
		if !nameInfo.scan( /Twitter:\s(.*)\n/).last.nil?
			twitter = nameInfo.scan( /Twitter:\s(.*)\n/).last.first
			puts "twitter " + twitter
			row << twitter
		else
			twitter = ""
			row << twitter
		end
		# Born name
		if !nameInfo.scan( /\(born\s(.*)\)/).last.nil?
			bornname = nameInfo.scan( /\(born\s(.*)\)/).last.first
			puts "bornname " + bornname
			row << bornname
		else
			bornname = ""
			row << bornname
		end
		# Position
		position = info.scan( /Position:\s(.*).{3}Shoots/).last.first
		puts "position " + position
		row << position
		# Shoots
		shoots = info.scan( /Shoots:\s(.*)Height:/).last.first
		puts "shoots " + shoots
		row << shoots
		# Height Feet
		heightft = info.scan( /Height:\s(.*)-/).last.first
		puts "height ft " + heightft
		row << heightft
		# Height Inches
		heightin = info.scan( /-(.*).{3}Weight:/).last.first
		puts "height in " + heightin
		row << heightin
		# Weight
		weight = info.scan( /Weight:\s(.*)\slbs/).last.first
		puts "weight " + weight
		row << weight
		# Birth Month
		bmonth = info.scan( /Born:\s(.*)\s[0-9]*,/).last.first
		puts "birth month " + bmonth
		row << bmonth
		# Birth Day
		bday = info.scan( /Born:\s.*\s([0-9]*),/).last.first
		puts "birth day " + bday
		row << bday
		# Birth Year
		byear = info.scan( /Born:\s.*\s[0-9]*,\s(19[0-9]{2})\s/).last.first
		puts "birth year " + byear
		row << byear
		# Birth City
		if !info.scan( /Born:.*[0-9]{4}\sin\s(.*),/).last.nil?
			bcity = info.scan( /[0-9]{4}\sin\s(.*),/).last.first
			puts "birth city " + bcity
			row << bcity
		
			# Birth State and Country
			playerPage.search('#info_box p a:nth-child(9)').each {|nd|  
				puts "HOW BOUT IT!"
				puts nd
				birthInfo = nd['href'] 
				# Birth State
				if birthInfo.scan( /&state=(.*)/).first
					bstate = birthInfo.scan( /&state=(.*)/).last.first
					puts "birth state " + bstate
				else
					bstate = ""
				end
				row << bstate	
				# Birth Country
				bcountry = birthInfo.scan( /\.cgi\?country=(.*)&state/).last.first
				puts "birth country " + bcountry
				row << bcountry
			}
		end
		# High School
		if !info.scan( /School:\s(.*)/).last.nil?

			hs = info.scan( /School:\s(.*)\sin/).last.first
			puts "high school " + hs
			# High School City
			hscity = info.scan( /School:\s.*\sin\s(.*),/).last.first
			puts "high school city " + hscity
			# High School State
			hsstate = info.scan( /School:\s.*\sin\s.*,\s(.*)\n/).last.first
			puts "high school state " + hsstate
		else
			hs = ""
			hscity = ""
			hsstate = ""
		end
		row << hs
		row << hscity
		row << hsstate
		# College
		if !info.scan( /College:\s(.*)\n/).first.nil?
			college = info.scan( /College:\s(.*)\n/).last.first
			puts "college " + college
		else
			college = ""
		end
		row << college

		# Draft
		if !info.scan( /Draft:\s(.*)\n/).last.nil?
			# Draft Team
			draftteam = info.scan( /Draft:\s([^,]*),/).last.first
			puts "draft team " + draftteam
			# Draft Round
			draftround = info.scan( /Draft:[^1-5]*,\s([0-9]{1,2})[a-z]{2}/).last.first
			puts "draft round " + draftround
			# Draft Round Pick
			draftroundpick = info.scan( /round\s\(([0-9]{1,2})[a-z]{2}/).last.first
			puts "draft round pick " + draftroundpick
			# Draft Overall Pick
			draftoverall = info.scan( /pick,\s([0-9]{1,3})[a-z]{2}/).last.first
			puts "draftoverall " + draftoverall
			# Draft Year
			draftyear = info.scan( /overall\),\s([0-9]{4})\s/).last.first
			puts "draft year " + draftyear
		else
			draftteam = ""
			draftround = ""
			draftroundpick = ""
			draftoverall = ""
			draftyear = ""
		end
		row << draftteam
		row << draftround
		row << draftroundpick
		row << draftoverall
		row << draftyear
		# Hall of Fame
		if !info.scan( /Fame:\s(.*)\n/).first.nil?
			hofyear = info.scan( /as\sPlayer\sin\s([0-9]{4})\s/).last.first
			puts "hof year " + hofyear
		else
			hofyear = ""
		end
		row << hofyear
		puts row
		csv << row
	end
	# Salaries
	salaries = playerPage.search("#salaries")
	CSV.open("../data/raw/playerSalaries.csv", 'a+', :write_headers => true, :headers => salary_headers) do |csv|
		salary_headers = nil
		statsData = {}
		1.upto(4) do |i|
			statsData["statsArray#{i}"]=[]
			playerPage.search("#salaries tbody td:nth-child(#{i})").each do |item|
				if (i==1)
					year = item.text.scan( /-([0-9]{2})$/).last.first.to_i
					if (year<50)
						stat = "20"+year.to_s.rjust(2,'0')
					else
						stat = "19"+year.to_s.rjust(2,'0')
					end
					stat = stat.to_i
					puts stat
				end
				if (i==2)
					stat = item.children[0].attributes["href"].value
					stat = stat.scan( /\/teams\/([A-Z]{3})\/[0-9]{4}/).last.first
					puts stat
				end
				if (i==3)
					stat = id
					puts stat
				end
				if (i==4)
					stat = item.attributes["csk"].value
					puts stat
				end
				statsData["statsArray#{i}"] << stat
			end
		end
		salaries_table =[]
		1.upto(4) do |j|
			salaries_table << statsData["statsArray#{j}"]
		end
		salaries_table = salaries_table.transpose
	    salaries_table.each do |row|
	        csv << row
	    end
	end

end





# Salaries


puts "Done!"
