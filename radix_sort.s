/*
Author - Calvin Gross
Date - 10/14/25 to 10/21/25
Title - Radix Sort Program
Description -   This program generates a user specified number of integers 
              between 1 and 50000. It then sorts them using a radix sort.
              Then, it prints out up to the first 200 integers. After that
              it runs a function to verify that the array is in order and
              prints the results.
                This create an array in the heap and uses C's rand function
              to input random 2 byte numbers into each element in the array.
              Then it creates another array of the same size to use as the 
              bin for the radix sort.
                Then for the radix sort it loops 16 times using a count down
              loop. Each loop sorts the array using a mask and puts it in 
              either the bin, if the bit is 1 or leaves it in the array. Then 
              it adds back the numbers from the bin at the bottom of the array.
*/


        .include "macro_lib.s"

        .section .data

# for user input handling and generating rand numbers
count_msg:      .asciz  "How many random numbers do you want to generate and sort: "
show_count:     .asciz  "\nThere are %d numbers.\n"
show_int:       .asciz  "%d "
arr_len:        .long   0
cap:            .long   400
seed:           .quad   129562591
nl:             .asciz  "\n"
unsorted_msg:   .asciz  "\n            _________________Unsorted_List_________________\n"
sorted_msg:     .asciz  "\n            __________________Sorted_List__________________\n"
over_200_msg:   .asciz  "\n            ______First_200_Numbers_of_the_Sorted_List_____\n"

intro_msg:      .ascii  "\n_____________________Welcome to Radix Sort_____________________\n"
                .ascii  "    This program takes in an integer of how many numbers to\n"
                .ascii  "    sort and then sorts them. It then outputs the first 200\n"
                .ascii  "    numbers. After that, it runs a function that does a\n"
                .ascii  "    simple check if each number is greater or equal to the\n"
                .ascii  "    number before it. Then it prints the outcome.\n"
                .asciz  "_______________________________________________________________\n"
        .section .text

in_order:       .asciz  "\n\nThe check function varified that the numbers are in order.\n\n"
out_order:      .asciz  "\n\nThe check function found that the numbers are out of order.\n\n"
        .global main

# main function; starts the program, prints messages to the user,
# and receives user input.
main:
    # print intro message
    sys_print intro_msg
    
    sys_print count_msg                # print message to recive user input for how many numbers to generate
    scan_int arr_len                # recive user input and store in address at arr_len
    print2 show_count, (arr_len)      # print number inputed


    # Calculate size of new array in bytes and store it back in arr_len
    movl    (arr_len), %ecx
    addl    %ecx, %ecx
    movl    %ecx, (arr_len)

    # create array of 0s with the proper length
    movl    (arr_len), %edi
    call    malloc
    movq    %rax, %r14              # %r14 now contains array of length 



# function to generate all the random numbers and fill
# the created array with them.
generate_rand_nums:
    xorq    %r12, %r12              # counter for position in array

    movq    seed, %rdi              # set the seed for the random number generation
    call    srand                   # This only happens once so it is outside the macro and generation loop.


generation_loop:
    cmpl    (arr_len), %r12d        # if the array is full
    jae     finished_generation     # then jump to finished_generation

    generate_rand_num               # call macro to generate a random number
    movw    %dx, (%r14, %r12)       # add the random number to the array
    addl    $2, %r12d               # increment the pointer for the array by 2 bytes
    jmp generation_loop

finished_generation:
    # next print, if less than or equal to 200
    cmpl    $400, (arr_len)       
    jg      radix_sort

    # print title for unsorted numbers
    print1 unsorted_msg
    movq    $0, %r13
            
# prints every random number if there are less than 200 numbers.
# Each line contains at max 15 numbers.
print_unsorted_loop:
    cmpl    (arr_len), %r13d        # if the array is fully printed
    jae     radix_sort              # then jump to finished_generation
    
    xorq    %r10, %r10              # clear %r10 
    movw    (%r14, %r13), %r10w     # store a 2 byte value of the array in %r10
    print2 show_int, %r10           # print the number
    
    addl    $2, %r13d

    # check if 15 numbers have been printed on the current line, if so add a newline
    xorq    %rdx, %rdx              # clear rdx to store remainder
    movq    $30, %r11               # modifier is 30 so 15 numbers of 2 bytes each can be shown per line
    movq    %r13, %rax              # prep for division
    divq    %r11                    # current pointer modded by 30

    cmpq    $0, %rdx
    jne     print_unsorted_loop 
    # otherwise print a newline char
    print1 nl

    jmp print_unsorted_loop


# Function to preform radix sort an the array.
# Sorts every number one bit at a time; puts the 
# numbers with a 1 in the current bit into an 
# array, bin and leave the numbers with a 0 in 
# array. Then stick the current 
radix_sort:
    # create bin
    movl    (arr_len), %edi
    call    malloc
    movq    %rax, %r13              # %r13 now contains the bin for numbers with a 1 bit for each iteration

    xorq    %r8, %r8                # index0 to store the current index of where numbers with 0 bits are added in the array of random nums
    xorq    %r9, %r9                # index1 to store the current index of where numbers with 1 bits are added in the bin
    xorq    %r10, %r10              # index to store the current location in the array of random nums which is being checked
    movb    $16, %r11b              # index for count down loop that loops 16 times; one for each bit
    movw    $1, %r12w               # mask for current bit
bit_loop:

# loop to split numbers into correct bins
split_nums:
    cmpl    (arr_len), %r10d        # if the array is checked jump out
    jae     add_bin_back            # then jump to add_bin_back

    # get current num
    movw    (%r14, %r10), %r15w     # store the current 2 byte num of the array in %r15w
    
    movw    %r15w, %cx              # duplicate the current number for bitwise and with the mask
    # check if current bit is 1
    andw    %r12w, %cx              # bitwise and with mask to check get current bit
    cmpw    %cx, %r12w              # check if current bit is a 1
    je      bit_is_1                # if the bit is 1

    # otherwise if the bit is 0
    movw    %r15w, (%r14, %r8)      # move current number back into the array
    addq    $2, %r8                 # increment pointer for the current array adding location to next bit
    addq    $2, %r10                # increment pointer for current array to next bit
    jmp     split_nums

bit_is_1:
    movw    %r15w, (%r13, %r9)      # move current number into bin
    addq    $2, %r9                 # increment pointer for the bin adding location to next bit
    addq    $2, %r10                # increment pointer for current array to next bit
    jmp     split_nums


# add the bin back into the array
add_bin_back:
    xorq    %r10, %r10              # index to store the current location in the bin

bin_loop:
    cmpq    %r10, %r9               # check if all of the bin as been added back into the array
    je      finished_adding_bin

    # get current num in bin
    movw    (%r13, %r10), %r15w     # store the current 2 byte num of the bin in %r15w
    movw    %r15w, (%r14, %r8)      # move current number back into the array

    # increment pointers
    addq    $2, %r10                # increment pointer for bin
    addq    $2, %r8                 # increment pointer for array
    jmp     bin_loop

finished_adding_bin:
    # clear all the indices before next bit
    xorq    %r8, %r8                
    xorq    %r9, %r9                
    xorq    %r10, %r10              

    # shift mask
    shlw    %r12w                   # bitshift to next bit in the mask

    # countdown loop index handling
    decb    %r11b                   # countdown loop index decremented
    jnz     bit_loop                # if the index is not 0 continue looping

finished_radix_sort:
    print1 nl
    print1 nl
    movq    $0, %r13
    
    # check if array is greater than 200 numbers
    cmpl    $400, (arr_len)         # if the array is over 200 only print the first 200
    jg      greater_200

    # print title for sorted array
    print1  sorted_msg
    movl    (arr_len), %ebx     
    movl    %ebx, (cap)         # set the cap of numbers to be printed at the length of the array
    jmp print_sorted_loop

# when there are greater than 200 numbers
greater_200:
    print1 over_200_msg
    

print_sorted_loop:
    cmpl    (cap), %r13d            # if the array is fully printed; compared to cap which has a default of 200
    jae     check_order             # then jump to check_order
    
    xorq    %r10, %r10              # clear %r10 
    movw    (%r14, %r13), %r10w     # store a 2 byte value of the array in %r10
    print2 show_int, %r10           # print the number
    
    addl    $2, %r13d

    # check if 15 numbers have been printed on the current line, if so add a newline
    xorq    %rdx, %rdx              # clear rdx to store remainder
    movq    $30, %r11               # modifier is 30 so 15 numbers of 2 bytes each can be shown per line
    movq    %r13, %rax              # prep for division
    divq    %r11                    # current pointer modded by 30

    cmpq    $0, %rdx
    jne     print_sorted_loop 
    # otherwise print a newline char
    print1 nl

    jmp print_sorted_loop


# function to check if the array is in order.
# loops through every number and varifies that
# it is larger than the previous number.
check_order:
    movq    $2, %r10                # use %r10 as a pointer for the current location in the array
    movw    (%r14), %r8w            # uses %r8 to track the prev number; set to the first value of the array

check_loop:
    cmpw    (arr_len), %r10w        # jump to done once the end the end of the array is hit
    jge     found_in_order

    cmpw    (%r14, %r10), %r8w      # check if greater to the previous number
    ja     found_out_of_order     

    movw    (%r14, %r10), %r8w      
    addw    $2, %r10w               # increment pointer for array to the next number

    # otherwise continue looping
    jmp     check_loop

# function to print out of order message.
found_out_of_order:
    print1 out_order
    jmp     done

# function to print in order message.
found_in_order:
    print1 in_order                 

done:
    # print 2 extra newlines 
    print1 nl                       
    print1 nl

    ret
    
.section    .note.GNU-stack,"",@progbits
