*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

    move.l  #$ffff,d0
    move.l  #$10001,d1
    jsr     mult32u
    
    SIMHALT             ; halt simulator

;272 cycles
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
