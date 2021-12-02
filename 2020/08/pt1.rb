$lines = File.readlines('./input.txt')

rows = []
$lines.each_with_index do |l, i|
	l.scan(/(\w{3}) (-|\+)(\d+)/)
	arg = $3.to_i
	arg = -(arg) if $2 == '-'
	rows.push({op: $1, arg: arg})
end

visisted_lines = {}
next_line = 0
acc = 0
until visisted_lines.include?(next_line)
	visisted_lines[next_line] = true
	row = rows[next_line]
	next_line += 1
	case row[:op]
	when 'acc'
		acc += row[:arg]
	when 'jmp'
		next_line += row[:arg] + -1
	when 'nop'
		# nop
	end

end

puts acc
