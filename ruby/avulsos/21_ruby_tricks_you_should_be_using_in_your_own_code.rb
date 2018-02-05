### 1 - Extract regular expression matches quickly
email = "Fred Bloggs <fred@bloggs.com>"
email.match(/<(.*?)>/)[1]   #=> "fred@bloggs.com"
email[/<(.*?)>/, 1]         #=> "fred@bloggs.com"


### 2 - Shortcut for Array#join
[1, 2] * 3  #=> [1, 2, 1, 2, 1, 2]

%w{this is a test} * ", "  #=> "this, is, a, test"

h = { name: "Fred", age: 77 }   #=> {:name=>"Fred", :age=>77}
h.map { |k| k * "=" }           #=> ["name=Fred", "age=77"]
h.map { |i| i * "=" } * "&"     #=> "name=Fred&age=77"


## 3 - Format decimal amounts quickly
money = 9.5       #=> 9.5
"%.2f" % money    #=> "9.50"


## 4 - Interpolate text quickly
"[%s]" % "same old drag"              #=> "[same old drag]"
"<%s>%s</%s>" %  ["p", "hello", "p"]  #=> "<p>hello</p>"


## 5 - Delete trees of files
require 'fileutils'
FileUtils.rm_r 'somedir'


## 6 - Exploding enumerables
a = %w{a b}
b = %w{c d}
[a + b]       # => [["a", "b", "c", "d"]]
[*a + b]      # => ["a", "b", "c", "d"]

a = { name: "Fred", age: 93 }
[a]           # => [{:name => "Fred", :age =>93}]
[*a]          # => [[:name, "Fred"], [:age, 93]]

a = %w{a b c d e f g h}
b = [0, 5, 6]
a.values_at(*b)   # => ["a", "f", "g"]


## 7 - Cut down on local variable definitions ~ 2009 update: don't use this

## 8 - Using non-strings or symbols as hash keys
does = is = { true => 'Yes', false => 'No' }
does[10 == 50]    # => "No"
is[10 > 5]        # => "Yes"


## 9 - Use 'and' and 'or' to group operations for single liners
queue = []
%w{hello x world}.each do |word|
  queue << word and puts "Added to queue" unless word.length <  2
end
# Added to queue
# Added to queue
#=> ["hello", "x", "world"]
puts queue.inspect
# ["hello", "world"]
#=> nil


## 10 - Do something only if the code is being implicitly run, not required
if __FILE__ == $0
  # Do something.. run tests, call a method, etc. We're direct.
end


## 11 - Quick mass assignments
a, b, c, d = 1, 2, 3, 4


## 12 - Use ranges instead of complex comparisons for numbers
year = 1972
puts  case year
        when 1970..1979; "Seventies"
        when 1980..1989; "Eighties"
        when 1990..1999; "Nineties"
      end
# Seventies
#=> nil


## 13 - Use enumerations to cut down repetitive code
%w{rubygems daemons eventmachine}.each { |x| require x } # requiring multiple files

def initialize(args)
  args.keys.each { |name| instance_variable_set "@" + name.to_s, args[name] }
end


## 14 - The Ternary Operator
x = 1
puts x == 10 ? "x is ten" : "x is not ten"
# Or.. an assignment based on the results of a ternary operation:
LOG.sev_threshold = ENVIRONMENT == :development ? Logger::DEBUG : Logger::INFO


## 15 - Nested Ternary Operators
qty = 1
qty == 0 ? 'none' : qty == 1 ? 'one' : 'many'
# Just to illustrate, in case of confusion:
(qty == 0 ? 'none' : (qty == 1 ? 'one' : 'many'))


## 16 - Fight redundancy with Ruby's "logic" features
def is_odd(x)
  # Use the logical results provided to you by Ruby already..
  x % 2 != 0
end

class String
  def contains_digits?
    # mas quando pode retornar indesejado...
    self[/\d/] ? true : false
  end
end


## 17 - See the whole of an exception's backtrace
def do_division_by_zero; 5 / 0; end
begin
  do_division_by_zero
rescue => exception
  puts exception.backtrace
end


## 18 - Allow both single items AND arrays to be enumerated against
# [*items] converts a single object into an array with that single object
# of converts an array back into, well, an array again
[*items].each do |item|
  # ...
end


## 19 - Rescue blocks don't need to be tied to a 'begin'
def x
  # ...
rescue
  # ...
end


## 20 - Block comments
puts "x"
=begin
  this is a block comment
  You can put anything you like here!

  puts "y"
=end
puts "z"


## 21 - Rescue to the rescue
h = { :age => 10 }
h[:name].downcase                    # ERROR
h[:name].downcase rescue "No name"   # => "No name"
