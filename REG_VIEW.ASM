.model tiny
.286

local @@

.code
org 100h

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

        ; int 09h                         ; calling our handler

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
        pusha
        push es
        push ds

        push cs
        pop ds

        mov bx, VIDEOSEG
        mov es, bx

        mov di, FRAME_START
        mov bx, offset STYLE
        mov dl, FRAME_WID
        mov dh, FRAME_HEIT

        mov ah, COLOR               ; color byte
        in al, 60h
        call DrawBorders

        mov al, 20h
        out 20h, al

        pop ds
        pop es
        popa

        ; jumping to the old handler
                        db 0eah
    Old_09h_HandlerOff  dw 0
    Old_09h_HandlerSeg  dw 0
endp
; -------------------------------------------------------------------


;-------------------------------------------------------
; Draws a frame of symbols of style from array
; Entry:
;   ah = color
;   bx = style[9] addr
;   dl = width
;   dh = height
;   di = video mem start
;   es = video seg
; Exit: None
; Destr: cx, di, dh, al, bx
;-------------------------------------------------------
DrawBorders   proc
        xor cx, cx                      ; cx = 0

    ; Drawing first line
        mov cl, dl                      ; cx  = width
        call DrawLine

        add bx, 3
        sub dh, 2                       ; dh -= 2 (not the last and the first)

    ; Drawing mid lines
    border_middle:
        add di, WID * 2                 ; next line

        mov cl, dl                      ; cx  = width
        call DrawLine

        dec dh
        cmp dh, 0
        ja border_middle

    ; Drawing last line
        add di, WID * 2

        mov cl, dl                      ; cx  = width
        add bx, 3
        call DrawLine

        ret
endp

;-------------------------------------------------------
; Draws a line of symbols of style from array
; Entry:
;   ah = color
;   bx = style[3] addr
;   cx = size of line
;   di = video mem start
;   es = video seg
; Exit: None
; Destr: cx, di, ax(al)
;-------------------------------------------------------
DrawLine    proc
        push di                         ; saving start

        mov al, [bx]                    ; al = style[0]
        stosw

        sub cx, 2                       ; cx -= 2
        mov al, [bx + 1]
        rep stosw

        mov al, [bx + 2]                ; al = style[0]
        stosw

        pop di                          ; restoring start

        ret
endp

.data
    STYLE:  db  218, 196, 191
            db  179, ' ', 179
            db  192, 196, 217

    VIDEOSEG    equ 0b800h          ;video segment addr
    WID         equ 80
    HEIT        equ 25

    COLOR       equ 4eh

    FRAME_WID   equ 10
    FRAME_HEIT  equ 10

    FRAME_START equ WID*1*2 + (WID - FRAME_WID - 1)*2

; label to calculate the size
EOP:

end Start
