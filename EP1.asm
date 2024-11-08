.data
	#Todos os arquivos necessários devem estar na mesma pasta que o arquivo .asm
    xTrain:         .asciiz  "teste.txt"
    xTrainBuffer:   .space 4320

#

.text

.globl main

main:

    jal abrirArquivos

    j exit

abrirArquivos:

    li $v0, 13
    la $a0, xTrain
    li $a1, 0
    li $a2, 0
    syscall
    move $s0, $v0

lerArquivos:

    li $v0, 14
    move $a0, $s0
    la $a1, xTrainBuffer
    li $a2, 1
    syscall

    li $v0, 11
    move $a0, $t0
    syscall
    j analisar

analisar:

    beq $v0, 0, exit
    lb $t0, 0($a1)

    li $v0, 11
    move $a0, $t0
    syscall

    j analisar

exit:
    li $v0, 10
    syscall