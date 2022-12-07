#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'

lines = T.let([], T::Array[String])
input_file = ARGV.first || 'testinput1.txt'
file = File.open(input_file, 'r')

line = T.must(file.readlines.first)

DISTINCT_CHARS = 4
first_marker = 0
line.chars.each_cons(DISTINCT_CHARS).with_index do |arr, i|
	uniq = arr.tally.count >= DISTINCT_CHARS
	if uniq
		first_marker = i + DISTINCT_CHARS
		break
	end
end

puts first_marker
