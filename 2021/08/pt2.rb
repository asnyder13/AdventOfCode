#!/usr/bin/env ruby
# frozen_string_literal: true

require 'set'

abort('Please provide input file') if ARGV.count.zero?
# This way sorbet gives at least _some_ hints.
lines = []
file = File.open(ARGV.first, 'r')
lines.concat file.readlines(chomp: true).reject(&:empty?)

NUM_MAP = {
	0 => 'abcefg',
	1 => 'cf',      #
	2 => 'acdeg',
	3 => 'acdfg',
	4 => 'bcdf',    #
	5 => 'abdfg',
	6 => 'abdefg',
	7 => 'acf',     #
	8 => 'abcdefg', #
	9 => 'abcdfg'
}.freeze
NUM_LEN = NUM_MAP.transform_values(&:length).freeze
UNIQUE_COUNTS = [NUM_LEN[1], NUM_LEN[4], NUM_LEN[7], NUM_LEN[8]].freeze

Entry = Struct.new(:patterns, :output) do
	# def both = patterns + output
	def uniques = patterns.filter { UNIQUE_COUNTS.include? _1.length }.sort_by(&:length)
	def sets = patterns.map(&:chars).map(&:to_set)
end

require 'pp'
# pp NUM_MAP, NUM_LEN

entries = lines.map do |l|
	patterns, output = l.split '|'
	patterns = patterns.split
	output = output.split
	Entry.new patterns, output
end

# PP.pp entries.map(&:both), $>, 140
# PP.pp entries.map(&:unique), $>, 140

entries.each do |entry|
	actual_config = {}
	# pp entry.patterns
	# pp entry.patterns.map(&:chars).flatten.tally.sort_by(&:last)
	uniques = entry.uniques

	pp uniques
	pp entry.sets

	uniques.each do |u|
		digit = NUM_MAP.key u
		actual_config[digit] = 0
	end
	# pp
end
