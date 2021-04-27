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

class Ship
	def initialize
		@loc = [0, 0]
		@dir = Direction.new(0)
	end

	def move(move_dir, amount)
		coord = move_dir[:coord]
		@loc = [@loc[0] + coord[0] * amount, @loc[1] + coord[1] * amount]
	end

	def turn(amount, clockwise:)
		amount.times { clockwise ? @dir.next : @dir.prev }
	end

	def forward(amount)
		move(@dir.peek, amount)
	end

	def manhattan_distance
		@loc[0].abs + @loc[1].abs
	end
end

Instruction = Struct.new(:ins, :amount)
ship = Ship.new

lines.each do |l|
	next unless l =~ /^(\w)(\d+)$/

	step = Instruction.new($1, $2.to_i)
	case step.ins
	when 'N', 'S', 'E', 'W'
		ship.move(DIRS[step.ins.to_sym], step.amount)
	when 'R'
		ship.turn(step.amount / 90, clockwise: true)
	when 'L'
		ship.turn(step.amount / 90, clockwise: false)
	when 'F'
		ship.forward(step.amount)
	end
end

puts ship.manhattan_distance
