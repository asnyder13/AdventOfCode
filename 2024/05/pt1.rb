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

passing = update_runs.filter do |updates|
  indecies = T.let({}, T::Hash[Integer, Integer])
  updates.each_with_index { |update, i| indecies[update] ||= i }

  updates.each_with_index.all? do |update, idx|
    leadings = page_ordering[update]
    next true if leadings.nil?

    leadings.all? do |leading_update|
      idx_leading = indecies[leading_update]
      idx_leading.nil? || idx_leading < idx
    end
  end
end

puts (passing.map { it[it.length / 2] }).sum
