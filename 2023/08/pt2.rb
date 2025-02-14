#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'bundler'
Bundler.require

extend T::Sig
# T::Configuration.default_checked_level = :tests

require_relative '../../lib/file_parsers'
require_relative '../../lib/extensions'

L = 'L'
R = 'R'
A = 'A'
Z = 'Z'

class String
	sig { returns(T::Boolean) }
	def start_node?
		@start_node = end_with? A if @start_node.nil?
		@start_node
	end

	sig { returns(T::Boolean) }
	def end_node?
		@end_node = end_with? Z if @end_node.nil?
		@end_node
	end
end

rxp_turns = /([RL]+)/
rxp_nodes = /(\w+) = \((\w+), (\w+)\)/
matches = FileParsers.regexes(rxp_turns, rxp_nodes)

instruction = T.must(matches[rxp_turns]&.flatten&.first)
nodes = T.must(matches[rxp_nodes])

graph = T.let({}, T::Hash[String, T::Hash[String, String]])
nodes_starting = T.let([], StringArray)

nodes.each do |node|
	root, left, right = node
	raise "Nodes weren't parsed right: #{root} #{left} #{right}"  if root.nil? || left.nil? || right.nil?

	graph[root] = { L => left, R => right }
	nodes_starting << root if root.start_node?
end

positions = T.let(nodes_starting.to_h { [_1, _1] }, T::Hash[String, String])

len = T.let([], T::Array[Integer])
positions.each_key do |root|
	curr_node = root
	instruction.chars.cycle.each.with_index do |dir, idx|
		curr_node = T.must(T.must(graph[curr_node])[dir])
		if curr_node.end_node?
			len << idx + 1
			break
		end
	end
end
puts len.reduce(:lcm)
# 8811050362409
