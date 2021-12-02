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

	def seat_taken? = @alive
	def seat_free?  = !@alive && !@floor
	def floor?      = @floor
	def changed?    = @changed

	def [](direction)
		send(direction)
	end

	def []=(direction, neighbour)
		send("#{direction}=", neighbour)
	end

	def queue_next_state
		@next_state = taken_next?
		@changed = seat_taken? != @next_state
	end

	def apply_next_state
		@alive = @next_state
	end

	def to_s
		val = floor? ? nil : seat_taken?
		Floorplan::MAPPING.key(val)
	end

		private

	def neighbours
		NEIGHBOUR_DIRECTIONS.map(&method(:[])).compact
	end

	def dir_with_neightbours
		NEIGHBOUR_DIRECTIONS.map { |dir| [dir, self[dir]] }
	end

	def neighbours_by_sight
		dir_neigh = dir_with_neightbours.filter { !_2.nil? }
		at_edges = false
		until at_edges
			follow_directions(dir_neigh)
			at_edges = dir_neigh.reject { _2.nil? || _2.seat_taken? || _2.seat_free? }.empty?
		end

		return dir_neigh.map { _2 }
	end

	def follow_directions(dir_neigh)
		dir_neigh.map! do |dir, n|
			if !n.nil? && !n.seat_taken? && !n.seat_free?
				[dir, n[dir]]
			else
				[dir, n]
			end
		end
	end

	def taken_next?
		taken_neighbours = neighbours_by_sight.compact.count(&:seat_taken?)

		if floor? then false
		elsif seat_taken? then taken_neighbours < 5
		else taken_neighbours.zero?
		end
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
		@floor.map { |row| row.select(&:seat_taken?).length }.reduce(&:+)
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
