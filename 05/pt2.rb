$lines = File.readlines('./input.txt')

class Seat
	attr_reader :ID
	def initialize(row, col)
		@row = row
		@col = col
		@ID = row * 8 + col
	end

	def <=>(other)
		@ID <=> other.ID
	end
end

class Plane
	# Binary space partitioning
	#  \w{7}
	#   F - upper half
	#   B - lower half
	#  \w{3}
	#   R - upper
	#   L - lower

	def initialize
		@seats = []
	end

	def get_IDs
		@seats.map(&:ID)
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
		@seats.push(Seat.new(down, over))
	end

	def find_missing_ID
		@seats.sort!
		bit = @seats.first.ID & 1 ^ 1
		@seats.each do |s|
			return s.ID - 1 if bit == (s.ID & 1)
			bit = s.ID & 1
		end
	end

end

plane = Plane.new()
$lines.each {|l| plane.parse_row(l) }
puts plane.find_missing_ID
