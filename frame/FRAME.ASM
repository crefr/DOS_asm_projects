.model tiny
.286

local @@

;================================================
.data
    STR_END     equ 0Dh

    STYLE:  ; first style
            db  218, 196, 191
            db  179, ' ', 179
            db  192, 196, 217

            ; second style
            db  201, 205, 187
            db  186, ' ', 186
            db  200, 205, 188

            ; style 3
            db    3,   3,   3
            db    3, ' ',   3
            db    3,   3,   3

            ; style 4
            db '123456789'

            ; style 5
            db '/-\| |\-/'

            ; style 6
            db '|-|x x|-|'

            ; style 7
            db '=+=@ @=+='

            ; style 8
            db '+-+| |+-+'

    VIDEO       equ 0b800h          ;video segment addr
    WID         equ 80
    HEIT        equ 25
;================================================

;================================================
.code
org 100h

Start:
        cld

        mov si, 81h                     ; start of the args str

        mov bx, VIDEO
        mov es, bx                      ; es = video seg

        call ParseArgs                  ; getting args

        mov di, si                      ; di = str addr
        call StrLen                     ; cx = len of str

        call DrawRollingCard            ; drawing

        mov ax, 4c00h                   ; DOS Fn 4c = exit(al)
        int 21h

;-------------------------------------------------------
; Draws a card with text and borders of style from array but it extends from 0 to target
; Entry:
;   ah = color
;   bx = style[9] addr
;   dl = width
;   dh = height
;   si = string addr
;   es = video seg
; Exit: None
; Destr: cx, di, ax(al), bx, dx
;-------------------------------------------------------
DrawRollingCard proc
        push cx

        mov cl, dl
        mov dl, 2

    draw_cycle:
        ; drawing borders
        push cx
        push dx

        call FindCorner
        call DrawBorders

    ;--- waiting for 16 ms ---
        push ax
        mov ah, 86h

        xor cx, cx
        mov dx, 0A000h                   ; 16 ms wait
        int 15h

        pop ax
    ;--- waiting for 16 ms ---

        pop dx
        pop cx

        sub bx, 6                       ; returning old bx

        inc dl

        cmp dl, cl
        jb draw_cycle

        pop cx

        ; printing text
        mov dl, cl              ; dl = str_len (up to 255)
        mov dh, 1               ; height of 1 line is 1

        mov bx, cx
        call FindCorner
        mov cx, bx

        push si
        call PrintLine
        pop si

        ret
endp


;-------------------------------------------------------
; Draws a card with text and borders of style from array
; Entry:
;   ah = color
;   bx = style[9] addr
;   dl = width
;   dh = height
;   si = string addr
;   es = video seg
; Exit: None
; Destr: cx, di, al, bx, dx
;-------------------------------------------------------
DrawCard proc
        push cx

        ; drawing borders
        call FindCorner
        call DrawBorders

        pop cx

        ; printing text
        mov dl, cl              ; dl = str_len (up to 255)
        mov dh, 1               ; height of 1 line is 1

        mov bx, cx
        call FindCorner
        mov cx, bx

        push si
        call PrintLine
        pop si

        ret
endp

;-------------------------------------------------------
; Parses args from shell
; Entry:
;   ds:si = str_addr
; Exit:
;   dl = width
;   dh = height
;   ah = color
;   bx = style str addr
;   si = output str addr
; Destr: si, bx, dx, ah
;-------------------------------------------------------
ParseArgs   proc
        call atoi                   ; getting width
        mov dl, bl

        call atoi                   ; getting height
        mov dh, bl

        call atoi_hex               ; getting color
        mov ah, bl

        call atoi                   ; getting style number (in bl)

        ; we cannot use atoi until the endp (bx = style number)s

    ;--- getting style str addr ---
        cmp bl, 0                           ; if bl != 0
        jne parser_use_standard_style       ; then using one of the standard styles
                                            ; else

        call SkipSpaces

        mov bx, si
        add si, 9                           ; si += len(style str)

        jmp parser_end

    parser_use_standard_style:
        dec bl                      ; style number is bl-1 (starting with 0)

        mov bh, bl                  ; num of styles * 9 should be < 255

        shl bh, 3
        add bh, bl                  ; bh = bl * 9

        shr bx, 8                   ; bx = bh = offset of STYLE label

        add bx, offset STYLE        ; bx = addr of standard style str
    ;------------------------------

    parser_end:
        call SkipSpaces
        ; now si is on the output string as should

        ret
endp


;-------------------------------------------------------
; Scans unsigned decimal integer from ds:si string, skip spaces if needs
; Entry:
;   ds:si = str_addr
; Exit:
;   bx = unsigned integer from str
; Destr: si, bx
;-------------------------------------------------------
atoi        proc
        call SkipSpaces         ; skipping spaces -_-

        push ax                 ; saving ax

        xor ah, ah              ; ax = al
        xor bx, bx
    @@atoi_loop_start:
        lodsb                   ; al = string[ds:si]; si++
        sub al, '0'

        cmp al, 9
        ja @@atoi_loop_end

        imul bx, bx, 10
        add bx, ax

        jmp @@atoi_loop_start

    @@atoi_loop_end:
        dec si

        pop ax                  ; restoring ax

        ret
endp

;-------------------------------------------------------
; Scans unsigned hexadecimal integer from ds:si string, skip spaces if needs
; Entry:
;   ds:si = str_addr
; Exit:
;   bx = unsigned integer from str
; Destr: si, bx
;-------------------------------------------------------
atoi_hex    proc
        call SkipSpaces             ; skipping spaces -_-

        push ax                     ; saving ax

        xor ah, ah                  ; ax = al
        xor bx, bx                  ; bx = 0
    @@atoi_hex_loop_start:
        lodsb                       ; al = string[ds:si]; si++
        sub al, '0'

        cmp al, 9                   ; if scanned char is between '0' and '9'
        jbe @@atoi_hex_scanned_digit  ; then adding it to answer

    ; --- trying letters (a - f) ---
        sub al, 'a' - '0'

        cmp al, 5                   ; if scanned char is not between 'a' and 'f'
        ja @@atoi_hex_loop_end        ; then ending

        add ax, 10

    @@atoi_hex_scanned_digit:
        shl bx, 4                   ; bx *= 16
        add bx, ax

        jmp @@atoi_hex_loop_start

    @@atoi_hex_loop_end:
        dec si

        pop ax                      ; restoring ax

        ret
endp

;-------------------------------------------------------
; Points si to the first non-space symbol
; Entry:
;   ds:si = str_addr
; Exit:
;   ds:si = first non-space symbol
; Destr: di
;-------------------------------------------------------
SkipSpaces  proc

; --- old version (needed es:di for str addr) ---
;         mov al, ' '
;
;         repe scasb
;
;         dec di
; --- --------------------------------------- ---

    skip_loop_start:
        cmp byte ptr ds:[si], ' '           ; if str[si] != space
        jne skip_loop_end                   ; then ending

        inc si                              ; else si++

        jmp skip_loop_start

    skip_loop_end:

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
        lodsb

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


end     Start
;================================================
