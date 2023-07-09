.data
ADDR:	.word	0x2004#起始地址，存放数组大小，后面存放数组数据，升序原位排序

.text
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
	beq t1, t3, ENDD#i from 1 to n-1 
	blt t3, t1, ENDD
	lw t4, 0(t1)#a[i]
	lw t5, 0(t2)#a[j]
	bltu t4, t5, RIGHT#Don't need to swap
	li t6, 1
RIGHT:
	addi t1, t1, 4#i=i+1
	addi t2, t2, 4#j=j+1
	jal LOOPT
ENDD:
	jal ENDD
	
	
