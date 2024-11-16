.data 
    coiso: .double 55324.7
    coiso2: .double 10.0

.text
.globl main

main:
    l.d $f0, coiso
    l.d $f2, coiso2
    div.d $f4, $f0, $f2
    round.w.d $f4, $f0
    cvt.d.w $f4, $f4

