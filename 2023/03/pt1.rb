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

valid_runs = T.let([], SeatRuns)
get_numbers(fp).each do |run|
	valid = run.any? do |seat|
		seat.neighbours.reject { _1.value.numeric? }.any? do |neigh|
			neigh.value != '.'
		end
	end

	valid_runs << run if valid
end

pp valid_runs.map { _1.map(&:value).join }.map(&:to_i).sum
