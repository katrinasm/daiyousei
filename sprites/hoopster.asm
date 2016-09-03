
%dys_offsets(Main, Init)

!SpeedupRange = $10

yspeed:
	db $08, -$08, $18, -$10

Init:
	ldy #$00
	lda !spr_extraBit,x : and #$04 : bne + : iny
	lda yspeed,y : sta !spr_spdY,x
	rtl

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Main:
	jsr Gfx

	lda !spr_status,x : cmp #$08 : bne .ret
	lda $9d : bne .ret

	jsl !ssr_Offscreen_X0

	jsl !ssr_TranslateX
	jsl !ssr_TranslateY
	jsl $019138!F

	jsr PlayerInteract
.movement
	; If the sprite is touching something other than a vine,
	; flip
	lda !WB|$1693 : cmp #$06 : beq .proxCheck
	lda !spr_miscA,x : eor #$01 : sta !spr_miscA,x

.proxCheck
	jsr Proximity
	sta !spr_miscI,x

	asl : ora !spr_miscA,x : tay
	lda yspeed,y : sta !spr_spdY,x
.ret
	rtl

PlayerInteract:
	ldy #$b9 : lda $1490 : beq + : ldy #$39 : +
	tya : sta !spr_props4,x

	jsl !ssr_CollideSprPlayer
.MakeSpriteSolid
	bcc .ret2
	lda $77 : and #$08 : beq + : stz !spr_miscA,x : +
	phk : pea .continue-1 : pea $8020
	jml $81b45c
	
.continue
	bcc .spriteWins
	lda !spr_miscB,x : bne .playerWins
	lda #$01 : sta !spr_miscB,x
	
	ldy #$10 : sty !spr_spdY,x
	
.playerWins
	lda #$08 : sta !spr_disableContact,x
	lda !spr_spdY,x : dec : cmp #$f0 : bmi .ret
	sta !spr_spdY,x
	rts
	
.spriteWins
	lda !spr_disableContact,x : bne .ret
	jsl !ssr_HurtPlayer
.ret2
	lda !spr_disableContact,x : bne .ret
	stz !spr_miscB,x
.ret
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Gfx:
	jsl !ssr_GetDrawInfo
	lda !spr_miscA,x : lsr : ror : eor #$80 : sta $02
	
	lda $00 : sta !oam1_ofsX,y
	lda $01 : sta !oam1_ofsY,y

	phy
	lda $14
	ldy !spr_miscI,x : beq .far
.near
	asl
.far
	lsr #2
	clc : adc !dys_slot
	lsr
	and #$01
	tay
	lda tilemap,y
	ply
	sta !oam1_tile,y
	
	lda !spr_tileProps,x : ora $64 : ora $02 : sta !oam1_props,y
	
	ldy #$02
	lda #$00
	jsl !ssr_FinishOamWrite
	rts
	
tilemap:
	db $d0, $d2

;------------------------------------------------------------------------------;

Proximity:
	lda #!SpeedupRange : sta $0a : stz $0b

	lda !spr_posXH,x : xba : lda !spr_posXL,x
	rep #$20
	sec : sbc $94 : bpl +
	eor.w #-1 : inc
+	cmp $0a
	sep #$20
	bcs .rangeOut
.rangeIn:
	lda #$01
	rts
.rangeOut:
	lda #$00
	rts
