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
require_relative '../../lib/hiker'

fp = Floorplan.from_lines FileParsers.lines, wrapping: false

direction_markers = %w[^ < > v]
marker_dir_symbol = {
  '^' => :north,
  '<' => :west,
  '>' => :east,
  'v' => :south,
}
starting_seat = fp.find do |seat|
  direction_markers.include? seat.value
end
starting_pos = T.let(starting_seat, Seat[String]).vector
starting_dir = marker_dir_symbol[starting_pos]

# fp.pretty_print
# ap starting_pos
# ap starting_pos.vector

hiker = Hiker.new fp, start: starting_pos
visited = Set.new

x = 0
unchanged_count = 0
# until visited.include?(hiker.location.vector)
until unchanged_count >= 100000
# loop do
  next_step = hiker.peek&.value
  hiker.turn :right if next_step == '#' || next_step.nil?

  visited_count = visited.length
  visited << hiker.location.vector
  unchanged_count += 1 if visited_count == visited.length

  hiker.location.value = 'X'

  next_step = hiker.peek&.value
  break if next_step == '#' || next_step.nil?

  hiker.step
end

# ap visited
# fp.pretty_print
ap visited.length
# 5128 too high
