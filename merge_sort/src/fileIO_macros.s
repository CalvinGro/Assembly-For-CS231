/*
Author   - Calvin Gross
Created  - 11/25/25
Modified - 11/26/25
           11/28/25
           11/29/25
           12/1/25
           12/2/25
           12/6/25
           12/7/25
Project Title     - Merge Sort Program
Helper File Title - Merge Sort File I/O Macros
Description -   These are macro to handle file input and output.
                It contains macros to open a file, close a file,
                read a file into an array, and print to a file.
*/

        .include "macro_library.s"

        .section .data
line_buf:         .space   7

new_line:         .asciz "\n"
space_char:       .asciz " "

        .section .text

# Macro to open a file.
# Parameter: file - name of the file
# Uses: %rax, %rdi, %rsi, %rdx, and %r15
# return: %r15 - file descriptor
open_file: .macro file
    movq $2, %rax                   # use sys_open
    leaq \file(%rip), %rdi          # put file in %rdi
    movq $0102, %rsi                # set flags to allow for reading, writing, and creation
    movq $0644, %rdx                # define accessability
    syscall
    movq %rax, %r15                 # put file descriptor in %r15
        .endm



# Macro to close the file at %r15. 
# Parameter: %r15 - containing file descriptor
# Uses: %rax, %r15, and %rdi
# Return: none
close_file: .macro
    movq $3, %rax                   # use sys_close
    movq %r15, %rdi                 # file descriptor of file getting closed
    syscall
        .endm



# Macro to read the file at %r15 into an array.
# Parameters: %r15 - containing file descriptor
#             adr - the address of the array
#             count - how many numbers to read
# Uses: %r9, %r10, %r12, %r14, %r15, %rax, %rsi, %rdi, and %rdx
# Return: None
read_file: .macro adr count
    leaq \adr, %r14                 # use %r14 to store the adr of the numbers array
    movl \count, %r12d              # count used in countdown loop
    call fn_read_file
        .endm
    


# Macro to print to an open file using a given 
# array of integers. 
# Paramters: adr - address of the integer array
#            count - number of integers to print
# Uses: %r8, %r9, %r13, and %r15
# Return: None
print_to_file: .macro adr count
    leaq \adr, %r8                  # move address of array into %r8
    xorq %r9, %r9
    movl \count, %r9d               # move count of nums to print into %r9d
    call fn_print_to_file           # call function to print to file at %r15 
        .endm



# Macro to print to stdout using a given array of
# integers. It prints in rows of 15 numbers at a time.
# Paramters: adr - address of the integer array
#            count - number of integers to print
# Uses: %r8, %r9, %r11, %r12, %r13, %rax, and %rdx
# Return: None
print_array: .macro adr count
    leaq \adr, %r8
    movl \count, %r9d
    call fn_print_array
        .endm



# ___Print_Array_Function____
#   Function to print the a set number of integers from
# the given array. It prints them in rows of 15.
# Parameters: Array Address   - %r8
#             Integer Count   - %r9d
# Return: None
fn_print_array:
    xorq %r12, %r12                 # clear %r12 to uses as index in the array of integers

printing_loop:
    cmpq %r12, %r9                  # once the index reaches the count, then the print loop is done
    je done_printing

    movl (%r8, %r12, 4), %r11d      # move the integer getting printed into %r11d
    sys_print_int %r11d, $1         # print the integer to stdout
    sys_print space_char, $1        # add space after every integer
    incq %r12                       # increment the index to the next value

    # check if current index mod 15 is 0. If so add \n
    movq %r12, %rax                 # put index value in %rax for division
    xorq %rdx, %rdx                 # clear %rdx for division
    movq $15, %r13                  # move 15 into %r13 to use as divisor
    divq %r13                       # preform the division

    cmpq $0, %rdx                   # check if current index mod 15 is 0, if so add a newline
    jne printing_loop

    sys_print new_line, $1          # print newline after every 15 numbers
    jmp printing_loop

done_printing:
    ret



# ___Read_File_Function____
#   Function to read a set number of integers from the
# file at %r15 and store the content in a given array.
# Parameters: Array Address   - %r14
#             File Descriptor - %r15
#             Integer Count   - %r12d
# Return: None
fn_read_file:
    xorq %r10, %r10                 # clear %r10 to uses as index in the numbers array at adr

read_next: 
    # find integer: skips through \r, \n, etc bytes.
    leaq line_buf, %r9              # use to store index in line buffer; resets each read_next loop
    
while_not_numbers:
    movq $0, %rax                   # read sys call
    movq %r15, %rdi                 # using file from file descriptor stored at %r15
    movq %r9, %rsi                  # store byte in the line buffer, but don't advance %r9 so the byte does not get saved.
    movq $1, %rdx                   # read 1 byte at a time
    syscall
    
    cmpb $'0', (%r9)                # check if current byte is greater or equal to '0'
    jl while_not_numbers

    cmpb $'9', (%r9)                # check if current byte is less than or equal to '9'
    jg while_not_numbers

    incq %r9                        # if the value added was an integer, advance to while_numbers loop 
                                    # and advance %r9 index to save the integer value in line_buf.             
while_numbers:                      # while the current value read from the file is a number
    movq $0, %rax                   # read sys call
    movq %r15, %rdi                 # using file from file descriptor stored at %r15
    movq %r9, %rsi                  # store input in the line buffer
    movq $1, %rdx                   # read 1 byte at a time
    syscall
    
    cmpb $'0', (%r9)                # check if current byte is greater or equal to '0'
    jl out_of_range

    cmpb $'9', (%r9)                # check if current byte is less than or equal to '9'
    jg out_of_range

    incq %r9
    jmp while_numbers               # if the value added was an integer, read another byte from the file

out_of_range:
    movb $0, (%r9)                  # replace last byte (which is a non-integer) with a null char

    str_to_int line_buf             # take the number stored at line_buf and turn to integer and put in %eax

    movl %eax, (%r14, %r10, 4)      # put int in number array
    incq %r10                       # inc index for number array

    decl %r12d                      # if this was the last integer end function; uses countdown loop
    jnz read_next
    ret



# ___Print_to_File_Function____
#   Function to print to an open file at %r15 using an
# address of an array. 
# Parameters: Array Address   - %r8
#             File Descriptor - %r15
# Returns: None
fn_print_to_file:
    xorq %r13, %r13
    movl (%r8), %r13d
    sys_print_int %r13d, %r15       # print int at %r8 in the file at the file descriptor %r15
    sys_print new_line, %r15
    addq $4, %r8                    # increment the index at %r8
    
    decl %r9d                       # if count reached using countdown loop, then done
    jnz fn_print_to_file      

    ret                             # if null char hit 
