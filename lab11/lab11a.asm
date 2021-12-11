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

	LD	R0,ROW    		;
	ADD	R6,R6,#-1 		;
	STR	R0,R6,#0 		; push ROW

	LD	R0,COLUMN 		;
	ADD	R6,R6,#-1 		;
	STR	R0,R6,#0 		; push COLUMN

	LD	R0,RED    		;
	ADD	R6,R6,#-1		;	
	STR	R0,R6,#0 		; push RED

	JSR	DRAW_PIXEL 		; DRAW_PIXEL(ROW, COLUMN, RED) 
	ADD	R6,R6,#3		; remove parameters from stack frame

	LD	R0,BSIZE		;
	ADD	R6,R6,#-1  		;
	STR	R0,R6,#0  		; push BSIZE	

	LD	R0,BCOLOR		;
	ADD	R6,R6,#-1  		;
	STR	R0,R6,#0  		; push BCOLOR	

	LD	R0,BROW   		;
	ADD	R6,R6,#-1 		;	
	STR	R0,R6,#0 		; push BROW

	LD	R0,BCOLUMN 		;
	ADD	R6,R6,#-1  		;
	STR	R0,R6,#0  		; push BCOLUMN

	JSR	DRAW_BLK		; DRAW_BLOCK(BROW, BCOLUMN)
	ADD	R6,R6,#4		; remove parameters from stack frame

	LD	R0,B2SIZE		;
	ADD	R6,R6,#-1  		;
	STR	R0,R6,#0  		; push B2SIZE	

	LD	R0,B2COLOR		;
	ADD	R6,R6,#-1  		;
	STR	R0,R6,#0  		; push B2COLOR	

	LD	R0,B2ROW   		;
	ADD	R6,R6,#-1 		;	
	STR	R0,R6,#0 		; push B2ROW

	LD	R0,B2COL		;
	ADD	R6,R6,#-1  		;
	STR	R0,R6,#0  		; push B2COLUMN

	JSR	DRAW_BLK		; DRAW_BLOCK(BROW, BCOLUMN)
	ADD	R6,R6,#4		; remove parameters from stack frame

	LD	R0,B3SIZE		;
	ADD	R6,R6,#-1  		;
	STR	R0,R6,#0  		; push B3SIZE	

	LD	R0,RED		;
	ADD	R6,R6,#-1  		;
	STR	R0,R6,#0  		; push red	

	LD	R0,B3ROW   		;
	ADD	R6,R6,#-1 		;	
	STR	R0,R6,#0 		; push B3ROW

	LD	R0,B3COL		;
	ADD	R6,R6,#-1  		;
	STR	R0,R6,#0  		; push B3COLUMN

	JSR	DRAW_BLK		; DRAW_BLOCK(BROW, BCOLUMN)
	ADD	R6,R6,#4		; remove parameters from stack frame

STOP   	HALT

TOP	.FILL	x6000			; where does the stack begin?

ROW	.FILL	4			; which pixel row?
COLUMN	.FILL	8			; which pixel column?
RED	.FILL	x7C00			; desired color for pixel

BROW	.FILL	3			; which block row?
BCOLUMN	.FILL	8			; which block column?
BCOLOR  .FILL   x03E0			; What block color?
BSIZE	.FILL	3			; What size block?

B2ROW	.FILL	0			
B2COL	.FILL	4
B2COLOR .FILL   xF19C
B2SIZE	.FILL	8

B3ROW	.FILL	1
B3COL	.FILL   1
B3SIZE	.FILL	30
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
	LDR	R3,R5,#-4
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
	
	.END