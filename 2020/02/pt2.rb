$lines = File.foreach('./input.txt')

class PassLine
	attr_accessor :first
	attr_accessor :second
	attr_accessor :let
	attr_accessor :pass

	def initialize(first, second, let, pass)
		@first= first
		@second= second
		@let = let
		@pass = pass
	end

	def is_valid?
		pos1 = pass[first - 1] == let
		pos2 = pass[second - 1] == let
		return true if pos1 && !pos2
		return true if pos2 && !pos1
		return false
	end
end

def parse_lines(lines)
	passwordInfo = []
	valids = 0

	lines.each do |line|
		caps = line.scan(/(\d+)-(\d+) (\w): (\w+)/)
		count = $4.count($3)

		passwordInfo.append(PassLine.new(
			$1.to_i,
			$2.to_i,
			$3,
			$4
		))
	end
	passwordInfo.each { |l| valids += 1 if l.is_valid? }
	return valids
end

puts parse_lines($lines)
