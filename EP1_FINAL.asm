.data 
    xTrain: .asciiz "Xtrain.txt" # Localizacao do arquivo de entrada (x) do conjunto de treino
    xTest: .asciiz "Xtest.txt"  # Localizacao do arquivo de entrada (x) do conjunto de teste
    yTrain: .asciiz "Ytrain.txt" # Localizacao do arquivo de entrada (y) do conjunto de treino
    yTest: .asciiz "Ytest.txt" # Localizacao do arquivo de entrada (y) do conjunto de teste

    buffer: .space 200000
    numeroTeste: .double 123.456

    numero: .space 8 # Variavel para armazenar os digitos do numero para a escrita ("buffer")
    newline: .asciiz "\n"
    
    .align 3
    v_xTrain: .space 40000
    v_yTrain: .space 40000
    v_xTest: .space 40000
    v_yTest: .space 40000

    bufferSize: .word 200000
    dezDouble: .double 10.0 
    zeroDouble: .double 0.0
    fimDouble: .double -1.0
    

.text
.globl main

main:
    # Leitura dos arquivos - passa o caminho como parametro para a funcao lerArquivo
    
    la $a0, xTrain
    la $a3, v_xTrain
    jal lerArquivo

    la $a0, yTest
    la $a3, v_yTest
    jal escreverArquivo


    #move $a0, $v0
    #jal abrirArquivos

    j fim

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
    ldc1 $f10, dezDouble # Inicializa o registrador com 10.0 - NÃO PODE USAR,  TROCAR DEPOIS
    ldc1 $f0, zeroDouble # Inicializa o registrador com 0.0 - NÃO PODE USAR, TROCAR DEPOIS
    

copiaNumero:
    lb $t0, 0($s1) # Carrega o primeiro byte do buffer em t0
    
    beqz $t0, fimNumero # Verifica se o arquivo chegou ao fim
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
    

    # TESTE-Imprime o valor
    #move $a0, $s0
    #ldc1 $f12, 0($a0)
    #li $v0, 3
    #syscall


    addiu $s0, $s0, 8 # Avança para a próxima posição do vetor

    # Redefine as variáveis
    li $t1, 0
    li $t2, 0
    li $t3, 0
    ldc1 $f0, zeroDouble
    ldc1 $f2, zeroDouble

    beqz $t0, fimArquivo # Verifica se o arquivo chegou ao fim

    j fimCaractere # Avança para o próximo número

fimArquivo:
    ldc1 $f2, fimDouble
    s.d $f2, 0($s0) # Guarda o valor no vetor

    # TESTE-Imprime o valor (só para o -1)

    #move $a0, $s0
    #ldc1 $f12, 0($a0)
    #li $v0, 3
    #syscall

    la $t0, buffer
    lw $t1, bufferSize

    #Skippa o limpar buffer pra testes
    jr $ra

    limparBuffer:
        sb $zero, 0($t0) # limpa o buffer
        addiu $t0, $t0, 1
        sub $t1, $t1, 1        
        bne $t1, 0, limparBuffer
    
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
    c.eq.d $f2, $f4 # Verifica se o array acabou de ser lido (-1.0 é a sentinela)
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
        add $a3, $a3, -1 # Volta uma posicao para ajustar a posição do ponteiro (uma anterior do contador de digitos)

        
        
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
        sb $t4, 0($s1) # Armazena o ponto no array temporário de números
        addi $s1, $s1, 1 # Avança o ponteiro
        addi $t5, $t5, 1 # Incrementa o contador de digitos
        j loopConversaoEscrita # Volta para a conversao de digitos

proximoNumeroEscrita:
    addiu $s0, $s0, 8  # Avança para o próximo número
    lw $t4, newline # Adiciona uma quebra de linha
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
