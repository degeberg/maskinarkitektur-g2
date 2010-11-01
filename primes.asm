init:
    ori     $sp, $zero, 0               # initialize stack to  the whole
                                        # memory. When you push something
                                        # to the stack it will be put at
                                        # the largest possible address).

    jal     main                        # call main
init_loop:
    j       init_loop                   # infinite loop

mul:
    ori     $v0, $zero, 0               # res = 0
mul_loop_init:
    slt     $a2, $zero, $a0             # b > 0?
    beq     $a2, $zero, mul_exit        # if(b > 0) goto mul_exit
mul_loop:
    addu    $v0, $v0, $a0               # res += a
    addiu   $a1, $a1, -1                # b--
    bne     $a1, $zero, mul_loop        # if(b != 0) goto mul_loop
mul_exit:
    jr      $ra                         # return

largest_prime:
# int largest_prime(int n)
# Finds largest prime less than n using the Sieve of Eratosthenes
    addiu   $sp, $sp, -16               # make room to save 4 32-bit words
    sw      $s2, 12($sp)                # save $s2 on stack, $s2 = p
    sw      $s1, 8($sp)                 # save $s1 on stack, $s1 = i
    sw      $s0, 4($sp)                 # save $s0 on stack, $s0 = n
    sw      $ra, 0($sp)                 # save return address
    ori     $s0, $a0, 0                 # save n in $s0

    addu    $t0, $s0, $s0               # adjust stack pointer to
    addu    $t0, $t0, $t0               # make room for primes array
    subu    $sp, $sp, $t0               
                                        

    slti    $t0, $s0, 3                 # n <= 2?
    bne     $t0, $zero, lp_return_zero  # if(n <= 2) return 0

# Loop 1, set primes[i] = i, for 2 <= i < n
    ori     $s1, $zero, 2               # i = 2
lp_loop1:
    addu    $t0, $s1, $s1               # Address for primes[i]
    addu    $t0, $t0, $t0               # Address for primes[i]
    addu    $t0, $t0, $sp               # Address for primes[i]
    sw      $s1, 0($t0)                 # primes[i] = i
    addiu   $s1, $s1, 1                 # i += 1
    bne     $s0, $s1, lp_loop1          # if(n != 0) goto lp_loop1

# Loop 2, goes through array, looking for primes p.
# When it finds them, marks multiplications of p as not-prime
    ori     $s2, $zero, 1               # Start at p=2 (increased in a sec)
lp_loop2:
    addiu   $s2, $s2, 1                 # p++
    ori     $a0, $s2, 0                 # set param, p
    ori     $a1, $s2, 0                 # set param, p
    jal     mul                         # call mul(p,p)
    slt     $t0, $v0, $s0               # mul(p,p) < n
    beq     $t0, $zero, lp_loop2_end    # if(mul(p,p) < n) exit loop 2

    addu    $t0, $s2, $s2               # Address for primes[p]
    addu    $t0, $t0, $t0               # Address for primes[p]
    addu    $t0, $t0, $sp               # Address for primes[p]
    lw      $t0, 0($t0)                 # Load primes[p]
    ori     $s1, $zero, 2               # i = 2, is here to avoid blocking
    beq     $t0, $zero, lp_loop2        # primes[0] == 0, loop again
lp_loop2_1:
    ori     $a0, $s1, 0                 # set param, i
    ori     $a1, $s2, 0                 # set param, p
    jal     mul                         # call idx = mul(i,p)
    slt     $t0, $v0, $s0               # idx < n?
    beq     $t0, $zero, lp_loop2        # if (idx>=n) exit inner loop
    addu    $t0, $v0, $v0               # Address for primes[idx]
    addu    $t0, $t0, $t0               # Address for primes[idx]
    addu    $t0, $t0, $sp               # Address for primes[idx]
    sw      $zero, 0($t0)               # primes[idx] = 0
    addiu   $s1, $s1, 1                 # i++
    j       lp_loop2_1                  # inner loop
lp_loop2_end:

# Loop 3 starts at primes[n-1] and continues down until a prime is found
    addiu   $s1, $s0, -1                # i = n-1
lp_loop3:
    slti    $t0, $s1, 2                 # i < 2?
    bne     $t0, $zero, lp_return_zero  # if(i < 2) return 0     
    addu    $t0, $s1, $s1               # Address for primes[i]
    addu    $t0, $t0, $t0               # Address for primes[i]
    addu    $t0, $t0, $sp               # Address for primes[i]
    lw      $t0, 0($t0)                 # Load primes[i]
    addiu   $s1, $s1, -1                # i--
    beq     $t0, $zero, lp_loop3        # if (!primes[i]) loop again
    
lp_loop3_break:
    addiu   $v0, $s1, 1                 # ret=i+1 (i was decreased
                                        # while loading from memory)
    j largest_prime_exit
lp_return_zero:
    ori     $v0, $zero, 0               # ret = 0
largest_prime_exit:

    addu    $t0, $s0, $s0               # Remove primes array
    addu    $t0, $t0, $t0
    addu    $sp, $sp, $t0

    lw      $ra, 0($sp)                 # Restore $ra
    lw      $s0, 4($sp)                 # Restore $s0
    lw      $s1, 8($sp)                 # Restore $s1
    lw      $s2, 12($sp)                # Restore $s2
    addiu   $sp, $sp, 16                # restore stack pointer
    jr      $ra                         # return to caller
    
main:
    addiu   $sp, $sp, -4                # make room to save 1 32-bit word
    sw      $ra, 0($sp)                 # Save return address

    ori     $a0, $zero, 28              # set n = 28
    jal largest_prime                   # call largest_prime(n)
        
    lw      $ra, 0($sp)                 # restore return address
    addiu   $sp, $sp, 1                 # restore stack
    jr      $ra 

