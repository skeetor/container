*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

	jsr		init

	movem.l	d2-d3/d7,-(sp)
	movem.l	(sp)+,d2-d3/d7
	
	movem.l	d2/d7,-(sp)
	movem.l	(sp)+,d2/d7

	

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

* Put variables and constants here

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
