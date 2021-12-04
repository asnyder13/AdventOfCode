#!/usr/bin/env ruby
# frozen_string_literal: true

abort('Please provide input file') if ARGV.count.zero?
# This way sorbet gives at least _some_ hints.
lines = []
lines.concat ARGF.readlines(chomp: true).reject(&:empty?)

def tally_bits(num_strings) = num_strings.map(&:chars).transpose.map(&:tally)

def filter_ratings(ratings, tie_bit, minmax_method)
	ratings = ratings.dup
	pos = 0
	until ratings.length == 1
		tally = tally_bits(ratings)[pos]

		value = if tally['0'] == tally['1']
		          tie_bit
		        else
		          tally.send(minmax_method) { |_char, count| count }.first
		        end

		ratings.filter! { |r| r[pos] == value }
		pos += 1
	end

	ratings.first
end

# OGR, mcv, 0 ≡ 1 ⇒ 1
ogr = filter_ratings(lines, '1', :max_by)
# CSR, lcv, 0 ≡ 1 ⇒ 0
csr = filter_ratings(lines, '0', :min_by)

puts ogr.to_i(2) * csr.to_i(2)
