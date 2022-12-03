#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'

input_file = ARGV.first || 'testinput.txt'
file = File.open(input_file, 'r')

lines = file.readlines(chomp: true)

point1 = [0, 0]
point2 = [0, 0]
delivered1 = Hash.new(0)
delivered2 = Hash.new(0)
delivered1[point1] = 1
delivered2[point2] = 1

def update_delivery(c, point, delivered)
	x, y = point
	case c
	when '^'
		y += 1
		delivered[point] += 1
	when 'v'
		y -= 1
		delivered[point] += 1
	when '<'
		x -= 1
		delivered[point] += 1
	when '>'
		x += 1
		delivered[point] += 1
	end

	[x, y]
end

lines.first.chars.each_slice(2) do |first, second|
		point1 = update_delivery first, point1, delivered1
		point2 = update_delivery second, point2, delivered2
end

puts delivered1.merge(delivered2).length
