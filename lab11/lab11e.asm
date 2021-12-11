	;; 
	;; Author: Bill Slough
	;;
	;; Subroutines with stack frames: improved parameter passing
	;;
	;; Lights one pixel and one 2x2 square block
	;; 

	.ORIG x3000

	;; Main program...............................................................

START	LD	R6,TOP  		; initialize stack pointer
	AND	R5,R5,#0		; frame pointer = null


	LD	R0, Num
	ADD	R6,R6,#-1  		;
	STR	R0,R6,#0  		; push N	

	LD	R0, Siz
	ADD	R6,R6,#-1  		;
	STR	R0,R6,#0  		; push S	

	LD	R0,RED   		;
	ADD	R6,R6,#-1 		;	
	STR	R0,R6,#0 		; push RED

	LD	R0,OTHER 		;
	ADD	R6,R6,#-1  		;
	STR	R0,R6,#0  		; push DIFFERENT COLOR

	JSR	DRAW_BRD		; DRAW_BLOCK(BROW, BCOLUMN)
	ADD	R6,R6,#4		; remove parameters from stack frame


STOP   	HALT

TOP	.FILL	x6000			; where does the stack begin?
PRMPT	.STRINGZ 	"ENTER N"
PRMP2	.STRINGZ 	"ENTER S"
Siz	.FILL	8			; what size?
Num	.FILL	7			; what number?
RED	.FILL	x7C00			; desired color for pixel
OTHER	.FILL   x03E0			; second color


BCOLOR  .FILL   x03E0			; What block color?
BSIZE	.FILL	3			; What size block?

	;; SUBROUTINE
DRAW_BRD
	;; Draw a CheckeredPattern
	;;
	;; Parameters:
	;; 
	;; Frame offsets:
	;;	-4  saved R4
	;;	-3  saved R3
	;; 	-2  saved R2
	;; 	-1  saved R1
	;; 	 0  saved R0
	;; 	+1  previous frame pointer
	;; 	+2  return address
	;; 	+3  color_two
	;; 	+4  color_one
	;;	+5  s
	;;  	+6  n

	;; PROLOG
	ADD	R6,R6,#-1 		;
	STR	R7,R6,#0  		; push return address

	ADD	R6,R6,#-1		;	
	STR	R5,R6,#0  		; push previous frame pointer

	ADD	R5,R6,#-1		; establish frame pointer for this frame

	STR	R0,R6,#-1		; save registers being used in this routine
	STR	R1,R6,#-2		;
	STR	R2,R6,#-3		;
	STR	R3,R6,#-4		;
	STR 	R4,R6,#-5
	ADD	R6,R6,#-5		; adjust stack pointer to the top of the frame
	;; BODY
	
	LDR	R0,R5,#6
	AND	R4,R4,#0
	AND	R0,R0,#0
	ADD	R0,R0,#-1
	AND	R1,R1,#0
	ADD	R1,R1,#-1
	LDR	R2,R5,#3

RL	ADD	R0,R0,#1
CL	ADD	R1,R1,#1
	LDR	R3,R5,#5
	ADD	R6,R6,#-1		
	STR	R3,R6,#0		;push size
	ADD	R6,R6,#-1
	STR	R2,R6,#0		;push color
	ADD	R6,R6,#-1
	STR	R0,R6,#0		;push row	
	ADD	R6,R6,#-1
	STR	R1,R6,#0		;push col
	JSR	DRAW_BLK		
	ADD	R6,R6,#4	
	LDR	R3,R5,#6
	NOT	R3,R3
	ADD	R3,R3,#2
	ADD	R3,R3,R1
	BRn	CL
	AND	R1,R1,#0
	ADD	R1,R1,#-1
	

	LDR	R3,R5,#6
	NOT	R3,R3
	ADD	R3,R3,#2
	ADD	R3,R3,R0
	BRn	RL



	LDR	R0,R5,#6
	AND	R4,R4,#0
	AND	R0,R0,#0
	ADD	R0,R0,#-1
	AND	R1,R1,#0
	ADD	R1,R1,#-2
	LDR	R2,R5,#4
	
ROLOOP	ADD	R0,R0,#1
COLOOP	ADD	R1,R1,#2
	LDR	R3,R5,#5
	ADD	R6,R6,#-1		
	STR	R3,R6,#0		;push size
	ADD	R6,R6,#-1
	STR	R2,R6,#0		;push color
	ADD	R6,R6,#-1
	STR	R0,R6,#0		;push row	
	ADD	R6,R6,#-1
	STR	R1,R6,#0		;push col
	JSR	DRAW_BLK		
	ADD	R6,R6,#4	
	LDR	R3,R5,#6
	NOT	R3,R3
	ADD	R3,R3,#3
	ADD	R3,R3,R1
	BRn	COLOOP
	AND	R1,R1,#0
	ADD	R1,R1,#-2
	
	ADD	R6,R6,#-1
	STR	R0,R6,#0		;push row
	JSR	DIVISIBLE
	LDR	R3,R6,#0
	ADD	R1,R1,R3
	ADD	R6,R6,#1
	LDR	R3,R5,#6
	NOT	R3,R3
	ADD	R3,R3,#2
	ADD	R3,R3,R0
	BRn	ROLOOP
	;; EPILOG
	LDR	R4,R5,#-4
	LDR	R3,R5,#-3
	LDR	R2,R5,#-2 		; restore R2
	LDR	R1,R5,#-1 		; restore R1
	LDR	R0,R5,#0  		; restore R0
	LDR	R7,R5,#2 		; get the return address
	LDR	R5,R5,#1  		; restore the previous frame pointer
	ADD	R6,R6,#7 		; adjust the stack pointer, deallocate frame
	RET

BROW	.FILL	0			; which block row?
BCOLUMN	.FILL	0			; which block column?

	;; Subroutine ................................................................
DRAW_BLK
	;; Draw a 2x2 green block at a specified location
	;;
	;; Parameters:
	;; 	b_row    -- which row of blocks
	;; 	b_column -- which column of blocks
	;; 
	;; Frame offsets:
	;;	-4  saved R4
	;;	-3  saved R3
	;; 	-2  saved R2
	;; 	-1  saved R1
	;; 	 0  saved R0
	;; 	+1  previous frame pointer
	;; 	+2  return address
	;; 	+3  column
	;; 	+4  row
	;;	+5  color
	;;  	+6  size

	;; PROLOG
	ADD	R6,R6,#-1 		;
	STR	R7,R6,#0  		; push return address

	ADD	R6,R6,#-1		;	
	STR	R5,R6,#0  		; push previous frame pointer

	ADD	R5,R6,#-1		; establish frame pointer for this frame

	STR	R0,R6,#-1		; save registers being used in this routine
	STR	R1,R6,#-2		;
	STR	R2,R6,#-3		;
	STR	R3,R6,#-4		;
	STR 	R4,R6,#-5
	ADD	R6,R6,#-5		; adjust stack pointer to the top of the frame

	;; BODY
	LDR	R3,R5,#6		; R3 = size
	LDR	R2,R5,#5		; R2 = color
	LDR	R0,R5,#4 		; R0 = b_row
	LDR	R1,R5,#3		; R1 = b_column
	
		

	MUL	R0,R0,R3 		; R0 = 2 * b_row
	MUL	R1,R1,R3		; R1 = 2 * b_column

BRLOOP	LDR	R4,R5,#6		; R4 = R3 for col counter
BCLOOP	ADD	R6,R6,#-1 		; upper left pixel in block
	STR	R0,R6,#0 		; push R0
	ADD	R6,R6,#-1		;
	STR	R1,R6,#0 		; push R1
	ADD	R6,R6,#-1		;
	STR	R2,R6,#0		; push R2
	JSR	DRAW_PIXEL		; draw_pixel(2 * b_row, 2 * b_column, GREEN)
	ADD	R6,R6,#3		; remove parameters
	ADD	R1,R1,#1
	ADD	R4,R4,#-1
	BRp	BCLOOP
	LDR	R1,R5,#3
	LDR	R4,R5,#6
	MUL	R1,R1,R4
	ADD	R0,R0,#1
	ADD	R3,R3,#-1
	BRp	BRLOOP
	
	;; EPILOG
	LDR	R4,R5,#-4
	LDR	R3,R5,#-3
	LDR	R2,R5,#-2 		; restore R2
	LDR	R1,R5,#-1 		; restore R1
	LDR	R0,R5,#0  		; restore R0
	LDR	R7,R5,#2 		; get the return address
	LDR	R5,R5,#1  		; restore the previous frame pointer
	ADD	R6,R6,#7 		; adjust the stack pointer, deallocate frame
	RET

	;; Constants used by DRAW_BLK
GREEN	.FILL	x03E0	
	;; Subroutine
DIVISIBLE	;; Draw a pixel on the graphics display unit at a specified location
	;;
	;; Parameters:
	;; 	row     -- a value between 0 and 123
	;; 	column  -- a value between 0 and 127
	;; 	color   -- a 15-bit RGB value
	;;
	;; Frame offsets:
	;; 	-4  saved R4
	;; 	-3  saved R3
	;; 	-2  saved R2
	;; 	-1  saved R1
	;; 	 0  saved R0
	;; 	+1  previous frame pointer
	;; 	+2  return address
	;; 	+3  row

	;; PROLOG
	ADD	R6,R6,#-1 		;
	STR	R7,R6,#0  		; push return address

	ADD	R6,R6,#-1		;	
	STR	R5,R6,#0  		; push previous frame pointer

	ADD	R5,R6,#-1		; establish frame pointer for this frame

	STR	R0,R6,#-1		; save registers being used in this routine
	STR	R1,R6,#-2		;
	STR	R2,R6,#-3		;
	STR	R3,R6,#-4 		;
	STR	R4,R6,#-5 		;
	ADD	R6,R6,#-5		; adjust stack pointer to the top of the frame

	LDR	R0,R5,#3
LOOP	ADD 	R0,R0,#-1
	BRz 	ODD
	ADD 	R0,R0,#-1
	BRp 	LOOP
	AND	R0,R0,#0
	ADD	R0,R0,#1
	STR	R0,R5,#3
	;; EPILOG
	LDR	R4,R5,#-4 		; restore R4
	LDR	R3,R5,#-3 		; restore R3
	LDR	R2,R5,#-2 		; restore R2
	LDR	R1,R5,#-1 		; restore R1
	LDR	R0,R5,#0  		; restore R0
	LDR	R7,R5,#2 		; get the return address
	LDR	R5,R5,#1  		; restore the previous frame pointer
	ADD	R6,R6,#7 		; adjust the stack pointer, deallocate frame
	RET

ODD	AND	R0,R0,#0
	STR	R0,R5,#3
	;; EPILOG
	LDR	R4,R5,#-4 		; restore R4
	LDR	R3,R5,#-3 		; restore R3
	LDR	R2,R5,#-2 		; restore R2
	LDR	R1,R5,#-1 		; restore R1
	LDR	R0,R5,#0  		; restore R0
	LDR	R7,R5,#2 		; get the return address
	LDR	R5,R5,#1  		; restore the previous frame pointer
	ADD	R6,R6,#7 		; adjust the stack pointer, deallocate frame
	RET
	
	;; Subroutine ................................................................
DRAW_PIXEL
	;; Draw a pixel on the graphics display unit at a specified location
	;;
	;; Parameters:
	;; 	row     -- a value between 0 and 123
	;; 	column  -- a value between 0 and 127
	;; 	color   -- a 15-bit RGB value
	;;
	;; Frame offsets:
	;; 	-4  saved R4
	;; 	-3  saved R3
	;; 	-2  saved R2
	;; 	-1  saved R1
	;; 	 0  saved R0
	;; 	+1  previous frame pointer
	;; 	+2  return address
	;; 	+3  color
	;; 	+4  column
	;; 	+5  row

	;; PROLOG
	ADD	R6,R6,#-1 		;
	STR	R7,R6,#0  		; push return address

	ADD	R6,R6,#-1		;	
	STR	R5,R6,#0  		; push previous frame pointer

	ADD	R5,R6,#-1		; establish frame pointer for this frame

	STR	R0,R6,#-1		; save registers being used in this routine
	STR	R1,R6,#-2		;
	STR	R2,R6,#-3		;
	STR	R3,R6,#-4 		;
	STR	R4,R6,#-5 		;
	ADD	R6,R6,#-5		; adjust stack pointer to the top of the frame

	;; BODY
	LDR	R0,R5,#5 		; R0 = row
	LDR	R1,R5,#4 		; R1 = column
	LDR	R2,R5,#3 		; R2 = color
	
	ADD	R3,R0,#0	  	;
	LD	R4,PIX_PER_ROW 	;
	MUL	R3,R3,R4		;
	ADD	R3,R3,R1		; R3 = PIX_PER_ROW * row + column

	LD	R4,VIDEO_ADDR
	ADD	R4,R4,R3 		; R4 = address of desired pixel

	STR	R2,R4,#0 		; Video[row,column] = color

	;; EPILOG
	LDR	R4,R5,#-4 		; restore R4
	LDR	R3,R5,#-3 		; restore R3
	LDR	R2,R5,#-2 		; restore R2
	LDR	R1,R5,#-1 		; restore R1
	LDR	R0,R5,#0  		; restore R0
	LDR	R7,R5,#2 		; get the return address
	LDR	R5,R5,#1  		; restore the previous frame pointer
	ADD	R6,R6,#7 		; adjust the stack pointer, deallocate frame
	RET

	;; Constants used by DRAW_PIXEL
VIDEO_ADDR	.FILL	xC000	; base address of the video display
PIX_PER_ROW	.FILL	128	; number of pixels per row
GET_PIXEL
	;; Get a pixel on the graphics display unit at a specified location
	;; 
	;; Parameters:
	;; 	row     -- a value between 0 and 123
	;; 	column  -- a value between 0 and 127
	;; 
	;; Frame offsets:
	;; 	-4  saved R4
	;; 	-3  saved R3
	;; 	-2  saved R2
	;; 	-1  saved R1
	;; 	 0  saved R0
	;; 	+1  previous frame pointer
	;; 	+2  return address
	;; 	+3  val
	;; 	+4  col
	;; 	+5  row
	;;	
	;; PROLOG
	
	
	ADD	R6,R6,#-2 		; push 1
	STR	R7,R6,#0  		; push return address

	ADD	R6,R6,#-1		;	
	STR	R5,R6,#0  		; push previous frame pointer

	ADD	R5,R6,#-1		; establish frame pointer for this frame

	STR	R0,R6,#-1		; save registers being used in this routine
	STR	R1,R6,#-2		;
	STR	R2,R6,#-3		;
	STR	R3,R6,#-4 		;
	STR	R4,R6,#-5 		;
	ADD	R6,R6,#-5		; adjust stack pointer to the top of the frame
	
	;; BODY
	LDR	R0,R5,#5		; row coordinates
	LDR	R1,R5,#4		; col coordinates
	
	ADD	R3,R0,#0
	LD	R4,PIX_PER_ROW	
	MUL	R3,R3,R4
	ADD	R3,R3,R1
	LD	R4,VIDEO_ADDR
	ADD	R4,R4,R3
	LDR	R4,R4,#0

	STR	R4,R5,#3
	
	
	;; EPILOG
	LDR	R4,R5,#-4 		; restore R4
	LDR	R3,R5,#-3 		; restore R3
	LDR	R2,R5,#-2 		; restore R2
	LDR	R1,R5,#-1 		; restore R1
	LDR	R0,R5,#0  		; restore R0
	LDR	R7,R5,#2 		; get the return address
	LDR	R5,R5,#1  		; restore the previous frame pointer
	ADD	R6,R6,#7 		; adjust the stack pointer, deallocate frame
	RET
	.END