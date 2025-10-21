
        .section data

/* Macros to execute the write and read system calls */

prints: .macro  a,b,c 
	 movq $1, %rax		# write () system call
	 movq \a, %rdi		# %rdi = 1, fd = stdout
	 leaq \b, %rsi		# %rsi ---> address of buffer to output 
	 movq \c, %rdx		# %rdx = count of number of characters to write out
	 syscall		# execute write () system call
        .endm

reads:  .macro  a,b,c 
	 movq $0, %rax		# read () system call
	 movq \a, %rdi		# %rdi = 0, fd = stdin
	 leaq \b, %rsi		# %rsi --> address of input buffer 
	 movq \c, %rdx		# %rdx = number of characters to read 
	 syscall		# execute read () system call
        .endm


/* Macros to perform output by calling the C printf function */

printfs: .macro  a,b,c,d,e,f 
        movq \a, %rdi      # 
        movq \b, %rsi      #
        movq \c, %rdx      #
        movq \d, %rcx
        movq \e, %r9
        movq \f, %r8
        xorq %rax, %rax
        call printf        # execute write () system call
        .endm

printfsx: .macro  a,b,c,d 
         movq \a, %rdi      # 
         movq \b, %rsi      #
         movq \c, %rdx      #
         movq \d, %rcx
         xorq %rax, %rax
         call printf        # execute write () system call
        .endm

               
/* Macro to shift bits left by a certain number of places
 *   Parameters:
 *      \a  
 *      \b 
 *      \c:  The number of places to shift left
*/ 

shift_left:  .macro a,b,c
             movq \c, \a
             movq $1, \b
             decq \a
             movq \a, %rcx
             shlq %cl, \b
             .endm

/*  int2str macro converts a number to a numeric string by calling the C sprintf function. 
 *    The C function format is "sprintf(output_str_addr, "%d", number to convert)a
 *    Parameters:
 *      /a: %rdi: output string address
 *      /b: %rsi: format string address (usually address of "%d" string)
 *      /c: %rdx: number to be converted
 *          %rax: $0 (similar to other C functions that are called from assembler
*/
 
int2str:  .macro  a, b, c
          leaq    \a, %rdi
          leaq    \b, %rsi
          movq    \c, %rdx
          movq    $0, %rax
          call    sprintf
          .endm


/*  sys_call parameters:
            \a: %rax:  0 - read;  1 - write;  2 - open/create file;  3 - close file 
            \b: %rdi:  1 - stdout or stdin;  Otherwise, use file descriptor from open/create syscall
            \c: %rsi:  for open syscall: 101 - read or write only;  for read/write syscall - buffer address
            \d: %rdx:  for open syscall: 600 permission; for read/write syscall - number of bytes to read or write 

            syscall    # execute the open() system call
*/

sys_call: .macro  a, b, c, d 
          movq \a, %rax     # 0 - read;  1 - write;  2 - open/create file;  3 - close file
          movq \b, %rdi     # 1 - stdout or stdin;  Otherwise, use file descriptor from open/create syscall 
	  movq \c, %rsi     # for open syscall:  0 = read only, 101 =  write only;  for read/write syscall - buffer address 
          movq \d, %rdx     # for open syscall: 600 permission; for read/write syscall - number of bytes to read or write 
          syscall           # execute read/rite () system call
          .endm


        .global main
        .section .text

main:

        # Calling examples

        prints  $1, prompt, prompt_len
        reads $0, buffer, $80
	prints $1, newline, nl_len
        prints $1, buffer, $80 
	prints $1, newline, nl_len

        printfs  $format, $ex_str, num1, num2, num4, num3
        printfs  $format, $ex_str2, num4, num3, num2, num1
        printfsx  $format1, $ex_str, num1, num2


	## display string using write () system call
        sys_call  $1,$1, prompt, prompt_len

	## enter string using read () system call
        sys_call $0, $0, buffer, $80

	## display string using write () system call
	sys_call $1, $1, newline, nl_len

	## display input string using write () system call
        sys_call $1, $1, buffer, $80 

	## display string using write () system call
	sys_call $1, $1, newline, nl_len


	## terminate program via _exit () system call 
        sys_call $60, $0, newline, $0


        ## create and open file to write to; file descriptor is returned in %rax
        sys_call   $2, $filename, $101, $0600
 
        # Use the int2str macro to insert code to convert the number in inpval to the numeric string in outval
        int2str outval, ninp, inpval

        ## Use the sys_call macro to write the numeric string in outval 
        ## to the file referenced by the file descriptor stored in %r15
        sys_call  $1, %r15, $outval, $10 

        ## Use the sys_call macro to write a newline character
        ## to the file referenced by the file descriptor stored in %r15
        sys_call  $1, %r15, $newline, nl_len

        ## Use the sys_call macro to close the file that is open
        sys_call $6, %r15, $0, $0

        ## %r15 will be used to hold the number of places to shift
        ## %r8 is the value that will be shifted, e.g. %r8 = $1 if a mask is being shifted.
        shift_left %r15, %r8, $52

	## terminate program via _exit () system call 
	movq $60, %rax		# %rax = 1 system call _exit ()
	movq $0, %rdi		# %rbx = 0 normal program return code
	syscall 		# execute system call _exit ()


