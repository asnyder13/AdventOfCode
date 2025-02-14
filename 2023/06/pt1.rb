#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'
extend T::Sig
T::Configuration.default_checked_level = :tests

require_relative '../../lib/file_parsers'

labels = ['Time:', 'Distance:']

# parsed = FileParsers.labeled_groups(labels, alignment: FileParsers::GroupAlignment::Both).transform_values do |value|
parsed = FileParsers.labeled_groups(labels, alignment: FileParsers::GroupAlignment::Both).transform_values do |value|
	value.first&.split&.map(&:to_i)
end

times, distances = parsed.values
times, distances = T.must(times), T.must(distances)
winning_races = times.zip(distances).map do |time, distance|
	(1...time).map { |milisec| milisec * (time - milisec) }.filter { _1 > T.must(distance) }
end

puts winning_races.map(&:count).reduce(&:*)
