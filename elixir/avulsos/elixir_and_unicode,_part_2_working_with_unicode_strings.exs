noel = "noe\u0308l" # => "noël"
String.codepoints(noel) # => ["n", "o", "e", "̈", "l"]
String.graphemes(noel)  # => ["n", "o", "ë", "l"]

## quantidade de graphemes (como a string aparenta)
## O(n)
String.length(noel) # => 4

## quantidade de bytes que ocupa
## O(1)
IO.puts byte_size(noel) # => 6


{two_codepoints, one_codepoint} = {"e\u0308", "\u00EB"} # => {"ë", "ë"}
two_codepoints == one_codepoint # => false
## normaliza as strings antes de compará-las
String.equivalent?(two_codepoints, one_codepoint) # => true


String.downcase("MAÑANA") == "mañana" # => true

## valor hexadecimal do codepoint
"🂡" == "\u{1F0A1}" # => true
## valor decimal do codepoint
"🂡" == <<127_137::utf8>> # => true
