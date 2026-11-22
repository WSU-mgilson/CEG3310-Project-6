; output.asm - TRAP x41 (vector table entry x0041 -> x5000)
;
; Prints the value in R0 as a decimal number (no leading zeros).
;   Example: R0 = x0028 prints "40".
; Input  : R0 = value to print
; All registers are preserved (R0 included).
; Registers are saved in memory rather than on the stack, so this routine
; works no matter what R6 points to.
;
; Method: for each power of ten (10000, 1000, 100, 10, 1) subtract it from the
; value as many times as possible. The number of subtractions is that digit.

.ORIG x5000

        ST   R0, SAVE_R0
        ST   R1, SAVE_R1
        ST   R2, SAVE_R2
        ST   R3, SAVE_R3
        ST   R4, SAVE_R4
        ST   R5, SAVE_R5
        ST   R7, SAVE_R7

        ADD  R1, R0, #0         ; R1 = value left to print
        BRzp PD_START
        LD   R0, ASCII_MINUS    ; negative: print '-' and negate
        OUT
        NOT  R1, R1
        ADD  R1, R1, #1

PD_START
        LEA  R3, POWERS         ; R3 = pointer into the table of -10^k
        AND  R5, R5, #0         ; R5 = 0 until the first digit is printed
        AND  R4, R4, #0
        ADD  R4, R4, #5         ; R4 = digits left to handle (5 .. 1)

PD_DIGIT
        LDR  R0, R3, #0         ; R0 = -(power of ten)
        AND  R2, R2, #0         ; R2 = this digit

PD_COUNT
        ADD  R1, R1, R0         ; subtract the power of ten
        BRn  PD_COUNT_DONE
        ADD  R2, R2, #1
        BRnzp PD_COUNT

PD_COUNT_DONE
        NOT  R0, R0
        ADD  R0, R0, #1         ; R0 = +power of ten
        ADD  R1, R1, R0         ; undo the last (too far) subtraction

        ; Print the digit unless it is a leading zero.
        ; (The last digit is always printed so that 0 prints as "0".)
        ADD  R2, R2, #0
        BRp  PD_PRINT           ; non-zero digit
        ADD  R5, R5, #0
        BRp  PD_PRINT           ; zero, but a digit was already printed
        ADD  R0, R4, #-1
        BRz  PD_PRINT           ; the ones place
        BRnzp PD_NEXT           ; leading zero: skip it

PD_PRINT
        LD   R0, ASCII_0
        ADD  R0, R0, R2
        OUT
        ADD  R5, R5, #1         ; a digit has now been printed

PD_NEXT
        ADD  R3, R3, #1         ; next power of ten
        ADD  R4, R4, #-1
        BRp  PD_DIGIT

        LD   R0, SAVE_R0
        LD   R1, SAVE_R1
        LD   R2, SAVE_R2
        LD   R3, SAVE_R3
        LD   R4, SAVE_R4
        LD   R5, SAVE_R5
        LD   R7, SAVE_R7
        RET

ASCII_0     .FILL x0030
ASCII_MINUS .FILL x002D
POWERS      .FILL #-10000
            .FILL #-1000
            .FILL #-100
            .FILL #-10
            .FILL #-1
SAVE_R0     .FILL x0000
SAVE_R1     .FILL x0000
SAVE_R2     .FILL x0000
SAVE_R3     .FILL x0000
SAVE_R4     .FILL x0000
SAVE_R5     .FILL x0000
SAVE_R7     .FILL x0000

.END
