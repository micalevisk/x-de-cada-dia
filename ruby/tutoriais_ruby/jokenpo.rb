def calcular_vencedor(escolha_humano, escolha_pc)
	resultado = (escolha_humano - escolha_pc) % 3

	if resultado == 1
		'Você ganhou!'
	elsif resultado == 2
		'O bot ganhou!'
	else
		'Deu empate'
	end
end


opcoes = {
	1 => 'Pedra',
	2 => 'Papel',
	3 => 'Tesoura'
}

novo_jogo = 's'

while novo_jogo.downcase == 's'
	opcoes.each { |k, v| puts "#{k} - #{v}" }
	print 'Escolha uma opção acima: '
	escolha_humano = gets.to_i

	while opcoes[escolha_humano].nil?
		print 'Opção inválida! Escolha novamente: '
		escolha_humano = gets.to_i
	end

	escolha_pc = Random.rand(3) + 1

	print "\nO bot escolheu #{opcoes[escolha_pc]}, então... "
	puts calcular_vencedor(escolha_humano, escolha_pc)
	
	print "\nJogar novamente? (s/n) "
	novo_jogo = gets.chomp[0]
end

