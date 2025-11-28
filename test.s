

        .include "merge_sort_macros.s"

       .section .data

num:        .quad   123352



        .section .text
        .globl  main
main:
        sys_print_int (num)
        ret
    
.section    .note.GNU-stack,"",@progbits