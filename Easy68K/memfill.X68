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

	lea		MemL,a0
	;add.l	#1,a0
	move.l	#1024,d2			; Length
	move.l	#$33,d1			; Fillbyte
	jsr		memfill

    SIMHALT             ; halt simulator

memfill:
	move.l	d2,a1
	tst.l	d2
	beq		.Done

	moveq	#3,d2
	cmp.l	d2,a1
	ble		.ByteLoop

	move.l	a0,d0
	btst	#0,d0
	beq		.Even

	move.b	d1,(a0)+
	subq	#1,a1

.Even:
	move.l	a1,d0
	tst.l	d0
	beq		.Done

	moveq	#4,d7
	cmp.l	d7,d0
	ble		.ByteLoop

	; Extend the fillbyte so we can use it also in DWORD
	; operations.
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
	move.l	d2,a2
	btst	#0,d2
	beq		.EvenBig

	moveq	#1,d7
	sub.l	d7,d0
	move.b	d1,-(a2)

.EvenBig:
	cmp.w	#32,d0
	ble		.16Byte

	moveq	#32,d7
	move.l	d1,a3
	move.l	d1,a4
	move.l	d1,a5
	move.l	d1,d3
	move.l	d1,d4
	move.l	d1,d5
	move.l	d1,d6

.32ByteLoop:
	movem.l	d1/d3-d6/a3-a5,-(a2)

.Start32ByteLoop:
	sub.l	d7,d0
	beq		.Done
	bpl		.32ByteLoop

	add.l	d7,d0

.16Byte:
	cmp.w	#16,d0
	ble		.8ByteFill

.16ByteFill:
	moveq	#16,d7
	move.l	d1,a3
	move.l	d1,d3
	move.l	d1,d4
	move.l	d0,d6
	and.b	#16,d6
	bne		.Start16ByteLoop

.16ByteLoop:
	movem.l	d1/d3/d4/a3,-(a2)

.Start16ByteLoop:
	sub.l	d7,d0
	beq		.Done
	bpl		.16ByteLoop

	add.l	d7,d0

.8ByteFill:
	moveq	#8,d7
	move.l	d1,a3
	move.l	d0,d3
	and.b	#8,d3
	bne		.Start8ByteLoop

.8ByteLoop:
	movem.l	d1/a3,-(a2)

.Start8ByteLoop:
	sub.l	d7,d0
	beq		.Done
	bpl		.8ByteLoop

	add.l	d7,d0

.4Byte:
	; We subtract one item, so that extra bytes at the end
	; don't spill over.
	; i.E. If we have to copy 5 bytes and we wouldn't subtract
	; this, the loop would copy 8 bytes, while it should copy 4 + 1.
	moveq	#4,d7
	move.l	d0,d3
	and.b	#3,d3
	bne		.Start4ByteLoop
	
.4ByteLoop:
	move.l	d1,(a0)+

.Start4ByteLoop:
	sub.l	d7,d0
	beq		.Done
	bpl		.4ByteLoop
	add.l	d7,d0
	
.ByteLoop:
	move.b	d1,(a0)+
	subq	#1,d0
	bne		.ByteLoop

.Done:
	rts

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
