#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'bundler'
Bundler.require

require 'sorbet-runtime'
extend T::Sig
T::Configuration.default_checked_level = :tests

require_relative '../../lib/file_parsers'

# Camel cards hand
class Hand
	extend T::Sig
	include Comparable

	RANKS = %w[2 3 4 5 6 7 8 9 T J Q K A].freeze
	RANK_SCORES = T.let(RANKS.each_with_index.to_h, T::Hash[String, Integer])
	HANDS = %i[high pair tpair three house four five].freeze
	HAND_RANKS = HANDS.each_with_index.to_h

	sig { returns(String) }
	attr_reader :cards

	sig { returns(Integer) }
	attr_reader :bet

	sig { params(cards: String, bet: Integer).void }
	def initialize(cards, bet)
		@cards = cards
		@bet = bet
	end

	sig { params(other: Hand).returns(Integer) }
	def <=>(other)
		rank_other = other.rank

		return HAND_RANKS[rank] <=> HAND_RANKS[rank_other] if rank != rank_other

		cards
		  .chars
		  .zip(other.cards.chars)
		  .map { |a, b| [RANK_SCORES[a], RANK_SCORES[T.must(b)]] }
		  .map { _1 <=> T.must(_2) }
		  .filter { _1 != 0 }
		  .first || 0
	end

	sig { returns(T::Hash[String, Integer]) }
	def tallys
		@tallys ||= cards.chars.tally
	end

	sig { returns(Symbol) }
	def rank
		case
		when five?  then :five
		when four?  then :four
		when house? then :house
		when three? then :three
		when tpair? then :tpair
		when pair?  then :pair
		else :high
		end
	end

	sig { returns(T::Boolean) }
	def five?
		@five = tallys.values.any? { _1 == 5 } if @five.nil?
		@five
	end

	sig { returns(T::Boolean) }
	def four?
		@four = tallys.values.any? { _1 == 4 } if @four.nil?
		@four
	end

	sig { returns(T::Boolean) }
	def house?
		@house = three? && pair? if @house.nil?
		@house
	end

	sig { returns(T::Boolean) }
	def three?
		@three = tallys.values.any? { _1 == 3 } if @three.nil?
		@three
	end

	sig { returns(T::Boolean) }
	def tpair?
		@tpair = tallys.values.count { _1 == 2 } == 2 if @tpair.nil?
		@tpair
	end

	sig { returns(T::Boolean) }
	def pair?
		@pair = tallys.values.one? { _1 == 2 } if @pair.nil?
		@pair
	end

	sig { returns(T::Boolean) }
	def high?
		!(five? || four? || three? || tpair? || pair?)
	end

	def to_s
		cards
	end
end

hands = FileParsers.whitespace_separated.map { |cards, bet| Hand.new(T.must(cards), bet.to_i) }
puts hands.sort.each_with_index.map { |hand, idx| hand.bet * (idx + 1) }.sum

# 246703682 too low
# 246795406
