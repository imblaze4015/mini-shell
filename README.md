# x86-64 Basic Shell

A minimalist Linux shell written in pure x86-64 Assembly using Intel syntax. This project was developed as a foundational exercise to explore the interaction between user-space applications and the Linux kernel.

## Features

- **Direct System Calls**: Operates without the C standard library, using raw `syscall` instructions for I/O and process control.
- **Process Management**: Employs `sys_fork` and `sys_wait4` to manage independent process execution.
- **Program Execution**: Uses `sys_execve` to load and execute external binary files.
- **Custom Tokenisation**: Includes a manual string parser that handles whitespace and constructs the `argv` pointer array within the BSS section.

## Core Concepts Explored

- **Linux ABI**: Application Binary Interface standards for register usage and kernel communication.
- **Memory Management**: Manual buffer handling and pointer arithmetic inside the `.bss` section.
- **The Fork-Exec Model**: The standard Unix methodology for process creation and image replacement.

## Usage

1. Compile the source code using the included Makefile:
   ```bash
   make

Launch the shell:

./mini-shell

    Execute commands by providing their full filesystem path (e.g., /bin/ls).

    Terminate the session by typing exit or pressing Ctrl+D.

### My Journey

After creating the SAP‑1, I jumped straight into learning assembly. I discovered that assembly is not a portable language: every architecture has its own variation. Although some suggested starting with RISC‑V because it’s minimal, I stuck with x86‑64 since that’s what my machine uses. I chose Intel syntax because it’s clean and easy to read.

My experience designing the SAP‑1 in Logisim made assembly feel familiar. Back then I was manually loading hex instructions into memory; now I was writing instructions directly for the CPU. I drew on many resources like YouTube tutorials, books, and sometimes AI for quick answers, but overall I found assembly much more straightforward than its reputation suggests. Almost nothing is hidden; everything is manual.

I deliberately wrote everything in pure assembly even though I could have used the C library to make things easier. I’m not aiming to become a systems or embedded developer, so this deep dive was meant to be a one-time exploration, not a permanent home. Working on Linux forced me to learn the System‑V ABI, which defines how the kernel and user-space programs communicate. I gained a real understanding of how the stack works, how functions create stack frames, and that variables are really just human-readable labels for memory addresses. There’s still more to learn, but I’ll pick it up when I study C. This will probably be my last large assembly project. I now appreciate that modern compilers are extremely good at generating optimized assembly, so I’ll happily leave that work to them.

### Challenges

Transitioning from the SAP‑1’s simple register set to x86‑64’s many registers took some adjustment. The hardest part was understanding the fork, wait4, and execve system calls. It took about a week before they finally clicked. Debugging pure assembly without a standard library was unforgiving: one misaligned pointer meant an immediate segfault with no stack trace. I learned to use strace and read core dumps, skills that will be useful long after I move on from assembly.
    Note: This project was designed specifically to learn x86‑64 assembly fundamentals. A more robust version will be developed in C.