*-----------------------------------------------------------
* Title      : Save ホロプロ！
* Description: m68K hololive themed game
*-----------------------------------------------------------
SCRNWDTH	EQU 640
SCRNHGHT	EQU 480

PIXELMULT	EQU	4
PSTRNCMSK	EQU $FFFC

SPRITEDIM 	EQU 16
SPRITEDIM8	EQU 8
SPRITESIZE8 EQU SPRITEDIM8*SPRITEDIM8*4
SPRITESIZE 	EQU SPRITEDIM*SPRITEDIM*4
MAXSPRITES	EQU 4

SPRITDIMBGX EQU 640/PIXELMULT
SPRITDIMBGY EQU 480/PIXELMULT
SPRITESIZBG EQU SPRITDIMBGX*SPRITDIMBGY*4
SIZEBGCOLL 	EQU SPRITDIMBGX*SPRITDIMBGY

STGCHARNUM	EQU 4
FILELENNAME EQU 8
	
	ORG    $1000

	INCLUDE "ENTITIEHEAD.x68"
	INCLUDE "LOADMEM.x68"
	INCLUDE	"DRAW.x68"
	INCLUDE "CINEMATICS.x68"
	INCLUDE	"PLAYER.x68"
	INCLUDE "ENTITIES.x68"

START:		; first instruction of program

	; SET WINDOWED MODE
	MOVE.B	#33,D0
	MOVE.L	#1,D1
	TRAP	#15

	; SET RESOLUTION
	MOVE.L	#SCRNWDTH<<16|SCRNHGHT,D1
	TRAP	#15

	; SET DOUBLE BUFFER
	MOVE.B	#92,D0
	MOVE.L	#17,D1
	TRAP	#15

	LEA.L 	cinIni, A1
	JSR		Cinematic

	;Set origin
	CLR.L 	D1

	;Load stage
	JSR		LoadStage

	;draw
	JSR		PlayerInit
.looptest
	LEA.L 	BGBuffer, A0
	JSR		DrawBackground

	; game
	JSR 	PlayerUpdate
	JSR 	ProcessEnemies
	JSR 	PlayerDraw
	JSR 	PlayerHPDraw
	
	; repaint
	MOVE.B	#94,D0
	TRAP	#15

	BRA .looptest

Ending
	LEA.L	cinFin, A1
	JSR		Cinematic
	JMP 	GameOver
	SIMHALT             ; halt simulator


currStage	DC.B 0
			DS.W 0
BGBuffer	DS.B SPRITESIZBG
			DS.W 0
collBuffer	DS.B SIZEBGCOLL
			DS.W 0
nameVector	DC.B 'lvl1','lvl2','lvl3','lvl4','lvl5','lvl6','lvl7'
			DS.W 0
collName	DC.B 'binFiles\lvl1.68kcol',0
			DS.W 0
BGname   	DC.B 'binFiles\lvl1.68kbmp',0
			DS.W 0

    END    START        
