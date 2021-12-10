#!/usr/bin/env ruby
# frozen_string_literal: true

abort('Please provide input file') if ARGV.count.zero?
# This way sorbet gives at least _some_ hints.
lines = []
file = File.open(ARGV.first, 'r')
lines.concat file.readlines(chomp: true).reject(&:empty?)

SCORES = {
	')' =>      3,
	']' =>     57,
	'}' =>  1_197,
	'>' => 25_137
}.freeze

matching = {
	']' => '[',
	')' => '(',
	'}' => '{',
	'>' => '<'
}
MATCHING = matching.merge matching.invert

corrupted = []
lines.each do |l|
	open = []
	l.chars.each do |char|
		case char
		when /[\[({<]/
			open << char
		when /[\])}>]/
			idx  = open.index  MATCHING[char]
			ridx = open.rindex MATCHING[char]

			if idx.nil? || ridx != open.length - 1
				corrupted << [MATCHING[open.last], char]
				break
			else
				open.delete_at ridx
			end
		end
	end
end

puts corrupted.map { |_exp, found| SCORES[found] }.reduce(:+)
