.text
.globl main

main:

li x10, 0x100 #x[] base address
li x11, 4 #len
li x5, 0 #i
li x6, 0 #

li x21, 3
li x22, 4
li x23, 5
li x24, 1

sw x21, 0(x10) #x[0]=3
sw x22, 4(x10) #x[1]=4
sw x23, 8(x10)#x[2]=5
sw x24, 12(x10) #x[3]=1

lw x25, 0(x10)
beq x25, x0 , exit  #exit if array is null
lw x26, 4(x10)
beq x26, x0 , exit #exit if x[1]==0
lw x27, 4(x10)
beq x27, x0 , exit #exit if x[2]==0
lw x28, 4(x10)
beq x28, x0 , exit #exit if x[3]==0

bubble:
    bge x5, x11, exit  # if i>=len, exit
    add x6, x0, x5 #j=i
    loop2:
        bge x6, x11, loop2_end #if j>=len, exit
        slli x9, x5,  2  #i*4(int=4bytes)
        add x9, x9, x10  #address of x[i]
        lw x7, 0(x9) #x[i]

        slli x20, x6, 2 
        add x20, x20, x10 #address of x[j]
        lw x8, 0(x20) #x[j]

        addi x6, x6, 1 #j++

        ble x7, x8,loop2  # if x[i]<=x[j], continue inner loop
        jal x1, swap

swap:
    sw x8, 0(x9)  #x[i]=x[j]
    sw x7, 0(x20) #x[j]=x[i] 
    j loop2 #return to loop

    loop2_end:
        addi x5, x5, 1 #i++
        j bubble
exit: