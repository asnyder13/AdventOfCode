$lines = File.readlines('./input.txt')

# Each line is a person's answers
# Groups separated by empty lines

class Group

	def initialize
		@answers = Hash.new
	end

	def parse_line(line)
		line.chomp!
		line.each_char do |c|
			@answers[c] = true;
		end
	end

	def answered
		return @answers.length
	end
end

groups = [Group.new]
$lines.each do |l|
	if l == "\n"
		groups.push(Group.new)
		next
	end
	groups.last.parse_line(l)
end

puts groups.map(&:answered).reduce(&:+)
