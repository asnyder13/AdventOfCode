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
	'A' => 1,
	'B' => 2,
	'C' => 3
}.freeze
RESULT = {
 'X' => :lose,
 'Y' => :draw,
 'Z' => :win
}.freeze
WIN_HAND = {
 'A' => 'B',
 'B' => 'C',
 'C' => 'A'
}.freeze
LOSE_HAND = {
 'A' => 'C',
 'B' => 'A',
 'C' => 'B'
}.freeze

score = 0
lines.map(&:split).each do |opponent_hand, result_str|
	result = RESULT[result_str]

	score += SCORE_WIN  if result == :win
	score += SCORE_DRAW if result == :draw

	case result
	when :draw
		score += SCORE_SHAPE[opponent_hand]
	when :win
		score += SCORE_SHAPE[WIN_HAND[opponent_hand]]
	when :lose
		score += SCORE_SHAPE[LOSE_HAND[opponent_hand]]
	end
end

puts score
