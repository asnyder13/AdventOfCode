#!/usr/bin/env ruby
# frozen_string_literal: true

abort('Please provide input file') if ARGV.count.zero?
# This way sorbet gives at least _some_ hints.
lines = []
lines.concat ARGF.readlines(chomp: true).reject(&:empty?).map(&:to_i)

puts lines.each_cons(3).each_cons(2).reduce(0) do |acc, (a, b)|
	(b.reduce(:+) - a.reduce(:+)).positive? ? acc + 1 : acc
end
