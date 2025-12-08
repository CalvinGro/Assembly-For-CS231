/*
Author   - Calvin Gross
Created  - 11/21/25
Modified - 11/23/25
           11/26/25
           11/28/25
           12/1/25
           12/6/25
Project Title     - Merge Sort Program
Helper File Title - Merge Sort Helper Macros
Description -   This is a library of the macros I use throughout my merge
                sort program. It contains macros to take in input, print
                a string, print an integer, and turn an string containing 
                an integer into just its integer value.
*/

        .section .data
str_number:         .space   11
input_str:          .space   100


        .section .text

# MACROS

# Macro to take input of one line up to length 100.
# The length of the line is stored in %rax and the 
# address is stored at lineAdr.
# Parameters: None
# Uses: %rax, %rdi, %rsi, and %rdx
# Return: lineAdr - contains address of inputed line
sys_input: .macro lineAdr
    movq $0, %rax                    # use sys_read
    movq $0, %rdi                    # file descriptor = stdin
    leaq \lineAdr(%rip), %rsi        # load address of where the line is to be stored
    movq $100, %rdx                  # size of allowed input in bytes
    syscall
    movb $0, \lineAdr-1(%rax)        # replace the \n with a null char.
        .endm


# Macro to print a string using only one argument, a
# string address. It uses syscalls instead of printf.
# Parameter: msg - Address of the message getting printed
# Uses: %rax, %rdi, %rsi, $rdx
# Return: None
sys_print: .macro  msg fd
    movq $1, %rax                    # use sys_write 
    movq \fd, %rdi                   # file descriptor; stdout = 1
    leaq \msg, %rsi                  # load address of the message
    xorq %rdx, %rdx                  # clear %rdx to prep for fn_find_size
    call fn_find_size                # find the size of the string and store it in %rdx
    syscall 
        .endm


# Macro to print an integer. It uses syscalls instead
# of printf.
# Parameter: num - Integer getting printed
#            fd  - File descriptor of the file getting printed to
# Uses: %rax, %rdi, %rsi, %rdx, %r10
# Return: None
sys_print_int: .macro num fd
    xorq %rax, %rax
    movl \num, %eax
    call fn_int_to_str
    movq $1, %rax                    # use sys_write
    movq \fd, %rdi                   # put file descriptor in %rdi
    leaq str_number(%r10), %rsi      # %r10 is set by fn_int_to_str to point to the start of the string
    call fn_find_size                # find the size of the string and store it in %rdx
    syscall 
        .endm


# Macro to read in a integer string and turn it into an int
# Parameter: adr - Address of the string
# Uses: %rax, %rbx, %rcx, %rdx, %r8, %rsi
# Returns: %rax - Integer value derived from string
str_to_int: .macro adr
    leaq \adr, %rcx
    call fn_str_to_int
        .endm



# ___String_to_Integer_Function____
#   Function to turn a string to an integer.
# Parameters: String Address - %rcx
# Returns: Integer - %rax
fn_str_to_int:
    xorq %rax, %rax                  # clear %rax and use it to store int 
    xorq %rbx, %rbx                  # clear %rbx and use as index of array
    xorl %r8d, %r8d                  # clear %r8d and use to stor current character integer
    movb (%rcx, %rbx), %r8b          # store current integer character in %r8b

str_to_int_loop:
    subb $'0', %r8b                  # subract asci value of 0 to get just the int value
    imull $10, %eax                  # multiply by ten
    addl %r8d, %eax                  # add the int value to %eax

added_digit:
    incq %rbx                        # inc index counter
    movb (%rcx, %rbx), %r8b          # store current number character in %r8b
    cmpb $0, %r8b                    # if null char reached, the loop is done
    jne str_to_int_loop
    ret                              # return value in %rax



# ___Find_Size_Function____
#   Function to find the size of a string.
# Parameters: String Address - %rsi
# Returns: String Size - %rdx
fn_find_size:                        # find the size of the string
    xorq %rdx, %rdx                  # clear %rdx and use as index in the string
find_size_loop:
    cmpb $0, (%rsi, %rdx)            # if null char found jmp to done_finding and return
    je   done_finding   

    incq %rdx                        # otherwise if null char not found increment the index and continue
    jmp  find_size_loop

done_finding:
    ret



# ___Integer_to_String_Function____
#   Function to turn an integer into a string and
# store the string in the str_number buffer.
# Parameters: Integer - %rax
# Returns: String int - (str_number, %r10b)
fn_int_to_str:
    movq $10, %r10                   # start adding at the end of the str_number 
    movb $0, str_number(%r10)
loop_int_to_str:
    decq %r10                        # decrement by 1 to next spot in str_number
    xorq %rdx, %rdx                  # clear %rdx for division
    movq $10, %rdi                   # move 10 into %rdi as the divisor so it returns the next digit as the remainder
    divq %rdi                        # divid %rax by 10
    addb $'0', %dl                   # turn rdx into asci value
    movb %dl, str_number(%r10)       # add remainder to str_number

    cmpq $0, %rax                    # exit if %rax is zero
    jne loop_int_to_str
           
    ret
