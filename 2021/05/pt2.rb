#!/usr/bin/env ruby
# frozen_string_literal: true

abort('Please provide input file') if ARGV.count.zero?
# This way sorbet gives at least _some_ hints.
input_lines = []
input_lines.concat ARGF.readlines(chomp: true).reject(&:empty?)

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
	def diagonal?   = !straight?

	def coords = straight? ? straight_coords : diag_coords

		private

	def straight_coords
		x, y = to_straight_range

		if x.instance_of? Range
			x.map { [_1, y] }
		else
			y.map { [x, _1] }
		end
	end

	def diag_coords
		x, y = to_diag_enums
		x.zip y
	end

	def to_straight_range
		if horizontal?
			range = point1.x < point2.x ? (point1.x..point2.x) : (point2.x..point1.x)
			[range, point1.y]
		else
			range = point1.y < point2.y ? (point1.y..point2.y) : (point2.y..point1.y)
			[point1.x, range]
		end
	end

	def to_diag_enums
		p1x, p1y, p2x, p2y = point1.x, point1.y, point2.x, point2.y
		x = p1x > p2x ? p1x.downto(p2x) : p1x.upto(p2x)
		y = p1y > p2y ? p1y.downto(p2y) : p1y.upto(p2y)
		[x, y]
	end
end

lines = input_lines.map do |l|
	match = l.match /(\d+),(\d+) -> (\d+),(\d+)/
	points = match.captures.map(&:to_i)
	Line.new(*points)
end

sparse_grid = Hash.new { |h, k| h[k] = 0 }
lines.map(&:coords).each { |coords| coords.each { sparse_grid[_1] += 1 } }

puts sparse_grid.values.count { _1 >= 2 }
