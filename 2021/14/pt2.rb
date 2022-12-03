#!/usr/bin/env ruby
# frozen_string_literal: true

abort('Please provide input file') if ARGV.count.zero?
# This way sorbet gives at least _some_ hints.
lines = []
file = File.open(ARGV.first, 'r')
lines.concat file.readlines(chomp: true)

ITERATIONS = 40
pair_insertions = {}
pair_counts = Hash.new 0
char_counts = Hash.new 0

lines.each do |l|
	next if l.empty?

	case l
	when /^(\w+)$/
		template_chars = $1.chars
		template_chars.each { |c| char_counts[c] += 1 }
		template_chars.each_cons(2).each { |a, b| pair_counts[[a, b]] += 1 }
	when /(\w)(\w) -> (\w)/
		pair_insertions[[$1, $2]] = $3
	end
end
pair_insertions.freeze

ITERATIONS.times do
	new_pair_counts = pair_counts.dup

	pair_counts.each do |(a, b), count|
		next if count.zero?

		new_pair_counts[[a, b]] -= count
		insertion_char = pair_insertions[[a, b]]

		char_counts[insertion_char]          += count
		new_pair_counts[[a, insertion_char]] += count
		new_pair_counts[[insertion_char, b]] += count
	end

	pair_counts = new_pair_counts
end

(min, max) = char_counts.minmax_by { |_char, count| count }.map(&:last)
puts max - min
