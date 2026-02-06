.text
.globl main
main:

li x10, 5  #n=5
li x11, 1 #factorial=1
li x5, 5

push_loop:
    beq x10, x0, pop_loop
    addi sp, sp, -4  #push in stack
    sw x10, 0(sp)  #store word in stack
    addi x10, x10, -1 #n=n-1
    j push_loop

pop_loop:
    beq x5, x0, end  #if stack is empty exit
    addi x5, x5, -1
    lw x12, 0(sp) #pop out of stack
    addi sp,sp, 4  #deallocate stack memory
    mul x11, x11 , x12  #x11=n*(n-1)
    bne sp, x0, pop_loop #if stack not empty pop

end:
    j end 

    