#!/usr/bin/env ruby
# frozen_string_literal: true

abort('Please provide input file') if ARGV.count.zero?
# This way sorbet gives at least _some_ hints.
lines = []
file = File.open(ARGV.first, 'r')
lines.concat file.readlines(chomp: true)

polymer_template = []
pair_insertions = {}
ITERATIONS = 10

lines.each do |l|
	next if l.empty?

	case l
	when /^(\w+)$/
		polymer_template = $1.chars
	when /(\w+) -> (\w)/
		pair_insertions[$1] = $2
	end
end

pair_insertions.freeze

ITERATIONS.times do
	insertions = polymer_template.each_cons(2).map { |a, b| pair_insertions[a + b] }
	polymer_template = (polymer_template.zip insertions).flatten.compact
end

(min, max) = polymer_template.tally.minmax_by { |_char, count| count }.map(&:last).map(&:to_i)
puts max - min
