#!/usr/bin/env ruby
# frozen_string_literal: true

require 'set'

abort('Please provide input file') if ARGV.count.zero?
# This way sorbet gives at least _some_ hints.
lines = []
file = File.open(ARGV.first, 'r')
lines.concat file.readlines(chomp: true).reject(&:empty?)

# Node
class Node
	include Comparable

	attr_reader :label, :linked_nodes, :upper, :lower, :start, :end

	def initialize(label)
		@label = label
		@linked_nodes = {}

		@upper = label.match?(/[[:upper:]]/)
		@lower = !@upper
		@start = label == 'start'
		@end   = label == 'end'
	end

	alias upper? upper
	alias lower? lower
	alias start? start
	alias end? end

	def ==(other) = other&.label == @label
	alias eql? ==

	def <=>(other) = @label <=> other.label
end

Link = Struct.new(:a, :b) do
	def other(node)
		node == a ? b : a
	end
end

# Graph
class Graph
	attr_reader :nodes, :links, :start, :end, :visited_paths, :valid_paths

	def initialize
		@nodes = {}
		@links = []
		@path_hashes     = []
		@valid_paths     = Set.new
		@visited_paths   = Set.new
		@current_double  = nil
	end

	def add_nodes(nodea, nodeb)
		assign_nodes nodea, nodeb

		nodea.linked_nodes[nodeb.label] = nodeb
		nodeb.linked_nodes[nodea.label] = nodea
		assign_start_or_end nodea
		assign_start_or_end nodeb
	end

	def find_paths
		follow_path @nodes['start'], 'start'
	end

	def follow_path(node, path)
		node.linked_nodes.each do |to_node_label, to_node|
			new_path = "#{path},#{to_node_label}"

			next if to_node.start?
			next if @visited_paths.include? new_path

			@visited_paths << new_path
			if to_node.end? && !@valid_paths.include?(path)
				@valid_paths << new_path
				next
			end

			next if to_node.end?

			(double_lower_char, double_count) = path
			                                    .split(',')
			                                    .tally
			                                    .filter { |node_label, _| node_label.match?(/[[:lower:]]/) }
			                                    .max_by { |_node_label, double_count| double_count }

			next unless to_node.upper? ||
			            (double_count < 2 || (double_lower_char != to_node_label && !path.include?(to_node_label)))

			follow_path to_node, new_path
		end
	end

		private

	def assign_nodes(nodea, nodeb)
		@nodes[nodea.label] ||= nodea
		@nodes[nodeb.label] ||= nodeb
	end

	def assign_start_or_end(node)
		@start ||= node if node.start?
		@end   ||= node if node.end?
	end
end

graph = Graph.new
lines.each do |l|
	a, b = l.split '-'
	node_a = graph.nodes[a] || Node.new(a)
	node_b = graph.nodes[b] || Node.new(b)

	graph.add_nodes(node_a, node_b)
end

graph.find_paths
puts graph.valid_paths.length
