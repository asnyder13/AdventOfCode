#!/usr/bin/env ruby
# frozen_string_literal: true

input_file = ARGV.first || 'testinput2.txt'
file = File.open(input_file, 'r')

NUMBERS = {
	'one' => 'o1e',
	'two' => 't2o',
	'three' => 'th3ee',
	'four' => 'f4ur',
	'five' => 'f5ve',
	'six' => 's6x',
	'seven' => 'se7en',
	'eight' => 'ei8ht',
	'nine' => 'n9ne'
}.freeze

sum = file.readlines(chomp: true).map do |line|
	NUMBERS.each { line.gsub!(_1, _2) }
	line.scan(/\d/).then { _1.first + _1.last }
end.map(&:to_i).sum
puts sum
