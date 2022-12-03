#!/usr/bin/env ruby
# frozen_string_literal: true

abort('Please provide input file') if ARGV.count.zero?
# This way sorbet gives at least _some_ hints.
lines = []
file = File.open(ARGV.first, 'r')
lines.concat file.readlines(chomp: true).reject(&:empty?)

NUM_MAP = {
	0 => 'abcefg',
	1 => 'cf',
	2 => 'acdeg',
	3 => 'acdfg',
	4 => 'bcdf',
	5 => 'abdfg',
	6 => 'abdefg',
	7 => 'acf',
	8 => 'abcdefg',
	9 => 'abcdfg'
}.freeze
NUM_LEN = NUM_MAP.transform_values(&:length).freeze
UNIQUE_COUNTS = [NUM_LEN[1], NUM_LEN[4], NUM_LEN[7], NUM_LEN[8]].freeze

Entry = Struct.new(:patterns, :output) do
	def count
		output.count { UNIQUE_COUNTS.include? _1.length }
	end
end

entries = lines.map do |l|
	patterns, output = l.split '|'
	patterns = patterns.split
	output = output.split
	Entry.new patterns, output
end

puts entries.map(&:count).sum
