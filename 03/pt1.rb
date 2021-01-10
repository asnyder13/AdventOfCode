$lines = File.readlines('./input.txt')

class ACMap
	# Array of column values in grid.
	# True -> tree, False -> open
	attr_accessor :grid
	attr_accessor :width

	def initialize(lines)
		@grid = []

		lines.each_with_index do |row, r|
			row.chomp!
			@grid[r] = []
			row.each_char.with_index do |cell, c|
				@grid[r][c] = cell == '#'
			end
		end

		@width = @grid[0].length
	end

	def hit_trees
		col = 3
		trees = 0
		expansion = 1

		@grid.each_with_index do |r,i|
			next if i == 0

			trees += 1 if r[col]

			# right 3, down 1
			col += 3
			col = col - @width if col >= @width
		end

		return trees
	end
end

p ACMap.new($lines).hit_trees

