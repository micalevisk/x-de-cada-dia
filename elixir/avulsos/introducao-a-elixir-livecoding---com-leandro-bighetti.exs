## $ elixir <nome_do_arquivo_script>.exs

###################
IO.puts "Olá, Mundo!"


###################
## 'set' geralmente tem de 2 a 3 elementos
a = {1, 2, 3}

## controle de fluxo
case a do
  {1, 2, c} ->
    IO.puts 'primeiro caso: #{c}'

  {1, b, c} ->
    IO.puts 'segundo caso: #{b} #{c}'

  {4, 5, 6} ->
    IO.puts 'não é isso aí'

  _ ->
    IO.puts 'deu beyblade'
end


###################
IO.puts "\nJogo do adivinha"

palavra = IO.gets "Adivinhe a palavra:\s"
palavra = String.trim(palavra) # rebind

IO.inspect palavra, width: 2, label: "(a palavra)"

if (palavra != "pão") do
  IO.puts "foo"
end

unless true do
  IO.puts "bar"
end

case palavra do
  # "joão" ->
  <<106, 111, 0, 111>> ->
    IO.puts "Você ganhou!!!"
  "trigo" ->
    IO.puts "Quase, é um ingrediente da resposta"
  _ ->
    IO.puts "Não!!"
end


###################
map = %{"a" => 2, 2 => 3, c: 4}
IO.puts map["a"]
IO.puts map[2]

%{c: valor} = map # pattern matching
IO.puts valor


IO.puts %{:a => 2, :b => 3} == %{:a => 2, :b => 3}

# IEx.configure [inspect: [charlists: false]]
