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

(left, right) = pairs.map(&:sort)
puts left.zip(right).map { |(l, r)| l - r }.map(&:abs).sum
