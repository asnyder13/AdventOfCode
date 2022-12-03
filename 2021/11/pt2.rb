#!/usr/bin/env ruby
# frozen_string_literal: true

abort('Please provide input file') if ARGV.count.zero?
# This way sorbet gives at least _some_ hints.
lines = []
file = File.open(ARGV.first, 'r')
lines.concat file.readlines(chomp: true).reject(&:empty?)

RELATIVE_NEIGHBOUR_COORDINATES = {
	north: [-1,  0].freeze, north_east: [-1,  1].freeze,
	east:  [ 0,  1].freeze, south_east: [ 1,  1].freeze,
	south: [ 1,  0].freeze, south_west: [ 1, -1].freeze,
	west:  [ 0, -1].freeze, north_west: [-1, -1].freeze
}.freeze
NEIGHBOUR_DIRECTIONS = RELATIVE_NEIGHBOUR_COORDINATES.keys.freeze

FLASH_THRESHOLD = 9

class Octopus
	attr_accessor(*NEIGHBOUR_DIRECTIONS)
	attr_reader :flash_count

	def initialize(energy_level)
		@energy_level = energy_level.to_i
		@updated_this_step = false
		@flash_count = 0
	end

	def will_flash? = @energy_level > FLASH_THRESHOLD
	def flashed? = @energy_level.zero?

	def [](direction)
		send(direction)
	end

	def []=(direction, neighbour)
		send("#{direction}=", neighbour)
	end

	def inc_enegry
		@energy_level += 1 unless @energy_level.zero? && @updated_this_step
		@updated_this_step = true

		flash if will_flash?
	end

	def reset
		@updated_this_step = false
	end

	def to_s
		@energy_level.to_s
	end

		private

	def flash
		@flash_count += 1
		@energy_level = 0
		neighbours.each(&:inc_enegry)
	end

	def neighbours
		NEIGHBOUR_DIRECTIONS.map(&method(:[])).compact
	end
end

octopi_rows = lines.map do |l|
	l.chars.map { |c| Octopus.new(c) }
end

octopi_rows.each.with_index do |row, i|
	row.each.with_index do |octopus, j|
		RELATIVE_NEIGHBOUR_COORDINATES.each do |dir, dir_coords|
			octopus[dir] = nil
			rel_i, rel_j = dir_coords
			n_i = i + rel_i
			n_j = j + rel_j

			next if n_i.negative? || n_j.negative?

			octopus[dir] = octopi_rows.dig(n_i, n_j)
		end
	end
end

step = 0
octopi = octopi_rows.flatten
until octopi.filter(&:flashed?).length == octopi.length
	step += 1
	octopi.each(&:inc_enegry)
	octopi.each(&:reset)
end

puts step
