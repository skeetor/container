*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000


START:                  ; first instruction of program

    jsr     rnd
    jsr     rnd
    jsr     rnd

    SIMHALT             ; halt simulator

rnd:
    lea     .rndSeed(pc),a0
    move.l  (a0),d0
	move.l  4(a0),d1
	swap	d1
	add.l	d0,d1
	eor.l	d0,d1
	move.l  d0,4(a0)
	move.l  d1,(a0)
	move.l  d1,d0
	rts

.rndSeed: dc.l  $cd2ef3b7    
.rndValue: dc.l $6be7d35b

* Put variables and constants here
    ORG    $1100

    END    START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
