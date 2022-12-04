#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'

input_file = ARGV.first || 'testinput6.txt'
file = File.open(input_file, 'r')

lines = file.readlines(chomp: true)

nice_count = 0
lines.each do |l|
	has_spaced_repeat = l.match?(/(.).\1/)

	pair_counts = l.chars.each_cons(2).tally
	doubles = pair_counts.filter { |_k, count| count >= 2 }

	has_double = !doubles.empty?

	if has_double
		double_pairs = pair_counts.filter { |(a, b), count| a == b && count > 1 }
		unless double_pairs.length.zero?
			double_pairs.each do |(a, _), _|
				has_double = l.match?(/(#{a})\1+.*\1{2}/)
			end
		end
	end

	nice_count += 1 if has_spaced_repeat && has_double
end

puts nice_count
