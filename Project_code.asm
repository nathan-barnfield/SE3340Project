#testing and experimenting. Thinking of making a jump table containing the offset of all the 9 letter words. The 9 letter words will have the words that can be matched with thier
#letters directly after it with a RS(30 in decimal)(record seperator) signifying the end of the record. the program will choose a random #, use that number in the jumptable to jump 
#to the address of the 9 letter word and will use that word and its subsequent matches to make a seperate wordlist that will be used for the actual game.
.data
fin: 		.asciiz 	"compiledWordList2.txt"		#filename for input
fin1: 		.asciiz 	"byteData3.dat"
		.align 		0
wordList: 	.space 		3900000
		.align		 2
data: 		.space 		40000
string:		.space		 8
string2:	.space 		16
		.align 		0
newLine:	.asciiz 	"\n"
.text

#open the file for opening

#li $a0, 3900000
#li $v0, 9
#syscall
#move $s6, $v0

#li $a0, 40000
#li $v0, 9
#syscall
#move $s7, $v0

li   $v0, 13       # system call for open file
la   $a0, fin      # board file name
li   $a1, 0        # Open for reading
li   $a2, 0
syscall            # open a file (file descriptor returned in $v0)
move $s6, $v0      # save the file descriptor 

#read from file
li   $v0, 14       # system call for read from file
move $a0, $s6      # file descriptor 
la   $a1, wordList     # address of buffer to which to read
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
syscall            # open a file (file descriptor returned in $v0)				##Testing if it reads integers or ascii characters
move $s6, $v0      # save the file descriptor 

#read from file
li   $v0, 14       # system call for read from file
move $a0, $s6      # file descriptor 
la   $a1, data     # address of buffer to which to read
li   $a2, 40000     # hardcoded buffer length
syscall            # read from file

# Close the file 
li   $v0, 16       # system call for close file
move $a0, $s6      # file descriptor to close
syscall            # close file

#la $s4, string
#la $s1, en4
#lbu $s2, 0($s1)
#lbu $s3, 1($s1)
#lbu $s5, 2($s1)
#lbu $s6, 3($s1)
#lbu $s7, 4($s1)

#sb $s2, 0($s4)
#sb $s3, 1($s4)
#sb $s5, 2($s4)
#sb $s6, 3($s4)
#sb $s7, 4($s4)
#lbu $s2, 5($s1)
#lbu $s3, 6($s1)

la $t1, string2
la $t2, data

lw $t3, 0($t2)

add $a0, $zero, $t3
li $v0, 1
syscall

la $a0, newLine
li $v0, 4
syscall


lw $t3, 4($t2)

add $a0, $zero, $t3
li $v0, 1
syscall


la $a0, newLine
li $v0, 4
syscall

lw $t3, 8($t2)

add $a0, $zero, $t3
li $v0, 1
syscall


la $a0, newLine
li $v0, 4
syscall

lw $t3, 12($t2)

add $a0, $zero, $t3
li $v0, 1
syscall


la $a0, newLine
li $v0, 4
syscall

lb $t3, 16($t2)

move $a0, $t3
li $v0, 1
syscall


la $a0, newLine
li $v0, 4
syscall

abs $t3, $t3

add $a0, $zero, $t3
li $v0, 1
syscall

la $a0, newLine
li $v0, 4
syscall
###################################################

addi $t1, $zero, 2
sll $t1, $t1, 2
la $t2, data
add $t2, $t1, $t2
lw $t1, 0($t2)

add $a0, $zero, $t1
li $v0, 1
syscall

la $t5, wordList
add $t5, $t5, $t1
lbu $t3, 0($t5)
lbu $t4, 1($t5)
lbu $t6, 2($t5)
lbu $t7, 3($t5)

la $s1, string
sb $t3, 0($s1)

add $a0, $zero, $t3
li $v0, 1
syscall
sb $t4, 1($s1)
add $a0, $zero, $t4
li $v0, 1
syscall
sb $t6, 2($s1)
sb $t7, 3($s1)
lbu $t3, 4($t5)
lbu $t4, 5($t5)
sb $t3, 4($s1)
sb $t4, 5($s1)

#sb $s2, 5($s4)
#sb $s3, 6($s4)

#la $a0, string
#li $v0, 4
#syscall

#la $a0, ($s3)
#li $v0, 1
#syscall

#la $a0, ($s2)
#li $v0, 1
#syscall

#la $s3, data
#lw $s2, 0($s3)
#add $s3, $s3, $s2
#lw $s4, 0($s3)
#lw $s5, 4($s3)


#la $a0, ($s2)
#li $v0, 1
#syscall

la $a0, string
li $v0, 4
syscall

#la $a0, newLine
#li $v0, 4
#syscall

