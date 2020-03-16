*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

    move.l      a7,a5

    pea         $16be
    pea         1
    
    ;pea         $100
    ;pea         $10
    jsr         mulsi3
    ;jsr         Mymulsi3
    move.l      a5,a7

    
    SIMHALT             ; halt simulator

;296
mulsi3:
    movem.l     4(sp),d0-d1
    move.l      d3,-(sp)
    move.l      d2,-(sp)

    move.w      d1,d2
    mulu.w      d0,d2
    move.l      d1,d3
    swap        d3
    mulu.w      d0,d3
    swap        d3
    clr.w       d3
    add.l       d3,d2
    swap        d0
    mulu.w      d1,d0
    swap        d0
    add.l       d2,d0

    move.l      (sp)+,d2
    move.l      (sp)+,d3
    rts


;274 cycles
Mymulsi3:
    movem.l     4(sp),d0-d1

mult32u:
	move.l	d2,-(sp)

	move.l	d0,-(sp)	; a
	move.l	d1,d2		; b
	mulu.w	d1,d0		; d0=al*bl
	mulu.w	(sp)+,d1	; d1=ah*bl
	swap	d2			; d2=bh
	mulu.w	(sp)+,d2	; d2=al*bh
	add.w	d2,d1
	swap	d1
	move.l	(sp)+,d2
	clr.w	d1
	add.l	d1,d0

	rts

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
