#!/usr/bin/env ruby
# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'

lines = T.let([], T::Array[String])
input_file = ARGV.first || 'input.txt'
file = File.open(input_file, 'r')

lines = file.readlines(chomp: true)

FILE = Struct.new(:name, :file_size)
DIR = Struct.new(:name, :files, :dirs, :parent) do
	def dir_size
		files.map(&:file_size).sum + dirs.map(&:dir_size).sum
	end

	def path
		if name == '/'
			name
		else
			parent.path + name
		end
	end
end

root = DIR.new('/', [], [], '/')
dirs = { { label: '/', parent: '/' } => root }

def check_existing_dir!(dirs, current_dir, label)
	dir = current_dir.dirs.find { |cdir| cdir.name == label }
	unless dir
		dir = DIR.new(label, [], [], current_dir)
		current_dir.dirs << dir
		dirs[{ label:, parent: current_dir.name }] = dir
	end
	return dir
end

current_dir = T.let(root, T.untyped)
lines.each do |l|
	x = true
	case l
	when %r{^\$ cd (?<dir_label>\w+|\.\.|/)}
		dir_label = Regexp.last_match :dir_label
		case dir_label
		when '/'
			current_dir = root
		when '..'
			current_dir = current_dir.parent
		else
			dir = check_existing_dir! dirs, current_dir, dir_label
			current_dir = dir
		end
	when /^(?<size>\d+) (?<file_name>[\w.]+)/
		size      = Regexp.last_match :size
		file_name = Regexp.last_match :file_name

		# file_already_in_dir = current_dir.files.any? { |f| f.name == file_name }
		file_already_in_dir = false
		current_dir.files << FILE.new(file_name, size.to_i) unless file_already_in_dir

		# if current_dir.name == 'pjmc' && current_dir.parent.name == 'pjmc'
		# 	pp current_dir
		# 	pp current_dir.dir_size
		# end
	end
end

# puts dirs['/'].dir_size

# 827083 too low
# 849287 too low
# 1442494 too low
# puts dirs.filter { |_label, dir| dir.dir_size <= 100_000 }.map { |_label, dir| dir.dir_size }.sum
# pp dirs.filter { |_label, dir| dir.dir_size <= 100_000 }.map { |_label, dir| { dir.name => dir.dir_size } }
# pp dirs.map { |_label, dir| { dir.name => dir.dir_size } }
temp = {}
dirs.each_value do |dir|
	temp[dir.path] = dir.dir_size
end
pp (temp.sort_by { |dir, _size| dir })

# pp root
# pp dirs.values.map { _1.dir_size }.filter { |size| size <= 100_000 }.sum
# puts
# dirs.values.each { |dir| dir.parent = nil }

# pp dirs.values.filter { |dir| dir.dir_size <= 100_000 }
# puts
# puts
# puts
# puts
# pp dirs.values
# pp dirs.values.map(&:dir_size).filter { |size| size <= 100_000 }
# pp dirs.values.map(&:dir_size).filter { |size| size <= 100_000 }.sum
# pp dirs.values.map(&:dir_size).sum

# puts
# puts

# dirs.values.map do |dir|
# 	if dir.name == 'pjmc' && dir.parent.name == 'pjmc'
# 		pp dir
# 		pp dir.dir_size
# 	end

# 	dir.dir_size
# end

# pp dirs.values




# puts
# puts
# puts
# pp dirs.values.map { _1.dir_size }
# pp dirs.values.map { _1.dir_size }.sum
# puts



# pp dirs
# dir = dirs[dir_label] || DIR.new(dir_label, [], [], current_dir)
# unless dirs[dir_label]
# 	dirs[dir_label] = dir
# 	current_dir.dirs << dir
# end

# existing_dir = current_dir.dirs.find { |dir| dir.name == dir_label }
# unless dirs[dir_label]
# 	dir = dirs[dir_label] || DIR.new(dir_label, [], [], current_dir)
# 	dirs[dir_label] = dir
# 	current_dir.dirs << dir
# end
# dirs = { '/' => DIR.new('/', [], [], '/') }
# DIR = Struct.new(:name, :files, :dirs, :parent_label) do
# 	def dir_size
# 		files.map(&:file_size).sum + dirs.map(&:dir_size).sum
# 	end
# end
