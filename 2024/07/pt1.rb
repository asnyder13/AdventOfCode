#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'bundler'
Bundler.require

extend T::Sig
T::Configuration.default_checked_level = :tests

require_relative '../../lib/file_parsers'
require_relative '../../lib/extensions'
require_relative '../../lib/floorplan'

num_regexes = /(\d+): (.+)/
matches = FileParsers.regexes(num_regexes)[num_regexes]
class Computation < T::Struct
  const :result, Integer
  const :operands, T::Array[Integer]
end

computations = T.must(matches).map do |(result, operands)|
  Computation.new(result: result.to_i, operands: T.must(operands).scan(/\d+/).map(&:to_i))
end

sum = 0
computations.each do |computation|
  operator_count = computation.operands.length - 1
  combin = ((2**operator_count) - 1)

  working_count = 0
  until combin.negative?
    ops = combin.to_s(2).rjust(operator_count, '0').chars.map { it == '1' ? :+ : :* }
    i = 0
    result = T.must(computation.operands).reduce do |acc, x|
      i += 1
      acc.send(T.must(ops[i - 1]), x)
    end

    if result == computation.result
      working_count += 1
      break
    end
    combin -= 1
  end
  sum += computation.result if working_count.positive?
end

puts sum
