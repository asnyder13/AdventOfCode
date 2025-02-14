#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'bundler'
Bundler.require

extend T::Sig
T::Configuration.default_checked_level = :tests

require_relative '../../lib/file_parsers'
require_relative '../../lib/extensions'

lines = FileParsers.whitespace_separated_ints
pairs = lines.transpose

(left, right) = pairs.map(&:tally)
right.default = 0
res = T.must(left).map do |key_left, count_left|
  key_left * count_left * right[key_left]
end
puts res.sum
