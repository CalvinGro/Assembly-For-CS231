/*
Author   - Calvin Gross
Created  - 12/5/25
Modified - 12/6/25
Project Title     - Merge Sort Program
Helper File Title - Merge Sort Macro
Description - This is the macro to actually do the merge sort on the
              given array. It uses three parameters the address of the
              array in memory, the starting index, and the end index. 
              It runs recursivly and uses the merge macro defined in 
              the "merge.s" file.
*/
        .include "merge_macro.s"
        .section .data

        .section .text

# Macro to preform merge sort on the the array of integers at
# array_adr. Only sorts the section in the given index range.
# Paramters: array_adr - address of the integer array
#            start - starting index in the array
#            end - index of the last int to include in the array
# Uses: %rbp, %rsp, %rax, %rsi, %rdi, %rdx, %r8, %r9, %r10, %r11, and %r13
# Return: None
merge_sort: .macro array_adr start end
    leaq \array_adr, %r13         # load the address of the start of the array into %r13
    movq \start, %r8              # move the start index into %r8
    movq \end, %r9                # move the end index into %r9
    call fn_merge_sort
        .endm



# ___Merge_Sort_Function____
#   Recursive modifying function to merge sort a
# section of an array based on the given parameters.
# Parameters: Array address - %r13
#             Start index   - %r8
#             Last index    - %r9
# Returns: None
fn_merge_sort:
    push %rbp                     # push base pointer onto stack
    movq %rsp, %rbp               # set the base pointer for the next frame

    cmpq %r9, %r8                 # check if the base case has been reached
    jb not_base_case
    pop %rbp                      # if base case reached immediately pop base pointer and return
    ret

not_base_case:
    # calculate middle index and store in %rax
    movq %r9, %rax                # start with the end index
    subq %r8, %rax                # subtract start index to get the difference between them
    shrq $1, %rax                 # then divid the difference by 2 to get the distance between the start and the middle
    addq %r8, %rax                # then add the start index to get the index of the middle

    push %r8                      # push %r8 onto stack to prep for recursive call
    push %r9                      # push %r9 onto stack to prep for recursive call
    push %rax                     # push the middle value onto the stack as well

    mov %rax, %r9                 # set new value for %r9 in the middle and recurse

    call fn_merge_sort            # call merge sort on the bottom half

    pop %rax                      # pop the original middle index
    pop %r9                       # pop the original end index
    pop %r8                       # pop the original start index

    push %r8                      # push %r8 onto stack to prep for recursive call
    push %r9                      # push %r9 onto stack to prep for recursive call
    push %rax                     # push the middle value onto the stack as well

    incq %rax                     # set the %rax to be one passed the end of the first section
    movq %rax, %r8                # move %rax, which now points to the start of the second section, into %r8

    call fn_merge_sort            # call merge sort on the top half

    pop %rax                      # pop the original middle index
    pop %r9                       # pop the original end index
    pop %r8                       # pop the original start index

    movq %r9, %rsi                # put the last index in %rsi
    subq %r8, %rsi                # find the difference between the last and firt indices
    addq %rsi, %r12               # add total number of integers merged in this merge to %r12
    
    incq %rax                     # add one to the middle index to point it to the start of the second sorted section
    leaq (%r13, %r8, 4), %rsi     # load the starting index of the first section getting merged into %rsi
    leaq (%r13, %rax, 4), %rdi    # load the start of the second section (adjacent to the first) getting merged into %rdi
    leaq (%r13, %r9, 4), %rdx     # load the end of the second section getting merged into %rdx
    merge %rsi, %rdi, %rdx        # call the merge macro

    incl %r14d

    pop %rbp                      # pop this frame's base pointer once the function has finished
    ret


















