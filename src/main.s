.intel_syntax noprefix
.global _start

.section .rodata
  prompt:
    .string "> "
    prompt_len = . - prompt

.section .bss
  user_input:
    .space 256

.section .text
_start:

  main_loop:
    
    #Print prompt "> "
    mov eax, 1
    mov edi, 1
    lea rsi, [rip + prompt]
    mov rdx, prompt_len
    syscall
    
    mov eax, 0
    mov edi, 0
    lea rsi, [rip + user_input]
    mov rdx, 256
    syscall
    
    jmp main_loop

    #Exit
    mov eax, 60 
    xor edi, edi
    syscall
