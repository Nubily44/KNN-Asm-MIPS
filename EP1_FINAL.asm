.data 
    xTrain: .asciiz "Xtrain.txt" # Localizacao do arquivo de entrada (x) do conjunto de treino
    xTest: .asciiz "Xtest.txt"  # Localizacao do arquivo de entrada (x) do conjunto de teste
    yTrain: .asciiz "Ytrain.txt" # Localizacao do arquivo de entrada (y) do conjunto de treino
    yTest: .asciiz "Ytest.txt" # Localizacao do arquivo de entrada (y) do conjunto de teste

    buffer: .space 200000 
    numeroTeste: .double 123.456

    numero: .space 8 # Variavel para armazenar os digitos do numero para a escrita ("buffer")

    espaco: .asciiz " "
    newline: .asciiz "\n"

    # Strings para printar na tela
    XTRAIN: .asciiz "\n\n\n\n\n X TRAIN \n\n\n\n\n"
    YTRAIN: .asciiz "\n\n\n\n\n Y TRAIN \n\n\n\n\n"
    XTEST: .asciiz "\n\n\n\n\n X TEST \n\n\n\n\n"
    YTEST: .asciiz "\n\n\n\n\n Y TEST \n\n\n\n\n"
    
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

    w: .word 5 # w Ã© o tamanho da coluna.
    h: .word 1 
    k: .word 2 # k Ã© o nÃºmero de vizinhos
    # quantidade de espaÃ§os de memoria alocados a cada matriz baseada em seu tamanho: ([244^2]*8)
    tamLinha: .word 476
    m_xTrain: .space 500000
    m_xTest: .space 500000

.text
.globl main

main:
    # Leitura dos arquivos - passa o caminho como parametro para a funcao lerArquivo
    
    ##########################  TRAIN   ########################################

    ##################################################
    # Leitura do XTrain

    la $a0, XTRAIN
    li $v0, 4       # printa o título do XTRAIN
    syscall

    la $a0, xTrain
    la $a3, v_xTrain     # Le o arquivo de entrada (x) do conjunto de treino
    jal abreArquivo

    ##################################################
    # Cria a matriz de treino

    addi $sp, $sp, -16   # reserva espaço para 4 palavras (4 * 4 bytes)
    sw $ra, 8($sp)      # salva o registrador de retorno (link) na pilha
    sw $s3, 0($sp)       # salva $a1 na pilha

    la $s3,  m_xTrain
    jal carregaMatriz_xTrain

    ##################################################
    # Recupera os valores salvos na pilha

    lw $s3, 0($sp)       # restaura $a1
    lw $ra, 8($sp)      # restaura $ra
    addi $sp, $sp, 16    # libera o espaço alocado na pilha
    
    addi $sp, $sp, -16   # reserva espaço para 4 palavras (4 * 4 bytes)
    sw $ra, 8($sp)      # salva o registrador de retorno (link) na pilha
    sw $s4, 0($sp)       # salva $a1 na pilha
    
    ##################################################
    # Cálculo e print do YTrain

    la $a0, YTRAIN
    li $v0, 4       # printa o título do YTRAIN
    syscall

    la $s4, v_yTrain
    jal carregaY

    ##################################################
    # Retorma os valores salvos na pilha

    lw $s4, 0($sp)       # restaura $a1
    lw $ra, 8($sp)      # restaura $ra
    addi $sp, $sp, 16    # libera o espaço alocado na pilha

    addi $sp, $sp, -16   # reserva espaço para 4 palavras (4 * 4 bytes)
    sw $ra, 8($sp)      # salva o registrador de retorno (link) na pilha
    sw $s5, 0($sp)       # salva $a1 na pilha
    
    ##################################################
    # Leitura do XTest

    la $a0, XTEST
    li $v0, 4       # printa o tÃ­tulo do XTEST
    syscall

    la $a0, xTest
    la $s5, v_xTest     # Le o arquivo de entrada (x) do conjunto de teste
    jal abreArquivo

    ##################################################
    # Cria a matriz de teste

    addi $sp, $sp, -16   # reserva espaÃ§o para 4 palavras (4 * 4 bytes)
    sw $ra, 8($sp)      # salva o registrador de retorno (link) na pilha
    sw $s5, 0($sp)       # salva $s5 na pilha

    la $s5,  m_xTest
    jal carregaMatriz_xTest
    
    ##################################################
    # Retorma os valores salvos na pilha

    lw $s5, 0($sp)       # restaura $a1
    lw $ra, 8($sp)      # restaura $ra
    addi $sp, $sp, 16    # libera o espaÃ§o alocado na pilha


    ##########################     KNN     #####################################


    knn:
    
    li $t1, 0 # i = 0
    li $t2, 0
    lw $t3, k
    
loop_knn:
    slt $t0, $t1, $t2 
    beq $t0, $zero, fim_knn
    
    lw $t2, tamLinha
    sll $t2, $t2, 3
    
fim_knn:





    ##########################  ESCRITA   ######################################
    
    # Escrita do YTest

    la $a0, yTest
    la $a3, v_yTest
    jal escreverArquivo

    j fim

carregaMatriz_xTrain:

    # Salva o endereÃ§o de retorno
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    li $t0, 0           # i = 0
L1:
    lw $t2, tamLinha   # Carrega o tamanho da matriz
    lw $t8, w
    slt $t3, $t0, $t2   # se i < tamMatriz, continua
    beq $t3, $zero, imprimirMatriz  # Alterado para ir para impressÃ£o depois de carregar
    
    li $t1, 0           # j = 0
L2:
    slt $t3, $t1, $t8   # se j < w
    beq $t3, $zero, proximaLinha
    
    # Calcula o endereÃ§o na matriz: base + (i * tamMatriz + j) * 8
    mul $t4, $t0, $t2   # t4 = i * linha
    addu $t4, $t4, $t1  # t4 = i * tamMatriz + j
    sll $t4, $t4, 3     # multiplica por 8 (tamanho do double)
    addu $t4, $s3, $t4  # endereÃ§o final = base + offset
    
    # Calcula o endereÃ§o no vetor:
    addu $t6, $t0,$t1 # i+j para o endereÃ§o do vetor 
    sll $t6, $t6, 3 # multiplica essa soma por 8, para o endereÃ§o em byte (0+0) * 8 =0, 1+0 * 8 = 8 ... etc
    addu $t6, $a3,$t6 # endereÃ§o base do vetor somado baseado nas contas feitas.

    # Carrega e salva o valor
    ldc1 $f2, 0($t6)     # carrega do vetor
    sdc1 $f2, 0($t4)     # salva na matriz
    
    addiu $t1, $t1, 1   # j++
    j L2    
    
proximaLinha:
    addiu $t0, $t0, 1   # i++
    j L1    
    
# Impressão da Matriz xTrain
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
    
    # Calcula o endereÃ§o na matriz novamente
    mul $t4, $t0, $t2   # t4 = i * tamMatriz
    addu $t4, $t4, $t1  # t4 = i * tamMatriz + j
    sll $t4, $t4, 3     # multiplica por 8 (tamanho do double)
    addu $t4, $s3, $t4  # endereÃ§o final = base + offset
    
    # Carrega e imprime o valor
    ldc1 $f12, 0($t4)    # carrega o valor em f12 para impressÃ£o
    li $v0, 3           # cÃ³digo para imprimir double
    syscall
    
    # Imprime um espaÃ§o
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
    lw $ra, 0($sp)      # Restaura o endereÃ§o de retorno
    addiu $sp, $sp, 4
    jr $ra              # retornaÂ paraÂ oÂ caller

# Carrega xTest
carregaMatriz_xTest:

    # Salva o endereÃ§o de retorno
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    li $t0, 0           # i = 0
L1_xTest:
    lw $t2, tamLinha   # Carrega o tamanho da matriz
    lw $t8, w
    slt $t3, $t0, $t2   # se i < tamMatriz, continua
    beq $t3, $zero, imprimirMatriz_xTest  # Alterado para ir para impressÃ£o depois de carregar
    
    li $t1, 0           # j = 0
L2_xTest:
    slt $t3, $t1, $t8   # se j < w
    beq $t3, $zero, proximaLinha_xTest
    
    # Calcula o endereÃ§o na matriz: base + (i * tamMatriz + j) * 8
    mul $t4, $t0, $t2   # t4 = i * linha
    addu $t4, $t4, $t1  # t4 = i * tamMatriz + j
    sll $t4, $t4, 3     # multiplica por 8 (tamanho do double)
    addu $t4, $s5, $t4  # endereÃ§o final = base + offset
    
    # Calcula o endereÃ§o no vetor:
    addu $t6, $t0,$t1 # i+j para o endereÃ§o do vetor 
    sll $t6, $t6, 3 # multiplica essa soma por 8, para o endereÃ§o em byte (0+0) * 8 =0, 1+0 * 8 = 8 ... etc
    addu $t6, $a3,$t6 # endereÃ§o base do vetor somado baseado nas contas feitas.

    # Carrega e salva o valor
    ldc1 $f2, 0($t6)     # carrega do vetor
    sdc1 $f2, 0($t4)     # salva na matriz
    
    addiu $t1, $t1, 1   # j++
    j L2_xTest
    
proximaLinha_xTest:
    addiu $t0, $t0, 1   # i++
    j L1_xTest

# Impressão da Matriz xTrain
imprimirMatriz_xTest:
    li $t0, 0           # i = 0
L1_print_xTest:
    lw $t2, tamLinha   # Carrega o tamanho da matriz
    slt $t3, $t0, $t2   # se i < tamMatriz, continua
    beq $t3, $zero, fimImpressao_xTest
    
    li $t1, 0           # j = 0
L2_print_xTest:
    slt $t3, $t1, $t8   # se j < w
    beq $t3, $zero, proximaLinha_print_xTest
    
    # Calcula o endereÃ§o na matriz novamente
    mul $t4, $t0, $t2   # t4 = i * tamMatriz
    addu $t4, $t4, $t1  # t4 = i * tamMatriz + j
    sll $t4, $t4, 3     # multiplica por 8 (tamanho do double)
    addu $t4, $s5, $t4  # endereÃ§o final = base + offset
    
    # Carrega e imprime o valor
    ldc1 $f12, 0($t4)    # carrega o valor em f12 para impressÃ£o
    li $v0, 3           # cÃ³digo para imprimir double
    syscall
    
    # Imprime um espaÃ§o
    li $v0, 4
    la $a0, espaco
    syscall
    
    addiu $t1, $t1, 1   # j++
    j L2_print_xTest

proximaLinha_print_xTest:
    # Imprime uma quebra de linha
    li $v0, 4
    la $a0, newline
    syscall
    
    addiu $t0, $t0, 1   # i++
    j L1_print_xTest

fimImpressao_xTest:
    lw $ra, 0($sp)      # Restaura o endereço de retorno
    addiu $sp, $sp, 4
    jr $ra              # retorna para o caller

# FunÃ§Ã£o que carrega o Ytrain.
carregaY:
    
    li $t0, 0           # i = 0
    lw $t8, w           # t8 = valor de w 
    lw $t3, tamVetor
    subu $t3, $t3, $t8  # tamanho do vetor Y = tamVetor - w

yLOOP:
    # Primeiro verifica se chegamos ao fim
    slt $t1, $t0, $t3   # comparando i com tamanho do vetor - w
    beq $t1, $zero, fimYFunction

    # Debug: imprime Ã­ndice atual
    li $v0, 1
    move $a0, $t0
    syscall
    la $a0, espaco
    li $v0, 4
    syscall

    # Calcula Ã­ndices e carrega valores
    addu $t2, $t8, $t0  # x + w
    sll $t4, $t2, 3     # (i + w) * 8
    addu $t4, $a3, $t4  # endereÃ§o [i + w] * 8
    ldc1 $f8, 0($t4)     # carrega valor de xTrain
    
    sll $t5, $t0, 3     # i * 8
    addu $t5, $t5, $s4  # endereÃ§o base yTrain + offset
    sdc1 $f8, 0($t5)     # salva valor em yTrain[i]
    
    # Imprime o valor salvo
    ldc1 $f12, 0($t5)    
    li $v0, 3           
    syscall
    
    # Imprime quebra de linha
    la $a0, newline
    li $v0, 4
    syscall
    
    # Incrementa contador e continua
    addi $t0, $t0, 1
    j yLOOP

fimYFunction:
    jr $ra



# Carrega o conteudo de um arquivo no buffer
abreArquivo:
    move $a1, $a3 # Guarda o endereco do vetor
    # Salva os parametros passados para a funcao para recuperacao posterior
    addiu $s6, $a0, 0
    addiu $s7, $a1, 0

    la $s0, 0($a1) # Carrega em s0 o endereco do vetor onde serao armzenados os valores

    li $v0, 13
    li $a1, 0 # Flag 0: Read-only
    li $a2, 0 # Modo que libera as permissoes de acesso
    syscall # Salva o descritor do arquivo em v0 
    
    addiu $s1, $v0, 0 # Salva o descritor do arquivo (obtido com o syscall 13) em s1

# Inicializa os registradores utilizados na leitura de cada numero
inicializaNumero:
   li $t0, 0 # Inicializa o registrador que ira armazenar o numero sendo lido
   li $t2, 0 # Indicador  de se o digito sendo lido corresponde (1) ou nao (0) a uma casa decimal
   li $t3, 0 # Contador de quantas casas decimais o numero possui
   li $t4, 0 # Indicador de se o arquivo chegou ao final

# Le um caractere do arquivo aberto
leCaractere:
    li $v0, 14
    addiu $a0, $s1, 0 # Copia o descritor do arquivo para a0
    la $a1, buffer # Endereco do buffer
    li $a2, 1 # Quantidade de caracteres lidos - le 1 caractere por vez
    syscall
    
    la $s2, buffer # Carrega o endereco do buffer em s1
    
    beqz $v0, fimArquivo
    
    # TESTE - Imprime o buffer
    #li $v0, 4
    #la $a0, buffer
    #syscall

# Verifica qual eh o caractere lido e determina o que deve ser feito
processaCaractere:
    lb $t1, 0($s2) # Carrega o primeiro byte do buffer em t1
    
    beq $t1, '\r', fimNumero # Verifica se ha quebra de linha - finaliza a copia do numero
    beq $t1, '\n', leCaractere # Verifica se ha quebra de linha - passa para a leitura do proximo caractere
    beq $t1, '.', verificaDecimal # Verifica se ha um ponto que determina as casas decimais
    
# Converte um caractere em numero e atualiza o calculo do numero cmpleto
copiaNumero:
    subu $t1, $t1, 48 # Converte o caractere para inteiro - o caractere '0' equivale ao numero 48 da tabela ASCII
    
    mul $t0, $t0, 10 # Multiplica o inteiro anteriormente armazenado (o que foi lido ate entao) por 10 - aumenta em um a ordem numerica
    add $t0, $t0, $t1 # Soma o digito atual ao numero completo que esta sendo lido

    beq $t2, 1, leituraDecimal # Verifica se o digito sendo lido corresponde a uma casa decimal

    j leCaractere

# Digito sendo lido corresponde a uma casa decimal
leituraDecimal:
    addi $t3, $t3, 1 # Incrementa o contador de casas decimais
    j leCaractere

# Apos ler um '.', indica que os proximos digitos serao as casas decimais
verificaDecimal:
    li $t2, 1 # Atualiza o indicador das casas decimais
    j leCaractere

fimNumero:
    # Converte o numero para double
    mtc1 $t0, $f0 # Move o numero para o coprocessador utilizado para operacoes com double
    cvt.d.w $f0, $f0 # Transforma o numero inteiro no equivalente em double
    
    li $t5, 0 # Inicializa a variavel de controle do loop a seguir
    ldc1 $f10, dezDouble # Carrega a constante 10.0 (double) em f10, utilizada para cÃ¡lculos
    
    beqz $t3, pulaLoopConversao
    
    # Realiza uma divisao do numero por 10 a cada decimal existente
    loopConversao:
        addiu $t5, $t5, 1
        div.d $f0, $f0, $f10
        bne $t5, $t3, loopConversao
    
    pulaLoopConversao:
    # TESTE - Imprime o numero
    #ldc1 $f2, zeroDouble
    #add.d $f12, $f0, $f2
    #li $v0, 3
    #syscall
    #la $a0, quebraLinha
    #li $v0, 4
    #syscall
    
    sdc1 $f0, 0($s0) # Guarda o valor no vetor - PSEUDOINSTRUCAO, PRECISA ALTERAR
    addiu $s0, $s0, 8 # Avanca para a proxima posicao do vetor

    beq $t4, 1, fechaArquivo # Verifica se o arquivo chegou ao fim
    j inicializaNumero # Avanca para o proximo numero

fimArquivo:
    li $t4, 1 # Atualiza o indicador de fim do arquivo
    j fimNumero # Finaliza o calculo do ultimo numero

fechaArquivo:
    ldc1 $f2, fimDouble # Valor indicador do fim do vetor
    sdc1 $f2, 0($s0) # Guarda o valor no vetor
    
    # Fecha o arquivo
    li $v0, 16
    syscall
    
    # Recupera os valores dos parametros passados
    addiu $a0, $s6, 0
    addiu $a1, $s7, 0
    
    # Retorna para a funcao principal
    jr $ra

escreverArquivo:

    move $s0, $a3 # Guarda o endereco do vetor
    la $s1, numero # Guarda o endereco da variavel que armazenara os digitos do numero

    #syscall de abertura para criar o arquivo
    li $v0, 13 # Syscall 13: Abre um arquivo
    li $a1, 1 # Flag 1: Write-only
    li $a2, 0 # Modo que libera as permissoes de acesso
    syscall
    move $t0, $v0 # Salva o descritor do arquivo em t0


escrita:
    ldc1 $f2, 0($s0)
    ldc1 $f4, fimDouble
    c.eq.d $f2, $f4 # Verifica se o array acabou de ser lido (-1.0 Ã© a sentinela)
    bc1t fimEscrita # Se sim, finaliza a escrita



    dividirAlgarismos:
        mul.d $f2, $f2, $f10 # Multiplica o numero por 100 para obter o numero inteiro e seus dois digitos decimais
        mul.d $f2, $f2, $f10

        cvt.w.d $f2, $f2 # Converte o numero para inteiro
        mfc1 $t1, $f2

        la $s1, numero # Carrega o endereco da variavel que armazenara os digitos do numero
        li $t5, 0 # Inicializa o contador de digitos

        loopConversaoEscrita:
            beq $t5, 2, escreverPonto # Verifica se o contador de casas decimais chegou a 2
            li $t2, 10 
            div $t1, $t2 # Divide o numero por 10
            mfhi $t4 
            addi $t4, $t4, 48 # Converte o numero para ASCII
            sb $t4, 0($s1) # Armazena o numero no buffer

            addi $s1, $s1, 1 # Avanca o ponteiro do numero
            addi $t5, $t5, 1 # Incrementa o contador de digitos
            mflo $t1 # Atualiza o numero
            bnez $t1, loopConversaoEscrita # Verifica se o numero ainda possui digitos

    escreverNumero:

        beq $t5, 0, proximoNumeroEscrita # Verifica se o numero possui digitos restantes

        la $a3, numero 
        add $a3, $a3, $t5 # Atualiza o endereco do ponteiro do numero
        add $a3, $a3, -1 # Volta uma posicao para ajustar a posiÃ§Ã£o do ponteiro (uma anterior do contador de digitos)

        
        
        move $a1, $a3 # Endereco do buffer
        li $a2, 1 # Tamanho do caractere lido do array numero para ser escrito
        move $a0, $t0 # Usa o descritor do arquivo de t0
        li $v0, 15 # Syscall 15: Escreve no arquivo

        syscall

        addi $s1, $s1, -1
        addi $t5, $t5, -1

        j escreverNumero
    
    escreverPonto:
        li $t4, 46 # ASCII do ponto
        sb $t4, 0($s1) # Armazena o ponto no array temporÃ¡rio de nÃºmeros
        addi $s1, $s1, 1 # AvanÃ§a o ponteiro
        addi $t5, $t5, 1 # Incrementa o contador de digitos
        j loopConversaoEscrita # Volta para a conversao de digitos

proximoNumeroEscrita:
    addiu $s0, $s0, 8  # AvanÃ§a para o prÃ³ximo nÃºmero
    lb $t4, newline # Adiciona uma quebra de linha
    sb $t4, 0($s1) 

    move $a1, $s1
    li $a2, 1
    move $a0, $t0
    li $v0, 15 # Syscall 15: Escreve no arquivo
    syscall

    j escrita

fimEscrita:
    li $v0, 16 #Fecha o arquivo
    syscall

    jr $ra

fim: 
    li $v0, 10
    syscall
