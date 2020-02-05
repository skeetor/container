*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

    moveq.l #-1,d0
    clr.l   d1
    subq.w  #1,d1    
    and.l   d1,d0

    move.l  #$abababab,d1
    move.l  d1,d2
    move.l  d1,d3
    move.l  d1,d4
    move.l  d1,d5
    move.l  d1,d6
    move.l  d1,d7

    ;lea DecimalStringGood1,a0       ; 19345:4b91
    ;lea DecimalStringGood2,a0      ; 65535:ffff
    ;lea DecimalStringGood3,a0      ; 00000000000000000019345:4b91
    ;lea DecimalStringGood4,a0      ; 65536:10000
    ;lea DecimalStringGood5,a0      ; 4294967295:ffffffff
    lea DecimalStringGood6,a0      ; 9999:270f
    ;lea DecimalStringEmpty,a0      ; 0,0
    ;lea     DecimalStringBad1,a0   ; 123456:-1,-1
    ;lea     DecimalStringBad2,a0   ; 65536:-1,-1
    ;lea     DecimalStringBad3,a0   ; $2f,100123456,0,0
    moveq   #4,d0
    jsr     fromDecimalU32

    SIMHALT                 ; halt simulator

fromDecimalU32:
	movem.l	d3/d4/d5,-(sp)

	and.l	#$ffff,d0

    move.l  #429496729,d3	; cutoff
    moveq.l  #5,d4			; cutoff limit

    exg     a0,d2			; null pointer
    tst.l   d2
    bne.s   .DoConversion

    exg     a0,d2
    moveq.l   #-1,d0

.ShortDone:
    move.l  d0,d1
    movem.l (sp)+,d3/d4/d5
    rts

.DoConversion:
    exg     a0,d2

    clr.l   d5
    tst.w   d0				; Zero length 0:0
    beq.s   .ShortDone

    movem.l d2,-(sp)

    move.l  d5,d2
    move.l  d0,d5
    move.l  a0,a1
    add.l   d5,a1
    move.l  a0,d5
    moveq   #0,d0

    bra.s   .Start

.loop:
    move.b  (a0)+,d2
    beq.s   .Done    

    sub.b   #'0',d2
    cmp.b   #9,d2
    bhi.s   .Done

    cmp.l   d3,d0           ; cutoff reached?
    blt.s   .Ok             ; Overflow
    bgt.s   .Error
    
    cmp.b   d4,d2           ; cutofflimit exceeded?
    bgt.s   .Error          ; Overflow

.Ok:
	moveq.l	#10,d1
    jsr		mul32u
    add.l   d2,d0

.Start:
    cmp.l   a0,a1
    bgt.s   .loop

    add.l   #1,a0
    
.Done:
    exg     a0,d5
    sub.l   a0,d5
    sub.l   #1,d5
    move.l  d5,d1

.Exit:
    movem.l (sp)+,d2/d3/d4/d5
    rts

.Error:
    moveq.l	#-1,d0
    move.l	d0,d1
    bra.s   .Exit

fromDecimalU16:
	movem.l	d3/d4,-(sp)

    ; Cutoff*10 + limit is the maximum that an U16 can hold. If the next char is higher
    ; than 5 the result would overflow.
    move.w  #6553,d3		; cutoff
    moveq   #5,d4			; cutoff limit

convertFromDecimal:
    exg     a0,d2			; null pointer
    tst.l   d2
    bne.s   .DoConversion

    exg     a0,d2
    moveq   #-1,d0

.ShortDone:
    move.w  d0,d1
    movem.l (sp)+,d3/d4
    rts

.DoConversion:
    exg     a0,d2

    clr.l   d1
    tst.w   d0				; Zero length 0:0
    beq.s   .ShortDone

    movem.l d2,-(sp)

    move.w  d1,d2
    move.w  d0,d1
    move.l  a0,a1
    add.l   d1,a1
    move.l  a0,d1
    moveq   #0,d0

    bra.s   .Start
    
.loop:
    move.b  (a0)+,d2
    beq.s   .Done    

    sub.b   #'0',d2
    cmp.b   #9,d2
    bhi.s   .Done

    cmp.w   d3,d0           ; cutoff reached?
    blt.s   .Ok             ; Overflow
    bgt.s   .Error
    
    cmp.b   d4,d2           ; cutofflimit exceeded?
    bgt.s   .Error          ; Overflow

.Ok:
    mulu.w  #10,d0
    add.w   d2,d0

.Start:
    cmp.l   a0,a1
    bgt.s   .loop

    add.l   #1,a0
    
.Done:
    exg     a0,d1
    sub.l   a0,d1
    sub.l   #1,d1

.Exit:
    movem.l (sp)+,d2/d3/d4
    rts

.Error:
    moveq   #-1,d0
    move.w  d0,d1
    bra.s   .Exit

mul32u:
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

DecimalStringEmpty: dc.b 0
DecimalStringGood1: dc.b '19345',0
DecimalStringGood2: dc.b '65535',0
DecimalStringGood3: dc.b '00000000000000000019345',0
DecimalStringGood4: dc.b '65536',0
DecimalStringGood5: dc.b '4294967295',0
DecimalStringGood6: dc.b '9999',0
DecimalStringBad1: dc.b '123456',0
DecimalStringBad2: dc.b '65536',0
DecimalStringBad3: dc.b $2f,'100123456',0

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~


