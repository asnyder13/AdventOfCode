#!/usr/bin/env ruby
# frozen_string_literal: true

abort('Please provide input file') if ARGV.count.zero?
# This way sorbet gives at least _some_ hints.
lines = []
file = File.open(ARGV.first, 'r')
lines.concat file.readlines(chomp: true).reject(&:empty?)

positions = lines.first.split(',').map(&:to_i)
max_pos = positions.max

def cons_int_sum(last)
	last * (last + 1) / 2
end

def fuel_cost(positions, starting_pos)
	positions.map { cons_int_sum (_1 - starting_pos).abs }
end

costs = (0..max_pos).map { fuel_cost positions, _1 }
puts costs.map(&:sum).min
