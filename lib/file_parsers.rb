# frozen_string_literal: true
# typed: strict

require 'sorbet-runtime'
require_relative 'sorbet_types'

# File parsing utilities for AoC
module FileParsers
	extend T::Sig
	# Alignment enum for labeled_groups
	class GroupAlignment < T::Enum
		enums do
			Sameline = new
			Multiline = new
			Both = new
		end
	end

	class << self
		extend T::Sig

		@lines_from_file = T.let(nil, T.nilable(StringsFromFile))
		sig { returns(StringsFromFile) }
		def lines_from_file
			if @lines_from_file.nil?
				filename = ARGV.first || 'testinput.txt'
				file = File.open(filename, 'r')
				@lines_from_file = T.let(T.unsafe(file).readlines(chomp: true), T.nilable(StringsFromFile))
			end
			T.must(@lines_from_file)
		end

		sig { params(block: T.nilable(T.proc.params(arg0: String).returns(BasicObject))).returns(T::Enumerable[String]) }
		def lines(&block)
			lines_from_file.each(&block)
		end

		sig {
			params(
				 labels: T::Enumerable[SymOrString],
				 alignment: GroupAlignment
		 ).returns(T::Hash[SymOrString, StringArray])
		}
		def labeled_groups(labels, alignment:)
			groups = T.let(labels.to_h { [_1, []] }, T::Hash[SymOrString, StringArray])

			current_section = T.let(nil, T.nilable(SymOrString))
			lines.map(&:strip).each do |line|
				new_label, rest_of_line = check_for_label line, labels
				current_section = new_label unless new_label.nil?

				if current_section
					section_values = T.must(groups[current_section])
					case alignment
					when GroupAlignment::Sameline
						section_values << T.must(rest_of_line) if new_label
					when GroupAlignment::Multiline
						section_values << line unless line.empty?
					when GroupAlignment::Both
						if new_label
							section_values << T.must(rest_of_line)
						elsif !line.empty?
							section_values << line
						end
					end
				end
			end

			groups.transform_values! { _1.reject(&:empty?) }
		end

		sig { returns(StringArrayArray) }
		def whitespace_separated
			lines.map(&:chomp).reject(&:empty?).map(&:split)
		end

		sig { returns(T::Array[T::Array[Integer]]) }
		def whitespace_separated_ints
			whitespace_separated.map { _1.map(&:to_i) }
		end

		sig { params(regexes: Regexp).returns(T::Hash[Regexp, StringArrayArray]) }
		def regexes(*regexes)
			matches = T.let({}, T::Hash[Regexp, StringArrayArray])
			lines.each do |line|
				regexes.each do |regex|
					m = line.match regex
					unless m.nil?
						matches[regex] ||= []
						T.must(matches[regex]) << m.captures
					end
				end
			end

			matches
		end

		ScanResults = T.type_alias { T::Array[T::Array[T.any(T::Array[String], String)]] }
		sig { params(regexes: Regexp).returns(T::Hash[Regexp, ScanResults]) }
		def regexes_scan(*regexes)
			matches = T.let({}, T::Hash[Regexp, ScanResults])
			lines.each do |line|
				regexes.each do |regex|
					m = line.scan regex
					matches[regex] ||= []
					T.must(matches[regex]) << m
				end
			end

			matches
		end

			private

		sig { params(line: String, labels: T::Enumerable[SymOrString]).returns(T.nilable([SymOrString, String])) }
		def check_for_label(line, labels)
			found_label = labels.find { line.include? _1.to_s }

			return unless found_label

			splits = line.split found_label.to_s

			return found_label, splits.last&.strip || ''
		end
	end
end
