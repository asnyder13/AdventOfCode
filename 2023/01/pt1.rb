#!/usr/bin/env ruby
# frozen_string_literal: true

input_file = ARGV.first || 'testinput.txt'
file = File.open(input_file, 'r')

sum = file.readlines(chomp: true).map do |line|
	line.scan(/\d/).then { _1.first + _1.last }
end.map(&:to_i).sum
puts sum
