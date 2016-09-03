;==============================================================================;
; Substitute Thwimp, by Katrina                                                ;
;------------------------------------------------------------------------------;
; A substitute for SMW’s Thwimp.                                               ;
;==============================================================================;
%dys_offsets(Main, !ssr_Nothing)

;------------------------------------------------------------------------------;
; Customizations                                                               ;
;------------------------------------------------------------------------------;
speedsX: db $10, -$10

f8x8:
	db $10
	db $00, $a2, $03, $00, $00
	db $00, $b2, $03, $00, $08
	db $00, $a2, $43, $08, $00
	db $00, $b2, $43, $08, $08
	db $ff
f16x16:
	db $10
	db $02, $a2, $03, $00, $00
	db $ff

fTable:
	dw f8x8
	dw f16x16

;------------------------------------------------------------------------------;
; Main routine                                                                 ;
;------------------------------------------------------------------------------;
Main:
	lda !spr_status,x : cmp #$08 : bne .frozen
	lda $9d : bne .frozen
	lda #$01 : sta !spr_facing,x
	jsl !ssr_Offscreen_X0
	jsl !ssr_CollidePlayer
	jsl !ssr_TranslateXY
	jsl !ssr_CollideLevel
	
	lda !spr_spdY,x : bmi .afc3
	cmp #$40 : bcs .afc8
	adc #$05
.afc3
	clc : adc #$03
	bra .afca
.afc8
	lda #$40
.afca
	sta !spr_spdY,x
;--------------------------------------;
	lda !spr_blocked,x : bit #$08 : beq .didntHit
.hitCeiling
	lda #$10 : sta !spr_spdY,x
	lda !spr_blocked,y
.didntHit
	and #$04 : beq .inAir
.onGround
	jsr SetYSpeed
	stz !spr_spdY,x
	stz !spr_spdX,x
	
	lda !spr_timeA,x
	beq .sound
	dec : bne .frozen
.jump
	lda #$a0 : sta !spr_spdY,x
	inc !spr_miscA,x
	lda !spr_miscA,x : and #$01 : tay : lda speedsX,y : sta !spr_spdX,x
	bra .frozen
	
.sound
	lda #$01 : sta !WB|$1df9
	lda #$40 : sta !spr_timeA,x
	
.inAir
.frozen
	lda !spr_xProps1,x : tay
	rep #$20
	lda.w #fTable
	jml !ssr_GenericGfx_FTableMTS
	
;------------------------------------------------------------------------------;
; Helper routines                                                              ;
;------------------------------------------------------------------------------;
SetYSpeed:
	lda !spr_blocked,x : bmi +
	lda #$00
	ldy !spr_onSlope,x
	beq ++
+	lda #$18
	sta !spr_spdY,x
++	rts
