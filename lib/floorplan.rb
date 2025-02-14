#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'matrix'
require 'sorbet-runtime'

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
	extend T::Sig
	extend T::Generic
	# T::Configuration.default_checked_level = :tests

	FloorplanElem = type_member

	include Enumerable

	sig { returns(Matrix) }
	attr_reader :floor

	sig { params(size: Numeric).void }
	def initialize(size)
		@floor = Matrix.build(size) { 0 }
	end

	sig { params(coord: Vector).returns(T.nilable(Seat[FloorplanElem])) }
	def [](coord)
		floor[*coord]
	end
	sig { params(coord: Vector, value: Seat[FloorplanElem]).returns(Seat[FloorplanElem]) }
	def []=(coord, value)
		floor[*coord] = value
	end

	sig {
		override.params(block: T.proc.params(arg0: FloorplanElem).returns(BasicObject))
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
	attr_reader :value

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

	# sig { params(floorplan: Floorplan[SeatElem], value: SeatElem, vector: Vector).void }
	# def initialize(floorplan, value, vector:)
	# 	@floor = floorplan
	# 	@value = value
	# 	@vector = vector
	#
	# 	@floor[vector] = self
	# end
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
