;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Beezo, by mikeyk
;;
;; (Daiyousei conversion by Katrina)
;; Description: 
;;
;; Note: When rideable, clipping tables values should be: 03 0A FE 0E
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Uses first extra bit: NO
;;
;; Extra Property Byte 1
;;    bit 0 - enable spin killing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%dys_offsets(MAIN, !ssr_FacePlayer)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite main code 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

X_SPEED:            db $10,$F0
KILLED_X_SPEED:     db $F0,$10

RETURN:
	rtl

MAIN:
SPRITE_CODE_START:
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
	jsl $01a7dc!F : bcc RETURN_24
	jsl !ssr_VertPos
    lda $0e : cmp #$e6 : bpl SPRITE_WINS
	lda $7d : bmi RETURN_24
	lda !spr_xProps1,x : lsr : bcc SPIN_KILL_DISABLED
	lda !WB|$140d : bne SPIN_KILL
	
SPIN_KILL_DISABLED:
	lda #$01 : sta !WB|$1471
	lda #$06 : sta !spr_timeB,x
	stz $7d
	; set mario's position relative to us (+$e1 if on yoshi, +$d1 otherwise)
	lda #$e1
	ldy $187a : beq NO_YOSHI
	lda #$d1
	
NO_YOSHI:
	clc : adc !spr_posYL,x
	sta $96
	lda !spr_posYH,x : adc #$ff : sta $97
	
	ldy #$00 : lda !WB|$1491 : bpl + : dey : +
	clc : adc $94 : sta $94
	tya : adc $95 : sta $95
	rtl
	
SPRITE_WINS:
	lda !spr_timeB,x : ora !spr_beingEaten,x : bne RETURN_24
	lda !WB|$1490 : bne HAS_STAR
	jml $00f5b7!F
RETURN_24:
	rtl

SPIN_KILL:
	jsl !ssr_StompPoints
	jsl $01aa33!F           ; set mario speed for bounce
	jsl $01ab99!F           ; display spinkill cloud
	lda #$04 : sta !spr_status,x
	lda #$1f : sta !spr_timeA,x
	
	jsl $07fc3b!F           ; "show star animation"?
	lda #$08 : sta !WB|$1df9    ; sfx
	rtl
	
HAS_STAR:
	lda #$02 : sta !spr_status,x
	lda #$d0 : sta !spr_spdY,x
	jsl !ssr_HorizPos : lda KILLED_X_SPEED,y : sta !spr_spdX,x
	jsl !ssr_StarPoints
	rtl

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TILEMAP:
	db $c4,$c6
	
SPRITE_GRAPHICS:
	lda $14 : lsr #2 : clc : adc !dys_slot : and #$01 : tay
	lda !spr_status,x : cmp #$02 : bne +
	ldy #$00
+	rep #$20
	lda.w #TILEMAP
	jsl !ssr_GenericGfx_16x16
	rts
