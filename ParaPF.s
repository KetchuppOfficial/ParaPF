;================================;
;= ParaPF - para print function =;
;================================;

section .text

global ParaPF

;--------------------------------------------------------------------
ParaPF:
        
        pop r10                 ; save ret_addr

        push r9                 ; sixth arg
        push r8                 ;
        push rcx                ; ...
        push rdx                ;
        push rsi                ; second arg
        push rdi                ; first arg (string)

        push rbp
        mov rbp, rsp

        mov r12, 2

        mov rsi, rdi            ; char *str

        call Process_Str

return:
        pop rbp

        pop rdi 
        pop rsi 
        pop rdx 
        pop rcx 
        pop r8 
        pop r9

        push r10                ; return ret_addr
        ret
;--------------------------------------------------------------------

;--------------------------------------------------------------------
;Process_Str:
;
;Input:
;       rsi - address of ParaPF format string
;       r12 - ParaPF arguments counter
;Output:
;       None
;Register that change values:
;       al  - currect character
;       rsi
;--------------------------------------------------------------------
Process_Str:

        mov al, [rsi]
        
        cmp al, 0
        je .exit

        cmp al, '%'
        je Process_Percent

        call Putchar
        inc rsi
        jmp Process_Str

.exit:
        ret
;--------------------------------------------------------------------

;--------------------------------------------------------------------
;Process_Percent:
;
;Input:
;       rsi - address of ParaPF format string
;       r12 - ParaPF arguments counter
;Output:
;       None
;Register that change values:
;       rax/al - format specifier/address in the branch table
;       rsi
;       r12
;--------------------------------------------------------------------
Process_Percent:
        
        inc rsi
        xor rax, rax
        mov al, [rsi]
        
        cmp al, 'b'
        jb Error

        cmp al, 'x'
        ja Error

        cmp al, 'X'
        je Hexadecimal_Upper
        
        cmp al, '%'
        je Percent
        
        mov rax, [branch_table + (rax - 'b') * 8]
        jmp rax

percent_exit:

        inc rsi
        inc r12
        jmp Process_Str

;--------------------------------------------------------------------
;Decimal, Hexadecimal_Lower, Hexadecimal_Upper, Octal, Binary:
;
;Input:
;       rsi - address of ParaPF format string
;Output:
;       None
;Register that change values:
;       rbx - radix
;       r13 - address of the string with digits in upper- or lowercase
;--------------------------------------------------------------------      
;---------------------------------
Decimal:

        mov rbx, 10
        mov r13, numbers_lower
        call Integer
        jmp percent_exit
;---------------------------------
Hexadecimal_Lower:

        mov rbx, 16
        mov r13, numbers_lower
        call Integer
        jmp percent_exit
;---------------------------------
Hexadecimal_Upper:

        mov rbx, 16
        mov r13, numbers_upper
        call Integer
        jmp percent_exit
;---------------------------------
Octal:

        mov rbx, 8
        mov r13, numbers_lower
        call Integer
        jmp percent_exit
;---------------------------------
Binary:

        mov rbx, 2
        mov r13, numbers_lower
        call Integer
        jmp percent_exit
;---------------------------------

;--------------------------------------------------------------------
;Charcter, String:
;
;Input:
;       rsi - address of ParaPF format string (saved via stack)
;Output:
;       None
;Register that change values:
;       rsi - address of character of string to print
;--------------------------------------------------------------------
;---------------------------------
Charcter:

        push rsi
        lea rsi, [rbp + r12 * 8]        ; address of the stack cell
        call Putchar
        pop rsi

        jmp percent_exit
;---------------------------------
String:

        push rsi
        mov rsi, [rbp + r12 * 8]        ; content of the stack cell
        call Puts
        pop rsi

        jmp percent_exit
;---------------------------------

;--------------------------------------------------------------------
;Process_Percent:
;
;Input:
;       rsi - address of ParaPF format string
;Output:
;       None
;Register that change values:
;       rsi
;--------------------------------------------------------------------
;---------------------------------
Percent:

        call Putchar
        inc rsi
        jmp Process_Str
;---------------------------------

;--------------------------------------------------------------------
;Process_Percent:
;
;Input:
;       None
;Output:
;       None
;Register that change values:
;       rax - place to pop return address of Process_Str into
;       rsi - address of the string with report on an error
;--------------------------------------------------------------------
;---------------------------------
Error:

        mov rsi, error_report
        call Puts
        pop rax                 ; ret_addr of Process_Str
        jmp return
;---------------------------------

;--------------------------------------------------------------------
;Process_Percent:
;
;Input:
;       rsi - address of ParaPF format string
;       rbx - radix
;Output:
;       None
;Register that change values:
;       rax - number to print
;       rdi - a string to put charcters into
;--------------------------------------------------------------------
Integer:

        mov rax, [rbp + r12 * 8]        ; number
                                        ; radix in rbx
        mov rdi, num_string             ; string to put chars into

        push rsi
        call Itoa
        call Puts
        pop rsi

        ret
;--------------------------------------------------------------------

;--------------------------------------------------------------------
;Itoa:
;
;Input:
;       rax - number
;       rbx - radix (at first)
;       rdi - address of the string to put characters into
;       r13 - address of the string with digits in upper- or lowercase
;Output:
;       rsi - string with number
;Register that change values:
;       rax/ah - contains digits
;       rbx - copy of rdi (to have ptr on the beginning of the string)
;       rcx/ch - contains characters
;       rdi
;       r14 - contains the remainder of the division
;--------------------------------------------------------------------
Itoa:
        
        push rdi

        cmp rax, 0
        je .zero

        push rax
        mov r15, rax
        mov rax, 0x0000000080000000     ; masking the most significant bit of eax part of rax
        test r15, rax
        jne .negative

        pop rax
        jmp .positive

.zero:  
        mov ch, '0'
        mov [rdi], ch
        inc rdi

        mov ch, 0
        mov [rdi], ch
        jmp .return

.negative:
        pop rax
        mov ch, '-'
        mov [rdi], ch
        inc rdi

        neg rax
        shl rax, 32     ; zeroing out not eax part of rax
        shr rax, 32     ;

.positive: 
        xor rdx, rdx
        div rbx
        xor r14, r14
        mov r14, [r13 + rdx]
        mov [rdi], r14
        inc rdi

        cmp rax, 0
        jne .positive 

        mov ch, 0
        mov [rdi], ch

        pop rbx         ; ptr on the beginning of the string
        push rbx

        mov ch, '-'
        cmp [rbx], ch
        jne .change

        inc rbx

.change:
        dec rdi
        mov ch, [rdi]

        mov ah, [rbx]
        mov [rdi], ah

        mov [rbx], ch
        inc rbx

        cmp rdi, rbx
        ja .change

.return:
        pop rsi
        ret
;--------------------------------------------------------------------

;--------------------------------------------------------------------
;Putchar:
;
;Input:
;       rsi - address of a character to print
;Output:
;       None
;Register that change values:
;       rax -
;       rdi - all three register are used for syscall
;       rdx -
;--------------------------------------------------------------------
Putchar:

        push rcx
        push r11
        
        mov rdi, 1              ; file descriptor (stdout)
        mov rdx, 1              ; number of charcters to write
                                ; rsi already contains offset of a char
        mov rax, 1              ; syscall number

        syscall                 ; fuckes up rcx and r11

        pop r11
        pop rcx
        
        ret
;--------------------------------------------------------------------

;--------------------------------------------------------------------
;Puts:
;
;Input:
;       rsi - address of the string to print (must and in '\0')
;Output:
;       None
;Register that change values:
;       rcx/ch - contains '\0'
;       rsi
;--------------------------------------------------------------------
Puts:

        mov ch, 0
        jmp .condition

.loop:
        call Putchar
        inc rsi
.condition:
        cmp [rsi], ch
        jne .loop

.exit:
        ret
;--------------------------------------------------------------------

section .data

numbers_upper:  db "0123456789ABCDEF"
numbers_lower:  db "0123456789abcdef"

num_string:     times 32 db 0

error_report:   db 0x0A, "Incorrect input", 0x0A, 0

branch_table:
                                        dq Binary
                                        dq Charcter
                                        dq Decimal
                times ('i' - 'd' - 1)   dq Error
                                        dq Decimal
                times ('o' - 'i' - 1)   dq Error
                                        dq Octal
                times ('s' - 'o' - 1)   dq Error
                                        dq String
                times ('x' - 's' - 1)   dq Error
                                        dq Hexadecimal_Lower
