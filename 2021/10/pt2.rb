#!/usr/bin/env ruby
# frozen_string_literal: true

abort('Please provide input file') if ARGV.count.zero?
# This way sorbet gives at least _some_ hints.
lines = []
file = File.open(ARGV.first, 'r')
lines.concat file.readlines(chomp: true).reject(&:empty?)

SCORES = {
	')' => 1,
	']' => 2,
	'}' => 3,
	'>' => 4
}.freeze

matching = {
	']' => '[',
	')' => '(',
	'}' => '{',
	'>' => '<'
}
MATCHING = matching.merge matching.invert

require 'pp'

def step_seq(open, char)
	case char
	when /[\[({<]/
		open << char
	when /[\])}>]/
		idx  = open.index  MATCHING[char]
		ridx = open.rindex MATCHING[char]

		return false if idx.nil? || ridx != open.length - 1

		open.delete_at ridx
	end
end

open_seqs = []
# Remove corrupted lines
lines.filter! do |l|
	open_seqs << []
	l.chars.each do |c|
		not_corrupted = step_seq open_seqs.last, c
		unless not_corrupted
			open_seqs.pop
			break false
		end
	end
end

scores = open_seqs.map do |seq|
	seq.reverse.reduce(0) { |acc, char| (acc * 5) + SCORES[MATCHING[char]] }
end

puts scores.sort[(scores.length / 2).floor]
