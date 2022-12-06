#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'

lines = T.let([], T::Array[String])
input_file = ARGV.first || 'testinput.txt'
file = File.open(input_file, 'r')

lines = file.readlines

OP = Struct.new(:amt, :from, :to)

stacks = {}
ops = []
lines.each do |l|
	stack_regex = / {3}|\[(\w+)\][ \n]/

	case l
	when stack_regex
		cols = l.scan(stack_regex).flatten
		cols.each.with_index do |x, i|
			stacks[i + 1] ||= []
			stacks[i + 1].unshift x unless x.nil?
		end
	when /^move/
		amt, from, to = l.scan(/^move (\d+) from (\d+) to (\d+)/).flatten
		ops << OP.new(amt.to_i, from.to_i, to.to_i)
	end
end

ops.each do |op|
	stacks[op.to].concat stacks[op.from].slice!(-op.amt..)
end

puts stacks.map { |_, stack| stack.last }.join
