#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'bundler'
Bundler.require

extend T::Sig
T::Configuration.default_checked_level = :tests

require_relative '../../lib/file_parsers'
require_relative '../../lib/extensions'

corrupted_memory_lines = FileParsers.lines
res = corrupted_memory_lines.map { it.scan(/mul\((\d+),(\d+)\)/) }.flatten(1)
res = res.map { it.map(&:to_i).reduce(:*) }.sum

puts res
