#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'bundler'
Bundler.require

extend T::Sig
T::Configuration.default_checked_level = :tests

require_relative '../../lib/file_parsers'
require_relative '../../lib/extensions'
require_relative '../../lib/floorplan'

fp = Floorplan.from_lines FileParsers.lines, wrapping: false
runs = fp.each.filter { it.value == 'X' }.map { it.runs(4) }.flatten 1

xmas_count = runs.count { it.map(&:value).join == 'XMAS' }
puts xmas_count
