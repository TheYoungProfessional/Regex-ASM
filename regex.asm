#
# CS 35101 - Regex Parser
# Test Cases 4, 5, and 8 Implementation
#
.data
userInput1:     .asciiz "Please enter a regex to process: "
userInput2:     .asciiz "Please enter characters to search: "
regexBuffer:    .space  300
inputBuffer:    .space  300
storeBuffer:    .space  10
comma:          .asciiz ","
out8:           .asciiz "\nGoodbye! \n"

.text
.globl main

main:
    li $v0, 4
    la $a0, userInput1
    syscall
    
    li $v0, 8
    la $a0, regexBuffer
    li $a1, 200
    syscall
    
    li $v0, 4
    la $a0, userInput2
    syscall
    
    li $v0, 8
    la $a0, inputBuffer
    li $a1, 200
    syscall
    
    jal parseRegex
    
    # Print goodbye message and exit
    la $a0, out8
    li $v0, 4
    syscall
    
    li $v0, 10
    syscall

#############################################################################################################
# PARSE LOGIC
#############################################################################################################

<<<<<<< Updated upstream
parseRegex: #initiate parsing
la $t0, regexBuffer #
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

lb $t1, 0($t0) #loads in regex
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

parseNegation:
li $s2, 1
addi $t0, $t0, 1

parseRange:
li $s3, 1
lb $s0, 0($t0) #storing the lesser value in the range
lb $s1, 2($t0)    #storing the greater value in the range
addi $t0, $t0, 4
j doneParse

=======
parseRegex:
    la $t0, regexBuffer
    la $t4, storeBuffer
    
    # Initialize flags
    li $t1, 0           # current char
    li $t2, 0           # star flag
    li $t3, 0           # bracket flag
    li $s0, 0           # lower range value
    li $s1, 0           # upper range value
    li $s2, 0           # negation flag
    li $s3, 0           # range flag
    li $s4, 0           # count for plain chars
    li $s5, 0           # dot flag
    li $s6, 0           # escape flag
    li $s7, 0           # literal string buffer index
    
    lb $t1, 0($t0)      # Load first char
    
    # Check for dot
    li $t6, '.'
    beq $t1, $t6, parseDot
    
    # Check for backslash (escape)
    li $t6, '\\'
    beq $t1, $t6, parseEscape
    
    # Check for bracket
    li $t6, '['
    beq $t1, $t6, parseBrackets
    
    j parseNoBrackets
>>>>>>> Stashed changes

#############################################################################################################
# NEW: Parse dot (.) - Test Cases 4 & 5
#############################################################################################################
parseDot:
    li $s5, 1           # Set dot flag
    addi $t0, $t0, 1    # Move past '.'
    lb $t1, 0($t0)      # Load next char
    
    # Check if followed by '*'
    li $t6, '*'
    beq $t1, $t6, parseDotStar
    
    # Just a single dot - go to matchStart to initialize registers
    j matchStart

parseDotStar:
    li $t2, 1           # Set star flag
    j matchStart

#############################################################################################################
# NEW: Parse escape character (\) - Test Case 8
#############################################################################################################
parseEscape:
    li $s6, 1           # Set escape flag
    addi $t0, $t0, 1    # Move past '\'
    lb $t1, 0($t0)      # Load escaped character
    
    # Store the literal character to match
    la $t4, storeBuffer
    sb $t1, 0($t4)
    addi $t0, $t0, 1
    
    # For test case 8: [A-z]*\.edu
    # After parsing \., we need to continue parsing "edu"
    j parseAfterEscape

parseAfterEscape:
    la $t4, storeBuffer
    addi $t4, $t4, 1    # Move to next position in buffer
    
parseAfterEscapeLoop:
    lb $t1, 0($t0)      # Load next char
    beq $t1, $zero, doneParseAfterEscape
    beq $t1, 10, doneParseAfterEscape    # newline
    
    sb $t1, 0($t4)      # Store in buffer
    addi $t4, $t4, 1
    addi $t0, $t0, 1
    addi $s7, $s7, 1    # Increment literal string count
    j parseAfterEscapeLoop

doneParseAfterEscape:
    # For test case 8, we need special handling
    # Pattern is: [A-z]* followed by \.edu
    # This means we need to match range, then literal string
    j matchStart

#############################################################################################################
parseNoBrackets:
    li $t3, 0
    la $t4, storeBuffer
    
noBracketLoop:
    lb $t1, 0($t0)
    beq $t1, $zero, doneNoBracketLoop
    beq $t1, 10, doneNoBracketLoop
    sb $t1, 0($t4)
    addi $t4, $t4, 1
    addi $s4, $s4, 1
    addi $t0, $t0, 1
    j noBracketLoop

doneNoBracketLoop:
    j matchStart

parseBrackets:
    addi $t0, $t0, 1
    li $t3, 1
    lb $t1, 0($t0)
    li $t7, '^'
    beq $t1, $t7, parseNegation
    
    lb $t5, 1($t0)
    li $t6, '-'
    beq $t5, $t6, parseRange
    j parseNoRange

parseNegation:
    addi $t0, $t0, 1
    li $s2, 1
    li $s3, 1
    lb $s0, 0($t0)
    addi $t0, $t0, 2
    lb $s1, 0($t0)
    addi $t0, $t0, 1
    j doneParse

parseNoRange:
    li $s3, 0
    la $t4, storeBuffer
    
parseNoRangeLoop:
    lb $t1, 0($t0)
    li $t6, ']'
    beq $t6, $t1, doneNoRangeLoop
    sb $t1, 0($t4)
    addi $t4, $t4, 1
    addi $t0, $t0, 1
    j parseNoRangeLoop

doneNoRangeLoop:
    addi $t0, $t0, 1
    lb $t1, 0($t0)
    li $t6, '*'
    beq $t6, $t1, parseStarNoRange
    j matchStart

parseStarNoRange:
    li $t2, 1
    addi $t0, $t0, 1
    j matchStart

parseRange:
    li $s3, 1
    lb $s0, 0($t0)
    addi $t0, $t0, 2
    lb $s1, 0($t0)
    addi $t0, $t0, 2
    j doneParse

doneParse:
    lb $t1, 0($t0)
    li $t6, '*'
    beq $t6, $t1, parseStar
    
    # Check if there's more to parse (for test case 8)
    addi $t0, $t0, 1
    lb $t1, 0($t0)
    beq $t1, $zero, matchStart
    beq $t1, 10, matchStart
    
    # There's more pattern - check for escape
    li $t6, '\\'
    beq $t1, $t6, parseEscapeAfterRange
    j matchStart

parseEscapeAfterRange:
    addi $t0, $t0, 1    # Move past '\'
    lb $t1, 0($t0)      # Load escaped char ('.')
    la $t4, storeBuffer
    sb $t1, 0($t4)      # Store '.'
    addi $t4, $t4, 1    # Move to next position
    addi $t0, $t0, 1    # Move past '.'
    
    # Now continue parsing "edu"
parseEscapeRestLoop:
    lb $t1, 0($t0)      # Load next char
    beq $t1, $zero, doneParseEscapeRest
    beq $t1, 10, doneParseEscapeRest    # newline
    
    sb $t1, 0($t4)      # Store in buffer
    addi $t4, $t4, 1
    addi $t0, $t0, 1
    j parseEscapeRestLoop
    
doneParseEscapeRest:
    sb $zero, 0($t4)    # Null terminate the literal string
    j matchStart

parseStar:
    li $t2, 1
    addi $t0, $t0, 1
    
    # Check if there's more after * (for test case 8)
    lb $t1, 0($t0)
    beq $t1, $zero, matchStart
    beq $t1, 10, matchStart
    
    li $t6, '\\'
    beq $t1, $t6, parseEscapeAfterRangeStar
    j matchStart

parseEscapeAfterRangeStar:
    li $s6, 1           # Set escape flag
    j parseEscapeAfterRange

#############################################################################################################
# MATCH LOGIC
#############################################################################################################

matchStart:
    # Initialize pointers
    li $t5, 0
    la $t0, regexBuffer
    la $t4, storeBuffer
    move $t5, $t4
    la $t8, inputBuffer    # Load input buffer address into $t8
    
    # Check which pattern to match
    bne $s5, $zero, checkDotStar  # Dot flag set?
    bne $s6, $zero, matchEscapePattern  # Escape flag set?
    bne $t3, $zero, matchBracket
    j matchNoBracket

checkDotStar:
    bne $t2, $zero, matchDotStar
    j matchDot

#############################################################################################################
# NEW: Match single dot (.) - Test Case 4
#############################################################################################################
matchDot:
    li $t5, 0           # First match flag
    
matchDotLoop:
    lb $t7, 0($t8)
    beq $t7, $zero, doneDotMatch
    beq $t7, 10, doneDotMatch    # Skip newline
    
    # Print comma if not first
    beq $t5, 0, printDotChar
    li $v0, 4
    la $a0, comma
    syscall
    
printDotChar:
    li $t5, 1           # Not first anymore
    li $v0, 11
    move $a0, $t7
    syscall
    
    addi $t8, $t8, 1
    j matchDotLoop

doneDotMatch:
    jr $ra

#############################################################################################################
# NEW: Match dot-star (.*) - Test Case 5
#############################################################################################################
matchDotStar:
    lb $t7, 0($t8)
    beq $t7, $zero, doneDotStarMatch
    beq $t7, 10, doneDotStarMatch
    
    li $v0, 11
    move $a0, $t7
    syscall
    
    addi $t8, $t8, 1
    j matchDotStar

doneDotStarMatch:
    jr $ra

#############################################################################################################
# NEW: Match escaped pattern - Test Case 8: [A-z]*\.edu
#############################################################################################################
matchEscapePattern:
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    # For test case 8: [A-z]*\.edu means find ".edu" and print preceding letters + ".edu"
    # Strategy: scan input for ".edu", then backtrack to collect preceding valid range chars
    
    la $t8, inputBuffer
    la $t4, storeBuffer
    
findLiteralString:
    lb $t7, 0($t8)          # Current input char
    beq $t7, $zero, doneEscapeMatch
    beq $t7, 10, doneEscapeMatch
    
    # Try to match literal string ".edu" at current position
    move $a0, $t8           # Input position
    move $a1, $t4           # Literal string to find (should be ".edu")
    jal matchLiteralAtPos
    
    # $v0 = 1 if match, 0 if no match
    beq $v0, 0, nextEscapePos
    
    # Found ".edu"! Now backtrack to get preceding range chars and print everything
    move $a0, $t8           # Position where ".edu" starts
    jal printPrecedingRangeAndLiteral
    
    # After printing one match, exit
    j doneEscapeMatch
    
nextEscapePos:
    addi $t8, $t8, 1
    j findLiteralString

doneEscapeMatch:
    # Restore return address and return
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

#############################################################################################################
# Helper: Match literal string at position
# Args: $a0 = input position, $a1 = literal string
# Returns: $v0 = 1 if match, 0 otherwise
#############################################################################################################
matchLiteralAtPos:
    move $t0, $a0           # Input pointer
    move $t1, $a1           # Literal pointer
    
matchLitLoop:
    lb $t2, 0($t1)          # Literal char
    beq $t2, $zero, matchLitSuccess
    
    lb $t3, 0($t0)          # Input char
    bne $t2, $t3, matchLitFail
    
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    j matchLitLoop

matchLitSuccess:
    li $v0, 1
    jr $ra

matchLitFail:
    li $v0, 0
    jr $ra

#############################################################################################################
# Helper: Print preceding range characters + literal string
# Args: $a0 = position where literal string starts (e.g., where ".edu" begins)
# This backtracks to find where the valid [A-z] sequence starts, then prints sequence + literal
# Uses $s0 and $s1 for the range bounds that were set during parsing
#############################################################################################################
printPrecedingRangeAndLiteral:
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $a0, 4($sp)
    sw $s0, 8($sp)
    sw $s1, 12($sp)
    
    move $t9, $a0           # Save: position where ".edu" starts
    
    # Simple approach: backtrack from position before ".edu" 
    # to find where the letter sequence starts
    move $t8, $t9
    addi $t8, $t8, -1       # Start at char immediately before ".edu"
    
    # Handle case where ".edu" is at start of string
    la $t0, inputBuffer
    blt $t8, $t0, noPrecedingChars
    
    # Find the start of the letter sequence by going backward
    # Use the range stored in $s0 and $s1
backtrackLoop:
    blt $t8, $t0, foundSequenceStart  # Reached start of buffer
    
    lb $t7, 0($t8)
    
    # Check if char is in the parsed range [stored in $s0-$s1]
    blt $t7, $s0, foundSequenceStart  # Below range
    bgt $t7, $s1, foundSequenceStart  # Above range
    
    # Still in range, keep going back
    addi $t8, $t8, -1
    j backtrackLoop
    
foundSequenceStart:
    # $t8 is now pointing at the char BEFORE the sequence starts
    # (or before the start of buffer)
    addi $t8, $t8, 1        # Move to actual start of sequence
    
    # Now print from $t8 to $t9 (the range chars) then the literal string
    j startPrinting
    
noPrecedingChars:
    # ".edu" is at the very start, just print the literal
    move $t8, $t9
    
startPrinting:
    # Print range characters (from $t8 to $t9)
printRangeChars:
    bge $t8, $t9, printLiteralPart
    lb $t7, 0($t8)
    
    li $v0, 11
    move $a0, $t7
    syscall
    
    addi $t8, $t8, 1
    j printRangeChars
    
printLiteralPart:
    # Now print the literal string ".edu" from storeBuffer
    la $t4, storeBuffer
    
printLiteralLoop:
    lb $t7, 0($t4)
    beq $t7, $zero, donePrintRangeLit
    
    li $v0, 11
    move $a0, $t7
    syscall
    
    addi $t4, $t4, 1
    j printLiteralLoop

donePrintRangeLit:
    lw $ra, 0($sp)
    lw $a0, 4($sp)
    lw $s0, 8($sp)
    lw $s1, 12($sp)
    addi $sp, $sp, 16
    jr $ra

#############################################################################################################
# Existing match functions (kept from your original code)
#############################################################################################################

matchNoBracket:
    jr $ra

matchBracket:
<<<<<<< Updated upstream
beq $s3, $zero, matchNoRange #if flag for range is zero, process value within bracket not as a range
=======
    beq $s3, $zero, matchNoRange
    bne $s2, $zero, negateStarRange
    bne $t2, $zero, matchStarRange
    j matchRange
>>>>>>> Stashed changes

matchRange:
<<<<<<< Updated upstream
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

nextCharRange: #look to next character in range, run match logic again
addi $t8, $t8, 1
j matchRange
=======
    lb $t7, 0($t8)
    beq $t7, $zero, donePrint
    beq $t7, 10, donePrint
    blt $t7, $s0, nextCharRange
    bgt $t7, $s1, nextCharRange
    
    li $v0, 11
    move $a0, $t7
    syscall
    
    li $v0, 4
    la $a0, comma
    syscall
    
nextCharRange:
    addi $t8, $t8, 1
    j matchRange
>>>>>>> Stashed changes

donePrint:
    jr $ra

matchNoRange:
<<<<<<< Updated upstream
li $t3, 0
bne $t2, $zero, matchStarNoRange #Checking if input entered is in the format [a-z]*
lb $t7, 0($t8) #pointer to input buffer
move $t4, $t5 #pointing to start 
beq $t7, $zero, donePrint #ending print when we reach end of line 

=======
    li $t5, 0
    la $t4, storeBuffer
    move $t5, $t4
    
matchNoRangeLoop:
    lb $t7, 0($t8)
    beq $t7, $zero, donePrint
    beq $t7, 10, donePrint
    
    move $t4, $t5
    
>>>>>>> Stashed changes
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
    la $a0, comma
    syscall

nextCharNoRange:
    addi $t8, $t8, 1
    j matchNoRangeLoop

matchStarRange:
<<<<<<< Updated upstream
li $t6, ','
li $t5, 0 #we will use this to indicate whether ',' has been printed or not

matchStarLoop:
lb $t7, 0($t8) #pointer to input buffer 
beq $t7, $zero, donePrintStar
blt $t7, $s0, nextStarChar
bgt $t7, $s1, nextStarChar

li $v0, 11
move $a0, $t7
syscall

li $t5, 1
addi $t8, $t8, 1

j matchStarLoop
=======
    li $t5, 0
    
matchStarLoop:
    lb $t7, 0($t8)
    beq $t7, $zero, donePrintStar
    beq $t7, 10, donePrintStar
    blt $t7, $s0, nextStarChar
    bgt $t7, $s1, nextStarChar
    
    li $v0, 11
    move $a0, $t7
    syscall
    
    li $t5, 1
    addi $t8, $t8, 1
    j matchStarLoop
>>>>>>> Stashed changes

nextStarChar:
    beq $t5, $zero, skipComma
    li $v0, 4
    la $a0, comma
    syscall
    li $t5, 0

skipComma:
    addi $t8, $t8, 1
    j matchStarLoop

donePrintStar:
<<<<<<< Updated upstream
li $v0, 10
syscall

######################################################################################

matchStarNoRange:
li $t6, ','
lb $t7, 0($t8) #pointer to input buffer
move $t4, $t5 #pointing to start to the store buffer
beq $t7, $zero, donePrint #ending print when we reach end of line 

# we iterate through each character in the store buffer, and print matches 
starNoRangeLoop:
lb $t6, 0($t4)
beq $t6, $zero, nextStarNoRange #going to next char in store buffer to check if we reach the end
beq $t7, $t6, printNoStarRange
beq $t3, $zero, printCommaStar
addi $t4, $t4, 1
j noStarRangeLoop

printCommaStar:
bne $t3, $zero, noComma

li $v0, 4
la $a0, comma #print comma between each character
syscall 

li $t3, 1

j noStarRangeLoop

noComma:
addi $t4, $t4, 1
j noStarRangeLoop

printStarNoRange:
li $v0, 11
move $a0, $t7
syscall
bne $t3, $zero, noComma

nextStarNoRange:
addi $t8, $t8, 1
j matchStarNoRange
=======
    jr $ra

negateStarRange:
    li $t5, 0
    
negateStarLoop:
    lb $t7, 0($t8)
    beq $t7, $zero, doneNegate
    beq $t7, 10, doneNegate
    blt $t7, $s0, printNegate
    bgt $t7, $s1, printNegate
    j checkComma

printNegate:
    li $v0, 11
    move $a0, $t7
    syscall
    li $t5, 0
    addi $t8, $t8, 1
    j negateStarLoop

checkComma:
    bne $t5, $zero, skipNegateComma
    li $v0, 4
    la $a0, comma
    syscall
    li $t5, 1

skipNegateComma:
    addi $t8, $t8, 1
    j negateStarLoop

doneNegate:
    jr $ra
>>>>>>> Stashed changes
