.intel_syntax noprefix
.global _start


#Define the syscalls so that no need to remember them and for readability
.equ sys_fork, 57
.equ sys_execve, 59
.equ sys_exit, 60
.equ sys_wait4, 61

#Here where buffers are declared.
.section .bss
  user_input: .space 256            #Reserve 256 bytes for user input
  argv: .space 10 * 8               #Reserve 10 slots of array with 8 bytes each

#Here where read only data are declared. 
.section .rodata
  prompt: .string "-> "
  new_line: .string "\n"
  exit_cmd: .string "exit"
  echo_cmd: .string "echo"                                                                        


#Here where are the instructions are written
.section .text

_start:

get_user_input:

  #Print "-> "
  lea rsi, [rip + prompt]           #Load the address of prompt to rsi
  mov edx, 3
  call print
  
  #Get user input and place to to buffer "user_input"
  mov eax, 0                        #sys_write
  mov edi, 0                        #stdin
  lea rsi, [rip + user_input]       #Load the user "user_input" buffer. This is where we put 
                                    # - the input

  mov edx, 256                      #We are only taking exactly 256 bytes or characters. 
                                    # - To avoid memory leak                       
  syscall

  #From here on RAX holding the number of characters from user_input including "space" and 
  # - "new line"
  
  #Check rax == 0. If the user press CTRL + D it means the program didn't catch anything.
  test eax, eax                     #Did the user press CTRL + D? If yes then print new line and
  jz exit_and_print_newline

  #Check if rax == 1. If the user just press enter without typing anything the program will
  # - only catch 1 value. Because '\n' is counted as one. If yes then restart the program
  cmp rax, 1
  je get_user_input

  #Change end of string from "\n" to "0". Because later on, execve need to know where to stop
  # - and that's the purpose of "0"

  add rsi, rax                      #As of the moment rsi is pointing at starting address of 
  dec rsi                           # - input so by adding rax, it is now pointing one byte ahead
  mov byte ptr [rsi], 0             # - of the last char, that's why we are decreasing one byte
                                    # - and change the new line to NULL or "0"
                             

  #Check if the user typed "exit" and enter? If yes then exit the program
  mov esi, dword ptr [rip + user_input]
  mov edi, dword ptr [rip + exit_cmd]
  cmp esi, edi
  jne tokenize

  cmp byte ptr [rip + user_input + 4], 0
  je exit


#In this section, User inputs should be tokenized. All spaces should be replaced to NULL. Later on the execve
# - need to know the start and end of every word.
tokenize:
  lea rsi, [rip + user_input]        #Reload the user_input in rsi.
  lea rdi, [rip + argv]              #Now rdi holding the address of argv. This is where put the tokenize words

  #Skip leading spaces. If the user typed "  Hello0", It should skip the leading spaces and start with "H"
  .skip_leading_spaces:
    cmp byte ptr [rsi], 32           #Check if the current byte holding a space
    jne .store_arg                   #Not a space? Then it's the start of character
    inc rsi                          #It's a space, Move to the next byte
    jmp .skip_leading_spaces


  .store_arg:
    mov [rdi], rsi                  #Store the address of each word inside argv
    add rdi, 8                      #Now rdi pointing on the next 8 byte for the next arg
  
  #In this section we found the first character of word. Now it's time to find the last char of the word
  .scan_word:
    cmp byte ptr [rsi], 0           #Check if NULL. What if the user just typed spaces then press enter?
    je .finish_tokenize             #If NULL then  go back to get_user_input

    cmp byte ptr [rsi], 32          #Check if it's end of the word.
    je .terminate_word              #If end of the word then we need to put a NULL at the end of the word

    inc rsi                         #Not a NULL and not the end of the word either so let's move to the next byte
    jmp .scan_word

  #In this section we found the last letter of the word and now we need to put a NULL at the end of each word.
  .terminate_word:
    mov byte ptr [rsi], 0           #We mark the end of the word. This time we check if there is another word
    inc rsi
    jmp .skip_leading_spaces

  .finish_tokenize:
    mov qword ptr [rdi], 0

#In this section we will use fork. We will create a parent and child process. In Linux
fork:
  #Here we clone our current process and that will be the child process. It will carry out the execve
  mov eax, sys_fork
  syscall

  #In this moment we have two identical process running in the background, Parent and child. Even the state of
  # - even the registers are similar aside from rax. The rax in parent holding the child PID and the child rax
  # - holding 0. 
  test eax, eax                     #Is it the child or the parent
  jz child_process                  #If the child then jump to child process if not then continue to parent

#We will ask the parent to stop it's process and have the child finish it's process
parent_process:
  mov r8, rax                       #Backup the PID to r8 because sys_wait4 will use the rax

  #The parent will stop until the child finished it's process then go back to get_ser_input
  mov eax, sys_wait4                
  mov rdi, r8                       #Pass the PID of child so that system know which child to wait
  xor edx, edx                      #I don't need the how the status report of the child
  xor r10, r10                      #I don't need the memory usage report of the child
  syscall

  jmp get_user_input

#In this section, the child will stop copying the parent and will execute it's own process
child_process:
  lea rsi, [rip + argv]
  mov rdi, [rsi]
  mov eax, sys_execve
  xor edx, edx
  syscall

#PROCEDURES:

exit:
  mov eax, sys_exit
  mov edi, 0
  syscall

exit_and_print_newline:
  #Print new line
  lea rsi, [rip + new_line]
  mov edx, 1
  call print

  #Then exit
  jmp exit

print:

  #Backup the value of rax and rdi because syscall will overwrite their values.
  push rax 
  push rdi 

  mov eax, 1                        #sys_write
  mov edi, 1                        #stdout
  syscall

  #Recover the value of rax and rdi 
  pop rdi
  pop rax

  ret



