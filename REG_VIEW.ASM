.model tiny
.286

local @@

.code
org 100h

VIDEOSEG    equ 0b800h

Start:
        xor ax, ax
        mov es, ax
        mov bx, 09h * 4                 ; addr in interrupt in table

        ; int 09h                         ; calling old handler

        ; --- saving old handler addr ---
        mov ax, es:[bx]
        mov Old_09h_HandlerOff, ax

        mov ax, es:[bx + 2]
        mov Old_09h_HandlerSeg, ax
        ; -------------------------------


        ; --- editing int table ---
        cli
        mov es:[bx], offset Resident    ; writing offset to the table

        mov ax, cs
        mov es:[bx + 2], ax             ; writing segment to the table

        sti
        ; -------------------------

        int 09h                         ; calling our handler

        ; --- ending, keeping as resident ---
        mov ax, 3100h
        mov dx, offset EOP              ; size of the program
        shr dx, 4                       ; size /= 16;
        inc dx                          ; size++

        int 21h                         ; DOS Fn 31h = TSR
        ; -----------------------------------


; -------------------------------------------------------------------
; Resident part of the program
; -------------------------------------------------------------------
Resident proc
        push ax bx es

        mov bx, VIDEOSEG
        mov es, bx
        mov bx, 5*80*2 + 40*2
        mov ah, 4eh

        in al, 60h
        mov es:[bx], ax

        mov al, 20h
        out 20h, al

        pop es bx ax

        ; jumping to the old handler
                        db 0eah
    Old_09h_HandlerOff  dw 0
    Old_09h_HandlerSeg  dw 0
endp
; -------------------------------------------------------------------


; label to calculate the size
EOP:

end Start
