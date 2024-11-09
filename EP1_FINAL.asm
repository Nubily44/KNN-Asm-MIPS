.data 
    xTrain: .asciiz "H:/Meu Drive/4° Semestre/Organização e Arquitetura de Computadores II/EPs/EP1/KNN-Asm-MIPS/Xtrain.txt" # Localizacao do arquivo de entrada (x) do conjunto de treino
    #xTrain: .asciiz "C:/Users/kauep/teste.txt"
    #xTest: .asciiz "Xtest.txt"  # Localizacao do arquivo de entrada (x) do conjunto de teste
    #yTrain: .asciiz "Ytrain.txt" # Localizacao do arquivo de entrada (y) do conjunto de treino
    #yTest: .asciiz "Ytest.txt" # Localizacao do arquivo de entrada (y) do conjunto de teste

    buffer: .space 20000  

    .align 3
    v_xTrain: .space 40000
    v_yTrain: .space 40000
    v_xTest: .space 40000
    
    dezDouble: .double 10.0 
    zero: .double 0.0
    
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
    addiu $a0, $v0, $zero # Move o descritor do arquivo (obtido com o syscall 13)

    # Carrega o arquivo no buffer
    li $v0, 14
    la $a1, buffer # Endereco do buffer
    li $a2, 20000 # Numero maximo de caracteres a serem lidos
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
    l.d $f10, $dezDouble # Inicializa o registrador com 10.0 - NÃO PODE USAR,  TROCAR DEPOIS
    l.d $f2, $zeroDouble # Inicializa o registrador com 0.0 - NÃO PODE USAR, TROCAR DEPOIS
    
    
# Copia dos numeros
copiaNumero:
    lb $t0, 0($s1) # Carrega o primeiro byte do buffer em t0
    
    beq $t0, 0, fimArquivo # Verifica se o arquivo chegou ao fim
    beq $t0, '\n', fimNumero # Verifica se ha quebra de linha - finaliza a copia do numero
    beq $t0, '.', verificaDecimal # Verifica se ha um ponto que determina as casas decimais
    
    subu $t0, $t0, 48 # Converte o caractere para inteiro - o caractere '0' equivale ao número 48 da tabela ASCII
    
    beq $t2, 1, leituraDecimal # Verifica se o digito sendo lido corresponde a uma casa decimal
    
    mul $t1, $t1, 10 # Multiplica o inteiro anteriormente armazenado por 10 (ha deslocamento de uma casa decimal)
    add $t1, $t1, $t0 # Adiciona o digito atual
    j fimCaractere

verificaDecimal:
    li $t2, 1 # Atualiza o indicador das casas decimais
    li $t3, 0 # Inicializa o contador de casas decimais
    
leituraDecimal:
    # Conversao para double - NÃO PODE USAR, PENSAR EM OUTRA FORMA DE FAZER
    mtc1 $t0, $f0
    cvt.d.w $f0, $f0
    
    addiu $t3, $t3, 1 # Incrementa o contador de casas decimais
    
    li $t4, $t4, 0 # Inicializa a variavel do controle do loop a seguir
    
    # Loop que divide o valor inteiro por múltiplos 10 para obter o valor decimal correto
    loopDivisao:
        addiu $t4, $t4, 1
        div.d $f0, $f0, $f10
        bne $t4, $t3, loopDivisao # Executa a divisao de acordo com a quantidade de casas decimais do digito em questao
    
    add.d $f2, $f2, $f0 # Adiciona a nova casa decimal ao valor decimal calculado até então
    li $t4, 0 # Redefine a variável de controle do loop
    
fimCaractere:
    addiu $s1, $s1, 1 # Avança o buffer para o próximo byte
    j copiaNumero # Vai para a próxima iteração do loop

fimNumero:
    # Converte a parte inteira para double - PODEMOS DESDE O INÍCIO SOMAR E SALVAR COMO DOUBLE
    mtc1 $t1, $f4
    cvt.d.w $f4, $f4
    
    add.d $f4, $f4, $f2 # Soma a parte decimal
    
    s.d $f4, 0($s0) # Guarda o valor no vetor
    addiu $s0, $s0, 8 # Avança para a próxima posição do vetor

    # Redefine as variáveis
    li $t1, 0
    li $t2, 0
    li $t3, 0
    l.d $f0, zeroDouble
    l.d $f2, $zeroDouble
    
    j fimCaractere # Avança para o próximo número
      
fimArquivo:
    
    

fim: 
    li $v0, 10
    syscall
