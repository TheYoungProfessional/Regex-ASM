#

#

#

#

# Amitha Ajithkumar, Michael Overman

#

#

#

#

.data

userInput1:.asciiz "Please enter a regex to process: "
userInput2:.asciiz "Please enter characters to search: "
inputBuffer1:.space  300
inputBuffer2:.space  300
printSorted:.asciiz "sorted list!"
printIndexEnd:.asciiz "Your number from the index is: "
printtheAverage:.asciiz "The average is: "
printtheSum:.asciiz "The sum is: "
printGreater:.asciiz "The greatest element is: "
printLesser:.asciiz "The lowest element is: "
print:.asciiz "The list is: "
printtheIndex:.asciiz "The value at the index is: "
open_Bracket:.asciiz "["
closed_Bracket:.asciiz "]"
closing:.asciiz "Goodbye!"
indexInput:.asciiz "Please enter an index number to access an element: "
comma:.asciiz ","

out8: .asciiz "Goodbye! \n"


.text
.globl main


main:
li $v0, 4   #v0 is 4 to print a string
la $a0, userInput1 #setting a0 to the appropriate prompt
syscall #ask for user regex input


li $v0, 8  #setting v0 as 8 to accept a string input
la $a0, inputBuffer1 #setting a0 to the space we reserved in the memory
li $a1, 200 #allocating space of size 200
syscall #receive user regex input


li $v0, 4   #v0 is 4 to print a string
la $a0, userInput2 #setting a0 to the appropriate prompt
syscall #ask for user test string input


li $v0, 8  #setting v0 as 8 to accept a string input
la $a0, inputBuffer2 #setting a0 to the space we reserved in the memory
li $a1, 200 #allocating space of size 200
syscall #receive user test string input


li $t1, 0 #initializing tmp registers and s registers to 0 for reuse after being used in previous functions
li $t2, 0 
li $t3, 0 
li $t4, 0 
li $t6, 0 
li $t7, 0 
li $t8, 0 
li $t9, 0 
li $s1, '['
li $s2, ']'
li $s3, '.'
li $s4, '*'
#li $s5, '\'
li $s6, '^'
li $s7, '-'

la $t0, inputBuffer1
la $t1, inputBuffer2

j exit

parseBuffer:

lb $t2, 0($t0)#regex base address load

#jal countLoop
jal inputCountLoop
lb $t0, 0($t0)  #loading byte 
lb $t1, 0($t0)
beq $t0, $s1, openBracket #no need for endbracket, will be handled within startbracket
beq $t0, $s3, matchLoop
beq $t0, $s4, unboundedMatch
beq $t0, $s5, escape
beq $t0, $s6, negate
beq $t0, $s7, hyphen


inputCountLoop:
lb $t3, 0($t1)#input2 character load
beq $t2, $zero, doneCount
addi $s0, $s0, 1
j inputCountLoop

doneCount:
j regexCountLoop

regexCountLoop:
lb $t2, 0($t0)#input2 character load
beq $t2, $zero, doneRegexCount
addi $t5, $t5, 1
j regexCountLoop

doneRegexCount:
jr $ra

matchLoop:
lb $t3, 0($t1)#input 2 characters
beq $t2, $t3, matchPrint
beq $t3, $s0, newLineMatch
addi $t1, $t1, 1
j matchLoop

matchPrint:
li $v0, 11
la $a0, 0($t2)
beq $t2, $t5, newLineMatch #when we reach the max number of regex characters, exit to print a new line
syscall
j matchLoop

newLineMatch:
li $v0, 10 #newline
syscall
j matchLoop


openBracket:
lb $t3, 0($t1)#input 2 characters
beq $t2, $t3, bracketPrint
#beq $t3, $s0, $s2 #if we reach the closing bracket end print
beq $t3, $s0, bracketPrint #if we reach the closing bracket end print
addi $t1, $t1, 1
j openBracket

bracketPrint:
li $v0, 11
la $a0, 0($t2)
syscall

li $v0, 4
la $a0, comma #print comma between each character
syscall 

j openBracket

unboundedMatch:
escape:
negate:
hyphen:

########################################################
# EXIT
########################################################
exit:
	la $a0, out8
	li $v0, 4
	syscall
	li $v0, 10
	syscall
