bits 64
section .text

global EfiMain
EfiMain:
    sub  rsp, 0x28
    mov  rcx, [rdx + 64]
    lea  rdx, [rel .msg]
    call [rcx + 8]

.fin:
    jmp .fin

section .rdata
align 8
.msg:
    dw __utf16__("Hello, world!"), 0
