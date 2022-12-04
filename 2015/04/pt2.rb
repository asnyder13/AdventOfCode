#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'
require 'digest'

input_file = ARGV.first || 'testinput.txt'
file = File.open(input_file, 'r')

line = file.readlines(chomp: true).first
raise 'No line' if line.nil?

i = 1
i += 1 until Digest::MD5.hexdigest(line + i).to_s.start_with?('000000')

puts i.to_s
