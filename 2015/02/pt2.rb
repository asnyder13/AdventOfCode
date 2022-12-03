#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'

input_file = ARGV.first || 'testinput.txt'
file = File.open(input_file, 'r')

lines = file.readlines(chomp: true)

surface_areas = lines.map do |l|
	l, w, h = l.split('x').map(&:to_i)
	min1, min2 = [l, w, h].min(2)
	# (2 * l * w) + (2 * w * h) + (2 * h * l) + (min1 * min2)
	volumne = l * w * h

	(min1 * 2) + (min2 * 2) + volumne
end

puts surface_areas.sum
