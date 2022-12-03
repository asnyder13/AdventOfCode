# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'

# BiHash
class BiHash
	extend T::Sig
	extend T::Generic

	Elem = type_member

	def initialize
		@forward = {}
		@reverse = {}
	end

	T::Sig::WithoutRuntime.sig { params(key: T.any(Integer, String, Symbol, Elem)).returns(T.any(Integer, Elem, NilClass)) }
	def [](key)
		@forward[key] || @reverse[key]
	end

	T::Sig::WithoutRuntime.sig { params(key: T.any(Integer, String, Symbol, Elem), value: T.any(Integer, String, Symbol, Elem)).returns(NilClass) }
	def insert(key, value)
		@reverse[value] = nil if @forward.key? key
		if @reverse.key? key
			@reverse[key]   = nil
			@forward[value] = nil
		end

		@forward[key]   = value
		@forward[value] = key
		return
	end

	T::Sig::WithoutRuntime.sig { params(key: T.any(Integer, String, Symbol, Elem), value: T.any(Integer, String, Elem)).returns(NilClass) }
	def []=(key, value)
		insert key, value
		return
	end

	T::Sig::WithoutRuntime.sig { params(key: T.any(Integer, String, Symbol, Elem)).returns(NilClass) }
	def delete(key)
		if @forward.key?(key)
			x = @forward[key]
			@forward[key] = nil
			@reverse[x] = nil
		elsif @reverse.key?(key)
			x = @reverse[key]
			@reverse[key] = nil
			@forward[x] = nil
		end
	end
end
