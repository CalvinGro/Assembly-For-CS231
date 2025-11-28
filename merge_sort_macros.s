/*
Author - Calvin Gross
Date - 11/21/25
Modified - 11/23/25
Modified - 11/26/25
Modified - 11/28/25
Project Title - Merge Sort Program
Helper File Title - Merge Sort Macros
Description -   This is a library of the macros I use throughout my merge
                sort program.
*/

        .section .data
str_number:         .space   11



        .section .text

# MACROS

# Macro to print a string using only one argument, a
# string address. It uses syscalls instead of printf.
# USES: %rax, %rdi, %rsi, $rdx
sys_print: .macro  a

    movq $1, %rax
    movq $1, %rdi
    leaq \a, %rsi
    xorq %rdx, %rdx
    call fn_find_size                # find the size of the string and store it in %rdx
    syscall 
        .endm

# Macro to print an integer. It uses syscalls instead
# of printf.
# USES: %rax, %rdi, %rsi, %rdx, %r10
# PARAMETERS: a is the int getting printed
sys_print_int: .macro a
    movq \a, %rax
    call fn_int_to_str
    movq $1, %rax
    movq $1, %rdi
    leaq str_number(%r10), %rsi
    xorq %rdx, %rdx
    call fn_find_size                # find the size of the string and store it in %rdx
    syscall 
        .endm



# Macro to read in a integer string and turn it into an int
str_to_int: .macro adr
    leaq \adr(%rip), %rcx
    call fn_str_to_int
        .endm



# FUNCTIONS
fn_str_to_int:
    xorl %eax, %eax                  # clear %eax and use it to store int 
    xorq %rbx, %rbx                  # clear %rbx and use as index of array
    xorl %r8d, %r8d                  # clear %r8d and use to stor current character number
    movb (%rcx, %rbx, 4), %r8b      # store current number character in %r8b


str_to_int_loop:
    subb $'0', %r8b                  # subract asci value of 0 to get just the int value
    imull $10, %eax                  # multiply by ten
    addl %r8d, %eax                  # add the int value to %eax


added_digit:

    incq %rbx                        # inc index counter
    movb (%rcx, %rbx, 4), %r8b      # store current number character in %r8b
    cmpb $0, %r8b                    # if null char reached, the loop is done
    jne str_to_int_loop
    ret                              # return value in %rax
    

fn_find_size:                        # find the size of the string
    cmpb $0, (%rsi, %rdx)
    je   done_finding

    incq %rdx
    jmp  fn_find_size
done_finding:
    ret


# function to turn an integer into a string.
# PARAMETERS: %rax is int
# RETURN: int string at (str_number, %r10b)
fn_int_to_str:
    movq $10, %r10                   # start adding at the end of the str_number 
    movb $0, str_number(%r10)
loop_int_to_str:
    decq %r10                        # decrement by 1 to next spot in str_number
    xorq %rdx, %rdx
    movq $10, %rdi
    divq %rdi                        # divid %rax by 10
    addb $'0', %dl                   # turn rdx into asci value
    movb %dl, str_number(%r10)       # add remainder to str_number


    cmpq $0, %rax                    # exit if %rax is zero
    jne loop_int_to_str
           
    ret