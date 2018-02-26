# "bread"

hints = "flour, water, yeast, bakery"
IO.puts "Hints: #{hints}"

guess = IO.gets "Guess the word: "
guess = String.trim(guess)

case guess do
  "bread" ->
    IO.puts "won!"
  _wrong_gues ->
    IO.puts "lost!"
end
