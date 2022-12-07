#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'

extend T::Sig

input_file = ARGV.first || 'testinput.txt'
file = File.open(input_file, 'r')

lines = file.readlines(chomp: true)

# Circuit
class Circuit
	extend T::Sig

	attr_reader :outputs

	def initialize
		@outputs = {}
		@memo = {}
	end

	sig { params(connection: Connection).void }
	def <<(connection) = @outputs[connection.wire_out] = connection

	# Each output wire is unique
	def output(wire_out)
		result = @memo[wire_out]
		return result unless result.nil?

		if wire_out.match(/\d+/)
			@memo[wire_out] = wire_out.to_i
			return wire_out.to_i
		end

		conn = T.let(@outputs[wire_out], Connection)
		case conn.op
		when :source then result = conn.val
		when :wire
			wire_in = T.must(conn.inputs.first)
			result = output(wire_in)
		when :and
			wire1, wire2 = conn.inputs
			result = output(wire1) & output(wire2)
		when :or
			wire1, wire2 = conn.inputs
			result = output(wire1) | output(wire2)
		when :lshift
			wire_in = T.must(conn.inputs.first)
			val = output wire_in
			result = val << conn.shift_val
		when :rshift
			wire_in = T.must(conn.inputs.first)
			val = output wire_in
			result = val >> conn.shift_val
		when :not
			wire_in = T.must(conn.inputs.first)
			val = output wire_in
			result = neg_16_bit val
		end

		raise 'result not found' if result.negative?

		@memo[wire_out] = result
		result
	end

		private

	sig { params(num: Integer).returns(Integer) }
	def neg_16_bit(num)
		[~num].pack('S').unpack1('S')
	end
end

# Connection
class Connection
	extend T::Sig

	sig { returns(Integer) }
	attr_reader :val, :shift_val

	sig { returns(Symbol) }
	attr_reader :op

	sig { returns(String) }
	attr_reader :wire_out

	sig { returns(T::Array[String]) }
	attr_reader :inputs

	def initialize(line)
		@inputs = []

		case line
		when /^(\d+) -> (\w+)/
			@op = :source
			val, @wire_out = T.must(Regexp.last_match).captures
			@val = val.to_i
		when /^(\w+) -> (\w+)/
			@op = :wire
			val, @wire_out = T.must(Regexp.last_match).captures
			@inputs << val
		when /^(\w+) (AND|OR) (\w+) -> (\w+)/
			wire1, this_op, wire2, @wire_out = T.must(Regexp.last_match).captures
			@op = T.must(this_op).downcase.to_sym
			@inputs << wire1 << wire2
		when /^(\w+) ([LR]SHIFT) (\d+) -> (\w+)/
			wire1, this_op, shift_val, @wire_out = T.must(Regexp.last_match).captures
			@op = T.must(this_op).downcase.to_sym
			@inputs << wire1
			@shift_val = shift_val.to_i
		when /^NOT (\w+) -> (\w+)/
			@op = :not
			wire_in, @wire_out = T.must(Regexp.last_match).captures
			@inputs << wire_in
		else
			raise "Bad conn parse #{line}"
		end
	end
end

circuit = Circuit.new
lines.each { |l| circuit << Connection.new(l) }

puts circuit.output('a')
