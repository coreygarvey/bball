require 'rubygems'
require 'mechanize' 
require 'nokogiri'
require 'csv'


agent = Mechanize.new
Dir.mkdir "shotCharts"


for y in 2001..2014
	
	
	schedpage = agent.get("http://www.basketball-reference.com/leagues/NBA_#{y}_games.html").search('#games td:nth-child(2)').each do |boxscore|
		
		# BOXSCORES ||  BOXSCORES ||  BOXSCORES ||  BOXSCORES
		boxscore_link = boxscore.children[0].attributes["href"].value
		
		# Find game abbreviation in boxscore link
		game_regex = /
			\/boxscores\/(?<game>.*)\.                 
		/x

		str = boxscore_link
		parts = str.match(game_regex)
		game = parts['game']

		boxpage = agent.get('http://www.basketball-reference.com' + boxscore_link)
		
		# Shot Chart
		shot_charts_link = boxpage.search('.padding:nth-child(3)').children[0].attributes["href"].value
		shotChart = agent.get('http://www.basketball-reference.com' + shot_charts_link)
		Dir.mkdir "../shotCharts/#{parts['game']}"
		fileAway = File.new("shotCharts/#{parts['game']}/away.html", "w+")
		fileHome = File.new("shotCharts/#{parts['game']}/home.html", "w+")
		shotChartAway = shotChart.search("#shots-#{away_abbr}")
		shotChartHome = shotChart.search("#shots-#{home_abbr}")
		fileAway.puts shotChartAway
		fileHome.puts shotChartHome
		time = Time.now
		puts "Current Time : " + time.inspect

	end
end

puts "Done!"

