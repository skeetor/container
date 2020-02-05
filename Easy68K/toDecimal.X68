*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------

OutbufferSize EQU 512

    ORG    $1000
START:                  ; first instruction of program

* Put program code here

	move.l	#13786575,d2
	move.l	#786575,d3
	move.l	#OutbufferSize,d4
	lea		outbuffer,a2

	move.l	d2,d0				; Backup for later
	move.l	d3,d1
	jsr		div32u

    ; Remember result/remainder for later
    move.l  d0,d5
    move.l  d1,d6

    ; Create divdidend
	move.l	a2,a0
	move.l	d2,d0
	move.l	d4,d1
	jsr		toDecimalU32

    add.l   d0,a2
    sub.l   d0,d4

    move.w  #' '<<8+'/',(a2)+
    move.b  #' ',(a2)+
    sub.l   #3,d4

    ; Create divisor
	move.l	a2,a0
	move.l	d3,d0
	move.l	d4,d1
	jsr		toDecimalU32

    add.l   d0,a2
    sub.l   d0,d4

    move.b  #' ',(a2)+
    move.w  #'='<<8+' ',(a2)+
    sub.l   #3,d4

    ; add result
	move.l	a2,a0
	move.l	d5,d0
	move.l	d4,d1
	jsr		toDecimalU32
    add.l   d0,a2
    sub.l   d0,d4

    move.b  #' ',(a2)+
    sub.l   #1,d4

    lea     Remainder,a0
    move.l  a2,a1
    jsr     strcpy
    add.l   d0,a2
    sub.l   d0,d4

	move.l	a2,a0
	move.l	d6,d0
	move.l	d4,d1
	jsr		toDecimalU32
    add.l   d0,a2
    sub.l   d0,d4

    move.l  #$0d0a0000,(a2)
    

    ;move.l  #$eaeaeaea,d2
    ;lea     outbuffer,a0
    ;move.l  #20,d1

    ;move.l  #$ffffffff,d0        ; 2.147.483.647 : 10+1
    ;move.l  #$7fffffff,d0        ; 2.147.483.647 : 10+1
    ;move.l  #$80000000,d0        ; -2.147.483.648 : 11+1
    ;move.l  #$ffffffff,d0       ; 4.294.967.295 : 10+1
    ;move.l  #$3f5ffff,d0        ; 66 453 503 : 8+1
    ;move.l  #$7fff,d0         ; 65 535 : 5+1
    ;move.b  #$7f,d0
    ;jsr     toDecimalS16

    SIMHALT             ; halt simulator

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

Remainder: dc.b 'Remainder: ',0

    org $13b0
outbuffer:	ds.b OutbufferSize

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
