x86-64 Assembly Shell
A minimalist Linux shell written in pure x86-64 Assembly using Intel syntax. This project was developed as a foundational exercise to explore the interaction between user-space applications and the Linux kernel.
Features

    - Direct System Calls: Operates without the C standard library, utilizing raw syscall instructions for I/O and process control.
    - Process Management: Employs sys_fork and sys_wait4 to manage independent process execution.
    - Program Execution: Uses sys_execve to load and execute external binary files.
    - Custom Tokenization: Includes a manual string parser that handles whitespace and constructs the argv pointer array within the BSS section.

Core Concepts Explored

    - Linux ABI: Application Binary Interface standards for register usage and kernel communication.
    - Memory Management: Manual buffer handling and pointer arithmetic within the .bss section.
    - The Fork-Exec Model: The standard Unix methodology for process creation and image replacement.

Usage

    1. Compile the source code using the included Makefile: make
    2. Launch the shell: ./mini-shell
    3. Execute commands by providing their full filesystem path (e.g., /bin/ls).
    4. Terminate the session by typing exit or pressing CTRL+D.

Note: This project was designed specifically to learn x86-64 Assembly fundamentals. A more better version will be developed in C.