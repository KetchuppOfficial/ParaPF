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
        
        mov [rbp - 16], rdi   ; string
	mov [rbp - 24], rsi   ; first arg
	mov [rbp - 32], rdx   ;
	mov [rbp - 40], rcx   ; ...
	mov [rbp - 48], r8    ;
	mov [rbp - 56], r9    ; fifth arg
                              ; other args are with positive offset relatively to bp
        mov rsi, [rbp - 16]    ; char *str

        call Process_Str

return:
        ret
;--------------------------------------------------------------------

;--------------------------------------------------------------------
Process_Str:

        mov al, [rsi]
        
        cmp al, 0
        je return

        cmp al, '%'
        je Process_Percent

        call Putchar
        jmp Process_Str
;--------------------------------------------------------------------

;--------------------------------------------------------------------
%macro  puts    1

        mov rdi, 1              ; file descriptor (stdout)
        mov rdx, %1             ; number of charcters to write
                                ; rsi already contains offset of a char
        mov rax, 1              ; syscall number
        syscall
        
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
                ;je .decimal

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

.return:
        jmp Process_Str
;---------------------------------
.percent:
        call Putchar
        jmp .return
;---------------------------------

;--------------------------------------------------------------------
itoa:

        push rbp
        mov rbp, rsp

        mov rax, [rbp + 8]      ; num
        mov rbx, [rbp + 6]      ; str
        mov rdi, [rbp + 4]      ; radix

        cmp rax, 0
        je .zero

        cmp rax, 0
        jb .negative

        jmp .positive

.zero:  mov ch, [numbers]
        mov [rbx], ch
        inc rbx

        mov ch, 0
        mov [rbx], ch
        jmp .return


.negative: 
        mov ch, '-'
        mov [rbx], ch
        inc rbx

        neg rax

.positive: 
        xor rdx, rdx
        div rdi
        mov rsi, rdx
        mov ch, [numbers + rsi]
        mov [rbx], ch
        inc rbx

        cmp rax, 0
        jne .positive
            
        mov ch, 0
        mov [rbx], ch

        mov rdi, [rbp + 6]
.change:
        dec rbx
        mov ch, [rbx]

        mov ah, [rdi]
        mov [rbx], ah

        mov [rdi], ch
        inc rdi

        cmp rbx, rdi
        ja .change
      
.return:
        mov rax, [rbp + 6]

        pop rbp
        ret

;--------------------------------------------------------------------


section .data

numbers db      "0123456789ABCDEF"
