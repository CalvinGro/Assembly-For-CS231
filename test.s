       .section .data
# [01] Buffers + state
paragraph:     .space  800        # total capacity
offset:        .quad   0          # how many bytes have been written so far
msg:           .asciz  "Enter a line (blank line to finish): "
outfmt:        .asciz  "\nParagraph:\n%s\n"

        .section .text
        .globl  main
main:
# [10] offset = 0; paragraph[0] = '\0' so we have a valid C-string
        movq    $0, offset(%rip)
        leaq    paragraph(%rip), %rdi
        movb    $0, (%rdi)

read_loop:
# [15] Print prompt
        leaq    msg(%rip), %rdi
        xor     %eax, %eax
        call    printf

# [19] Load offset and compute dest = paragraph + offset
        movq    offset(%rip), %rcx         # rcx = offset
        leaq    paragraph(%rip), %rdi      # rdi = &paragraph[0]
        addq    %rcx, %rdi                 # rdi = &paragraph[offset]

# [24] Compute remaining = capacity - offset
        movq    $800, %rax                 # capacity
        subq    %rcx, %rax                 # rax = remaining bytes
        cmpq    $1, %rax
        jle     finish                     # no space (need >=1 for '\0')

# [30] fgets(dest, remaining, stdin)
        movl    %eax, %esi                 # esi = (int) remaining
        movq    stdin(%rip), %rdx
        call    fgets
        testq   %rax, %rax
        je      finish                     # EOF/error

# [36] If user just hit Enter: first char is '\n' at dest
        cmpb    $'\n', (%rdi)
        je      finish

# [39] len = strlen(dest)   (only the newly appended tail)
        movq    %rdi, %rsi                 # keep dest in rsi
        movq    %rdi, %rdi                 # rdi = dest
        call    strlen                     # rax = length just read
# [43] offset += len
        addq    %rax, %rcx
        movq    %rcx, offset(%rip)

        jmp     read_loop

finish:
# [49] Ensure final NUL (already true, fgets wrote one; but be explicit)
        movq    offset(%rip), %rcx
        leaq    paragraph(%rip), %rdi
        movb    $0, (%rdi,%rcx,1)

# [54] Show the result
        leaq    outfmt(%rip), %rdi
        leaq    paragraph(%rip), %rsi
        xor     %eax, %eax
        call    printf

        xor     %eax, %eax
        ret