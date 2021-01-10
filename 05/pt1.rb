$lines = File.readlines('./input.txt')

class Plane
	# Binary space partitioning
	#  \w{7}
	#   F - upper half
	#   B - lower half
	#  \w{3}
	#   R - upper
	#   L - lower
	@rows
	@columns

	# [{row: 0, col: 7}]
	@seats

	def initialize
		@rows = 128
		@columns = 8
		@seats = []
	end

	def get_IDs
		@seats.map{|seat| (seat[:row] * 8) + seat[:col] }
	end

	def parse_row(line)
		line.chomp!
		down = line[...7]
							.split('')
							.map {|c| c == 'B' ? '1' : '0' }
							.join
							.to_i(2)
		over = line[7..]
							.split('')
							.map {|c| c == 'R' ? '1' : '0' }
							.join
							.to_i(2)
		@seats.push({ row: down, col: over })
	end

end

plane = Plane.new()
$lines.each {|l| plane.parse_row(l) }
puts plane.get_IDs.max

