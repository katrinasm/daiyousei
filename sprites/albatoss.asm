;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Albatoss, by mikeyk
;;
;; Description: This is a flying bird that can drop Bob-ombs.
;;
;; Uses first extra bit: YES
;; If the first extra bit is set, the Albatoss will drop Bob-ombs
;;
;; Extra Property Byte 1
;;    bit 0 - enable spin killing (if ridable)
;;    bit 2 - pause when dropping bob-ombs
;;    bit 4 - drop next sprite instead of bob-omb
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%dys_offsets(Main, !ssr_FacePlayer)

;==============================================================================;
; Constants                                                                    ;
;==============================================================================;
	!timeTillDrop    = $64
	!timeTillExplode = $58
	!timeToPause     = $18
	
;==============================================================================;
; Rename labels                                                                ;
;==============================================================================;
	!dropTimer = !spr_timeA
	!rideTimer = !spr_timeB

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite main code 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

X_SPEED:        db $10, -$10
KILLED_X_SPEED: db -$10, $10

RETURN:
	rtl
Main:
	jsr SPRITE_GRAPHICS
	lda !spr_status,x : cmp #$08 : bne RETURN
	jsl !ssr_Offscreen_X0

	lda !spr_extraBit,x
	and #$04
	beq MOVE

	lda !dropTimer,x : cmp.b #!timeToPause : bcs MOVE
	cmp #$00 : bne NO_RESET3
	lda.b #!timeTillDrop : sta !dropTimer,x
	
NO_RESET3:
	cmp #$01 : bne DONT_DROP
	jsr SUB_HAMMER_THROW

DONT_DROP:
	stz !spr_spdX,x
	
	lda !spr_xProps1,x : and #$04 : bne DONT_MOVE
MOVE:
	; set x speed based on direction
	ldy !spr_facing,x : lda X_SPEED,y : sta !spr_spdX,x
	lda $9d : bne RETURN
	
DONT_MOVE:
	stz !spr_spdY,x
	jsl !ssr_Move
	; flip direction if sprite is contact with an object
	lda !spr_blocked,x : and #$03 : beq NO_CONTACT
	lda !spr_facing,x : eor #$01 : sta !spr_facing,x

NO_CONTACT:        
	jsl !ssr_CollidePlayer : bcc RETURN_24
	; if mario isn't above sprite, and there's vertical contact, sprite wins
	jsl !ssr_VertPos
	lda $0e : cmp #$e6 : bpl SPRITE_WINS
	; if mario speed is upward, return
	lda $7d : bmi RETURN_24

	; if mario is spin jumping and the sprite is set for it, die on spinjump
	lda !spr_xProps1,x : and #$01 : beq SPIN_KILL_DISABLED
	lda $140d : bne SPIN_KILL

SPIN_KILL_DISABLED:
	lda #$01 : sta $1471
	lda #$06 : sta !rideTimer,x
	stz $7d
	; Set Mario’s Y postion to $e1/$d1 depending on Yoshi
	lda #$e1 : ldy $187a : beq NO_YOSHI
	lda #$d1 
NO_YOSHI:
	clc : adc !spr_posYL,x : sta $96
	; Set Mario’s X position
	lda !spr_posXH,x : adc #$ff : sta $97
	ldy #$00
	lda $1491 : bpl +
	dey
+	clc : adc $94 : sta $94
	tya : adc $95 : sta $95
RETURN_24B:
	rtl

SPRITE_WINS:
	lda !rideTimer,x : ora !spr_beingEaten,x : bne RETURN_24
	lda $1490 : bne HAS_STAR : jsl !ssr_HurtPlayer
RETURN_24:
	rtl

SPIN_KILL:
	jsl !ssr_StompPoints
	jsl $01ab99!F
	lda #$04 : sta !spr_status,x
	lda #$1f : sta !spr_timeA,x
	jsl $07fc3b!F
	lda #$08 : sta $1df9
	rtl

HAS_STAR:
	lda #$02 : sta !spr_status,x
	lda #$d0 : sta !spr_spdY,x
	jsl !ssr_HorizPos : lda KILLED_X_SPEED,y : sta !spr_spdX,x
	jml !ssr_StarPoints

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; hammer routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

X_OFFSET:  db $0A,$07
X_OFFSET2: db $00,$00
!Y_OFFSET = $0C

RETURN68:
	rts
SUB_HAMMER_THROW:
	lda !spr_offscreenH,x : ora !spr_offscreenV,x : ora !spr_beingEaten,x : bne RETURN68
	
	lda !spr_xProps1,x : and #$10 : beq .bobomb
	
	lda !spr_extraBit,x : sta $01
	lda !spr_custNum,x : inc : sta $00
	bra +
	
.bobomb	
	lda #$00 : sta $01
	lda #$0d : sta $00
	
+	jsl !ssr_SpawnSprite
	
	; set x pos for dropped sprite
	phy
	lda !spr_facing,x : tay
	lda !spr_posXL,x : clc : adc X_OFFSET,y
	ply
	sta.w !spr_posXL,y
	phy
	lda !spr_facing,x : tay
	lda !spr_posXH,x : clc : adc X_OFFSET2,y
	ply
	sta.w !spr_posXH,y
	
	; set y pos for dropped sprite
	lda !spr_posYL,x : clc : adc.b #!Y_OFFSET : sta.w !spr_posYL,y
	lda !spr_posYH,x : adc #$00 : sta.w !spr_posYH,y
	
	; initialize other tables for the dropped sprite
	phy : phx
	tyx
	jsl !ssr_FacePlayer
	plx : ply
	
	lda #$0c : sta.w !spr_timeD,y
	lda !spr_xProps1,x : and #$10 : bne RETURN67
	lda.b #!timeTillExplode : sta.w !spr_timeA,y
RETURN67:
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TILEMAP:
; Each row is one frame
	db $06,$0a
	db $0e,$20
	db $22,$24
	db $26,$28
	db $40,$42
	db $44,$46
	db $48,$4a
	db $4e,$64
	
; Left is bob-omb, right is ‘next sprite’
bombTiles:
	db $ca, $2d
bombProps:
	db $05, $05
	
SPRITE_GRAPHICS:
	lda !spr_status,x : cmp #$02 : bne NO_STAR
	lda !spr_tileProps,x : ora #$80 : sta !spr_tileProps,x
NO_STAR:
	lda $14 : lsr #4 : clc : adc $15e9 : and #$07 : tay
	rep #$20
	lda.w #TILEMAP
	jsl !ssr_GenericGfx_32x16

; All this junk seems to be for the Bob-omb.
	lda !spr_status,x : cmp #$08 : bne NO_SHOW
	lda !dropTimer,x : cmp #$20 : bcs NO_SHOW
	cmp #$01 : bcc NO_SHOW
	bra SHOW
NO_SHOW:
	rts

SHOW:
	lda !spr_facing,x : sta $02
	lda !spr_oamIndex,x : clc : adc #$08 : sta !spr_oamIndex,x
	jsl !ssr_GetDrawInfo
	lda $00                 ; tile x position = sprite x location ($00)
	phx
	ldx $02
	clc
	adc X_OFFSET,x
	plx
	sta !oam1_ofsX,y  
	
	lda $01                 ; tile y position = sprite y location ($01)
	clc
	adc.b #!Y_OFFSET
	sta !oam1_ofsY,y  
	
	phy
	ldy #$00
	lda !spr_xProps1,x : and #$10 : beq +
	iny
+	lda bombTiles,y
	sta $03
	lda bombProps,y
	sta $04
	ply
	lda $03 : sta !oam1_tile,y    
	
	lda $04
	phx
	ldx $02
	bne NO_FLIP2
	ora #$40
NO_FLIP2:
	plx
	ora $64                 ; add in tile priority of level
	sta !oam1_props,y      

	ldy #$02                ; \ FF, because we wrote to 460
	lda #$00                ;  | A = number of tiles drawn - 1
	jsl !ssr_FinishOamWrite ; / don't draw if offscreen
	rts                     ; return                    
