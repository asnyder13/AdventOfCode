$lines = File.readlines('./input.txt')

rows = []
$lines.each_with_index do |l, i|
	if l =~ /(\w{3}) ((?:-|\+)\d+)/
		rows.push({op: $1, arg: $2.to_i})
	end
end

def attempt_run(rows, line_to_switch = -1)
	visisted_lines = {}
	next_line = 0
	acc = 0

	until visisted_lines[next_line] || next_line >= rows.length
		visisted_lines[next_line] = true
		row = rows[next_line]
		next_line += 1

		if next_line == line_to_switch
			case row[:op]
			when 'acc'
				acc += row[:arg]
			when 'jmp'
				# nop
			when 'nop'
				next_line += row[:arg] - 1
			end
		elsif
			case row[:op]
			when 'acc'
				acc += row[:arg]
			when 'jmp'
				next_line += row[:arg] - 1
			when 'nop'
				# nop
			end
		end

	end

	at_end = next_line == rows.length
	return at_end, acc
end

found_fix, acc = attempt_run(rows)

curr_line = -1
until found_fix
	curr_line += 1
	found_fix, acc = attempt_run(rows, curr_line)
end

puts acc
