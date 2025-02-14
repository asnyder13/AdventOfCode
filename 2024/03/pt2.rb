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
switch_syms = {
  do: 'do()',
  dont: "don't()"
}.invert

last_line_len = 0
res = corrupted_memory_lines.map.with_index do |line, idx|
  muls = line.enum_for(:scan, /mul\((\d+),(\d+)\)/).map do |nums|
    { nums: nums.map(&:to_i), pos: T.must(Regexp.last_match).begin(0) + (last_line_len * idx) }
  end
  switches = line.enum_for(:scan, /((?:do|don't)\(\))/).map do |(switch)|
    { switch: switch_syms[switch], pos: T.must(Regexp.last_match).begin(0) + (last_line_len * idx) }
  end

  last_line_len = line.length

  { muls:, switches: }
end.flatten(1)
muls = res.map { it[:muls] }.flatten 1
switches = res.map { it[:switches] }.flatten 1

good_ranges = T.let([], T::Array[T::Range[Integer]])
last_switch_do = T.let({ switch: :do, pos: 0 }, T.nilable({ switch: Symbol, pos: Integer }))
switches.each do |curr|
  last_switch_do = curr if last_switch_do.nil? && curr[:switch] == :do
  next if last_switch_do.nil? || last_switch_do[:switch] == curr[:switch]

  good_ranges << (last_switch_do[:pos]..curr[:pos])
  last_switch_do = nil
end

final_switch = switches.last
good_ranges << (final_switch[:pos]..) if final_switch[:switch] == :do

result = muls.filter do |mul|
  good_ranges.any? { it.cover?(mul[:pos]) }
end
result = result.map { it[:nums] }
result = result.map { it.map(&:to_i).reduce(:*) }.sum

puts result
