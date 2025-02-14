#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'matrix'
require 'set'
require 'sorbet-runtime'

extend T::Sig

lines = T.let([], T::Array[String])
input_file = ARGV.first || 'input.txt'
file = File.open(input_file, 'r')
lines.concat file.readlines(chomp: true).reject(&:empty?)

letters = T.let([], T::Array[String])
lines.each do |l|
	letters = l.chars unless l.empty?
end

OP_TYPES = {
	0 => :sum,
	1 => :product,
	2 => :min,
	3 => :max,
	4 => :literal,
	5 => :gt,
	6 => :lt,
	7 => :eq
}.freeze

# PacketParser
class PacketParser
	extend T::Sig

	def initialize
		@parse_depth = 0
		@last_type = :nop
	end

	sig { params(binary_string: String).returns(Symbol) }
	def get_v(binary_string)
		version_and_type = binary_string.match(/(\d{3})(\d{3})/)
		return :nop if version_and_type.nil?

		_version, type_id = version_and_type.captures.map { _1.to_i(2) }
		return OP_TYPES[type_id]
	end

	sig { params(binary_string: String).returns(Symbol) }
	def get_v!(binary_string)
		type = get_v binary_string
		binary_string.slice!(...6)
		return type
	end

	sig { params(binary_string: String).returns(Integer) }
	def parse_literal_packet(binary_string)
		sections = 0
		bits = binary_string.chars
		                    .each_slice(5)
		                    .map(&:join)
		                    .each.with_object([]) do |x, acc|
				sections += 1
				last_bit = x.start_with? '0'

				acc << x.match(/[01](\d{4})/)&.captures&.first
				raise 'No match on literal bit?' if acc.last.nil?

				break acc if last_bit
		end

		binary_string.slice!(...(sections * 5))
		bits.join.to_i(2)
	end

	sig { params(binary_string: String).returns(T::Array[Integer]) }
	def parse_operator_packet(binary_string)
		result = []
		first_bit = binary_string.slice!(0)

		case first_bit == '0' ? :bit_count : :packet_count
		when :bit_count
			# 15 bits for total length of sub-packets
			sub_length = binary_string.slice!(...15)&.to_i(2)
			raise 'No sub_length?' if sub_length.nil?

			sub_section = binary_string.slice!(...sub_length)
			raise 'No sub_section?' if sub_section.nil?

			result.concat [parse_packet(sub_section)] until sub_section.empty?
			result.concat [parse_packet(binary_string)]
		when :packet_count
			# 11 bits for the number of sub-packets immediately contained
			sub_packet_count = binary_string.slice!(...11)&.to_i(2)
			raise 'No sub_length?' if sub_packet_count.nil?

			sub_packet_count.times do
				result.concat [parse_packet(binary_string)]
			end
		end

		return result
	end

	sig { params(binary_string: String).returns(T.nilable(Integer)) }
	def parse_packet(binary_string)
		@parse_depth += 1
		# return 0 if binary_string.length <= 6

		type = get_v! binary_string
		@last_type = type

		values = []
		result = 0
		if type == :literal
			result = parse_literal_packet(binary_string)
		else
			t = @parse_depth
			values = parse_operator_packet(binary_string)
			values = values.compact

			case type
			when :sum
				result = values.reduce(&:+)
			when :product
				result = values.reduce(&:*)
			when :min
				result = values.min
			when :max
				result = values.max
				# when :literal
			when :gt
				first, second = values
				result = T.must(first) > T.must(second) ? 1 : 0
			when :lt
				first, second = values
				result = T.must(first) < T.must(second) ? 1 : 0
			when :eq
				first, second = values
				result = T.must(first) == T.must(second) ? 1 : 0
			when :nop
				result = nil
			else raise 'Cant determine packet type'
			end
		end

		@parse_depth -= 1
		return result
	end
end

# result = parse_packet letters.map { _1.to_i(16).to_s(2).rjust(4, '0') }.join
# puts result
temp = PacketParser.new
result = temp.parse_packet letters.map { _1.to_i(16).to_s(2).rjust(4, '0') }.join
puts result
