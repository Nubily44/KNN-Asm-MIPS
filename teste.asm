.data
    path: .asciiz "teste.txt"
    teste: .space 2

.text
file_open:
    li $v0, 13
    la $a0, path
    li $a1, 1
    li $a2, 0
    syscall  # File descriptor gets returned in $v0
    
file_write:
    move $a0, $v0  # Syscall 15 requieres file descriptor in $a0
    li $v0, 15
    li $t1, 57
    la $s0, teste
    sb $t1, 0($s0)
    addi $s0, $s0, 1
    sb $t1, 0($s0)
    la $a1, teste
    la $a2, 2
    syscall
file_close:
    li $v0, 16  # $a0 already has the file descriptor
    syscall
