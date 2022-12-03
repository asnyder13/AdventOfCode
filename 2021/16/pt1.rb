#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'matrix'
require 'set'
require 'sorbet-runtime'

extend T::Sig

lines = T.let([], T::Array[String])
input_file = ARGV.first || 'testinput2.txt'
file = File.open(input_file, 'r')
lines.concat file.readlines(chomp: true).reject(&:empty?)

letters = T.let([], T::Array[String])
lines.each do |l|
	letters = l.chars unless l.empty?
end

LITERAL_TYPE = 4
sig { params(binary_string: String).returns([Integer, Symbol]) }
def get_v_and_t(binary_string)
	version_and_type = binary_string.match(/(\d{3})(\d{3})/)
	raise 'No match data' if version_and_type.nil?

	version, type_id = version_and_type.captures.map { _1.to_i(2) }
	type = type_id == LITERAL_TYPE ? :literal : :operator
	return version || 0, type
end

sig { params(binary_string: String).returns([Integer, Symbol]) }
def get_v_and_t!(binary_string)
	version, type = get_v_and_t binary_string
	binary_string.slice!(...6)
	return version, type
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
	bits.join.to_i 2
end

sig { params(binary_string: String).returns([Integer, Integer]) }
def parse_operator_packet(binary_string)
	version_sum = value_sum = 0
	first_bit = binary_string.slice!(0)
	case first_bit == '0' ? :bit_count : :packet_count
	when :bit_count
		# 15 bits for total length of sub-packets
		sub_length = binary_string.slice!(...15)&.to_i(2)
		raise 'No sub_length?' if sub_length.nil?

		sub_section = binary_string.slice!(...sub_length)
		raise 'No sub_section?' if sub_section.nil?

		until sub_section.empty?
			ver, val = parse_packet sub_section
			version_sum += ver
			value_sum   += val
		end
		ver, val = parse_packet binary_string
		version_sum += ver
		value_sum   += val
	when :packet_count
		# 11 bits for the number of sub-packets immediately contained
		sub_packet_count = binary_string.slice!(...11).to_i(2)
		raise 'No sub_length?' if sub_packet_count.nil?

		sub_packet_count.times do
			ver, val = parse_packet binary_string
			version_sum += ver
			value_sum   += val
		end
	end

	return version_sum, value_sum
end

sig { params(binary_string: String).returns([Integer, Integer]) }
def parse_packet(binary_string)
	return 0, 0 if binary_string.length <= 6

	value_sum = 0
	version_sum, type = get_v_and_t! binary_string
	return 0, 0 if binary_string.to_i(2).zero?

	case type
	when :literal
		# TODO: not updating the binary string here.
		value_sum += parse_literal_packet binary_string
	when :operator
		ver, val = parse_operator_packet binary_string
		version_sum += ver
		value_sum   += val
	else raise 'Cant determine packet type'
	end

	return version_sum, value_sum
end

version_sum, _value_sum = parse_packet letters.map { _1.to_i(16).to_s(2).rjust(4, '0') }.join
puts version_sum
