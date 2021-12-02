#!/usr/bin/env ruby
# frozen_string_literal: true

lines = File.readlines('./input.txt')

class Bus
	attr_reader :id, :curr_min_time

	def initialize(interval)
		@id = interval
		@curr_min_time = 0
	end

	def first_time(timestamp)
		step until @curr_min_time >= timestamp

		self
	end

	def to_answer(timestamp)
		(@curr_min_time - timestamp) * id
	end

		private

	def step
		@curr_min_time += @id
	end
end

timestamp = lines[0].to_i
busses = lines[1].split(',').filter { _1 != 'x' }.map do
	bus = Bus.new(_1.to_i)
	bus.first_time(timestamp)
end

soonest = busses.min { |a, b| a.curr_min_time <=> b.curr_min_time }
puts soonest.to_answer(timestamp)
