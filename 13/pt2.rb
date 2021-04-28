#!/usr/bin/env ruby
# frozen_string_literal: true

lines = File.readlines('./input.txt')

class Bus
	attr_reader :id, :curr_min_time

	def initialize(interval)
		@id = interval
		@curr_min_time = 0
	end

	def step
		@curr_min_time += @id
	end

	def first_time(timestamp)
		step until @curr_min_time >= timestamp
	end
end

Departure = Struct.new(:bus) do
	def empty? = bus.nil?
end

departures = lines[1].split(',').map do |x|
	x = x.to_i
	bus = x.positive? ? Bus.new(x) : nil
	Departure.new(bus)
end

curr_ts = departures.first.bus.id
jump = 1

departures.each.with_index do |dep, i|
	next if dep.empty?

	curr_ts += jump while (curr_ts + i) % dep.bus.id != 0

	jump *= dep.bus.id
end

puts curr_ts
