*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------

; Interleave : 5 Planes
; 11111111   Line 1 Plane 1
; 12121212   Line 1 Plane 2
; 13131313   Line 1 Plane 3
; 14131314   Line 1 Plane 4
; 15151515   Line 1 Plane 5
; 21212121   Line 2 Plane 1
; 22222222   Line 2 Plane 2
; 23232323   Line 2 Plane 3
; 24242424   Line 2 Plane 4
; 25252525   Line 2 Plane 5

; Standard : 5 Planes
; 11111111   Line 1 Plane 1
; 21212121   Line 2 Plane 1
; 12121212   Line 1 Plane 2
; 22222222   Line 2 Plane 2
; 13131313   Line 1 Plane 3
; 23232323   Line 2 Plane 3
; 14131314   Line 1 Plane 4
; 24242424   Line 2 Plane 4
; 15151515   Line 1 Plane 5
; 25252525   Line 2 Plane 5

BIF_FL_NONE     	EQU 0
BIF_BT_INTERLEAVE	EQU	1
BIF_FL_INTERLEAVE	EQU (1<<1)


DISPLAY_WIDTH		EQU	320
DISPLAY_HEIGHT		EQU	256
BITMAP_PLANES		EQU	5

IMAGE_WIDTH     	EQU 189
IMAGE_HEIGHT    	EQU 200

IMAGE_VALUE			EQU IMAGE_WIDTH/16

	IFNE (IMAGE_WIDTH-(IMAGE_VALUE*16))
IMAGE_WORDS			EQU IMAGE_VALUE+1
	ENDC

	IFEQ (IMAGE_WIDTH-(IMAGE_VALUE*16))
IMAGE_WORDS			EQU IMAGE_VALUE
	ENDC

BMI_Width		    EQU	0	; WORD
BMI_Height  	    EQU	2	; WORD
BMI_Planes			EQU	4	; WORD
BMI_Flags			EQU	6	; WORD
BMI_Frames			EQU	8	; WORD
BMI_Bitplane	    EQU	10	; WORD
BMI_BytesPerRow		EQU	14	; WORD
BMI_LineDistance	EQU	16	; WORD
BMI_PlaneDistance	EQU 20	; WORD
BMI_NextLine		EQU	24	; DWORD
BMI_NextPlane		EQU 28	; DWORD
BitmapInfo          EQU 32
	
BL_CurSourceLine	EQU	0
BL_CurTargetLine	EQU	BL_CurSourceLine+4
BitmapBlit			EQU	BL_CurTargetLine+4


    ORG    $1000
    
START:                  ; first instruction of program

	move.l	#101,d0
	move.l	#32,d1
	
	mulu	#100,d0
	mulu	#100,d1
	divu	d1,d0
	
.start:
	jsr		FillStandardPatterns

	jsr     Setup
	jsr     Init

	move.w  #0,d2               ; x
	move.w  #256,d3               ; y
	lea     ImageBitmap,a2		; Source
	lea     DisplayBitmap,a3	; Target
	
.WaitClick:
	move.w	d2,d0
	move.w	d3,d1
	jsr		BlitCPU
	tst.l	d0
	bne		.NextLine
	moveq	#-1,d3

.NextLine:
	add.w	#1,d3

	cmp.l 	#$deadbeef, DisplayEnd
	beq		.WaitClick

    SIMHALT             ; halt simulator

Setup:
	moveq.l #-1,d0
	move.l  d0,d1
	move.l  d0,d2
	move.l  d0,d3
	move.l  d0,d4
	move.l  d0,d5
	move.l  d0,d6
	move.l  d0,d7

	rts

FillStandardPatterns:
	; D2 = LLWP
	lea		Source,a0
	move.w	#$1,d2
	move.w	#BITMAP_PLANES,d3
	move.w	#IMAGE_WORDS,d4
	move.w	#IMAGE_HEIGHT,d5
	jsr		FillStandardPattern

	lea		Target,a0
	move.w	#$A,d2
	move.w	#BITMAP_PLANES,d3
	move.w	#DISPLAY_WIDTH/16,d4
	move.w	#DISPLAY_HEIGHT,d5

FillStandardPattern:
	move.w	d4,d0
	move.w	d5,d1

.LineLoop:
	move.w	d2,(a0)+
	add.w	#$10,d2		; Width
	sub.w	#1,d0
	bne		.LineLoop

.NextLine:
	sub.w	#$10,d2
	and.w	#$ff0f,d2	; Clear width, leave plane and line intact.
	add.w	#$100,d2	; Line
	move.w	d4,d0
	sub.w	#1,d1
	bne		.LineLoop

	move.w	d5,d1
	and.w	#$f,d2
	add.w	#$1,d2		; Plane
	sub.w	#$1,d3
	bne		.LineLoop
	
	rts

Init:
	lea     ImageBitmap,a2
	move.w  #IMAGE_WIDTH,BMI_Width(a2)
	move.w  #IMAGE_HEIGHT,BMI_Height(a2)
	move.w  #BITMAP_PLANES,BMI_Planes(a2)
	move.w  #BIF_FL_NONE,BMI_Flags(a2)
	move.w  #1,BMI_Frames(a2)
	move.l  #Source,BMI_Bitplane(a2)
	jsr     InitBitmapInfo

	lea     DisplayBitmap,a2
	move.w  #DISPLAY_WIDTH,BMI_Width(a2)
	move.w  #DISPLAY_HEIGHT,BMI_Height(a2)
	move.w  #BITMAP_PLANES,BMI_Planes(a2)
	move.w  #BIF_FL_NONE,BMI_Flags(a2)
	move.w  #1,BMI_Frames(a2)
	move.l  #Target,BMI_Bitplane(a2)
	jsr     InitBitmapInfo

	rts

InitBitmapInfo:

	moveq	#0,d1
	move.w  BMI_Width(a2),d0

	; Calculate number of bytes perrow
	; bytesPerRow = width / 8;
	; if ((width & 0x0f) != 0)	// Modulo 16
	;   bytesPerRow += 2;
	move.w  d0,d1
	and.w	#$fff0,d1
	lsr.w   #3,d1							; div by 8
	and.w   #$f,d0
	beq     .StoreBytes
	addq.w  #2,d1

.StoreBytes:
	move.w  d1,BMI_BytesPerRow(a2)

	; If the bitplane is interleaved, one bitplane row
	; follows directly after the other, otherwise a complete
	; bitplane follows after the other.
	move.w	BMI_Flags(a2),d0
	btst	#BIF_BT_INTERLEAVE,d0
	bne		.Interleaved
	
	; If not interleaved then the next line follows 
	; directly after the end of a line.
	moveq	#0,d0
	move.l	d0,BMI_NextLine(a2)
	move.l  d1,BMI_LineDistance(a2)

	; The next plane starts after <Height> lines after the
	; end of a line.
	; BytesPerRow*(Height-1)
	move.w  BMI_Height(a2),d0
	mulu.w  d1,d0
	move.l  d0,BMI_PlaneDistance(a2)
	move.l  d0,BMI_NextPlane(a2)

	rts

.Interleaved:
	; When interleaved, the same line of the next plane
	; follows directly after the end of a line.
	moveq	#0,d0
	move.l  d0,BMI_NextPlane(a2)
	move.l  d1,BMI_PlaneDistance(a2)

	; If interleaved then the next line of the same plane
	; starts at BytesPerRow*(Planes-1) after the end of a line.
	move.w	BMI_Planes(a2),d0
	mulu.w	d1,d0
	move.l  d0,BMI_LineDistance(a2)
	sub.l	d1,d0
	move.l  d0,BMI_NextLine(a2)

	rts

BlitCPU:

	movem.l	d2-d7/a2-a6,-(sp)

	; Source off the left
	; if ((x + sw) <= 0)
	;	return Invisible;
	move.w	BMI_Width(a2),d2
	move.w	d2,d5
	add.w	d0,d2
	ble		.Invisible
	
	; Determine the number of visible pixels.
	; if ((x + sw) < sw)	// Negative x
	;	sw = x + sw;
	cmp.w	d2,d5
	ble		.CheckLeft
	move.w	d2,d5
	bra		.CheckHeight

.CheckLeft:
	; if ((x + tw) > sw)
	;	sw = tw - x;
	move.w	BMI_Width(a3),d3
	cmp.w	d3,d2
	blt		.CheckHeight
	move.w	d3,d5
	sub.w	d0,d5
	ble		.Invisible
	
.CheckHeight:
	; Source is above the target
	; if ((y + ih) <= 0)
	;	return Invisible;
	move.w	BMI_Height(a3),d4
	move.w	BMI_Height(a2),d2
	move.w	d2,d6
	add.w	d1,d2
	ble  	.Invisible

	; if ((y + sh) <= th)	// Negative y
	;	sh = y + sh;
	cmp.w	d2,d6
	ble		.CheckDown
	move.w	d2,d6
	bra		.LoadPointers

.CheckDown:
	; if ((y + th) > sh)
	;	sh = th - y;
	cmp.w	d4,d2
	blt		.LoadPointers
	move.w	d4,d6
	sub.w	d1,d6
	ble		.Invisible
	
	; d0 - x
	; d1 - y
	; d5 - Visible source columns
	; d6 - Visible source lines
	
.LoadPointers:
	move.l	BMI_Bitplane(a2),a0
	move.l	BMI_Bitplane(a3),a1

	; Position pointers to line
	; sp = &splane[y * sLineDistance]
	move.l	BMI_LineDistance(a2),d2
	move.l	d2,d3
	mulu.w	d1,d2
	add.l	d2,a0

	; tp = &tplane[y * tLineDistance]
	move.l	BMI_LineDistance(a3),d2
	move.l	d2,d4
	mulu.w	d1,d2
	add.l	d2,a1

	; Modulo for the target after a line has been copied
	moveq	#0,d0
	move.w	BMI_BytesPerRow(a2),d0
	
	move.l	BMI_NextPlane(a2),d1
	sub.l	d0,d1
	move.l	BMI_NextPlane(a3),d2
	sub.l	d0,d2
	move.w	BMI_Planes(a2),a6

.BlitterLoop:
	; d0 - Visible width loop counter
	; d1 - NextPlane source
	; d2 - NextPlane target
	; d3 - LineDistance source
	; d4 - LineDistance target
	; d5 - Visible columns
	; d6 - Visible lines
	; d7 - PlaneCounter

	; a0 - Source linepointer
	; a1 - Target linepointer
	; a6 - Nuber of planes

	move.w	a6,d7
	move.w	d5,d0
	move.l	a0,a4
	move.l	a1,a5

.LineLoop:
	move.w	(a4)+,(a5)+

.BitCopy:
	sub.w	#16,d0
	bpl		.LineLoop

.NextPlane:
	add.l	d1,a4
	add.l	d2,a5
	move.w	d5,d0
	sub.w	#1,d7
	bne		.LineLoop

.NextLine:
	add.l	d3,a0
	add.l	d4,a1
	move.w	a6,d7
	
	subq	#1,d6
	bne		.BlitterLoop

.BlitDone:
	movem.l (sp)+,d2-d7/a2-a6
	moveq.l #1,d0

	rts

.Invisible:
	movem.l (sp)+,d2-d7/a2-a6
	moveq.l #0,d0
	rts

* Put variables and constants here

DisplayBitmap:  ds.b BitmapInfo
ImageBitmap:    ds.b BitmapInfo

    ORG    (*+15)&-16
ImageStart:     dc.b 'ISIS'
    ORG    (*+15)&-16
Source:         dcb.w IMAGE_HEIGHT*IMAGE_WORDS*BITMAP_PLANES,$eabf
ImageEnd:       dc.b $de,$ad,$be,$ef,'IEIE',0,0

    ORG    (*+15)&-16
DisplayStart:   dc.b 'DSDS'
    ORG    (*+15)&-16
Target:         ds.w (DISPLAY_WIDTH/16)*DISPLAY_HEIGHT*BITMAP_PLANES
DisplayEnd:     dc.b $de,$ad,$be,$ef,'DEDE',0,0
	
    END    START        ; last line of source






*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
