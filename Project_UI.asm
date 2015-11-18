.data
space: .asciiz "   "
greeting: .asciiz "Welcome to Lexathon! Wait while the game loads..."
countdownPrompt: .asciiz "Your game will start in 3 seconds.\n"
countdownPrompt2: .asciiz " seconds\n"
timerPrompt: .asciiz "         Time left: "
userInput: .space 9
letterString: .space 9
placeholder: .asciiz "jacocama"
middleholder: .asciiz "b"

.text
main:
	#Print Greeting
	la $a0, greeting
	li $v0, 4
	syscall
	
	#Call function to get pick word group & letters/middle letter
	jal startup
	
	#Call function to scramble order of letters
	
	#Make program sleep for 3 seconds for countdown
	la $a0, countdownPrompt
	li $v0, 4
	syscall
	
	li $a0, 3000 #load $a0 with 3 seconds
	li $v0, 32 #syscall to sleep
	syscall
	
	#Initialize register for time
	addi $s0, $s0, 60000 #$s0 holds the starting time at 60 seconds
	
	#Start timer
	andi $a0, $a0, 0 #clear $a0
	li $v0, 30 #call for system time again
	syscall
	add $s0, $s0, $a0 #add system time to initial time (this is when the 'timer' starts)
	
	#Actual game starts here
UI:	jal UIPrint #subroutine to print the UI
	la $a0, userInput
	li $v0, 8
	syscall

#subroutines to make coding quicker
quickPrint:  li $v0, 4
	     la $a0, ($a1)
	     syscall
	     jr $ra
UIPrint:
	andi $s1, $s1, 0 #clear $s1 and use it to hold ra
	addi $s1, $ra, 0 
	la $a0, timerPrompt #print timerPrompt and time/check time
	li $v0, 4
	syscall
	jal timeCheck
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
	jr $s1 #end print, return to UI
	

timeCheck:
	andi $a0, $a0, 0
	li $v0, 30
	syscall
	sub $a0, $s0, $a0 #subtract to find how much time has passed
	div $a0, $a0, 1000 #change from milliseconds to seconds
	beqz $a0, end #end program if time runs out
	li $v0, 1 #print time
	syscall
	li $v0, 4
	la $a0, countdownPrompt2
	syscall
	jr $ra

startup: #placeholder function until implementation
	la $s1, letterString
	la $s2, placeholder
	li $s3, 0
	copyDataLoop:  
   		lb $t0, ($s2) # get character at address  
   		beq $s3, 8, endCopy #end if reached the end
   		sb $t0, ($s1) # else store current character 
   		addi $s2, $s2, 1 #move pointers for both strings
   		addi $s1, $s1, 1 
   		addi $s3, $s3, 1               
   		li $v0, 4
   		la $a0, letterString
   		j copyDataLoop # loop 
	endCopy: #ends and loads middle letter as well
		la $s1, middleLetter
		la $s2, middleholder
		lb $t0, ($s2)
		sb $t0, ($s1)
		jr $ra
end:
	
