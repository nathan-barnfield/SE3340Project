scramble: #Where the letters will randomize in order
	la $t6, letterString
	la $t0, Seed	#load seed's address
	lw $t1, ($t0)	#loads seed into registry
	la $t0, SeedCounter	#loads seed counter
	lw $t2, ($t0)	#loads seed counter into registry
	addi $t2, $t2, 1 #updates counter scrambler
	sw $t2, ($t0)
	smodl1: #modular algorithm, divides based on counter
	divu $t1, $t1, 9
	subi $t2, $t2, 1
	blt $t2, $zero, breakmodl
	mfhi $t3
	mul $t1, $t1, $t3
	j smodl1
	breakmodl:
	mfhi $t4
	la $t0, middleLetter #sets middle letter
	add $t4, $t6, $t4
	sb $t0, ($t4)
	add $t2, $zero, 8
	add $t3, $zero, 8
	addi $t5, $zero, 1
	smodl2:
	beq $t3, $t2 midjump #swaps letters randomly
	beq $t4,$t2, midjump
	divu $t1, $t1, 3
	mfhi $t4
	bgt $t4, $t5, swap
	swap:
		add $t7, $t6, $t3
		add $t8, $t6, $t2
		lb $t9, ($t7)
		sb $t8, ($t7)
		sb $t8, ($t9)
	midjump:
	subi $t2, $t2, 1
	blt $t2, $zero, breakmod2nested
	j smodl2
	breakmod2nested:
	mul $t1, $t1, 20000
	subi $t3, $t3, 1
	blt $t3, $zero, breakmod2
	j smodl2
	breakmod2:
	lw $ra, ($sp)
	li $v0, 30 #Resume time
	syscall
	add $s0, $s0, $a0 
	j UI #Loop
SeedGenerator:  #save registries not in use, okay to use
			subi $sp,$sp, -4
			sw $ra, 0($sp)
			j gets
	random:
		move $a0, $zero
		li $a1, 1841 #upper limit of random number
		li $v0, 42   #random
		syscall
		sll $t0, $a0, 9 #multiplies 1841 by 9, the size of 8 bytes plus \n
		jr $ra
	gets:
		la $23, completeWordList      #set base address of Seeds to s3
		la $s1, SeedBuffer
		jal random
		add $s3, $s3, $a0
	l1:	#loops til; beginning of integer
		lb $t0, 0($s3)        #load the char from Seeds into t0
		lb $t1, newLine     #load newline char into t1
		beq $t0, $t1, l2 
		addi $s3, $s3, 1    #increments base address of Seeds
		j l1
	l2:           #start of read loop
		addi $s3, $s3, 1
		lb $t0, 0($s3)      #Loads first character from Seeds
		sb $t0, 0($s1)      #store the char into the seed
		lb $t1, newLine     #load newline char into t1
		beq $t0, $t1, done  #end of string
		addi $s1, $s1, 1    #increments base address of array
		j l2          #jump to start of l2

	done:           #let s2 be the sum total
		addi $s1, $s1, -1   #reposition array pointer to last char before newline char
		la $s0, SeedBuffer       #set base address of array to s0 for use as counter
		addi $s0, $s0, -1   #reposition base array to read leftmost char in string
		add $s2, $zero, $zero   #initialize sum to 0
		li $t0, 10      #set t0 to be 10, used for decimal conversion
		li $t3, 1
		lb $t1, 0($s1)      #load char from array into t1
		blt $t1, 48, error  #check if char is not a digit (ascii<'0')
		bgt $t1, 57, error  #check if char is not a digit (ascii>'9')
		addi $t1, $t1, -48  #converts t1's ascii value to dec value
		add $s2, $s2, $t1   #add dec value of t1 to sumtotal
		addi $s1, $s1, -1   #decrement array address
	lp:         #loop for all digits preceeding the LSB
		mul $t3, $t3, $t0   #multiply power by 10
		beq $s1, $s0, SGend   #exit if beginning of string is reached
		lb $t1, ($s1)       #load char from array into t1
		blt $t1, 48, error  #check if char is not a digit (ascii<'0')
		bgt $t1, 57, error  #check if char is not a digit (ascii>'9')
		addi $t1, $t1, -48  #converts t1's ascii value to dec value
		mul $t1, $t1, $t3   #t1*10^(counter)
		add $s2, $s2, $t1   #sumtotal=sumtotal+t1
		addi $s1, $s1, -1   #decrement array address
		j lp            #jump to start of loop

	error:          #if non digit chars are entered, readInt returns 0
		add $s2, $zero, $zero
		j SGend

	SGend:
		li $v0, 4
		la $a0, seedPrompt #prompt for seed number
		syscall
		li $v0, 1
		add $a0, $s2, $zero
		syscall 
		la $t0, Seed
		sw $s0, 0($t0)
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra
RandomNumber:	#random number method
		subi $sp,$sp, -4
		sw $ra, 0($sp)
		la $t0, Seed
		lw $t1, ($t0)
		la $t0, SeedCounter
		lw $t2, ($t0)
		la $t3, Rand
		rl: #modular algorithm, divides based on counter
		divu $t1, $t1, 9620
		subi $t2, $t2, 1
		blt $t2, $zero, breakrl
		mfhi $t4
		mul $t1, $t1, $t4
		j rl
		breakrl:
		mfhi $t4
		sw $t4, ($t3)
		addi $sp, $sp, 4
		jr $ra
