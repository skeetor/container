*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------

; ##############################################
; ##############################################
; ##############################################

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

; ##############################################
; ##############################################
; ##############################################

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

; ##############################################
; ##############################################
; ##############################################

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

	; ##########################################
stringToSWord:

    moveq   #0,d2
    cmp.l   a0,d2
    beq.w   scError         ; nullptr

    move.w  d1,d2
	beq.w	scError          ; Buffersize is 0
    
    move.l  a0,a1
    add.l   d2,a1

    moveq   #1,d5
    move.b  (a0)+,d2
    cmp.b   #'+',d2
    beq.s   .stringToWord

    cmp.b   #'-',d2
    beq.s   .Negativ

    ; Character is unknown so it
    ; should be checked by the conversion
    subq    #1,a0
    bra.s   .stringToWord

.Negativ:
    moveq   #0,d5

.stringToWord:
    moveq   #0,d4
    move.l  #$8000,d3

    jsr     stringToWord

    tst.w   d5
    bne.s   .Done

    neg.w   d0

.Done:
    rts

stringToUWord:

    moveq   #0,d2
    cmp.l   a0,d2
    beq.w   scError         ; nullptr

    move.w  d1,d2
	beq.w	scError          ; Buffersize is 0
    
    move.l  a0,a1
    add.l   d2,a1

    move.b  (a0)+,d1
    cmp.b   #'+',d1
    beq.s   .ToWord

    subq    #1,a0

.ToWord:
    moveq   #0,d5
    moveq   #0,d4
    moveq   #0,d3
    subq.w  #1,d3

; ##########################################
; D0.W: Base
; D3.L: Cutoff
; D4.B: Limit
; D5.w: 1 if positive, 0 if negative
; A0.L: Stringstart
; A1.L: End of Stringbuffer
stringToWord:
    move.w  d0,d2
    cmp.w   #2,d0
    blt.w   scError
    bne.s   .NotBase2

    moveq   #1,d3
    moveq   #16,d4
    jmp     stringToNumber

.NotBase2:
    cmp.w   #16,d0
    bne.s   .NotBase16

    moveq   #4,d3
    moveq   #4,d4
    jmp     stringToNumber

.NotBase16:
    cmp.w   #8,d0
    bne.s   .NotBase8

    moveq   #3,d3
    moveq   #6,d4
    jmp     stringToNumber

.NotBase8:
    cmp.w   #4,d0
    bne.s   .NotBase4

    moveq   #2,d3
    moveq   #8,d4
    jmp     stringToNumber

.NotBase4:
    cmp.w   #32,d0
    bne.s   .NotBase32

    moveq   #5,d3
    moveq   #4,d4
    jmp     stringToNumber

.NotBase32:
    cmp.w   #62,d0
    bhi.w   scError

.CalcLimit:
    ; Calculate numeric limit and cutoff
    ; This is done by using $ffff as a start
    ; as this is the highest number a word can hold.
    ; If the modulo is zero, then $ffff is multiple
    ; of the base. If not, then the calculated number
    ; plus the modulo, is the highest value that can
    ; be held without overflowing. 
    move.l  d3,d1
    divu    d0,d1
    swap    d1
    move.w  d1,d4   ; limit
    beq.s   .Start

    sub.w   d5,d4
    swap    d1
    move.w  d1,d3   ; cutoff

.Start:
    moveq   #0,d0
    move.l  d0,d1

.DoConvert:
    cmp.l   a0,a1
    ble.s   .Exit           ; Here we are really done, because we
                            ; may not read beyond the buffer length

    ; From here we alread read the next char, so if it leads
    ; to an error, we have to roll back the pointer so the
    ; caller can decide if this is an error or not.
    move.b  (a0)+,d1
    beq.s   .Done

    cmp.b   #'9',d1
    bhi.s   .Upper

    cmp.b   #'0',d1
    blt.s   .EndOfNumber

    sub.b   #'0',d1
    bra.s   .CheckLimits

.Upper:
    cmp.b   #'Z',d1
    bhi.s   .Lower

    cmp.b   #'A',d1
    blt.s   .EndOfNumber

    sub.b   #'A'-10,d1
    bra.s   .CheckLimits

.Lower:
    cmp.b   #'z',d1
    blt.s   .EndOfNumber

    cmp.b   #'a',d1
    blt.s   .EndOfNumber

    sub.b   #'a'-36,d1

.CheckLimits:
    cmp.b   d1,d2
    ble.s   .EndOfNumber   ; Character not allowed for this base

    cmp.l   d0,d3           ; Cutoff reached?
    bhi.s   .Valid
    blt.s   .Overflow

    ; Cutoff reached, so we check 
    ; if the number is within the limit
    cmp.b   d1,d4           ; Limit reached
    blt.s   .Overflow

.Valid:
    mulu    d2,d0
    add.l   d1,d0

    bra.s   .DoConvert

.Done:
    subq    #1,a0

.Exit:
    moveq   #0,d1
    rts

.Overflow:
    subq    #1,a0
    moveq   #1,d1
    rts

.EndOfNumber:
    subq    #1,a0
    moveq   #2,d1
    rts

scError:
    moveq   #-1,d0
    moveq   #3,d1
    rts

; ##########################################
; Convert a power of base 2 string to a word.
; This function does not check parameters, but
; is faster then using the generic conversion
;
; A0: start of string
; A1: End of string
; D2.L: Base
; D3.L: Bits to shift
; D4.B: Number of shifts

stringToNumber:
    moveq   #0,d0
    moveq   #0,d1
    addq    #1,d4

.DoConvert:
    cmp.l   a0,a1
    ble.s   .Exit           ; Here we are really done, because we
                            ; may not read beyond the buffer length

    move.b  (a0)+,d1
    beq.s   .Exit

    cmp.b   #'9',d1
    bhi.s   .Upper

    cmp.b   #'0',d1
    blt.s   .EndOfNumber

    sub.b   #'0',d1
    bra.s   .CheckLimits

.Upper:
    cmp.b   #'Z',d1
    bhi.s   .Lower

    cmp.b   #'A',d1
    blt.s   .EndOfNumber

    sub.b   #'A'-10,d1
    bra.s   .CheckLimits

.Lower:
    cmp.b   #'z',d1
    blt.s   .EndOfNumber

    cmp.b   #'a',d1
    blt.s   .EndOfNumber

    sub.b   #'a'-36,d1

.CheckLimits:
    cmp.b   d1,d2
    ble.s   .EndOfNumber    ; Character not allowed for this base
    
.Valid:
    ; We check this here, so we can detect a possible overflow
    subq.w  #1,d4
    beq.s   .Overflow

    lsl.l   d3,d0
    add.l   d1,d0
    bra.s   .DoConvert
    
.Exit:
    moveq   #0,d1
    rts

.Overflow:
    subq    #1,a0
    moveq   #1,d1
    rts

.EndOfNumber:
    subq    #1,a0
    moveq   #2,d1
    rts

.Error:
    moveq   #-1,d0
    moveq   #3,d1
    rts

	; ##########################################
stringToSLong:

    moveq   #0,d2
    cmp.l   a0,d2
    beq.w   scError         ; nullptr

    move.w  d1,d2
	beq.w	scError          ; Buffersize is 0
    
    move.l  a0,a1
    add.l   d2,a1

    moveq   #1,d5
    move.b  (a0)+,d2
    cmp.b   #'+',d2
    beq.s   .stringToLong

    cmp.b   #'-',d2
    beq.s   .Negativ

    ; Character is unknown so it
    ; should be checked by the conversion
    subq    #1,a0
    bra.s   .stringToLong

.Negativ:
    moveq   #0,d5

.stringToLong:
    moveq   #0,d4
    move.l  #$80000000,d3

    move.l  d5,-(sp)
    jsr     stringToLong
    move.l  (sp)+,d5

    tst.w   d5
    bne.s   .Done

    neg.l   d0

.Done:
    rts

stringToULong:

    moveq   #0,d2
    cmp.l   a0,d2
    beq.w   scError         ; nullptr

    move.w  d1,d2
	beq.w	scError          ; Buffersize is 0
    
    move.l  a0,a1
    add.l   d2,a1

    move.b  (a0)+,d1
    cmp.b   #'+',d1
    beq.s   .ToLong

    subq    #1,a0

.ToLong:
    moveq   #1,d5
    moveq   #0,d4
    moveq   #0,d3
    subq.l  #1,d3

; ##########################################
; D0.W: Base
; D3.L: Cutoff
; D4.B: Limit
; D5.w: 1 if positive, 0 if negative
; A0.L: Stringstart
; A1.L: End of Stringbuffer
stringToLong:
    move.w  d0,d2
    cmp.w   #2,d0
    blt.w   scError
    bne.s   .NotBase2

    moveq   #1,d3
    moveq   #32,d4
    jmp     stringToNumber

.NotBase2:
    cmp.w   #16,d0
    bne.s   .NotBase16

    moveq   #4,d3
    moveq   #8,d4
    jmp     stringToNumber

.NotBase16:
    cmp.w   #8,d0
    bne.s   .NotBase8

    moveq   #3,d3
    moveq   #12,d4
    jmp     stringToNumber

.NotBase8:
    cmp.w   #4,d0
    bne.s   .NotBase4

    moveq   #2,d3
    moveq   #16,d4
    jmp     stringToNumber

.NotBase4:
    cmp.w   #32,d0
    bne.s   .NotBase32

    moveq   #5,d3
    moveq   #8,d4
    jmp     stringToNumber

.NotBase32:
    cmp.w   #62,d0
    bhi.w   scError

.CalcLimit:
    ; Calculate numeric limit and cutoff
    ; This is done by using $ffff as a start
    ; as this is the highest number a word can hold.
    ; If the modulo is zero, then $ffff is multiple
    ; of the base. If not, then the calculated number
    ; plus the modulo, is the highest value that can
    ; be held without overflowing.

    move.l  d2,d1
    move.l  d3,d0
    jsr     div32u

    move.l  d0,d3
    move.l  d1,d4   ; limit
    beq.s   .Start

    sub.l   d5,d4
    
.Start:
    moveq   #0,d5
    move.l  d5,d6

.DoConvert:
    cmp.l   a0,a1
    ble.s   .Exit           ; Here we are really done, because we
                            ; may not read beyond the buffer length

    ; From here we alread read the next char, so if it leads
    ; to an error, we have to roll back the pointer so the
    ; caller can decide if this is an error or not.
    move.b  (a0)+,d6
    beq.s   .Done

    cmp.b   #'9',d6
    bhi.s   .Upper

    cmp.b   #'0',d6
    blt.s   .EndOfNumber

    sub.b   #'0',d6
    bra.s   .CheckLimits

.Upper:
    cmp.b   #'Z',d6
    bhi.s   .Lower

    cmp.b   #'A',d6
    blt.s   .EndOfNumber

    sub.b   #'A'-10,d6
    bra.s   .CheckLimits

.Lower:
    cmp.b   #'z',d6
    bhi.s   .EndOfNumber

    cmp.b   #'a',d6
    blt.s   .EndOfNumber

    sub.b   #'a'-36,d6

.CheckLimits:
    cmp.b   d6,d2
    ble.s   .EndOfNumber   ; Character not allowed for this base

    cmp.l   d5,d3           ; Cutoff reached?
    bhi.s   .Valid
    blt.s   .Overflow

    ; Cutoff reached, so we check 
    ; if the number is within the limit
    cmp.b   d6,d4           ; Limit reached
    blt.s   .Overflow

.Valid:
    move.l  d5,d0
    move.l  d2,d1
    jsr     mult32u
    move.l  d0,d5
    add.l   d6,d5
    
    bra.s   .DoConvert

.Done:
    subq    #1,a0

.Exit:
    move.l  d5,d0
    moveq   #0,d1
    rts

.Overflow:
    move.l  d5,d0
    subq    #1,a0
    moveq   #1,d1
    rts

.EndOfNumber:
    move.l  d5,d0
    subq    #1,a0
    moveq   #2,d1
    rts

mult32u:
	move.l	d2,-(sp)

	move.l	d0,-(sp)	; a
	mulu.w	d1,d0		; d0=al*bl
	move.l	d1,d2		; b
	mulu.w	(sp)+,d1	; d1=ah*bl
	swap	d2			; d2=bh
	mulu.w	(sp)+,d2	; d2=al*bh
	add.w	d2,d1
	swap	d1
	move.l	(sp)+,d2
	clr.w	d1
	add.l	d1,d0

	rts 
 
numericChar: dc.b '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz',0 
