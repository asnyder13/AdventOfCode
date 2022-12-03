#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'

input_file = ARGV.first || 'testinput.txt'
file = File.open(input_file, 'r')

lines = file.readlines(chomp: true)

pos = 0
idx = 0
lines.first.chars.map { |c| c == '(' ? 1 : -1 }.each do |x|
	idx += 1
	pos += x
	break if pos.negative?
end

puts idx
