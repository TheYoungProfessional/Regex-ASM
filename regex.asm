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
input2Buffer:.space  300
printSorted:.asciiz "sorted list!"
printIndexEnd:.asciiz "Your number from the index is: "
printtheAverage:.asciiz "The average is: "
printtheSum:.asciiz "The sum is: "
printGreater:.asciiz "The greatest element is: "
printLesser:.asciiz "The lowest element is: "
print:.asciiz "The list is: "
printtheIndex:.asciiz "The value at the index is: "
openBracket:.asciiz "["
closedBracket:.asciiz "]"
closing:.asciiz "Goodbye!"
indexInput:.asciiz "Please enter an index number to access an element: "
comma:.asciiz ","
.align 2
floatBuffer:.space 1200
mf1: .float 10.0

.text
.globl main

main:
li $v0, 4   #v0 is 4 to print a string
la $a0, userInput1 #setting a0 to the appropriate prompt
syscall

li $v0, 8  #setting v0 as 8 to accept a string input
la $a0, inputBuffer1 #setting a0 to the space we reserved in the memory
li $a1, 200 #allocating space of size 200
syscall

li $v0, 4   #v0 is 4 to print a string
la $a0, userInput2 #setting a0 to the appropriate prompt
syscall

li $v0, 8  #setting v0 as 8 to accept a string input
la $a0, inputBuffer2 #setting a0 to the space we reserved in the memory
li $a1, 200 #allocating space of size 200
syscall

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

parseBuffer:
lb $t0, 0($t0)  #loading byte 
lb $t1, 0($t0)
beq $t0, $s1, startBracket
beq $t0, $s2, endBracket
beq $t0, $s3, matchAny
beq $t0, $s4, unboundedMatch
beq $t0, $s5, escape
beq $t0, $s6, negate
beq $t0, $s7, hyphen

matchLoop:
beq 
j matchLoop

lb $t0, inputBuffer1
lb $t1, inputBuffer2




countLoop:

j countLoop


li $t0, 0
li $t1, 0


