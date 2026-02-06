    .text
    .globl main

main:
    li x10, 0x100 # base address a[]
    li x11, 4   #len=4     

    li x20, 1
    li x21, 2
    li x22, 3
    li x23, 4

    sw x20, 0(x10) #a[0]= 1
    sw x21, 4(x10) #a[1]= 2
    sw x22, 8(x10) #a[2]= 3
    sw x23, 12(x10) #a[3]= 4

    jal x1, sum_array    
    addi x12, x10, 0
exit:
    li x10, 10
    ecall

sum_array:
    addi sp, sp, -16
    sw x1, 12(sp) #return address
    sw x10, 8(sp) #base address
    sw x11, 4(sp) #length
    sw x6, 0(sp) #sum register

    addi x6, x0, 0 #sum=0
    addi x5, x0, 0 #i=0

sum_loop:
    bge x5, x11, sum_done

    slli x7, x5, 2  #i*4
    add x7, x7, x10
    lw x7, 0(x7)     #arr[i]

    addi x10, x6, 0 #x10=sum
    addi x11, x7, 0 #x11=arr[i]
    jal x1, add_func  

    addi x6, x10, 0  
    addi x5, x5, 1 #i++
    j sum_loop

sum_done:
    addi x10, x6, 0     

    lw x6, 0(sp)
    lw x1, 12(sp)
    addi sp, sp, 16
    jalr x0, x1, 0


add_func:
    add x10, x10, x11
    jalr x0, x1, 0
