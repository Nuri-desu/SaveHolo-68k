DrawSprite16
    ;A0 has the address of sprite to draw, D1.W has the X position and D2.W the Y
	MOVE.L 	A0, -(SP)
	MOVEM.L	D0-D7, -(SP)

	CLR.L	D5			;set "pointer" to 0
	CLR.L	D6

	AND.W 	#PSTRNCMSK,D1	;truncate X position
	AND.W 	#PSTRNCMSK,D2	;truncate Y position

.fetchPixel
	MOVE.L	(A0), D7	;pixel color
	BTST.L	#31, D7		;checks transparency
	BNE		.nextPixel

;DRAW PIXEL
	EOR.L 	D1, D7		;swap register contents
	EOR.L 	D7,	D1
	EOR.L 	D1,	D7
	MOVE.B 	#80, D0		;pen color
	TRAP	#15
	MOVE.B 	#81, D0		;fill color
	TRAP	#15

	MOVE.L 	D7, D1		;get positon back
	MOVE.B 	#87, D0		;drawRect
	MOVE.W 	D1, D3
	MOVE.W 	D2, D4
	ADDQ.W 	#PIXELMULT-1, D3
	ADDQ.W 	#PIXELMULT-1, D4
	TRAP	#15

.nextPixel
	ADDA 	#4, A0		;next pixel
	ADDQ.W 	#1, D5
	ADDQ.W 	#PIXELMULT, D1
	CMPI.W 	#SPRITEDIM, D5
	BLO		.fetchPixel
.nextY
	CLR.W	D5			;set "pointer" to 0
	SUBI.W 	#PIXELMULT*SPRITEDIM, D1
	ADDQ.W 	#1, D6
	ADDQ.W 	#PIXELMULT, D2
	CMPI.W 	#SPRITEDIM, D6
	BLO		.fetchPixel

;END OF SPRITE
	MOVEM.L	(SP)+, D7-D0
	MOVE.L 	(SP)+, A0
	RTS

DrawBackground
    ;A0 has the address of sprite to draw, D1.W has the X position and D2.W
	MOVE.L 	A0, -(SP)
	MOVEM.L	D0-D7, -(SP)

	CLR.L	D5			;set "pointer" to 0
	CLR.L	D6

	AND.W 	#PSTRNCMSK,D1	;truncate X position
	AND.W 	#PSTRNCMSK,D2	;truncate Y position

.fetchPixelBG
	MOVE.L	(A0), D7	;pixel color
	BTST.L	#31, D7		;checks transparency
	BNE		.nextPixelBG

;DRAW PIXEL
	EOR.L 	D1, D7		;swap register contents
	EOR.L 	D7,	D1
	EOR.L 	D1,	D7
	MOVE.B 	#80, D0		;pen color
	TRAP	#15
	MOVE.B 	#81, D0		;fill color
	TRAP	#15

	MOVE.L 	D7, D1		;get positon back
	MOVE.B 	#87, D0		;drawRect
	MOVE.W 	D1, D3
	MOVE.W 	D2, D4
	ADDQ.W 	#PIXELMULT-1, D3
	ADDQ.W 	#PIXELMULT-1, D4
	TRAP	#15

.nextPixelBG
	ADDA 	#4, A0		;next pixel
	ADDQ.W 	#1, D5
	ADDQ.W 	#PIXELMULT, D1
	CMPI.W 	#SPRITDIMBGX, D5
	BLO		.fetchPixelBG
.nextYBG
	CLR.W	D5			;set "pointer" to 0
	SUBI.W 	#PIXELMULT*SPRITDIMBGX, D1
	ADDQ.W 	#1, D6
	ADDQ.W 	#PIXELMULT, D2
	CMPI.W 	#SPRITDIMBGY, D6
	BLO		.fetchPixelBG

;END OF BACKGROUND
	MOVEM.L	(SP)+, D7-D0
	MOVE.L 	(SP)+, A0

	RTS

DrawSprite8
    ;A0 has the address of sprite to draw, D1.W has the X position and D2.W the Y
	MOVE.L 	A0, -(SP)
	MOVEM.L	D0-D7, -(SP)

	CLR.L	D5			;set "pointer" to 0
	CLR.L	D6

	AND.W 	#PSTRNCMSK,D1	;truncate X position
	AND.W 	#PSTRNCMSK,D2	;truncate Y position

.fetchPixel
	MOVE.L	(A0), D7	;pixel color
	BTST.L	#31, D7		;checks transparency
	BNE		.nextPixel

;DRAW PIXEL
	EOR.L 	D1, D7		;swap register contents
	EOR.L 	D7,	D1
	EOR.L 	D1,	D7
	MOVE.B 	#80, D0		;pen color
	TRAP	#15
	MOVE.B 	#81, D0		;fill color
	TRAP	#15

	MOVE.L 	D7, D1		;get positon back
	MOVE.B 	#87, D0		;drawRect
	MOVE.W 	D1, D3
	MOVE.W 	D2, D4
	ADDQ.W 	#PIXELMULT-1, D3
	ADDQ.W 	#PIXELMULT-1, D4
	TRAP	#15

.nextPixel
	ADDA 	#4, A0		;next pixel
	ADDQ.W 	#1, D5
	ADDQ.W 	#PIXELMULT, D1
	CMPI.W 	#SPRITEDIM8, D5
	BLO		.fetchPixel
.nextY
	CLR.W	D5			;set "pointer" to 0
	SUBI.W 	#PIXELMULT*(SPRITEDIM8), D1
	ADDQ.W 	#1, D6
	ADDQ.W 	#PIXELMULT, D2
	CMPI.W 	#SPRITEDIM8, D6
	BLO		.fetchPixel

;END OF SPRITE
	MOVEM.L	(SP)+, D7-D0
	MOVE.L 	(SP)+, A0
	RTS
