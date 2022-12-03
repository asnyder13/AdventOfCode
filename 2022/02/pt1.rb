#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'

lines = T.let([], T::Array[String])
input_file = ARGV.first || 'testinput.txt'
file = File.open(input_file, 'r')

lines = file.readlines(chomp: true)

SCORE_WIN  = 6
SCORE_DRAW = 3
SCORE_SHAPE = {
	'X' => 1,
	'Y' => 2,
	'Z' => 3
}.freeze
WINNING_HAND = {
 'Y' => 'A',
 'Z' => 'B',
 'X' => 'C'
}.freeze
DRAW_HAND = {
	'X' => 'A',
	'Y' => 'B',
	'Z' => 'C'
}.freeze

score = 0
lines.map(&:split).each do |opponent_hand, my_hand|
	score += SCORE_SHAPE[my_hand]

	score += SCORE_WIN  if WINNING_HAND[my_hand] == opponent_hand
	score += SCORE_DRAW if DRAW_HAND[my_hand] == opponent_hand
end

puts score
