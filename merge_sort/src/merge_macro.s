/*
Author   - Calvin Gross
Created  - 11/23/25
Modified - 11/25/25
           12/3/25
           12/4/25
           12/6/25
Project Title     - Merge Sort Program
Helper File Title - Merge Macro
Description -   This is a macro to merge two adjacent sections of an array.
                It takes in the addresses (not indices) of the start, middle 
                and end of the section getting merged. It calls a merge function
                to complete the merge.
*/

    .section .data

sorted:             .space   32004         

        .section .text


# Macro to merge two sorted adjacent sections of an 
# array of integers.
# Paramters: fir - address of the start of the first section
#            sec - address of the end of the first section and used to find the start of the second section
#            end - address of the end of the second section
# Uses: %rcx, %rsi, %rdi, %rdx, %r8, %r9, %r10, %r11, and %r15
# Return: None
merge: .macro fir, sec, end
    movq \fir, %rsi
    movq \sec, %rdi
    movq \end, %rdx
    call fn_merge
        .endm



# ___Merge_Function___
#   Modifying function used to merge two adjacent sections
# of an array given the address of the sections.
# Parameters: start address  - %rsi
#             middle address - %rdi
#             last address   - %rdx
# Returns: None
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
    jae inc_rsi

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

# finished creating sorted array
    movq %r9, %r15                # store index at the end of the array
    xorq %r9, %r9                 # clear %r9 to store index in sorted
    movl sorted(, %r9, 4), %r8d   # put the current number in %r8d
    

add_back_loop:
    cmpq %r15, %r9             # done once all the numbers in sorted have been looped through
    je done

    movl %r8d, (%rcx)             # put the current number back into the array
    addq $4, %rcx                 # inc the index in the sorted array
    incq %r9                      # inc the index in the array
    movl sorted(, %r9, 4), %r8d   # put the new number in %r8d

    jmp add_back_loop
done:
    ret
    