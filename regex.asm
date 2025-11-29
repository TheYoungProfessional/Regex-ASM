#

#

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
li $t6, 0
li $t7, 0
li $t8, 0
li $t9, 0

lb $t1, 0($t0) #pointer to regex buffer
li $t6, '['
beq $t1, $t6, parseBrackets

parseNoBrackets:
li $t3, 0   #we set the flag indicating brackets to 0
la $t4, storeBuffer #extra buffer to store plain values 

noBracketLoop: #jumping to this loop if no brackets are present
lb $t1, 0($t0)
beq $t1, $zero, doneNoBracketLoop #when we reach end of line we end the loop
addi $t0, $t0, 1
sb $s4, 0($t0)
j noBracketLoop

doneNoBracketLoop:
j matchStart  #start matching after parsing 

parseBrackets:
addi $t0, $t0, 1
li $t3, 1   #setting bracket flag to 1, telling code we have brackets
lb $t1, 0($t0)
li $t7, '^'
beq $t1, $t7, parseNegation

lb $t5, 1($t0) #peeking ahead by a byte (the '[' bracket) to see if there is a ^ after it
li $t6, '-'
beq $t5, $t6, parseRange
j parseNoRange

parseNegation:
addi $t0, $t0, 1
li $s2, 1   #setting s2 to 1 to indicate that negation boolean = 1 
li $s3, 1   #setting s3 to 1 indicating range is present
lb $s0, 0($t0) #storing the lesser value in the range
addi $t0, $t0, 2
lb $s1, 0($t0)    #storing the greater value in the range
addi $t0, $t0, 1
j doneParse


parseNoRange:
li $s3, 0 #setting no range flag to 0
la $t4, storeBuffer

parseNoRangeLoop:
beq $t1, $zero, doneNoRangeLoop #finish when we reach ]
lb $t1, 0($t0)
sb $t1, 0($t4)    #storing string to buffer to process 
addi $t4, $t4, 1
addi $t0, $t0, 1
li $t6, '*'
beq $t6, $t1, parseStarNoRange
j parseNoRangeLoop

doneNoRangeLoop:
j matchStart

parseStarNoRange:
li $t2, 1

doneParse:
lb $t1, 0($t0) 
li $t6, '*'
beq $t6, $t1, parseStar
j matchStart

parseStar:
li $t2, 1 #setting star flag to 1
j matchStart

parseRange:
li $s3, 1   #setting s3 to 1 indicating range is present
lb $s0, 0($t0) #storing the lesser value in the range
lb $s1, 2($t0)    #storing the greater value in the range
addi $t0, $t0, 1
j doneParse


#############################################################################################################

# MATCH LOGIC

############################################################################################################

matchStart:
li $t5, 0
la $t0, regexBuffer
la $t4, storeBuffer
move $t5, $t4
la $t8, inputBuffer #holds input for non range values, ex:abc, etc
li $t9, ']'
bne $t3, $zero, matchBracket #if flag for bracket is 1, process within bracket
j matchNoBracket
#######################################################################################################
matchNoBracket: #NEED TO IMPLEMENT
jr $ra

matchBracket:
beq $s3, $zero, matchNoRange #if flag for range is zero, process value within bracket not as a range
bne $s2, $zero, negateStarRange

#bne $s2, $zero, matchNegation
#####################################################################################################
matchRange:
bne $s2, $zero, negateStarRange
bne $t2, $zero, matchStarRange #Checking if input entered is in the format [a-z]*
lb $t7, 0($t8) #pointer to input buffer
beq $t7, $zero, donePrint
blt $t7, $s0, nextCharRange
bgt $t7, $s1, nextCharRange

li $v0, 11
move $a0, $t7
syscall

li $v0, 4
la $a0, comma #print comma between each character
syscall 

nextCharRange:
addi $t8, $t8, 1
j matchRange

donePrint:
li $v0, 10
syscall
####################################################################################
matchNegation:
######################################################################################

matchNoRange:
li $t3, 0
bne $t2, $zero, matchStarNoRange #Checking if input entered is in the format [avz]*
lb $t7, 0($t8) #pointer to input buffer
move $t4, $t5 #pointing to start 
beq $t7, $zero, donePrint #ending print when we reach end of line 

noRangeLoop:
lb $t6, 0($t4)
beq $t6, $zero, nextCharNoRange
beq $t7, $t6, printNoRange
addi $t4, $t4, 1
j noRangeLoop

printNoRange:
li $v0, 11
move $a0, $t7
syscall

li $v0, 4
la $a0, comma #print comma between each character
syscall 

nextCharNoRange:
addi $t8, $t8, 1
j matchNoRange

######################################################################################
matchStarRange:
beq $s2, $zero, matchStarNoRange
li $t6, ','
li $t5, 0 #we will use this to indicate whether ',' has been printed or not

matchStarLoop:
lb $t7, 0($t8) #pointer to input buffer 
beq $t7, $zero, donePrintStar
blt $t7, $s0, nextStarChar
bgt $t7, $s1, nextStarChar

li $v0, 11
move $a0, $t7 #printing char if it matches
syscall

li $t5, 1
addi $t8, $t8, 1

j matchStarLoop

nextStarChar:
beq $t5, $zero, skipComma
li $v0, 4
la $a0, comma #print comma between each character
syscall 

li $t5, 0

skipComma:
addi $t8, $t8, 1
j matchStarLoop

donePrintStar:
li $v0, 10
syscall

######################################################################################

#[abc]* test case 

######################################################################################
matchStarNoRange:
li $t3,1

matchStarNoRangeLoop:
move $t4, $t5 #pointing to start 
lb $t7, 0($t8) #pointer to input buffer 
beq $t7, $zero, doneNoRangePrint #ending print when we reach end of line 
li $t2, 0

noRangeStarLoop:
lb $t6, 0($t4) #pointer to store buffer
beq $t6, $zero, printStarCommaMaybe
beq $t7, $zero, doneNoRangePrint
beq $t7, $t6, matchElement
addi $t4, $t4,1
j noRangeStarLoop

matchElement:
li $t2, 1

printStarCommaMaybe:
beq $t2, $zero, skipCommaNoRange
beq $t3, $zero, printCharStarRange

li $v0, 4
la $a0, comma #print comma between each character
syscall 

printCharStarRange:
li $v0, 11
move $a0, $t7
syscall

li $t3, 0

addi $t8, $t8, 1
j matchStarNoRangeLoop

nextElement:
addi $t4, $t4, 1
j noRangeStarLoop

skipCommaNoRange:
li $t3, 1
addi $t8, $t8, 1
j matchStarNoRangeLoop

doneNoRangePrint:
li $v0, 10
syscall



###############################################

#[^A-Z]* test case 

negateStarRange:
beq $s2, $zero, negateStarRange
li $t6, ','
li $t5, 0 #we will use this to indicate whether ',' has been printed or not

negateStarLoop:
lb $t7, 0($t8) #pointer to input buffer 
beq $t7, $zero, doneNegate
blt $t7, $s0, printNegate
bgt $t7, $s1, printNegate
j checkComma

printNegate:
li $v0, 11
move $a0, $t7
syscall

li $t5, 0 #setting flag to 1 after we have printed

addi $t8, $t8, 1
j negateStarLoop

checkComma: #checks if a comma should be printed
bne $t5, $zero, skipNegateComma #we skip printing comma if the flag is 1

li $v0, 4
la $a0, comma #print comma between each character
syscall 

li $t5, 1

skipNegateComma:
addi $t8, $t8, 1
j negateStarLoop

doneNegate:
li $v0, 10
syscall












































