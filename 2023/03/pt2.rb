#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'
require_relative '../../lib/floorplan'
require_relative '../../lib/extensions'

extend T::Sig
T::Configuration.default_checked_level = :tests

input_file = ARGV.first || 'testinput.txt'
file = File.open(input_file, 'r')

lines = T.unsafe(file).readlines(chomp: true)
row_length = lines.first&.length
raise "Couldn't read line length"  if row_length.nil?

fp = Floorplan[String].new(row_length)

lines.each_with_index do |line, x|
	line.chars.each_with_index do |char, y|
		vector = Vector[x, y]
		Seat.new(floorplan: fp, value: char, vector:)
	end
end

SeatRun = T.type_alias { T::Array[Seat[String]] }
SeatRuns = T.type_alias { T::Array[SeatRun] }
sig { params(floorplan: Floorplan[String]).returns(SeatRuns) }
def get_numbers(floorplan)
	runs = T.let([[]], SeatRuns)
	floorplan.rows.each do |row|
		row.each do |seat|
			unless seat.value.numeric?
				runs << [] unless runs.last&.empty?
				next
			end

			runs.last&.push seat
		end
	end

	runs.pop
	runs
end

sig { params(floorplan: Floorplan[String]).returns(SeatRuns) }
def get_part_numbers(floorplan)
	get_numbers(floorplan).filter do |run|
		run.any? do |seat|
			seat.neighbours.reject { _1.value.numeric? }.any? do |neigh|
				neigh.value != '.'
			end
		end
	end
end

sig { params(floorplan: Floorplan[String]).returns(SeatRun) }
def get_gears(floorplan)
	floorplan.rows.map do |row|
		row.filter { _1.value == '*' }
 end.flatten
end

part_numbers = get_part_numbers(fp)
valid_gear_runs = get_gears(fp).map do |gear|
	part_numbers.filter do |part_run|
		part_run.any? { |part| gear.adjacent(part) }
	end
end.filter { _1.length == 2 }

ratios = valid_gear_runs.map do |runs|
	runs.map { _1.map(&:value).join }.map(&:to_i).reduce(&:*)
end
p ratios.sum
