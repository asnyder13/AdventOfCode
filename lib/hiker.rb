#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'matrix'
require 'sorbet-runtime'
require_relative 'sorbet_types'
require_relative 'floorplan'

DIRECTIONS = T.let({
  north: Vector[-1,  0],
  east:  Vector[0,  1],
  south: Vector[1,  0],
  west:  Vector[0, -1],
}.freeze, T::Hash[Symbol, Vector])

TURNS = T.let({
  right: {
    north: :east,
    east:  :south,
    south: :west,
    west:  :north,
  },
  left: {
    north: :west,
    east:  :north,
    south: :east,
    west:  :south,
  }
}.freeze, T::Hash[Symbol, T::Hash[Symbol, Symbol]])

# Hiker
class Hiker
  extend T::Sig
  extend T::Generic

  FloorplanElem = type_member

  sig { returns Floorplan[FloorplanElem]  }
  attr_reader :floorplan

  sig { returns Seat[FloorplanElem]  }
  attr_reader :location

  sig { returns Symbol }
  attr_reader :direction

  sig {
    params(
      floorplan: Floorplan[FloorplanElem],
      start: T.nilable(Vector)
    ).void
  }
  def initialize(floorplan, start: nil)
    @floorplan = floorplan
    @location = floorplan[start || Vector[0, 0]]
    @direction = :north
  end

  sig { returns(Hiker[FloorplanElem]) }
  def step
    @location = location[direction]
    self
  end

  sig { params(turn_direction: Symbol).returns(Hiker[FloorplanElem]) }
  def turn(turn_direction)
    raise 'Only :right and :left turns accepted' if turn_direction != :right && turn_direction != :left

    @direction = T.must(TURNS[turn_direction])[direction]
    self
  end

  def peek
    location[direction]
  end
end
