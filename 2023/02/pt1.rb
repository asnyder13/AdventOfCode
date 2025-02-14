#!/usr/bin/env ruby
# frozen_string_literal: true

input_file = ARGV.first || 'testinput.txt'
file = File.open(input_file, 'r')

Pull = Struct.new(:num, :color)
Game = Struct.new(:num, :pulls)

games = []
file.readlines(chomp: true).map do |line|
	/Game (?<gamenum>\d+):/ =~ line
	games << Game.new(gamenum.to_i, [])

	line.split(':').last.split(';').each do |pull|
		last_pulls = (games.last.pulls << []).last
		pull.split(',').each do |hand|
			/(?<num>\d+) (?<color>\w+)/ =~ hand
			last_pulls << Pull.new(num: num.to_i, color:)
		end
	end
end

bag_info = {
	'red' => 12,
	'green' => 13,
	'blue' => 14,
}

game_ids = games.reject do |game|
	game.pulls.any? do |pull|
		pull.any? { _1.num > bag_info[_1.color] }
	end
end.map(&:num)

puts game_ids.sum
