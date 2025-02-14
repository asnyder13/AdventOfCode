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
start_points = fp.each.filter { _1.value == 'A' }
xes = start_points.count do |seat|
  x1 = [seat[:north_east], seat[:south_west]].compact
  side1 = x1.any? { it.value == 'M' } && x1.any? { it.value == 'S' }

  x2 = [seat[:north_west], seat[:south_east]].compact
  side2 = x2.any? { it.value == 'M' } && x2.any? { it.value == 'S' }

  side1 && side2
end

puts xes
