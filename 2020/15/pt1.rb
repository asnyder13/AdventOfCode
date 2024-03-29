#!/usr/bin/env ruby
# frozen_string_literal: true

abort('Please provide input file') if ARGV.count.zero?
lines = ARGF.readlines

initial_values = lines[0].split(',').map(&:chomp).map(&:to_i)
spoken = initial_values
positions = Hash.new { |h, v| h[v] = [] }
initial_values.each.with_index { positions[_1] << _2 }

(spoken.length...2020).each do |i|
	this_num = 0
	unless positions[spoken.last].length == 1
		(idx2, idx1) = positions[spoken.last].last(2)
		this_num = idx1 - idx2
	end

	spoken << this_num
	positions[this_num] << i
end

puts spoken.last
