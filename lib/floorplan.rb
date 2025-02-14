#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'matrix'
require 'sorbet-runtime'
require_relative 'sorbet_types'

RELATIVE_NEIGHBOUR_COORDINATES = T.let({
  north: Vector[-1,  0], north_east: Vector[-1,  1],
  east:  Vector[0,  1], south_east: Vector[1,  1],
  south: Vector[1,  0], south_west: Vector[1, -1],
  west:  Vector[0, -1], north_west: Vector[-1, -1]
}.freeze, T::Hash[Symbol, Vector])
NEIGHBOUR_DIRECTIONS = T.let(RELATIVE_NEIGHBOUR_COORDINATES.keys.freeze, T::Array[Symbol])
NEIGHBOUR_VECTORS = T.let(RELATIVE_NEIGHBOUR_COORDINATES.values.freeze, T::Array[Vector])

# Floorplan
class Floorplan
  include Enumerable

  extend T::Sig
  extend T::Generic
  # T::Configuration.default_checked_level = :tests

  FloorplanElem = type_member

  sig { returns(Matrix) }
  attr_reader :floor

  sig do
    type_parameters(:U)
      .params(
        lines: T::Enumerable[String],
        wrapping: T::Boolean,
        block: T.nilable(
          T.proc.params(char: String).returns(T.type_parameter(:U))
        )
      )
      .returns(Floorplan[T.any(String, T.type_parameter(:U))])
  end
  def self.from_lines(lines, wrapping: true, &block)
    Floorplan[T.any(String, T.type_parameter(:U))].new(lines.count, wrapping:) do |fp|
      lines.map(&:chars).each_with_index do |row, x|
        row.each_with_index do |char, y|
          char = yield char if block

          vector = Vector[x, y]
          Seat.new(floorplan: fp, value: char, vector:)
        end
      end
    end
  end

  sig {
  type_parameters(:U).params(
    size: Numeric,
    wrapping: T::Boolean,
    # block: T.nilable(T.proc.params(fp: Floorplan[Floorplan::FloorplanElem]).returns(T.untyped))
    block: T.nilable(
      T.proc.params(fp: Floorplan[Floorplan::FloorplanElem]).returns(T.type_parameter(:U))
    )
  ).void
  }
  def initialize(size, wrapping: true, &block)
    @floor = Matrix.build(size) { 0 }
    @wrapping = wrapping
    yield self if block
  end

  sig { params(coord: Vector).returns(T.nilable(Seat[FloorplanElem])) }
  def [](coord)
    return nil if !@wrapping && coord.any?(&:negative?)

    # if !@wrapping
    #
    #   end

    floor[*coord]
  end
  sig { params(coord: Vector, value: Seat[FloorplanElem]).returns(Seat[FloorplanElem]) }
  def []=(coord, value)
    floor[*coord] = value
  end

  sig {
    override.params(block: T.nilable(T.proc.params(arg0: Seat[FloorplanElem]).returns(BasicObject)))
            .returns(T::Enumerator[Seat[FloorplanElem]])
  }
  def each(&block)
    if block.nil?
      to_enum(:each)
    else
      @floor.each { yield _1 }
    end
  end

  sig { returns(T::Array[T::Array[Seat[FloorplanElem]]]) }
  def rows
    floor.to_a
  end

  def pretty_print
    rows.map { _1.map(&:inspect) }.map(&:join).each { p _1 }
  end

  sig { params(seat: Seat[FloorplanElem]).returns(self) }
  def <<(seat)
    self[seat.vector] = seat
    self
  end
end

# Seat
class Seat
  extend T::Sig
  extend T::Generic
  # T::Configuration.default_checked_level = :tests

  SeatElem = type_member

  sig { returns(Vector) }
  attr_reader :vector

  sig { returns(SeatElem) }
  attr_accessor :value

  sig { returns(Floorplan[SeatElem]) }
  attr_reader :floor

  # attr_accessor(*T.unsafe(NEIGHBOUR_DIRECTIONS))

  sig { params(direction: Symbol).returns(T.nilable(Seat[SeatElem])) }
  def [](direction)
    raise 'Seat neighbour access was not given valid direction' unless NEIGHBOUR_DIRECTIONS.include?(direction)

    dir_coord = T.cast(RELATIVE_NEIGHBOUR_COORDINATES[direction], Vector)
    @floor[pos + dir_coord]
  end

  sig { returns(T::Array[Seat[SeatElem]]) }
  def neighbours
    @neighbours ||= NEIGHBOUR_DIRECTIONS.map(&method(:[])).compact
  end

  sig { params(length: Integer, only_full: T::Boolean).returns(T::Array[T::Array[Seat[SeatElem]]]) }
  def runs(length, only_full: true)
    res = T.cast(NEIGHBOUR_DIRECTIONS, T::Enumerable[Symbol]).map do |dir|
      run = T.let([], T::Array[Seat[SeatElem]])
      curr = self
      length.times do |i|
        run << curr

        next_seat = curr[T.cast(dir, Symbol)]
        break if next_seat.nil?

        curr = next_seat
      end

      run
    end

    res = res.filter { _1.length == length } if only_full

    return res
  end

  sig { params(value: SeatElem, vector: Vector, floorplan: T.nilable(Floorplan[SeatElem])).void }
  def initialize(value:, vector:, floorplan:)
    @floor = floorplan unless floorplan.nil?
    @value = value
    @vector = vector

    @floor[vector] = self unless @floor.nil?
  end

  sig { returns(Vector) }
  def pos = @vector

  def inspect = @value

  sig { params(other: Seat[SeatElem]).returns(T::Boolean) }
  def adjacent(other) = neighbours.include? other
end
