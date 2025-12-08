/*
Author   - Calvin Gross
Created  - 11/29/25
Modified - 12/1/25
           12/3/25
           12/5/25
           12/6/25
           12/7/25
Project Title - Merge Sort Program
Helper Files  - merge_sort_macro.s
                macro_library.s
                fileIO_macros.s
                merge_macro.s
Description   -     This is the main file of my merge sort. I structured 
                my program using encapsulation via macros because i prefer
                how clean their parameters look. Thus, almost every task  
                is preformed by a macro including the merge sort.
                    I take in the file to read from and then the number of 
                integers to read out of the file. Then I read in the integers.
                If there are less than 5000 integers I simply print the unsorted 
                integers and then sort them and print the sorted integers.
                Otherwise I print the integers to a file after they are sorted.
                    I also track how many merges take place in my merge sort and 
                use a check function to varify that it was sorted properly.
*/


        .include "fileIO_macros.s"
        .include "merge_sort_macro.s"
        .section .data

intro_msg:      .ascii  "\n_____________________Welcome to Merge Sort_____________________\n"
                .ascii  "    This program takes in a file to input integers from. Then\n"
                .ascii  "    it takes in the count of how many integers to sort. If the\n"
                .ascii  "    number is over 5000 then it outputs the sorted numbers to a\n"
                .ascii  "    file. Otherwise, it just prints the unsorted integers and\n"
                .ascii  "    then prints them again after they are sorted. This program\n"
                .ascii  "    allows tracks the number of merges that occured. It also\n"
                .ascii  "    runs a function to verify that the sort was correct.\n"
                .asciz  "_______________________________________________________________\n"

unsorted_msg:   .asciz  "\n            _________________Unsorted_List_________________\n"
sorted_msg:     .asciz  "\n\n\n            __________________Sorted_List__________________\n"

source_name_msg:  .asciz  "\nPlease input the name of the source file: "
output_name_msg:  .asciz  "\nPlease input a new file name for the output: "
count_msg:        .asciz  "\n\nPlease input the number of integers to input: "
merge_msg:        .asciz  "\nNumber of merges that occurred: "
ints_merged_msg:  .asciz  "\nNumber of integers merged: "

in_order:       .asciz  "\n\nThe check function varified that the numbers are in order.\n\n"
out_order:      .asciz  "\n\nThe check function found that the numbers are out of order.\n\n"
count:          .long   0
count_str:      .space  10

int_array:      .space  32000
file_name:      .space  100
new_file_name:  .space  100
stdout:         .quad   1

        .section .text

        .global main

main:
    # print intro message
    sys_print intro_msg, stdout

    # get file name
    sys_print source_name_msg, stdout
    sys_input file_name
    
    # get count 
    sys_print count_msg, stdout
    sys_input count_str
    str_to_int count_str
    movl %eax, count

    # open file and read integers from it 
    open_file file_name
    read_file int_array, count
    close_file

    # compare count to 5000 to determine if the output is 
    # printed to a file or just stdout.
    movl $5000, %r14d
    cmpl count, %r14d
    jl use_file


    # otherwise if less than 5000 numbers print unsorted array to stdout
    sys_print unsorted_msg, stdout
    print_array int_array, count

    xorq %r14, %r14                         # clear %r14 and use it to track the number of merges that are preformed
    xorq %r12, %r12                         # clear %r12 to track total integers merged
here:
    # merge sort the array
    movq $0, %r9
    xorq %r10, %r10
    movl count, %r10d
    decl %r10d                              # decrement count by one to account for 0 indexing
    merge_sort int_array, %r9, %r10         # preform the merge sort

    # print merge count 
    sys_print merge_msg, stdout
    sys_print_int %r14d, stdout

    # print number of integers that were merged
    sys_print ints_merged_msg, stdout
    sys_print_int %r12d, stdout
    
    # print the sorted array to stdout
    sys_print sorted_msg, stdout
    print_array int_array, count

    jmp verify_sort

use_file:
    # get new file name
    sys_print output_name_msg, stdout
    sys_input new_file_name
    sys_print new_file_name, stdout

    # merge sort the array
    movq $0, %r9
    xorq %r10, %r10
    movl count, %r10d
    decl %r10d                              # decrement count by one to account for 0 indexing
    merge_sort int_array, %r9, %r10         # preform the merge sort

    # print to new file
    open_file new_file_name
    print_to_file int_array, count
    close_file

verify_sort:
    xorq %r8, %r8                           # use %r8 to track the current index
    incq %r8                                # start at index 1 because it will be compared to the integer before it
    leaq int_array, %r9

    movl (%r9), %r10d                       # move the integer at the first index of the array into %r10d
    
verify_loop:
    cmpl count, %r8d                         # if the current index is at the end, then jump out of the loop
    je verified

    cmpl (%r9, %r8, 4), %r10d               # compare current integer to the one before it
    jg wrong                                # jump to wrong if the one before it is larger

    movl (%r9, %r8, 4), %r10d               # otherwise move the current integer into %r10d for the next comparison

verified:
    sys_print in_order, stdout
    ret

wrong:
    sys_print out_order, stdout
    ret

.section    .note.GNU-stack,"",@progbits
