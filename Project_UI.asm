.data
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
	jal startup
	
	
	
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
	jal wordCheck #Calls function to check word, stores if found (1) or not(0) in $a1
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

startup: #placeholder function until implementation
	la $s1, letterString
	la $s2, placeholder
	la $s3, fullWord
	li $s4, 0 #Counter
	copyDataLoop:  
   		lb $t0, ($s2) # get character at address  
   		beqz $t0, endCopy #end if reached the end
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
	endCopy:	
		la $a1, letterString
		jr $ra
wordCheck: #placeholder function
	li $a1, 1
	jr $ra

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
	
