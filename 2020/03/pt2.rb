$lines = File.readlines('./input.txt')

class ACMap
	# Array of column values in grid.
	# True -> tree, False -> open
	attr_accessor :grid
	attr_reader :height
	attr_reader :width

	def initialize(lines)
		@grid = []

		lines.each_with_index do |row, r|
			row.chomp!
			@grid[r] = row.split(//).map {|c| c == '#'}
		end

		@height = @grid.length
		@width = @grid[0].length
	end

	def hit_trees(down, right)
		col = right
		trees = 0
		expansion = 1

		rows_to_check = (down..@height - 1).select.each_with_index { |_, i| i % down == 0 }
		rows_to_check.each do |i|
			trees += 1 if @grid[i][col]

			col += right
			col = col - @width if col >= @width
		end

		return trees
	end
end

map = ACMap.new($lines)
routes = [
	map.hit_trees(1, 1),
	map.hit_trees(1, 3),
	map.hit_trees(1, 5),
	map.hit_trees(1, 7),
	map.hit_trees(2, 1)
]

p routes.reduce(:*)

