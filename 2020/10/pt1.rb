$lines = File.readlines('./input.txt')
adapters = $lines.map(&:to_i).sort
adapters.unshift(0)
adapters.push(adapters.last + 3)

diffs = { 1 => 0, 2 => 0, 3 => 0 }
(0...adapters.length - 1).each do |i|
	diff = adapters[i + 1] - adapters[i]
	diffs[diff] += 1
end

puts "1: #{diffs[1]}, 2: #{diffs[2]}, 3: #{diffs[3]}"
puts "Answer: #{diffs[1] * diffs[3]}"
