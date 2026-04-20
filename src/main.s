.intel_syntax noprefix
.global _start

.section .rodata
  prompt:
    .string "-> "

  newline:
    .string "\n"
  
  exit_cmd:
    .string "exit"

  parent_msg:
    .string "Parent\n"
  parent_msg_len = . - parent_msg

  child_msg:
    .string "Child\n"
  child_msg_len = . - child_msg

  fork_fail_msg:
    .string "Fork failed\n"
  fork_fail_msg_len = . - fork_fail_msg

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
    
    #Check if the user pressi just Enter, If yes then jump to main_loop
    cmp eax, 1
    je main_loop
    
    #Back up the number of bytes from buffer
    mov r8, rax
    
    #Change the new line to 0 for null terminate
    lea rdi, [rip + user_input]
    add rdi, r8
    dec rdi
    mov byte ptr [rdi], 0

    #Check if the user type exit, If yes then jump to exit
    mov eax, dword ptr [rip + user_input]
    cmp eax, dword ptr [rip + exit_cmd]
    jne not_exit_check
    
    #Check the 5th byte is null
    cmp byte ptr [rip + user_input + 4], 0
    je do_exit
  
  not_exit_check:
  #Demonstrate fork
  call demo_fork
  jmp main_loop
  
do_exit:
  #Exit the program
  mov eax, 60 
  xor edi, edi
  syscall

demo_fork:
  #sys_fork
  push rbx
  mov eax, 57
  syscall
  
  #Check return value
  test eax, eax
  jz child_process
  js fork_error
  
  #Backup rax value to rbx
  mov rbx, rax

  #Wait4
  mov rdi, rbx
  mov eax, 61
  xor esi, esi
  xor edx, edx
  xor r10, r10
  syscall

  #Print "Parent\n"
  mov eax, 1
  mov edi, 1
  lea rsi, [rip + parent_msg]
  mov edx, parent_msg_len
  syscall
  
  pop rbx
  ret 

child_process:
    # Print "Child\n"
    mov eax, 1
    mov edi, 1
    lea rsi, [rip + child_msg]
    mov edx, child_msg_len
    syscall

    # Child exits (important! or it will return and run main_loop)
    mov eax, 60
    xor edi, edi
    syscall

fork_error:
    # Print "Fork failed\n"
    mov eax, 1
    mov edi, 1
    lea rsi, [rip + fork_fail_msg]
    mov edx, fork_fail_msg_len
    syscall

    pop rbx
    ret

print_new_line_and_exit:
  #Print newline before exiting on CTRL + D 
  mov eax, 1
  mov edi, 1
  lea rsi, [rip + newline]
  mov edx, 1
  syscall
  jmp do_exit
