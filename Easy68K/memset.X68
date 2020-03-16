*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
    
ClrMemValue equ 16
ClrMemSize equ 16

START:                  ; first instruction of program

* Put program code here

    ; (14172:14562:4096) (3804:4194:1024) (370:512:16) (332:336:8)
    lea         Clrmem,a0
    move.l      #ClrMemValue,d0
    move.l      #ClrMemSize,d1
    jsr         memset

    ; (90146:4096) (22562:1024) (386:16) (210:8)
    lea         Clrmem,a0
    move.l      #1,d0
    move.l      #ClrMemSize,d1
    jsr         memset1

    ; (19570:4096)(4978:1024)(190:16) (152:8)
    move.l      #8,d0
    move.l      #ClrMemSize,d1
    lea         Clrmem,a0
    jsr         memset8

    ; (13948:4096)(3580:1024)(178:16)
    move.l      #16,d0
    move.l      #ClrMemSize,d1
    lea         Clrmem,a0
    jsr         memset16

    SIMHALT             ; halt simulator

; Returns the input pointer as required by C
memset:
    movem.l     d2/a0,-(sp)

    move.l      a0,d2
    btst        #0,d2
    beq.s       .IsEven

    move.b      d0,(a0)+
    subq        #1,d1
    
.IsEven:
    cmp.l       #8,d1
    bge.s       .Do8
    bra.s       .Do1

.Do8:
    movem.l     d1,-(sp)
    cmp.l       #16,d1
    bge.s       .Do16

    jsr         memset8
    bra.s       .DoRemainder

.Do16:
    movem.l     d3/d4,-(sp)
    jsr         memset16
    movem.l     (sp)+,d3/d4

.DoRemainder:
    ; We want to preserve D1 as it still contains the fillbyte
    ; so we restore this to D2 which is currently
    ; a scratch register
    movem.l    (sp)+,d2

    sub.l       d0,d2
    beq.s       .Done

    move.l      d1,d0
    move.l      d2,d1
    move.l      a1,a0

.Do1:
    bsr.s       memset1

.Done:
    movem.l     (sp)+,d2/a0
    rts

memset16:
    move.l      d1,d4
    lsr.l       #4,d4
    beq.s       .Done

    and.b       #$f0,d1
    add.l       d1,a0
    move.l      a0,a1

    move.b      d0,d1
    lsl.w       #8,d0
    move.b      d1,d0
    move.w      d0,d1
    swap        d0
    move.w      d1,d0
    move.l      d0,d1
    move.l      d0,d2
    move.l      d0,d3

.loop:
    movem.l     d0-d3,-(a0)
    subq        #1,d4
    bne.s       .loop

.Done:
    move.l      a1,d0
    sub.l       a0,d0
    rts

memset8:
    move.l      d1,d2
    lsr.l       #3,d2
    beq.s       .Done

    and.b       #$f8,d1
    add.l       d1,a0
    move.l      a0,a1

    move.b      d0,d1
    lsl.w       #8,d0
    move.b      d1,d0
    move.w      d0,d1
    swap        d0
    move.w      d1,d0
    move.l      d0,d1

.loop:
    movem.l     d0-d1,-(a0)
    subq        #1,d2
    bne.s       .loop
    
.Done:
    move.l      a1,d0
    sub.l       a0,d0
    rts

memset1:
.loop:
    move.b  d0,(a0)+
    subq    #1,d1
    bne.s   .loop
    rts

* Put variables and constants here

    ORG    $2000-4
STARTMarker: dc.b $DE,$AD,$BE,$EF
ClrMem: ds.b ClrMemSize
ENDMarker: dc.b $DE,$AD,$BE,$EF

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
