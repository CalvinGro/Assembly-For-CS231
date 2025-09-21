# Title:       copy_replace.s
# Auther:      Calvin Gross
# Date:        9/15/25
# Description: This program modifies a user inputed paragraph by replacing any
#              target word with a given replacement word. It takes in up to 10 
#              lines from the user as a paragraph. Then it takes in the target 
#              word to replace and the word it will replace it with. Then it 
#              loops through each character in the paragrah and checks if it is 
#              equal to the first char in the target. If it is equal, then it  
#              loops through the rest of target comparing each char to the next 
#              char in the line. If all the others are the same it replaces it.
        .section .data

input_paragraph:   .space   800
output_paragraph:  .space   1000

input_line:        .space   80
para_input_msg:    .asciz   "\nPlease input the next line or press (Enter) to end the paragraph: "
offset:            .quad    0       # pointer for tracking where to put the next line in input_paragraph.
word_input_msg:    .asciz   "\nPlease input the %s word: "
target:            .asciz   "target"
replacement:       .asciz   "replacement"
users_target:      .space   20
users_replacement: .space   20
fmt_s:             .asciz   "%s\n"
intro_msg:         .ascii   "____________________________________________________________\n"
                   .ascii   " This program replaces all instances of one word with\n"
                   .ascii   " another in a paragraph. First, input the paragraph line\n"
                   .ascii   " by line, then the target word, and finally the replacement\n"
                   .ascii   " word. Then the program prints the resulting paragraph.\n"
                   .asciz   "____________________________________________________________\n"
output_msg:        .asciz   "\nNewly formed Paragraph:"



        .section .text
        .global main
main:
        # prints intro message
        leaq    fmt_s, %rdi
        leaq    intro_msg, %rsi               # sets the second arg of printf to be intro_msg.
        xorq    %rax, %rax                    # clears %rax register.
        call    printf

        call    get_paragraph

        # gets user input for target word and puts it at the users_target, spot in memory.
        leaq    target, %rdi                  # first arg for get_word - this is the word used in the input message
        leaq    users_target, %rsi            # second arg for get_word - this is the address where the user input is stored.
        call    get_word                      # used to get target word

        # gets user input for replacement word and puts it at the users_replacement, spot in memory.
        leaq    replacement, %rdi             # first arg for get_word - this is the word used in the input message
        leaq    users_replacement, %rsi       # second arg for get_word - this is the address where the user input is stored.
        call    get_word                      # used to get replacement word

        call    make_output_paragraph

        # print message labeling output
        leaq    fmt_s, %rdi
        leaq    output_msg, %rsi              # sets the second arg of printf to be the address of output_msg
        xorq    %rax, %rax                    # clears %rax register.
        call    printf

        # prints actual output paragraph
        leaq    fmt_s, %rdi
        leaq    output_paragraph, %rsi        # sets the second arg of printf to be the address of output_paragraph
        xorq    %rax, %rax                    # clears %rax register.
        call    printf

        ret


make_output_paragraph:
        leaq    output_paragraph, %r14        # stores the address of the output_paragraph in %r14
        leaq    input_paragraph, %r13         # stores the address of the input_paragraph in %r13
        leaq    users_target, %r12            # stores the address of the target in %r12
        leaq    users_replacement, %r10       # stores the address of the replacement in %r10     

        movq    %r12, %rdi                    # set address of the target as the argument for strlen.
        call    strlen
        movq    %rax, %r11                    # store length of target in %r11

while:  
        cmpb    $'\0', (%r13)                 # checks if the end of the input_paragraph has been reached
        je      done                          # if so jmp to done

        movq    %r12, %rdi
        movq    %r13, %rsi
        call    is_target                     # check if the current values are equal to the target

        cmpl    $0, %eax                      # it is not the start of the target
        je      not_equal

# the char is the the start of the target        
        addq    %r11, %r13                    # add the length of target to the pointer for the input_paragrah to skip over the target word
        decq    %r13                          # need to go one back because of \n being part of the length of the taget.
        movq    %r10, %r9                     # temporary pointer for the index of the replacement word
        
replacment_loop:
        cmpb    $'\0', (%r9)                  # checks if the end of the replacement has been reached via \0
        je      while                         # if so jmp to while and countinue checking the next char
        cmpb    $'\n', (%r9)                  # checks if the end of the replacement has been reached via \n
        je      while                         # if so jmp to while and countinue checking the next char

        movb    (%r9), %cl                    # store the current char of the replacement word at %cl
        movb    %cl, (%r14)                   # put the current char at %cl at the next spot in the output_paragraph
        incq    %r9                           # increment the counter for the index in the  replacement word
        incq    %r14                          # increment the counter for the index in the output_paragraph

        jmp     replacment_loop
        

not_equal:
        movb    (%r13), %cl                   # set what is at the pointer for input_paragraph to %cl
        movb    %cl, (%r14)                   # put the byte at %cl in the output_paragraph
        incq    %r13                          # increment the pointer for the input_paragraph
        incq    %r14                          # increment the pointer for the output_paragraph
        jmp     while

done:   
        movb    $'\0', %cl                   # put \0 in %cl
        movb    %cl, (%r14)                  # add \0 - %cl to the end of the output_paragraph
        ret
        
# checks if  char in the paragraph is the start of the target
# parameter-1 - %rdi is the address of the first char in the target word.
# parameter-2 - %rsi is current position in the paragraph.
# return type - bool (0 or 1)
is_target:
        movb    (%rdi), %r8b
        cmpb    %r8b, (%rsi)                  # compares the target's current char to the current paragraph char
        jne     not_target                    # returns false (0) if the chars are not equal
        incq    %rdi                          # increments to next char in the target word
        incq    %rsi                          # increments to next char in the paragraph

        cmpb    $'\0', (%rdi)                 # Checks if the end of the target has been reached via \0 and
        je      found_target                  # returns true if so.
        cmpb    $'\n', (%rdi)                 # Checks if the end of the target has been reached via \n and
        je      found_target                  # returns true if so.

        jmp     is_target                     # while loop
found_target:
        movl    $1, %eax                      # return value = 1 (true)
        ret
not_target:
        movl    $0, %eax                      # return value = 0 (false)
        ret

# parameter-1 - %rdi is the word type in ascii as a string.
# parameter-2 - %rsi is address where the user inputed word is stored.
get_word:  
        movq    %rsi, %r14                    # stores the address of where the inputed word will go in %r14.
        movq    %rdi, %rsi                    # moving the target word into the second arg.
        leaq    word_input_msg, %rdi          # move the user input message to arg 1.
        xorq    %rax, %rax                    # clear rax.
        call    printf


        movq    %r14, %rdi                    # sets %rdi, the first arg of fgets, to the address stored at %r14.
        movq    $20, %rsi                     # sets 20 as the second arg of fgets.
        movq    stdin(%rip), %rdx             # sets stdin as the third arg of fgets.
        call    fgets 

        # remove \n on word
        movq    %rax, %rdi                    # put the index of the word from fgets as the arg for strlen
        call    strlen                         
        decq    %rax                          # dec length of string
        add     %r14, %rax                    # add address of the word to the length of string = address of \n    
        movb    $'\0', (%rax)                 # replace \n with \0

        ret



# function that gets user input and puts it into a paragraph stored at input_paragraph.
get_paragraph:
        # preparing variables
        movq    offset, %r8                 # put the offset in %r14 so we can access it. %rip used for rip-relative addressing.
        leaq    input_paragraph, %r13       # put the input_paragraph in %r13 for easy access as well.
        addq    %r8, %r13                   # add the offset (how many bytes alreay used) to the address of the 
                                            # paragraph. That way it starts where the last line ended.             
        xorl %r15d, %r15d                   # clear %r15d to use as while loop counter.

gp_while:  
        cmpl    $10, %r15d                  # if the count is equal to 10 exit while loop.
        je      gp_next
        
        # prints a message to prompt the user for a line
        leaq    para_input_msg, %rdi        # sets the first arg of printf to be para_input_msg
        xorq    %rax, %rax                  # clears %rax register.
        call    printf

        # gets the users string input and puts it at %rdi, where the previous line ended. 
        # (if there was a prev line, otherwise just at the address of input_paragraph)
        movq    %r13, %rdi                  # sets %rdi, the first arg of fgets, to the pointer %r13 which tracks the current location in input_paragraph.
        movq    $80, %rsi                   # sets 80 as the second arg of fgets.
        movq    stdin(%rip), %rdx           # sets stdin as the third arg of fgets.
        call    fgets 
        incl    %r15d                       # increments counter that tracks if 10 lines have been inputed yet.

        # checks if input was a new line.
        cmpb    $'\n', (%rax)               # compare the byte (character) at the address stored in %rax to '\n' and jump to next if equal.
        je      gp_next      

        # finds length of input, including /n.
        movq    %rax, %rdi                  # move address of the added line to %rdi as the argument for strlen.
        call    strlen

        addq    %rax, %r13                  # Set start address of the next line to the address of the null char of the last line.
                                            # This added the length of the added line to the starting address of it.
        jmp      gp_while                   # continue looping                 

gp_next:
        incq    %rax                        # increment past 
        incq    %rax                        # last line containing \n
        movb    $'\0', (%rax)               # add null terminator
        xorq    %rax, %rax                  # clear %rax because get_paragraph returns nothing
        ret



.section    .note.GNU-stack,"",@progbits

