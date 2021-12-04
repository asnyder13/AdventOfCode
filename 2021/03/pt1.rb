#!/usr/bin/env ruby
# frozen_string_literal: true

abort('Please provide input file') if ARGV.count.zero?
# This way sorbet gives at least _some_ hints.
lines = []
lines.concat ARGF.readlines(chomp: true).reject(&:empty?)

char_tally = lines.map(&:chars).transpose.map(&:tally)
most_common_chars = char_tally.map { |h| h.max_by { |_char, count| count } }.map(&:first)

gamma = most_common_chars.join.to_i(2)
epsilon = most_common_chars.map(&:to_i).map { _1 ^ 1 }.join.to_i(2)

puts gamma * epsilon
