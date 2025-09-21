# Title:       simple_assember.s
# Auther:      Calvin Gross
# Date:        9/13/25
# Description: This program takes in a string from the user. Then
#              it prints it out one char at a time on seprate lines.
#              Then it prints the length of the string.




# section to initialize vars 
         .section .data

intro:      .ascii  "______________Simple String Character Counter______________\n"
            .ascii  " By: Calvin Gross\n\n"
            .ascii  " Description: This program takes in a line you input\n"
            .ascii   "   and returns each charater from the line on a seprate\n"
            .asciz   "   line. Then it prints out the total character count.\n"

inpmsg:     .asciz  "\nPlease input your string: "
inputstr:   .space  80
char:       .asciz  "%c\n"
count:      .byte   0
lenmsg:     .asciz  "\nThe line has %ld characters.\n\n"
prtmsg:     .asciz  "\nCharacter Occurrences:\n"


        .global main

        .section .text
main:
        # prints title and description message
        leaq    intro, %rdi     # moves address of intro into %rdi.
        xorq    %rax, %rax      # clears %rax register.
        call    printf

        # prints a message to prompt the user for a string
        leaq    inpmsg, %rdi    # sets the first arg of printf to be inpmsg
        xorq    %rax, %rax      # clears %rax register.
        call    printf

        # gets the users string input
        leaq    inputstr, %rdi  # sets inputstr as the first arg of fgets.
        movq    $80, %rsi       # sets 80 as the second arg of fgets.
        movq    stdin(%rip), %rdx   # sets stdin as the third arg of fgets.
        call    fgets

        # preping for while loop
        movq    %rax, %rbx      # storing the address of inputstr in rbx because rax is cleared for printf.
        xorq    %rbp, %rbp      # rbp = 0 counter for str length.

        
        # prints the character occurences message
        leaq    prtmsg, %rdi    # sets the first arg of printf to be prtmsg
        xorq    %rax, %rax      # clears %rax register.
        call    printf

# prints each char on a new line using a while loop.
while:  cmpb    $0, (%rbx)      # comparing what is actually at rbx - because of the parentheses. jump to next if \0
        je      next

        cmpb    $10, (%rbx)     # jump to next if \n found. (10 is ascii value of \n)
        je      next

        # body of while loop
        leaq    char, %rdi      # move char into first arg for printf
        movzbl (%rbx), %esi     # (2nd arg) moves the char stored at rbx to esi and zeros out the rest of rsi. 
        xorq    %rax, %rax      # clears %rax
        call    printf

        incq    %rbx            # moves the pointer(rbx) to the next char in the inputstr.
        incq    %rbp            # increment counter for string length
        
        # jump back up to the top of while for the next iteration of the while loop.
        jmp     while


# prints final message about length of the input
next:   leaq    lenmsg, %rdi    # sets lenmsg as first arg for printf
        movq    %rbp, %rsi      # sets counter(%rbp) as the second arg for printf
        xorq    %rax, %rax      # clears %rax
        call    printf             


# exits program
exit:   
        xorq    %rax, %rax      # sets return to nothing by clearing rax.
        ret




