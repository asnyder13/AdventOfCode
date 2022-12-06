#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'

lines = T.let([], T::Array[String])
input_file = ARGV.first || 'testinput.txt'
file = File.open(input_file, 'r')

lines = file.readlines(chomp: true)

total_overlaps = lines.reduce(0) do |acc, l|
	first, second = l.split ','
	schedule1 = Range.new(*first.split('-').map(&:to_i))
	schedule2 = Range.new(*second.split('-').map(&:to_i))

	no_overlap = (schedule1.max < schedule2.begin || schedule2.max < schedule1.begin)
	no_overlap ? acc : acc + 1
end

puts total_overlaps
