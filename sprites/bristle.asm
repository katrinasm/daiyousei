;==============================================================================;
; Bristle, by Katrina                                                          ;
;==============================================================================;
%dys_offsets(Main, !ssr_FacePlayer)

	!BODY_TILE      = $de
	!SPIKE_TILE     = $cb
	!ARM_TILE       = $cc
	
	!SPANSION_DIST  = $18
	!SPANSION_SPD   = $02
	!TIME_EXPANDED  = $10
	
	!spansionTimer  = !spr_timeA
	!spansion       = !spr_miscA
	!spansionDir    = !spr_miscB
	!expanded       = !spr_miscJ

xSpds:
db	$08, -$08
	
;------------------------------------------------------------------------------;
; Main routine                                                                 ;
;------------------------------------------------------------------------------;

Ret:
	rtl
Main:
	jsr Gfx
	jsl !ssr_Offscreen_X0
	lda $9d : bne Ret

	lda !expanded,x : beq .inspanded

.expanded
	lda !spansionTimer,x : beq + : jmp .finish : +
	lda !spansionDir,x : bne .inspand
	
.expand
	lda !spansion,x : clc : adc.b #!SPANSION_SPD : cmp.b #!SPANSION_DIST : bcc +
	lda.b #!TIME_EXPANDED : sta !spansionTimer,x
	inc !spansionDir,x
	lda.b #!SPANSION_DIST
+	sta !spansion,x
	bra .finish
	
.inspand
	lda !spansion,x : sec : sbc.b #!SPANSION_SPD : bpl +
	stz !expanded,x
	lda.b #60 : sta !spansionTimer,x
	lda #$00
+	sta !spansion,x
	bra .finish
	
.inspanded
	lda !spr_blocked,x : bit #$84 : beq .move
	jsl !ssr_HorizPos
	lda $0f : bpl + : eor #$ff : inc : + : cmp.b #!SPANSION_DIST+$12 : bcs .move
	jsl !ssr_FacePlayer
	lda !spansionTimer,x : bne .move
	stz !spansionDir,x
	inc !expanded,x
	lda #$1a : sta $1df9
	bra .finish
	
.move
	ldy !spr_facing,x : lda xSpds,y : sta !spr_spdX,x
	lda !spr_blocked,x
	bit #$03 : beq +
	
.flip
	lda !spr_facing,x : eor #$01 : sta !spr_facing,x
	tay
	lda xSpds,y : sta !spr_spdX,x
	bra ++

+	bit #$84 : beq ++
	lda.b #-$0e : sta !spr_spdY,x
++	
	jsl !ssr_Move
	
.finish
	lda.b #-$04 : sec : sbc !spansion,x : sta !spr_xClipL,x
	lda.b !spansion,x : asl : adc.b #$18 : sta !spr_xClipW,x
	jml !ssr_CollideSprPlayer
	
;------------------------------------------------------------------------------;
; Graphics routine                                                             ;
;------------------------------------------------------------------------------;
Gfx:
	ldy !spr_facing,x
	
	lda !spr_tileProps,x : ora $64
	sta $04
	ora .dirProps,y
	sta $05
	
	jsl !ssr_GetDrawInfo
	
	lda.b #!oam1_sizes>>8 : sta $09
	tya : lsr #2 : clc : adc.b #!oam1_sizes : sta $08
	sta $0a
.body
	lda $00 : sta !oam1_ofsX,y
	lda $01 : sta !oam1_ofsY,y
	lda.b #!BODY_TILE : sta !oam1_tile,y
	lda $05 : sta !oam1_props,y
	lda #$02 : sta ($08)
	inc $08
	iny #4
	
	lda $01 : clc : adc #$04 : sta $01
	
.lftspike
	lda $00 : sec : sbc !spansion,x : sec : sbc #$04 : sta !oam1_ofsX,y
	lda $01 : sta !oam1_ofsY,y
	lda.b #!SPIKE_TILE : sta !oam1_tile,y
	lda $04 : sta !oam1_props,y
	lda #$00 : sta ($08)
	inc $08
	iny #4
	
	lda !spansion,x : beq .rgtspike
	lsr #3 : sta $0f
	lda $00 : sec : sbc !spansion,x : clc : adc #$04 : sta $02
.lftarm
	lda $02 : sta !oam1_ofsX,y : clc : adc #$08 : sta $02
	lda $01 : sta !oam1_ofsY,y 
	lda.b #!ARM_TILE : sta !oam1_tile,y
	lda $04 : sta !oam1_props,y
	lda #$00 : sta ($08)
	iny #4
	inc $08
	dec $0f : bpl .lftarm
	
.rgtspike
	lda $00 : clc : adc !spansion,x : clc : adc #$0c : sta !oam1_ofsX,y
	lda $01 : sta !oam1_ofsY,y
	lda.b #!SPIKE_TILE : sta !oam1_tile,y
	lda $04 : eor #$40 : sta !oam1_props,y
	lda #$00 : sta ($08)
	inc $08
	iny #4
	
	lda !spansion,x : beq .end
	lsr #3 : sta $0f
	lda !spansion,x : and #$07 : clc : adc $00 : clc : adc #$04 : sta $02
.rgtarm
	lda $02 : sta !oam1_ofsX,y : clc : adc #$08 : sta $02
	lda $01 : sta !oam1_ofsY,y 
	lda.b #!ARM_TILE : sta !oam1_tile,y
	lda $04 : sta !oam1_props,y
	lda #$00 : sta ($08)
	iny #4
	inc $08
	dec $0f : bpl .rgtarm
	
.end
	ldy #$ff
	lda $08 : sec : sbc $0a
	jsl !ssr_FinishOamWrite
	
	rts

.dirProps
	db $40, $00
	