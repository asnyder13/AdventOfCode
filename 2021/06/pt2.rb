#!/usr/bin/env ruby
# frozen_string_literal: true

abort('Please provide input file and cycle count.') unless ARGV.count == 2
# This way sorbet gives at least _some_ hints.
lines = []
file = File.open(ARGV.first, 'r')
lines.concat file.readlines(chomp: true).reject(&:empty?)

ages = lines.first.split(',').map(&:to_i)

# School of fish
class School
	attr_accessor :fish

	def initialize(ages)
		@fish = Hash.new { |h, k| h[k] = 0 }
		ages.each { |x| @fish[x] += 1 }
	end

	def step
		spawn = fish[0]
		fish.delete 0

		old_fish = fish.dup
		fish.clear
		old_fish.each do |age, count|
			fish[age - 1] = count
		end

		unless spawn.zero?
			fish[6] += spawn
			fish[8] += spawn
		end

		self
	end

	def size = fish.values.reduce(:+)

	def inspect
		fish
	end
end

school = School.new ages
ARGV.last.to_i.times { school.step }
pp school.size
