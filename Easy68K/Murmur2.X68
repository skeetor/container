*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
   
MURMUR_M EQU $05bd1e995
MURMUR_R EQU 24

;   #define mmix(h, k)
;	k *= m;
;	k ^= k >> r;
;	k *= m;
;	h *= m;
;	h ^= k;

START:                  ; first instruction of program

    move.l  #$a3f89ab0,d0       ; random seed
    move.l  #$4,d1              ; length of buffer
    lea     Buffer,a0           ; pointer to buffer
    jsr     Murmur2Hash

    SIMHALT             ; halt simulator

Murmur2Hash:
    movem.l d2-d3,-(sp)

.Loop:
	cmp.l	#$4,d1
	blt.s	.Remainder

    move.l  (a0)+,d2
    subq.l  #4,d1
    beq.s   .Done

    bra.s   .Loop

.Remainder:
    moveq.l #0,d2
    move.l  d2,d3

    move.b  (a1)+,d2
    subq.l  #1,d1
    beq.s   .Finalize

    move.b  (a1)+,d3
    asl.w   #8,d3
    add.w   d3,d2
    subq.l  #1,d1
    beq.s   .Finalize

    sub.w   d3,d3
    move.b  (a1)+,d3
    asl.w   #16,d3
    add.l   d3,d2

.Finalize:

.Done:
    movem.l (sp)+,d2-d3

    rts
    
mult32u:
	move.l	d2,-(sp)

	move.l	d0,-(sp)	; a
	mulu.w	d1,d0		; d0=al*bl
	move.l	d1,d2		; b
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
    ORG    $1100

Buffer: dc.b '1234'

    END    START        ; last line of source



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
