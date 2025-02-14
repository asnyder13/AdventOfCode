#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'bundler'
Bundler.require
require 'debug'

require 'sorbet-runtime'
extend T::Sig
# T::Configuration.default_checked_level = :tests

require_relative '../../lib/file_parsers'

# Camel cards hand
class Hand
	extend T::Sig
	include Comparable

	RANKS = %w[J 2 3 4 5 6 7 8 9 T Q K A].freeze
	RANK_SCORES = T.let(RANKS.each_with_index.to_h, T::Hash[String, Integer])
	HANDS = %i[high pair tpair three house four five].freeze
	HAND_RANKS = HANDS.each_with_index.to_h
	J = 'J'

	sig { returns(T::Array[String]) }
	attr_reader :cards

	sig { returns(T::Array[String]) }
	attr_reader :og_cards

	sig { returns(Integer) }
	attr_reader :bet

	sig { params(cards: T.any(String, T::Array[String]), bet: Integer, og_cards: T.nilable(T::Array[String])).void }
	def initialize(cards, bet, og_cards = nil)
		@cards = (cards.is_a?(Array) && cards) || cards.chars
		@og_cards = og_cards || @cards.dup
		@bet = bet
		@perms = T.let([], T::Array[T::Hash[String, Integer]])
	end

	sig { params(other: Hand).returns(Integer) }
	def <=>(other)
		rank_other = other.rank

		return HAND_RANKS[rank] <=> HAND_RANKS[rank_other] if rank != rank_other

		og_cards
		  .zip(other.og_cards)
		  .map { |a, b| [RANK_SCORES[a], RANK_SCORES[T.must(b)]] }
		  .map { _1 <=> T.must(_2) }
		  .filter { _1 != 0 }
		  .first || 0
	end

	sig { returns(T::Array[Hand]) }
	def permute_js
		non_js = cards.reject { _1 == J }

		@tallys = cards.tally
		j_count = @tallys[J] || 0
		result = T.let([self], T::Array[Hand])

		unless j_count.zero?
			perms = non_js.uniq.repeated_permutation(j_count)
			j_indexes = cards.each_index.select { cards[_1] == J }

			perms.each do |perm|
				aperm = cards.dup
				j_indexes.each_with_index do |jidx, idx|
					aperm[jidx] = T.must(perm[idx])
				end

				result << Hand.new(aperm, bet, og_cards)
			end
		end

		result
	end

	sig { returns(T::Hash[String, Integer]) }
	def tallys
		@tallys ||= cards.tally
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
		@tpair = tallys.values.count { _1 == 2 } >= 2 if @tpair.nil?
		@tpair
	end

	sig { returns(T::Boolean) }
	def pair?
		@pair = tallys.values.any? { _1 == 2 } if @pair.nil?
		@pair
	end

	sig { returns(T::Boolean) }
	def high?
		!(five? || four? || three? || tpair? || pair?)
	end
end

hands = FileParsers.whitespace_separated.map { |cards, bet| Hand.new(T.must(cards), bet.to_i) }
# ap hands[1].permute_js.sort
# ap hands.map(&:permute_js).map(&:sort).map(&:max).flatten.sort
# puts hands.sort.each_with_index.map { |hand, idx| hand.bet * (idx + 1) }.sum
puts hands.map(&:permute_js).map(&:sort).map(&:max).flatten.sort.each_with_index.map { |hand, idx|
 hand.bet * (idx + 1)
}.sum

# 248974256 too low
# 249262847 too low
# 249381357 just wrong?
# 250243401 just wrong
# 249603241 just wrong (full permutations, messing up order maybe?  Ah it's comparing with the Js replaced, need to
#                       compare on the OG string)
# 249356515
