#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'

lines = T.let([], T::Array[String])
input_file = ARGV.first || 'testinput.txt'
file = File.open(input_file, 'r')

lines = file.readlines(chomp: true)

full_overlaps = lines.reduce(0) do |acc, l|
	first, second = l.split ','
	schedule1 = Range.new(*first.split('-').map(&:to_i))
	schedule2 = Range.new(*second.split('-').map(&:to_i))

	schedule1.cover?(schedule2) || schedule2.cover?(schedule1) ? acc + 1 : acc
end

puts full_overlaps
