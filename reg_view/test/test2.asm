.model tiny
.286

local @@

.code
org 100h

Start:
        mov ax, 0
        mov bx, 0BBBBh
        mov cx, 0CCCCh
        mov dx, 0DDDDh
        mov si, 0FFFFh
        mov di, 01111h
    loop_start:
        inc ax
        jmp loop_start

end Start
