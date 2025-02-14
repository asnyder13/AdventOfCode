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

rxp_page_ordering = /(\d+\|\d+)/
rxp_update = /(\d+,[\d,]+)/
matches = FileParsers.regexes rxp_page_ordering, rxp_update
matches_flattened = T.let(matches.transform_values { _1.flatten! 1 }, T::Hash[Regexp, StringArray])

page_ordering = T.let(Hash.new { |h, k| h[k] = Set.new }, T::Hash[Integer, T::Set[Integer]])
T.must(matches_flattened[rxp_page_ordering])
 .map { |pair_string| pair_string.split('|').map(&:to_i) }
 .each { |(lead, follow)| T.must(page_ordering[T.must(follow)]) << T.must(lead) }
update_runs = T.must(matches_flattened[rxp_update]).map { _1.split(',').map(&:to_i) }

sig {
  params(
    updates: T::Array[Integer],
    page_ordering: T::Hash[Integer, T::Set[Integer]],
    indecies: T::Hash[Integer, Integer]
  ).returns([T.nilable(Integer), T.nilable(Integer)])
}
def index_ooo(updates, page_ordering, indecies)
  ooo_val = T.let(nil, T.nilable(Integer))
  ooo_idx_precc = T.let(nil, T.nilable(Integer))
  target_idx = T.let(nil, T.nilable(Integer))

  updates.each_with_index do |update, idx|
    successions = page_ordering[update]
    next if successions.nil?

    ooo_val = successions.find do |succ_update|
      idx_precc = indecies[succ_update]
      next if idx_precc.nil?

      if idx_precc > idx
        ooo_idx_precc = idx_precc
        target_idx = idx
      end

      idx_precc > idx
    end

    break if ooo_val

    ooo_idx_precc = nil
    target_idx = nil
  end

  [target_idx, ooo_idx_precc]
end

sig {
  params(
    updates: T::Array[Integer],
    page_ordering: T::Hash[Integer, T::Set[Integer]],
    indecies: T::Hash[Integer, Integer]
  ).returns(T::Boolean)
}
def passing(updates, page_ordering, indecies)
  updates.each_with_index.all? do |update, idx|
    successions = page_ordering[update]
    next true if successions.nil?

    successions.all? do |succ_update|
      idx_leading = indecies[succ_update]
      idx_leading.nil? || idx_leading < idx
    end

    # ooo_idx, = index_ooo updates, page_ordering, indecies
    # ooo_idx.nil?
  end
end

not_passing = update_runs.filter do |updates|
  indecies = updates.each_with_index.to_h { [_1, _2] }

  !passing updates, page_ordering, indecies
end

def swap(arr, target_idx:, source_idx:)
  arr[target_idx], arr[source_idx] = arr[source_idx], arr[target_idx]
end

not_passing.each do |updates|
  loop do
    indecies = updates.each_with_index.to_h { [_1, _2] }
    (target_idx, source_idx) = index_ooo updates, page_ordering, indecies
    break if target_idx.nil? || source_idx.nil?

    swap(updates, target_idx:, source_idx:)
  end
end

puts (not_passing.map { it[it.length / 2] }).sum
