.data 
    xTrain: .asciiz "Xtrain.txt" # Localizacao do arquivo de entrada (x) do conjunto de treino
    xTest: .asciiz "Xtest.txt"  # Localizacao do arquivo de entrada (x) do conjunto de teste
    yTrain: .asciiz "Ytrain.txt" # Localizacao do arquivo de entrada (y) do conjunto de treino
    yTest: .asciiz "Ytest.txt" # Localizacao do arquivo de entrada (y) do conjunto de teste

    buffer: .space 200000

    .align 3
    v_xTrain: .space 40000
    v_yTrain: .space 40000
    v_xTest: .space 40000
    
    bufferSize: .word 200000
    dezDouble: .double 10.0 
    zeroDouble: .double 0.0
    fimDouble: .double -1.0
    
    #masValue: .double 999999999999999

.text
.globl main

main:
    # Leitura dos arquivos - passa o caminho como parametro para a funcao lerArquivo
    
    la $a0, xTrain
    la $a3, v_xTrain
    jal lerArquivo

    #la $a0, xTest
    #la $a3, v_xTest
    #jal lerArquivo

    #la $a0, yTrain
    #la $a3, v_yTrain
    #jal lerArquivo

    #la $s0, v_xTrain
    #la $s1, v_yTrain
    #la $s2, v_xTest


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
    

    # TESTE-Imprime o valor
    #move $a0, $s0 # We can pass the address of the array element that contains the double value
    #l.d $f12, 0($a0) # Load the double value from memory to $f12
    #li $v0, 3 # Syscall code for printing a floating-point number
    #syscall


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
    li $t1, bufferSize

    limparBuffer:
        sb $zero, 0($t0) # limpa o buffer
        addiu $t0, $t0, 1
        sub $t1, $t1, 1        
        bne $t1, 0, limparBuffer
    
    jr $ra

fim: 
    li $v0, 10
    syscall
