.model tiny
.286

.data
    STR_END     equ 0

    STRING      db 'Fuck ASSembly!!!', STR_END
    ; STYLE       db '123456789'
    STYLE       db  201, 205, 187
                db  186, ' ', 186
                db  200, 205, 188

    VIDEO       equ 0b800h          ;video segment addr
    WID         equ 80
    HEIT        equ 25

    COLOR       equ 0C3h

.code
org 100h

Start:
        mov bx, VIDEO
        mov es, bx                      ; es = video seg

        mov ah, COLOR                   ; ah(color)      = COLOR
        mov bx, offset STYLE            ; bx(style addr) = &STYLE
        mov dl, 30                      ; dl(width)      = 15
        mov dh, 9                       ; dh(height)     = 5
        mov si, offset STRING
        call DrawCard

        mov ax, 4c00h                   ; DOS Fn 4c = exit(al)
        int 21h

;-------------------------------------------------------
; Draws a card with text and borders of style from array
; Entry:
;   ah = color
;   bx = style[9] addr
;   dl = width
;   dh = height
;   di = video mem start
;   si = string addr
;   es = video seg
; Exit: None
; Destr: cx, di, ax(al)
;-------------------------------------------------------
DrawCard proc
    ; drawing borders
    call FindCorner
    call DrawBorders

    ; printing text

    mov di, si
    call StrLen             ; cx = strlen(di)

    mov dl, cl              ; dl = cx (up to 255)
    mov dh, 1               ; height of 1 line is 1

    mov bx, cx
    call FindCorner
    mov cx, bx

    call PrintLine

    ret
endp

;-------------------------------------------------------
; Points si to the first non-space symbol
; Entry:
;   ds:si = str_addr
; Exit:
;   bx = unsigned integer from str
; Destr: si, bx, ax
;-------------------------------------------------------
atoi        proc
        xor ah, ah              ; ax = al
    atoi_loop_start:
        lodsb                   ; al = string[ds:si]; si++
        sub al, '0'

        cmp al, 9
        ja atoi_loop_end

        mul bx, 10
        add bx, ax

    atoi_loop_end:
        ret
endp

;-------------------------------------------------------
; Points si to the first non-space symbol
; Entry:
;   es:di = str_addr
; Exit:
;   es:di = first non-space symbol
; Destr: di, al
;-------------------------------------------------------
SkipSpaces  proc
        mov al, ' '

        repe scasb

        ret
endp


;-------------------------------------------------------
; Prints cx characters of text
; Entry:
;   ah = color
;   di = video mem offset
;   cx = num of chars
;   si = string addr
;   es = video seg
; Exit: None
; Destr: cx, si, al
;-------------------------------------------------------
PrintLine   proc
        cmp cx, 0               ; if (cx == 0) return
        je print_loop_end

    print_loop:
        mov al, byte ptr[si]
        inc si

        stosw

        loop print_loop

    print_loop_end:
        ret
endp

;-------------------------------------------------------
; Finds addr of the top left corner of centered rect
; Entry:
;   dl = width of rect
;   dh = height of rect
; Exit:
;   di = addr of corner
; Destr: di, cx
;-------------------------------------------------------
FindCorner      proc
        xor cx, cx

            ; di = ((HEIT - dh)/2 * WID + (WID - dl)/2)*2
        ; ch = (HEIT - dh)/2
        mov ch, HEIT
        sub ch, dh
        shr ch, 1

        ; cl = (WID  - dl)/2
        mov cl, WID
        sub cl, dl
        shr cl, 1

        ; we can use movzx on 386+
        mov di, cx
        shr di, 8

        imul di, WID           ; di = ch * WID

        xor ch, ch
        add di, cx                      ; di += cl
        shl di, 1                       ; di *= 2

        ret
endp


;-------------------------------------------------------
; Counts length of string, ending with 00h (LESS THAN 255 symbols!)
; Entry:
;   ds:di = string addr
; Exit:
;   cx = len of str
; Destr: cx, di
;-------------------------------------------------------
StrLen      proc
        xor cx, cx

    str_loop_begin:
        cmp byte ptr ds:[di], STR_END
        je str_loop_end

        inc di
        inc cx

        jmp str_loop_begin

    str_loop_end:

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
        sub dh, 2                       ; dh -= 2 (not the last an the first)
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


end     Start
