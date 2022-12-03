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

priorities = lines.each_slice(3).map do |group|
	common_in_group = group.map { |l| Set.new l.chars }.reduce(&:&)
	PRIORITIES[common_in_group.first]
end

puts priorities.sum
