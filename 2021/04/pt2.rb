#!/usr/bin/env ruby
# frozen_string_literal: true

abort('Please provide input file') if ARGV.count.zero?
# This way sorbet gives at least _some_ hints.
lines = []
lines.concat ARGF.readlines(chomp: true)

# Bingo Board
class BingoBoard
	attr_reader :rows, :marked, :count_row, :count_col, :bingo_draw

	def initialize
		@rows = []
		@count_row = Hash.new { |h, k| h[k] = 0 }
		@count_col = Hash.new { |h, k| h[k] = 0 }
		@marked    = Hash.new { |h, k| h[k] = false }
		@bingo_draw = 1
	end

	def empty? = rows.empty?
	def add_row(row) = rows << row
	def size = rows.length

	def mark(num)
		row = rows.detect { |r| r.include? num }
		return unless row

		row_idx = rows.index row
		col_idx = row.index num

		marked[[row_idx, col_idx]] = true
		count_row[row_idx] += 1
		count_col[col_idx] += 1
	end

	def bingo?
		bingo = (count_row.values.include?(size) && :row) || (count_col.values.include?(size) && :col)
		@bingo_draw += 1 unless bingo
		bingo
	end

	def unmarked
		result = []
		rows.each.with_index do |row, ir|
			row.each.with_index do |num, ic|
				result << num unless @marked.key? [ir, ic]
			end
		end
		result
	end
end

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
numbers.each do |n|
	boards.each { _1.mark n }
	last_num = n
	break if boards.map(&:bingo?).all?
end

last_bingo_board = boards.max_by(&:bingo_draw)
puts last_bingo_board.unmarked.reduce(:+) * last_num
