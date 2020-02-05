*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

a:
    moveq.l #-1,d0
    move.l  #$abababab,d1
    move.l  d1,d2
    move.l  d1,d3
    move.l  d1,d4
    move.l  d1,d5
    move.l  d1,d6
    move.l  d1,d7

    ;lea DecimalStringGood1,a0      ; 19345:4b91
    ;lea DecimalStringGood1_2,a0    ; 19345:4b91
    ;lea DecimalStringGood2,a0      ; -32768:8000
    ;lea DecimalStringGood2_2,a0    ; 32767:7fff
    ;lea DecimalStringGood3,a0      ; 00000000000000000019345:4b91
    ;lea DecimalStringGood4,a0      ; 65536:10000
    ;lea DecimalStringGood5,a0      ; -2147483648:80000000
    ;lea DecimalStringGood5,a0      ; 2147483647:80000000
    ;lea DecimalStringGood7,a0      ; 9999:270f
    ;lea DecimalStringEmpty,a0      ; 0,0
    lea DecimalString8,a0           ; '3214748364',0-BF9D2ACC
    ;lea     DecimalStringBad1,a0   ; 123456:-1,-1
    ;lea     DecimalStringBad2,a0   ; 65536:-1,-1
    ;lea     DecimalStringBad3,a0   ; $2f,100123456,0,0
    ;lea     DecimalStringBad4,a0   ; +,0,0
    move.w   #-1,d0
    ;jsr     fromDecimalS32
    jsr     fromDecimalU32
    ;jsr     fromDecimalS16

    SIMHALT                 ; halt simulator

fromDecimalS32:
    lea     .S32Limits,a1
    bra.s   convertFromDecSigned

.S32Limits:
	; For S32 we need to adjust the stack, because it
	; expects also the D5 register to be pushed
	movem.l	(sp)+,a1		; get return address of caller
	movem.l d5,-(sp)
	movem.l a1,-(sp)

    move.l  #214748364,d3	; cutoff
    moveq   #7,d4			; cutoff limit
    lea     convertFromDecU32,a1
    rts

; ############################################
convertFromDecSigned:
	moveq	#0,d1
    cmp.l   d1,a0			; null pointer
    bne.s   .CheckLength

    moveq   #-1,d0
	move.l	d0,d1
    rts

.CheckLength:
    tst.w   d0				; Zero length 0:0
    bne.s   .CheckSign

    moveq   #0,d0
	move.l	d0,d1
    rts

.CheckSign:
    movem.l d2,-(sp)

    move.l #.RetCall,-(sp)

    moveq   #0,d2
    cmp.b   #'-',(a0)
    bne.s   .DoConvert

    moveq   #1,d2
    add.l   d2,a0
    
.DoConvert:
	movem.l	d3/d4,-(sp)

    jsr (a1)
    add.l   d2,d4

    ; Stack will be cleaned by callee
    jmp (a1)

.RetCall:
    tst.b   d2
    beq.s   .Done

    neg.w   d0
    add.w   d2,d1
    
.Done:
    movem.l (sp)+,d2
    rts

; ############################################
fromDecimalU32:
	movem.l	d3/d4/d5,-(sp)

    move.l  #429496729,d3	; cutoff
    moveq.l  #5,d4			; cutoff limit

	moveq.l	#0,d5
    move.l  a0,d5			; null pointer
    tst.l   d5
    bne.s   convertFromDecU32

    moveq.l   #-1,d0

U32ShortDone:
    move.l  d0,d1
    movem.l (sp)+,d3/d4/d5
    rts

convertFromDecU32:
	and.l	#$ffff,d0
    tst.w   d0				; Zero length 0:0
    beq.s   U32ShortDone

    movem.l d2,-(sp)

    move.l  a0,a1
    add.l   d0,a1
    move.l  a0,d5
    moveq   #0,d0
    move.l  d0,d2

    cmp.l   a0,a1
    ble.s   .Done

    move.b  (a0)+,d2
    beq.s   .Done    

	cmp.b	#'+',d2
	beq.s	.Start
    bra.s   .FirstChar

.loop:
    move.b  (a0)+,d2
    beq.s   .Done    

.FirstChar:
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

; ##############################################
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
DecimalStringGood1_2: dc.b '+19345',0
DecimalStringGood2: dc.b '-32768',0
DecimalStringGood2_2: dc.b '32767',0
DecimalStringGood3: dc.b '00000000000000000019345',0
DecimalStringGood4: dc.b '65536',0
DecimalStringGood5: dc.b '-2147483648',0
DecimalStringGood6: dc.b '2147483647',0
DecimalStringGood7: dc.b '9999',0
DecimalString8: dc.b '3214748364',0
DecimalStringBad1: dc.b '123456',0
DecimalStringBad2: dc.b '65536',0
DecimalStringBad3: dc.b $2f,'100123456',0
DecimalStringBad4: dc.b '+',0

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
