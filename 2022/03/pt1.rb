#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'set'
require 'sorbet-runtime'

lines = T.let([], T::Array[String])
input_file = ARGV.first || 'testinput.txt'
file = File.open(input_file, 'r')

lines = file.readlines(chomp: true)

PRIORITIES = [*'a'..'z', *'A'..'Z'].each_with_index.to_h { |k, i| [k, i + 1] }.freeze

priorities = lines.map do |l|
	midpoint = l.length / 2
	first  = T.must(l[...midpoint])
	second = T.must(l[midpoint..])

	set_first    = T.let(Set.new(first.chars), T::Set[String])
	set_second   = T.let(Set.new(second.chars), T::Set[String])
	intersection = set_first & set_second
	raise 'Multiple common items' unless intersection.size == 1

	PRIORITIES[intersection.first]
end

puts priorities.sum
