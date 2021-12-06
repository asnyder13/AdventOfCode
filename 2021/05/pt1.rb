#!/usr/bin/env ruby
# frozen_string_literal: true

abort('Please provide input file') if ARGV.count.zero?
# This way sorbet gives at least _some_ hints.
input_lines = []
input_lines.concat ARGF.readlines(chomp: true).reject(&:empty?)

ranges = input_lines.map do |l|
	m = l.match /(\d+),(\d+) -> (\d+),(\d+)/
	m.captures.map(&:to_i)
end

Point = Struct.new(:x, :y) do
	def horizontal?(other) = y == other.y
	def vertical?(other) = x == other.x
end

# Line
class Line
	attr_reader :point1, :point2

	# Point, Point
	#   or
	# x1, y1, x2, y2
	def initialize(*args)
		@point1, @point2 = case args.length
		                   when 2
		                     [args.first, args.last]
		                   when 4
		                     [Point.new(args[0], args[1]), Point.new(args[2], args[3])]
		                   else
		                    throw 'Line: wrong number of args'
		                   end
	end

	def horizontal? = point1.horizontal?(point2)
	def vertical?   = point1.vertical?(point2)
	def straight?   = horizontal? || vertical?

	def coords
		x, y = to_straight_range

		if x.instance_of? Range
			x.map { [_1, y] }
		else
			y.map { [x, _1] }
		end
	end

		private

	def to_straight_range
		if horizontal?
			range = point1.x < point2.x ? (point1.x..point2.x) : (point2.x..point1.x)
			[range, point1.y]
		else
			range = point1.y < point2.y ? (point1.y..point2.y) : (point2.y..point1.y)
			[point1.x, range]
		end
	end
end

lines = ranges.map { Line.new(*_1) }.filter(&:straight)

sparse_grid = Hash.new { |h, k| h[k] = 0 }
lines.map(&:coords).each do |coords|
	coords.each { sparse_grid[_1] += 1 }
end
puts sparse_grid.values.count { _1 >= 2 }
