;------------------------------
; ParaPF - para print function 
;------------------------------

; 1 - rdi, 2 - rsi, 3 - rdx, 4 - rcx, 5 - r8, 6 - r9, 7, 8, ... - in stack
; rax, rcx, rdx are caller-saved, the rest are callee-saved
; ST0 and ST7 must be empty; ST1 to ST7 must be empty on exiting a function

;TODO!!!: %d, %x, %o, %b, %c, %s, %%
;       \n, \t, \\

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
%macro  puts    1

        mov rdi, 1              ; file descriptor (stdout)
        mov rdx, %1             ; number of charcters to write
                                ; rsi already contains offset of a char
        mov rax, 1              ; syscall number

        syscall                 ; fuckes up rcx and r11
        
%endmacro
;--------------------------------------------------------------------
Putchar:
        puts 1
        inc rsi
        ret
;--------------------------------------------------------------------

;--------------------------------------------------------------------
Process_Percent:
        
        inc rsi
        mov al, [rsi]

        cmp al, 'd'
        je .decimal

        cmp al, 'x'
                ;je .hexadecimal

        cmp al, 'o'
                ;je .octal

        cmp al, 'b'
                ;je .binary

        cmp al, 'c'
                ;je .charcter

        cmp al, 's'
                ;je .string

        cmp al, '%'
        je .percent

                ;call Error

;---------------------------------
.decimal:

        mov rax, [rbp + r12 * 8]        ;
        mov rdi, num_string             ; itoa () arguments
        mov rbx, 10                     ;

        push rsi
        call itoa
        pop rsi

        inc r12

        push rdi
        call Strlen
        pop rdi

        push rsi
        mov rsi, rdi
        puts rax
        pop rsi
        
        inc rsi

        jmp Process_Str
;---------------------------------
.percent:
        call Putchar
        jmp Process_Str
;---------------------------------


;--------------------------------------------------------------------
itoa:
        
        push rdi

        cmp rax, 0
        je .zero

        cmp rax, 0
        jb .negative

        jmp .positive

.zero:  mov ch, [numbers]
        mov [rbx], ch
        inc rdi

        mov ch, 0
        mov [rdi], ch
        jmp .return

.negative:
        mov ch, '-'
        mov [rdi], ch
        inc rdi

        neg rax

.positive: 
        xor rdx, rdx
        div rbx
        mov rsi, rdx                    ; <---------| SEGFAULT HERE
        mov ch, [numbers + rsi]
        mov [rdi], ch
        inc rdi

        cmp rax, 0
        jne .positive
            
        mov ch, 0
        mov [rdi], ch

        pop rbx
        push rbx
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
