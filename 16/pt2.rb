#!/usr/bin/env ruby
# frozen_string_literal: true

abort('Please provide input file') if ARGV.count.zero?
lines = ARGF.readlines

section = :ranges
myticket = nil
nearby = []

Field = Struct.new(:field, :ranges)
fields = []

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
		fields << Field.new($1, [(r1a..r1b), (r2a..r2b)])
	when :myticket
		myticket = line.split(',').map(&:to_i)
	when :nearby
		nearby << line.split(',').map(&:to_i)
	end
end

invalid = nearby.map do |tickets|
	tickets.filter do |ticket|
		fields.map(&:ranges).flatten.none? { |range| range.cover?(ticket) }
	end
end.flatten

valid = nearby.filter { |x| x.intersection(invalid).length.zero? }

matches = Hash.new { _1[_2] = [] }
transposed = valid.transpose
fields.each do |f|
	transposed.each.with_index do |values, i|
		found = values.all? do |v|
			f.ranges.any? do |range|
				range.cover?(v)
			end
		end

		matches[f.field] << i if found
	end
end
sorted_matches = matches.sort { |(_, v1), (_, v2)| v1.length <=> v2.length }
# [
# 	['field1', [12]],
# 	['field2', [12, 13]]
# ]


found_indexes = []
orders = {} # {class: 1, row: 0, seat: 2}
matches.length.times do
	(field, field_indecies) = sorted_matches.shift

	field_indecies = field_indecies.delete_if { |idx| found_indexes.include?(idx) }
	field_idx = field_indecies.first

	found_indexes << field_idx
	orders[field_idx] = field
end

myfields = orders.transform_keys { |idx| myticket[idx] }.to_h

puts myfields.filter { |_, field| field.start_with?('departure') }
             .keys
             .reduce(:*)
             .to_s
