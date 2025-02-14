# frozen_string_literal: true
# typed: true

require 'etc'
require 'sorbet-runtime'

# Easy thread pool
# Just keeping a copy in this repo so I have it for IO bound projects,
# Ruby is GIL'd so it's not helpful for computation usually.
class ThreadPool
	extend T::Sig

	attr_reader :mutex

	sig { params(thread_count: T.nilable(Integer)).void }
	def initialize(thread_count = nil)
		@queue = Queue.new
		@swimmers = (thread_count || Etc.nprocessors).times.map do
			Thread.new do
				until @queue.empty? && @queue.closed?
					block = @queue.deq
					block&.call
				end
			end
		end
	end

	# Cleanup.  Existing queue entries will finish.
	def close
		@queue.close
		@swimmers.map(&:join)
	end

	# Block of work to be executed on queue.
	def work(&block) = @queue << block
end

# For brute forcing bad algorithms.
class ForkPool
	def initialize
		@reader, @writer = IO.pipe
	end

	def close
	end
end
