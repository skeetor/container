*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------

BPL1PTH_OFS EQU $0e0

    ORG    $1000

START:                  ; first instruction of program

    move.l  #$0,d0
    move.l  #$1,d1
    move.l  #$2,d2
    move.l  #$3,d3
    move.l  #$4,d4
    move.l  #$5,d5
    move.l  #$6,d6
    move.l  #$7,d7

    move.l  #$10,a0
    move.l  #$11,a1
    move.l  #$12,a2
    move.l  #$13,a3
    move.l  #$14,a4
    move.l  #$15,a5
    move.l  #$16,a6

    jsr PrintCPU
    
    SIMHALT             ; halt simulator

PrintCPU:
    move.l a7,RegSP
    
    move.l	(a7),-(sp)
    move.l	RegSP,-(sp)
    movem.l d0-d7/a0-a6,-(sp)

    move.l  #$34,d0
    move.l  #$34,a6
    
    move.l	RegSP,a7
	sub.l	#17*4,a7
    movem.l (sp)+,d0-d7/a0-a6
    move.l	RegSP,a7
    rts
    
* Put variables and constants here

    ORG    $10C0
    
RegStack:	ds.l 15
RegSP:	ds.l 1

    END    START        ; last line of source
    
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
