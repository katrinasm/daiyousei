;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; YI Shy Guy, by mikeyk
;;
;; Description: 
;;
;; Note: When rideable, clipping tables values should be: 03 0A FE 0E
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Uses first extra bit: NO
;;
;; Extra Property Byte 1
;;    bit 0 - enable spin killing
;;    bit 1 - stay on ledges
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%dys_offsets(Main, Init)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite init JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Init:
	lda !spr_blocked,x : ora #$04 : sta !spr_blocked,x
	jml !ssr_FacePlayer
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite main code 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

X_SPEED:            db $08,$F8
KILLED_X_SPEED:     db $F0,$10

RETURN:
	rtl
Main:
	jsr SPRITE_GRAPHICS
	lda !spr_status,x : cmp #$08 : bne RETURN
	lda $9d : bne RETURN
	
	jsl !ssr_Offscreen_X3

NOT_FIRING:
	lda $14 : lsr : clc : adc !dys_slot : and #$07 : sta !spr_miscI,x
	
	; flip sprite if touching walls
	lda !spr_blocked,x : and #$03 : beq +
	lda !spr_facing,x : eor #$01 : sta !spr_facing,x
+
	lda !spr_xProps1,x : and #$02 : beq FALLING
	lda !spr_blocked,x : ora !spr_miscD,x : bne ON_GROUND
	
	jsr SUB_CHANGE_DIR
	lda #$01 : sta !spr_miscD,x
	
ON_GROUND:
	lda !spr_blocked,x : and #$04 : beq SET_SPEED
	stz !spr_miscD,x : stz !spr_spdY,x
	bra X_TIME
	
FALLING:
	lda !spr_blocked,x : and #$04 : beq SET_SPEED
	lda #$10 : sta !spr_spdY,x
	
X_TIME:
	ldy !spr_facing,x : lda X_SPEED,y : sta !spr_spdX,x
SET_SPEED:
	jsl !ssr_Move
	
DONE_WITH_SPEED:
	jsl !ssr_CollideSpr
	jsl !ssr_CollidePlayer
	bcc RETURN_24
	jsl !ssr_VertPos
	lda $0e : cmp #$e6 : bpl SPRITE_WINS
	lda $7d : bmi RETURN_24
	lda !spr_xProps1,x : and #$01 : beq SPIN_KILL_DISABLED
	lda !WB|$140d : bne SPIN_KILL
SPIN_KILL_DISABLED:
	lda #$01 : sta !WB|$1471
	lda #$06 : sta !spr_disableContact,x
	stz $7d
	lda #$e1
	ldy $187a : beq +
	lda #$d1
+	clc : adc !spr_posYL,x : sta $96
	lda !spr_posYH,x : adc #$ff : sta $97
	ldy #$00
	lda !WB|$1491 : bpl +
	dey
+	clc : adc $94 : sta $94
	tya
	adc $95 : sta $95
RETURN_24:
	rtl
	
SPRITE_WINS:
	lda !spr_disableContact,x : ora !spr_beingEaten,x : bne RETURN_24
	lda !WB|$1490 : bne HAS_STAR
	jml !ssr_HurtPlayer
	
SPIN_KILL:
	lda #$04 : sta !spr_status,x
	jml !ssr_StompPoints
	
HAS_STAR:
	lda #$02 : sta !spr_status,x
	jsl !ssr_HorizPos : lda KILLED_X_SPEED,y : sta !spr_spdX,x
	jml !ssr_StarPoints
	
SUB_CHANGE_DIR:
	lda !spr_spdX,x : eor #$ff : inc : sta !spr_spdX,x
	lda !spr_facing,x : eor #$01 : sta !spr_facing,x
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SPRITE_GRAPHICS:
	ldy #$00
	lda !spr_status,x : cmp #$02 : beq +
	ldy !spr_miscI,x
+	rep #$20
	lda.w #fTable
	jsl !ssr_GenericGfx_FTableMTS
	rts
	
fTable:
dw .f0, .f1, .f2, .f3, .f4, .f5, .f6, .f7
.f0
	db $10
	;  size tile prop xofs yofs
	db $02, $ac, $09, $00,-$03
	db $00, $9e, $07, $01, $08
	db $00, $9e, $47, $07, $08
	db $ff
.f1
	db $10
	db $02, $ac, $09, $00,-$02
	db $00, $8e, $07, $00, $08
	db $00, $8e, $47, $08, $08
	db $ff
.f2
	db $10
	db $02, $ac, $09, $00,-$01
	db $00, $8f, $07,-$04, $08
	db $00, $8f, $47, $0b, $08
	db $ff
.f3
	db $10
	db $02, $ac, $09, $00,-$01
	db $00, $8f, $07,-$04, $05
	db $00, $8f, $47, $0b, $05
	db $ff
.f4
	db $10
	db $02, $ac, $09, $00,-$01
	db $00, $8e, $07,-$04, $08
	db $00, $8e, $47, $0b, $08
	db $ff
.f5
	db $10
	db $02, $ac, $09, $00,-$02
	db $00, $8e, $07, $00, $08
	db $00, $8e, $47, $08, $08
	db $ff
.f6
	db $10
	db $02, $ac, $09, $00,-$03
	db $00, $9e, $07, $01, $08
	db $00, $9e, $47, $07, $08
	db $ff
.f7
	db $10
	db $02, $ac, $09, $00,-$03
	db $00, $9e, $07, $04, $08 ; The feet are in the same spot, so only draw one.
	db $ff
