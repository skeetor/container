*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

    jsr     clearRegisters
    
    ;lea     Number_01,a0       ; ''
    ;lea     Number_02,a0       ; '0'
    ;lea     Number_03,a0       ; '15'
    ;lea     Number_05,a0       ; 'a3f',0
    ;lea     Number_06,a0       ; '65535'
    ;lea     Number_07,a0       ; '1111111111111111' - Base2/2840/2374
    ;lea     Number_08,a0       ; '1VVV',65535
    ;lea     Number_09,a0        ; 'FFFF',0 - Base16/942/856
    ;lea     Number_10,a0        ; '33333333',0 ; Base4
    ;lea     Number_11,a0        ; '177777',0 ; Base8
    ;lea     Number_12,a0        ; '32767',0
    lea     Number_13,a0        ; '-32768',0

    move.w  #10,d0
    move.w  #-1,d1
    jsr     stringToSWord
    ;jsr     stringToUWord

    SIMHALT             ; halt simulator

; ##########################################
stringToSWord:

    moveq   #0,d2
    cmp.l   a0,d2
    beq.w   scError         ; nullptr

    move.w  d1,d2
	beq.w	scError          ; Buffersize is 0
    
    move.l  a0,a1
    add.l   d2,a1

    moveq   #1,d5
    move.b  (a0)+,d2
    cmp.b   #'+',d2
    beq.s   .stringToWord

    cmp.b   #'-',d2
    beq.s   .Negativ

    ; Character is unknown so it
    ; should be checked by the conversion
    subq    #1,a0
    bra.s   .stringToWord

.Negativ:
    moveq   #0,d5

.stringToWord:
    moveq   #0,d4
    move.l  #$8000,d3

    jsr     stringToWord

    tst.w   d5
    bne.s   .Done

    neg.w   d0

.Done:
    rts

stringToUWord:

    moveq   #0,d2
    cmp.l   a0,d2
    beq.w   scError         ; nullptr

    move.w  d1,d2
	beq.w	scError          ; Buffersize is 0
    
    move.l  a0,a1
    add.l   d2,a1

    move.b  (a0)+,d1
    cmp.b   #'+',d1
    beq.s   .ToWord

    subq    #1,a0

.ToWord:
    moveq   #0,d5
    moveq   #0,d4
    moveq   #0,d3
    subq.w  #1,d3

; ##########################################
; D0.W: Base
; D3.L: Cutoff
; D4.B: Limit
; D5.w: 1 if positive, 0 if negative
; A0.L: Stringstart
; A1.L: End of Stringbuffer
stringToWord:
    move.w  d0,d2
    cmp.w   #2,d0
    blt.w   scError
    bne.s   .NotBase2

    moveq   #1,d3
    moveq   #16,d4
    jmp     stringToNumber

.NotBase2:
    cmp.w   #16,d0
    bne.s   .NotBase16

    moveq   #4,d3
    moveq   #4,d4
    jmp     stringToNumber

.NotBase16:
    cmp.w   #8,d0
    bne.s   .NotBase8

    moveq   #3,d3
    moveq   #6,d4
    jmp     stringToNumber

.NotBase8:
    cmp.w   #4,d0
    bne.s   .NotBase4

    moveq   #2,d3
    moveq   #8,d4
    jmp     stringToNumber

.NotBase4:
    cmp.w   #32,d0
    bne.s   .NotBase32

    moveq   #5,d3
    moveq   #4,d4
    jmp     stringToNumber

.NotBase32:
    cmp.w   #62,d0
    bhi.w   scError

.CalcLimit:
    ; Calculate numeric limit and cutoff
    ; This is done by using $ffff as a start
    ; as this is the highest number a word can hold.
    ; If the modulo is zero, then $ffff is multiple
    ; of the base. If not, then the calculated number
    ; plus the modulo, is the highest value that can
    ; be held without overflowing. 
    move.l  d3,d1
    divu    d0,d1
    swap    d1
    move.w  d1,d4   ; limit
    beq.s   .Start

    sub.w   d5,d4
    swap    d1
    move.w  d1,d3   ; cutoff

.Start:
    moveq   #0,d0
    move.l  d0,d1

.DoConvert:
    cmp.l   a0,a1
    ble.s   .Exit           ; Here we are really done, because we
                            ; may not read beyond the buffer length

    ; From here we alread read the next char, so if it leads
    ; to an error, we have to roll back the pointer so the
    ; caller can decide if this is an error or not.
    move.b  (a0)+,d1
    beq.s   .Done

    cmp.b   #'9',d1
    bhi.s   .Upper

    cmp.b   #'0',d1
    blt.s   .EndOfNumber

    sub.b   #'0',d1
    bra.s   .CheckLimits

.Upper:
    cmp.b   #'Z',d1
    bhi.s   .Lower

    cmp.b   #'A',d1
    blt.s   .EndOfNumber

    sub.b   #'A'-10,d1
    bra.s   .CheckLimits

.Lower:
    cmp.b   #'z',d1
    blt.s   .EndOfNumber

    cmp.b   #'a',d1
    blt.s   .EndOfNumber

    sub.b   #'a'-36,d1

.CheckLimits:
    cmp.b   d1,d2
    ble.s   .EndOfNumber   ; Character not allowed for this base

    cmp.l   d0,d3           ; Cutoff reached?
    bhi.s   .Valid
    blt.s   .Overflow

    ; Cutoff reached, so we check 
    ; if the number is within the limit
    cmp.b   d1,d4           ; Limit reached
    blt.s   .Overflow

.Valid:
    mulu    d2,d0
    add.l   d1,d0

    bra.s   .DoConvert

.Done:
    subq    #1,a0

.Exit:
    moveq   #0,d1
    rts

.Overflow:
    subq    #1,a0
    moveq   #1,d1
    rts

.EndOfNumber:
    subq    #1,a0
    moveq   #2,d1
    rts

scError:
    moveq   #-1,d0
    moveq   #3,d1
    rts

; ##########################################
; Convert a power of base 2 string to a word.
; This function does not check parameters, but
; is faster then using the generic conversion
;
; A0: start of string
; A1: End of string
; D2.L: Base
; D3.L: Bits to shift
; D4.B: Number of shifts

stringToNumber:
    moveq   #0,d0
    moveq   #0,d1
    addq    #1,d4

.DoConvert:
    cmp.l   a0,a1
    ble.s   .Exit           ; Here we are really done, because we
                            ; may not read beyond the buffer length

    move.b  (a0)+,d1
    beq.s   .Exit

    cmp.b   #'9',d1
    bhi.s   .Upper

    cmp.b   #'0',d1
    blt.s   .EndOfNumber

    sub.b   #'0',d1
    bra.s   .CheckLimits

.Upper:
    cmp.b   #'Z',d1
    bhi.s   .Lower

    cmp.b   #'A',d1
    blt.s   .EndOfNumber

    sub.b   #'A'-10,d1
    bra.s   .CheckLimits

.Lower:
    cmp.b   #'z',d1
    blt.s   .EndOfNumber

    cmp.b   #'a',d1
    blt.s   .EndOfNumber

    sub.b   #'a'-36,d1

.CheckLimits:
    cmp.b   d1,d2
    ble.s   .EndOfNumber    ; Character not allowed for this base
    
.Valid:
    ; We check this here, so we can detect a possible overflow
    subq.w  #1,d4
    beq.s   .Overflow

    lsl.l   d3,d0
    add.l   d1,d0
    bra.s   .DoConvert
    
.Exit:
    moveq   #0,d1
    rts

.Overflow:
    subq    #1,a0
    moveq   #1,d1
    rts

.EndOfNumber:
    subq    #1,a0
    moveq   #2,d1
    rts

.Error:
    moveq   #-1,d0
    moveq   #3,d1
    rts

; ##########################################
clearRegisters:
    move.l  #$abababab,d0
    move.l  d0,d1
    move.l  d0,d2
    move.l  d0,d3
    move.l  d0,d4
    move.l  d0,d5
    move.l  d0,d6
    move.l  d0,d7

    move.l  d0,a0
    move.l  d0,a1
    move.l  d0,a2
    move.l  d0,a3
    move.l  d0,a4
    move.l  d0,a5
    move.l  d0,a6
    
    rts


* Put variables and constants here

    ORG    (*+19)&-16
ENDLABEL: dc.b '****** END *****'

Number_01: dc.b  '',0
Number_02: dc.b  '0',0
Number_03: dc.b  '15',0
Number_04: dc.b  'A3F',0
Number_05: dc.b  'a3f',0
Number_06: dc.b  '65535',0
Number_07: dc.b  '1111111111111111',0
Number_08: dc.b  '1VVV',0
Number_09: dc.b  'FFFF',0
Number_10: dc.b  '33333333',0 ; Base4
Number_11: dc.b  '177777',0 ; Base 8
Number_12: dc.b  '32767',0
Number_13: dc.b  '-32768',0

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
