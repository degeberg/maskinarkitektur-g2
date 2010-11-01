# after execution, register bank should contain
#
# $1 = 0x1
# $2 = 0x2
# $3 = 0x3
# $4 = 0x1
# $5 = 0x2
# $6 = 0x2
# $31 != 0x0 (some instruction address)
#
# all other registers should be zero


#####
# simple test of j, jr, jal
# includes lots of nops to make sure errors do not occur from forwarding/stalling/flushing 
	j     l0
	nop
	addiu $30, $30, 0x1  # $30 != 0x0 (= fail)
l0:
	addiu $1, $0, 1
	nop
	nop
	nop
	nop
	jal   l1
	nop
	beq   $1, $0, l2
	nop
	nop
	addiu $29, $29, 0x1  # $29 != 0x0 (= fail)
l1:
	or $1, $0, $0
	nop
	nop
	nop
	nop
	jr    $ra
	nop
	nop
	addiu $28, $28, 0x1 # $28 != 0x0 (= fail)
l2:



#####
# test forwarding
	addiu $1, $0, 0x1      # $1 = 0x1
	addiu $2, $0, 0x2      # $2 = 0x2
	addu  $3, $1, $2       # $3 = 0x3
	subu  $4, $3, $2       # $4 = 0x1
	sw    $1, 0($0)
	lw    $5, 0($0)
	nop                    # nop to avoid stalling - we only want forwarding
	addu  $5, $5, $5       # $5 = 0x2



#####
# test stalling from lw data hazards
	lw    $6, 0($0)
	addu  $6, $6, $6       # $6 = 0x2



#####
# test flushing from mispredicted beq control hazards
	beq   $0, $0, l3
	nop
	nop
	addiu $27, $27, 0x1  # $27 != 0x0 (= fail)
l3:
	beq   $0, $0, l4
	nop
	addiu $27, $27, 0x1  # $27 != 0x0 (= fail)
l4:
	beq   $0, $0, l5
	addiu $27, $27, 0x1  # $27 != 0x0 (= fail)
l5:



#####
# test flushing from j control hazards
	j     l6
	nop
	addiu $26, $26, 0x1  # $26 != 0x0 (= fail)
l6:
	j     l7
	addiu $26, $26, 0x1  # $26 != 0x0 (= fail)
l7:



#####
# test flushing from jal control hazards
	jal   l8
	nop
	addiu $25, $25, 0x1  # $25 != 0x0 (= fail)
l8:
	jal   l9
	addiu $25, $25, 0x1  # $25 != 0x0 (= fail)
l9:



#####
# test flushing from jr control hazards
	jal   l10
	j     l11
l10:
	jr    $ra
	addiu $24, $24, 0x1  # $24 != 0x0 (= fail)
l11:

####
# test no forwarding of $0
	addu $0, $1, $1
	addu $7, $0, $0        # $7 = 0x0 (shouldn't be 0x4)


