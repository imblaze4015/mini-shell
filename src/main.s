.intel_syntax noprefix
.global _start

.section .rodata
  prompt:
    .string "-> "

  newline:
    .string "\n"
  
  exit_cmd:
    .string "exit"

.section .bss
  user_input:
    .space 256

.section .text
_start:

  main_loop:
    
    #Print prompt "-> "
    mov eax, 1
    mov edi, 1
    lea rsi, [rip + prompt]
    mov edx, 3
    syscall
    
    #Catch user input and place it to buffer
    mov eax, 0
    mov edi, 0
    lea rsi, [rip + user_input]
    mov edx, 256
    syscall
    
    #Check if the user press CTRL + D, If yes add new line then exit
    test eax, eax
    jz print_new_line_and_exit
    
    #Check if the user press Enter, If yes then jump to main_loop
    cmp eax, 1
    je main_loop
    
    #Back up the number of bytes from buffer
    mov r8, rax
    
    #Check if user input is equal to 5 (e,x,i,t,\n)
    cmp r8, 5

    #If not equal to 5 then echo back the input 
    jne echo_back

    #Check if the user type exit, If yes then jump to exit
    mov eax, dword ptr [rip + user_input]
    mov edx, dword ptr [rip + exit_cmd]
    cmp eax, edx
    je do_exit
  
  echo_back: 
    #Echo back exactly what user typed
    mov rdx, r8    
    mov eax, 1
    mov edi, 1
    lea rsi, [rip + user_input]
    syscall
    jmp main_loop
  
do_exit:
  #Exit the program
  mov eax, 60 
  xor edi, edi
  syscall

print_new_line_and_exit:
  #Print newline before exiting on CTRL + D 
  mov eax, 1
  mov edi, 1
  lea rsi, [rip + newline]
  mov edx, 1
  syscall
  jmp do_exit
