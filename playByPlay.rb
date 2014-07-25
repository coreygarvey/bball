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

		# Play By Play
		play_by_play_link = boxpage.search('.margin_right:nth-child(2)').children[0].attributes["href"].value
		playByPlay_page = agent.get('http://www.basketball-reference.com' + play_by_play_link)
		playByPlay = File.new("playByPlay/#{parts['game']}.html", "w+")
		pbp = playByPlay_page.search('.stats_table:nth-child(3)')
		playByPlay.puts pbp
		time = Time.now
		puts "Current Time : " + time.inspect

	end
end

puts "Done!"

