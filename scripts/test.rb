require 'rubygems'
require 'mechanize' 
require 'nokogiri'
require 'csv'


agent = Mechanize.new
Dir.mkdir "boxScores"
Dir.mkdir "playByPlay"
Dir.mkdir "shotCharts"





schedpage = agent.get('http://www.basketball-reference.com/leagues/NBA_2000_games.html').search('#games td:nth-child(2)').each do |boxscore|

	basic_headers = ["PLAYER", "MP", "FG", "FGA", "FG%", "3P", "3PA", "3P%", "FT", "FTA", "FT%", "ORB", "DRB", "TRB", "AST", "STL", "BLK", "TOV", "PF", "PTS","+/-", "GAME", "HOME/AWAY", "TEAM"]
	adv_headers = ["PLAYER", "MP", "TS%", "eFG%", "ORB%", "DRB%", "TRB%", "AST%", "STL%", "BLK%", "TOV%", "USG%", "ORtg", "DRtg", "GAME", "HOME/AWAY", "TEAM"]
	
	# BOXSCORES ||  BOXSCORES ||  BOXSCORES ||  BOXSCORES
	boxscore_link = boxscore.children[0].attributes["href"].value
	
	# Find game abbreviation in boxscore link
	game_regex = /
		\/boxscores\/(?<game>.*)\.                 
	/x
	str = boxscore_link
	parts = str.match(game_regex)
	puts "Game: #{parts['game']}".strip

	boxpage = agent.get('http://www.basketball-reference.com' + boxscore_link)
	away_abbr = boxpage.search('.nav_table tr:nth-child(3) td:nth-child(1)').text
	home_abbr = boxpage.search('.nav_table tr:nth-child(4) td:nth-child(1)').text
	away_basic = boxpage.search("##{away_abbr}_basic")
	away_advanced = boxpage.search("##{away_abbr}_advanced")
	home_basic = boxpage.search("##{home_abbr}_basic")
	home_advanced = boxpage.search("##{home_abbr}_advanced")


	
	# BOXSCORE AWAY
	length_away = boxpage.search("##{away_abbr}_basic tbody td:nth-child(1)").length
	puts "length_away: #{length_away}"
	length_played_away = boxpage.search("##{away_abbr}_basic tbody td:nth-child(3)").length
	dnp_away = length_away - length_played_away

	# BOXSCORE HOME
	length_home = boxpage.search("##{home_abbr}_basic tbody td:nth-child(1)").length
	puts "length_home: #{length_home}"
	length_played_home = boxpage.search("##{home_abbr}_basic tbody td:nth-child(3)").length
	dnp_home = length_home - length_played_home

	CSV.open("boxScores/basic.csv", 'a+', :write_headers => true, :headers => basic_headers) do |csv|
		basic_headers = nil
		# BASIC AWAY
		statsData = {}
		1.upto(21) do |i|
			statsData["statsArray#{i}"]=[]
			boxpage.search("##{away_abbr}_basic tbody td:nth-child(#{i})").each do |item|
				if (i==1)
					stat = item.children[0].attributes["href"].value
					stat = stat.scan( /\/players\/.\/(.*)\./).last.first
				else
					stat = item.text
				end
				if (stat=="Did Not Play")
					stat = "DNP"
				end
				if (stat=="")
					stat = "N/A"
				end
				statsData["statsArray#{i}"] << stat
			end
			if (i > 2)
				1.upto(dnp_away) do |k|
					statsData["statsArray#{i}"] << "DNP"
				end
			end
		end
		22.upto(24) do |i|
			statsData["statsArray#{i}"]=[]
			1.upto(length_away) do |u|
				if (i == 22)
					statsData["statsArray#{i}"] << "#{parts['game']}"
				end
				if (i == 23)
					statsData["statsArray#{i}"] << "AWAY"
				end
				if (i == 24)
					statsData["statsArray#{i}"] << "#{away_abbr}"
				end
			end
		end
		basic_table_away =[]
		1.upto(24) do |j|
			basic_table_away << statsData["statsArray#{j}"]
		end
		basic_table_away = basic_table_away.transpose
	    basic_table_away.each do |row|
	        csv << row
	    end



		# BASIC HOME
		statsData = {}
		1.upto(21) do |i|
			statsData["statsArray#{i}"]=[]
			boxpage.search("##{home_abbr}_basic tbody td:nth-child(#{i})").each do |item|
				if (i==1)
					stat = item.children[0].attributes["href"].value
					stat = stat.scan( /\/players\/.\/(.*)\./).last.first
				else
					stat = item.text
				end
				if (stat=="Did Not Play")
					stat = "DNP"
				end
				if (stat=="")
					stat = "N/A"
				end
				statsData["statsArray#{i}"] << stat
			end
			if (i > 2)
				1.upto(dnp_home) do |k|
					statsData["statsArray#{i}"] << "DNP"
				end
			end
		end
		22.upto(24) do |i|
			statsData["statsArray#{i}"]=[]
			1.upto(length_home) do |u|
				if (i == 22)
					statsData["statsArray#{i}"] << "#{parts['game']}"
				end
				if (i == 23)
					statsData["statsArray#{i}"] << "HOME"
				end
				if (i == 24)
					statsData["statsArray#{i}"] << "#{home_abbr}"
				end
			end
		end
		basic_table_home =[]
		1.upto(24) do |j|
			basic_table_home << statsData["statsArray#{j}"]
		end
		basic_table_home = basic_table_home.transpose
	    basic_table_home.each do |row|
	        csv << row
	    end
	end
	
	CSV.open("boxScores/advanced.csv", 'ab', :write_headers => true, :headers => adv_headers) do |csv|
		adv_headers = nil
		# ADVANCED AWAY
		statsData = {}
		1.upto(14) do |i|
			statsData["statsArray#{i}"]=[]
			boxpage.search("##{away_abbr}_advanced tbody td:nth-child(#{i})").each do |item|
				if (i==1)
					stat = item.children[0].attributes["href"].value
					stat = stat.scan( /\/players\/.\/(.*)\./).last.first
				else
					stat = item.text
				end
				if (stat=="Did Not Play")
					stat = "DNP"
				end
				if (stat=="")
					stat = "N/A"
				end
				statsData["statsArray#{i}"] << stat
			end
			if (i > 2)
				1.upto(dnp_away) do |k|
					statsData["statsArray#{i}"] << "DNP"
				end
			end
		end
		15.upto(17) do |i|
			statsData["statsArray#{i}"]=[]
			1.upto(length_away) do |u|
				if (i == 15)
					statsData["statsArray#{i}"] << "#{parts['game']}"
				end
				if (i == 16)
					statsData["statsArray#{i}"] << "AWAY"
				end
				if (i == 17)
					statsData["statsArray#{i}"] << "#{away_abbr}"
				end
			end
		end
		adv_table_away =[]
		1.upto(17) do |j|
			adv_table_away << statsData["statsArray#{j}"]
		end
		adv_table_away = adv_table_away.transpose
	    adv_table_away.each do |row|
	        csv << row
	    end

		# ADVANCED HOME
		statsData = {}
		1.upto(14) do |i|
			statsData["statsArray#{i}"]=[]
			boxpage.search("##{home_abbr}_advanced tbody td:nth-child(#{i})").each do |item|
				if (i==1)
					stat = item.children[0].attributes["href"].value
					stat = stat.scan( /\/players\/.\/(.*)\./).last.first
				else
					stat = item.text
				end
				if (stat=="Did Not Play")
					stat = "DNP"
				end
				if (stat=="")
					stat = "N/A"
				end
				statsData["statsArray#{i}"] << stat
			end
			if (i > 2)
				1.upto(dnp_home) do |k|
					statsData["statsArray#{i}"] << "DNP"
				end
			end
		end
		15.upto(17) do |i|
			statsData["statsArray#{i}"]=[]
			1.upto(length_home) do |u|
				if (i == 15)
					statsData["statsArray#{i}"] << "#{parts['game']}"
				end
				if (i == 16)
					statsData["statsArray#{i}"] << "HOME"
				end
				if (i == 17)
					statsData["statsArray#{i}"] << "#{home_abbr}"
				end
			end
		end
		adv_table_home =[]
		1.upto(17) do |j|
			adv_table_home << statsData["statsArray#{j}"]
		end
		adv_table_home = adv_table_home.transpose
	    adv_table_home.each do |row|
	        csv << row
	    end
	end

	# PLAY BY PLAY
	play_by_play_link = boxpage.search('.margin_right:nth-child(2)').children[0].attributes["href"].value
	playByPlay_page = agent.get('http://www.basketball-reference.com' + play_by_play_link)
	playByPlay = File.new("playByPlay/#{parts['game']}.html", "w+")
	pbp = playByPlay_page.search('.stats_table:nth-child(3)')
	playByPlay.puts pbp

	# SHOT CHART
	shot_charts_link = boxpage.search('.padding:nth-child(3)').children[0].attributes["href"].value
	shotChart = agent.get('http://www.basketball-reference.com' + shot_charts_link)
	Dir.mkdir "shotCharts/#{parts['game']}"
	fileAway = File.new("shotCharts/#{parts['game']}/away.html", "w+")
	fileHome = File.new("shotCharts/#{parts['game']}/home.html", "w+")
	shotChartAway = shotChart.search("#shots-#{away_abbr}")
	shotChartHome = shotChart.search("#shots-#{home_abbr}")
	fileAway.puts shotChartAway
	fileHome.puts shotChartHome
	
	visitor = boxpage.search('.padding:nth-child(1) .large_text a').text
	visitor_points = boxpage.search('.stat_total td:nth-child(20)').first.text
	#puts visitor + ", PTS: " + visitor_points

	time = Time.now
	puts "Current Time : " + time.inspect
	sleep(2.9)
	time = Time.now
	puts "Current Time : " + time.inspect
end

puts "Done!"

