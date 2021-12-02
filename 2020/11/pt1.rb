#!/usr/bin/env ruby
# frozen_string_literal: true

lines = File.readlines('./input.txt')

class Seat
	RELATIVE_NEIGHBOUR_COORDINATES = {
	  north: [-1,  0].freeze, north_east: [-1,  1].freeze,
	  east:  [ 0,  1].freeze, south_east: [ 1,  1].freeze,
	  south: [ 1,  0].freeze, south_west: [ 1, -1].freeze,
	  west:  [ 0, -1].freeze, north_west: [-1, -1].freeze
	}.freeze

	NEIGHBOUR_DIRECTIONS = RELATIVE_NEIGHBOUR_COORDINATES.keys.freeze

	attr_accessor(*NEIGHBOUR_DIRECTIONS)

	def initialize(seat)
		@floor = seat.nil?
		@alive = !@floor && seat
		@next_state = false
		@changed = true
	end

	def alive?   = @alive
	def floor?   = @floor
	def changed? = @changed

	def [](direction)
		send(direction)
	end

	def []=(direction, neighbour)
		send("#{direction}=", neighbour)
	end

	def neighbours
		NEIGHBOUR_DIRECTIONS.map(&method(:[])).compact
	end

	def alive_next?
		alive_neighbours = neighbours.count(&:alive?)

		if floor? then false
		elsif alive? then alive_neighbours < 4
		else alive_neighbours.zero?
		end
	end

	def queue_next_state
		@next_state = alive_next?
		@changed = alive? != @next_state
	end

	def apply_next_state
		@alive = @next_state
	end

	def to_s
		val = floor? ? nil : alive?
		Floorplan::MAPPING.key(val)
	end
end

class Floorplan
	MAPPING = { '.' => nil, 'L' => false, '#' => true }.freeze

	def initialize(lines)
		@floor = []
		add_rows(lines)
		reassign_neighbors
	end

	def reassign_neighbors
		@floor.each.with_index do |row, i|
			row.each.with_index do |seat, j|
				Seat::RELATIVE_NEIGHBOUR_COORDINATES.each do |dir, dir_coords|
					seat[dir] = nil
					rel_i, rel_j = dir_coords
					n_i = i + rel_i
					n_j = j + rel_j

					next if n_i.negative? || n_j.negative?

					seat[dir] = @floor.dig(n_i, n_j)
				end
			end
		end
	end

	def step
		@floor.each { |row| row.each(&:queue_next_state) }
		@floor.each { |row| row.each(&:apply_next_state) }
		reassign_neighbors
	end

	def changing?
		@floor.map { |row| row.map(&:changed?).reduce(&:|) }.reduce(&:|)
	end

	def occupied
		@floor.map { |row| row.select(&:alive?).length }.reduce(&:+)
	end

	def to_s
		@floor.map { |s| s.map(&:to_s).join }.join("\n")
	end

		private

	def add_rows(lines)
		lines.each { |l| add_row(l) }
	end

	def add_row(line)
		line.chomp!
		@floor << line.each_char.map { |s| MAPPING[s] }.map { |m| Seat.new(m) }
	end
end

floorplan = Floorplan.new(lines)
floorplan.step while floorplan.changing?
puts floorplan.occupied
