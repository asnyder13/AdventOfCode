#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'matrix'
require_relative './priority_queue'

lines = []
input_file = ARGV.first || 'testinput.txt'
file = File.open(input_file, 'r')
lines.concat file.readlines(chomp: true).reject(&:empty?)

DIRS    = [[-1, 0], [0, -1], [1, 0], [0, 1]].freeze
VECTORS = DIRS.map { Vector[*_1] }
def neighbours(point)
	point_vector = Vector[*point]
	VECTORS.map { |vec| point_vector + vec }.filter { |vec| vec.none?(&:negative?) }.map(&:to_a)
end

rows = lines.map do |l|
	l.chars.map(&:to_i)
end
risk_map = Matrix.rows rows

distance      = Hash.new(Float::INFINITY)
previous      = {}
queue         = MinPriorityQueue.new

distance[[0, 0]] = 0
risk_map.each_with_index { |_risk, row, col| queue.push distance[[row, col]], [row, col] }

until queue.length.zero?
	node = queue.pop

	neighbours(node).each do |neigh|
		next if risk_map[*neigh].nil?

		alt = distance[node] + risk_map[*neigh]

		next unless alt < distance[neigh]

		distance[neigh] = alt
		previous[neigh] = node
		queue.decrease_priority alt, neigh if queue.include? neigh
	end
end

puts distance[[risk_map.row_count - 1, risk_map.column_count - 1]]
