class Monstro
  attr_accessor :energia, :ataque, :vivo

  def initialize
    self.energia = Random.rand(10) + 6
    self.vivo = true
  end

  def vivo?
    true if self.energia > 0
  end

  def bater(alvo)
    if alvo.vivo?
      self.ataque = Random.rand(5)
      alvo.energia -= self.ataque
      puts "O dano do monstro foi #{self.ataque}"
    else
      puts 'Você está morto!'
    end
  end
end

class Heroi
  attr_accessor :energia, :ataque, :vivo, :numero_mortos

  def initialize
    self.energia = 30
    self.vivo = true
    self.numero_mortos = 0
  end

  def vivo?
    true if self.energia > 0
  end

  def bater(alvo)
    if alvo.vivo?
      self.ataque = Random.rand(5) + 3 # mínimo 3 de dano
      alvo.energia -= self.ataque
      puts "Você acertou o monstro, seu dano foi #{self.ataque}"
    else
      puts 'O monstro está morto!'
    end

    unless alvo.vivo?
      puts "O monstro está morto!\n\n"
      self.numero_mortos += 1
    end

  end

end


odim = Heroi.new
puts odim.inspect

while odim.vivo?
  fishman = Monstro.new
  puts fishman.inspect

  while fishman.vivo? and odim.vivo? ## '&&' vs 'and' http://www.rubyinside.com/and-or-ruby-3631.html
    odim.bater(fishman)

    if fishman.vivo?
      puts "A energia do Fishman é #{fishman.energia}"
      fishman.bater(odim)

      print "Sua energia é #{odim.energia}"
      puts ''
    end
  end
end

puts "\nOdim está morto."
puts "Você matou #{odim.numero_mortos} monstros antes de morrer."
