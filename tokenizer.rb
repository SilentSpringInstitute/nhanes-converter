#!/usr/bin/ruby

class Input
  def initialize(source)
    @contents = File.open(source).read
    @position = 0
  end

  def match(str)
    if str.is_a?(Regexp)
      matchData = str.match(@contents[@position..@contents.length])

      if matchData == nil
        false
      else
        matchData[0]
      end
    else
      if @contents[@position...(@position + str.length)] == str
        str
      else
        false
      end
    end
  end

  def advance(num)
    @position += num
  end

  def loop
    while @position < @contents.length
      if @position % 10000 == 0
        puts @position.to_f / @contents.length.to_f
      end

      yield @contents[@position]
    end
  end
end

transitions = {
  :start => {
    "" => :chemical
  },
  :chemical => {
    "\n" => :chemical_description
  },
  
  :chemical_description => {
    "Total" => :total,
    "Age group" => :age_group,
    "Gender" => :gender,
    "Race/ethnicity" => :race
  },

  #
  # Section Headers
  #
  
  :total => {
    " " => :row
  },

  :age_group => {
    " " => :age_row,
    "\n" => :age_row
  },

  :gender => {
    " " => :gender_row,
    "\n" => :gender_row
  },

  :race => {
    " " => :race_row,
    "\n" => :race_row
  },

  #
  # Race
  #

  :race_year => {
    " (" => :race_confidence_interval,
    " " => :race_data
  },

  :race_data => {
    " " => :race_seperator,
    "\n" => :race_row
  },

  :race_seperator => {
    "(" => :race_confidence_interval,
    "< LOD" => :race_LOD,
    /^./ => :race_data
  },

  :race_LOD => {
    " " => :race_data
  },

  :race_row => {
    "Limit of detection" => :start,
    "< LOD means" => :start,
    "Biomonitoring Summary" => :start,
    "*In" => :start,
    "**To" => :start,
    "+Not" => :start,
    "__" => :start,
    /\A[A-Z]/ => :race_type,
    /\A[0-9 -]/ => :race_year,
    "\n" => :race_row
  },

  :race_type => {
    /\A[0-9]/ => :race_year
  },

  :race_confidence_interval => {
    " " => :race_seperator
  },

  #
  # Gender
  #
  :gender_year => {
    " (" => :gender_confidence_interval,
    " " => :gender_data
  },

  :gender_data => {
    " " => :gender_seperator,
    "\n" => :gender_row
  },

  :gender_seperator => {
    "(" => :gender_confidence_interval,
    "< LOD" => :gender_LOD,
    /^./ => :gender_data
  },

  :gender_LOD => {
    " " => :gender_data
  },

  :gender_row => {
    /\AMales/ => :gender_type,
    /\AFemales/ => :gender_type,
    /\A[0-9 -]/ => :gender_year,
    "Race/ethnicity" => :race,
    "Limit of detection" => :start,
    "< LOD means" => :start,
    "Biomonitoring Summary" => :start,
    "*In" => :start,
    "__" => :start,
    "**To" => :start,
    "+Not" => :start,
    "\n" => :gender_row
  },

  :gender_type => {
    " " => :gender_row
  },

  :gender_confidence_interval => {
    " " => :gender_seperator
  },

  #
  # Age
  #
  :age_year => {
    " (" => :age_confidence_interval,
    " " => :age_data
  },

  :age_data => {
    " " => :age_seperator,
    "\n" => :age_row
  },

  :age_seperator => {
    '(' => :age_confidence_interval,
    "< LOD" => :age_LOD,
    /./ => :age_data
  },

  :age_LOD => {
    " " => :age_data
  },

  :age_range => {
    " " => :age_row
  },

  :age_row => {
    /\A[0-9]+-[0-9]+ years/ => :age_range,
    /\A[0-9]+ years and older/ => :age_range,
    /\A[0-9 -]/ => :age_year,
    "Gender" => :gender,
    "Limit of detection" => :start,
    "< LOD means" => :start,
    "*In" => :start,
    "__" => :start,
    "+Not" => :start,
    "Biomonitoring Summary" => :start,
    "**To" => :start,
    "\n" => :age_row
  },

  :age_confidence_interval => {
    " " => :age_seperator
  },

  #
  # Total
  #

  :row => {
    "Age group" => :age_group,
    "Gender" => :gender,
    "Race/ethnicity" => :race,
    "Limit of detection" => :start,
    "< LOD means" => :start,
    "*In" => :start,
    "__" => :start,
    "+Not" => :start,
    "Biomonitoring Summary" => :start,
    "**To" => :start,
    /^[0-9 -]/ => :year,
    "\n" => :row
  },

  :year => {
    " (" => :confidence_interval,
    " " => :data
  },

  :data => {
    " " => :seperator,
    "\n" => :row
  },

  :seperator => {
    "(" => :confidence_interval,
    "< LOD" => :LOD,
    /^./ => :data
  },

  :LOD => {
    " " => :data
  },

  :confidence_interval => {
    " " => :data
  }
}

input = Input.new('data/FourthReport_UpdatedTables_Feb2015.txt')

tokens = []
state = :start
token = [state, '']

input.loop do |character|
  match = false
  transitions[state].each do |str, nextState|
    match = input.match(str)

    if match != false
      tokens.push token

      input.advance(match.length)

      state = nextState

      token = [state, '']
      token[1] += match

      break
    end
  end

  if match == false
    token[1] += character
    input.advance(1)
  end

end

output = File.open('test.csv', 'w')

output.puts '"chemical","type","age_range","gender_type","race_type","year","contents"'

chemical = ""
year = ""
type = ""
age_range = ""
gender_type = ""
race_type = ""

number_types = ['geometric mean', '50th percentile', '75th percentile', '90th percentile', '95th percentile', 'sample size']
number_type = 0

tokens.each do |token|
  #puts token[0].to_s + "\t\t\t" + '"' + token[1] + '"'
  
  if token[0] == :total
    type = "total"
    age_range = ""
    gender_type = ""
    race_type = ""
  end

  if token[0] == :age_group
    type = "age"
  end

  if token[0] == :gender
    type = "gender"
    age_range = ""
  end

  if token[0] == :race
    type = "race"
    gender_type = ""
  end

  if token[0] == :age_range
    age_range = token[1].strip
  end

  if token[0] == :gender_type
    gender_type = token[1].strip
  end

  if token[0] == :race_type
    race_type = token[1].strip
  end

  if token[0] == :chemical
    chemical = token[1].strip 
  end

  if token[0] == :year or token[0] == :age_year or token[0] == :gender_year or token[0] == :race_year
    year = token[1].strip
  end

  if (token[0] == :data or 
     token[0] == :age_data or 
     token[0] == :gender_data or 
     token[0] == :race_data or
     token[0] == :LOD or 
     token[0] == :age_LOD or
     token[0] == :gender_LOD or
     token[0] == :race_LOD) and
     token[1] != ' '


    contents = token[1].strip

    if token[0] == :LOD or token[0] == :age_LOD or token[0] == :gender_LOD
      contents = '< LOD'
    end

    output.puts "\"#{chemical}\",\"#{type}\",\"#{age_range}\",\"#{gender_type}\",\"#{race_type}\",\"#{year}\",\"#{number_types[number_type]}\"\"#{contents}\""
    number_type = (number_type + 1) % number_types.length
  end
end
