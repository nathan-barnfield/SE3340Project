#testing and experimenting. Thinking of making a jump table containing the offset of all the 9 letter words. The 9 letter words will have the words that can be matched with thier
#letters directly after it with a RS(30 in decimal)(record seperator) signifying the end of the record. the program will choose a random #, use that number in the jumptable to jump 
#to the address of the 9 letter word and will use that word and its subsequent matches to make a seperate wordlist that will be used for the actual game.
.data
fin: .asciiz "en4.txt"		#filename for input
en4: .space 21000
string: .space 8
.text

#open the file for opening

li   $v0, 13       # system call for open file
la   $a0, fin      # board file name
li   $a1, 0        # Open for reading
li   $a2, 0
syscall            # open a file (file descriptor returned in $v0)
move $s6, $v0      # save the file descriptor 

#read from file
li   $v0, 14       # system call for read from file
move $a0, $s6      # file descriptor 
la   $a1, en4      # address of buffer to which to read
li   $a2, 21000     # hardcoded buffer length
syscall            # read from file

# Close the file 
li   $v0, 16       # system call for close file
move $a0, $s6      # file descriptor to close
syscall            # close file

la $s4, string
la $s1, en4
lbu $s2, 0($s1)
lbu $s3, 1($s1)
lbu $s5, 2($s1)
lbu $s6, 3($s1)
lbu $s7, 4($s1)

sb $s2, 0($s4)
sb $s3, 1($s4)
sb $s5, 2($s4)
sb $s6, 3($s4)
sb $s7, 4($s4)
lbu $s2, 5($s1)
lbu $s3, 6($s1)

sb $s2, 5($s4)
sb $s3, 6($s4)

la $a0, string
li $v0, 4
syscall

la $a0, ($s3)
li $v0, 1
syscall

la $a0, ($s2)
li $v0, 1
syscall


