.data 
    xTrain: .asciiz "Xtrain.txt" # Localizacao do arquivo de entrada (x) do conjunto de treino
    xTest: .asciiz "Xtest.txt"  # Localizacao do arquivo de entrada (x) do conjunto de teste
    yTrain: .asciiz "Ytrain.txt" # Localizacao do arquivo de entrada (y) do conjunto de treino
    yTest: .asciiz "Ytest.txt" # Localizacao do arquivo de entrada (y) do conjunto de teste
    espaco: .asciiz " "
    newline: .asciiz "\n"
    YTRAIN: .asciiz "\n\n\n\n\n\nY TRAAIIIIIIIIIIIIIIINNNNNNNNNNNNN \n\n\n\n\n"
    Xtest: .asciiz "\n\n\n\n XTESTEEEEEEEEEE: \n\n\n\n "
    buffer: .space 200000
    tamVetor: .word 479
    .align 3
    v_xTrain: .space 40000
    v_yTrain: .space 40000
    v_xTest: .space 40000
    v_yTest: .space 40000
    
    bufferSize: .word 200000
    dezDouble: .double 10.0 
    zeroDouble: .double 0.0
    fimDouble: .double -1.0
    
    #masValue: .double 999999999999999
    # definição no .Data das variaveis dadas no exercicio.
    w: .word 3 # w é o tamanho da coluna.
    h: .word 1
    k: .word 2
    # quantidade de espaços de memoria alocados a cada matriz baseada em seu tamanho: ([244^2]*8)
    tamLinha: .word 476
    m_xTrain: .space 500000
    m_xTest: .space 500000
.text
.globl main

main:
    # Leitura dos arquivos - passa o caminho como parametro para a funcao lerArquivo
    
    la $a0, xTrain
    la $a3, v_xTrain
    jal lerArquivo
    
    
    addi $sp, $sp, -16   # reserva espaço para 4 palavras (4 * 4 bytes)
    sw $ra, 8($sp)      # salva o registrador de retorno (link) na pilha
    sw $a1, 0($sp)       # salva $a1 na pilha

    la $a1,  m_xTrain
    jal carregaMatriz
    
    lw $a1, 0($sp)       # restaura $a1
    lw $ra, 8($sp)      # restaura $ra
    addi $sp, $sp, 16    # libera o espaço alocado na pilha
    
    addi $sp, $sp, -16   # reserva espaço para 4 palavras (4 * 4 bytes)
    sw $ra, 8($sp)      # salva o registrador de retorno (link) na pilha
    sw $a1, 0($sp)       # salva $a1 na pilha
    
    la $a1, v_yTrain
    jal carregaYtrain 
    
    lw $a1, 0($sp)       # restaura $a1
    lw $ra, 8($sp)      # restaura $ra
    addi $sp, $sp, 16    # libera o espaço alocado na pilha
    
    la $a0, xTest
    la $a3, v_xTest
    jal lerArquivo
    
    la $a0, Xtest
    li $v0, 4
    syscall
    
    addi $sp, $sp, -16   # reserva espaço para 4 palavras (4 * 4 bytes)
    sw $ra, 8($sp)      # salva o registrador de retorno (link) na pilha
    sw $a1, 0($sp)       # salva $a1 na pilha

    la $a1,  m_xTrain
    jal carregaMatriz
    
    lw $a1, 0($sp)       # restaura $a1
    lw $ra, 8($sp)      # restaura $ra
    addi $sp, $sp, 16    # libera o espaço alocado na pilha
	
    
    
    #la $a0, yTrain
    #la $a3, v_yTrain
    #jal lerArquivo

    #la $s0, v_xTrain
    #la $s1, v_yTrain
    #la $s2, v_xTest


    #move $a0, $v0
    #jal abrirArquivos
    j fim
    

carregaMatriz:
    # Salva o endereço de retorno
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    li $t0, 0           # i = 0
L1:
    lw $t2, tamLinha   # Carrega o tamanho da matriz
    lw $t8, w
    slt $t3, $t0, $t2   # se i < tamMatriz, continua
    beq $t3, $zero, imprimirMatriz  # Alterado para ir para impressão depois de carregar
    
    li $t1, 0           # j = 0
L2:
    slt $t3, $t1, $t8   # se j < w
    beq $t3, $zero, proximaLinha
    
    # Calcula o endereço na matriz: base + (i * tamMatriz + j) * 8
    mul $t4, $t0, $t2   # t4 = i * linha
    addu $t4, $t4, $t1  # t4 = i * tamMatriz + j
    sll $t4, $t4, 3     # multiplica por 8 (tamanho do double)
    addu $t4, $a1, $t4  # endereço final = base + offset
    
    # Calcula o endereço no vetor:
    addu $t6, $t0,$t1 # i+j para o endereço do vetor 
    sll $t6, $t6, 3 # multiplica essa soma por 8, para o endereço em byte (0+0) * 8 =0, 1+0 * 8 = 8 ... etc
    addu $t6, $a3,$t6 # endereço base do vetor somado baseado nas contas feitas.

    # Carrega e salva o valor
    l.d $f2, 0($t6)     # carrega do vetor
    s.d $f2, 0($t4)     # salva na matriz
    
    addiu $t1, $t1, 1   # j++
    j L2
    
proximaLinha:
    addiu $t0, $t0, 1   # i++
    j L1

imprimirMatriz:
    li $t0, 0           # i = 0
L1_print:
    lw $t2, tamLinha   # Carrega o tamanho da matriz
    slt $t3, $t0, $t2   # se i < tamMatriz, continua
    beq $t3, $zero, fimImpressao
    
    li $t1, 0           # j = 0
L2_print:
    slt $t3, $t1, $t8   # se j < w
    beq $t3, $zero, proximaLinha_print
    
    # Calcula o endereço na matriz novamente
    mul $t4, $t0, $t2   # t4 = i * tamMatriz
    addu $t4, $t4, $t1  # t4 = i * tamMatriz + j
    sll $t4, $t4, 3     # multiplica por 8 (tamanho do double)
    addu $t4, $a1, $t4  # endereço final = base + offset
    
    # Carrega e imprime o valor
    l.d $f12, 0($t4)    # carrega o valor em f12 para impressão
    li $v0, 3           # código para imprimir double
    syscall
    
    # Imprime um espaço
    li $v0, 4
    la $a0, espaco
    syscall
    
    addiu $t1, $t1, 1   # j++
    j L2_print
    
proximaLinha_print:
    # Imprime uma quebra de linha
    li $v0, 4
    la $a0, newline
    syscall
    
    addiu $t0, $t0, 1   # i++
    j L1_print

fimImpressao:
    lw $ra, 0($sp)      # Restaura o endereço de retorno
    addiu $sp, $sp, 4
    jr $ra              # retorna para o caller


# Função que carrega o Ytrain.
carregaYtrain:
    addi $sp, $sp, -24
    sw $ra, 20($sp)
    sw $a3, 16($sp)
    sw $a1, 12($sp)
    la $a0, YTRAIN
    li $v0, 4
    syscall
    
    li $t0, 0 # i = 0
    lw $t8, w #t1 = o valor de w 
    lw $t3, tamVetor
    subu $t3, $t3, $t8 # tamanho do vetor Y
YtrainLOOP:
    li $v0, 1
    move $a0, $t0
    syscall
    la $a0, espaco
    li $v0, 4
    syscall
    
    addu $t2, $t8, $t0 # x + w
    slt $t1, $t0, $t3 # comparando i com tamanho da linha - w
    beq $t1, $zero, fimYtrainFunction
    sll $t4, $t2, 3
    addu $a3, $a3, $t4 # endereçp [i + w] * 8
    l.d $f8, 0($a3) 
    sll $t5, $t0, 3  # endereço base = i * 8
    addu $a1, $t5, $a1 # base = i * 8
    s.d $f8, 0($a1) # salvo o valor da palavra que está em Xtrain[w+i] no Ytrain [i]
    l.d $f12, 0($a1)    # carrega o valor em f12 para impressão
    # código para imprimir double
    li $v0, 3           
    syscall
    addi $t0, $t0, 1
    
    # imprimindo \n 
    la $a0, newline
    li $v0, 4
    syscall
    
    
    j YtrainLOOP

fimYtrainFunction:
    lw $ra, 20($sp)
    lw $a3, 16($sp)
    lw $a1, 12($sp)
    addi $sp, $sp, 24
    jr $ra




# Carrega o conteudo de um arquivo no buffer
lerArquivo:
    # Abre o arquivo cujo caminho esta em $a0
    li $v0, 13
    li $a1, 0 # Flag 0: Read-only
    li $a2, 0 # Modo que libera as permissoes de acesso
    syscall # Salva o descritor do arquivo em v0 
    addiu $a0, $v0, 0 # Move o descritor do arquivo (obtido com o syscall 13)

    # Carrega o arquivo no buffer
    li $v0, 14
    la $a1, buffer # Endereco do buffer
    lw $a2, bufferSize # Numero maximo de caracteres a serem lidos
    syscall

    # Fecha o arquivo
    li $v0, 16
    syscall
    
    # TESTE-Imprime o buffer
    #li $v0, 4
    #la $a0, buffer
    #syscall

processarNum:
    la $s0, ($a3) # Carrega o endereco do vetor onde os valores serao armazenados
    la $s1, buffer # Carrega o buffer em si
    li $t1, 0 # Inicializa o registrador que irá conter o número copiado
    l.d $f10, dezDouble # Inicializa o registrador com 10.0 - NÃO PODE USAR,  TROCAR DEPOIS
    l.d $f0, zeroDouble # Inicializa o registrador com 0.0 - NÃO PODE USAR, TROCAR DEPOIS
    

copiaNumero:
    lb $t0, 0($s1) # Carrega o primeiro byte do buffer em t0
    
    beqz $t0, fimArquivo # Verifica se o arquivo chegou ao fim
    beq $t0, '\r', fimNumero # Verifica se ha quebra de linha - finaliza a copia do numero
    beq $t0, '\n', fimCaractere # Verifica se ha quebra de linha - finaliza a copia do numero
    beq $t0, '.', adicionaDecimalCount # Verifica se ha um ponto que determina as casas decimais
    
    subu $t0, $t0, 48 # Converte o caractere para inteiro - o caractere '0' equivale ao n�mero 48 da tabela ASCII
    
    mul $t1, $t1, 10 # Multiplica o inteiro anteriormente armazenado por 10 (ha deslocamento de uma casa decimal)
    add $t1, $t1, $t0 # Adiciona o digito atual

    beq $t2, 1, leituraDecimal # Verifica se o digito sendo lido corresponde a uma casa decimal

    j fimCaractere

adicionaDecimalCount:
    li $t2, 1 # Atualiza o indicador das casas decimais
    li $t3, 0 # Inicializa o contador de casas decimais
    
leituraDecimal:
    addi $t3, $t3, 1 # Incrementa o contador de casas decimais

    j fimCaractere

fimCaractere:
    addiu $s1, $s1, 1 # Avança o buffer para o próximo byte
    j copiaNumero # Vai para a próxima iteração do loop

fimNumero:
    # Converte o número para double
    mtc1 $t1, $f2
    cvt.d.w $f2, $f2
    
    li $t4, 1 # Inicializa a variável do controle do loop a seguir

    loopConversao:
        addiu $t4, $t4, 1
        div.d $f2, $f2, $f10
        bne $t4, $t3, loopConversao # Executa a divisao de acordo com a quantidade de casas decimais do digito em questao
    
    s.d $f2, 0($s0) # Guarda o valor no vetor
    

    #TESTE-Imprime o valor
  #  move $a0, $s0 # We can pass the address of the array element that contains the double value
   # l.d $f12, 0($a0) # Load the double value from memory to $f12
    # li $v0, 3 # Syscall code for printing a floating-point number
    # syscall


    addiu $s0, $s0, 8 # Avança para a próxima posição do vetor

    # Redefine as variáveis
    li $t1, 0
    li $t2, 0
    li $t3, 0
    l.d $f0, zeroDouble
    l.d $f2, zeroDouble
    
    j fimCaractere # Avança para o próximo número
      
fimArquivo:
    l.d $f2, fimDouble
    s.d $f2, 0($s0) # Guarda o valor no vetor

    la $t0, buffer
    lw $t1, bufferSize

    limparBuffer:
        sb $zero, 0($t0) # limpa o buffer
        addiu $t0, $t0, 1
        sub $t1, $t1, 1        
        bne $t1, 0, limparBuffer
    
    jr $ra

fim: 
    li $v0, 10
    syscall
    
