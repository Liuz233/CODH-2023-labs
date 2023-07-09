.data
ADDR:	.word	0x2004#起始地址，存放数组大小，后面存放数组数据，升序原位排序

.text
	li a0, 1
	li a1, 0x7f00
	sw a0, 0(a1)
REQ1: 
	lw a0, 16(a1)
	beq a0, zero, REQ1
	lw t0, 20(a1)
	li a0, 2
	sw a0, 0(a1)
REQ2:
	lw a0, 16(a1)
	beq a0, zero, REQ2
	lw t1, 20(a1)	
	lw s9, 24(a1)
	#la a0, x
	#lw t0, 0(a0)
	#lw t1, 4(a0)
	#li t0, 10
	#li t1, 369258147
	lw t2, ADDR
	sw t0, 0(t2)
	mv s0, t0
	mv s1, t1
	li a1, 1
	li t2, 0x2008
loop:
	mv s2, s1
	and s3, s2, a1
	srli s2, s2,10
	and s4, s2, a1
	xor s3,s3,s4
	srli s2,s2,20
	and s4,s2, a1
	xor s3,s3,s4
	srli s2,s2,1
	and s4,s2,a1
	xor s3,s3,s4
	slli s3,s3,31
	srli s1,s1,1
	add s1,s3,s1
	sw s1, 0(t2)
	addi t2, t2, 4
	addi s0, s0, -1
	blt x0, s0, loop

	lw t0, ADDR
	lw t0, 0(t0)#size
	lw t1, ADDR#pointer i
	lw t2, ADDR#pointer j
	li t3, 4
	slli t3, t0, 2
	add t3, t1, t3#end 
	addi t1, t1, 4
	addi t2, t2, 4
LOOPI:	
	beq t1, t3, END#i from 1 to n-1 
	blt t3, t1, END
	addi t2, t1, 4#j=i+1
LOOPJ:
	blt t3, t2, ENDJ#j from i+1 to n
	lw t4, 0(t1)#a[i]
	lw t5, 0(t2)#a[j]
	bltu t4, t5, NEXT#Don't need to swap
	sw t5, 0(t1)#a'[i]=a[j]
	sw t4, 0(t2)#a'[j]=a[i]
NEXT:
	addi t2, t2, 4#j=j+1
	jal LOOPJ
ENDJ:
	addi t1, t1, 4
	jal LOOPI
	
END:
	#the end
	lw t0, ADDR
	lw t0, 0(t0)#size
	lw t1, ADDR#pointer i
	lw t2, ADDR#pointer j
	li t3, 4
	slli t3, t0, 2
	add t3, t1, t3#end 
	addi t1, t1, 4
	addi t2, t2, 8
LOOPT:	
	beq t1, t3, MMIO#i from 1 to n-1 
	blt t3, t1, MMIO
	lw t4, 0(t1)#a[i]
	lw t5, 0(t2)#a[j]
	bltu t4, t5, RIGHT#Don't need to swap
	li t6, 1
RIGHT:
	addi t1, t1, 4#i=i+1
	addi t2, t2, 4#j=j+1
	jal LOOPT
	#mmio count->register->seg
MMIO:
	li a1, 0x7f00
	lw t0, 24(a1)
	sub t0, t0, s9
REQ3:	
	lw t1, 8(a1)
	beq t1, zero, REQ3
	sw t0, 12(a1)
ENDD:
	jal ENDD
	
	
