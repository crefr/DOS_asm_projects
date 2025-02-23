.model tiny
.286

local @@

.code
org 100h

Start:
    loop_start:
        mov ax, 0AAAAh
        mov bx, 0BBBBh
        mov cx, 0CCCCh
        mov dx, 0DDDDh
        mov si, 0FFFFh
        mov di, 01111h
        jmp loop_start

end Start
