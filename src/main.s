.intel_syntax noprefix
.global _start

.section .rodata
  prompt:
    .string "-> "

  newline:
    .string "\n"
  
  exit_cmd:
    .string "exit"

  execve_fail_msg:
    .string "execve failed\n"
  execve_fail_msg_len = . - execve_fail_msg

  fork_fail_msg:
    .string "Fork failed\n"
  fork_fail_msg_len = . - fork_fail_msg

  cmd_ls:
    .string "/bin/ls"

.section .bss
  user_input:
    .space 256
  
  argv:
    .space 80

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
    
    #Check if the user press just Enter, If yes then jump to main_loop
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
    #Load the address user_input to rdi and argv to rsi
    lea rdi, [rip + user_input]
    lea rsi, [rip + argv]

  skip_leading_spaces:
    #Check if end of string (NULL)? If yes then jmp to finish_tokenize
    mov al, [rdi]
    test al, al
    jz finish_tokenize
    
    #If space, Move to the next byte then repeat. Else jump to store_arg
    cmp al, 32
    jne store_arg
    inc rdi
    jmp skip_leading_spaces
    
  store_arg:
    #Store the argument to arg and move to the next byte
    mov [rsi], rdi
    add rsi, 8
  
  tokenize_loop:
    #Get the current char
    mov al, [rdi]
    
    #Check if NULL
    test al, al
    jz finish_tokenize
    
    #Check if space
    cmp al, 32
    je handle_space
    
    #Move to the next char and jmp to tokenize_loop
    inc rdi
    jmp tokenize_loop

  handle_space:
    #Change space to (NULL) and move to the next bye
    mov byte ptr [rdi], 0
    inc rdi
  
  handle_multiple_spaces:
    #Another space? If yes move to the next bye and repeat, Else jump to check_next_word
    mov al, [rdi]
    cmp al, 32
    jne check_next_word
    inc rdi
    jmp handle_multiple_spaces


  check_next_word:
    #End of string? If yes jump to finish_tokenize, Else jump to store_arg
    test al, al
    jz finish_tokenize
    jmp store_arg
    
  finish_tokenize:
    
    mov qword ptr [rsi], 0

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
  
    pop rbx
    ret 

  child_process:
    # sys_execve(argv[0], argv, NULL)
    mov rdi, [rip + argv]
    lea rsi, [rip + argv]
    xor edx, edx
    mov eax, 59
    syscall

    # If execve returns, it failed
    mov eax, 1
    mov edi, 1
    lea rsi, [rip + execve_fail_msg]
    mov edx, execve_fail_msg_len
    syscall

    #Child exits (important! or it will return and run main_loop)
    mov eax, 60
    xor edi, edi
    syscall

  fork_error:
    #Print "Fork failed\n"
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
