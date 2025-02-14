#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'matrix'
require 'set'
require 'sorbet-runtime'

extend T::Sig

lines = T.let([], T::Array[String])
input_file = ARGV.first || 'testinput2.txt'
file = File.open(input_file, 'r')
lines.concat file.readlines(chomp: true).reject(&:empty?)
arg = T.must(lines.first)

m = arg.match(/.+:\s*x=(-?\d+\.\.\-?d+),\s*y=(-?\d+\.\.-?\d+)/)
