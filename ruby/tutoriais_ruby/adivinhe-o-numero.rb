novo_jogo = "s"

while novo_jogo == "s"

	print "Adivinhe o número que estou pensando entre 1 e 10: "
	# puts seu_numero
	pc_numero = Random.rand(9) + 1

	tentativas = 1

	seu_numero = gets.to_i
	while seu_numero != pc_numero
		if pc_numero > seu_numero
			puts "O número é maior que #{seu_numero}" # usando String Interpolation
		else
			puts "O número é menor que #{seu_numero}"
		end

		tentativas += 1

		print "Tente novamente: "
		seu_numero = gets.to_i
	end

	puts "Parabéns! Você tentou #{tentativas} vezes"

	print "Deseja jogar novamente? (s/n)\n"
	novo_jogo = gets.chomp ## remove \n, \r, e \r\n da string

end

