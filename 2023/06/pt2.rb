#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'
extend T::Sig
T::Configuration.default_checked_level = :tests

require_relative '../../lib/file_parsers'

labels = ['Time:', 'Distance:']

parsed = FileParsers.labeled_groups(labels, alignment: FileParsers::GroupAlignment::Both).transform_values do |value|
	T.must(value.first&.split&.join&.to_i)
end

time, distance = parsed.values
time, distance = T.must(time), T.must(distance)
winning_races = (1...time).map { |milisec| milisec * (time - milisec) }.filter { _1 > T.must(distance) }
puts winning_races.count
