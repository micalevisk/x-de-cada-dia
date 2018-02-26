defmodule Alch do
  def read_my_file(filename) do ## named function
    File.read(filename)
  end

  def mapping(%{"keys" => value}) do
    IO.puts value
  end
end
# iex(1)> c("alch.ex") ## [Alch] ~ para compilar o módulo

