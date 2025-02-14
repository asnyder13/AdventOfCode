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

def min_cube_count(game)
	counts = Hash.new(0)
	game.pulls.each do |pull|
		pull.each do |hand|
			counts[hand.color] = [counts[hand.color], hand.num].max
		end
	end
	counts
end

puts games.map { min_cube_count(_1).values.reduce(&:*) }.sum
