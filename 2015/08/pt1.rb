#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'

extend T::Sig

input_file = ARGV.first || 'testinput.txt'
file = File.open(input_file, 'r')

lines = file.readlines(chomp: true)

# ParsedLine = Struct.new(:literal, :backslashes, :quotes, :hexes) do
# 	def total
# 		literal - (backslashes + quotes + (hexes * 3)) - 2
# 	end
# end
# parsed_lines = []
# parsed = lines.map do |line|
# 	line.gsub!(/^"/, '')
# 	line.gsub!(/"$/, '')
#
# 	escaped_backslashes = line.scan(/\\\\/).length
# 	escaped_quotes = line.scan(/\\"/).length
# 	escaped_hexes = line.scan(/\\x\h\h/).length
# 	ParsedLine.new line.length + 2, escaped_backslashes, escaped_quotes, escaped_hexes
# end
# literal = parsed.map(&:literal).sum
# total = parsed.map(&:total).sum

literal = 0
parsed = 0
lines.each do |l|
	literal += l.length
	parsed += eval(l).length
end

puts literal - parsed
# ans 1342
