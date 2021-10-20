#!/usr/bin/env ruby
# frozen_string_literal: true

abort('Please provide input file') if ARGV.count.zero?
lines = ARGF.readlines

section = :ranges
ranges = Hash.new { _1[_2] = [] }
myticket = nil
nearby = []

lines.each do |line|
	next if line =~ /^$/

	if line.start_with?('your ticket')
		section = :myticket
		next
	elsif line.start_with?('nearby ticket')
		section = :nearby
		next
	end

	case section
	when :ranges
		line =~ /(.+): (\d+)-(\d+) or (\d+)-(\d+)/
		(r1a, r1b, r2a, r2b) = [$2, $3, $4, $5].map(&:to_i)
		ranges[$1] = [(r1a..r1b), (r2a..r2b)]
	when :myticket
		myticket = line.split(',').map(&:to_i)
	when :nearby
		nearby << line.split(',').map(&:to_i)
	end
end

invalid = nearby.map do |tickets|
	tickets.filter do |ticket|
		ranges.map(&:last).flatten.none? { |range| range.cover?(ticket) }
	end
end.flatten

puts invalid.reduce(:+)

