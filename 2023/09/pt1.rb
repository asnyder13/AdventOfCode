#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'bundler'
Bundler.require

extend T::Sig
T::Configuration.default_checked_level = :tests

require_relative '../../lib/file_parsers'
require_relative '../../lib/extensions'

lines = FileParsers.whitespace_separated_ints

IntArray = T.type_alias { T::Array[Integer] }
IntArrayArray = T.type_alias { T::Array[IntArray] }
sig { params(arr: IntArray).returns(IntArray) }
def diffrerences(arr)
	result = []
	arr.each_cons(2) do |a, b|
		result.push(T.must(b) - T.must(a))
	end

	result
end

results = T.let([], T::Array[IntArrayArray])
lines.each do |history_values|
	result = history_values
	results << [result]
	loop do
		result = diffrerences result
		results.last << result
		break if result.all?(&:zero?)
	end
end

vals = results.map do |extrapolations|
	extrapolations.map(&:last).reverse.reduce(0, :+)
end

puts vals.sum
