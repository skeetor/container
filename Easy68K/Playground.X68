*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
   
START:                  ; first instruction of program

    move.l      #5,d0
    move.l      d0,d1
    asl.l       #7,d0
    asl.l       #5,d0
    moveq       #12,d2
    asl.w       d2,d1

    SIMHALT             ; halt simulator

    END    START        ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
