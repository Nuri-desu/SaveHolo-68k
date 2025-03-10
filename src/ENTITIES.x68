;look header
ProcessEnemies
    MOVE.L 	A1, -(SP)

	LEA.L 	eBuff, A1
	ADDA.L 	#MAXENEMIES, A1

	CMPI.B 	#-1, (A1)
	BEQ		endEnemyProcess

	MOVE.L 	A0, -(SP)
	MOVEM.L D0-D7, -(SP)
	CLR.W 	D0
enemyProcessLoop
	LEA.L 	.enemyJumpTable, A0
	MOVE.B	(A1), D0
	ADDA.W 	D0, A0
	JMP		(A0)
.enemyJumpTable: ;A1 has to contain multiples of 6
    JMP 	EnemyTest
    JMP 	Laplus
enemiesJumpTableEnd
	ADDA.L 	#1, A1
	CMPI.B 	#-1, (A1)
	BNE		enemyProcessLoop
;end
	MOVEM.L (SP)+, D7-D0
	MOVE.L 	(SP)+, A0
endEnemyProcess

	;CMPI.B 	#0, entityHitCD
	TST.B 	entityHitCD
	BEQ 	.end
	SUBQ.B 	#1, entityHitCD

.end
    MOVE.L 	(SP)+, A1
    RTS

EnemyCheckCollisions
;D0 will return the collision booleans, D1 has to contain enemy x position, D2 has to contain enemy y position,  D3 has to contain enemy x hitbox, D4 has to contain enemy y hitbox
	MOVEM.L D1-D2, -(SP)

	LSR.W 	#2, D1		;pointer on correct position
	LSR.W 	#2, D2		;pointer on correct position
	MOVE.B 	#0, D0		;current collisions

	CMP.W 	#SCRNWDTH/4, D1
	BLO		.continueX
	CLR.W 	D1
.continueX
	CMP.W 	#SCRNWDTH/4, D2
	BLO		.continueY
	CLR.W 	D2
.continueY
	ADD.B 	D3, D1
	CMP.W 	#SCRNWDTH/4, D1
	BLO		.continueXm
	MOVE.W 	#SCRNWDTH/4 ,D1
.continueXm
	SUB.B 	D3, D1
	ADD.B 	D4, D2
	CMPI.W 	#SCRNHGHT/4, D2
	BLO		.continueYm
	MOVE.W 	#SCRNHGHT/4, D2
.continueYm
	SUB.B 	D4, D2

	LEA.L 	collBuffer, A0	;collision buffer
	MULU.W 	#SPRITDIMBGX, D2	
	ADD.W 	D2, D1
	ADDA.L 	D1, A0			;pointer to ini pos

	CLR.W 	D1			;indexX
	CLR.W 	D2			;indexY

.loopColl
	OR.B 	(A0), D0
;next x
	ADDA.L	#1, A0		;next pixel
	ADDQ.B 	#1, D1

	CMP.B	D3, D1
	BLO		.loopColl
	CLR.B 	D1
	ADDQ.B 	#1, D2
	SUBA	D3, A0
	ADDA 	#SPRITDIMBGX, A0
	CMP 	D4, D2
	BLO     .loopColl

	MOVEM.L (SP)+, D2-D1
	RTS

GroundEnemyPhysics
	BTST  	#3, D0 ;check for right wall
	BEQ		.checkLeftWall
	AND.B 	#%01111111, D6
	BRA 	.moveLeft
.checkLeftWall
	BTST  	#2, D0 ;check for left wall
	BEQ		.move
	OR.B 	#%10000000, D6
	BRA.S 	.moveRight
.move
	BTST  	#7, D6 	;right
	BEQ 	.moveLeft
.moveRight
	CMPI.W 	#SCRNWDTH, D1
	BLO		.applyRigMove
	AND.B 	#%01111111, D6
	SUBQ.W	#ENEMYTSPD, D1
	BRA 	.fall
.applyRigMove
	ADDQ.W	#ENEMYTSPD, D1
	BRA 	.fall
.moveLeft
	BTST 	#15, D1
	BEQ		.applyLeftMove
	OR.B 	#%10000000, D6
	ADDQ.W	#ENEMYTSPD, D1
	BRA 	.fall
.applyLeftMove
	SUBQ.W	#ENEMYTSPD, D1
.fall
	EXT.W 	D5		;this gave me so many headaches omg
	BTST	#5, D0	;is on air?
	BEQ		.onAir
	;set speed to 0
	BTST 	#7, D5
	BNE 	.applyYSpeed
	MOVE.W 	#0, D5
	BRA 	.endPhysics
.onAir
	ADDQ.W 	#ENEMYTACC, D5

	CMPI.W 	#ENEMYTSPD*3, D5	;cap speed
	BLE		.applyYSpeed

	MOVE.W 	#ENEMYTSPD, D5
.applyYSpeed
	ADD.W 	D5, D2
.endPhysics
	RTS

BossPhysics
	CMP.W 	playerX, D1
	BLO 	.right
;left
	SUBQ.W 	#LAPLUSSPD, D1
	BRA 	.fall
.right
	ADDQ.W 	#LAPLUSSPD, D1
.fall
	EXT.W 	D5		;this gave me so many headaches omg
	BTST	#5, D0	;is on air?
	BEQ		.onAir
	;ground
	MOVE.W 	playerY, D7
	ADDI.W 	#(SPRITEDIM/2)*4, D7
	CMP.W 	D7, D2
	BLO 	.contFall
	MOVE.W 	#-16, D5 ;jump
.contFall
	BTST 	#7, D5
	BNE 	.applyYSpeed
	MOVE.W 	#0, D5
	BRA 	.endPhysics
.onAir
	ADDQ.W 	#LAPLUSSPD, D5

	CMPI.W 	#LAPLUSSPD*3, D5	;cap speed
	BLE		.applyYSpeed

	MOVE.W 	#LAPLUSSPD, D5
.applyYSpeed
	ADD.W 	D5, D2
.endPhysics
	RTS

EnemyPlayerCollision
;D1 has to contain enemy x position, D2 has to contain enemy y position,  D3 has to contain enemy x hitbox, D4 has to contain enemy y hitbox
	;CMPI.B 	#0, entityHitCD
	TST.B 	entityHitCD
	BEQ 	.continue
	RTS
.continue
	MOVEM.L D0-D5, -(SP)

	MOVE.W 	playerX, D5
	MOVE.W 	playerY, D0

	ADDI.W 	#PHBX*2, D5
	ADDI.W 	#PHBY*2, D0

	LSL.B	#1, D3
	LSL.B	#1, D4

	ADD.W 	D3, D1
	ADD.W 	D4, D2

	SUB.W 	D1, D5
	SUB.W 	D2, D0
	BTST 	#15, D5
	BEQ 	.posX
	NOT.W 	D5
	ADDQ.W 	#1, D5
.posX
	BTST 	#15, D0
	BEQ 	.posY
	NOT.W 	D0
	ADDQ.W 	#1, D0
.posY
	ADDI.W 	#PHBX*2, D3
	CMP.W 	D3, D5
	BGT 	.end
	ADDI.W 	#PHBY*2, D4
	CMP.W 	D4, D0
	BGT 	.end

; player has been hit
	;CMPI.B 	#0, pSpeedY
	TST.B 	pSpeedY
	BLE 	.hit
	MOVE.B 	#-(PMAXSPEED+PMAXSPEED/2), pSpeedY
	SUBQ.B 	#1, (6, A1)
	ADDQ.B 	#1, playerHP
.hit
	JSR 	PlayerHit

	CMPI.B 	#PHCD, pHitCD
	BNE 	.end

	MOVE.B 	D6, D7
	AND.B 	#%01111111, D6
	OR.B 	#%10000000, D7
	NOT.B 	D7
	OR.B 	D7, D6 

.end
	MOVEM.L (SP)+, D5-D0
	RTS

BossPlayerCollision
;D1 has to contain enemy x position, D2 has to contain enemy y position,  D3 has to contain enemy x hitbox, D4 has to contain enemy y hitbox
	;CMPI.B 	#0, entityHitCD
	TST.B 	entityHitCD
	BEQ 	.continue
	RTS
.continue
	MOVEM.L D0-D5, -(SP)

	MOVE.W 	playerX, D5
	MOVE.W 	playerY, D0

	ADDI.W 	#PHBX*2, D5
	ADDI.W 	#PHBY*2, D0

	LSL.B	#1, D3
	LSL.B	#1, D4

	ADD.W 	D3, D1
	ADD.W 	D4, D2

	SUB.W 	D1, D5
	SUB.W 	D2, D0
	BTST 	#15, D5
	BEQ 	.posX
	NOT.W 	D5
	ADDQ.W 	#1, D5
.posX
	BTST 	#15, D0
	BEQ 	.posY
	NOT.W 	D0
	ADDQ.W 	#1, D0
.posY
	ADDI.W 	#PHBX*2, D3
	CMP.W 	D3, D5
	BGT 	.end
	ADDI.W 	#PHBY*2, D4
	CMP.W 	D4, D0
	BGT 	.end

; player has been hit
	;CMPI.B 	#0, pSpeedY
	TST.B 	pSpeedY
	BLE 	.hit
	MOVE.B 	#-(PMAXSPEED+PMAXSPEED/2), pSpeedY
	SUBQ.B 	#1, (6, A1)
.hit
	JSR 	PlayerHit
	
	MOVE.B 	#-8, pSpeedX

	CMPI.B 	#PHCD, pHitCD
	BNE 	.end

.end
	MOVEM.L (SP)+, D5-D0
	RTS
; ENEMY TEST LOGIC:
ENEMYTID	EQU 0 	

ENEMYTHBX   EQU 8
ENEMYTHBY   EQU 8
ENEMYTSPD	EQU 4
ENEMYTACC 	EQU 1

ENEMYTSIZ	EQU	9

EnemyTest
	;CMPI.B 	#0, (6, A1)
	TST.B 	(6, A1)
	BLE 	.end
	MOVE.W	(2, A1), D1
	MOVE.W	(4, A1), D2
    MOVE.B	#ENEMYTHBX, D3
	MOVE.B 	#ENEMYTHBY, D4
	JSR		EnemyCheckCollisions ;this gests the x pos on D1 the y pos on D2 and the collision booleans on D0 
	MOVE.B 	(7, A1), D5 ;y speed on D5
	MOVE.B	(1, A1), D6 ;bools on D6
	JSR		EnemyPlayerCollision
	JSR 	GroundEnemyPhysics

	LEA.L	eSprtBffpt, A0
	ADDA.L	#ENEMYTID, A0
	MOVE.L	(A0), A0

	ADDQ.B 	#1, D6	;adds to the animation timer
	BTST   	#4, D6
	BEQ		.drawCheck
	AND.B 	#%11000000, D6
;etDrawPlusChange
	NOT.B 	(8, A1)
	CMPI.B 	#-1, (8, A1)
	BNE		.draw
;nextFrame
	ADDA.L 	#SPRITESIZE, A0
	BRA 	.draw

.drawCheck
	CMPI.B 	#-1, (8, A1)
	BNE		.draw
	ADDA.L 	#SPRITESIZE, A0
.draw
	JSR		DrawSprite16

	;Endlogic
	MOVE.W 	D1, (2, A1)
	MOVE.W 	D2, (4, A1)
	MOVE.B 	D6, (1, A1)
	MOVE.B 	D5, (7, A1)
.end
	ADDA	#(ENEMYTSIZ), A1
	JMP		enemiesJumpTableEnd ;RTS
	
; ENEMY TEST LOGIC:
LAPLUSID	EQU 6

LAPLUSHBX   EQU 16
LAPLUSHBY   EQU 16
LAPLUSSPD	EQU 4
LAPLUSACC 	EQU 1

LAPLUSSIZ	EQU	9

Laplus
	;CMPI.B 	#0, (6, A1)
	TST.B 	(6, A1)
	BLE 	.end
	MOVE.W	(2, A1), D1
	MOVE.W	(4, A1), D2
    MOVE.B	#LAPLUSHBX, D3
	MOVE.B 	#LAPLUSHBY, D4
	JSR		EnemyCheckCollisions ;this gests the x pos on D1 the y pos on D2 and the collision booleans on D0 
	MOVE.B 	(7, A1), D5 ;y speed on D5
	MOVE.B	(1, A1), D6 ;bools on D6
	JSR		BossPlayerCollision
	JSR 	BossPhysics

	LEA.L	eSprtBffpt, A0
	ADDA.L	#LAPLUSID, A0
	MOVE.L	(A0), A0

	ADDQ.B 	#1, D6	;adds to the animation timer
	BTST   	#4, D6
	BEQ		.drawCheck
	AND.B 	#%11000000, D6
;etDrawPlusChange
	NOT.B 	(8, A1)
	CMPI.B 	#-1, (8, A1)
	BNE		.draw
;nextFrame
	ADDA.L 	#SPRITESIZE, A0
	BRA 	.draw

.drawCheck
	CMPI.B 	#-1, (8, A1)
	BNE		.draw
	ADDA.L 	#SPRITESIZE, A0
.draw
	JSR		DrawSprite16

	;Endlogic
	MOVE.W 	D1, (2, A1)
	MOVE.W 	D2, (4, A1)
	MOVE.B 	D6, (1, A1)
	MOVE.B 	D5, (7, A1)
.end
	ADDA	#(LAPLUSSIZ), A1
	JMP		enemiesJumpTableEnd ;RTS