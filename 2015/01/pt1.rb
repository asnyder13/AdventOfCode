#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'

input_file = ARGV.first || 'testinput.txt'
file = File.open(input_file, 'r')

lines = file.readlines(chomp: true)

puts lines.first.chars.map { |c| c == '(' ? 1 : -1 }.sum
