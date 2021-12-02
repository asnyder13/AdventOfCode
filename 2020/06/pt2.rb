$lines = File.readlines('./input.txt')

# Each line is a person's answers
# Groups separated by empty lines

class Group

	def initialize
		@answers = Hash.new
		@members = 0
	end

	def parse_line(line)
		@members = @members + 1
		line.chomp!
		line.each_char do |c|
			@answers[c] = (@answers[c] || 0) + 1;
		end
	end

	def answered
		return @answers.length
	end

	def all_answered
		return @answers.select {|a,c| c == @members }.length
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

puts groups.map(&:all_answered).reduce(&:+)
