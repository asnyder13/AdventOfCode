#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'

lines = T.let([], T::Array[String])
input_file = ARGV.first || 'testinput.txt'
file = File.open(input_file, 'r')

# Elf
class Elf
	attr_accessor :calories

	def initialize     = @calories = []
	def total_calories = @calories.sum
end

elfs = [Elf.new]
file.readlines(chomp: true).each do |line|
	if line.empty?
		elfs << Elf.new
		next
	end

	elfs.last.calories << line.to_i
end

puts elfs.map(&:total_calories).max
