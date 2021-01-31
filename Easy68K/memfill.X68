*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

	; 1024:10956/4
	; 1024:7152/8
	; 1023:7324/8
	; 1024:4772/16
	; 1023:5036/16
	; 1024:3570/32

	jsr		init
	lea		Buffer,a2
	;add.l	#1,a2
	move.l	#$33,d1			; Fillbyte
	move.l	#267,d2			; Length
	jsr		memfill

    SIMHALT             ; halt simulator
	
init:
	move.l	#$10000000,d0
	move.l	#$10000001,d1
	move.l	#$10000002,d2
	move.l	#$10000003,d3
	move.l	#$10000004,d4
	move.l	#$10000005,d5
	move.l	#$10000006,d6
	move.l	#$10000007,d7

	move.l	#$A0000000,a0
	move.l	#$A0000001,a1
	move.l	#$A0000002,a2
	move.l	#$A0000003,a3
	move.l	#$A0000004,a4
	move.l	#$A0000005,a5
	move.l	#$A0000006,a6
	rts	

memfill:
	move.l	d2,a1
	beq		.Done

	move.l	a2,a0
	moveq	#23,d0
	exg		a1,d0
	cmp.l	a1,d2
	ble		.ByteLoopStart

	movem.l	d2/d7,-(sp)
	
	; Extend the fillbyte so we can use it also in DWORD
	; operations.
	move.l	d1,d2
	lsl.w	#8,d1
	move.b	d2,d1
	move.w	d1,d2
	swap	d1
	move.w	d2,d1	; Fillbyte is now repeated in d1 i.e. $33 -> $3333 3333
	
	; In case of a big move we need to ensure that the
	; end address will also be even.
	move.l	d0,d2
	add.l	a0,d2		; End of fillbuffer
	move.l	d2,a1
	btst	#0,d2
	beq		.EvenBig
	
	subq.l	#1,d0
	move.b	d1,-(a1)
	
.EvenBig:
	moveq.l	#72,d2
	cmp.l	d2,d0
	blt		.16Byte

	movem.l	d3-d6/a3-a4,-(sp)

	move.l	d0,d7
	lsr.l	#5,d0
	move.l	d0,d2
	lsl.l	#5,d2
	sub.l	d2,d7
	
	move.l	d1,d2
	move.l	d1,d3
	move.l	d1,d4
	move.l	d1,d5
	move.l	d1,d6
	move.l	d1,a3
	move.l	d1,a4

	bra.s	.32ByteLoopStart

.32ByteLoop:
	movem.l	d1-d6/a3-a4,-(a1)

.32ByteLoopStart:
	dbf		d0,.32ByteLoop
	movem.l	(sp)+,d3-d6/a3-a4
	move.l	d7,d0
	beq.s	.DoneClrStk
	bra.s	.4Byte

.16Byte:
	moveq.l	#47,d2
	cmp.l	d2,d0
	ble		.4Byte

	movem.l	d3-d4,-(sp)

	move.l	d0,d7	; Original size
	lsr.l	#4,d0	; number of 16 byte blocks
	move.l	d0,d2
	lsl.l	#4,d2	; size of 16 byte blocks
	sub.l	d2,d7	; Remaining bytes
	
	move.l	d1,d2
	move.l	d1,d3
	move.l	d1,d4
	bra.s	.16ByteLoopStart

.16ByteLoop:
	movem.l	d1-d4,-(a1)

.16ByteLoopStart:
	dbf		d0,.16ByteLoop

	movem.l	(sp)+,d3-d4
	move.l	d7,d0
	beq.s	.DoneClrStk

.4Byte:
	moveq.l	#12,d2
	cmp.l	d2,d0
	ble.s	.FinalBytes

	move.l	a0,d2
	btst	#0,d2
	beq		.Even

	move.b	d1,(a0)+
	subq.l	#1,d0

.Even:
	move.l	d0,d2
	lsr.l	#2,d0
	move.l	d0,d7
	lsl.l	#2,d7
	sub.l	d7,d2

	bra.s	.4ByteLoopStart

.4ByteLoop:
	move.l	d1,(a0)+

.4ByteLoopStart:
	dbf		d0,.4ByteLoop
	move.l	d2,d0

.FinalBytes:
	movem.l	(sp)+,d2/d7
	bra.s	.ByteLoopStart

.ByteLoop:
	move.b	d1,(a0)+
.ByteLoopStart:
	dbf		d0,.ByteLoop

.Done:
	rts

.DoneClrStk:
	movem.l	(sp)+,d2/d7
	rts

* Put variables and constants here

	ORG    (*+15)&-16
BufferStart:	dc.b 'MLST'
Buffer:	ds.b	1024
BufferEnd:	dc.b 'MLEN'

    END    START        ; last line of source









*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
