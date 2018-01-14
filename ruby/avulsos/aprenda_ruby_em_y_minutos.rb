# (c) https://learnxinyminutes.com/docs/pt-br/ruby-pt

=begin
comentário
de
várias
linhas
=end

## TUDO É UM OBJETO; métodos acessados por '.' ##

# ----- número são objetos ----- #
3.class #=> Fixnum
3.to_s #=> "3"

# ----- aritmética básica ----- #
1 + 1 #=> 2
8 - 1 #=> 7
10 * 2 #=> 20
35/5 #=> 7

# ----- artimética é apenas um syntax sugar pra chamadas de métodos ----- #
1.+(3) #=> 4
10.* 5 #=> 50


# ----- valores especiais são objetos ----- #
nil.class #=> NilClass
true.class #=> TrueClass
false.class #=> FalseClass

# ----- lógica booleana ----- #
1 == 1 #=> true
2 != 2 #=> false
!true #=> false
!nil #=> false
!0 #=> false
1 < 10 #=> true

# ----- Strings são objetos ----- #
'Eu sou uma string'.class #=> String
"Eu também sou string".class #=> String
placeholder = "usar interpolação de string"
puts "Funciona #{placeholder} assim com impressão na stdout"

# ----- variáveis ----- #
x = y = 25 #=> 25
y #=> 25

# ----- por convenção, usar snake_case para nomear variáveis ----- #
snake_case = true
caminho_para_a_raiz_do_projeto = '/bom/nome/'
caminho = '/nome/ruim/'

# ----- Símbolos são imutáveis, são constantes reutilizáveis representados internamente por um valor inteiro. São frequentemente usados no lugar de strings para transmitir com eficiência os valores específicos e significativos ----- #
:pendente.class #=> Symbol

status = :aprovado
status == :aprovado #=> true
status != 'aprovado' #=> true

# ----- Arrays ----- #
[1, 2, 3, 4, 5] #=> [1, 2, 3, 4, 5]
array = [1, "Oi", false]
array[12] #=> nil
## a partir do final
array[-1] #=> 5
## com um índice de início e fim
array[2, 4] #=> [3, 4, 5]
## ou com um intervalo de valores
array[1..3] #=> [2, 3, 4]

## adicionar elemento no (final do) array [alterando-o]
array << 6 #=> [1, 2, 3, 4, 5, 6]

# ----- Hashs são o principal dicionário; com pares de chaves/valor ----- #
minha_hash = {'cor' => 'verde', 'numero' => 5}
minha_hash['cor'] #=> 'verde'
minha_hash.each do |k, v|
  puts "#{k} é #{v}"
end

## ao utilizar símbolos como keys
novo_hash = {defcon: 3, acao: true}
novo_hash.keys #=> [:defcon, :acao]
novo_hash.values #=> [3, true]

# ----- estruturas de controle ----- #

if true
  "Se verdadeiro"
elsif false
  "else if, opcional"
else
  "else, também é opcional"
end

for contador in 1..5
  puts "iteração #{contador} <<<"
end

(1..5).each do |contador|
  puts "iteração #{contador} <<<"
end

contador = 1
while contador <= 5 do
  puts "iteração #{contador}"
  contador += 1
end

# ----- switch case ----- #
grau = 'B'
case grau
  when 'A'
    puts "foo"
  when 'B'
    puts "bar"
  else
    puts "default"
end

# ----- funções ----- #

def dobrar(x)
  x * 2
end

## funções (e todos os blocos) retornam implicitamente o valor da última linha; parênteses opcionais
dobrar dobrar 3 #=> 12

def somar(x, y)
  x + y
end

## argumentos são separados por uma vírgula
somar 3, 4 #=> 7

# ----- yield. Todos os métodos possuem implicitamente um parêmtro opcional que é um bloco, ele pode ser chamado pela keyword 'yield' ----- #
def ao_redor
  print ">>"
  yield
  print "<<"
end

ao_redor { print 'Olá Mundo!' } #=> ">>Olá Mundo!<<"


# ----- classes ----- #

class Humano
  @@especie = "H. sapiens" # variável de classe (mesmo que atributo; compartilhada para classes derivadas)

  def initialize(nome, idade=0) # construtor
    @nome = nome
    @idade = idade
  end

  def nome=(nome) # método para atribuir valor (setter)
    @nome = nome
  end

  def especie # método para resgatar valor (getter)
    @@especie
  end

  def falar(msg)
    "#{@nome} [#{especie}] falou '#{msg}'"
  end
end

# Instanciando uma classe
jim = Humano.new("Jim Halpert")
jim.especie #=> "H. sapiens"
jim.nome = "Jim Halpert II" #=> "Jim Halpert II"
jim.nome #=> "Jim Halpert II"

puts jim.falar "foo" # chamar método

## uma classe também é objeto. Então uma classe pode possuir variável de instância
## classe derivada
class Trabalhador < Humano
end
foo  = Trabalhador.new('aaa')
foo.especie #=> "H. sapiens"


# ----- módulos ----- #

module ExemploModulo
  def foo
    'foo'
  end
end

## Incluir (include) móduloas conecta seus métodos às instâncias da classe
class Pessoa
  include ExemploModulo
end
Pessoa.new.foo #=> 'foo'

## Herdar (extend) módulos conecta seus métodos à classe em si
class Livro
  extend ExemploModulo
end
Livro.foo #=> 'foo'

## callbacks são executados ao incluir e herdar um módulo

module ExemploDeConceito
  def self.included(base)
    base.extend(MetodosDeClasse)
    base.send(:include, MetodosDeInstancia)
  end

  module MetodosDeClasse
    def bar
      'bar'
    end
  end

  module MetodosDeInstancia
    def qux
      'qux'
    end
  end
end

class Algo
  include ExemploDeConceito
end

Algo.bar #=> 'bar'
Algo.new.qux #=> 'qux'
Algo.qux #=> NoMethodError: undefined method `qux'
Algo.new.bar #=> NoMethodError: undefined method `bar'
