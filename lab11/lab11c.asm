	;; 
	;; Author: Bill Slough
	;;
	;; Invoking subroutines with stack frames
	;;
	;; Draws rectangles of varying sizes
	;; 

	.ORIG x3000

	;; Main program...............................................................

START	LD	R6,TOP  		; initialize stack pointer
	AND	R5,R5,#0		; frame pointer = null

	LEA	R0,P    		; i = 0
	LEA	R1,Q
LOOP0	LEA	R2,P_END		; while (corner points remain)
	NOT	R2,R2    		;
	ADD	R2,R2,#1 		;
	ADD	R2,R0,R2 		; 
	BRz	ELOOP0

	LDR	R3,R0,#0 		;  
	ADD	R6,R6,#-1		;
	STR	R3,R6,#0		;   push P[i].row

	LDR	R3,R0,#1 		;
	ADD	R6,R6,#-1		;
	STR	R3,R6,#0		;   push P[i].column

	LDR	R3,R1,#0 		;
	ADD	R6,R6,#-1		;
	STR	R3,R6,#0		;   push Q[i].row

	LDR	R3,R1,#1  		;
	ADD	R6,R6,#-1 		;
	STR	R3,R6,#0		;   push Q[i].column

	LD	R3,RED  		;
	ADD	R6,R6,#-1		;
	STR	R3,R6,#0		;   push RED

	JSR	DRAW_RECT 		;   draw_rect(P[i].row, P[i].column,
	ADD	R6,R6,#5		;             Q[i].row, Q[i].column, RED)
	
	ADD	R0,R0,#2		;
	ADD	R1,R1,#2		;   i = i + 1
	BR	LOOP0                   ; end while
ELOOP0	
	LD	R6,TOP
	LD	R0,F_ROW
	ADD	R6,R6,#-1
	STR	R0,R6,#0		; push f row
	
	LD	R0,F_COL
	ADD	R6,R6,#-1
	STR	R0,R6,#0		; push f col

	LD	R0,BLACK
	ADD	R6,R6,#-1
	STR	R0,R6,#0		; push first color(black)

	LD	R0,RED
	ADD	R6,R6,#-1
	STR	R0,R6,#0		; push first color(black)

	JSR	FLOOD_FILL
	ADD	R6,R6,#4
STOP   	HALT

TOP	.FILL	xC000                   ; where does the stack begin?

RED	.FILL	x7C00                   ; desired color for rectangles
BLACK	.FILL	x0000
F_ROW	.FILL	50       		; where to start the flood fill...
F_COL	.FILL	50                     ; currently (6,11)

	;; P stores the coordinates of the upper-left corner points
P	.FILL	5		; (5, 10)
	.FILL	10		;
	.FILL	20		; (20, 40)
	.FILL	40		;
	.FILL	90		; (90, 90)
	.FILL	90		;
	.FILL	10		; (10, 60)
	.FILL	60		;
	.FILL	0		; (0, 0)
	.FILL	0
P_END	.FILL	-1

	;; Q stores the coordinates of the lower-right corner points
Q	.FILL	30		; (30, 50)
	.FILL	50		;
	.FILL	100		; (100, 100)
	.FILL	100		;
	.FILL	95		; (95, 120)
	.FILL	120		;
	.FILL	70		; (70, 80)
	.FILL	80		;
	.FILL	123		; (123, 127)
	.FILL	127
Q_END	.FILL	-1

	;; Subroutine ................................................................
DRAW_RECT
	;; Draw a rectangle, given the coordinates of opposing corner points
	;;
	;; Parameters:
	;; 	ULrow   (upper left corner)
	;; 	ULcol
	;; 	LRrow   (lower right corner)
	;; 	LRcol
	;; 	color   (desired color)
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
	;; 	+4  LRcolumn
	;; 	+5  LRrow
	;; 	+6  ULcolumn
	;; 	+7  ULrow

	;; PROLOG
	ADD	R6,R6,#-1 		;
	STR	R7,R6,#0  		; push return address

	ADD	R6,R6,#-1		;	
	STR	R5,R6,#0  		; push previous frame pointer

	ADD	R5,R6,#-1		; establish frame pointer for this frame

	STR	R0,R6,#-1		; save registers being used in this routine
	STR	R1,R6,#-2		;
	STR	R2,R6,#-3		;
	STR	R3,R6,#-4
	STR	R4,R6,#-5
	ADD	R6,R6,#-5		; adjust stack pointer to the top of the frame

	;; BODY
	;; Draw horizontal line segments 
	LDR	R3,R5,#7 		; R3 = ULrow
	LDR	R4,R5,#5		; R4 = LRrow
 
	LDR	R0,R5,#6 		; c = ULcolumn
LOOP1	LDR	R1,R5,#4		; while (c <= LRcolumn)
	NOT	R2,R0                   ;
	ADD	R2,R2,#1		;
	ADD	R1,R1,R2		;
	BRn	ELOOP1                  ;
BODY1
	ADD	R6,R6,#-1 		;   
	STR	R3,R6,#0		;    push ULrow

	ADD	R6,R6,#-1 		;
	STR	R0,R6,#0		;    push c

	LDR	R1,R5,#3 		;
	ADD	R6,R6,#-1		;
	STR	R1,R6,#0		;    push color 

	JSR	DRAW_PIXEL 		;    draw_pixel(ULrow, c, color)
	ADD	R6,R6,#3		;    remove parameters

	ADD	R6,R6,#-1 		;    
	STR	R4,R6,#0		;    push LRrow

	ADD	R6,R6,#-1 		;
	STR	R0,R6,#0		;    push c 

	ADD	R6,R6,#-1 		;
	STR	R1,R6,#0		;    push color

	JSR	DRAW_PIXEL 		;    draw_pixel(LRrow, c, color)
	ADD	R6,R6,#3		;

	ADD	R0,R0,#1 		;    c = c + 1
	BR	LOOP1   		; end while
ELOOP1
	;; Draw vertical line segments 
	LDR	R3,R5,#6 		; R3 = ULcolumn
	LDR	R4,R5,#4		; R4 = LRcolumn
 
	LDR	R0,R5,#7 		; r = ULrow
LOOP2	LDR	R1,R5,#5		; while (r <= LRrow)
	NOT	R2,R0                   ;
	ADD	R2,R2,#1		;
	ADD	R1,R1,R2		;
	BRn	ELOOP2                  ;
BODY2
	ADD	R6,R6,#-1 		;   
	STR	R0,R6,#0		;    push r

	ADD	R6,R6,#-1 		;
	STR	R3,R6,#0		;    push ULcolumn

	LDR	R1,R5,#3 		;
	ADD	R6,R6,#-1		;
	STR	R1,R6,#0		;    push color

	JSR	DRAW_PIXEL 		;    draw_pixel(r, ULcolumn, color)
	ADD	R6,R6,#3		;    remove parameters

	ADD	R6,R6,#-1 		;    
	STR	R0,R6,#0		;    push r

	ADD	R6,R6,#-1 		;
	STR	R4,R6,#0		;    push LRcolumn

	ADD	R6,R6,#-1 		;
	STR	R1,R6,#0		;    push color

	JSR	DRAW_PIXEL 		;    draw_pixel(r, LRcolumn, color)
	ADD	R6,R6,#3		;

	ADD	R0,R0,#1 		;    r = r + 1
	BR	LOOP2   		; end while
ELOOP2	
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

	;; GET PIXEL SUBROUTINE
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
	;; SUBROUTINE
FLOOD_FILL
	;;
	;; Parameters:
	;; 	row     -- a value between 0 and 123
	;; 	column  -- a value between 0 and 127
	;;	color1  -- First Color
	;; 	color2   -- Second Color
	;;
	;; Frame offsets:
	;; 	-4  saved R4
	;; 	-3  saved R3
	;; 	-2  saved R2
	;; 	-1  saved R1
	;; 	 0  saved R0
	;; 	+1  previous frame pointer
	;; 	+2  return address
	;; 	+3  color two
	;; 	+4  color one
	;; 	+5  col
	;;	+6  row

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

	LDR	R0,R5,#6   		;
	ADD	R6,R6,#-1 		;	
	STR	R0,R6,#0 		; push row

	LDR	R0,R5,#5		;
	ADD	R6,R6,#-1  		;
	STR	R0,R6,#0  		; push col

	JSR	GET_PIXEL
	LDR	R0,R6,#0
	ADD	R6,R6,#3
	LDR	R1,R5,#4
	NOT	R1,R1
	ADD	R1,R1,#1
	ADD	R0,R0,R1
	BRnp	RETURN

	LDR	R0,R5,#6
	ADD	R6,R6,#-1
	STR	R0,R6,#0		; push row
	LDR	R0,R5,#5		;
	ADD	R6,R6,#-1  		;
	STR	R0,R6,#0  		; push col
	LDR	R0,R5,#3		;
	ADD	R6,R6,#-1  		;
	STR	R0,R6,#0  		; push color2
	JSR	DRAW_PIXEL
	ADD	R6,R6,#3

	LDR	R0,R5,#6
	ADD	R6,R6,#-1
	STR	R0,R6,#0		; push row
	LDR	R0,R5,#5		;
	ADD	R6,R6,#-1  		;
	ADD	R0,R0,#-1
	STR	R0,R6,#0  		; push col-1
	LDR	R0,R5,#4		;
	ADD	R6,R6,#-1  		;
	STR	R0,R6,#0  		; push color1
	LDR	R0,R5,#3		;
	ADD	R6,R6,#-1  		;
	STR	R0,R6,#0  		; push color2
	JSR	FLOOD_FILL		; FLOODFILL	row, col-1, color1, color2
	ADD	R6,R6,#4
	
	LDR	R0,R5,#6
	ADD	R6,R6,#-1
	STR	R0,R6,#0		; push row
	LDR	R0,R5,#5		;
	ADD	R6,R6,#-1  		;
	ADD	R0,R0,#1
	STR	R0,R6,#0  		; push col+1
	LDR	R0,R5,#4		;
	ADD	R6,R6,#-1  		;
	STR	R0,R6,#0  		; push color1
	LDR	R0,R5,#3		;
	ADD	R6,R6,#-1  		;
	STR	R0,R6,#0  		; push color2
	JSR	FLOOD_FILL		; FLOODFILL	row, col+1, color1, color2
	ADD	R6,R6,#4

	LDR	R0,R5,#6
	ADD	R6,R6,#-1
	ADD	R0,R0,#-1
	STR	R0,R6,#0		; push row-1
	LDR	R0,R5,#5		;
	ADD	R6,R6,#-1  		;
	STR	R0,R6,#0  		; push col
	LDR	R0,R5,#4		;
	ADD	R6,R6,#-1  		;
	STR	R0,R6,#0  		; push color1
	LDR	R0,R5,#3		;
	ADD	R6,R6,#-1  		;
	STR	R0,R6,#0  		; push color2
	JSR	FLOOD_FILL		; FLOODFILL	row-1, col, color1, color2
	ADD	R6,R6,#4

	LDR	R0,R5,#6
	ADD	R6,R6,#-1
	ADD	R0,R0,#1
	STR	R0,R6,#0		; push row+1
	LDR	R0,R5,#5		;
	ADD	R6,R6,#-1  		;
	STR	R0,R6,#0  		; push col
	LDR	R0,R5,#4		;
	ADD	R6,R6,#-1  		;
	STR	R0,R6,#0  		; push color1
	LDR	R0,R5,#3		;
	ADD	R6,R6,#-1  		;
	STR	R0,R6,#0  		; push color2
	JSR	FLOOD_FILL		; FLOODFILL	row+1, col, color1, color2
	ADD	R6,R6,#4


RETURN	;; EPILOG
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