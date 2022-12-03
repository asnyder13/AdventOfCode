#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'

input_file = ARGV.first || 'testinput.txt'
file = File.open(input_file, 'r')

lines = file.readlines(chomp: true)

x = 0
y = 0
delivered = Hash.new(0)
delivered[[0, 0]] = 1

lines.first.chars.each do |l|
	case l
	when '^'
		y += 1
		delivered[[x, y]] += 1
	when 'v'
		y -= 1
		delivered[[x, y]] += 1
	when '<'
		x -= 1
		delivered[[x, y]] += 1
	when '>'
		x += 1
		delivered[[x, y]] += 1
	end
end

puts delivered.length
