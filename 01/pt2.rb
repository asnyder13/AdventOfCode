expenses = File.readlines('./input.txt').map(&:to_i)

answer = -1
expenses.each_with_index do |exp1, i1|
	expenses.drop(i1 + 1).each_with_index do |exp2, i2|
		expenses.drop(i2 + 1).each do |exp3|
			curr = exp1 + exp2 + exp3
			if curr == 2020
				answer = exp1 * exp2 * exp3
				break
			end
		end
	end
end

puts answer
