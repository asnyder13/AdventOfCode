# frozen_string_literal: true
# typed: strict

require 'sorbet-runtime'

# String extensions
class String
	extend T::Sig

	sig { returns(T::Boolean) }
	def numeric?
		!Float(self).nil?
	rescue StandardError
		false
	end
end

# Vector extensions
class Vector
	extend T::Sig

	sig { params(others: Vector).returns(Vector) }
	def pairwise_max(*others)
		others.reduce(self) do |acc, other_vec|
			acc.map2(other_vec) { |e1, e2| [e1, e2].max }
		end
	end

	sig { params(others: Vector).returns(Vector) }
	def pairwise_min(*others)
		others.reduce(self) do |acc, other_vec|
			acc.map2(other_vec) { |e1, e2| [e1, e2].min }
		end
	end
end

# Range extensions
class Range
	extend T::Sig

	# Compute the range over which this range and the specified other range
	# overlap. Returns nil if no such overlap exists.
	# https://git.sr.ht/~awsmith/advent-of-code/tree/2023-ruby/item/lib/util/range.rb
	sig { params(other: T::Range[T.untyped]).returns(T.nilable(T::Range[Elem])) }
	def intersection(other)
		last_element = T.let(
			 ->(range) { range.exclude_end? ? range.max : range.last },
			 T.proc.params(range: T::Range[T.untyped]).returns(Numeric)
	 )
		self_max = last_element.call(self)
		other_max = last_element.call(other)
		return nil if other.first > self_max || first > other_max

		[first, other.first].max..[self_max, other_max].min
	end

	alias & intersection
end
