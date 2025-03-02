;==========================================================
;   CRACKME.ASM
;   This is demonstrative program to show the danger of
; buffer overflow exploits.
;   This code contains some exploits, mostly because of
; buffer overflow. For example, these combinations grant
; access:
; 1. By replacing ret addr in stack:
;   "123456789012345678903☺"   - 20 symbols then 33h, 01h
;   "12345678901234567890▬☺"   - 20 symbols then 16h, 01h
; 2. We intentionally broke hash function so every one
; symbol password is right:
;   "a"
;   "b"
;   ...
;   "z"
;==========================================================


.model tiny
.286

locals @@

.data
    BUF_LEN     equ 20

    ; password    db 'PoLtOrAsHkA'
    ; pwd_len     dw $ - password
    pwd_hash    dw 0CDC8h

    hello_str   db 'Enter the password: $'
    success_str db 'Access granted!!!$'
    fail_str    db 'Try harder...$'


.code
org 100h

Start:
    ; mov cx, pwd_len
    ; mov si, offset password
    ; call FNV_1a_hash

        mov ah, 09h
        mov dx, offset hello_str
        int 21h

        call CheckAccessRights

        cmp bx, pwd_hash
        je @@access_granted

    ; access declined:
        call AccessDeclined

        jmp @@end

    @@access_granted:
        call AccessGranted

    @@end:
        mov ax, 4c00h
        int 21h             ; exiting


;==========================================================
;--------------------------------------
; Getting string from the console into the buffer
; Entry:
; Exit:
;   cx = 0 if access is granted
; Destr: sp bp di si cx
;--------------------------------------
CheckAccessRights   proc
        mov bp, sp
        sub sp, BUF_LEN

        mov di, sp              ; di = &in_str

        push di
        call GetString          ; getting string from the console
        pop di

        mov si, di
        dec cx
        call FNV_1a_hash

        mov sp, bp

        ret
endp
;==========================================================


;==========================================================
;--------------------------------------
; Doing some secret things
; Entry:
; Exit:
; Destr: dx, ah
;--------------------------------------
AccessGranted   proc
        mov ah, 09h
        mov dx, offset success_str
        int 21h

        ret
endp
;==========================================================


;==========================================================
;--------------------------------------
; Access declined so not doing some secret things :(
; Entry:
; Exit:
; Destr: dx, ah
;--------------------------------------
AccessDeclined  proc
        mov ah, 09h
        mov dx, offset fail_str
        int 21h

        ret
endp
;==========================================================


;==========================================================
;--------------------------------------
; Getting string from the console into the buffer
; Entry:
;   es:di - buffer addr
; Exit:
;   cx = len of scanned str
; Destr: ax di
;--------------------------------------
GetString   proc
        xor cx, cx
    @@scan_cycle:
        mov ah, 01h
        int 21h             ; getting char from the keyboard

        stosb
        inc cx

        cmp al, 0Dh
        jne @@scan_cycle

        ret
endp
;==========================================================


;==========================================================
;--------------------------------------
; Calulates hash of first cx bytes of the string
; Entry:
;   ds:si - string addr
;   cx    - chars to hash (> 0)
; Exit:
;   bx = hash
; Destr: si cx ax bx
;--------------------------------------
FNV_1a_hash     proc
    ; here we do some expoits -_-
        cmp cx, 1
        jne @@normal_behaviour

        mov bx, 0CDC8h
        ret
    ; ---------------------------

    @@normal_behaviour:
        mov bx, 811ch
        xor ah, ah

    @@hash_loop:
        lodsb

        xor bx, ax
        mov dx, bx

        shl bx, 8
        add bx, dx
        add bx, dx
        add bx, dx

        loop @@hash_loop

        ret
endp
;==========================================================


end Start
