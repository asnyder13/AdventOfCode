#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'

extend T::Sig
# T::Configuration.default_checked_level = :tests

input_file = ARGV.first || 'testinput.txt'
file = File.open(input_file, 'r')

lines = T.let(T.unsafe(file).readlines(chomp: true), T::Array[String])
row_length = lines.first&.length
raise "Couldn't read line length"  if row_length.nil?

CardSet = T.type_alias { T::Set[Numeric] }
# Scratchcard
class Card < T::Struct
	extend T::Sig

	prop :winning, CardSet
	prop :have, CardSet
	prop :count, Numeric

	sig { returns(T::Set[Numeric]) }
	def intersection
		@intersection ||= have & winning
	end

	sig { returns(Integer) }
	def winning_count = intersection.length

	sig { returns(Numeric) }
	def score
		return 0 if winning_count.zero?

		2**(winning_count - 1)
	end
end

card_counts = T.let([], T::Array[Card])
lines.each do |line|
	numbers = line.split ':'
	winning, have = numbers.last.split '|'
	winning = winning.split.to_set(&:to_i)
	have = have.split.to_set(&:to_i)
	card_counts << Card.new(winning:, have:, count: 1)
end

card_counts.each_with_index do |card, idx|
	winning_count = card.winning_count
	current_card_count = card.count
	(idx + 1..idx + winning_count).each do |i|
		card_counts[i]&.count += current_card_count
	end
end

p card_counts.map(&:count).sum
