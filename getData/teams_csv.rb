require 'rubygems'
require 'mechanize' 
require 'nokogiri'
require 'csv'


agent = Mechanize.new
# Dir.mkdir "boxScores"

team_headers = ["season", "team", "w", "l", "srs", "pace", "rel_pace", "ortg", "rel_ortg", "drtg", "rel_drtg", "playoffs", "coaches", "top_ws"]

schedpage = agent.get("http://www.basketball-reference.com/teams/").search('#active a').each do |team|
	
	# BOXSCORES ||  BOXSCORES ||  BOXSCORES ||  BOXSCORES
	team_link = team.attributes["href"].value

	puts team_link
	
	# Find team abbreviation in team link
	team_regex = /
		\/teams\/(?<team>[A-Z]{3})\/                 
	/x

	str = team_link
	parts = str.match(team_regex)
	team = parts['team']
	puts "Team Abbr: #{team}".strip

	team_page = agent.get('http://www.basketball-reference.com' + team_link)

	# CSV.open("../data/raw/basic.csv", 'a+', :write_headers => true, :headers => basic_headers) do |csv|
	CSV.open("../data/raw/teams.csv", 'a+', :write_headers => true, :headers => team_headers) do |csv|
		team_headers = nil
		columns = [1, 3, 4, 5, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17]
		# Team Data
		teamData = {}
		2.upto(30) do |j|
			columns.each { |i|
				teamData["teamArray#{i}"]=[]
				team_page.search("tr:nth-child(#{j}) td:nth-child(#{i})").each do |item|
					if (i==1)
						year = item.text.scan( /-([0-9]{2})$/).last.first.to_i
						if (year<50)
							stat = "20"+year.to_s.rjust(2,'0')
						else
							stat = "19"+year.to_s.rjust(2,'0')
						end
						stat = stat.to_i
						puts stat
					elsif (i==3)
						stat = item.children[0].attributes["href"].value
						stat = stat.scan( /\/teams\/([A-Z]{3})\/[0-9]{4}/).last.first
						puts stat
					else
						stat = item.text
					end

					if stat.nil?
						stat = ""
					end

					teamData["teamArray#{i}"] << stat
				end
			}
			basic_table_team =[]
			columns.each { |k|
				basic_table_team << teamData["teamArray#{k}"]
			}
			puts basic_table_team[1]
			basic_table_team = basic_table_team.transpose
		    basic_table_team.each do |row|
		        csv << row
		    end
		end
		
	end
	
	time = Time.now
	puts "Current Time : " + time.inspect

end


puts "Done!"

