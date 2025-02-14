# vim: noexpandtab
# frozen_string_literal: true
# typed: true

require 'etc'
require 'parallel'
require 'sorbet-runtime'

# Easy thread pool
# Just keeping a copy in this repo so I have it for IO bound projects,
# Ruby is GIL'd so it's not helpful for computation usually.
class ThreadPool
	extend T::Sig

	attr_reader :mutex

	sig { params(thread_count: Integer).void }
	def initialize(thread_count = Etc.nprocessors)
		@queue = Queue.new
		@swimmers = thread_count.times.map do
			Thread.new do
				until @queue.empty? && @queue.closed?
					block = @queue.deq
					block&.call
				end
			end
		end
	end

	# Cleanup.	Existing queue entries will finish.
	def close
		@queue.close
		@swimmers.map(&:join)
	end

	# Block of work to be executed on queue.
	def work(&block) = @queue << block
end

# For brute forcing bad algorithms.
class ForkPool
	extend T::Sig

	def initialize
		@reader, @writer = IO.pipe
	end

	def close
		Process.waitall
		@writer.close
		res = @reader.read
		@reader.close
		res
	end

	sig {
		params(enum: T::Enumerable[T.untyped], processor_count: Integer, block: T.untyped).returns(NilClass)
	}
	def work(enum, processor_count = Etc.nprocessors, &block)
		# puts processor_count
		enum.each_slice(enum.count / processor_count) do |slice|
			# ap slice
			fork do
				@reader.close
			# 	# @writer.puts block.call(@reader, @writer)
				slice.each { @writer.puts block.call(it) }
			# 	@writer.puts block.call
				@writer.close
			end
		end
		# fork do
		# 	@reader.close
		# 	# @writer.puts block.call(@reader, @writer)
		# 	@writer.puts block.call
		# 	@writer.close
		# end
	end
end

class ForkPoolUnlimited
	def initialize
		@reader, @writer = IO.pipe
	end

	def close
		Process.waitall
		@writer.close
		res = @reader.read
		@reader.close
		res
	end

	def work(&block)
		fork do
			@reader.close
			# @writer.puts block.call(@reader, @writer)
			@writer.puts block.call
			@writer.close
		end
	end
end
