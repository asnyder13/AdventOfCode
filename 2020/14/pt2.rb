#!/usr/bin/env ruby
# frozen_string_literal: true

abort('Please provide input file') if ARGV.count.zero?
lines = ARGF.readlines

# {mask: String, mems: {addr: Integer} }
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

def change_string(value, pos, bit)
	value[pos] = bit
	value
end

def make_mask_hash(mask_indexes, perm_strings)
	x = perm_strings.map do |ps|
		mask_indexes.zip(ps.chars)
	end

	x.map(&:to_h)
end

def floating_bit_masks(mask)
	# 1X01X
	mask_split = mask.chars
	                 .reverse
	 	               .each.with_index
	# [[X,0],[1,1],[0,2],[X,3],[1,4]]
	mask_bits = mask_split.select { |char, _i| char == 'X' }
	# [[X,0],[X,3]]
	mask_indexes = mask_bits.map { |_char, i| i }
	# [0, 3]
	total_addresses = 2**mask_bits.length
	# 4
	permutation_strings = (0...total_addresses).map { |x| x.to_s(2).rjust(mask_bits.length, '0') }
	# ['00','01','10','11']
	make_mask_hash(mask_indexes, permutation_strings)
end

mem = {}
instructions.each do |i|
	# {mask: String, mems: {addr: Integer} }
	mask_bits = i.mask
	             .chars
	             .reverse
	             .each.with_index

	i.mems.each do |addr, value|
		init = addr.to_i.to_s(2).rjust(i.mask.length, '0').reverse
		mask_bits.each do |c, i2|
			next if %w[X 0].include?(c)

			change_string(init, i2, '1')
		end

		floating_masks = floating_bit_masks(i.mask)
		new_addrs = []
		floating_masks.each do |fm|
			side_effects = init.dup
			fm.each do |idx, bit|
				change_string(side_effects, idx, bit)
			end
			new_addrs << side_effects
		end

		new_addrs.flatten.map(&:reverse).each do |a|
			mem[a.to_i] = value
		end
	end
end

puts mem.values.reduce(:+)
