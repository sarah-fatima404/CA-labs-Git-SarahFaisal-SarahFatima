li x10,0x100 #x[] base address 
li x11, 0x200 #y[] base address 
#Store Hi  into y[]
li x5, 'H'
li x6, 'i'
sb x5, 0(x11) #y[0]='H'
sb x6, 1(x11)   # y[1] = 'i'
sb x0, 2(x11)   # y[2] = '\0'

jal x1,strcpy 
j exit

strcpy:
addi sp, sp, -8   #allocate memory
sw x19, 0(sp)     # save the value of x19
li x19, 0         # initialize x19

while_loop:
    add x12, x10, x19  #base + offset for x[]
    add x13, x11, x19  #base + offset for y[]
    lbu x14, 0(x13)    #x14=y[i]
    sb x14, 0(x12)     #x[i]=y[i]
    beq x14, x0,done   #if y[i]='\0'
    addi x19, x19, 1   #i++
    jal x0, while_loop

    done:
        lw x19, 0(sp) 
        addi sp, sp, 8  #reallocate memory
        jalr, x0, 0(x1) #jump to x1 and return address x0

exit:

