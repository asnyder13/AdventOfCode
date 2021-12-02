$lines = File.foreach('./input.txt')

class PassLine
	attr_accessor :min
	attr_accessor :max
	attr_accessor :let
	attr_accessor :pass

	def initialize(min, max, let, pass)
		@min = min
		@max = max
		@let = let
		@pass = pass
	end

	def is_valid?
		count = @pass.count(@let)
		return count >= @min && count <= @max
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
