;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Birdo's Egg, by mikeyk
;;
;; Description
;: 
;; Note: When rideable, clipping tables values should be: 03 0A FE 0E
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Uses first extra bit: NO
;;
;; Extra Property Byte 1
;;    bit 0 - enable spin killing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%dys_offsets(Main, !ssr_FacePlayer)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite main code 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

X_SPEED:            db $20,-$20
KILLED_X_SPEED:     db -$10,$10

RETURN:
	rtl 
Main:
	jsr SPRITE_GRAPHICS
	lda !spr_status,x : cmp #$08 : bne RETURN
	jsl !ssr_Offscreen_X0
	ldy !spr_facing,x : lda X_SPEED,y : sta !spr_spdX,x
	lda $9d : bne RETURN
	
	stz !spr_spdY,x
	jsl !ssr_Move
	
	lda !spr_blocked,x : and #$03 : beq NO_CONTACT
	lda !spr_facing,x : eor #$01 : sta !spr_facing,x
NO_CONTACT:
	jsl !ssr_CollidePlayer : bcc RETURN_24
	jsl !ssr_VertPos
	lda $0f : cmp #$e6 : bpl SPRITE_WINS
	lda $7d : bmi RETURN_24
	lda !spr_xProps1,x : lsr : bcc SPIN_KILL_DISABLED
	lda !WB|$140d : bne SPIN_KILL
SPIN_KILL_DISABLED:
	lda #$01 : sta !WB|$1471
	lda #$06 : sta !spr_disableContact,x
	stz $7d

	lda #$e1
	ldy !WB|$187a : beq NO_YOSHI
	lda #$d1
NO_YOSHI:
	clc : adc !spr_posYL,x : sta $96
	lda !spr_posYH,x : adc #$ff : sta $97
	
	ldy #$00
	lda $77 : and #$03 : bne RETURN_24
	lda !WB|$1491 : bpl +
	dey
+	clc : adc $94 : sta $94
	tya
	adc $95
	sta $95
RETURN_24:
	rtl

SPRITE_WINS:
	lda !spr_disableContact,x : ora !spr_beingEaten,x : bne RETURN_24
	lda !WB|$1490 : bne HAS_STAR
	jml !ssr_HurtPlayer
	
SPIN_KILL:
	jsl !ssr_StompPoints
	jsl $01aa33!F
	jsl $01ab99!F
	lda #$04 : sta !spr_status,x
	lda #$1f : sta !spr_timeA,x
	jsl $07fc3b!F
	lda #$08 : sta !WB|$1df9
	rtl

HAS_STAR:
	lda #$02 : sta !spr_status,x
	lda #$d0 : sta !spr_spdY,x
	jsl !ssr_HorizPos
	lda KILLED_X_SPEED,y : sta !spr_spdX,x
	jml !ssr_StarPoints

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TILEMAP:
	db $8c, $8c
	
SPRITE_GRAPHICS:
	lda $14 : lsr #3 : clc : adc !dys_slot : and #$01 : tay
	rep #$20
	lda.w #TILEMAP
	jsl !ssr_GenericGfx_16x16
	rts
	