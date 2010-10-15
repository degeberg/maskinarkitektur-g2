main:
    addiu $a0, $zero, 28      # set n = 28
    jal largest_prime         # call largest_prime(n)
    j exit                    # exit program

mul:
    addiu $v0, $zero, 0             # res = 0
mul_loop:
    beq $a1, $zero, mul_exit        # exit loop if b == 0
    addu $v0, $v0, $a0              # res += a
    subiu $a1, $a1, 1               # b -= 1
    j mul_loop                      # restart loop
mul_exit:
    jr $ra                          # return to caller

largest_prime:
    addiu $s1, $sp, 0               # save stack pointer
    sll $t2, $a0, 2                 # calculate required memory on the stack (n*4)
    subu $sp, $sp, $a0              # adjust stack pointer to make room for primes array
    addiu $t1, $zero, 2             # set i = 2
    addiu $s0, $a0, 0               # store n
lp_loop1:                           # init array
    sll $t2, $t1, 2                 # get array offset (i * 4)
    sw $t1, 0($t2)                  # primes[i] = i
    addiu $t1, $t1, 1               # i += 1
    bne $t1, $a0, lp_loop1          # restart loop if i != n
    # loop1 done...
    addiu $t1, $zero, 2             # set p = 2
lp_loop2:                           # filter non-prime numbers
    addu $a0, $t1, $zero            # set param, p
    addu $a1, $t1, $zero            # set param, p
    jal mul                         # call mul(p,p)
    slt $t5, $v0, $s0               # mul(p,p) < n
    beq $t5, $zero, lp_loop2_end    # loop ends
    sll $t2, $t1, 2                 # get array offset
    bne $t1, $zero, lp_loop2
    addiu $t3, $zero, 2             # i = 2
lp_loop2_1:
    addu $a0, $t3, $zero            # set param, i
    addu $a1, $t1, $zero            # set param, p
    jal mul                         # call mul(i,p)
    addiu $t4, $v0, 0               # store idx = mul(i,p)
    slt $t5, $t4, $s0               # check (idx < n) == !(idx >= n)
    bne $t5, $zero, lp_loop2_end    # if (idx>=n) break
    sw $zero, 0($t4)                # primes[idx] = 0
    addiu $t3, $t3, 1               # i++
    j lp_loop2_1                    # restart while loop
lp_loop2_end:
    subiu $t1, $s0, 1               # i = n-1
lp_loop3:
    slti $t2, $t1, 2                # i < 2
    bne $t2, $zero, lp_loop3_end
    slti $t3, $t2, 2
    lw $t4, 0($t3)
    beq $t4, $zero, lp_loop3_break  # if (!primes[i]) return
    subiu $t1, $t1, 1               # i--
lp_loop3_end:
    addiu $v0, $zero, 0             # ret = 0
    j largest_prime_exit
lp_loop3_break:
    addu $v0, $zero, $t1            # ret = i
largest_prime_exit:
    addiu $sp, $s1, 0               # restore stack pointer
    jr $ra                          # return to caller
    
exit:

