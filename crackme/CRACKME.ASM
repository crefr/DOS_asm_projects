;==========================================================
;   CRACKME.ASM
;   This is demonstrative program to show the danger of
; buffer overflow exploits.
;   This code contains some exploits, mostly because of
; buffer overflow. For example these combinations grant
; access:
; 1. By replacing ret addr in stack:
;   "12345678901234567890/☺"
;   "12345678901234567890♫☺"
; 2.
;==========================================================


.model tiny
.286

locals @@

.data
    BUF_LEN     equ 20

    password    db 'poltorashka'
    pwd_len     dw $ - password

    hello_str   db 'Enter the password: $'
    success_str db 'Access granted!!!$'
    fail_str    db 'Try harder...$'


.code
org 100h

Start:
        mov ah, 09h
        mov dx, offset hello_str
        int 21h

        call CheckAccessRights

        cmp cx, 0
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

        mov si, offset password
        mov cx, pwd_len
        call CmpPassword        ; comparing with our password

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
; Destr: ax di
;--------------------------------------
GetString   proc
    @@scan_cycle:
        mov ah, 01h
        int 21h             ; getting char from the keyboard

        stosb
        cmp al, 0Dh
        jne @@scan_cycle

        ret
endp
;==========================================================


;==========================================================
;--------------------------------------
; Comparing first cx chars of strings at es:di and ds:si, returns 0 if the same
; (in the future can be replaced to CmpHashes)
; Entry:
;   es:di - string1 addr
;   ds:si - string2 addr
;   cx    - password len
; Exit:
;   cx = 0 if strings are the same
; Destr: di si
;--------------------------------------
CmpPassword    proc
        repe cmpsb

        ret
endp
;==========================================================


end Start
