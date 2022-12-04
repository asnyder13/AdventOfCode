#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'

input_file = ARGV.first || 'testinput1.txt'
file = File.open(input_file, 'r')

lines = file.readlines(chomp: true)

nice_count = 0
lines.each do |l|
	has_vowels  = l.scan(/[aeiou]/).length >= 3
	has_double  = l.match?(/(.)\1/)
	has_naughty = l.match?(/ab|cd|pq|xy/)

	nice_count += 1 if has_vowels && has_double && !has_naughty
end

puts nice_count
