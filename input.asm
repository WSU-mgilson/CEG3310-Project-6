; input.asm - TRAP x40 (vector table entry x0040 -> x4000)
;
; Reads a decimal number of 1 or 2 digits from the keyboard.
;   - Typing two digits finishes immediately ("31" -> R0 = x001F).
;   - Typing one digit finishes when Enter is pressed ("5" Enter -> R0 = x0005).
;   - Digits are echoed; any other key is ignored; one newline is printed at the end.
; Output : R0 = the number
; All other registers are preserved (R7 is saved because GETC/OUT overwrite it).
; Registers are saved in memory rather than on the stack, so this routine
; works no matter what R6 points to.

.ORIG x4000

        ST   R1, SAVE_R1
        ST   R2, SAVE_R2
        ST   R3, SAVE_R3
        ST   R4, SAVE_R4
        ST   R7, SAVE_R7

        AND  R2, R2, #0         ; R2 = value read so far
        AND  R3, R3, #0         ; R3 = number of digits read so far

READ_CHAR
        GETC                    ; R0 = typed character
        LD   R1, NEG_ASCII_0
        ADD  R1, R0, R1         ; R1 = character - '0'
        BRn  NOT_DIGIT          ; below '0'
        ADD  R4, R1, #-9
        BRp  NOT_DIGIT          ; above '9'

        ; It is a digit (R1 = 0..9): value = value * 10 + digit
        ADD  R4, R2, R2         ; R4 = 2v
        ADD  R2, R4, R4         ; R2 = 4v
        ADD  R2, R2, R2         ; R2 = 8v
        ADD  R2, R2, R4         ; R2 = 10v
        ADD  R2, R2, R1         ; R2 = 10v + digit
        ADD  R3, R3, #1         ; one more digit read
        OUT                     ; echo the digit (R0 still holds it)
        ADD  R4, R3, #-2
        BRn  READ_CHAR          ; fewer than 2 digits so far: keep reading
        BRnzp FINISH            ; 2 digits: done

NOT_DIGIT
        ADD  R3, R3, #0
        BRz  READ_CHAR          ; no digits yet: ignore this key
        ADD  R1, R0, #-10       ; line feed?
        BRz  FINISH
        ADD  R1, R0, #-13       ; carriage return?
        BRz  FINISH
        BRnzp READ_CHAR         ; anything else: ignore

FINISH
        LD   R0, NEWLINE
        OUT                     ; move to the next line
        ADD  R0, R2, #0         ; return value in R0

        LD   R1, SAVE_R1
        LD   R2, SAVE_R2
        LD   R3, SAVE_R3
        LD   R4, SAVE_R4
        LD   R7, SAVE_R7
        RET

NEG_ASCII_0 .FILL #-48
NEWLINE     .FILL x000A
SAVE_R1     .FILL x0000
SAVE_R2     .FILL x0000
SAVE_R3     .FILL x0000
SAVE_R4     .FILL x0000
SAVE_R7     .FILL x0000

.END
