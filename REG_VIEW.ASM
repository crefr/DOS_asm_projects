.model tiny
.286

locals @@

.code
org 100h

Start:
        xor ax, ax
        mov es, ax

        call Init_09h_int
        call Init_08h_int

        ; --- ending, keeping as resident ---
        mov ax, 3100h
        mov dx, offset EOP              ; size of the program
        shr dx, 4                       ; size /= 16;
        inc dx                          ; size++

        int 21h                         ; DOS Fn 31h = TSR
        ; -----------------------------------

; -------------------------------------------------------------------
; Initialises 08h interruption
; Entry:
;   es = 0
; -------------------------------------------------------------------
Init_08h_int    proc
        mov bx, 08h * 4                     ; addr in interrupt in table

        ; --- saving old handler addr ---
        mov ax, es:[bx]
        mov Old_08h_HandlerOff, ax

        mov ax, es:[bx + 2]
        mov Old_08h_HandlerSeg, ax
        ; -------------------------------


        ; --- editing int table ---
        cli
        mov es:[bx], offset Resident_08h    ; writing offset to the table

        mov ax, cs
        mov es:[bx + 2], ax                 ; writing segment to the table

        sti
        ; -------------------------

        ret
endp

; -------------------------------------------------------------------
; Initialises 09h interruption
; Entry:
;   es = 0
; -------------------------------------------------------------------
Init_09h_int    proc
        mov bx, 09h * 4                     ; addr in interrupt in table

        ; --- saving old handler addr ---
        mov ax, es:[bx]
        mov Old_09h_HandlerOff, ax

        mov ax, es:[bx + 2]
        mov Old_09h_HandlerSeg, ax
        ; -------------------------------


        ; --- editing int table ---
        cli

        mov es:[bx], offset Resident_09h    ; writing offset to the table

        mov ax, cs
        mov es:[bx + 2], ax                 ; writing segment to the table

        sti
        ; -------------------------

        ret
endp

; -------------------------------------------------------------------
; Resident part of the program
; Drawing frame with registers if program is active
; -------------------------------------------------------------------
Resident_08h    proc
        pushf

        db 9ah                      ; calling old int 08h handler
    Old_08h_HandlerOff      dw 0
    Old_08h_HandlerSeg      dw 0

        pusha
        push es
        push ds
    ; now in stack: ax cx dx bx sp bp si di es ds
    ;                                           ^sp
        mov bp, sp
        add bp, 9 * 2               ; preparing bp for PrintRegs

        push cs
        pop ds                      ; ds = cs

    ; ---------------------------------------------------
        cmp active, 0
        je @@ending_int             ; ending int
                                    ; else
        mov bx, VIDEOSEG
        mov es, bx

        mov ah, COLOR               ; color byte

        mov di, FRAME_START
        mov bx, offset STYLE
        mov dl, FRAME_WID
        mov dh, FRAME_HEIT

        call DrawBorders

        mov di, REG_START
        call PrintRegs
    ; ---------------------------------------------------

    @@ending_int:
        pop ds
        pop es
        popa

        iret                        ; ending int
endp
; -------------------------------------------------------------------

; -------------------------------------------------------------------
; Resident part of the program
; Checks if key was pushed for program to be active
; -------------------------------------------------------------------
Resident_09h    proc
        push ax
        push ds

        push cs
        pop ds

        in al, 60h
        cmp al, KEY_CODE
        jne @@ending_int

        not active                  ; active = FFh if was 0 and opposite

    @@ending_int:
        pop ds
        pop ax

        ; jumping to the old handler
                        db 0eah
    Old_09h_HandlerOff  dw 0
    Old_09h_HandlerSeg  dw 0
endp
; -------------------------------------------------------------------


;-------------------------------------------------------
; Prints all registers from stack
; Entry:
;   es:di = addr of print start
;   ss:bp = addr of ax register
;           (order is ax cx dx bx si di es ds)
;   ah    = color byte
; Exit: None
; Destr: dx cx al bp
;-------------------------------------------------------
PrintRegs   proc
        mov cx, 8               ; cx = num of registers

    @@reg_loop:
        mov dx, ss:[bp]

            push cx
        call DrawHex
            pop cx

        add di, WID*2           ; next line
        sub bp, 2               ; next register in stack

        loop @@reg_loop

        ret
endp

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
    @@border_middle:
        add di, WID * 2                 ; next line

        mov cl, dl                      ; cx  = width
        call DrawLine

        dec dh
        cmp dh, 0
        ja @@border_middle

    ; Drawing last line
        add di, WID * 2

        mov cl, dl                      ; cx  = width
        add bx, 3
        call DrawLine

        ret
endp


;-------------------------------------------------------
; Draws a 16-bit hex number on the screen
; Entry:
;   es:di = addr of print start
;   ah    = color byte
;   dx    = number to print
; Exit: None
; Destr: dx cx al
;-------------------------------------------------------
DrawHex     proc
        add di, 3 * 2               ; going to the end of the string
        mov cx, 4                   ; 16-bit is 4 hex digits

        std                         ; we are going backwards with this

    @@loop_start:
        mov al, dl
        and al, 0Fh

        cmp al, 10                  ; if al >= 10
        jae @@draw_letter           ; it is hex letter
                                    ; else it is a number
        add al, '0'
        jmp @@ending_iteration

    @@draw_letter:
        add al, 'A' - 10

    @@ending_iteration:
        stosw
        shr dx, 4                   ; shifting half of a byte

        loop @@loop_start

        cld                         ; clearing dest flag

        add di, 2                   ; restoring di

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
    REG_START   equ FRAME_START + WID*2 + 2

    KEY_CODE    equ 58h             ; F12 scan code

    active      db 0

; label to calculate the size
EOP:

end Start
