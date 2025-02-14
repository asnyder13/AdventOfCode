#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'bundler'
Bundler.require
require 'awesome_print'

extend T::Sig
T::Configuration.default_checked_level = :tests

require_relative '../../lib/file_parsers'
require_relative '../../lib/extensions'
IntArray = T.type_alias { T::Array[Integer] }

reports = FileParsers.whitespace_separated_ints

sig { params(report: IntArray).returns(IntArray) }
def make_diffs(report) = report.each_cons(2).map { |(a, b)| a - b }

sig { params(report: IntArray).returns([T::Boolean, T::Boolean, IntArray]) }
def one_direction(report)
  diffs = make_diffs report
  one_dir = diffs.all?(&:positive?) || diffs.all?(&:negative?)

  count_pos = diffs.count(&:positive?)
  count_neg = diffs.count(&:negative?)
  count_zero = diffs.count(&:zero?)

  if count_pos == 1
    report.delete_at T.must(diffs.index(&:positive?))
  elsif count_neg == 1
    report.delete_at T.must(diffs.index(&:negative?))
  elsif count_zero == 1
    report.delete_at T.must(diffs.index(&:zero?))
  end

  removed = !one_dir && (count_pos == 1 || count_neg == 1 || count_zero == 1)

  return one_dir || removed, removed, report
end

sig { params(report: IntArray).returns([T::Boolean, T::Boolean]) }
def steps_safe(report)
  diffs = make_diffs(report).map(&:abs)
  report = report.clone

  all_in_range = diffs.all? { it >= 1 && it <= 3 }

  removed = false
  unless all_in_range
    high_idx = diffs.index { it < 1 || it > 3 }
    report.delete_at(T.must(high_idx))
    removed = true

    return false, false unless make_diffs(report).all? { it >= 1 && it <= 3 }
  end

  return all_in_range || removed, removed
end

safe = reports.filter.with_index do |report, i|
  errors = 0

  one_dir, removed = one_direction report
  errors += 1 if removed
  # p one_dir, removed if i == 4

  safe_steps, removed = steps_safe report
  errors += 1 if removed
  # p safe_steps, removed if i == 4

  # if i == 4
  #   ap report
  #   ap make_diffs report
  # end
  (one_dir && safe_steps && errors <= 1)
end

# ap safe
puts safe.length
# 400 too low
