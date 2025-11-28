/*
Author - Calvin Gross
Date     - 10/14/25 
Modified - 10/21/25
Modified - 11/20/25
Project Title - Radix Sort Program
Helper File Title - Macro Library
Description -   This is a library of the macros I use throughout this
              program. I have two print macros, one that takes one argument
              and another that takes 2. The first args will be addresses to
              strings and the second arg for print2 is a integer to print.
              I also have a macro for C's scanf and one to generate random
              numbers. 
                The macro to generate random numbers does not take any args
              and presumes a seed has already been set by srand. It uses 
              C's rand function to generate a number and then divides it by
              50,000 which stores the remainder in %dx.
*/

        .section .text
int_fmt:        .asciz  "%d"    # string to take in an integer for the scaf


# Function to print a string using only one argument, a
# string address. It uses syscalls instead of printf.
sys_print: .macro  a

    movq $1, %rax
    movq $1, %rdi
    leaq \a, %rsi
    xorq %rdx, %rdx
    call fn_find_size           # find the size of the string and store it in %rdx
    syscall 
        .endm


sys_print_int: .macro a



# Function to print a string using only one argument, a
# string address. It uses C's printf function.
print1: .macro  a
    leaq    \a, %rdi		
    xorq    %rax, %rax
    call    printf
        .endm

# Function to print a string using two arguments, a
# string address and an integer. This also uses C's
# printf function.
print2: .macro a, b
    leaq    \a, %rdi		
    movq    \b, %rsi
    xorq    %rax, %rax
    call    printf
        .endm

# Function to take in an integer from stdin. It uses
# C's scanf function.
scan_int: .macro b
    push    %r15            # dummy push to aligh stack
    movq    $int_fmt, %rdi
    leal    \b, %esi  
    xorq    %rax, %rax
    call    scanf
    pop     %r15            # Undo push instruction
        .endm

# Function to generate a random number. It does not have
# any parameters and stores the resulting number in %dx.
# It uses C's rand function to generate a random number 
# and divides it by 50,000. Thus, the remainder is a 
# random number from 1 - 50,000 and is stored in %dx.
generate_rand_num: .macro 
    call    rand            # returned rand number put in %eax
    movq    $50000, %r15    # move the divisor, 50000, into %r15
    xorq    %rdx, %rdx      # clear spot for remainder
    divq    %r15            # remainder now in %dx, cause it is modded by 50000 so it can be stored in 2 bytes
    incw    %dx             # add 1 so range goes from 0-49,999 to 1-50,000.
        .endm               # A random number from 1-50,000 is now stored in %dx

    
fn_find_size:               # find the size of the string
    cmpb $0, (%rsi, %rdx)
    je   done_finding

    incq %rdx
    jmp  fn_find_size
done_finding:
    ret

