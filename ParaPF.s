;================================;
;= ParaPF - para print function =;
;================================;

;TODO!!!: %s

;TODO!!! make buffer for stdout

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
        inc rsi
        jmp Process_Str

.exit:
        ret
;--------------------------------------------------------------------

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
        je .charcter

        cmp al, 's'
        je .string

        cmp al, '%'
        je .percent

                ;call Error

.percent_exit:

        inc rsi
        inc r12
        jmp Process_Str
;---------------------------------
.decimal:

        mov rdi, 10
        call Integer
        jmp .percent_exit
;---------------------------------
.hexadecimal:

        mov rbx, 16
        call Integer
        jmp .percent_exit
;---------------------------------
.octal:

        mov rbx, 8
        call Integer
        jmp .percent_exit
;---------------------------------
.binary:

        mov rbx, 2
        call Integer
        jmp .percent_exit
;---------------------------------
.charcter:

        push rsi
        lea rsi, [rbp + r12 * 8]        ; address of the stack cell
        call Putchar
        pop rsi

        jmp .percent_exit
;---------------------------------
.string:

        push rsi
        mov rsi, [rbp + r12 * 8]        ; content of the stack cell
        call Puts
        pop rsi

        jmp .percent_exit
;---------------------------------
.percent:

        call Putchar
        inc rsi
        jmp Process_Str
;---------------------------------

;--------------------------------------------------------------------
Integer:

        mov rax, [rbp + r12 * 8]        ;
        mov rbx, rdi
                                        ; radix in rbx
        mov rdi, num_string             ; itoa () arguments

        push rsi
        call itoa
        call Puts
        pop rsi

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

numbers: db      "0123456789ABCDEF"

num_string:     times 32 db 0
