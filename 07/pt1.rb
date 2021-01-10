$lines = File.readlines('./input.txt')

$line_regex = /^(\w+ \w+) bags contain ((?:\d+ \w+ \w+ bags?(?:, )?)+)\.$/
$no_bag_regex = /^(\w+ \w+) bags contain no other bags\.$/

class Graph
	attr_reader :nodes

	def initialize
		# {
		#  "posh brown": {"light gray": 3, "bright red": 1"},
		#  "vibrant lime": {"dark blue": 2"}
		# }
		@nodes = {}
	end

	def add_node(line)
		if line =~ $line_regex
			key_color = $1
			linked_colors_str = $2
			@nodes[key_color] = Hash.new
			linked_colors_str.split(',').each do |color|
				color.scan(/(\d+) (\w+ \w+)/)[0]
				@nodes[key_color][$2] = $1.to_i
			end
		elsif line =~ $no_bag_regex
			key_color = $1
			@nodes[key_color] = Hash.new
		end
	end

	def find_containers(bottom_bag, current_bag)
		links = @nodes[current_bag].keys
		return true if links.include?(bottom_bag)
		return links.map{ |l| self.find_containers(bottom_bag, l) }.reduce(:|)
	end
end

graph = Graph.new
$lines.each do |l|
	graph.add_node(l)
end

puts graph.nodes.keys.map{|bag| graph.find_containers('shiny gold', bag) }.select{|x| x}.length
