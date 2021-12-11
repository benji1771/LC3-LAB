	;; 
	;; Author: Bill Slough
	;;
	;; Subroutines with stack frames: improved parameter passing
	;;
	;; Lights a few pixels
	;; 

	.ORIG x3000

	;; Main program...............................................................

START	LD	R6,TOP  		; initialize stack pointer
	AND	R5,R5,#0		; frame pointer = null

	LD	R0,ROW   		;
	ADD	R6,R6,#-1 		;	
	STR	R0,R6,#0 		; push ROW

	LD	R0,COLUMN 		;
	ADD	R6,R6,#-1  		;
	STR	R0,R6,#0  		; push COLUMN

	LD	R0,RED  		;
	ADD	R6,R6,#-1		;
	STR	R0,R6,#0		; push RED

	JSR	DRAW_PIXEL		; DRAW_PIXEL(ROW, COLUMN, RED)
	ADD	R6,R6,#3		; remove parameters from stack frame

	LD	R0,ROW   		;
	ADD	R6,R6,#-1 		;	
	STR	R0,R6,#0 		; push ROW

	LD	R0,COLUMN 		;
	ADD	R0,R0,#2		;
	ADD	R6,R6,#-1  		;
	STR	R0,R6,#0  		; push COLUMN + 2

	LD	R0,GREEN 		;
	ADD	R6,R6,#-1		;
	STR	R0,R6,#0		; push GREEN

	JSR	DRAW_PIXEL		; DRAW_PIXEL(ROW, COLUMN + 2, GREEN)
	ADD	R6,R6,#3		; remove parameters from stack frame

	LD	R0,ROW   		;
	ADD	R6,R6,#-1 		;	
	STR	R0,R6,#0 		; push ROW

	LD	R0,COLUMN 		;
	ADD	R6,R6,#-1  		;
	STR	R0,R6,#0  		; push COLUMN
	JSR	GET_PIXEL
	ADD	R6,R6,#3

	LD	R0,ROW   		;
	ADD	R6,R6,#-1 		;	
	STR	R0,R6,#0 		; push ROW

	LD	R0,COLUMN 
	ADD	R0,R0,#1		;
	ADD	R6,R6,#-1  		;
	STR	R0,R6,#0  		; push COLUMN + 1
	JSR	GET_PIXEL
	ADD	R6,R6,#3
	
	LD	R0,ROW   		;
	ADD	R6,R6,#-1 		;	
	STR	R0,R6,#0 		; push ROW	

	LD	R0,COLUMN 
	ADD	R0,R0,#2		;
	ADD	R6,R6,#-1  		;
	STR	R0,R6,#0  		; push COLUMN + 2
	JSR	GET_PIXEL
	ADD	R6,R6,#3
	
STOP   	HALT

TOP	.FILL	x6000		; where does the stack begin?

RED	.FILL	x7C00		;
GREEN	.FILL	x03E0

ROW	.FILL	3		; which row?
COLUMN	.FILL	8		; which column?

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

	;; SUBROUTINE
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
	LDR	R0,R5,#5		; row coord
	LDR	R1,R5,#4		; col coord
	
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