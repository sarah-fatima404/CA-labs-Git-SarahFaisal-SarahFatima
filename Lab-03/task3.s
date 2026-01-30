.text
.globl main
main:

addi x24, x0, 2  #v[k]
addi x25, x0, 1  #v[k+1]
addi x27, x0, 5 

sw x24, 0x100(x0)
sw x25, 0x104(x0)
sw x27, 0x108(x0)
addi, x10, x0, 0x100
addi, x11, x0, 1
jal x1, swap
j exit

swap:
addi sp, sp, -12
sw x27, 8(sp)
sw x25, 4(sp)
sw x24, 0(sp)

slli x6, x11, 2
add x6, x10, x6

lw x5, 0(x6)  #temp= v[k]
lw x7, 4(x6)  #v[k+1]

sw x7, 0(x6)   # v[k] = v[k+1]
sw x5, 4(x6)   # v[k+1] = temp

lw x24, 0(sp)
lw x25, 4(sp)
lw x27, 8(sp)

addi sp, sp, 12

jalr x0, 0(x1)

exit: