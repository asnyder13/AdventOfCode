$lines = File.readlines('./input.txt')
parsed_lines = $lines.map(&:to_i)

def find_pair(arr, sum)
	arr.each do |a|
		arr.each do |b|
			next if a == b
			return true if a + b == sum
		end
	end

	return false
end

moving_set = []
invalid = -1
parsed_lines.each_with_index do |l, i|
	if i < 25
		moving_set.push(l)
	else
		if find_pair(moving_set, l)
			moving_set.shift
			moving_set.push(l)
		else
			invalid = l
			break
		end
	end
end

len = parsed_lines.length
parsed_lines.each_with_index do |l, i|
	sum = 0
	(i...len - 1).each do |j|
		sum += parsed_lines[j]
		if sum == invalid
			min, max = parsed_lines[i..j].min, parsed_lines[i..j].max
			puts "#{i}, #{j}, #{min}, #{max}, #{min + max}"
			exit
		end
	end
end
