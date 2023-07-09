.data
stre:	.string "ERROR"
strr:   .string "RIGHT"
ADDR1:  .word    0x0020
ADDR2:  .word    0x4070
DATA1:  .word    0x00008234
DATA2:  .word    0xffff8234
#add, addi, sub, auipc, lui
#and, or, xor
#slli, srli, srai
#lw, sw
#beq, blt, bltu, jal, jalr
.text
	#test beq
	beq zero, zero, BEQ
	
	
	
	li t6, 1
	#test jal
BEQ:	
	jal ra, JAL
	
	
	
	li t6, 2
JAL:	
	li t0, 0x000c 
	beq ra, t0 ,JAL2
	
	
	
	li t6, 2
JAL2:   	
	#test jalr
	jalr ra, zero, 0x0024
	
	
	
	li t6, 3
	li t0, 0x0020
	beq ra, t0, JALR
	
	
	
	li t6, 3
JALR:
	#test bltu
	li t0, 0xffffffff
	bltu zero, t0, BLTU
	
	
	
	li t6, 4
BLTU:	
	#test blt
	blt t0, zero, BLT
	
	
	
	li t6, 5
BLT:
	#test lw
	li t1, 0x0020
	lw t0, ADDR1
	beq t1, t0, LW
	
	
	
	li t6, 6
LW:
	#test sw
	sw t0, 0(sp)
	lw t1, 0(sp)
	beq t0, t1, SW
	
	
	
	li t6, 7
SW:
	#test auipc
	lw t1, ADDR2
	auipc t0, 0x4
	beq t1, t0, AUIPC
	
	
	
	li t6, 8
AUIPC:
	#test addi
	addi t0, ra, -0x20
	
	
	
	beq t0, zero, ADDI
	
	
	
	li t6, 9
ADDI:
	#test lui
	li t1, 0x4000
	lui t0, 0x4
	beq t0, t1, LUI
	li t6, 10
LUI:
	#test add
	li t0, 1
	li t1, 2
	li t3, 3
	add t2, t0, t1
	beq t2, t3, ADD
	li t6, 11
ADD:
	#test sub
	li t3, -1
	sub t2, t0, t1
	beq t2, t3, SUB
	li t6, 12
SUB:
	#test and
	li t0, 0x5
	li t1, 0xf
	and t2, t1, t0
	beq t2, t0, AND
	li t6, 13
AND:
	#test or
	or t2, t1, t0
	beq t2, t1, OR
	li t6, 14
OR:
	#test xor
	li  t3, 0xa
	xor t2, t1, t0
	beq t2, t3, XOR
	li t6, 15
XOR:
	#test slli
	li t0, 0x4
	li t1, 0x40
	slli t0, t0, 4
	beq t0, t1, SLLI
	li t6, 16
SLLI:
	#test srli
	lw t0, DATA1
	lw t1, DATA2
	slli t2, t0, 16
	srli t3, t2, 16
	beq t3, t0, SRLI
	li t6, 17
SRLI:   
        #test srai
        srai t3, t2, 16
        beq t3, t1, RIGHT
        li t6, 18
RIGHT:
	#the end
	jal RIGHT
