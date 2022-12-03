#!/usr/bin/env ruby
# frozen_string_literal: true

require 'matrix'

abort('Please provide input file') if ARGV.count.zero?
# This way sorbet gives at least _some_ hints.
lines = []
file = File.open(ARGV.first, 'r')
lines.concat file.readlines(chomp: true).reject(&:empty?)

folds = []
pairs = []

lines.each do |l|
	next if l.empty?

	case l
	when /(\d+),(\d+)/
		pairs << { x: $1.to_i, y: $2.to_i }
	when /fold along ([xy])=(\d+)/
		folds << { axis: $1, val: $2.to_i }
	end
end

width  = pairs.map { _1[:x] }.max + 1
height = pairs.map { _1[:y] }.max + 1

matrix = Matrix.build(height, width) { 0 }

pairs.each do |pair|
	# i, j or down, across
	matrix[pair[:y], pair[:x]] = 1
end

def translate_axis(val, axis_val)
	return nil                            if val == axis_val
	return val                            if val < axis_val
	return (val - (2 * (val - axis_val))) if val > axis_val
end

row_count    = matrix.row_count
column_count = matrix.column_count

fold   = folds.first
axis   = fold[:axis]
ax_val = fold[:val]

case axis
when 'x'
	(0...column_count).each do |x|
		new_x = translate_axis x, ax_val
		row_count.times.each do |y|
			if new_x.nil?
				matrix[y, x] = 0
			else
				val = matrix[y, x]
				matrix[y, new_x] = val unless val.zero?
				matrix[y,     x] = 0 if new_x < x
			end
		end
	end
when 'y'
	(0...row_count).each do |y|
		new_y = translate_axis y, ax_val
		column_count.times.each do |x|
			if new_y.nil?
				matrix[y, x] = 0
			else
				val = matrix[y, x]
				matrix[new_y, x] = val unless val.zero?
				matrix[y,     x] = 0 if new_y < y
			end
		end
	end
end

puts matrix.each.sum
