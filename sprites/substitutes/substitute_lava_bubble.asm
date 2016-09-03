;==============================================================================;
; Substitute Lava Bubble, by Katrina                                           ;
;------------------------------------------------------------------------------;
; This is a substitute sprite for SMW’s Lava Bubble/Podoboo.                   ;
; It allows using the podoboo with non-dynamic 16x16 graphics,                 ;
; as well as a version which doesn’t require bouyancy and can be placed        ;
; outside of lava.                                                             ;
;==============================================================================;
%dys_offsets(Main, Init)

;------------------------------------------------------------------------------;
; Customizations                                                               ;
;------------------------------------------------------------------------------;

fallSpeeds:  db $70              ; Normal version
             db $20              ; Bowser version
			 
!bowserProps = $35               ; yxppccct properties for bowser version
			 
staticTiles: db $a6, $a8         ; Only used by non-dynamic normal version
bowserTiles: db $2a, $2c         ; Used by either version when Bowser-style

;------------------------------------------------------------------------------;
; Redefs                                                                       ;
;------------------------------------------------------------------------------;
	!topPosYL  = !spr_miscE
	!topPosYH  = !spr_miscD
	!jumpWait  = !spr_timeA
	!type      = !spr_miscA
	; The below are only used by non-bouyant version.
	!initPosYL = !spr_miscK
	!initPosYH = !spr_miscL
;------------------------------------------------------------------------------;
; Init routine                                                                 ;
;------------------------------------------------------------------------------;
Init:
	lda #$20 : sta !jumpWait,x

	lda !spr_xProps1,x : lsr : bcs .noBouyancy
	
.bouyancy
	lda !spr_posYL,x : sta !topPosYL,x
	lda !spr_posYH,x : sta !topPosYH,x
.fall
	lda !spr_posYL,x : clc : adc #$10 : sta !spr_posYL,x
	lda !spr_posYH,x : adc #$00 : sta !spr_posYH,x
	jsl !ssr_CollideLevel
	lda !spr_inWater,x : beq .fall
	rtl
	
.noBouyancy
	lda !spr_xByte1,x : asl #4 : sta $00
	lda !spr_xByte1,x : lsr #4 : sta $01
	
	lda !spr_posYL,x
	sta !initPosYL,x
	sec : sbc $00 : sta !topPosYL,x
	lda !spr_posYH,x
	sta !initPosYH,x
	sbc $01 : sta !topPosYH,x
	jml !ssr_CollideLevel

;------------------------------------------------------------------------------;
; Main routine                                                                 ;
;------------------------------------------------------------------------------;
Main:
	;stz !spr_beingEaten,x ; why??????????
	lda !jumpWait,x : beq .jumping
.waiting
	dec : bne +
	lda #$27 : sta !WB|$1dfc
+	rtl

.jumping
	lda $9d : beq + : jmp .finish : +
	jsl !ssr_CollidePlayer
	jsr SetAnimationFrame : jsr SetAnimationFrame
	lda !spr_tileProps,x : and #$7f
	ldy !spr_spdY,x : bmi +
	ora #$80
+	sta !spr_tileProps,x
	
	lda !spr_xProps1,x : lsr : bcs .noBouyancy
	
.bouyancy
	jsl !ssr_CollideLevel
	lda !spr_inWater,x : beq .notLanding
	lda !spr_spdY,x : bmi .notLanding
	bra .landing
	
.noBouyancy
	jsl !ssr_CollideLevel
	lda !spr_posYL,x : cmp !initPosYL,x
	lda !spr_posYH,x : sbc !initPosYH,x
	bne .notLanding
	lda !spr_spdY,x : bmi .notLanding
	bra .landing
	
.landing
	jsl !ssr_NewRand : and #$3f : adc #$60 : sta !jumpWait,x
	; I have no fucking idea what is going on.
	sec : sbc !topPosYL,x : sta $00
	lda !spr_posYH,x : sbc !topPosYH,x
	lsr : ror $00
	lda $00
	lsr #3
	phx : tax : lda $01e07b!F,x : plx
	cmp #$00 : bmi +
	lda #$80
+	sta !spr_spdY,x
	rtl
	
.notLanding
	jsl !ssr_TranslateY
	lda $14 : and #$07 : ora !spr_miscA,x : bne +
	jsl $0285df!F ; draws lava trail
+	lda !spr_timeC,x : bne .keepSpeed
	lda !spr_spdY,x : bmi +
	ldy !spr_miscA,x : cmp fallSpeeds,y : bcs .keepSpeed
+	clc : adc #$02
	sta !spr_spdY,x
.keepSpeed
	jsl !ssr_Offscreen_X0
	
.finish
	lda !type,x : beq .normal
.bowser
	ldy $9d : bne .bFrozen
	lda !spr_blocked,x : and #$04 : beq .bFloating
.bLanding
	stz !spr_spdY,x
	lda !spr_timeB,x : beq +
	cmp #$01 : bne ++
; Turn into a smoke puff
	lda #$04 : sta !spr_status,x
	lda #$1f : sta !spr_timeA,x
	rtl
	
+	lda #$80 : sta !spr_timeB,x
++	bra .bFrozen

.bFloating
	txa : asl #2 : adc $13
	ldy #$f0
	and #$04 : beq +
	ldy #$10
+	jsl !ssr_TranslateX
.bFrozen
	jsr BowserGfx
	rtl
	
.normal
	jsr Gfx
	rtl
	

;------------------------------------------------------------------------------;
; Helper routines                                                              ;
;------------------------------------------------------------------------------;
SetAnimationFrame:
	lda !spr_miscG,x : inc : sta !spr_miscG,x
	lsr #3 : and #$01
	sta !spr_miscI,x
	rts
	
;------------------------------------------------------------------------------;
; Graphics routines                                                            ;
;------------------------------------------------------------------------------;
Gfx:
	lda !spr_xProps1,x : and #$02 : beq .dynamic
.static:
	ldy !spr_miscI,x
	rep #$20
	lda.w #staticTiles
	jsl !ssr_GenericGfx_16x16
	rts
	
.dynamic:
	jsl !ssr_GetDrawInfo
	lda $00 : sta !oam1_ofsX,y : sta !oam1_ofsX+8,y
	clc : adc #$08 : sta !oam1_ofsX+4,y : sta !oam1_ofsX+12,y
	
	lda $01 : sta !oam1_ofsY,y : sta !oam1_ofsY+4,y
	clc : adc #$08 : sta !oam1_ofsY+8,y : sta !oam1_ofsY+12,y
	
	phy
	lda !spr_miscI,x : asl : tay
	rep #$20
	lda .tilePairs,y
	sep #$20
	
	ldy !spr_tileProps,x : bpl + : xba : +
	ply
	
	sta !oam1_tile,y : sta !oam1_tile+4,y
	xba
	sta !oam1_tile+8,y : sta !oam1_tile+12,y
	
	lda !spr_tileProps,x : ora $64
	sta !oam1_props,y : sta !oam1_props+8,y
	ora #$40 : sta !oam1_props+4,y : sta !oam1_props+12,y 
	
	ldy #$00
	lda #$03
	jsl !ssr_FinishOamWrite
	
	rep #$20
	lda #$8600 : sta !WB|$0d8b
	lda #$8800 : sta !WB|$0d95
	sep #$20
	rts
.tilePairs
dw	$1606, $1707
	
BowserGfx:
	lda.b #!bowserProps : sta !spr_tileProps,x
	lda $14 : and #$0c : lsr : adc !dys_slot : lsr : pha
	and #$01 : tay
	pla : lsr : and #$01 : sta !spr_facing,x
	rep #$20
	lda.w #bowserTiles
	jsl !ssr_GenericGfx_16x16

	rts
	