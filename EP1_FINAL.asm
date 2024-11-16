# Organizacao e Arquitetura de Computadores II - Exercicio Programa 1
# Instrucoes: Mudar no .data os caminhos absolutos dos arquivos de entrada

.data 
    xTrain: .asciiz "H:/Meu Drive/4° Semestre/Organização e Arquitetura de Computadores II/EPs/EP1/KNN-Asm-MIPS/Xtrain.txt" # Localizacao do arquivo de entrada (x) do conjunto de treino
    #xTest: .asciiz "Xtest.txt"  # Localizacao do arquivo de entrada (x) do conjunto de teste
    #yTrain: .asciiz "Ytrain.txt" # Localizacao do arquivo de entrada (y) do conjunto de treino
    #yTest: .asciiz "Ytest.txt" # Localizacao do arquivo de entrada (y) do conjunto de teste

    buffer: .space 1 # Buffer de 1 byte - usado para armazenar 1 caractere por vez
   
    .align 3
    v_xTrain: .space 40000
    v_yTrain: .space 40000
    v_xTest: .space 40000
    v_yTest: .space 40000
   
    dezDouble: .double 10.0 
    zeroDouble: .double 0.0
    fimDouble: .double -1.0
    
    # quebraLinha: .asciiz "\n" # Utilizada para testes

.text
.globl main

main:
    # Leitura dos arquivos - passa o caminho como parametro para a funcao abreArquivo
    la $a0, xTrain
    la $a1, v_xTrain
    jal abreArquivo

    #la $a0, yTest
    #la $a3, v_xTrain
    #jal escreverArquivo

    j fim

# Abre o arquivo cujo caminho esta em $a0
abreArquivo:
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
    ldc1 $f10, dezDouble # Carrega a constante 10.0 (double) em f10, utilizada para cálculos
    
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
    
    s.d $f0, 0($s0) # Guarda o valor no vetor - PSEUDOINSTRUCAO, PRECISA ALTERAR
    addiu $s0, $s0, 8 # Avanca para a proxima posicao do vetor

    beq $t4, 1, fechaArquivo # Verifica se o arquivo chegou ao fim
    j inicializaNumero # Avanca para o proximo numero

fimArquivo:
    li $t4, 1 # Atualiza o indicador de fim do arquivo
    j fimNumero # Finaliza o calculo do ultimo numero

fechaArquivo:
    l.d $f2, fimDouble # Valor indicador do fim do vetor
    s.d $f2, 0($s0) # Guarda o valor no vetor
    
    # Fecha o arquivo
    li $v0, 16
    syscall
    
    # Recupera os valores dos parametros passados
    addiu $a0, $s6, 0
    addiu $a1, $s7, 0
    
    # Retorna para a funcao principal
    jr $ra

fim: 
    li $v0, 10
    syscall