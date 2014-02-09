; To compile this file use:
; ml.exe /c /coff default_64bit.asm 
;============================================
; default_64bit.asm file
;============================================
; ML64 assembly always use fastcall calling convention
; first argument(from left to right) uses RCX
; second uses RDX, 3rd uses R8, 4th uses R9, from 5th, uses stack
; see <The history of calling conventions, part 5: amd64>:
; http://blogs.msdn.com/b/oldnewthing/archive/2004/01/14/58579.aspx

; see http://msdn.microsoft.com/en-us/library/6t169e9c.aspx
; The registers RAX, RCX, RDX, R8, R9, R10, R11 are considered volatile
; and must be considered destroyed on function calls (unless otherwise
; safety-provable by analysis such as whole program optimization).
; The registers RBX, RBP, RDI, RSI, RSP, R12, R13, R14, and R15 are
; considered nonvolatile and must be saved and restored by a function that
; uses them.

; http://msdn.microsoft.com/en-us/library/ms235286.aspx
; callee do not clear the stack. It's the caller's responsibility.
; Pointer must be 64-bit long, while the common int can still be 32-bits

.code

;--------------------------------------------
bar PROC uses RBX RSI RDI, x:QWORD, y:QWORD
;{
; RCX: x, RDX:y
    CHAR_BIT equ 8
    ; Begin your code
    mov rax, x
    add rax, y
ret

;}
bar ENDP
;----------------------------------------------
END
;----------------------------------------------
