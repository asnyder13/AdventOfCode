expenses = File.readlines('./input.txt').map(&:to_i)

answer = -1
expenses.each_with_index do |exp1, i|
	expenses.drop(i + 1).each do |exp2|
		curr = exp1 + exp2
		if curr == 2020
			answer = exp1 * exp2
			break
		end
	end
end

puts answer
