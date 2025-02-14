#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'bundler'
Bundler.require

extend T::Sig
T::Configuration.default_checked_level = :tests

require 'parallel'
require 'etc'

require_relative '../../lib/file_parsers'
require_relative '../../lib/extensions'
require_relative '../../lib/floorplan'
require_relative '../../lib/parallelism'

num_regexes = /(\d+): (.+)/
matches = FileParsers.regexes(num_regexes)[num_regexes]
class Computation < T::Struct
  const :result, Integer
  const :operands, T::Array[Integer]
end

computations = T.must(matches).map do |(result, operands)|
  Computation.new(result: result.to_i, operands: T.must(operands).scan(/\d+/).map(&:to_i))
end

temp = Parallel.map(computations, in_processes: Etc.nprocessors) do |computation|
  operator_count = computation.operands.length - 1
  combin = ((3**operator_count) - 1)

  working_count = 0
  until combin.negative?
    ops = combin.to_s(3).rjust(operator_count, '0').chars.map do |x|
      case x
      when '1'
        :+
      when '2'
        :*
      else
        :concat
      end
    end

    i = 0
    result = T.must(computation.operands).reduce do |acc, x|
      i += 1
      op = T.must(ops[i - 1])
      if op == :concat
        (acc.to_s + x.to_s).to_i
      else
        acc.send(op, x)
      end
    end

    if result == computation.result
      working_count += 1
      break
    end
    combin -= 1
  end

  computation.result if working_count.positive?
end
# ap temp
ap temp.compact.sum

# res = pool.close
# results = res.split.map(&:to_i)
# sum = results.sum

# puts sum
