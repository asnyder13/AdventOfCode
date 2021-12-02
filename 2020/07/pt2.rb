$lines = File.readlines('./input.txt')

$line_regex = /^(\w+ \w+) bags contain ((?:\d+ \w+ \w+ bags?(?:, )?)+)\.$/
$no_bag_regex = /^(\w+ \w+) bags contain no other bags\.$/

class Graph
	attr_reader :nodes

	def initialize
		# {
		#  "posh brown": {"light gray": 3, "bright red": 1},
		#  "vibrant lime": {"dark blue": 2}
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

	def find_outer_bags(bottom_bag, current_bag)
		links = @nodes[current_bag].keys
		return true if links.include?(bottom_bag)
		return links.map{ |l| self.find_outer_bags(bottom_bag, l) }.reduce(:|)
	end

	def nested_bags_count(current_bag)
		curr = @nodes[current_bag]
		return curr.reduce(0) {|sum, (k,v)| sum + v + v * self.nested_bags_count(k) }
	end

end

graph = Graph.new
$lines.each{|l| graph.add_node(l) }
puts graph.nested_bags_count('shiny gold')
