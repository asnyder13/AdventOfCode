#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'time'
require 'sorbet-runtime'
extend T::Sig
T::Configuration.default_checked_level = :tests

require_relative '../../lib/file_parsers'

require_relative '../../lib/thread_pool'

# input mapping
class PlantMap < T::Struct
	extend T::Sig

	prop :dest, Numeric
	prop :src, Numeric
	prop :len, Integer
end

labels = ['seeds:',
		        'seed-to-soil map:',
		        'soil-to-fertilizer map:',
		        'fertilizer-to-water map:',
		        'water-to-light map:',
		        'light-to-temperature map:',
		        'temperature-to-humidity map:',
		        'humidity-to-location map:',]
groups = T.let(labels.to_h { [_1, []] }, T::Hash[T.any(Symbol, String), T::Array[PlantMap]])
seed_pairs = T.let([], T::Array[[Numeric, Numeric]])

FileParsers.labeled_groups(labels,
                           alignment: FileParsers::GroupAlignment::Both).each_with_index do |(label, lines), idx|
	if idx.zero?
		pairs = T.must(lines.first).split
		raise "Wrong number of seed pairs? len: #{pairs.length}" unless pairs.length.even?

		seed_pairs = pairs.each_slice(2).map do |pair|
			[pair.first.to_i, pair.last.to_i]
		end
	else
		lines.each do |line|
			dest, src, len = line.split.map(&:to_i)
			groups[label] << PlantMap.new(dest:, src:, len:)
		end
	end
end

class Link < T::Struct
	prop :src, T::Range[Numeric]
	prop :dest, T::Range[Numeric]
end
maps = T.let(
		labels.drop(1).to_h { [_1, []] },
		T::Hash[T.any(Symbol, String), T::Array[Link]]
)
groups.each do |k, pmaps|
	pmaps.sort_by(&:src).each do |pmap|
		link = Link.new(src: (pmap.src..pmap.src + pmap.len), dest: (pmap.dest..pmap.dest + pmap.len))
		T.must(maps[k]) << link
	end
end
maps.each { |k, v| maps[k] = v.reverse }

loc = T.let(0, Numeric)
reader, writer = IO.pipe
seed_pairs.each do |start, len|
	# Bad brute force, longest query took 1hr 15min
	fork do
		reader.close

		x = (start..start + len).map do |seed|
			loc = seed
			labels.drop(1).map { T.must(maps[_1]) }.each do |links|
				mapping = links.find { |link| link.src.cover? loc }
				if mapping
					diff = mapping.dest.begin - mapping.src.begin
					loc += diff
				end
			end

			loc
		end

		writer.puts x.min.to_s
		writer.close
	end
end

Process.waitall
writer.close
from_children = reader.read
reader.close

all_results = from_children.split.map(&:to_i)
puts all_results.min
