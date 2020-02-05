*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

    move.l  #8,d0
    move.l  d0,a0
    lea     -4(a0),a1
    sub.l   #4,a0
    move.l  a0,a2


    lea     List,a0
    lea     Target,a1
    jsr     zcopyl

    lea     Clear,a0
    lea     Target,a1
    moveq   #4,d0
    jsr     CounterCopy

    lea     List,a0
    lea     Target,a1
    jsr     ZeroCheckCopy

    SIMHALT             ; halt simulator

zcopyl:
    moveq #-1,d0

.Loop:
    move.l  (a0)+,(a1)+
    dbeq    d0,.Loop

    rts

ZeroCheckCopy:
.Loop:
    move.l  (a0)+,d0
    beq.s   .Done
    move.l  d0,(a1)+
    bra.s   .Loop

.Done
    rts

CounterCopy:
    tst.l   d0
    beq.s   .Done    

.Loop:
    move.l  (a0)+,(a1)+
    subq.l    #1,d0
    bne     .Loop

.Done:
    rts

* Put variables and constants here

    org $1100

Clear:
    dc.l $ABABABAB
    dc.l $ABABABAB
    dc.l $ABABABAB
    dc.l $ABABABAB

List:
    dc.l 1
    dc.l 2
    dc.l 3
    dc.l 4

    dc.l 0
    dc.l $cccccccc
    dc.l $cccccccc
    dc.l $cccccccc


Target:
    dc.l $ABABABAB
    dc.l $ABABABAB
    dc.l $ABABABAB
    dc.l $ABABABAB
    dc.l $ABABABAB
    dc.l $ABABABAB


    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
