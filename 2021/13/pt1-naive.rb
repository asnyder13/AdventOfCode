#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pp'

abort('Please provide input file') if ARGV.count.zero?
# This way sorbet gives at least _some_ hints.
lines = []
file = File.open(ARGV.first, 'r')
# file = File.open('./input.txt', 'r')
lines.concat file.readlines(chomp: true).reject(&:empty?)

folds = []

pairs = []
lines.each do |l|
	next if l.empty?

	case l
	when /(\d+),(\d+)/
		x = $1.to_i
		y = $2.to_i
		pairs << { x:, y: }
	when /fold along ([xy])=(\d+)/
		folds << { axis: $1, val: $2.to_i }
	end
end

def fresh_matrix(height, width)
	cols = []
	fresh_row = Array.new width
	(0...height).each do |y|
		cols[y] = fresh_row.dup
	end

	cols
end

width  = pairs.map { _1[:x] }.max + 1
height = pairs.map { _1[:y] }.max + 1
initial_paper = fresh_matrix height, width

pairs.each do |pair|
	initial_paper[pair[:y]][pair[:x]] = true
end

def translate_axis(val, axis_val)
	return nil                            if val == axis_val
	return val                            if val < axis_val
	return (val - (2 * (val - axis_val))) if val > axis_val
end

current_paper = fresh_matrix height, width

# folds.each do |fold|
fold   = folds.first
axis   = fold[:axis]
ax_val = fold[:val]

initial_paper.each.with_index do |row, y|
	row.each.with_index do |marked, x|

		case axis
			# when 'x'
			#		new_x = translate_axis x, ax_val
			#		current_paper[new_x][y] = marked if new_x
		when 'y'
			new_y = translate_axis y, ax_val

			current_paper[new_y][x] ||= marked if new_y
		end
	end
end
initial_paper = current_paper.dup

# PP.pp initial_paper, $>, 10000
pp initial_paper.flatten.filter { _1 }.count
