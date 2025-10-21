          .section .data

buf1:     .asciz  "This is a number %d\n"

seed:     .quad   5478393011

          .section .text

          .global main

main:

          # move seed value into %rdi  
          # call srand only one time to randomize
          movq seed, %rdi      # set seed value to randomize for the rand function
          call srand          # 

do_rand:  call rand           # get a random number, rand returns the random number in %rax

          leaq buf1, %rdi     # move format string to %rdi
          movq %rax, %rsi     # move the random number to %rsi for printing 
          xorq %rax, %rax     # clear %rax
          call printf         # print random number

          movq $1, %rax       # exit program
          movq $0, %rbx       # exit code 
          int  $0x80

