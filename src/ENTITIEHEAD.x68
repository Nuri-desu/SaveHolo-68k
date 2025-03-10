TPSOFENEM	EQU 2

MAXENEMIES 	EQU 6
EMXBFFSIZ 	EQU 13*MAXENEMIES

;booleans ;0000000 ; bit 7: facing left | bits 5,4,3,2,1,0 frame animation

EHCD 	EQU 3
entityHitCD 	DC.B 0

eName		DC.B 'binFiles\0000.68kent',0
			DS.W 0
eBuff 		DS.B EMXBFFSIZ
			DS.W 0
eSpritBuff 	DS.B SPRITESIZE*MAXENEMIES*2
			DS.W 0
eSprtBffpt	DS.B TPSOFENEM*6 ; the 6 is because is stored in longs and theres 2 byte padding
			DS.W 0
;eColBool	DC.B %00000000	; prev stage | next stage | is on ground | is touching cealing | is touching right wall | is touching left wall | where stage index | where stage index	; where stage: 0 = left, 1 = up, 2 = right, 3 = down