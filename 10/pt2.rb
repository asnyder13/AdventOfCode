#!/usr/bin/env ruby
# frozen_string_literal: true

adapters = File.readlines('./input.txt').map(&:to_i).sort
# I admit defeat https://old.reddit.com/r/adventofcode/comments/ka8z8x/2020_day_10_solutions/
counter = [nil, nil, nil, 1]
adapters.each {|x| counter[x + 3] = counter[x..x + 2].compact.sum }
puts counter.last
