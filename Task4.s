.text
.globl main 
main:
li x5,5 #range a
li x6,4 #range b
li x7, 0 #i=0
li x29, 0 #j=0
li x10, 0x200

Loop1:
    li x29, 0    #j=0
    Loop2:
        slli x11, x29, 4  #4*j
        add x11, x11, x10 #x11=base + offset
        add x12, x7, x29  # i+j
        sw x12, 0(x11)     #D[4*j]=i+j
        addi x29, x29, 1  #j++
        bne x29, x6, Loop2 

    addi x7, x7, 1 #i++
    bne  x7, x5, Loop1 

end:
    j end