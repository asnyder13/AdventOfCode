#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'
require 'matrix'

input_file = ARGV.first || 'testinput1.txt'
file = File.open(input_file, 'r')

lines = file.readlines(chomp: true)

def traverse_grid(start, finish)
	Range.new(*start).each do |x|
		Range.new(*finish).each do |y|
			yield x, y
		end
	end
end

MATRIX_DIM_SIZE = 1000
lights = Matrix.build(MATRIX_DIM_SIZE, MATRIX_DIM_SIZE) { false }
lines.each do |l|
	matches = /(?<op>[\w ]+) (?<start>\d+,\d+) through (?<finish>\d+,\d+)/.match l
	start  = matches[:start].split(',').map(&:to_i)
	finish = matches[:finish].split(',').map(&:to_i)

	traverse_grid([start.first, finish.first], [start.last, finish.last]) do |x, y|
		case matches[:op]
		when 'turn on'
			lights[x, y] = true
		when 'turn off'
			lights[x, y] = false
		when 'toggle'
			lights[x, y] = !lights[x, y]
		end
	end
end

puts lights.each.count { _1 }
