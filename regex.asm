#

#

#

#

# Amitha Ajithkumar, Michael Overman, Garrett White

#

#

#

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
li $v0, 4   #v0 is 4 to print a string
la $a0, userInput1 #setting a0 to the appropriate prompt
syscall #ask for user regex input


li $v0, 8  #setting v0 as 8 to accept a string input
la $a0, regexBuffer
li $a1, 200 #allocating space of size 200
syscall #receive user regex input


li $v0, 4   #v0 is 4 to print a string
la $a0, userInput2 #setting a0 to the appropriate prompt
syscall #ask for user test string input


li $v0, 8  #setting v0 as 8 to accept a string input
la $a0, inputBuffer 
li $a1, 200 #allocating space of size 200
syscall #receive user test string input

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

    j matchStart

#############################################################################################################
parseNoBrackets:
li $t3, 0 #we set the flag indicating brackets to 0
la $t4, storeBuffer #extra buffer to store plain values
    
noBracketLoop: #jumping to this loop if no brackets are present
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
    lb $t1, 0($t0)
    li $t6, ']'
    beq $t6, $t1, doneNoRangeLoop
    sb $t1, 0($t4)
    addi $t4, $t4, 1
    addi $t0, $t0, 1
    li $t6, '*'
beq $t6, $t1, parseStarNoRange
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
    lb $t1, 0($t0)      # Load escaped char
    
    # Store in literal buffer
    la $t4, storeBuffer
    sb $t1, 0($t4)      # Store escaped char
    addi $t4, $t4, 1    # Move to next position
    addi $t0, $t0, 1    # Move past escaped char
    
    # Now continue parsing the REST of the literal string
parseEscapeRestLoop:
    lb $t1, 0($t0)      # Load next char
    beq $t1, $zero, doneParseEscapeRest
    beq $t1, 10, doneParseEscapeRest    # newline
    
    # Check for another escape sequence
    li $t6, '\\'
    beq $t1, $t6, handleNestedEscape
    
    sb $t1, 0($t4)      # Store in buffer
    addi $t4, $t4, 1
    addi $t0, $t0, 1
    j parseEscapeRestLoop

handleNestedEscape:
    # Handle nested escape (like \. within the literal)
    addi $t0, $t0, 1    # Move past '\'
    lb $t1, 0($t0)      # Load escaped char
    sb $t1, 0($t4)      # Store it
    addi $t4, $t4, 1
    addi $t0, $t0, 1
    j parseEscapeRestLoop
    
doneParseEscapeRest:
    sb $zero, 0($t4)    # Null terminate the literal string
    j matchStart

parseStar:
    li $t2, 1
    addi $t0, $t0, 1
    
    j parseRestOfPatternAfterStar

parseRestOfPatternAfterStar:
    la $t4, storeBuffer
    
parseRestLoop:
    lb $t1, 0($t0)
    beq $t1, $zero, doneParseRest
    beq $t1, 10, doneParseRest
    
    # Check for escape
    li $t6, '\\'
    beq $t1, $t6, handleEscapeInRest
    
    # Regular character
    sb $t1, 0($t4)
    addi $t4, $t4, 1
    addi $t0, $t0, 1
    j parseRestLoop

handleEscapeInRest:
    li $s6, 1           # Set escape flag
    addi $t0, $t0, 1    # Move past '\'
    lb $t1, 0($t0)      # Load escaped char
    sb $t1, 0($t4)      # Store it
    addi $t4, $t4, 1
    addi $t0, $t0, 1
    j parseRestLoop
    
doneParseRest:
    sb $zero, 0($t4)    # Null terminate
    j matchStart

parseEscapeAfterRangeStar:
    li $s6, 1           # Set escape flag
    j parseRestOfPatternAfterStar

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
        #holds input for non range values, ex:abc, etc
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


matchEscapePattern:
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)
    
    
    la $t8, inputBuffer
    
findFullPattern:
    lb $t7, 0($t8)          # Current input char
    beq $t7, $zero, doneEscapeMatch
    beq $t7, 10, doneEscapeMatch
    
    # For each position, try to match the full pattern
    move $a0, $t8           # Starting position in input
    jal tryMatchFullPattern
    
    beq $v0, 1, foundFullPatternMatch
    
    addi $t8, $t8, 1
    j findFullPattern

foundFullPatternMatch:
    # Print the match
    move $a0, $v1           # Start of match
    jal printMatch
    
    move $t0, $v1           # Start of this match
    
    # Find where literal begins
    la $t3, storeBuffer
    lb $t4, 0($t3)          # First char of literal
    
findLiteralInMatch:
    lb $t5, 0($t0)
    beq $t5, $zero, foundEnd
    beq $t5, 10, foundEnd
    
    # Check if this is start of literal
    bne $t5, $t4, notLiteralYet
    move $a0, $t0
    move $a1, $t3
    addi $sp, $sp, -8
    sw $t0, 0($sp)
    sw $ra, 4($sp)
    jal matchLiteralAtPos
    lw $t0, 0($sp)
    lw $ra, 4($sp)
    addi $sp, $sp, 8
    
    beq $v0, 1, foundLiteralPosition
    
notLiteralYet:
    addi $t0, $t0, 1
    j findLiteralInMatch

foundLiteralPosition:
    # t0 points to start of literal
    # Calculate length of literal
    la $t3, storeBuffer
    li $t6, 0
countLitLen:
    lb $t5, 0($t3)
    beq $t5, $zero, gotLitLen
    addi $t6, $t6, 1
    addi $t3, $t3, 1
    j countLitLen

gotLitLen:
    # t0 + t6 = end of match
    add $t0, $t0, $t6
    
foundEnd:
    
    # Check if there are more characters for potential next match
    lb $t5, 0($t0)
    beq $t5, $zero, skipComma
    beq $t5, 10, skipComma
    
    # Print comma between matches
    li $v0, 4
    la $a0, comma
    syscall

skipComma:
    # Continue searching from AFTER this match
    move $t8, $t0
    j findFullPattern          # Length of literal
countLiteralLength:
    lb $t3, 0($t1)
    beq $t3, $zero, gotLiteralLength
    addi $t2, $t2, 1
    addi $t1, $t1, 1
    j countLiteralLength

gotLiteralLength:
    # t0 = start, need to find end
    # Find where range part ends and literal begins
    move $t1, $t0
findRangeEnd:
    lb $t3, 0($t1)
    beq $t3, $zero, skipCommaCheck
    beq $t3, 10, skipCommaCheck
    
    # Check if this is start of literal
    la $t4, storeBuffer
    lb $t5, 0($t4)
    beq $t3, $t5, foundLiteralStart
    addi $t1, $t1, 1
    j findRangeEnd

foundLiteralStart:
    # t1 points to start of literal
    add $t1, $t1, $t2      # Move past literal
    
    # Check if there are more characters after match
    lb $t3, 0($t1)
    beq $t3, $zero, skipCommaCheck
    beq $t3, 10, skipCommaCheck
    
    # There might be another match, print comma
    li $v0, 4
    la $a0, comma
    syscall

skipCommaCheck:
    addi $t8, $t8, 1
    j findFullPattern

doneEscapeMatch:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
    
    tryMatchFullPattern:
    move $t0, $a0           # Save start position
    move $t1, $a0           # Current scanning position
    
    la $t3, storeBuffer     # Literal string to match
    lb $t4, 0($t3)          # First char of literal
    
    # Find a position where literal might match
findLiteralStart:
    lb $t2, 0($t1)
    beq $t2, $zero, noMatch
    beq $t2, 10, noMatch
    
    # Check if this could be start of literal
    bne $t2, $t4, notLiteralStart
    
    move $a0, $t1
    move $a1, $t3
    addi $sp, $sp, -12
    sw $t0, 0($sp)
    sw $t1, 4($sp)
    sw $ra, 8($sp)
    jal matchLiteralAtPos
    lw $t0, 0($sp)
    lw $t1, 4($sp)
    lw $ra, 8($sp)
    addi $sp, $sp, 12
    
    beq $v0, 1, foundMatchWithRange
    
notLiteralStart:
    # Check if current char is a valid range char
    blt $t2, 65, noMatch           # Below 'A'
    bgt $t2, 122, noMatch          # Above 'z'
    blt $t2, 97, checkUpper        # Could be uppercase
    j isLower                      # Is lowercase

checkUpper:
    bgt $t2, 90, noMatch           # Between 'Z' and 'a'
    j continueSearch

isLower:
    bgt $t2, 122, noMatch
    
continueSearch:
    addi $t1, $t1, 1
    j findLiteralStart

foundMatchWithRange:

    li $v0, 1
    move $v1, $t0          # Return start position (beginning of range part)
    jr $ra

noMatch:
    li $v0, 0
    jr $ra

printMatch:
    move $t6, $a0           # Start of match
    
    la $t3, storeBuffer     # Literal string
    lb $t4, 0($t3)          # First char of literal
    
findLitStartForPrint:
    lb $t7, 0($t6)
    beq $t7, $zero, printDone
    beq $t7, 10, printDone
    

    bne $t7, $t4, printRangeChar
    
    move $a0, $t6
    move $a1, $t3
    addi $sp, $sp, -8
    sw $t6, 0($sp)
    sw $ra, 4($sp)
    jal matchLiteralAtPos
    lw $t6, 0($sp)
    lw $ra, 4($sp)
    addi $sp, $sp, 8
    
    beq $v0, 1, printLiteralPart
    # Not a match, print as range char and continue
    j printRangeChar

printRangeChar:
    li $v0, 11
    move $a0, $t7
    syscall
    addi $t6, $t6, 1
    j findLitStartForPrint

printLiteralPart:
    # Print the entire literal
    la $t4, storeBuffer
    
printLitLoop:
    lb $t7, 0($t4)
    beq $t7, $zero, printDone
    
    li $v0, 11
    move $a0, $t7
    syscall
    
    addi $t4, $t4, 1
    j printLitLoop

printDone:
    jr $ra


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


printPrecedingRangeAndLiteral:
    addi $sp, $sp, -16
    sw $ra, 0($sp)
    sw $a0, 4($sp)
    sw $s0, 8($sp)
    sw $s1, 12($sp)
    
    move $t9, $a0
    
    move $t8, $t9
    addi $t8, $t8, -1

    la $t0, inputBuffer
    blt $t8, $t0, noPrecedingChars

backtrackLoop:
    blt $t8, $t0, foundSequenceStart  # Reached start of buffer
    
    lb $t7, 0($t8)
    
    # Check if char is in the parsed range [stored in $s0-$s1]
    blt $t7, $s0, foundSequenceStart  # Below range
    bgt $t7, $s1, foundSequenceStart  # Above range
    
    addi $t8, $t8, -1
    j backtrackLoop
    
foundSequenceStart:
    addi $t8, $t8, 1
    
    j startPrinting
    
noPrecedingChars:
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
# Existing match functions 
#############################################################################################################

matchNoBracket:
la $t4, storeBuffer   # regex literal
la $t8, inputBuffer   # input pointer

matchNoBracketLoop:
lb $t7, 0($t8)        # current input char
beq $t7, $zero, noBracketDone   # end of input

# attempt to match literal sequence
la $t4, storeBuffer      # start of literal
move $t9, $t8            # temporary pointer to scan input
li $s5, 1                # assume match success

literalMatchLoop:
lb $t6, 0($t4)           # next char of literal
beq $t6, $zero, literalMatched   # success, end of literal
beq $t6, 10, literalMatched      # also handle newline
    
lb $t7, 0($t9)           # next char of input
beq $t7, $zero, literalFailed    # input ended early
beq $t7, 10, literalFailed       # input newline before literal ends
bne $t7, $t6, literalFailed      # mismatch

addi $t4, $t4, 1
addi $t9, $t9, 1
j literalMatchLoop

literalMatched:
# Save the match end position
move $s7, $t9  # t9 points to character after the match
    
# print literal
la $t4, storeBuffer
printLiteralLoopA:
lb $t6, 0($t4)
beq $t6, $zero, afterLiteralPrint
beq $t6, 10, afterLiteralPrint   # handle newline
    
li $v0, 11
move $a0, $t6
syscall
    
addi $t4, $t4, 1
j printLiteralLoopA

afterLiteralPrint:
move $t4, $s7  # Position after current match
    
# Skip newline/null check
lb $t6, 0($t4)
beq $t6, $zero, skipCommaLiteral   # No more characters
beq $t6, 10, skipCommaLiteral      # Just newline left
    
scanRemaining:
move $t5, $t4  
    
scanLoop:
lb $t6, 0($t5)
beq $t6, $zero, skipCommaLiteral   # End of input
beq $t6, 10, skipCommaLiteral      # End of line
    
# Try to match literal starting at t5
la $t7, storeBuffer
move $t1, $t5
    
tryMatch:
lb $t2, 0($t7)
beq $t2, $zero, foundMatch    # Success!
beq $t2, 10, foundMatch       # Or newline
lb $t3, 0($t1)
beq $t3, $zero, scanNext      # Input ended
beq $t3, 10, scanNext         # Or newline
bne $t2, $t3, scanNext        # Mismatch
    
addi $t7, $t7, 1
addi $t1, $t1, 1
j tryMatch
    
foundMatch:
# Another match exists, print comma
li $v0, 4
la $a0, comma
syscall
j skipCommaLiteral
    
scanNext:
addi $t5, $t5, 1
j scanLoop

skipCommaLiteral:
# Continue searching from next character
addi $t8, $t8, 1
j matchNoBracketLoop

literalFailed:
addi $t8, $t8, 1        # advance scan pointer on failure
j matchNoBracketLoop

noBracketDone:
jr $ra

matchBracket:
    beq $s3, $zero, matchNoRange
    bne $s2, $zero, negateStarRange
    bne $t2, $zero, matchStarRange
    j matchRange

matchRange:
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

donePrint:
    jr $ra

matchNoRange:
    li $t5, 0
    la $t4, storeBuffer
    move $t5, $t4
    
matchNoRangeLoop:
    lb $t7, 0($t8)
    beq $t7, $zero, donePrint
    beq $t7, 10, donePrint
    
    move $t4, $t5
    
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
    beq $s2, $zero, matchStarNoRange
    li $t6, ','
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

nextStarChar:
    beq $t5, $zero, skipCommaA
    li $v0, 4
    la $a0, comma
    syscall
    li $t5, 0

skipCommaA:
    addi $t8, $t8, 1
    j matchStarLoop

donePrintStar:
    jr $ra
    
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









































