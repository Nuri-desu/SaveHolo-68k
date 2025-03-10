Cinematic
;cinematic starts on A1
	MOVEM.L	D0-D2, -(SP)
	MOVE.L 	A0, -(SP)

	CLR.W 	D1
	CLR.W 	D2

	LEA.L 	BGBuffer, A0
	MOVE.L 	#SPRITESIZBG, D0
	JSR 	LoadMemory

	JSR 	DrawBackground
	MOVE.B	#94,D0	; repaint
	TRAP	#15

	MOVE.B  #19, D0
	BRA 	.loop1

.drawNext
	JSR 	NextString
	CMPI.B 	#-1, (A1)
	BEQ		.end

	LEA.L 	BGBuffer, A0
	MOVE.L 	#SPRITESIZBG, D0
	JSR 	LoadMemory
	CLR.W 	D1
	JSR 	DrawBackground
	MOVE.B	#94,D0	; repaint
	TRAP	#15

	MOVE.B  #19, D0
.loop1
    MOVE.L  #'    ', D1
    TRAP    #15

	BTST 	#0, D1
	BEQ		.loop1

.loop2
	MOVE.L  #'    ',D1
    TRAP    #15

	BTST 	#0, D1
	BNE		.loop2
	BRA 	.drawNext
.end
	MOVE.L 	(SP)+, A0
    MOVEM.L (SP)+, D2-D0
	RTS

GameOver
	LEA.L 	BGBuffer, A0
	LEA.L 	endCin, A1
	MOVE.L 	#SPRITESIZBG, D0
	JSR 	LoadMemory
	CLR.W 	D1
	CLR.W 	D2
	JSR 	DrawBackground
	MOVE.B	#94,D0	; repaint
	TRAP	#15
	SIMHALT

cinIni	DC.B 'binFiles\cin1.68kbmp',0,'binFiles\cin2.68kbmp',0,'binFiles\cin3.68kbmp',0,'binFiles\cin4.68kbmp',0,'binFiles\cin5.68kbmp',0,'binFiles\cin6.68kbmp',0,'binFiles\cin7.68kbmp',0,-1
cinFin	DC.B 'binFiles\cfi1.68kbmp',0,'binFiles\cfi2.68kbmp',0,'binFiles\cfi3.68kbmp',0,'binFiles\cfi4.68kbmp',0,-1

endCin 	DC.B 'binFiles\cend.68kbmp',0
