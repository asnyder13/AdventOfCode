#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative './bingo_board'

abort('Please provide input file') if ARGV.count.zero?
# This way sorbet gives at least _some_ hints.
lines = []
lines.concat ARGF.readlines(chomp: true)

numbers = lines.shift.split(',').map(&:to_i)
boards = []
lines.each do |l|
	if l.empty?
		boards << BingoBoard.new
		next
	end

	boards.last.add_row l.split.map(&:to_i)
end
boards.pop if boards.last.empty?

last_num = -1
marked_nums = []
numbers.each do |n|
	boards.each { _1.mark n }
	marked_nums << last_num = n
	break if boards.map(&:bingo?).all?
end

last_bingo_board = boards.max_by(&:bingo_draw)
puts last_bingo_board.unmarked.reduce(:+) * last_num
