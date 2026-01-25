.text
.globl main
main:
li x10,10
li x22, 0  #i
li x23, 0 #sum
li x11, 0x200 #array declaration 
Loop:
    slli x12, x22,2   # x12= i*4
    add x12, x11, x12 # x12= base + offset
    sw x22, 0(x12)  #a[i]=i
    addi x22, x22, 1 #i++
    bne x10, x22, Loop 

li x22,0 #i=0
Loop2:
    slli x12, x22,2   # x12= i*4
    add x12, x11, x12 # x12= base + offset
    lw x5, 0(x12)     # x5 the loads value temporarily
    add x23, x5, x23  # x23=sum + a[i]
    addi x22, x22, 1  #i++
    bne x10, x22, Loop2 

end:
    j end 
    



