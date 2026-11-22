; Lab 6 - Linked list menu program
; Implements int main(), printList(), addValue() and removeValue().
; Uses TRAP x40 (input.asm) to read a number and TRAP x41 (output.asm) to print one.
;
; Calling convention (same as the sample main):
;   - Arguments are pushed on the runtime stack by the caller, and popped by the caller.
;   - The callee pushes the return address (R7), then the caller's frame pointer (R5),
;     then sets R5 = R6. Locals live below R5 (R5-1, R5-2, ...).
;   - Inside a callee:  R5+0 = saved R5,  R5+1 = return address,
;                       R5+2 = last argument pushed, R5+3 = the one pushed before it.

.ORIG x3000
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; int main()
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Main's return value
LD R6, STACK_BASE		; R6 = x6000

; Main's return address
ADD R6, R6, #-1			; R6 = x5FFF
STR R7, R6, #0

; Previous frame pointer
ADD R6, R6, #-1			; R6 = x5FFE
STR R5, R6, #0

; Set frame pointer
ADD R5, R6, #0			; R5 = R6 = x5FFE

; node_t *head
ADD R6, R6, #-1			; R6 = x5FFD
AND R0, R0, #0			; R0 = 0
STR R0, R6, #0

; char selection = 's'  (the sample code left this uninitialised)
ADD R6, R6, #-1			; R6 = x5FFC
LD R0, LOWERCASE_S
STR R0, R6, #0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; while(selection != 'q')
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Perform the check for the while loop
; We check to see if char selection is equal to 'q'
; If equal, quit
; It not equal, continue running the loop
CHECK_WHILE
LDR R0, R5, #-2			; R0 = char selection
LD R1, LOWERCASE_Q
NOT R1, R1
ADD R1, R1, #1
ADD R1, R0, R1
BRz BREAK_WHILE_LOOP

; Print the options menu
LEA R0, PROMPT_MENU
PUTS

; Get a character from the keyboard and put it in selection
; Like scanf(" %c"), skip whitespace such as a leftover Enter key
GET_SELECTION
GETC
ADD R1, R0, #-16
ADD R1, R1, #-16		; R1 = R0 - 32 (' ')
BRnz GET_SELECTION		; space / control character: read again
OUT				; echo the character the user typed
STR R0, R5, #-2			; Store the character on the runtime stack in char selection (R0 = char selection)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; if(selection == 'p')
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Check if char selection is equal to 'p'
LD R1, LOWERCASE_P
NOT R1, R1
ADD R1, R1, #1
ADD R1, R0, R1
BRnp ELSE_IF_A			; If not equal to 'p' check 'a'

; Display prompt
LEA R0, PROMPT_PRINT
PUTS

; node_t **head (&head) (input to printList())
ADD R6, R6, #-1			; R6 = x5FFB
ADD R0, R5, #-1			; R0 = &head = x5FFD
STR R0, R6, #0

JSR PRINT_LIST

; Pop node_t **head
ADD R6, R6, #1			; R6 = x5FFC

BRnzp CONTINUE_WHILE_LOOP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; else if(selection == 'a')
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Check if char selection is equal to 'a'
ELSE_IF_A
LD R1, LOWERCASE_A
NOT R1, R1
ADD R1, R1, #1
ADD R1, R0, R1
BRnp ELSE_IF_R

; int a
ADD R6, R6, #-1			; R6 = x5FFB
AND R0, R0, #0
STR R0, R6, #0

; Display prompt
LEA R0, PROMPT_ADD
PUTS

; TRAP service routine for getting a number (input.asm); result is in R0
TRAP x40

; Store number entered into int a
STR R0, R5, #-3

; node_t **head (&head) (input to addValue())
ADD R6, R6, #-1			; R6 = x5FFA
ADD R0, R5, #-1			; R0 = &head = x5FFD
STR R0, R6, #0

; int added (a) (input to addValue())
ADD R6, R6, #-1			; R6 = x5FF9
LDR R0, R5, #-3
STR R0, R6, #0

JSR ADD_VALUE

; Pop int added
ADD R6, R6, #1			; R6 = x5FFA

; Pop node_t **head
ADD R6, R6, #1			; R6 = x5FFB

; Pop int a
ADD R6, R6, #1			; R6 = x5FFC

BRnzp CONTINUE_WHILE_LOOP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; else if(selection == 'r')
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Check if char selection is equal to 'r'
ELSE_IF_R
LD R1, LOWERCASE_R
NOT R1, R1
ADD R1, R1, #1
ADD R1, R0, R1
BRnp CONTINUE_WHILE_LOOP

; int r
ADD R6, R6, #-1			; R6 = x5FFB
AND R0, R0, #0
STR R0, R6, #0

; Display prompt
LEA R0, PROMPT_REMOVE
PUTS

; TRAP service routine for getting a number (input.asm); result is in R0
TRAP x40

; Store number entered into int r
STR R0, R5, #-3

; node_t **head (&head) (input to removeValue())
ADD R6, R6, #-1			; R6 = x5FFA
ADD R0, R5, #-1			; R0 = &head = x5FFD
STR R0, R6, #0

; int removed (r) (input to removeValue())
ADD R6, R6, #-1			; R6 = x5FF9
LDR R0, R5, #-3
STR R0, R6, #0

JSR REMOVE_VALUE

; Pop int removed
ADD R6, R6, #1			; R6 = x5FFA

; Pop node_t **head
ADD R6, R6, #1			; R6 = x5FFB

; Pop int r
ADD R6, R6, #1			; R6 = x5FFC

BRnzp CONTINUE_WHILE_LOOP

; Loop back to check the while loop condition again
CONTINUE_WHILE_LOOP
BRnzp CHECK_WHILE

BREAK_WHILE_LOOP

; Pop local variables in main
ADD R6, R6, #2			; R6 = x5FFE

; Pop previous frame pointer
LDR R5, R6, #0
ADD R6, R6, #1			; R6 = x5FFF

; Pop return address
LDR R7, R6, #0
ADD R6, R6, #1			; R6 = x6000

HALT

STACK_BASE .FILL x6000

LOWERCASE_A .FILL x0061
LOWERCASE_P .FILL x0070
LOWERCASE_Q .FILL x0071
LOWERCASE_R .FILL x0072
LOWERCASE_S .FILL x0073

PROMPT_MENU .STRINGz 	"Available options:\np - Print linked list\na - Add value to linked list\nr - Remove value from linked list\nq - Quit\nChoose an option: "
PROMPT_PRINT .STRINGz 	"\nContents of the linked list: \n"
PROMPT_ADD .STRINGz 	"\nType a number to add: \n"
PROMPT_REMOVE .STRINGz 	"\nType a number to remove: \n"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void printList(node_t **head)
;   R5+2 = head (node_t **)
;   R5-1 = node_t *current
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRINT_LIST
ADD R6, R6, #-1			; push return address
STR R7, R6, #0
ADD R6, R6, #-1			; push previous frame pointer
STR R5, R6, #0
ADD R5, R6, #0			; set frame pointer
ADD R6, R6, #-1			; local: current (R5-1)

; node_t *current = (*head);
LDR R0, R5, #2			; R0 = head (the address of the caller's head)
LDR R0, R0, #0			; R0 = *head
STR R0, R5, #-1

; while(current != 0)
PL_WHILE
LDR R0, R5, #-1			; R0 = current
BRz PL_END

; printf("%d", current->value);
LDR R0, R0, #0			; R0 = current->value
TRAP x41			; output TRAP service routine (output.asm)

; current = current->next;
LDR R0, R5, #-1
LDR R0, R0, #1			; R0 = current->next
STR R0, R5, #-1			; (STR does not change the condition codes)

; if(current != 0) printf(" -> ");
BRz PL_END			; condition codes still describe current->next
LEA R0, ARROW
PUTS
BRnzp PL_WHILE

; printf("\n");
PL_END
LD R0, NEWLINE
OUT

ADD R6, R5, #0			; pop local variables
LDR R5, R6, #0			; pop previous frame pointer
ADD R6, R6, #1
LDR R7, R6, #0			; pop return address
ADD R6, R6, #1
RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void addValue(node_t **head, int added)
;   R5+3 = head (node_t **)       R5+2 = added
;   R5-1 = node_t *current        R5-2 = the new node
;
; There is no malloc subroutine, so the new node (2 words: value, next) is
; taken from a block of free memory that starts at HEAP_PTR (x7000) and grows
; upward. This is done inline, not in a subroutine.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ADD_VALUE
ADD R6, R6, #-1			; push return address
STR R7, R6, #0
ADD R6, R6, #-1			; push previous frame pointer
STR R5, R6, #0
ADD R5, R6, #0			; set frame pointer
ADD R6, R6, #-2			; locals: current (R5-1), new node (R5-2)

; new node = malloc(sizeof(node_t));
LD R0, HEAP_PTR			; R0 = address of the new node
STR R0, R5, #-2
ADD R1, R0, #2
ST R1, HEAP_PTR			; the next free block is 2 words further

; node->value = added;  node->next = 0;
LDR R1, R5, #2			; R1 = added
STR R1, R0, #0
AND R1, R1, #0
STR R1, R0, #1

; node_t *current = (*head);
LDR R1, R5, #3			; R1 = head (the address of the caller's head)
LDR R2, R1, #0			; R2 = *head
STR R2, R5, #-1
ADD R2, R2, #0			; set condition codes from *head
BRnp AV_WALK

; if((*head) == 0) the new node becomes the first node
STR R0, R1, #0			; *head = new node (R0 = new node, R1 = head)
BRnzp AV_DONE

; Otherwise walk to the last node (the one whose next is 0)
AV_WALK
LDR R1, R5, #-1			; R1 = current
LDR R2, R1, #1			; R2 = current->next
BRz AV_LINK
STR R2, R5, #-1			; current = current->next
BRnzp AV_WALK

; current->next = new node
AV_LINK
LDR R0, R5, #-2			; R0 = new node
STR R0, R1, #1

AV_DONE
ADD R6, R5, #0			; pop local variables
LDR R5, R6, #0			; pop previous frame pointer
ADD R6, R6, #1
LDR R7, R6, #0			; pop return address
ADD R6, R6, #1
RET

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void removeValue(node_t **head, int removed)
;   R5+3 = head (node_t **)       R5+2 = removed
;   R5-1 = node_t *prev           R5-2 = node_t *current
;
; free() is not implemented: the node is only unlinked, its 2 words of heap
; memory are simply not reused.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
REMOVE_VALUE
ADD R6, R6, #-1			; push return address
STR R7, R6, #0
ADD R6, R6, #-1			; push previous frame pointer
STR R5, R6, #0
ADD R5, R6, #0			; set frame pointer
ADD R6, R6, #-2			; locals: prev (R5-1), current (R5-2)

; if((*head) == 0) return;
LDR R1, R5, #3			; R1 = head (the address of the caller's head)
LDR R0, R1, #0			; R0 = *head
BRz RV_DONE

; node_t *prev = (*head);
STR R0, R5, #-1

; if((*head)->value == removed)
LDR R2, R0, #0			; R2 = (*head)->value
LDR R3, R5, #2			; R3 = removed
NOT R3, R3
ADD R3, R3, #1
ADD R2, R2, R3			; value - removed
BRnp RV_SEARCH

; (*head) = (*head)->next;  (free(prev) not implemented)
LDR R2, R0, #1			; R0 is still the old first node
STR R2, R1, #0
BRnzp RV_DONE

; node_t *current = (*head)->next;
RV_SEARCH
LDR R2, R0, #1
STR R2, R5, #-2

; while(current != 0)
RV_WHILE
LDR R2, R5, #-2			; R2 = current
BRz RV_DONE

; if(current->value == removed)
LDR R0, R2, #0			; R0 = current->value
LDR R3, R5, #2			; R3 = removed
NOT R3, R3
ADD R3, R3, #1
ADD R0, R0, R3
BRnp RV_ADVANCE

; prev->next = current->next;  (free(current) not implemented)
LDR R0, R2, #1			; R0 = current->next
LDR R1, R5, #-1			; R1 = prev
STR R0, R1, #1
BRnzp RV_DONE

; prev = current;  current = current->next;
RV_ADVANCE
STR R2, R5, #-1			; prev = current
LDR R0, R2, #1			; R0 = current->next
STR R0, R5, #-2			; current = current->next
BRnzp RV_WHILE

RV_DONE
ADD R6, R5, #0			; pop local variables
LDR R5, R6, #0			; pop previous frame pointer
ADD R6, R6, #1
LDR R7, R6, #0			; pop return address
ADD R6, R6, #1
RET

; Data used by the subroutines
HEAP_PTR .FILL x7000		; next free block of memory for new nodes
NEWLINE .FILL x000A
ARROW .STRINGz " -> "

.END
