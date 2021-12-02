$lines = File.readlines('./input.txt')

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
$lines.map(&:to_i).each_with_index do |l, i|
	if i < 25
		moving_set.push(l)
	else
		if find_pair(moving_set, l)
			moving_set.shift
			moving_set.push(l)
		else
			puts l
			break
		end
	end
end
