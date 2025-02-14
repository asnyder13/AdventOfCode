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
		result.push(b - a)
	end

	result
end

diff_sets = T.let([], T::Array[IntArrayArray])
lines.each do |history_values|
	diff = history_values
	diff_sets << [diff]
	loop do
		diff = diffrerences diff
		diff_sets.last << diff
		break if diff.all?(&:zero?)
	end
end

vals = diff_sets.map do |extrapolations|
	extrapolations.map(&:first).reverse.reduce(0) { |acc, curr| curr - acc }
end

puts vals.sum
