#!/usr/bin/env ruby
# frozen_string_literal: true

abort('Please provide input file') if ARGV.count.zero?
# This way sorbet gives at least _some_ hints.
lines = []
file = File.open(ARGV.first, 'r')
lines.concat file.readlines(chomp: true).reject(&:empty?)

heightmap = {}

lines.each.with_index do |l, r|
	l.chars.each.with_index do |x, c|
		heightmap[[r, c]] = x.to_i
	end
end

def adjacent_points((r, c))
	[
	  [r, c - 1],
	  [r + 1, c],
	  [r, c + 1],
	  [r - 1, c]
	]
end

low_points = []
heightmap.each do |point, x|
	adj = adjacent_points(point).map { heightmap[_1] }.compact
	low_points << x if adj.all? { _1 > x }
end

puts low_points.reduce(0) { |acc, x| acc + x + 1 }
