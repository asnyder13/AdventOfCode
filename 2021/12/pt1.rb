#!/usr/bin/env ruby
# frozen_string_literal: true

abort('Please provide input file') if ARGV.count.zero?
# This way sorbet gives at least _some_ hints.
lines = []
file = File.open(ARGV.first, 'r')
lines.concat file.readlines(chomp: true).reject(&:empty?)

# Node
class Node
	include Comparable

	attr_reader :label, :linked_nodes

	def initialize(label)
		@label = label
		@linked_nodes = {}
	end

	def upper? = label.match?(/[[:upper:]]/)
	def lower? = !upper?
	def start? = label == 'start'
	def end?   = label == 'end'

	def ==(other)   = other&.label == @label
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
		@path_hashes   = []
		@valid_paths   = []
		@visited_paths = []
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

			follow_path(to_node, new_path) unless to_node.lower? && path.include?(to_node_label)
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
