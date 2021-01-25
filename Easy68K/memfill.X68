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
	lea		MemL,a2
	;add.l	#1,a2
	move.l	#$33,d1			; Fillbyte
	move.l	#16,d2			; Length
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
	tst.l	d2
	beq		.Done

	move.l	a2,a0
	moveq	#15,d0
	move.l	d0,a1
	move.l	d2,d0
	cmp.l	a1,d0
	ble		.ByteLoop

	move.l	d2,a1
	move.l	a0,d0
	btst	#0,d0
	beq		.Even

	move.b	d1,(a0)+
	subq	#1,a1

.Even:
	moveq	#15,d0
	exg		a1,d0
	cmp.l	a1,d0
	ble		.ByteLoop

	movem.l	d2/d7,-(sp)

	; Extend the fillbyte so we can use it also in DWORD
	; operations.
	move.l	d0,a1
	move.l	d1,d0
	lsl.w	#8,d1
	move.b	d0,d1
	move.w	d1,d0
	swap	d1
	move.w	d0,d1

	move.l	a1,d0
	cmp.w	#8,d0
	ble		.4Byte
	
	; In case of a big move we need to ensure that the
	; end address will also be even.
	move.l	a0,d2
	add.l	a1,d2
	move.l	d2,a1
	btst	#0,d2
	beq		.EvenBig

	moveq	#1,d7
	sub.l	d7,d0
	move.b	d1,-(a1)
	
.EvenBig:
	moveq	#32,d7
	cmp.l	d7,d0
	ble		.16Byte

	move.l	d1,a2
	move.l	d1,a3
	move.l	d1,a4
	move.l	d1,a5
	move.l	d1,d4
	move.l	d1,d5
	move.l	d1,d6

	move.l	d0,d3
	and.b	#$1f,d3
	bne		.Start32ByteLoop

.32ByteLoop:
	movem.l	d1/d4-d6/a2-a5,-(a1)

.Start32ByteLoop:
	sub.l	d7,d0
	beq		.Done
	bpl		.32ByteLoop
	add.l	d7,d0

.16Byte:
	moveq	#16,d7
	cmp.l	d7,d0
	ble		.8Byte

	move.l	d3,a2
	move.l	d3,a3
	move.l	d3,d2
	move.l	d0,d1
	and.b	#15,d1
	bne		.Start16ByteLoop

.16ByteLoop:
	movem.l	d2-d3/a2-a3,-(a1)

.Start16ByteLoop:
	sub.l	d7,d0
	beq		.Done
	bpl		.16ByteLoop

	add.l	d7,d0

.8Byte:
	moveq	#8,d7
	cmp.l	d7,d0
	ble		.4Byte

	move.l	d3,a2
	move.l	d0,d1
	and.b	#7,d1
	bne		.Start8ByteLoop

.8ByteLoop:
	movem.l	d3/a2,-(a1)

.Start8ByteLoop:
	sub.l	d7,d0
	beq		.Done
	bpl		.8ByteLoop

	add.l	d7,d0

.4Byte:
	moveq	#4,d7
	exg		a1,d3
	move.l	d0,d3
	and.b	#3,d3
	exg		a1,d3
	bne		.Start4ByteLoop

.4ByteLoop:
	move.l	d1,(a0)+

.Start4ByteLoop:
	sub.l	d7,d0
	beq		.DoneClrStk4
	bpl		.4ByteLoop
	add.l	d7,d0

	movem.l	(sp)+,d2/d7

.ByteLoop:
	move.b	d1,(a0)+
	subq	#1,d0
	bne		.ByteLoop

.Done:
	rts

.DoneClrStk4:
	movem.l	(sp)+,d2/d7
	rts

; 466

* Put variables and constants here

    ORG    (*+15)&-16
Mem3Start:	dc.b 'M3ST'
Mem3:	dc.b	3,3,3
Mem3End:	dc.b 'M3EN'

    ORG    (*+15)&-16
Mem4Start:	dc.b 'M4ST'
Mem4:	dc.b	4,4,4,4
Mem4End:	dc.b 'M4EN'

    ORG    (*+15)&-16
MemLStart:	dc.b 'MLST'
MemL:	ds.b	1024
MemLEnd:	dc.b 'MLEN'

    END    START        ; last line of source







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
