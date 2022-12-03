# frozen_string_literal: true
# typed: true

require 'set'

# PriorityQueue
class MinPriorityQueue
	attr_reader :elements

	def initialize
		@priorities = [nil]
		@elements   = [nil]
		@set        = Set.new
		@element_indecies = {}
	end

	def push(priority, element)
		@priorities << priority
		@elements   << element
		@set        << element

		idx = @elements.size - 1
		@element_indecies[element] = idx

		bubble_up @elements.size - 1
	end
	alias << push

	def pop
		swap 1, @elements.size - 1
		min = @elements.pop

		@element_indecies[min] = nil
		@priorities.pop
		@set.delete min

		bubble_down 1

		min
	end

	def decrease_priority(priority, element)
		idx = @element_indecies[element]
		@priorities[idx] = priority
		bubble_up idx
	end

	def include?(elem) = @set.include? elem
	def length = @set.length

		private

	def swap(idxa, idxb)
		@priorities[idxa], @priorities[idxb] = @priorities[idxb], @priorities[idxa]
		@elements[idxa],   @elements[idxb]   = @elements[idxb],   @elements[idxa]

		elementa, elementb = @elements[idxa], @elements[idxb]
		@element_indecies[elementa] = idxa
		@element_indecies[elementb] = idxb
	end

	def bubble_up(idx)
		return idx if idx <= 1

		parent_idx = idx / 2
		return idx if @priorities[parent_idx] <= @priorities[idx]

		swap idx, parent_idx
		bubble_up parent_idx
	end

	def bubble_down(idx)
		child_idx = idx * 2

		return idx if child_idx > @elements.size - 1

		not_last_elem = child_idx < @priorities.size - 1
		left_elem     = @priorities[child_idx]
		right_elem    = @priorities[child_idx + 1]
		child_idx += 1 if not_last_elem && right_elem < left_elem

		return idx if @priorities[idx] <= @priorities[child_idx]

		swap idx, child_idx
		bubble_down child_idx
	end
end
