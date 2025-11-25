#

#

#



.data

userInput1:.asciiz "Please enter a regex to process: "
userInput2:.asciiz "Please enter characters to search: "
regexBuffer:.space  300
inputBuffer:.space  300
storeBuffer: .space 10
comma:.asciiz ","

out8: .asciiz "Goodbye! \n"


.text
.globl main


main:
li $v0, 4   #v0 is 4 to print a string
la $a0, userInput1 #setting a0 to the appropriate prompt
syscall #ask for user regex input


li $v0, 8  #setting v0 as 8 to accept a string input
la $a0, regexBuffer #setting a0 to the space we reserved in the memory
li $a1, 200 #allocating space of size 200
syscall #receive user regex input


li $v0, 4   #v0 is 4 to print a string
la $a0, userInput2 #setting a0 to the appropriate prompt
syscall #ask for user test string input


li $v0, 8  #setting v0 as 8 to accept a string input
la $a0, inputBuffer #setting a0 to the space we reserved in the memory
li $a1, 200 #allocating space of size 200
syscall #receive user test string input

jal parseRegex

la $a0, out8
li $v0, 4
syscall 

li $v0, 10
syscall
#############################################################################################################

# PARSE LOGIC

############################################################################################################

parseRegex:
la $t0, regexBuffer
la $t4 storeBuffer #where we will store ranges/ strings like abc to match
li $t1, 0 #initializing tmp registers and s registers to 0 for reuse after being used in previous functions
li $t2, 0  #flag indicating we have to process *
li $t3, 0  #flag indicating bracket for matching
li $s0, 0 #use this to store lower value for range
li $s1, 0 #use this to store upper value for range
li $s2, 0 #flag indicating negation for matching
la $t4, storeBuffer #storing range to process user input
li $s3, 0 #flag indicating whether there is a range of values to match- 0 if no range 1 if there is a range
li $s4, 0 #using this to count how many elements are present for matches without [], for example, abc
li $t5, 0 
li $t5, 0 
li $t6, 0
li $t7, 0
li $t8, 0
li $t9, 0

lb $t1, 0($t0)
li $t6, '['
beq $t1, $t6, parseBrackets

parseNoBrackets:
li $t3, 0   #we set the flag indicating brackets to 0
la $t4, storeBuffer

noBracketLoop: #jumping to this loop if no brackets are present
lb $t1, 0($t0)
beq $t1, $zero, doneNoBracketLoop #when we reach end of line we end the loop
addi $t0, $t0, 1
addi $s4, $s4, 1  #count the number of elements to print exact match for regex with no brackets
j noBracketLoop

doneNoBracketLoop:
j matchStart  #start matching after parsing 

parseBrackets:
addi $t0, $t0, 1
li $t3, 1   #setting bracket flag to 1, telling code we have brackets
lb $t1, 0($t0)
lb $t5, 1($t0)
li $t7, '^'
beq $t5, $t7, parseNegation
li $t6, '-'
beq $t5, $t6, parseRange
j parseNoRange

parseNoRange:
li $s3, 0 #setting no range flag to 0
la $t4, storeBuffer

parseNoRangeLoop:
li $t6, ']'
beq $t1, $t6, doneNoRangeLoop #finish when we reach ]
lb $t1, 0($t0)
sb $t1, 0($t4)    #storing string to buffer to process 
addi $t4, $t4, 1
addi $t0, $t0, 1
j parseNoRangeLoop

doneNoRangeLoop:
j matchStart

doneParse:
addi $t0, $t0, 1
lb $t1, 0($t0) 
li $t6, '*'
beq $t6, $t1, parseStar

parseStar:
li $t2, 1 #setting star flag to 1
j matchStart

parseNegation:
li $s2, 1
addi $t0, $t0, 1

parseRange:
li $s3, 1
lb $s0, 0($t0) #storing the lesser value in the range
lb $s1, 2($t0)    #storing the greater value in the range
beq $t6, $t1, doneParse #finish parsing brackets 
j matchStart


#############################################################################################################

# MATCH LOGIC

############################################################################################################

matchStart:
la $t0, regexBuffer
la $t4, storeBuffer
la $t8, inputBuffer
li $t9, ']'

bne $t3, $zero, matchBracket

matchNoBracket: #NEED TO IMPLEMENT
jr $ra

matchBracket:
j matchRange

#bne $s2, $zero, matchNegation
#beq $s3, $zero, matchNoRange

matchRange:
lb $t7, 0($t8) #pointer to input buffer
beq $t7, $zero, donePrint
#bne $t2, $zero, matchStarRange
blt $t7, $s0, nextChar
bgt $t7, $s1, nextChar


li $v0, 11
move $a0, $t7
syscall

li $v0, 4
la $a0, comma #print comma between each character
syscall 

nextChar:
addi $t8, $t8, 1
j matchRange

donePrint:
li $v0, 10
syscall


matchNegation:

matchStarRange:
matchNoRange:


























































