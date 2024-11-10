
processarNum:
    la $s0, ($a3) # Carrega o endereco do vetor onde os valores serao armazenados
    la $s1, buffer # Carrega o buffer em si
    li $t1, 0 # Inicializa o registrador que ir� conter o n�mero copiado
    l.d $f10, dezDouble # Inicializa o registrador com 10.0 - N�O PODE USAR,  TROCAR DEPOIS
    l.d $f0, zeroDouble # Inicializa o registrador com 0.0 - N�O PODE USAR, TROCAR DEPOIS
    

copiaNumero:
    lb $t0, 0($s1) # Carrega o primeiro byte do buffer em t0
    
    beq $t0, 0, fimArquivo # Verifica se o arquivo chegou ao fim
    beq $t0, '\n', fimNumero # Verifica se ha quebra de linha - finaliza a copia do numero
    beq $t0, '.', adicionaDecimalCount # Verifica se ha um ponto que determina as casas decimais
    
    subu $t0, $t0, 48 # Converte o caractere para inteiro - o caractere '0' equivale ao n�mero 48 da tabela ASCII
    
    beq $t2, 1, leituraDecimal # Verifica se o digito sendo lido corresponde a uma casa decimal
    
    mul $t1, $t1, 10 # Multiplica o inteiro anteriormente armazenado por 10 (ha deslocamento de uma casa decimal)
    add $t1, $t1, $t0 # Adiciona o digito atual
    j fimCaractere

adicionaDecimalCount:
    li $t2, 1 # Atualiza o indicador das casas decimais
    li $t3, 0 # Inicializa o contador de casas decimais
    
leituraDecimal:
    mul $t1, $t1, 10 # Multiplica o inteiro anteriormente armazenado por 10 (ha deslocamento de uma casa decimal)
    add $t1, $t1, $t0 # Adiciona o digito atual

    addi $t3, $t3, 1 # Incrementa o contador de casas decimais

    j fimCaractere

fimCaractere:
    addiu $s1, $s1, 1 # Avan�a o buffer para o pr�ximo byte
    j copiaNumero # Vai para a pr�xima itera��o do loop

fimNumero:
    # Converte a parte inteira para double - PODEMOS DESDE O IN�CIO SOMAR E SALVAR COMO DOUBLE
    mtc1 $t1, $f2
    cvt.d.w $f2, $f2
    
    li $t4, 0 # Inicializa a variavel do controle do loop a seguir

    loopConversao:
        addiu $t4, $t4, 1
        div.d $f2, $f2, $f10
        bne $t4, $t3, loopConversão # Executa a divisao de acordo com a quantidade de casas decimais do digito em questao
    
    s.d $f2, 0($s0) # Guarda o valor no vetor
    addiu $s0, $s0, 8 # Avan�a para a pr�xima posi��o do vetor

    # Redefine as vari�veis
    li $t1, 0
    li $t2, 0
    li $t3, 0
    l.d $f0, zeroDouble
    l.d $f2, zeroDouble
    
    j fimCaractere # Avan�a para o pr�ximo n�mero