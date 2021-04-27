#!/usr/bin/env ruby
# frozen_string_literal: true

lines = File.readlines('./input.txt')

# [x, y]
DIRS = {
	N: { coord: [ 0,  1] },
	E: { coord: [ 1,  0] },
	W: { coord: [-1,  0] },
	S: { coord: [ 0, -1] }
}.freeze
DIR_KEYS = %i[E S W N].freeze

class Direction
	def initialize(idx)
		@idx = idx
	end

	def next = @idx = @idx < DIR_KEYS.count - 1 ? @idx + 1 : 0
	def prev = @idx = @idx.positive? ? @idx - 1 : DIR_KEYS.count - 1
	def peek = DIRS[DIR_KEYS[@idx]]
end

class Movable
	attr_reader :loc

	def initialize(loc)
		@loc = loc
		@dir = Direction.new(0)
	end

	def move(coord, amount)
		@loc = [@loc[0] + coord[0] * amount, @loc[1] + coord[1] * amount]
	end

	def manhattan_distance
		@loc[0].abs + @loc[1].abs
	end
end

class Ship < Movable
	def forward(coord, amount)
		move(coord, amount)
	end
end

class Waypoint < Movable
	def turn(amount, clockwise:)
		amount.times do
			@loc = [@loc[1], @loc[0]]
			flip_neg(@loc, clockwise)
		end
	end

		private

	def flip_neg(new, clockwise)
		if clockwise
			new[1] = -new[1]
		else
			new[0] = -new[0]
		end
	end
end

Instruction = Struct.new(:ins, :amount)
ship = Ship.new([0, 0])
waypoint = Waypoint.new([10, 1])

lines.each do |l|
	next unless l =~ /^(\w)(\d+)$/

	step = Instruction.new($1, $2.to_i)
	case step.ins
	when 'N', 'S', 'E', 'W'
		waypoint.move(DIRS[step.ins.to_sym][:coord], step.amount)
	when 'R', 'L'
		waypoint.turn(step.amount / 90, clockwise: step.ins == 'R')
	when 'F'
		ship.forward(waypoint.loc, step.amount)
	end
end

puts ship.manhattan_distance
