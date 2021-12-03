#!/usr/bin/env ruby
# frozen_string_literal: true

abort('Please provide input file') if ARGV.count.zero?
lines = []
lines.concat ARGF.readlines(chomp: true).reject(&:empty?)

lines.map!(&:to_i)

increase = 0
lines.each_cons(2) { |a, b| increase += 1 if (b - a).positive? }
puts increase
