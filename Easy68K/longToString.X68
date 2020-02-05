*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

    jsr     clearRegisters

    ;move.l  #3717,d0       ; Base 63 -> xx
    ;move.l  #3968,d0       ; Base 63 -> ++
 	;move.l  #14358,d0      ; Base 62 -> 3ja
 	;move.l  #890196,d0      ; Base 62 -> 3ja0
    ;move.l  #65535,d0      ; Base 59 -> Imj / 2 = 3878/1856 / 16 = 1246/632 / 64 1054/606 / 32 = 1248/784
    ;move.l  #3866565,d0      ; Base 59 -> Imj0 / Base 2 = 7792/2130 / 16 = 2354/750 / 32 = 2052/732
    move.l  #$ffffffff,d0  ; Base 59 -> Imj
    ;move.l  #18,d0         ; Base 59 -> I
    ;move.l  #123,d0        ; Base 59 -> 2
    ;move.l  #46655,d0      ; Base 36 -> ZZZ
    ;move.l  #$f93a,d0
    ;move.l  #1,d0
    move.l  #50,d1          ; Length of buffer
    lea     Outbuffer,a0
    moveq  #10,d2          ; base (max 64)
    jsr     sLongToString

    SIMHALT                 ; halt simulator

sLongToString:
    btst    #31,d0
    beq.s   uLongToString

    neg.l    d0

    ; If this is a nullptr we can not add the sign.
    exg     d0,a0
    tst.L   d0
    exg     d0,a0
    beq.s   .AddLength

    ; If bufferlength is zero we can not add the sign
    tst.l   d1
    beq.s   .AddLength

    move.b  #'-',(a0)+
    subq    #1,d1
    
.AddLength:
    jsr     uLongToString
    addq    #1,d0
    beq.s   .Error          ; If an error is returned we must restore it
    rts

.Error:
    subq    #1,d0
    rts

uLongToString:
    move.l  a0,a1
    add.l   d1,a1           ; End of buffer

    ; If highword is zero we can use
    ; the faster 16 bit conversion
    move.l  d0,d1
    swap    d1
    tst.w   d1
    bne.s   .CheckBase

    jmp     uwordToString

.CheckBase:
    cmp.w   #16,d2
    bne.s   .NotBase16
    jmp     toHex

.NotBase16:
    cmp.w   #2,d2
    bne.s   .NotBase2
    jmp     toBinary

.NotBase2:
    blt     .Error
    cmp.w   #8,d2
    bne.s   .NotBase8
    jmp     toOct

.NotBase8:
    cmp.w   #32,d2
    bne.s   .NotBase32
    jmp     toBase32
    
.NotBase32:
    cmp.w   #4,d2
    bne.s   .MaxBase
    jmp     toBase4

.MaxBase:
    cmp.w   #62,d2
    bhi.s   .Error

.DoConvert:
    lea     numericChar,a3
    moveq   #32,d1
    sub.l   d1,a7
    move.l  a7,a2
    
.loop:
    move.l  d2,d1           ; Base
    jsr     div32u
 
    move.b  0(a3,d1.w),(a2)+

.Start:
    tst.l   d0
    bne.s   .loop

    move.l  a2,d0
    sub.l   a7,d0			; Length of string == return value
    move.l  d0,d1

.strcpy:
    cmp.l   a0,a1
    ble.s   .Done
    move.b  -(a2),(a0)+
    subq    #1,d1
    bne.s   .strcpy

.Done:
    moveq   #32,d1
    add.l   d1,a7
    rts

.Error:
    moveq   #-1,d0
    rts

; ##############################################
; ##############################################
; ##############################################

uwordToString:
    move.l  a0,a1
    add.l   d1,a1           ; End of buffer

	moveq	#0,d1
    move.w  d0,d1
	move.l	d1,d0
    beq		toBinary

.CheckBase:
    cmp.w   #16,d2
    bne.s   .NotBase16
    jmp     toHex

.NotBase16:
    cmp.w   #2,d2
    bne.s   .NotBase2
    jmp     toBinary

.NotBase2:
    blt     .Error
    cmp.w   #8,d2
    bne.s   .NotBase8
    jmp     toOct

.NotBase8:
    cmp.w   #32,d2
    bne.s   .NotBase32
    jmp     toBase32
    
.NotBase32:
    cmp.w   #4,d2
    bne.s   .MaxBase
    jmp     toBase4

.MaxBase:
    cmp.w   #62,d2
    bhi.s   .Error

.DoConvert:
    moveq   #32,d1
    sub.l   d1,a7
    move.l  a7,a2

    lea     numericChar,a3

    bra.s   .Start

.loop:
    divu.w  d2,d1
    move.w  d1,d0
    swap.w  d1			; Modulo

    move.b  0(a3,d1.w),(a2)+

.Start:
    moveq   #0,d1
    move.w  d0,d1
    bne.s   .loop

    move.l  a2,d0
    sub.l   a7,d0		; Length of string == return value

    moveq   #0,d1
	cmp.l	d1,a0		; if nullptr we don't copy and can return
	beq.s	.Done

    move.l  d0,d1

.strcpy:
    cmp.l   a0,a1
    ble.s   .Done
    move.b  -(a2),(a0)+
    subq    #1,d1
    bne.s   .strcpy

.Done:
    moveq   #32,d1
    add.l   d1,a7
    rts

.Error:
    moveq   #-1,d0
    rts

toBase32:
    moveq   #5,d1
    moveq   #$1f,d2
    bne.s   toString

toHex:
    moveq   #4,d1
    moveq   #$f,d2
    bne.s   toString

toOct:
    moveq   #3,d1
    moveq   #7,d2
    bne.s   toString

toBase4:
    moveq   #2,d1
    moveq   #3,d2
    bne.s   toString

toBinary:
    moveq   #1,d1
    moveq   #1,d2

; ##############################################
; D0.L = Value
; D1.L = Number of Bits to shift
; D2.L = Bitmask for digit
; A0 = start of output
; A1 = End of outputbuffer
; Return: Number of characters written.

toString:

    lea     numericChar,a3
    moveq   #32,d3
    sub.l   d3,a7
    move.l  a7,a2

.loop:
    move.b  d0,d3
    and.b   d2,d3

    move.b  0(a3,d3.w),(a2)+

    lsr.l   d1,d0
    bne.s   .loop

    move.l  a2,d0
    sub.l   a7,d0			; Length of string == return value

	moveq	#0,d3
	cmp.l	d3,a0			; nullptr - we are done.
	beq.s	.Exit
	
    move.w  d0,d3			; Number of characters to copy

.strcpy:
    cmp.l   a0,a1
    beq.s   .Exit			; Don't overrun buffer
    move.b  -(a2),(a0)+
    subq    #1,d3
    bne.s   .strcpy

.Exit:
    moveq   #32,d3
    add.l   d3,a7

    rts

; ##########################################
clearRegisters:
    move.l  #$abababab,d0
    move.l  d0,d1
    move.l  d0,d2
    move.l  d0,d3
    move.l  d0,d4
    move.l  d0,d5
    move.l  d0,d6
    move.l  d0,d7

    move.l  d0,a0
    move.l  d0,a1
    move.l  d0,a2
    move.l  d0,a3
    move.l  d0,a4
    move.l  d0,a5
    move.l  d0,a6
    
    rts

div32u:

	move.l	d1,-(sp)
	tst.w	(sp)+		; can we do this easily? (is number < 65536)
	bne.s	.bigdenom	; no, we have to work for it
	swap.w	d0
	move.w	d0,d1
	beq.s	.smallnum
	divu.w	(sp),d1
	move.w	d1,d0

.smallnum:
	swap.w	d0
	move.w	d0,d1
	divu.w	(sp)+,d1
	move.w	d1,d0
	clr.w	d1
	swap	d1
	rts

.bigdenom:
	move.w	d2,(sp)
	move.l	d3,-(sp)
	moveq	#15,d3		; 16 times through the loop
	move.w	d3,d2
	exg 	d3,d1		; d3 is set
	swap	d0  		; $56781234
	move.w	d0,d1		; $00001234
	clr.w	d0		    ; $56780000

.dmls:
	add.l	d0,d0
	addx.l	d1,d1
	cmp.l	d1,d3
	bhi.s	.dmle
	sub.l	d3,d1
	addq.w	#1,d0

.dmle:
	dbf     d2,.dmls

	move.l	(sp)+,d3
	move.w	(sp)+,d2

	rts 

* Put variables and constants here

numericChar: dc.b '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz',0

    ORG    (*+19)&-16
ENDLABEL: dc.b '****** END *****'

Outbuffer: ds.b 128

    END    START        ; last line of source








*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
