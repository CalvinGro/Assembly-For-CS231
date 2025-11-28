/*
Author - Calvin Gross
Date - 11/25/25
Modified - 11/26/25
Modified - 11/28/25
Project Title - Merge Sort Program
Helper File Title - File I/O Macros
Description -   These are macro to handle file input and output.
*/

        .include "merge_sort_macros.s"

     .section .data




        .section .text

# MACROS

open_file: .macro file
    movq $2, %rax
    leaq \file(%rip), %rdi
    movq $0, %rsi
    movq $0644, %rdx
    syscall
    movq %rax, %r15
        .endm
    



read_file: .macro adr
    leaq \adr(%rip), %rcx





# FUNCTIONS
fn_read_file:

read_loop: