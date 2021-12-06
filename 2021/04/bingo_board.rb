# frozen_string_literal: true

# Bingo Board
class BingoBoard
	attr_reader :rows, :marked, :count_row, :count_col, :bingo_draw

	def initialize
		@rows = []
		@count_row = Hash.new { |h, k| h[k] = 0 }
		@count_col = Hash.new { |h, k| h[k] = 0 }
		@marked    = []
		@bingo_draw = 1
	end

	def empty? = rows.empty?
	def add_row(row) = rows << row
	def size = rows.length

	def mark(num)
		row = rows.find { |r| r.include? num }
		return unless row

		row_idx = rows.index row
		col_idx = row.index num

		marked << num
		count_row[row_idx] += 1
		count_col[col_idx] += 1
	end

	def bingo?
		bingo = (count_row.values.include?(size) && :row) || (count_col.values.include?(size) && :col)
		@bingo_draw += 1 unless bingo
		bingo
	end

	def unmarked = rows.flatten.difference(marked)
end

