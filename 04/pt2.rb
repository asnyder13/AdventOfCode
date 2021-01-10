$lines = File.readlines('./input.txt')

class Passport

	def initialize
		@byr = { value: nil, regex:/byr:(\d{4})\s/, valid?: lambda{ |x|
                                                !x.nil? && x.to_i >= 1920 && x.to_i <= 2002
                                              } }
		@iyr = { value: nil, regex:/iyr:(\d{4})\s/, valid?: lambda{ |x|
                                                !x.nil? && x.to_i >= 2010 && x.to_i <= 2020
                                              } }
		@eyr = { value: nil, regex:/eyr:(\d{4})\s/, valid?: lambda{ |x|
                                                !x.nil? && x.to_i >= 2020 && x.to_i <= 2030
                                              } }
		@hgt = { value: nil, regex:/hgt:(\d+(?:in|cm))\s/, valid?: lambda{ |x|
																								return false if x.nil?
																								num = x[...-2].to_i
																								if x.end_with?('cm')
																									return num >= 150 && num <= 193
																								else
																									return num >= 59 && num <= 76
																								end
                                              } }
		@hcl = { value: nil, regex:/hcl:(#[0-9a-f]{6})\s/, valid?: lambda{ |x| !x.nil? } }
		@ecl = { value: nil, regex:/ecl:(amb|blu|brn|gry|grn|hzl|oth)\s/, valid?: lambda{ |x| !x.nil? } }
		@pid = { value: nil, regex:/pid:(\d{9})\s/, valid?: lambda{ |x| !x.nil? } }
	end

	def add_fields(line)
		if line =~ @byr[:regex] then
			@byr[:value] = $1
		end
		if line =~ @iyr[:regex] then
			@iyr[:value] = $1
		end
		if line =~ @eyr[:regex] then
			@eyr[:value] = $1
		end
		if line =~ @hgt[:regex] then
			@hgt[:value] = $1
		end
		if line =~ @hcl[:regex] then
			@hcl[:value] = $1
		end
		if line =~ @ecl[:regex] then
			@ecl[:value] = $1
		end
		if line =~ @pid[:regex] then
			@pid[:value] = $1
		end
	end

	def is_valid?
		@byr[:valid?].call(@byr[:value]) &&
		@iyr[:valid?].call(@iyr[:value]) &&
		@eyr[:valid?].call(@eyr[:value]) &&
		@hgt[:valid?].call(@hgt[:value]) &&
		@hcl[:valid?].call(@hcl[:value]) &&
		@ecl[:valid?].call(@ecl[:value]) &&
		@pid[:valid?].call(@pid[:value])
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

		passports.last.add_fields(l)

	end
	passports.pop

	passports
end

p parse_passports($lines).select{ |p| p.is_valid? }.length

