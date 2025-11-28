/*
Author - Calvin Gross
Date - 11/23/25
Modified - 11/25/25
Project Title - Merge Sort Program
Helper File Title - Merge
Description -   This is a macro to merge two adjacent sections of an array.
                It uses a merge function to do so.
*/

    .section .data
str_number:         .space   11

sorted:             .space   32000          

        .section .text

# MACROS

# Macro to merge two sorted adjacent sections of an array.

merge: .macro fir, sec, end
    movq \fir, %rsi
    movq \sec, %rdi
    movq \end, %rdx
    call fn_merge
        .endm


# PARAMETERS: %rsi = fir
#             %rdi = sec
#             %rdx = end
fn_merge:
    movq %rdi, %r8                # set %r8 at the end of the first section  
    xorq %r9, %r9                 # index for sorted array          
    addq $4, %rdx                 # set the end of the second section 
    movq %rsi, %rcx               # store address at %rsi in %rcx for adding numbers back into the array


loop:
    cmpq %rsi, %r8                # if all the elements of the first section have been added check rdi
    je check_rdi

    cmpq %rdi, %rdx               # if all the elements of the second section have been added, inc rsi 
    je inc_rsi


    movl (%rsi), %r11d
    cmpl %r11d, (%rdi)            # compare, if %rsi is smaller increment it
    jg inc_rsi

    # otherwise %rsi is larger so rdi is added
inc_rdi:
    movl (%rdi), %r10d
    movl %r10d, sorted(, %r9, 4)  # add %rdi to the list of sorted 
    addq $4, %rdi                 # increment index of %rdi
    incq %r9                      # increment index for the array

    jmp loop

    # %rdi is larger or is used up so %rsi is added
inc_rsi:
    movl (%rsi), %r10d
    movl %r10d, sorted(, %r9, 4)  # add %rdi to the list of sorted 
    addq $4, %rsi                 # increment index of %rsi
    incq %r9                      # increment index for the array

    jmp loop

check_rdi:
    cmpq %rdi, %rdx               # if all the elements of the first section have also been added it is done
    jne inc_rdi


    movl $0, sorted(, %r9, 4)     # add null char at the end of the array

# finished creating sorted array

    xorq %r9, %r9                 # clear %r9 to store index in sorted
    movl sorted(, %r9, 4), %r8d   # put the current number in %r8d

add_back_loop:
    cmpl $0, %r8d                 # jump to done once all the numbers in sorted have been looped through
    je done

    movl %r8d, (%rcx)             # put the current number back into the array
    addq $4, %rcx                     # inc the index in the sorted array
    incq %r9                      # inc the index in the array
    movl sorted(, %r9, 4), %r8d   # put the new number in %r8d
    jmp add_back_loop

done:
    ret


