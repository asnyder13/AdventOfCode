#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'
require 'json'

extend T::Sig

input_file = ARGV.first || 'testinput.txt'
file = File.open(input_file, 'r')

lines = file.readlines(chomp: true)

literal = 0
reencoded = 0
lines.each do |l|
	literal += l.length
	reencoded += l.to_json.length
end

puts reencoded - literal
# ans 2074
