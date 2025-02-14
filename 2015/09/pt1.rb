#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'
require 'matrix'

extend T::Sig

input_file = ARGV.first || 'testinput.txt'
file = File.open(input_file, 'r')

lines = file.readlines(chomp: true)

Route = Struct.new(:start, :end, :distance)
all_routes = []
cities = Set.new
lines.reject(&:empty?).each do |l|
	match = T.must(l.match(/(?<from>\w+) to (?<to>\w+) = (?<distance>\d+)/))
	from = match['from']
	to = match['to']
	all_routes << Route.new(from, to, match['distance'].to_i)
	all_routes << Route.new(to, from, match['distance'].to_i)
	cities << from << to
end
cities_count = cities.length

pp all_routes

all_routes_matrix = Matrix.build(cities.length) { 0 }
matrix_keys = cities.map.with_index { |c, i| [c, i] }.to_h
pp matrix_keys

all_routes.each do |route|
	all_routes_matrix[matrix_keys[route.start], matrix_keys[route.end]] = route.distance
end
pp all_routes_matrix
#
# cities.each do |city|
# 	
# end

# pp all_routes.sort_by(&:start)
# [#<struct Route start="Belfast", end="London", distance="518">,
#  #<struct Route start="Belfast", end="Dublin", distance="141">,
#  #<struct Route start="Dublin", end="London", distance="464">,
#  #<struct Route start="Dublin", end="Belfast", distance="141">,
#  #<struct Route start="London", end="Dublin", distance="464">,
#  #<struct Route start="London", end="Belfast", distance="518">]
# pp cities
#
# def follow(routes, city) = routes.filter { _1.start == city }
#
# full_routes = {}
# cities.each do |city|
# 	# starting_routes = routes.filter { _1.start == city }
# 	routes = follow all_routes, city
# 	route_length = 1
#
# 	routes.each do |route|
#
# 	end
#
# 	until route_length == cities_count
# 		routes = follow routes, city
# 		route_length += 1
# 	end
# end
