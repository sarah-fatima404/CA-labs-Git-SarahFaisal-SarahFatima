.text
.globl main
main:

addi x20, x0, 4 #x
addi x21, x0, 2 #a
addi x22, x0, 3 #b
addi x23, x0, 4 #c

li x1, 1
li x2, 2
li x3, 3
li x4, 4

beq x20, x1, case1
beq x20, x2, case2
beq x20, x3, case3
beq x20, x4, case4
beq x0, x0, default


case1:
    add x21, x22, x23
    beq x0, x0, end
case2:
    sub x21, x22, x23
    beq x0, x0, end
case3:
    slli x21, x22, 1
    # add x21, x22, x22
    beq x0, x0, end
case4:
    srli x21, x22, 1
    beq x0, x0, end

default:
    li x21, 0
    beq x0, x0, end

end:
    j end 