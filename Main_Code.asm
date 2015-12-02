.data
#####################################################################
# .data declarations from Nathan's portion
fin: 			.asciiz				"compiledWordList4.txt"
fin1:			.asciiz 			"byteData5.dat"	
.align 0
completeWordList:	.space		3900000
.align 0
compareString: 		.space		12
.align 0
printString:		.space 		12
.align 2
seedJumpTable:		.space		40000		#room for the offsets of 9 letter words in the wordlist. 9620 words * 4 bytes = 38480
.align 2
wordListAddr: 		.space 		12		#1st word = new wordlist, 2nd word = FoundWordlist, 3rd word = FoundWordList pointer
####################################################################
nl: .asciiz "\n"
space: .asciiz "   "
greeting: .asciiz "Welcome to Lexathon! Wait while the game loads..."
countdownPrompt: .asciiz "Your game will start in 3 seconds.\n"
timerPrompt2: .asciiz " seconds\n"
timerPrompt: .asciiz "Time left: "
scorePrompt: .asciiz "Score: "
inputPrompt: .asciiz "Type in a word using these letters including the middle letter or type 1 to scramble letters and 2 to give up!\n"
goodWordPrompt: .asciiz "Valid Word!\n"
badWordPrompt: .asciiz "This word isn't valid!\n"
endTimePrompt: .asciiz "Sorry, you're out of time, "
endingPrompt: .asciiz "Game Over!\nYour score is "
fullWordPrompt: .asciiz "Your nine letter word was: "
userInput: .space 10
fullWord: .space 11
letterString: .space 9
middleLetter: .space 2
placeholder: .asciiz "jacobsuks"


.text
main:
	#Print Greeting
	la $a0, greeting
	li $v0, 4
	syscall
	
	#Call function to get pick word group & letters/middle letter
	li $a0, 3	##placeholder #. Need a random number to be entered here
	jal create_wordlist#startup
	
	
	
	#Make program sleep for 3 seconds for countdown
	la $a0, countdownPrompt
	li $v0, 4
	syscall
	
	li $a0, 3000 #load $a0 with 3 seconds
	li $v0, 32 #syscall to sleep
	syscall
	
	#Initialize register for time
	addi $s0, $s0, 60000 #$s0 holds the starting time at 60 seconds
	
	
	li $s4, 0 #$s4 holds score
	
	jal scramble#Call function to scramble order of letters and start timer
	
	#Actual game starts here
UI:	jal UIPrint #subroutine to print the UI
	la $a0, userInput #Get user input
	la $a1, 10 #max input is 9
	li $v0, 8
	syscall
	
	#Stop Time
	li $a0, 0
	li $v0, 30
	syscall
	sub $s0, $s0, $a0 #subtract to find how much time has passed, hold time
	li $t1, 0 #Quick timer check
	slt $t1, $t1, $s0 #end program if time runs out
	beqz $t1, timerEnd
	
	
	li $s1, 0 #Use $s1 to count letters in string to choose library
	li $s2, 0 #Use $s2 as a switch to check for middle letter
	la $s3, middleLetter #$s3 will hold middle letter
	lb $s3, ($s3)
	la $a0, userInput
counter: lb $t0, ($a0)
	beqz $t0, counterEnd
	beq $t0, 49, scramble #If user wants to reorder letters
	beq $t0, 50, end #End if user gives up
	bne $t0, $s3, notMiddle #skip if not middle letter
	li $s2, 1 #1 means middle letter is in user input
notMiddle: addi $a0, $a0, 1 #Increment pointer and counter
	addi $s1, $s1, 1
	j counter #loop
counterEnd:
	beqz $s2, badWord
	li $a1, 0
	addi $a1, $s1, 0 #load number of letters in argument to choose which file to check
	jal find #Calls function to check word, stores if found (1) or not(0) in $a1
	beqz $a1, badWord #If not found, bad word
	la $a0, goodWordPrompt #Else, print valid prompt and add points and seconds to timer
	li $v0, 4
	syscall
	#Score System
	li $t0, 0
	addi $t0, $s0, 100000
	mul $s4, $t0, $s1
	div $s4, $s4, 100
	
	addi $s0, $s0, 20000 #Add 20 seconds to the clock
	li $v0, 30
	syscall
	add $s0, $s0, $a0 #Resume time
	j UI #Loop
badWord: 
	la $a1, nl
	jal quickPrint
	la $a0, badWordPrompt
	li $v0, 4
	syscall
	li $v0, 30
	syscall
	add $s0, $s0, $a0 #Resume time
	j UI


scramble: #Where the letters will randomize in order
	
	li $v0, 30 #Resume time
	syscall
	add $s0, $s0, $a0 
	j UI #Loop
#subroutines to make coding quicker
quickPrint:  li $v0, 4
	     la $a0, ($a1)
	     syscall
	     jr $ra
UIPrint:
	andi $s1, $s1, 0 #clear $s1 and use it to hold ra
	addi $s1, $ra, 0 
	jal timeCheck
	li $v0, 4 #Print Score
	la $a0, scorePrompt
	syscall
	li $v0, 1
	li $a0, 0
	addi $a0, $s4, 0
	syscall
	li $v0, 4
	la $a0, nl
	syscall
	la $t0, letterString #start printing board with string
	la $t1, middleLetter #and middle letter
	li $v0, 11
	lb $a0, ($t0)
	syscall			#First letter
	addi $t0, $t0, 1
	la $a1, space
	jal quickPrint		#Space
	li $v0, 11
	lb $a0, ($t0)
	syscall			#Second Letter
	addi $t0, $t0, 1
	jal quickPrint		#Space
	li $v0, 11
	lb $a0, ($t0)
	syscall			#Third Letter
	addi $t0, $t0, 1
	la $a1, nl		
	jal quickPrint		#New Line
	li $v0, 11
	lb $a0, ($t0)
	syscall			#Fourth Letter
	addi $t0, $t0, 1
	la $a1, space
	jal quickPrint		#Space
	li $v0, 11
	lb $a0, ($t1)
	syscall			#Middle Letter
	jal quickPrint		#Space
	li $v0, 11
	lb $a0, ($t0)
	syscall			#Sixth letter
	addi $t0, $t0, 1
	la $a1, nl		#New Line
	jal quickPrint
	li $v0, 11
	lb $a0, ($t0)
	syscall			#Seventh letter
	addi $t0, $t0, 1
	la $a1, space		
	jal quickPrint		#Space
	li $v0, 11
	lb $a0, ($t0)
	syscall			#Eight letter
	addi $t0, $t0, 1
	jal quickPrint		#Space
	li $v0, 11
	lb $a0, ($t0)
	syscall			#Ninth Letter
	la $a1, nl
	jal quickPrint		#New Line
	li $v0, 4		#Print user input prompt
	la $a0, inputPrompt
	syscall
	jr $s1 #end print, return to UI
	

timeCheck:
	li $a0, 0
	li $v0, 30
	syscall
	sub $t0, $s0, $a0 #subtract to find how much time has passed
	div $t0, $t0, 1000 #change from milliseconds to seconds
	#li $t1, 0
	#slt $t1, $t1, $t0 #end program if time runs out
	#beqz $t1, end
	la $a0, timerPrompt #print timerPrompt and time/check time
	li $v0, 4
	syscall
	move $a0, $t0
	li $v0, 1 #print time
	syscall
	li $v0, 4
	la $a0, timerPrompt2
	syscall
	jr $ra

#startup: #placeholder function until implementation
#	la $s1, letterString
#	la $s2, placeholder
#	la $s3, fullWord
#	li $s4, 0 #Counter
#	copyDataLoop:  
#   		lb $t0, ($s2) # get character at address  
#  		beqz $t0, endCopy #end if reached the end
#  		beq $s4, 4, middle
#   		sb $t0, ($s1) # else store current character 
#   		sb $t0, ($s3)
#  		addi $s2, $s2, 1 #move pointers for strings and counter
#   		addi $s3, $s3, 1 #fullWord
#   		addi $s4, $s4, 1 #counter
#   		addi $s1, $s1, 1 #placeholder
#   		j copyDataLoop # loop 
#	middle: #ends and loads middle letter as well
#		la $s5, middleLetter
#		lb $t0, ($s2)
#		sb $t0, ($s5)
#		sb $t0, ($s3)
#		addi $s3, $s3, 1 #fullWord
#		addi $s2, $s2, 1 #placeHolder
#		addi $s4, $s4, 1
#		j copyDataLoop
#	endCopy:	
#		la $a1, letterString
#		jr $ra
#wordCheck: #placeholder function
#	li $a1, 1
#	jr $ra

timerEnd:
	la $a0, endTimePrompt
	li $v0, 4
	syscall
end:
	la $a0, endingPrompt
	li $v0, 4
	syscall
	li $a0, 1
	addi $a0, $s4, 0
	li $v0, 1
	syscall
	la $a0, nl
	li $v0, 4
	syscall
	la $a0, fullWordPrompt
	syscall
	la $a0, fullWord
	syscall
	
#############################################################################################################
# FileInput code for inputing the byteCode data(9 letter indexs) and the wordlist
#############################################################################################################
fileInput:	li   $v0, 13       # system call for open file
		la   $a0, fin      # board file name
		li   $a1, 0        # Open for reading
		li   $a2, 0
		syscall            # open a file (file descriptor returned in $v0)
		move $s6, $v0      # save the file descriptor 

		#read from file
		li   $v0, 14       # system call for read from file
		move $a0, $s6      # file descriptor 
		la   $a1, completeWordList     # address of buffer to which to read
		li   $a2, 3900000   # hardcoded buffer length
		syscall            # read from file

		# Close the file 
		li   $v0, 16       # system call for close file
		move $a0, $s6      # file descriptor to close
		syscall            # close file

##############################################################################################
		li   $v0, 13       # system call for open file
		la   $a0, fin1      # board file name
		li   $a1, 0        # Open for reading
		li   $a2, 0
		syscall            # open a file (file descriptor returned in $v0)				
		move $s6, $v0      # save the file descriptor 

		#read from file
		li   $v0, 14       # system call for read from file
		move $a0, $s6      # file descriptor 
		la   $a1, seedJumpTable     # address of buffer to which to read
		li   $a2, 40000     # hardcoded buffer length
		syscall            # read from file

		# Close the file 
		li   $v0, 16       # system call for close file
		move $a0, $s6      # file descriptor to close
		syscall            # close file
		jr $ra
#############################################################################################
#Program Functions
#############################################################################################
##############################################################################################################################################
#function: find
# This Function assumes a word has been placed in userInput. The function compares the String to the strings placed in the new wordlist in the heap. It returns 1 in $v0 and places the word in the 
#Found words list (placed in the 2nd word of wordListAddr) if the word is found. If the word is not found, returns -1 in $v0
##############################################################################################################################################

find:		la $t1, wordListAddr
		lw $t2, 0($t1)			#store the address of the new wordlist
		la $t4, compareString
		la $t3, userInput
		add $t9, $zero, $zero
		
stringLenLoop:	lbu $t5, 0($t3)
		beqz $t5, compareLoop
		addi $t3, $t3, 1			##this loop finds the # of letters in the userInputString
		addi $t9, $t9, 1
		
		j stringLenLoop
		
compareLoop:	

		la $t4, compareString
		lbu $t5, 0($t4)
		beqz $t5, startCompare			##empty the compareString
		sb $zero, 0($t4)
		addi $t4, $t4, 1
		add $t8, $zero, $zero			##sets the compareString counter to 0
		j compareLoop
		
startCompare:	 la $t4, compareString			#load base compareString address
		 lbu $t5, 0($t2)			##grab next words first character (stores it if not end of list)
		 beq $t5, 30, findFailure		##checks to see if the list has been completeley searched. If it has, branch to findFailure
		 sb $t5, 0($t4)
		 addi $t2, $t2, 1
		 addi $t4, $t4, 1
		 addi $t8, $t8, 1			##adds 1 to the compar string letter count
		 
copyToStringLoop:	lbu $t5, 0($t2)
			sb $t5, 0($t4)
			addi $t2, $t2, 1
			addi $t4, $t4, 1
			addi $t8, $t8, 1			##add 1 to the letter count of the compare string
			bne $t5, 10, copyToStringLoop		##keep looping until the new line character is reached
			addi $t8, $t8, -2
			
			
			bne $t8, $t9, compareLoop		##check if the words have the same amount of letters. If they don't, move on to the next word
			
			sb $zero, -1($t4)			##null the carriage return and new line characters from the compare string
			sb $zero, -2($t4)
			la $t4, compareString			##reset $t4 to base compareString address
			la $t6, userInput			##reset/place address of user input into $t6
			
compareWordLoop:	lbu $t5, 0($t4)
			beqz $t5, findSuccess			##compare the input and compare strings. Keep checking each character until the null character is reached.
			addi $t4, $t4, 1			#increment compareString address	
			lbu $t7, 0($t6)
			addi $t6, $t6, 1
			bne $t7, $t5, compareLoop		##branch to the start of the word comparision loop if the 2 characters do not match
			j compareWordLoop			##loop back to compare the next two characters in the string
			
		 
		 
		 
findFailure:		add $a1, $zero, $zero			#indicate that the word was not found
			jr $ra
		
findSuccess:		la $t4, compareString	
			lw $t2, 8($t1)				##laod the foundWordsList pointer from memory
copyToFoundWords:	lbu $t5, 0($t4)
			beqz $t5, finishCopyToFoundWords
			addi $t4, $t4, 1
			sb $t5, 0($t2)
			addi $t2, $t2, 1
			j copyToFoundWords
			
finishCopyToFoundWords: li $t5, 13
			sb $t5, 0($t2)				##add the carriage and new line characters onto the end of the string placed in FoundWords
			li $t5, 10
			sb $t5, 1($t2)
			addi $t2, $t2, 2
			sw $t2, 8($t1)				##store the updated foundwords pointerback into memeory
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
				
		


##########################################################################################################################################
#Function: create_wordlist
#This function takes a random number as an argument and uses that to index into the presearched list of words. The words are then taken and placed into a seperate memory location
#that can be searched by the program. This location will be located on the heap and will be allocated using srbk. This function places the wordlist address into wordListAddr for later retrieval
# $a0 = random #
##########################################################################################################################################


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
		
		add $t3, $zero, $zero
		
nullFoundWordsLoop:	sb $zero, 0($v0)
			addi $v0, $v0, 1		#null the whole memory section
			addi $t3, $t3, 1
			bne $t3, 10999, nullFoundWordsLoop
		
		sll $t1, $t1, 2 			## multiple the random number by 4 so that you can jump straight to the 9 letter word offset in the data file
		
		la $t3, seedJumpTable
		add $t3, $t3, $t1			## add the offset to the base address
		lw $t4, 0($t3)				## retrieve the 9 letter word offset and place it in $t4
		la $t3, completeWordList
		add $t4, $t3, $t4			##store the address of the 9 letter word list to be retrieved in $t4
		
		
copyLoop:	lbu $t1, 0($t4)				##retrieve and store character from the old wordlist into the new wordlist
		sb $t1, 0($t7)
		addi $t4, $t4, 1			##incremement both addresses by 1
		addi $t7, $t7, 1
		bne $t1, 30, copyLoop			##loop back if the character isnt the record seperator character(30)
		
########################################################
##Code taken from Jacobs startup function
########################################################		
	la $s1, letterString
	lw $s2, 0($t2)					##retrieve the address of the new wordlist
	la $s3, fullWord
	li $s4, 0 #Counter
	copyDataLoop:  
   		lb $t0, ($s2) # get character at address  
   		beq $t0, 13, endCreateWordList #end if reached the end
   		beq $s4, 4, middle
   		sb $t0, ($s1) # else store current character 
   		sb $t0, ($s3)
   		addi $s2, $s2, 1 #move pointers for strings and counter
   		addi $s3, $s3, 1 #fullWord
   		addi $s4, $s4, 1 #counter
   		addi $s1, $s1, 1 #placeholder
   		j copyDataLoop # loop 
	middle: #ends and loads middle letter as well
		la $s5, middleLetter
		lb $t0, ($s2)
		sb $t0, ($s5)
		sb $t0, ($s3)
		addi $s3, $s3, 1 #fullWord
		addi $s2, $s2, 1 #placeHolder
		addi $s4, $s4, 1
		j copyDataLoop
		
endCreateWordList:	la $a1, letterString
			jr $ra					##return to caller
		
##############################################################################################################################################
#Function: Print_found_words
#This function will print all the found words that are located in the found words memory location.
#Does not take any arguments and does not pass any values back.
##############################################################################################################################################
print_found_words:	la $t1, wordListAddr			#load the address of the array holding the found words base address
			la $t3, printString			#load the address of the string we are going to use to print the words with
			lw $t1, 4($t1)				#load the base address of the found words list from the wordListAddr array
			
printLoop:		lbu $t2, 0($t1)				#load the next character in the foudn words list
			beqz $t2, finishPrint			#if null, the list is complete and jump to the finish portion of this function
			sb $t2, 0($t3)				#store the character into the 
			addi $t1, $t1, 1
			addi $t3, $t3, 1			#increment the printString and foundWordsList addresses
			bne $t2, 10, printLoop			#keep looping until you hit a new line char(end of word)
			
			la $a0, printString			#print the String to the console
			li $v0, 4
			syscall
			
			la $t3 printString			#reload the base address of the print string so that it can be emptied
			
			
nullPrintString:	lbu $t5, 0($t3)
			beqz $t5, nullPrintEnd
			sb $zero, 0($t3)			##empty the userInput String
			addi $t3, $t3, 1
			j nullPrintString
nullPrintEnd:		la $t3, printString
			j printLoop				#jump back to beginning of the function so that the next word can be printed	
			
			

			
finishPrint:	jr $ra						#jump back to the caller
			
##############################################################################################################################################	
