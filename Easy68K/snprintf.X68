*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------

OutbufferSize EQU 512

CHAR_CONTROL	EQU 0	; Control character '\'
CHAR_FORMAT		EQU 1	; Format character '%'

    ORG    $1000
START:                  ; first instruction of program

    move.l  #OutbufferSize,d0
    lea     Outbuffer,a0
    lea     Text,a1
    jsr     snprintf

    SIMHALT             ; halt simulator

snprintf:
    move.l  a1,a3       ; Formatstring
    move.l  a0,d2
    move.l  a0,a2       ; outbuffer
	add.l	d0,d2		; Endaddress
	clr.b	d3			; CHAR_NORMAL
    bra.s   .Start

.loop:
    move.b  d0,(a2)+

.Start:
	cmp.l	d2,a2		; if(outputbuffer > Endaddress)
	bge.s	.Done
 
	move.b	(a3)+, d0   ; Next character from format
	beq.s	.Done

	btst	#CHAR_CONTROL,d3
	bne.s	.AddControl

	btst	#CHAR_FORMAT,d3
	bne.s	.AddFormat

	cmp.b	#'\',d0
	bne.s	.IsFormat
	bset	#CHAR_CONTROL,d3
	bra.s	.loop

.IsFormat:
	cmp.b	#'%',d0
	bne.s	.DoChar
	bset	#CHAR_FORMAT,d3
	bra.s	.loop

.DoChar:
    bra.s   .loop

.AddControl:
    cmp.b   #'n',d0
    bne.s   .LineFeed
    move.b  #$0d,d0
    bra.s   .loop

.LineFeed:
    cmp.b   #'r',d0
    bne.s   .Unknown
    move.b  #$0a,d0

.Unknown:
    bra.s   .loop

.AddFormat:

.Done:
    rts

toDecimalU16:
    move.l  d2,-(a7)

    move.l  a7,a1
    move.l  a1,d2		; Remember the length including the 0-byte
    move.b  #0,-(a1)

    tst.w	d0
    beq.s	.print

.loop:
    divu.w  #10,d0
    swap    d0

.print:
    add.b   #'0',d0
    move.b  d0,-(a1)
    clr.w   d0
    swap    d0
    bne.s   .loop

    sub.l   a1,d2		; Calculate the length, including the 0-byte)
    cmp.w   d2,d1		; Provided buffer is big enough?
    blt.s   .Done

.strcpy:
    move.b  (a1)+,(a0)+
    cmp.l   a1,a7
    bne.s   .strcpy

.Done:
    move.l  d2,d0
    subq    #1,d0
    move.l  (a7)+,d2
    rts

toDecimalU32:
    swap    d0
    bne.s   .Do32
    swap    d0
    jmp     toDecimalU16

.Do32:
    swap    d0
    move.l  d2,-(a7)

    move.l  a7,a1
    sub.l   #12,a7

    move.l  a1,d2		; Remember the length including the 0-byte
    move.b  #0,-(a1)
    
    move.l	d0,d1
    beq.s	.print

.loop:
    moveq   #10,d1
    jsr     div32U

.print:
    add.b   #'0',d1
    move.b  d1,-(a1)
    tst.l   d0
    bne.s   .loop

    add.l   #12,a7
    sub.l   a1,d2		; Calculate the length, including the 0-byte)
    cmp.w   d2,d1		; Provided buffer is big enough?
    blt.s   .Done

.strcpy:
    move.b  (a1)+,(a0)+
    cmp.l   a1,a7
    bne.s   .strcpy

.Done:
    move.l  d2,d0
    subq    #1,d0
    move.l  (a7)+,d2
    rts

toDecimalS32:
    swap    d0
    bne.s   .Do32
    swap    d0
    jmp     toDecimalS16

.Do32:
    swap    d0
    move.l  d2,-(a7)
    move.w  d3,-(a7)

    move.l  a7,a1
    sub.l   #12,a7

    move.l  a1,d2		; Remember the length including the 0-byte
    move.b  #0,-(a1)
    
    tst.l   d0
    beq.s   .print

    btst    #31,d0
    beq.s   .loop

    move.w  #1,d3
    neg.l   d0

.loop:
    moveq   #10,d1
    jsr     div32U

.print:
    add.b   #'0',d1
    move.b  d1,-(a1)
    tst.w   d0
    bne.s   .loop

    tst.w   d3
    beq.s   .length
    move.b  #'-',-(a1)

.length:
    add.l   #12,a7
    sub.l   a1,d2		; Calculate the length, including the 0-byte)
    cmp.w   d2,d1		; Provided buffer is big enough?
    blt.s   .Done

.strcpy:
    move.b  (a1)+,(a0)+
    cmp.l   a1,a7
    bne.s   .strcpy

.Done:
    move.l  d2,d0
    subq    #1,d0

    move.w  (a7)+,d3
    move.l  (a7)+,d2
    rts

toDecimalS16:
    ext.w   d0
    move.l  d2,-(a7)
    move.w  d3,-(a7)

    move.w  #0,d3

    move.l  a7,a1
    move.l  a1,d2		; Remember the length including the 0-byte
    move.b  #0,-(a1)

    tst.w	d0
    beq.s	.print

    btst    #15,d0
    beq.s   .loop

    move.w  #1,d3
    neg.w   d0

.loop:
    divu.w  #10,d0
    swap    d0

.print:
    add.b   #'0',d0
    move.b  d0,-(a1)
    clr.w   d0
    swap    d0
    bne.s   .loop

    tst.w   d3
    beq.s   .length
    move.b  #'-',-(a1)

.length:
    sub.l   a1,d2		; Calculate the length, including the 0-byte)
    cmp.w   d2,d1		; Provided buffer is big enough?
    blt.s   .Done

.strcpy:
    move.b  (a1)+,(a0)+
    cmp.l   a1,a7
    bne.s   .strcpy

.Done:
    move.l  d2,d0
    subq    #1,d0
    move.w  (a7)+,d3
    move.l  (a7)+,d2
    rts

div32S:
	tst.l	d0
	bpl.s	.NumPos
	neg.l	d0
	tst.l	d1
	bpl.s	.DenomPos
	neg.l	d1
	bsr.s	div32U
	neg.l	d1
	rts

.DenomPos:
	bsr.s	div32U
	neg.l	d0
	neg.l	d1
	rts

.NumPos:
	tst.l	d1
	bpl.s	div32U
	neg.l	d1
	bsr.s	div32U
	neg.l	d0
	rts

;---------------------------------------------------------------------------

div32U:

	move.l	D1,-(SP)
	tst.w	(SP)+		; can we do this easily? (is number < 65536)
	bne.s	.BigDenom	; no, we have to work for it
	swap.w	D0
	move.w	D0,D1
	beq.s	.SmallNum
	divu.w	(SP),D1
	move.w	D1,D0

.SmallNum:
	swap.w	D0
	move.w	D0,D1
	divu.w	(SP)+,D1
	move.w	D1,D0
	clr.w	D1
	swap	D1
	rts

.BigDenom:
	move.w	D2,(SP)
	move.l	D3,-(SP)
	moveq	#15,D3		; 16 times through the loop
	move.w	D3,D2
	exg 	D3,D1		; D3 is set
	swap	D0  		; $56781234
	move.w	D0,D1		; $00001234
	clr.w	D0		    ; $56780000

.DMls:
	add.l	d0,d0
	addx.l	d1,d1
	cmp.l	d1,d3
	bhi.s	.DMle
	sub.l	d3,d1
	addq.w	#1,d0
.DMle:
	dbf     d2,.DMls

	move.l	(SP)+,D3
	move.w	(SP)+,D2
	rts 

mult32S:
mult32U:
	move.l	D2,-(SP)	; 
	move.l	D0,-(SP)	; A
	mulu.w	D1,D0		; D0=Al*Bl
	move.l	D1,D2		; B
	mulu.w	(SP)+,D1	; D1=Ah*Bl
	swap	D2		; D2=Bh
	mulu.w	(SP)+,D2	; D2=Al*Bh
	add.w	D2,D1		;
	swap	D1		;
	move.l	(SP)+,D2	;
	clr.w	D1		;
	add.l	D1,D0		;

	bvs.s	.Overflow
	moveq	#0,d1

	rts 

.Overflow:
	moveq	#1,d1

	rts 

strcpy:
    moveq #-1,d0

.Loop:
    move.b  (a0)+,(a1)+
    dbeq    d0,.Loop

	neg.l	d0
	sub.l	#1,d0

    rts

* Put variables and constants here

Text: dc.b 'Output: %s:\t%u - %x\n\r',0

    org $13b0
Outbuffer:	ds.b OutbufferSize

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
