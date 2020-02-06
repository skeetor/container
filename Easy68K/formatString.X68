*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------

    ORG    $1000

START:                  ; first instruction of program

    jsr     clearRegisters
    jmp     StartHere

    ORG    $1010
Outbuffer: ds.b 1024
    
* Put program code here

StartHere:
    ;lea     String_01,a1    ; 'Test'
    lea     String_02,a1    ; 'Tst\n\r\tTest\\Value'

    ;lea     String_03,a1    ; '%b'
    ;move.l  #$12345678,-(sp)

    lea     Outbuffer,a0
    move.l  #1028,d0
    jsr     formatString

    SIMHALT             ; halt simulator

SAVE_CHAR   MACRO
    cmp.l   a3,a4
    ble.s   .addCount\@

    move.b  \1,(a3)+

.addCount\@:
    addq    #1,d7

    ENDM

STR_CONTROL_MODE	equ 	31
STR_FORMAT_MODE		equ		30
STR_ZERO_FILL		equ		29
STR_ALIGN_RIGHT		equ		28
STR_PARAM_32		equ		27
STR_SIGNED			equ		26

formatString:

    moveq   #0,d1
    cmp.l   d1,a1
    bne.s   .FormatOk

    moveq   #-1,d0
    rts

.FormatOK:
    movem.l d2-d7/a2-a5,-(sp)
    lea     44(a7),a5   ; Argument base pointer

    movem.l a0,-(sp)    ; Remember original outputbuffer for the final 0-byte

	moveq	#0,d7       ; Charcount
	moveq	#0,d6       ; Mode+char
	moveq	#0,d5       ; fieldWidth

	move.l	a0,a3       ; Outputbuffer
	move.l	a0,a4
    cmp.l   d5,a3
    beq.s   .Null       ; In case of a nullptr both should be the same

	add.l	d0,a4       ; End of outputbuffer

.Null:
	move.l	a1,a2       ; FormatString
	bra.w	.NextChar

.loop:

; ******************************************************
; Control mode
	btst	#STR_CONTROL_MODE,d6
	beq.s	.CheckFormatMode

.TabChar:
    cmp.b   #'t',d6
    bne.s   .NewlineChar

    moveq   #0,d6           ; Clear mode
    move.b  #$09,d6
    bra.w   .StoreChar

.NewlineChar:
    cmp.b   #'n',d6
    bne.s   .ReturnChar

    moveq   #0,d6           ; Clear mode
    move.b  #$0d,d6
    bra.w   .StoreChar

.ReturnChar:
    cmp.b   #'r',d6
    bne.w   .StoreChar      ; Unknown character gets just stored as is.

    moveq   #0,d6           ; Clear mode
    move.b  #$0a,d6
    bra.w   .StoreChar

; ******************************************************
; Format mode
.CheckFormatMode:
	btst	#STR_FORMAT_MODE,d6
	beq.w	.DoChar

    cmp.b   #'l',d6
    bne.s   .CheckNumber

    bset    #STR_PARAM_32,d6
    bra.w   .NextChar

.CheckNumber:
    cmp.b   #'9',d6
    bhi.s   .CheckAlign

    cmp.b   #'0',d6
    blt.s   .CheckAlign
    bne.s   .fieldWidth

    bset    #STR_ZERO_FILL,d6

.FieldWidth:
    subq    #1,a2           ; Readjust number pointer to grab the first char as well
    moveq   #0,d6
    ;jsr     stringToUWord
    bra.w   .NextChar

.CheckAlign:
    cmp.b   #'-',d6
    bne.s   .CheckNumber

    bset    #STR_ALIGN_RIGHT,d6
    bra.w   .NextChar

.CheckString:
    cmp.b   #'s',d6
    bne.s   .UnsignedDecimal

    ; jsr strcpy
    moveq   #0,d6
    bra.w   .NextChar

.UnsignedDecimal:
    cmp.b   #'u',d6
    bne.s   .SignedDecimal

    ; jsr toDec
    moveq   #0,d6
    bra.w   .NextChar

.SignedDecimal:
    cmp.b   #'d',d6
    bne.s   .HexUpper

    ; jsr toDec
    moveq   #0,d6
    bra.w   .NextChar

.HexUpper:
    cmp.b   #'X',d6
    beq.s   .ToHex
    cmp.b   #'x',d6
    beq.s   .ToHex
    cmp.b   #'p',d6
    bne.s   .Binary

    SAVE_CHAR #'0'
    SAVE_CHAR #'x'

.ToHex:
    ; jsr toHex
    moveq   #0,d6
    bra.w   .NextChar

.Binary:
    cmp.b   #'b',d6
    bne.s   .SingleChar

    ; jsr toBinary
    moveq   #0,d6
    bra.s   .NextChar

.SingleChar:
    cmp.b   #'b',d6
    bne.s   .NumberParam

    move.l  (a5)+,d0
    moveq   #0,d6
    move.b  d0,d6
    bra.s   .StoreChar

.NumberParam:
    cmp.b   #'*',d6
    bne.s   .ReportSize

    move.l  (a5)+,d5
    bra.s   .NextChar

.ReportSize:
    cmp.b   #'n',d6
    bne.s   .Float

    moveq   #0,d6
    move.l  (a5)+,d0
    beq.s   .NextChar           ; Ignore if nullptr

    move.l  d0,a0
    move.l  d7,(a0)
    bra.s   .NextChar

.Float:
    cmp.b   #'e',d6
    beq.s   .INFText
    cmp.b   #'f',d6

    moveq   #0,d6
    bra.s   .StoreChar

.INFText:
    moveq   #0,d6
	SAVE_CHAR #'I'
	SAVE_CHAR #'N'
	SAVE_CHAR #'F'
    bra.s   .StoreChar  

; ******************************************************
; Unknown characters
.DoChar:
    cmp.b   #'%',d6
    bne.s   .CheckBackSlash

    bset    #STR_FORMAT_MODE,d6
    bra.s   .NextChar

.CheckBackSlash:
    cmp.b   #'\',d6
    bne.s   .StoreChar

    bset    #STR_CONTROL_MODE,d6
    bra.s   .NextChar

.StoreChar:
	SAVE_CHAR   d6

.NextChar:
	move.b	(a2)+,d6
	bne.w  	.Loop

    movem.l (sp)+,d0            ; Outputbuffer

    ; If outputbuffer was a nullptr we can't store the 0-byte ...
    tst.l   d0
    beq.s   .Done

    ; ... and also not if the buffersize was 0
    cmp.l   d0,a4
    beq.s   .Done
    
    cmp.l   a3,a4
    bgt.s   .storeZero

    subq    #1,a3

.storeZero:
    move.b  #0,(a3)+

.Done:
    move.l  d7,d0
    movem.l (sp)+,d2-d7/a2-a5

	rts

    include string_number.i

* Put variables and constants here
    
    ORG    (*+19)&-16
ENDLABEL: dc.b '****** END *****'

String_01: dc.b 'Test',0
String_02: dc.b 'Tst\n\r\tTest\\Value',0
String_03: dc.b '%b',0

    END    START        ; last line of source
    


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
