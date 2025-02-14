#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'bundler'
Bundler.require

extend T::Sig
T::Configuration.default_checked_level = :tests

require_relative '../../lib/file_parsers'
require_relative '../../lib/extensions'

reports = FileParsers.whitespace_separated_ints

safe = reports.filter do |report|
  diffs = report.each_cons(2).map { |(a, b)| a - b }
  (diffs.all?(&:positive?) || diffs.all?(&:negative?)) && diffs.map(&:abs).all? { it >= 1 && it <= 3 }
end

# ap safe
puts safe.length
