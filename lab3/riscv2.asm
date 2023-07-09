.data
addr0: .word 0x2000
addr1: .word 0x2010

.text
lw t0, addr0
lw t1, addr1
lw t2, 0(t0)
lw t2, 0(t0)
li t3, 1
sw t3, 0(t0)
lw t2, 0(t1)
lw t2, 0(t0)
lw t2, 0(t1)
sw t3, 0(t0)
lw t2, 0(t0)


