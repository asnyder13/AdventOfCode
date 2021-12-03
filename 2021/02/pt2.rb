#!/usr/bin/env ruby
# frozen_string_literal: true

abort('Please provide input file') if ARGV.count.zero?
# This way sorbet gives at least _some_ hints.
lines = []
lines.concat ARGF.readlines(chomp: true).reject(&:empty?)

horiz = depth = aim = 0
lines.each do |l|
	(dir, amt) = l.split
	amt = amt.to_i

	case dir
	when 'up'
		aim -= amt
	when 'down'
		aim += amt
	when 'forward'
		horiz += amt
		depth += aim * amt
	end
end

puts horiz * depth
