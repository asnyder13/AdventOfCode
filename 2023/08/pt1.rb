#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'bundler'
Bundler.require

extend T::Sig
T::Configuration.default_checked_level = :tests

require_relative '../../lib/file_parsers'
require_relative '../../lib/extensions'

L = 'L'
R = 'R'
START_NODE = 'AAA'
END_NODE = 'ZZZ'

rxp_turns = /([RL]+)/
rxp_nodes = /(\w+) = \((\w+), (\w+)\)/
matches = FileParsers.regexes([rxp_turns, rxp_nodes])

instruction = T.must(matches[rxp_turns]&.flatten&.first)
nodes = T.must(matches[rxp_nodes])

graph = T.let({}, T::Hash[String, T::Hash[String, String]])

nodes.each do |node|
	start, left, right = node
	raise "Nodes weren't parsed right: #{start} #{left} #{right}"  if start.nil? || left.nil? || right.nil?

	graph[start] = { L => left, R => right }
end

node = T.must(graph[START_NODE])
step_count = 0
instruction.chars.cycle.each do |dir|
	step_count += 1
	next_target = T.must(node[dir])
	break if next_target == END_NODE

	node = T.must(graph[next_target])
end

puts step_count
# 19637
