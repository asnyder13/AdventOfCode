#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'bundler'
Bundler.require

require_relative '../../lib/file_parsers'
require_relative '../../lib/extensions'

SIZE = 100
dial = 50
zero_count = 0

FileParsers.lines do |line|
	dir      = line[0]
	distance = line[1..].to_i

	distance *= -1 if dir == 'L'

	dial += distance
	zero_count += (dial / SIZE).abs

	dial %= SIZE
	dial = dial.abs
end

puts zero_count

