$lines = File.readlines('./input.txt')

class Passport
	# (Birth Year)
	attr_accessor :byr
	# (Issue Year)
	attr_accessor :iyr
	# (Expiration Year)
	attr_accessor :eyr
	# (Height)
	attr_accessor :hgt
	# (Hair Color)
	attr_accessor :hcl
	# (Eye Color)
	attr_accessor :ecl
	# (Passport ID)
	attr_accessor :pid
	# (Country ID)
	attr_accessor :cid

	def is_valid?
		!byr.nil? &&
		!iyr.nil? &&
		!eyr.nil? &&
		!hgt.nil? &&
		!hcl.nil? &&
		!ecl.nil? &&
		!pid.nil?
	end
end

def parse_passports(lines)
	passports = []

	passports.push(Passport.new)
	lines.each do |l|
		if l == "\n"
			passports.push(Passport.new)
			next
		end

		if l =~ /byr:(.+?)\s/ then
			passports.last.byr = $1
		end
		if l =~ /iyr:(.+?)\s/ then
			passports.last.iyr = $1
		end
		if l =~ /eyr:(.+?)\s/ then
			passports.last.eyr = $1
		end
		if l =~ /hgt:(.+?)\s/ then
			passports.last.hgt = $1
		end
		if l =~ /hcl:(.+?)\s/ then
			passports.last.hcl = $1
		end
		if l =~ /ecl:(.+?)\s/ then
			passports.last.ecl = $1
		end
		if l =~ /pid:(.+?)\s/ then
			passports.last.pid = $1
		end
		if l =~ /cid:(.+?)\s/ then
			passports.last.cid = $1
		end
	end
	passports.pop

	passports
end

p parse_passports($lines).select { |p| p.is_valid? }.length

