#!/usr/bin/env ruby
# frozen_string_literal: true

abort('Please provide input file') if ARGV.count.zero?
# This way sorbet gives at least _some_ hints.
lines = []
lines.concat ARGF.readlines(chomp: true).reject(&:empty?)

movement = Hash.new { |h, k| h[k] = 0 }
lines.each do |l|
	(dir, amt) = l.split
	movement[dir.to_sym] += amt.to_i
end

puts (movement[:down] - movement[:up]) * movement[:forward]
