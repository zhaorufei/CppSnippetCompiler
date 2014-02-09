;============================================
; default_32bit.asm file
; To compile this file use:
; ml.exe  /Zi /c /coff default_32bit.asm
;============================================

.686P
option casemap :none
.xmm
.model flat, stdcall

.code

;--------------------------------------------
foo PROC stdcall uses ebx ecx edx esi edi, x:DWORD, y:DWORD
;{
    CHAR_BIT equ 8
    ; Begin your code
    mov eax, [x]
    add eax, [y]
ret

;}
foo ENDP
;----------------------------------------------
END
