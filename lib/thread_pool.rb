# frozen_string_literal: true

require 'etc'

# Easy thread pool
# Just keeping a copy in this repo so I have it for IO bound projects,
# Ruby is GIL'd so it's not helpful for computation usually.
class ThreadPool
	attr_reader :mutex

	def initialize
		@queue = Queue.new
		@mutex = Mutex.new
		@swimmers = Etc.nprocessors.times.map do
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
