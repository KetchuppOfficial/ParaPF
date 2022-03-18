;------------------------------
; ParaPF - para print function 
;------------------------------

; 1 - rdi, 2 - rsi, 3 - rdx, 4 - rcx, 5 - r8, 6 - r9, 7, 8, ... - in stack
; rax, rcx, rdx are caller-saved, the rest are callee-saved
; ST0 and ST7 must be empty; ST1 to ST7 must be empty on exiting a function

;TODO!!!: %d, %x, %o, %b, %c, %s, %%
;       \n, \t, \\

;TODO!!!: solve the problem of negative numbers (they are no as negative as they seem) 

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
Process_Str:

        mov al, [rsi]
        
        cmp al, 0
        je .exit

        cmp al, '%'
        je Process_Percent

        call Putchar
        jmp Process_Str
.exit:
        ret
;--------------------------------------------------------------------

;--------------------------------------------------------------------
%macro  putsymbs    1

        mov rdi, 1              ; file descriptor (stdout)
        mov rdx, %1             ; number of charcters to write
                                ; rsi already contains offset of a char
        mov rax, 1              ; syscall number

        syscall                 ; fuckes up rcx and r11
        
%endmacro
;--------------------------------------------------------------------
Putchar:
        push rcx
        push r11
        putsymbs 1
        pop r11
        pop rcx
        inc rsi
        ret
;--------------------------------------------------------------------
Puts:

        push rsi
        mov rsi, rdi
        mov ch, 0

        jmp .condition

.loop:
        call Putchar
.condition:
        cmp [rsi], ch
        jne .loop

.exit:
        pop rsi
        ret
;--------------------------------------------------------------------
Process_Percent:
        
        inc rsi
        mov al, [rsi]

        cmp al, 'd'
        je .decimal

        cmp al, 'x'
        je .hexadecimal

        cmp al, 'o'
        je .octal

        cmp al, 'b'
        je .binary

        cmp al, 'c'
                ;je .charcter

        cmp al, 's'
                ;je .string

        cmp al, '%'
        je .percent

                ;call Error

;---------------------------------
.decimal:

        mov rdi, 10
        call Integer
        jmp Process_Str
;---------------------------------
.binary:

        mov rdi, 2
        call Integer
        jmp Process_Str
;---------------------------------
.octal:

        mov rdi, 8
        call Integer
        jmp Process_Str
;---------------------------------
.hexadecimal:

        mov rdi, 16
        call Integer
        jmp Process_Str
;---------------------------------
.percent:
        call Putchar
        jmp Process_Str
;---------------------------------

;--------------------------------------------------------------------
Integer:
        mov rax, [rbp + r12 * 8]        ;
        mov rbx, rdi                    ; radix
        mov rdi, num_string             ; itoa () arguments
        inc r12

        push rsi
        call itoa
        pop rsi

        call Puts

        inc rsi

        ret
;--------------------------------------------------------------------

;--------------------------------------------------------------------
itoa:
        
        push rdi

        cmp rax, 0
        je .zero

        push rax
        test rax, 00000000000000001000000000000000b
        jne .negative

        pop rax
        jmp .positive

.zero:  mov ch, '0'
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
        and rax, 00000000000000001111111111111111b

.positive: 
        xor rdx, rdx
        div rbx
        mov rsi, rdx
        mov ch, [numbers + rsi]
        mov [rdi], ch
        inc rdi

        cmp rax, 0
        jne .positive
            
        mov ch, 0
        mov [rdi], ch

        pop rbx
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
        pop rdi

        ret

;--------------------------------------------------------------------
;--------------------------------------------------------------------
Strlen:
            mov al, 0
            mov rbx, rdi

            dec rdi
.while:
            inc rdi
            cmp [rdi], al
            jne .while

            sub rdi, rbx
            mov rax, rdi
            
            ret
;--------------------------------------------------------------------


section .data

numbers: db      "0123456789ABCDEF"

num_string:     times 32 db 0
