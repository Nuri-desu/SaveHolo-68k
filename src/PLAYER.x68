PMAXSPRITE	EQU 4
PACCELERAT	EQU 1
PMAXSPEED	EQU 8
PMAXHP		EQU 10 
PHCD 		EQU 16

PDRWXOFFST	EQU 3*PIXELMULT

STAGECD		EQU 4

playerX		DC.W 50
playerY		DC.W SCRNHGHT-150
playerHP	DC.B 3
PHBX		EQU 10
PHBY		EQU 16
pSpeedX 	DC.B 0
pSpeedY 	DC.B 0
pSprite		DC.B 0
pBooleans	DC.B %00000000	;0 = facing right
pColBool	DC.B %00000000	; prev stage | next stage | is on ground | is touching cealing | is touching right wall | is touching left wall | where stage index | where stage index	; where stage: 0 = left, 1 = up, 2 = right, 3 = down
pStageCd	DC.B STAGECD
			DS.W 0

pSprite1	DC.B 'binFiles\guatame.68kbmp',0
pSprite2	DC.B 'binFiles\guatameMove.68kbmp',0
pSprite3	DC.B 'binFiles\guatameFlip.68kbmp',0
pSprite4	DC.B 'binFiles\guatameMoveFlip.68kbmp',0
heartSprit 	DC.B 'binFiles\heart.68kbmp',0
			DS.W 0
PSPRITEBUF	DS.B PMAXSPRITE*SPRITESIZE
hspritBuff 	DS.B SPRITESIZE8
pCurrFrame 	DC.B 0
pHitCD 		DC.B PHCD
			DS.W 0

PlayerInit
	MOVE.L	D0, -(SP)
	MOVEM.L	A0-A1, -(SP)

	LEA.L 	PSPRITEBUF, A0		;Loads the sprite to ram
	MOVE.L 	#SPRITESIZE, D0
	LEA 	pSprite1, A1
	JSR 	LoadMemory

	ADDA.L 	#SPRITESIZE, A0		;Loads the sprite to ram
	LEA 	pSprite2, A1
	JSR 	LoadMemory

	ADDA.L 	#SPRITESIZE, A0		;Loads the sprite to ram
	LEA 	pSprite3, A1
	JSR 	LoadMemory

	ADDA.L 	#SPRITESIZE, A0		;Loads the sprite to ram
	LEA 	pSprite4, A1
	JSR 	LoadMemory

	LEA.L 	hspritBuff, A0		;Loads the sprite to ram
	MOVE.L 	#SPRITESIZE8, D0
	LEA 	heartSprit, A1
	JSR 	LoadMemory

	MOVEM.L	(SP)+, A1-A0
	MOVE.L	(SP)+, D0

	RTS

PlayerUpdate
	JSR 	PlayerMove
	JSR 	PlayerPhysics
	JSR 	PlayerEnviromentCollisons
	JSR 	SwitchStage

	CMPI.B 	#0, pHitCD
	BEQ 	.end

	SUBQ.B 	#1, pHitCD
.end
	RTS

PlayerDraw
	MOVE.L	A0, -(SP)
	MOVEM.L	D0-D2, -(SP)

	MOVE.W 	playerX, D1
	SUB.W 	#PDRWXOFFST, D1
	MOVE.W 	playerY, D2
	MOVE.B 	pSprite, D0

	LEA 	PSPRITEBUF, A0

	;Animations
	TST.B 	pSpeedX	
	BEQ 	.draw
	NOT.B 	pCurrFrame
	BTST 	#7, pSpeedX
	BEQ 	.right
;left
	ADDA.L 	#SPRITESIZE*2, A0
.right
	BTST 	#0, pCurrFrame
	BEQ		.draw
	ADDA.L 	#SPRITESIZE, A0
.draw
	MULU.W 	#SPRITESIZE, D0
	ADDA.W 	D0, A1		;points to the sprite by ID

	JSR 	DrawSprite16

	MOVEM.L	(SP)+, D2-D0
	MOVE.L	(SP)+, A0

	RTS

PlayerMove
	MOVEM.L	D0-D1, -(SP)

	; READ KEYS
    MOVE.B  #19,D0
    MOVE.L  #'E DA',D1
    TRAP    #15

    BTST	#0, D1
	BNE		.aPress	
	BTST	#8, D1
	BEQ		.jumpPress

;dPress
	OR.B 	#%00000001, pBooleans
	ADDQ.B 	#PACCELERAT*2, pSpeedX
	BRA		.jumpPress

.aPress
	AND.B 	#%11111110, pBooleans
	SUBQ.B 	#PACCELERAT*2, pSpeedX

.jumpPress
	BTST	#16, D1
	BEQ		.ePress	
	BTST	#5, pColBool
	BEQ		.ePress	

	;jump
	MOVE.B 	#-(PMAXSPEED+PMAXSPEED/2), pSpeedY

.ePress
	;BTST	#24, D1
	;TODO

	MOVEM.L	(SP)+, D1-D0
	RTS

PlayerPhysics
	MOVEM.L	D0-D4, -(SP)
	MOVE.B	pSpeedX, D0
	MOVE.B	pSpeedY, D1 
	MOVE.W	playerX, D2
	MOVE.W	playerY, D3 
	MOVE.B 	pColBool,D4

	CMPI.B 	#0, D0	;is there speed?
	BEQ		.checkY

	BTST	#2, D4 	;is there a wall on the left?
	BEQ		.checkRightWall
	BTST	#7, D0 	;is speed positive?
	BEQ		.checkRightWall
	CLR.B 	D0
	BRA 	.checkY

.checkRightWall
	BTST	#3, D4 	;is there a wall on the right?
	BEQ		.negativeCap
	BTST	#7, D0 	;is speed negative?
	BNE		.negativeCap
	CLR.B 	D0
	BRA 	.checkY

.negativeCap
	CMPI.B 	#-PMAXSPEED, D0	;cap speed
	BGE		.positiveCap

	MOVE.B 	#-PMAXSPEED, D0
.positiveCap
	CMPI.B 	#PMAXSPEED, D0	;cap speed
	BLE		.applySpeed

	MOVE.B 	#PMAXSPEED, D0
.applySpeed
	EXT.W 	D0
	ADD.W 	D0, D2	;apply speed
	;friction
	BTST	#15, D0
	BEQ		.frictionRight	
	;frictionLeft
	ADDQ.W 	#PACCELERAT, D0
	BRA		.checkY
.frictionRight
	SUBQ.W 	#PACCELERAT, D0
	;TODO
.checkY
	EXT.W 	D1		;this gave me so many headaches omfg
	BTST	#5, D4	;is on air?
	BEQ		.onAir
	;set speed to 0
	BTST 	#7, D1
	BNE 	.applyYSpeed
	MOVE.W 	#0, D1
	BRA 	.endPlayerPhysics
.onAir
	ADDQ.W 	#PACCELERAT, D1

	CMPI.W 	#PMAXSPEED, D1	;cap speed
	BLE		.applyYSpeed

	MOVE.W 	#PMAXSPEED, D1
.applyYSpeed
	ADD.W 	D1, D3
.endPlayerPhysics
	MOVE.B	D0, pSpeedX
	MOVE.B	D1, pSpeedY
	MOVE.W	D2, playerX
	MOVE.W	D3, playerY
	MOVEM.L	(SP)+, D4-D0

	RTS

PlayerEnviromentCollisons
	MOVEM.L	D0-D4, -(SP)
	MOVE.L 	A0, -(SP)
	MOVE.W	playerX, D0
	LSR.W 	#2, D0		;pointer on correct position
	MOVE.W	playerY, D1 
	LSR.W 	#2, D1		;pointer on correct position
	MOVEQ	#PHBX, D2
	MOVEQ	#PHBY, D3

	CMPI.W 	#SCRNWDTH/4, D0
	BLO		.contX
	CLR.W 	D0
.contX
	CMPI.W 	#SCRNWDTH/4, D1
	BLO		.contY
	CLR.W 	D1
.contY
	ADD.B 	D2, D0
	CMPI.W 	#SCRNWDTH/4, D0
	BLO		.contXm
	MOVE.B 	#SCRNWDTH/4 ,D0
.contXm
	SUB.B 	D2, D0
	ADD.B 	D3, D1
	CMPI.W 	#SCRNHGHT/4, D1
	BLO		.contYm
	MOVE.B 	#SCRNHGHT/4, D1
.contYm
	SUB.B 	D3, D1

	MOVE.B 	#0, D4		;current collisions

	LEA.L 	collBuffer, A0	;collision buffer
	MULU.W 	#SPRITDIMBGX, D1
	ADD.W 	D1, D0
	ADDA.W 	D0, A0			;pointer to ini pos

	CLR.W 	D0			;indexX
	CLR.W 	D1			;indexY

loopCollisions
	OR.B 	(A0), D4
;next x
	ADDA 	#1, A0		;next pixel
	ADDQ.W 	#1, D0

	CMP 	D2, D0
	BLO 	loopCollisions
	
;next y
	ADDA 	#SPRITDIMBGX, A0		;next row
	SUBA	D2, A0
	CLR.W 	D0
	ADDQ.W 	#1, D1

	CMP 	D3, D1
	BLO     loopCollisions

	MOVE.B 	D4, pColBool
	MOVE.L 	(SP)+, A0
	MOVEM.L	(SP)+, D4-D0 
	RTS

SwitchStage
	CMPI.B 	#0, pStageCd
	BNE 	.subColdDown

	MOVE.L	D0, -(SP)
	
	MOVE.B 	pColBool, D0

	BTST 	#7, D0
	BEQ 	.nextStage
.prevStage
	SUBQ.B 	#1, currStage
	BRA 	.warp
.nextStage
	BTST 	#6, D0
	BEQ 	.endSwitchStage
	ADDQ.B 	#1, currStage

	CMPI.B 	#7, currStage
	BEQ 	Ending

.warp
	JSR 	LoadStage

	MOVE.B 	#STAGECD, pStageCd ;adds cold down to switching stage

	AND.B 	#$03, D0

	;CMPI.B 	#0, D0
	TST.B 	D0
	BEQ 	.leftWarp
	CMPI.B 	#1, D0
	BEQ 	.upWarp
	CMPI.B 	#2, D0
	BEQ 	.rightWarp
;downWrap
	MOVE.W 	#SCRNHGHT-(PIXELMULT*SPRITEDIM), playerY
	BRA 	.endSwitchStage
.leftWarp
	MOVE.W 	#PIXELMULT, playerX
	BRA 	.endSwitchStage
.upWarp
	MOVE.W 	#PIXELMULT, playerY
	BRA 	.endSwitchStage
.rightWarp
	MOVE.W 	#SCRNWDTH-(PIXELMULT*SPRITEDIM), playerX
.endSwitchStage
	MOVE.L	(SP)+, D0
	RTS
.subColdDown
	SUBQ.B 	#1, pStageCd
	RTS

PlayerHit
	CMPI.B 	#0, pHitCD
	BNE 	.end

	SUBQ.B 	#1, playerHP

	CMPI.B 	#0, playerHP
	BLE 	.die

	MOVE.B 	#-PMAXSPEED, pSpeedY
	MOVE.B 	#PHCD, pHitCD
.end
	RTS
.die
	JMP 	GameOver

PlayerHPDraw
	MOVEM.L D0-D2, -(SP)
	MOVE.L 	A0, -(SP)

	MOVE.B	playerHP, D0
	SUBQ.B 	#1, D0
	LEA.L 	hspritBuff, A0
	CLR.W 	D1
	CLR.W 	D2
.loop
	JSR		DrawSprite8
	ADDI.W 	#9*4, D1
	DBRA 	D0, .loop

	MOVE.L 	(SP)+, A0
	MOVEM.L (SP)+, D2-D0
	RTS