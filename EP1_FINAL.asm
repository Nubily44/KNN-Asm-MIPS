.data 
    xTrain: .asciiz "Xtrain.txt" # Localização do arquivo de entrada (x) do conjunto de treino

    xTest: .asciiz "Xtest.txt"  # Localização do arquivo de entrada (x) do conjunto de teste

    yTrain: .asciiz "Ytrain.txt" # Localização do arquivo de entrada (y) do conjunto de treino

    yTest: .asciiz "Ytest.txt" # Localização do arquivo de entrada (y) do conjunto de teste


    buffer: .space 20000  

    .align 3
    v_xTrain: .space 40000
    v_yTrain: .space 40000
    v_xTest: .space 40000
    

    dez: .double 10.0 
    zero: .double 0.0
    
    masValue: .double 999999999999999

.text

.globl main

main:
    # Leitura dos arquivos - passa o caminho como parâmetro para a função lerArquivo
    
    la $a0, xTrain
    la $a3, v_xTrain
    jal lerArquivo

    la $a0, xTest
    la $a3, v_xTest
    jal lerArquivo

    la $a0, yTrain
    la $a3, v_yTrain
    jal lerArquivo


    la $s0, v_xTrain
    la $s1, v_yTrain
    la $s2, v_xTest


    move $a0, $v0
    #jal abrirArquivos

    #j exit

# Carrega o conteúdo de um arquivo no buffer
lerArquivo:
    # Abre o arquivo
    li $v0, 13
    li $a1, 0 # Flag 0: Read-only
    li $a2, 0 # Modo que libera as permissões de acesso
    syscall

    # Carrega o arquivo no buffer
    li $v0, 14
    move $a0, $v0 # Move o identificador do arquivo (obtido com o syscall 13)
    la $a1, buffer # Endereço do buffer
    li $a2, 20000 # Número máximo de caracteres a serem lidos
    syscall

    # Fecha o arquivo
    li $v0, 16
    syscall

processarNum:
    la $s0, ($a3) # Carrega o endereço do vetor onde os valores serão armazenados
    la $s1, buffer # Carrega o buffer em si

    # Cópia dos números
    lb $t0, 0($s1) # Carrega o primeiro byte do buffer


exit: 
    li $v0, 10
    syscall