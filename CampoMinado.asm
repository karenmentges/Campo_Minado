# Campo Minado
# Desenvolvido por Karen Ruver Mentges

	.data
matriz_campo:		.space	324
matriz_interface: 	.word	-1,-1,-1,-1,-1,-1,-1,-1,  -1,-1,-1,-1,-1,-1,-1,-1,  -1,-1,-1,-1,-1,-1,-1,-1,  -1,-1,-1,-1,-1,-1,-1,-1,  -1,-1,-1,-1,-1,-1,-1,-1,  -1,-1,-1,-1,-1,-1,-1,-1,  -1,-1,-1,-1,-1,-1,-1,-1,  -1,-1,-1,-1,-1,-1,-1,-1
salva_S0:		.word	0
salva_ra:		.word	0
salva_ra1:		.word	0
msg_espaco:		.asciz  " "
msg_enter:		.asciz  "\n"
msg_traco:		.asciz  "-"
msg_bandeira:		.asciz  "F"
msg_cima:		.asciz  "\n  0 1 2 3 4 5 6 7"
msg_lateral:		.word	0, 1, 2, 3, 4, 5, 6, 7
msg_pensa:		.asciz  "\n\nEscolha a próxima jogada:\n1-Colocar uma bandeira;\n2-Abrir uma posição.\n"
msg_linha:		.asciz  "Insira o número da linha: "
msg_coluna:		.asciz  "Insira o número da coluna: "
msg_errobandeira:	.asciz  "\nNão foi possivel colocar uma bandeira.\n"
msg_errojogada:		.asciz  "\nNão foi possivel abrir a posição.\n"
msg_bomba:		.asciz  "\nA posição aberta possuia uma bomba.\nVocê perdeu.\n"
msg_ganhou:		.asciz  "\n\nParabéns!\nVocê ganhou.\n"


	.text

main:
	la 	a0, matriz_campo
	li	a1,8
	j 	INSERE_BOMBA


# Função desenvolvida pelo Professor
################################################################################################################

INSERE_BOMBA:
		la	t0, salva_S0
		sw  	s0, 0 (t0)		# salva conteudo de s0 na memoria
		la	t0, salva_ra
		sw  	ra, 0 (t0)		# salva conteudo de ra na memoria
		
		add 	t0, zero, a0		# salva a0 em t0 - endereço da matriz campo
		add 	t1, zero, a1		# salva a1 em t1 - quantidade de linhas 

QTD_BOMBAS:
		addi 	t2, zero, 15 		# seta para 15 bombas	
		add 	t3, zero, zero 		# inicia contador de bombas com 0
		addi 	a7, zero, 30 		# ecall 30 pega o tempo do sistema em milisegundos (usado como semente
		ecall 				
		add 	a1, zero, a0		# coloca a semente em a1

INICIO_LACO:
		beq 	t2, t3, FIM_LACO
		add 	a0, zero, t1 		# carrega limite para %	(resto da divisão)
		jal 	PSEUDO_RAND
		add 	t4, zero, a0		# pega linha sorteada e coloca em t4
		add 	a0, zero, t1 		# carrega limite para % (resto da divisão)
   		jal 	PSEUDO_RAND
		add 	t5, zero, a0		# pega coluna sorteada e coloca em t5
		
LE_POSICAO:	
		mul  	t4, t4, t1
		add  	t4, t4, t5  		# calcula (L * tam) + C
		add  	t4, t4, t4  		# multiplica por 2
		add  	t4, t4, t4  		# multiplica por 4
		add  	t4, t4, t0  		# calcula Base + deslocamento
		lw   	t5, 0(t4)   		# Le posicao de memoria LxC

VERIFICA_BOMBA:		
		addi 	t6, zero, 9		# se posição sorteada já possui bomba
		beq  	t5, t6, PULA_ATRIB	# pula atribuição 
		sw   	t6, 0(t4)		# senão coloca 9 (bomba) na posição
		addi 	t3, t3, 1		# incrementa quantidade de bombas sorteadas

PULA_ATRIB:
		j	INICIO_LACO

FIM_LACO:					# recupera registradores salvos
		la	t0, salva_S0
		lw  	s0, 0(t0)		# recupera conteudo de s0 da memória
		la	t0, salva_ra
		lw  	ra, 0(t0)		# recupera conteudo de ra da memória		
		j	inicializa1			# retorna para funcao que fez a chamada

PSEUDO_RAND:
		addi t6, zero, 125  		# carrega constante t6 = 125
		lui  t5, 682			# carrega constante t5 = 2796203
		addi t5, t5, 1697 		# 
		addi t5, t5, 1034 		# 	
		mul  a1, a1, t6			# a = a * 125
		rem  a1, a1, t5			# a = a % 2796203
		rem  a0, a1, a0			# a % lim
		bge  a0, zero, EH_POSITIVO  	# testa se valor eh positivo
		addi t4, zero, -1           	# caso não 
		mul  a0, a0, t4		    	# transforma em positivo

EH_POSITIVO:	
		ret				# retorna em a0 o valor obtido
		
################################################################################################################


# Inicializa os registradores para serem usados na função calculabombas
inicializa1:
	la	a0, matriz_campo	# Carrega o endereço da matriz campo em s1
	li 	a2, 8			# Carrega o número de colunas/linhas
	mul	a1, a2, a2		# Calcula o tamanho da matriz
	li	t0, 0			# Inicializa o contador que irá percorrer a matriz
	li	t1, 9			# Inicializa o comparador de bomba
	li	t2, 0			# Inicializa o contador secundário que irá contar as colunas da matriz
	li	t3, 0			# Inicializa o comparador da coluna 0
	li	t4, 7			# Inicializa o comparador da coluna 7
	li	t5, 0			# Inicializa o contador terciário que irá contar as linhas da matriz
	li	a4, 0			# Inicializa o contador de posições abertas
	li	a5, 0			# Inicializa o contador de bombas da matriz
	j 	calculabombas



# Função que irá calcular as bombas vizinhas de cada casa
calculabombas:	
	beq 	t0, a1, inicializa2	# Realiza a repetição da função em todas os indices da matriz
	beq	t2, a2, zera		# Quando o contador de colunas da matriz for igual a 8, será zerado para iniciar novamente a contagem das colunas na proxima linha
	lw  	s0, 0(a0)		# Carrega o valor de s0 em s0
	beq	s0, t1, carregabombas	# Se o valor lido na matriz é igual a 9, será calculado o valor das casas ao redor da bomba na função carregabombas
	addi	a0, a0, 4		# Acrescenta 4 no endereço da matriz para acessar o próximo número
	addi	t0, t0, 1		# Acrescenta 1 no contador primário
	addi	t2, t2, 1		# Acrescenta 1 no contador secundário
	j	calculabombas
	
	
	# Função que zera t2 para iniciar a comparação das colunas na próxima linha
	zera:
		li	t2, 0		# Zera o contador de colunas
		addi	t5, t5, 1	# Acrescenta 1 no contador terciário
		j 	calculabombas

	# Função que irá carregar o número de bombas próximas a cada casa da matriz
	carregabombas:
		beq	t2, t3, padrão1				# Se for da coluna 0, será feito o calculo das casas com o padrão 1
		beq	t2, t4, padrão2				# Se for da coluna 7, será feito o calculo das casas com o padrão 2
		j 	padrão3					# As demais colunas serão feitas com o padrão 3
	
	
		# Se a bomba estiver na coluna 0
		padrão1:
			beq	t5, t3, padrão1.1		# Se for da linha 0, será feito o calculo das casas com o padrão 1.1
			beq	t5, t4, padrão1.2		# Se for da linha 7, será feito o calculo das casas com o padrão 1.2
			addi	a0, a0, -28			# Acessa o valor da casa próxima a bomba
			lw  	s0, 0(a0)			# Carrega o valor da casa em s0
			beq	s0, t1, padrão1_1		# Se o valor for igual a 9 (bomba), pula para o próximo passo
			addi	s0, s0, 1			# Acrescenta 1 ao valor da casa
			sw  	s0, 0(a0)			# Grava o novo valor da casa na matriz campo
		
			padrão1_1:
				addi	a0, a0, -4		# Acessa o valor da casa próxima a bomba
				lw  	s0, 0(a0)		# Carrega o valor da casa em s0
				beq	s0, t1, padrão1_2	# Se o valor for igual a 9 (bomba), pula para o próximo passo
				addi	s0, s0, 1		# Acrescenta 1 ao valor da casa
				sw  	s0, 0(a0)		# Grava o novo valor da casa na matriz campo
		
			padrão1_2:	
				addi	a0, a0, 36		# Acessa o valor da casa próxima a bomba
				lw  	s0, 0(a0)		# Carrega o valor da casa em s0
				beq	s0, t1, padrão1_3	# Se o valor for igual a 9 (bomba), pula para o próximo passo	
				addi	s0, s0, 1		# Acrescenta 1 ao valor da casa
				sw  	s0, 0(a0)		# Grava o novo valor da casa na matriz campo
		
			padrão1_3:
				addi	a0, a0, 28		# Acessa o valor da casa próxima a bomba
				lw  	s0, 0(a0)		# Carrega o valor da casa em s0
				beq	s0, t1, padrão1_4	# Se o valor for igual a 9 (bomba), pula para o próximo passo
				addi	s0, s0, 1		# Acrescenta 1 ao valor da casa
				sw  	s0, 0(a0)		# Grava o novo valor da casa na matriz campo
		
			padrão1_4:
				addi	a0, a0, 4		# Acessa o valor da casa próxima a bomba
				lw  	s0, 0(a0)		# Carrega o valor da casa em s0
				beq	s0, t1, padrão1_5	# Se o valor for igual a 9 (bomba), pula para o próximo passo
				addi	s0, s0, 1		# Acrescenta 1 ao valor da casa
				sw  	s0, 0(a0)		# Grava o novo valor da casa na matriz campo
		
			padrão1_5:
				addi	a0, a0, -32		# Volta para a posição da bomba + 4 (o próximo valor a ser lido)
				addi	a5, a5, 1		# Calcula o número de bombas
				addi	t0, t0, 1		# Acrescenta 1 no contador primário
				addi	t2, t2, 1		# Acrescenta 1 no contador secundário
			
			j	calculabombas
			
			
		# Se a bomba estiver na coluna 0 e na linha 0	
		padrão1.1:
			addi	a0, a0, 4			# Acessa o valor da casa próxima a bomba
			lw  	s0, 0(a0)			# Carrega o valor da casa em s0
			beq	s0, t1, padrão1.1_1		# Se o valor for igual a 9 (bomba), pula para o próximo passo
			addi	s0, s0, 1			# Acrescenta 1 ao valor da casa
			sw  	s0, 0(a0)			# Grava o novo valor da casa na matriz campo
			
			padrão1.1_1:
				addi	a0, a0, 28		# Acessa o valor da casa próxima a bomba
				lw  	s0, 0(a0)		# Carrega o valor da casa em s0
				beq	s0, t1, padrão1.1_2	# Se o valor for igual a 9 (bomba), pula para o próximo passo
				addi	s0, s0, 1		# Acrescenta 1 ao valor da casa
				sw  	s0, 0(a0)		# Grava o novo valor da casa na matriz campo
				
			padrão1.1_2:
				addi	a0, a0, 4		# Acessa o valor da casa próxima a bomba
				lw  	s0, 0(a0)		# Carrega o valor da casa em s0
				beq	s0, t1, padrão1.1_3	# Se o valor for igual a 9 (bomba), pula para o próximo passo
				addi	s0, s0, 1		# Acrescenta 1 ao valor da casa
				sw  	s0, 0(a0)		# Grava o novo valor da casa na matriz campo
			
			padrão1.1_3:
				addi	a0, a0, -32		# Volta para a posição da bomba + 4 (o próximo valor a ser lido)
				addi	a5, a5, 1		# Calcula o número de bombas
				addi	t0, t0, 1		# Acrescenta 1 no contador primário
				addi	t2, t2, 1		# Acrescenta 1 no contador secundário
			
			j	calculabombas
		
		
		
		# Se a bomba estiver na coluna 0 e na linha 7
		padrão1.2:
			addi	a0, a0, 4			# Acessa o valor da casa próxima a bomba
			lw  	s0, 0(a0)			# Carrega o valor da casa em s0
			beq	s0, t1, padrão1.2_1		# Se o valor for igual a 9 (bomba), pula para o próximo passo
			addi	s0, s0, 1			# Acrescenta 1 ao valor da casa
			sw  	s0, 0(a0)			# Grava o novo valor da casa na matriz campo
			
			padrão1.2_1:
				addi	a0, a0, -32		# Acessa o valor da casa próxima a bomba
				lw  	s0, 0(a0)		# Carrega o valor da casa em s0
				beq	s0, t1, padrão1.2_2	# Se o valor for igual a 9 (bomba), pula para o próximo passo
				addi	s0, s0, 1		# Acrescenta 1 ao valor da casa
				sw  	s0, 0(a0)		# Grava o novo valor da casa na matriz campo
				
			padrão1.2_2:
				addi	a0, a0, -4		# Acessa o valor da casa próxima a bomba
				lw  	s0, 0(a0)		# Carrega o valor da casa em s0
				beq	s0, t1, padrão1.2_3	# Se o valor for igual a 9 (bomba), pula para o próximo passo
				addi	s0, s0, 1		# Acrescenta 1 ao valor da casa
				sw  	s0, 0(a0)		# Grava o novo valor da casa na matriz campo
			
			padrão1.2_3:
				addi	a0, a0, 36		# Volta para a posição da bomba + 4 (o próximo valor a ser lido)
				addi	a5, a5, 1		# Calcula o número de bombas
				addi	t0, t0, 1		# Acrescenta 1 no contador primário
				addi	t2, t2, 1		# Acrescenta 1 no contador secundário
			
			j	calculabombas
	
	
		# Se a bomba estiver na coluna 7
		padrão2:
			beq	t5, t3, padrão2.1		# Se for da linha 0, será feito o calculo das casas com o padrão 2.1
			beq	t5, t4, padrão2.2		# Se for da linha 7, será feito o calculo das casas com o padrão 2.2
			addi	a0, a0, -4			# Acessa o valor da casa próxima a bomba
			lw  	s0, 0(a0)			# Carrega o valor da casa em s0
			beq	s0, t1, padrão2_1		# Se o valor for igual a 9 (bomba), pula para o próximo passo
			addi	s0, s0, 1			# Acrescenta 1 ao valor da casa
			sw  	s0, 0(a0)			# Grava o novo valor da casa na matriz campo
	
			padrão2_1:
				addi	a0, a0, -28		# Acessa o valor da casa próxima a bomba
				lw  	s0, 0(a0)		# Carrega o valor da casa em s0
				beq	s0, t1, padrão2_2	# Se o valor for igual a 9 (bomba), pula para o próximo passo
				addi	s0, s0, 1		# Acrescenta 1 ao valor da casa
				sw  	s0, 0(a0)		# Grava o novo valor da casa na matriz campo
		
			padrão2_2:
				addi	a0, a0, -4		# Acessa o valor da casa próxima a bomba
				lw  	s0, 0(a0)		# Carrega o valor da casa em s0
				beq	s0, t1, padrão2_3	# Se o valor for igual a 9 (bomba), pula para o próximo passo
				addi	s0, s0, 1		# Acrescenta 1 ao valor da casa
				sw  	s0, 0(a0)		# Grava o novo valor da casa na matriz campo
			
			padrão2_3:
				addi	a0, a0, 64		# Acessa o valor da casa próxima a bomba
				lw  	s0, 0(a0)		# Carrega o valor da casa em s0
				beq	s0, t1, padrão2_4	# Se o valor for igual a 9 (bomba), pula para o próximo passo
				addi	s0, s0, 1		# Acrescenta 1 ao valor da casa
				sw  	s0, 0(a0)		# Grava o novo valor da casa na matriz campo
		
			padrão2_4:
				addi	a0, a0, 4		# Acessa o valor da casa próxima a bomba
				lw  	s0, 0(a0)		# Carrega o valor da casa em s0
				beq	s0, t1, padrão2_5	# Se o valor for igual a 9 (bomba), pula para o próximo passo
				addi	s0, s0, 1		# Acrescenta 1 ao valor da casa
				sw  	s0, 0(a0)		# Grava o novo valor da casa na matriz campo
		
			padrão2_5:
				addi	a0, a0, -28		# Volta para a posição da bomba + 4 (o próximo valor a ser lido)
				addi	a5, a5, 1		# Calcula o número de bombas
				addi	t0, t0, 1		# Acrescenta 1 no contador primário
				addi	t2, t2, 1		# Acrescenta 1 no contador secundário
		
			j	calculabombas
		
		
		# Se a bomba estiver na coluna 7 e na linha 0
		padrão2.1:
			addi	a0, a0, -4			# Acessa o valor da casa próxima a bomba
			lw  	s0, 0(a0)			# Carrega o valor da casa em a0
			beq	s0, t1, padrão2.1_1		# Se o valor for igual a 9 (bomba), pula para o próximo passo
			addi	s0, s0, 1			# Acrescenta 1 ao valor da casa
			sw  	s0, 0(a0)			# Grava o novo valor da casa na matriz campo
			
			padrão2.1_1:
				addi	a0, a0, 32		# Acessa o valor da casa próxima a bomba
				lw  	s0, 0(a0)		# Carrega o valor da casa em a0
				beq	s0, t1, padrão2.1_2	# Se o valor for igual a 9 (bomba), pula para o próximo passo
				addi	s0, s0, 1		# Acrescenta 1 ao valor da casa
				sw  	s0, 0(a0)		# Grava o novo valor da casa na matriz campo
				
			padrão2.1_2:
				addi	a0, a0, 4		# Acessa o valor da casa próxima a bomba
				lw  	s0, 0(a0)		# Carrega o valor da casa em a0
				beq	s0, t1, padrão2.1_3	# Se o valor for igual a 9 (bomba), pula para o próximo passo
				addi	s0, s0, 1		# Acrescenta 1 ao valor da casa
				sw  	s0, 0(a0)		# Grava o novo valor da casa na matriz campo
			
			padrão2.1_3:
				addi	a0, a0, -28		# Volta para a posição da bomba + 4 (o próximo valor a ser lido)
				addi	a5, a5, 1		# Calcula o número de bombas
				addi	t0, t0, 1		# Acrescenta 1 no contador primário
				addi	t2, t2, 1		# Acrescenta 1 no contador secundário
			
			j	calculabombas
		
		
		# Se a bomba estiver na coluna 7 e na linha 7
		padrão2.2:
			addi	a0, a0, -4			# Acessa o valor da casa próxima a bomba
			lw  	s0, 0(a0)			# Carrega o valor da casa em a0
			beq	s0, t1, padrão2.2_1		# Se o valor for igual a 9 (bomba), pula para o próximo passo
			addi	s0, s0, 1			# Acrescenta 1 ao valor da casa
			sw  	s0, 0(a0)			# Grava o novo valor da casa na matriz campo
			
			padrão2.2_1:
				addi	a0, a0, -28		# Acessa o valor da casa próxima a bomba
				lw  	s0, 0(a0)		# Carrega o valor da casa em a0
				beq	s0, t1, padrão2.2_2	# Se o valor for igual a 9 (bomba), pula para o próximo passo
				addi	s0, s0, 1		# Acrescenta 1 ao valor da casa
				sw  	s0, 0(a0)		# Grava o novo valor da casa na matriz campo
				
			padrão2.2_2:
				addi	a0, a0, -4		# Acessa o valor da casa próxima a bomba
				lw  	s0, 0(a0)		# Carrega o valor da casa em a0
				beq	s0, t1, padrão2.2_3	# Se o valor for igual a 9 (bomba), pula para o próximo passo
				addi	s0, s0, 1		# Acrescenta 1 ao valor da casa
				sw  	s0, 0(a0)		# Grava o novo valor da casa na matriz campo
			
			padrão2.2_3:
				addi	a0, a0, 36		# Volta para a posição da bomba
				addi	a5, a5, 1		# Calcula o número de bombas
				addi	t0, t0, 1		# Acrescenta 1 no contador primário
				addi	t2, t2, 1		# Acrescenta 1 no contador secundário
			
			j	calculabombas
			
			
			
		# Se a bomba estiver entre as colunas 1 e 6
		padrão3:
			beq	t5, t3, padrão3.1		# Se for da linha 0, será feito o calculo das casas com o padrão 3.1
			beq	t5, t4, padrão3.2		# Se for da linha 7, será feito o calculo das casas com o padrão 3.2
			addi	a0, a0, -4			# Acessa o valor da casa próxima a bomba
			lw  	s0, 0(a0)			# Carrega o valor da casa em s0
			beq	s0, t1, padrão3_1		# Se o valor for igual a 9 (bomba), pula para o próximo passo
			addi	s0, s0, 1			# Acrescenta 1 ao valor da casa
			sw  	s0, 0(a0)			# Grava o novo valor da casa na matriz campo
	
			padrão3_1:
				addi	a0, a0, -24		# Acessa o valor da casa próxima a bomba
				lw  	s0, 0(a0)		# Carrega o valor da casa em s0
				beq	s0, t1, padrão3_2	# Se o valor for igual a 9 (bomba), pula para o próximo passo
				addi	s0, s0, 1		# Acrescenta 1 ao valor da casa
				sw  	s0, 0(a0)		# Grava o novo valor da casa na matriz campo
	
			padrão3_2:
				addi	a0, a0, -4		# Acessa o valor da casa próxima a bomba
				lw  	s0, 0(a0)		# Carrega o valor da casa em s0
				beq	s0, t1, padrão3_3	# Se o valor for igual a 9 (bomba), pula para o próximo passo	
				addi	s0, s0, 1		# Acrescenta 1 ao valor da casa
				sw  	s0, 0(a0)		# Grava o novo valor da casa na matriz campo
	
			padrão3_3:
				addi	a0, a0, -4		# Acessa o valor da casa próxima a bomba
				lw  	s0, 0(a0)		# Carrega o valor da casa em s0
				beq	s0, t1, padrão3_4	# Se o valor for igual a 9 (bomba), pula para o próximo passo
				addi	s0, s0, 1		# Acrescenta 1 ao valor da casa
				sw  	s0, 0(a0)		# Grava o novo valor da casa na matriz campo
		
			padrão3_4:
				addi	a0, a0, 40		# Acessa o valor da casa próxima a bomba
				lw  	s0, 0(a0)		# Carrega o valor da casa em s0
				beq	s0, t1, padrão3_5	# Se o valor for igual a 9 (bomba), pula para o próximo passo
				addi	s0, s0, 1		# Acrescenta 1 ao valor da casa
				sw  	s0, 0(a0)		# Grava o novo valor da casa na matriz campo
	
			padrão3_5:
				addi	a0, a0, 24		# Acessa o valor da casa próxima a bomba
				lw  	s0, 0(a0)		# Carrega o valor da casa em s0
				beq	s0, t1, padrão3_6	# Se o valor for igual a 9 (bomba), pula para o próximo passo
				addi	s0, s0, 1		# Acrescenta 1 ao valor da casa
				sw  	s0, 0(a0)		# Grava o novo valor da casa na matriz campo
				
			padrão3_6:
				addi	a0, a0, 4		# Acessa o valor da casa próxima a bomba
				lw  	s0, 0(a0)		# Carrega o valor da casa em s0
				beq	s0, t1, padrão3_7	# Se o valor for igual a 9 (bomba), pula para o próximo passo
				addi	s0, s0, 1		# Acrescenta 1 ao valor da casa
				sw  	s0, 0(a0)		# Grava o novo valor da casa na matriz campo
	
			padrão3_7:
				addi	a0, a0, 4		# Acessa o valor da casa próxima a bomba
				lw  	s0, 0(a0)		# Carrega o valor da casa em s0
				beq	s0, t1, padrão3_8	# Se o valor for igual a 9 (bomba), pula para o próximo passo
				addi	s0, s0, 1		# Acrescenta 1 ao valor da casa
				sw  	s0, 0(a0)		# Grava o novo valor da casa na matriz campo
	
			padrão3_8:
				addi	a0, a0, -32		# Volta para a posição da bomba + 4 (o próximo valor a ser lido)
				addi	a5, a5, 1		# Calcula o número de bombas
				addi	t0, t0, 1		# Acrescenta 1 no contador primário
				addi	t2, t2, 1		# Acrescenta 1 no contador secundário
		
			j 	calculabombas
		
		
		# Se a bomba estiver entre as colunas 1 e 6 e na linha 0
		padrão3.1:
			addi	a0, a0, -4			# Acessa o valor da casa próxima a bomba
			lw  	s0, 0(a0)			# Carrega o valor da casa em s0
			beq	s0, t1, padrão3.1_1		# Se o valor for igual a 9 (bomba), pula para o próximo passo
			addi	s0, s0, 1			# Acrescenta 1 ao valor da casa
			sw  	s0, 0(a0)			# Grava o novo valor da casa na matriz campo
			
			padrão3.1_1:
				addi	a0, a0, 8		# Acessa o valor da casa próxima a bomba
				lw  	s0, 0(a0)		# Carrega o valor da casa em s0
				beq	s0, t1, padrão3.1_2	# Se o valor for igual a 9 (bomba), pula para o próximo passo
				addi	s0, s0, 1		# Acrescenta 1 ao valor da casa
				sw  	s0, 0(a0)		# Grava o novo valor da casa na matriz campo
				
			padrão3.1_2:
				addi	a0, a0, 24		# Acessa o valor da casa próxima a bomba
				lw  	s0, 0(a0)		# Carrega o valor da casa em s0
				beq	s0, t1, padrão3.1_3	# Se o valor for igual a 9 (bomba), pula para o próximo passo
				addi	s0, s0, 1		# Acrescenta 1 ao valor da casa
				sw  	s0, 0(a0)		# Grava o novo valor da casa na matriz campo
			
			padrão3.1_3:
				addi	a0, a0, 4		# Acessa o valor da casa próxima a bomba
				lw  	s0, 0(a0)		# Carrega o valor da casa em s0
				beq	s0, t1, padrão3.1_4	# Se o valor for igual a 9 (bomba), pula para o próximo passo
				addi	s0, s0, 1		# Acrescenta 1 ao valor da casa
				sw  	s0, 0(a0)		# Grava o novo valor da casa na matriz campo
				
			padrão3.1_4:
				addi	a0, a0, 4		# Acessa o valor da casa próxima a bomba
				lw  	s0, 0(a0)		# Carrega o valor da casa em s0
				beq	s0, t1, padrão3.1_5	# Se o valor for igual a 9 (bomba), pula para o próximo passo
				addi	s0, s0, 1		# Acrescenta 1 ao valor da casa
				sw  	s0, 0(a0)		# Grava o novo valor da casa na matriz campo
			
			padrão3.1_5:
				addi	a0, a0, -32		# Volta para a posição da bomba + 4 (o próximo valor a ser lido)
				addi	a5, a5, 1		# Calcula o número de bombas
				addi	t0, t0, 1		# Acrescenta 1 no contador primário
				addi	t2, t2, 1		# Acrescenta 1 no contador secundário
			
			j	calculabombas
		
		
		# Se a bomba estiver entre as colunas 1 e 6 e na linha 7
		padrão3.2:
			addi	a0, a0, 4			# Acessa o valor da casa próxima a bomba
			lw  	s0, 0(a0)			# Carrega o valor da casa em a0
			beq	s0, t1, padrão3.2_1		# Se o valor for igual a 9 (bomba), pula para o próximo passo
			addi	s0, s0, 1			# Acrescenta 1 ao valor da casa
			sw  	s0, 0(a0)			# Grava o novo valor da casa na matriz campo
			
			padrão3.2_1:
				addi	a0, a0, -8		# Acessa o valor da casa próxima a bomba
				lw  	s0, 0(a0)		# Carrega o valor da casa em a0
				beq	s0, t1, padrão3.2_2	# Se o valor for igual a 9 (bomba), pula para o próximo passo
				addi	s0, s0, 1		# Acrescenta 1 ao valor da casa
				sw  	s0, 0(a0)		# Grava o novo valor da casa na matriz campo
				
			padrão3.2_2:
				addi	a0, a0, -24		# Acessa o valor da casa próxima a bomba
				lw  	s0, 0(a0)		# Carrega o valor da casa em a0
				beq	s0, t1, padrão3.2_3	# Se o valor for igual a 9 (bomba), pula para o próximo passo
				addi	s0, s0, 1		# Acrescenta 1 ao valor da casa
				sw  	s0, 0(a0)		# Grava o novo valor da casa na matriz campo
				
			padrão3.2_3:
				addi	a0, a0, -4		# Acessa o valor da casa próxima a bomba
				lw  	s0, 0(a0)		# Carrega o valor da casa em a0
				beq	s0, t1, padrão3.2_4	# Se o valor for igual a 9 (bomba), pula para o próximo passo
				addi	s0, s0, 1		# Acrescenta 1 ao valor da casa
				sw  	s0, 0(a0)		# Grava o novo valor da casa na matriz campo
				
			padrão3.2_4:
				addi	a0, a0, -4		# Acessa o valor da casa próxima a bomba
				lw  	s0, 0(a0)		# Carrega o valor da casa em a0
				beq	s0, t1, padrão3.2_5	# Se o valor for igual a 9 (bomba), pula para o próximo passo
				addi	s0, s0, 1		# Acrescenta 1 ao valor da casa
				sw  	s0, 0(a0)		# Grava o novo valor da casa na matriz campo
			
			padrão3.2_5:
				addi	a0, a0, 40		# Volta para a posição da bomba + 4 (o próximo valor a ser lido)
				addi	a5, a5, 1		# Calcula o número de bombas
				addi	t0, t0, 1		# Acrescenta 1 no contador primário
				addi	t2, t2, 1		# Acrescenta 1 no contador secundário
			
			j	calculabombas

	
# Inicializa os registradores para serem usados nas próximas funções
inicializa2:
	li	t0, 0			# Inicializa o contador que irá percorrer a matriz
	li	t1, 8			# Inicializa o comparador de coluna para impressão da matriz
	mul	a6, t1, t1		# Calcula o tamanho da matriz
	li	t2, -1			# Inicializa o comparador para a impressão de traços na matriz interface
	li	t4, 2			# Inicializa o comparador de jogada, para abrir uma posição
	la	s0, matriz_interface	# Carrega o endereço da matriz interface em s0
	la	s1, matriz_campo	# Carrega o endereço da matriz campo em s1
	la	t3, msg_lateral		# Carrega o endereço da mensagem que ira ser impressa na lateral da matriz para indicar a marcação das posições
	li	t5, 4			# Inicializa o registrador
	li 	s8, 10			# Inicializa o comparador de bandeira
	j	imprimefirst
	

# Função que imprime a linha marcadora das posições da matriz na parte de cima, e inicia com o 0 na lateral
imprimefirst:
	la	a0, msg_cima		# Carrega a mensagem das marcações que vão na parte de cima da matriz
	li	a7, 4			# Imprime a mensagem
	ecall
	la	a0, msg_enter		# Carrega a mensagem enter, para pular a linha
	li	a7, 4			# Imprime a mensagem
	ecall
	lw  	a0, 0(t3)		# Carrega o primeiro valor da mensagem que vai na lateral da matriz para marcar as posições
	li 	a7, 1			# Imprime o valor
    	ecall
    	la	a0, msg_espaco		# Carrega a mensagem espaço, para dar um espaçamento entre a marcação e a matriz
	li	a7, 4			# Imprime a mensagem
	ecall
	addi	t3, t3, 4		# Acessa o próximo valor da mensagem
	j 	imprime	
	
	
	# Função que imprime os valores da matriz
	imprime:
		beq 	t0, a6, pensa			# Realiza a repetição da função conta em todos os indices da matriz
		beq	t0, t1, pula			# Se o contador for igual a 8, pula para a função pula
	
		lw  	a0, 0(s0)			# Carrega o valor da matriz
		beq	a0, t2, arruma			# Se o valor for igual a -1, pula para a função arruma
		bge	a0, s8, arruma2 		# Se o valor for igual a 10, pula para a função arruma2
		li 	a7, 1				# Imprime o valor
    		ecall
    		la	a0, msg_espaco			# Carrega a mensagem espaço, para dar um espaçamento entre a marcação e a matriz
		li	a7, 4				# Imprime a mensagem
		ecall
		addi	s0, s0, 4			# Acrescenta 4 no endereço da matriz, acessa o próximo número
		addi	t0, t0, 1			# Acrescenta 1 no contador
		j	imprime
	

		# Função que arruma os valores -1 na matriz para serem impressos como traço
		arruma:
			la	a0, msg_traco		# Carrega a mensagem traço, para ser impresso as posições que não foram abertas ainda
			li	a7, 4			# Imprime a mensagem
			ecall
			la	a0, msg_espaco		# Carrega a mensagem espaço, para dar um espaçamento entre a marcação e a matriz
			li	a7, 4			# Imprime a mensagem
			ecall
			addi	s0, s0, 4		# Acrescenta 4 no endereço da matriz, acessa o próximo número
			addi	t0, t0, 1		# Acrescenta 1 no contador
			j	imprime
	
		
		# Função que arruma os valores 10 na matriz para serem impressos como F
		arruma2:
			la	a0, msg_bandeira	# Carrega a mensagem bandeira, para ser impresso nas posições que foram inseridas uma bandeira
			li	a7, 4			# Imprime a mensagem 
			ecall
			la	a0, msg_espaco		# Carrega a mensagem espaço, para dar um espaçamento entre a marcação e a matriz
			li	a7, 4			# Imprime a mensagem
			ecall
			addi	s0, s0, 4		# Acrescenta 4 no endereço da matriz, acessa o próximo número
			addi	t0, t0, 1		# Acrescenta 1 no contador
			j	imprime


		# Função que pula a linha na matriz e imprime a marcação
		pula:
			la	a0, msg_enter		# Carrega a mensagem enter, para pular a linha
			li	a7, 4			# Imprime a mensagem
			ecall
			addi	t1, t1, 8		# Acrescenta o número da próxima quebra de linha na matriz
	
			lw  	a0, 0(t3)		# Carrega o primeiro valor da mensagem que vai na lateral da matriz para marcar as posições
			li 	a7, 1			# Imprime o valor
    			ecall
    			la	a0, msg_espaco		# Carrega a mensagem espaço, para dar um espaçamento entre a marcação e a matriz
			li	a7, 4			# Imprime a mensagem
			ecall
			addi	t3, t3, 4		# Acessa o próximo valor da mensagem
			j 	imprime


# Função que espera o jogador tomar uma decisão, e a partir dessa decisão executa as funções de colocar uma bandeira, ou abrir uma posição
pensa:
	beq	s6, t2, fim		# Se foi aberto uma bomba, pula para o fim
	sub	s7, a6, a5		# Calcula o número de casas que devem ser abertas para ganhar o jogo (quantidade de casas da matriz - número de bombas)
	beq	s7, a4, ganhou		# Confere se número de posições abertas é igual ao número de casa que devem ser abertas para ganhar, pula para a função ganhou
	la	a0, msg_pensa		# Carrega a mensagem com o insere bandeira e abre posição
	li	a7, 4			# Imprime a mensagem
	ecall
	addi	a7, zero, 5		# Lê o valor inserido pelo jogador (1 = inserebandeira / 2 = abre posição)
	ecall 
	add 	s9, zero, a0		# Carrega o valor lido em s9
	
	la	a0, msg_linha		# Carrega a mensagem de linha
	li	a7, 4			# Imprime a mensagem
	ecall
	addi	a7, zero, 5		# Lê o valor da linha inserido pelo jogador
	ecall 
	add 	s10, zero, a0		# Carrega o valor da linha em s10
	
	la	a0, msg_coluna		# Carrega a mensagem de coluna
	li	a7, 4			# Imprime a mensagem
	ecall
	addi	a7, zero, 5		# Lê o valor da coluna inserido pelo jogador
	ecall 
	add 	s11, zero, a0		# Carrega o valor da coluna em s11
	
	
	mul	t6, s10, a2		# Calcula a posição, fazendo a operação: (linha * quantidadedecolunas)
	add	t6, t6, s11		# Calcula a posição, fazendo a operação: (linha * quantidadedecolunas) + coluna
	la	s0, matriz_interface	# Carrega o endereço da matriz interface em s0
	la	s2, matriz_campo	# Carrega o endereço da matriz campo em s2
	mul	t6, t6, t5		# Calcula posição na matriz
	add	s0, s0, t6		# Carrega posição na matriz interface
	add	s2, s2, t6		# Carrega posição na matriz campo
	lw	a0, 0(s0)		# Carrega valor da posição da matriz interface
	lw	a1, 0(s2)		# Carrega valor da posição da matriz campo
	
	beq	s9, t4, jogada		# Se o jogador escolheu abrir uma posição, pula para a função jogada
	j	bandeira		# Se não, pula para a função bandeira
	
	
	# Função que verifica se já tem uma bandeira, se não pode ser colocada uma bandeira e se puder realiza o cálculo que coloca a bandeira na posição da matriz
	bandeira:
		bge 	a1, s8, retirabandeira		# Se o valor da posição da matriz campo é maior ou igual a 10, pula para a função retira bandeira
		bgt 	a0, t2, bandeira2		# Se o valor da posição da matriz interface é maior que -1, pula para a função bandeira2
		add	a1, a1, s8			# Adiciona 10 ao valor da posição armazenada em a1
		sw	a1, 0(s0)			# Grava o novo valor na posição da matriz interface
		sw	a1, 0(s2)			# Grava o novo valor na posição da matriz campo
		j	inicializa2


		# Função que verifica se a posição não pode ser colocada uma bandeira, se puder realiza o cálculo que coloca a bandeira na posição da matriz
		bandeira2:
			blt	a0, s8, errobandeira	# Se o valor da posição da matriz interface é menor que 10, pula para a função errobandeira
			add	a1, a1, s8		# Adiciona 10 ao valor da posição armazenada em a1
			sw	a1, 0(s0)		# Grava o novo valor na posição da matriz interface
			sw	a1, 0(s2)		# Grava o novo valor na posição da matriz campo
			j	inicializa2

		
		# Função que realiza o cálculo para retirar a bandeira
		retirabandeira:
			sub 	a1, a1, s8		# Subtrai 10 do valor da posição armazenada em a1
			sw	t2, 0(s0)		# Grava o valor de -1 na matriz interface
			sw	a1, 0(s2)		# Grava o valor subtraido de 10 na matriz campo
			j	inicializa2


		# Função que imprime a mensagem que não pode ser colocada uma bandeira na posição desejada
		errobandeira:
			la	a0, msg_errobandeira	# Carrega a mensagem errobandeira, que indica que não é possível colocar uma bandeira na posição desejada
			li	a7, 4			# Imprime a mensagem
			ecall
			j	inicializa2


	# Função que abre uma posição na matriz interface, calcula o número de posições abertas e confere se a posição aberta não é uma bomba ou se não pode ser aberta
	jogada:
		li	a3, 9				# Inicializa o comparador de bomba
		beq	a3, a1, bomba			# Se o valor da posição for igual a 9, pula para a função bomba
		bgt	a0, t2, errojogada		# Se o valor da posição na matriz interface é maior que -1, pula para a função errojogada
		sw	a1, 0(s0)			# Grava o valor da posição da matriz campo na matriz interface
		addi	a4, a4, 1			# Calcula o número de posições abertas
		j 	inicializa2
	
		
		# Função que imprime a mensagem que não é possivel abrir a posição desejada da matriz
		errojogada:
			la	a0, msg_errojogada	# Carrega a mensagem errojogada, que indica que não é possivel abrir a posição desejada
			li	a7, 4			# Imprime a mensagem
			ecall
			j	inicializa2

		
		# Função que imprime a mensagem que o jogador explodiu a bomba, inicializa as variaveis e manda para a impressão da matriz campo
		bomba:
			la	a0, msg_bomba		# Carrega a mensagem bomba, que indica que a posição aberta possuia uma bomba e que o jogador perdeu
			li	a7, 4			# Imprime a mensagem
			ecall
			li	s6, -1			# Inicializa o registrador com -1, para ser utilizado na finalização do programa
			la	s0, matriz_campo	# É carregado a matriz campo em s0 para ser impresso após a explosão da bomba
			la	t3, msg_lateral		# Carrega o endereço da mensagem que ira ser impressa na lateral da matriz para indicar a marcação das posições
			li	t0, 0			# Inicializa o contador que irá percorrer a matriz
			li	t1, 8			# Inicializa o comparador de coluna para impressão da matriz
			j	imprimefirst
	
	
	# Função que imprime a mensagem que o jogador ganhou
	ganhou:	
		la	a0, msg_ganhou		# Carrega a mensagem ganhou, para sinalizar que o jogador ganhou 
		li	a7, 4			# Imprime a mensagem
		ecall
		j	fim


# Função que finaliza o programa
fim:
	nop
