*-----------------------------------------------------------
* Title      :
* Written by :
* Date       :
* Description:
*-----------------------------------------------------------
    ORG    $1000
START:                  ; first instruction of program

* Put program code here

STACK_ALLOC MACRO

SA_SIZE     set \1
SA_ALIGN    set 2
SA_REGISTER set \2

	IFEQ NARG-3
SA_ALIGN    set \2
SA_REGISTER set \3
	ENDC

    IFGT SA_ALIGN-255
        FAIL [ERR] Alignment must be < 255
    ENDC
	
SA_MODULO set SA_SIZE-((SA_SIZE/SA_ALIGN)*SA_ALIGN)

    move.l      a7,SA_REGISTER
    sub.l       #SA_SIZE+(SA_ALIGN-SA_MODULO),SA_REGISTER
    and.b       #$100-SA_ALIGN,SA_REGISTER
    exg         SA_REGISTER,a7
    
    ENDM
    
    sub.l       #2,a7
    STACK_ALLOC 2,d0
    move.l      a7,d1
    sub.l       d1,d0    

    SIMHALT             ; halt simulator

* Put variables and constants here

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
