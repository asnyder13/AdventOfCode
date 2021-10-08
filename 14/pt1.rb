#!/usr/bin/env ruby
# frozen_string_literal: true

abort('Please provide input file') if ARGV.count.zero?
lines = ARGF.readlines

# {mask: String, mems: {addr: Integer}
Instruction = Struct.new(:mask, :mems)

instructions = []
lines.each do |l|
	case l
	when /mask = (\w+)/
		instructions << Instruction.new($1, {})
	when /mem\[(\d+)\] = (\d+)/
		instructions.last.mems[$1] = $2.to_i
	end
end

def change_bit(value, pos, bit)
	if bit.zero?
		value & ~(1 << pos)
	else
		value | 1 << pos
	end
end

mem = {}
instructions.each do |i|
	# {mask: String, mems: {addr: Integer}
	mask_bits = i.mask
	             .chars
	             .reverse
	             .each.with_index
	             .reject { |bit, _| bit == 'X' }
	             .map { |bit, pos| [bit.to_i, pos] }

	i.mems.each do |addr, value|
		mask_bits.each do |bit, pos|
			value = change_bit(value, pos, bit)
		end

		mem[addr] = value
	end
end

puts mem.values.reduce(:+)
