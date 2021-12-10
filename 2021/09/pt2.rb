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
	low_points << point if adj.all? { _1 > x }
end

basins = low_points.map do |low_point|
	basin = { low_point => true }
	last_len = -1

	loop do
		break if basin.length == last_len

		last_len = basin.length
		# Can't use Hash.each_key b/c that will trigger a "new key during enumeration" error on basin.
		basin.keys.each do |point|
			basin_points = adjacent_points(point).filter { |p| (heightmap[p] || 1234) < 9 }
			basin_points.each { |p| basin[p] = true }
		end
	end

	basin
end

puts basins.map(&:length).max(3).reduce(:*)
