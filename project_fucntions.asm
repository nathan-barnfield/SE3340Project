.data 
.align 0
userInput: .space 10
.align 0
compareString: .space 12
.align 2
seedJumpTable: 40000		#room for the offsets of 9 letter words in the wordlist. 9620 words * 4 bytes = 38480
.align 2
wordListAddr: .space 12		#1st word = new wordlist, 2nd word = FoundWordlist, 3rd word = FoundWordList pointer
.text

#################################################################
#function: find
# This Function assumes a word has been placed in userInput. The function compares the String to the strings placed in the new wordlist in the heap. It returns 1 in $v0 and places the word in the 
#Found words list (placed in the 2nd word of wordListAddr) if the word is found. If the word is not found, returns -1 in $v0
################################################################

find:		la $t1, wordListAddr
		lw $t2, 0($t1)			#store the address of the new wordlist
		la $t4, compareString
		
CompareLoop:	 lbu $t5, 0($t2)			##grab next words first character (stores it if not end of list)
		 beq $t5, 30, findFailure		##checks to see if the list has been completeley searched. If it has, branch to findFailure
		 sb $t5, 0($t4)
		 addi $t2, $t2, 1
		 addi $t4, $t4, 1
		 
copyToStringLoop:	lbu $t5, 0($t2)
			sb $t5, 0($t4)
			addi $t2, $t2, 1
			addi $t4, $t4, 1
			bne $t5, 10, copyToStringLoop		##keep looping until the new line character is reached
			sb $zero, -1($t4)			##null the carriage return and new line characters from the compare string
			sb $zero, -2($t4)
			la $t4, compareString			##reset $t4 to base compareString address
			la $t6, userInput			##reset/place address of user input into $t6
			
compareWordLoop:	lbu $t5, 0($t4)
			beqz $t5, findSuccess			##compare the input and compare strings. Keep checking each character until the null character is reached.
			addi $t4, $t4, 1			#increment compareString address	
			lbu $t7, 0($t6)
			addi $t6, $t6, 1
			bne $t7, $t5, CompareLoop		##branch to the start of the word comparision loop if the 2 characters do not match
			j compareWordLoop			##loop back to compare the next two characters in the string
			
		 
		 
		 
findFailure:		li $v0, -1
			jr $ra
		
findSuccess:		la $t4, compareString	
			lw $t2, 8($t1)				##laod the foundWordsList pointer from memory
copyToFoundWords:	lbu $t5, 0($t4)
			beqz $t5, finishCopyToFoundWords
			addi $t4, $t4, 1
			sb $t5, 0($t2)
			addi $t2, $t2, 1
			j copyToFoundWords
			
finishCopyToFoundWords:li $t5, 13
			sb $t5, 0($t2)				##add the carriage and new line characters onto the end of the string placed in FoundWords
			li $t5, 10
			sb $t5, 1($t2)
			addi $t2, $t2, 2
			sb $t2, 8($t1)				##store the updated foundwords pointerback into memeory
			la $t4, compareString
			la $t2, userInput
			
nullCompareString:	lbu $t5, 0($t4)
			beqz $t5, nullUserInput			##empty the compareString
			sb $zero, 0($t4)
			addi $t4, $t4, 1
			j nullCompareString
			
nullUserInput:		lbu $t5, 0($t2)
			beqz $t5, findEnd
			sb $zero, 0($t2)			##empty the userInput String
			addi $t2, $t2, 1
			j nullUserInput
						
findEnd:		li $v0, 1				##return successful
			jr $ra
				
		


################################################################
#Function: create_wordlist
#This function takes a random number as an argument and uses that to index into the presearched list of words. The words are then taken and placed into a seperate memory location
#that can be searched by the program. THis location will be located on the heap and will be allocated using srbk. This function places the wordlist address into wordListAddr for later retrieval
# $a0 = random #
################################################################


create_wordlist:
		move $t1, $a0				## move random number to $t1
		li $a0, 11000				## make room for 11k bytes
		li $v0, 9
		syscall
		la $t2, wordListAddr
		sw $v0, 0($t2)				## store the new wordlist address to wordListAddr for later retrieval
		move $t7, $v0
		
		
		li $a0, 11000				## make room for 11k bytes
		li $v0, 9
		syscall
		sw $v0, 4($t2)				## store the foundWords list address to wordListAddr for later retrieval
		sw $v0, 8($t2)				## store the foundWords list address to wordListAddr for pointer use and later retrieval
		
		sll $t1, $t1, 2 			## multiple the random number by 4 so that you can jump straight to the 9 letter word offset in the data file
		
		la $t3, seedJumpTable
		add $t3, $t3, $t1			## add the offset to the base address
		lw $t4, 0($t3)				## retrieve the 9 letter word offset and place it in $t4
		
		#add $t3, $zero, $zero			## initialize the wordlist point to keep track of where the function is in the wordlist array
		
copyLoop:	lbu $t1, 0($t4)				##retrieve and store character from the old wordlist into the new wordlist
		sb $t1, 0($t7)
		addi $t4, $t4, 1			##incremement both addresses by 1
		addi $t7, $t7, 1
		bne $t1, 30, copyLoop			##loop back if the character isnt the record seperator character(30)
		
		
		jr $ra					##return to caller
		
		

		

		
		
		
		
		
		
