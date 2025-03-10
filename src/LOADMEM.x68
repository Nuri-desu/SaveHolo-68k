

LoadMemory
    ;A0 has the buffer on which the data will be loaded, A1 has the file name address, D0 has the data size in bytes
	MOVEM.L A0-A1, -(SP)
	MOVEM.L	D0-D2, -(SP)

	MOVE.L	D0, D2			;puts data size in the correct register

	MOVE.B 	#51, D0			;opens file by name on A1
	TRAP	#15

	MOVE.L 	#53, D0			;reads file and writes its bits into a buffer
	MOVE.L	A0, A1
	TRAP 	#15

	MOVE.B 	#56, D0			;closes file
	TRAP	#15

    MOVEM.L	(SP)+, D2-D0
	MOVEM.L (SP)+, A1-A0
	RTS						;returns

LoadStage
	
	MOVEM.L	A0-A3, -(SP)
	MOVEM.L	D0-D1, -(SP)
;fetch next stage
	LEA.L 	nameVector, A0	;get current stage name
	MOVE.B 	currStage, D0
	MULU.W 	#STGCHARNUM, D0
	ADDA 	D0, A0

	LEA 	collName, A1
	LEA 	BGname, A2
	LEA 	eName, A3

	MOVEQ 	#FILELENNAME+STGCHARNUM,D0
	ADDA 	D0, A3
	ADDA 	D0, A2
	ADDA 	D0, A1
	MOVEQ 	#STGCHARNUM-1, D0 ;loop setup
	ADDA 	D0, A0
.nameChange
	MOVE.B 	(A0), (A1)
	MOVE.B 	(A0), (A2)
	MOVE.B 	(A0), (A3)

	SUBA 	#1, A0
	SUBA 	#1, A1
	SUBA 	#1, A2
	SUBA 	#1, A3
	DBRA 	D0, .nameChange
;load stage
	LEA.L 	BGBuffer, A0
	LEA.L 	BGname, A1
	MOVE.L 	#SPRITESIZBG, D0
	JSR 	LoadMemory

	LEA.L 	collBuffer, A0
	LEA.L 	collName, A1
	MOVE.L 	#SIZEBGCOLL, D0
	JSR 	LoadMemory
;load entities
	LEA.L 	eBuff, A0
	LEA.L 	eName, A1
	MOVE.L 	#EMXBFFSIZ, D0
	JSR 	LoadMemory

	CMPI.B 	#-1, (A0)
	BEQ		endStageLoad

	CLR.W 	D1
	MOVE.L 	A0, A2

	LEA.L	eSpritBuff, A0
loadEnemiesSprites
	LEA.L 	.enemyJmpTblSL, A3
	MOVE.B 	(A2), D1
	ADDA.W 	D1, A3
	JMP 	(A3)
.enemyJmpTblSL:
    JMP 	EnemyTestSL
    JMP 	LaplusSL
endJumpTableSL
	ADDA.L 	#1, A2
	CMPI.B 	#-1, (A2)
	BNE		loadEnemiesSprites

endStageLoad
	MOVEM.L (SP)+, D1-D0
	MOVEM.L	(SP)+, A3-A0
	RTS

;Enemy loads
eTestFrame1 DC.B 'binFiles\slimeGoomba1.68kbmp', 0
			DS.W 0
eTestFrame2 DC.B 'binFiles\slimeGoomba2.68kbmp', 0
			DS.W 0
EnemyTestSL
	MOVE.B	(A2), D1
	LEA.L 	eSprtBffpt, A3
	MOVE.L 	A0, (A3,D1.W)

	LEA.L 	eTestFrame1, A1
	MOVE.L 	#SPRITESIZE, D0
	JSR 	LoadMemory

	ADDA.L 	#SPRITESIZE, A0

	LEA.L 	eTestFrame2, A1
	MOVE.L 	#SPRITESIZE, D0
	JSR 	LoadMemory

	ADDA.L 	#SPRITESIZE, A0

	JMP		endJumpTableSL

laplusF1 DC.B 'binFiles\laplus.68kbmp', 0
			DS.W 0
laplusF2 DC.B 'binFiles\laplusMove.68kbmp', 0
			DS.W 0
LaplusSL
	MOVE.B	(A2), D1
	LEA.L 	eSprtBffpt, A3
	MOVE.L 	A0, (A3,D1.W)

	LEA.L 	laplusF1, A1
	MOVE.L 	#SPRITESIZE, D0
	JSR 	LoadMemory

	ADDA.L 	#SPRITESIZE, A0

	LEA.L 	laplusF2, A1
	MOVE.L 	#SPRITESIZE, D0
	JSR 	LoadMemory

	ADDA.L 	#SPRITESIZE, A0

	JMP		endJumpTableSL

NextString
;A1 contains the string
	;CMPI.B 	#0, (A1)
	TST.B 	(A1)
	BEQ 	.end
	ADDA.L 	#1, A1
	BRA 	NextString
.end 
	ADDA.L 	#1, A1
	RTS