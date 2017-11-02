pushpc
	org $0180a4
		jml SpriteMainPrep
	org $0180d2
		jml SetOam
	org $01b7bb
		jml FinishOamWriteUpdate
pullpc

FinishOamWriteUpdate:
	sty $0b
	sta $08
	
	lda !spr_posYL,x
	sec : sbc $1c
	sta $00
	lda !spr_posYH,x
	sbc $1D
	sta $01
	ldy !spr_oamIndex,x
	lda !spr_posXH,x : xba : lda !spr_posXL,x
	rep #$20
	sec : sbc $1a
	sta $02
	tya : lsr #2 : tax
	sep #$21
	
.loop	lda !oam1_ofsX,y
	sbc $02
	rep #$21
	bpl +
	ora #$ff00
+	adc $02 : cmp #$0100
	txa
	sep #$20
	lda $0b
	bpl +
	lda !oam1_sizes,x
	and #$02
+	adc #$00
	sta !oam1_sizes,x
	lda !oam1_ofsY,y
	sec : sbc $00
	rep #$21
	bpl +
	ora #$ff00
+	adc $00
	clc : adc #$0010 : cmp #$0100
	bcc +
	lda #$00f0
	sep #$20
	sta !oam1_ofsY,y
+	sep #$21
	iny #4
	inx
	dec $08
	bpl .loop
	tya
	sta !dys_lastOam
	jml $01b840!F	; org $01b840 : ldx !dys_slot : rts
	
SetOam:
	lda !spr_status,x : beq .ret
	lda !dys_lastOam
	cmp.b #!dys_firstOam : bcc .exhausted
	cmp !dys_lastLastOam : beq .findFree
	;sta !spr_oamIndex,x
	;sta !dys_lastLastOam
	tay
.ffLoop
-	lda !oam1_ofsY,y
	cmp #$f0
	beq .found
	tya
.findFree
	clc : adc #$10
	bcs .exhausted
	tay
	bra .ffLoop

.exhausted
	ldy.b #!dys_firstOam
.found
	tya
	sta !spr_oamIndex,x
	sta !dys_lastOam
	sta !dys_lastLastOam
.ret
	jml $0180e5!F



SpriteMainPrep:
	stz !WB|$18df
	; We want !lastLastOam lower than lastOam for the first sprite so that
	; it will always start at $24 instead of $34, as it would if they matched.
	lda.b #!dys_firstOam : sta !dys_lastOam
	dec : sta !dys_lastLastOam
	ldx.b #!dys_maxActive-1
	jml $0180a9!F



;-----------------------------------------------------------------------------;
; Misc. fixes                                                                 ;
;-----------------------------------------------------------------------------;

pushpc
	org $03b221 ; Bowser's Bowling Ball
		bra + : nop #3 : +
	org $01bb33 ; Climbing Net Door (1)
		lda.w !spr_oamIndex,x
		sta $03
		tay
		lsr
		lsr
		pha
		lda.b !spr_posXL,x
	org $01bbfd ; Climbing Net Door (2)
		jml CDoorOamFix
	org $01e8d2
		tya
		sta $0c
		clc : adc #$04 : sta $0d
		clc : adc #$04
		ldy !spr_miscA,x : beq +
		lda #$00
	+	sta $0e
		clc : adc #$04
		sta $0f
		nop
	org $01e945
		jml LakituCloudOamFix

	org $01dfa9
		jml BonusGameOamFix
pullpc

CDoorOamFix:
	pla
	ply
	cmp #$00
	beq +
	jml $01bc02!F
+	jml $01bc1c!F

LakituCloudOamFix:
	lda !dys_lastOam : pha
	lda !spr_oamIndex,x : pha
	lda $0e : sta !spr_oamIndex,x
	ldy #$02 : lda #$01
	jsl !ssr_FinishOamWrite
	pla : sta !spr_oamIndex,x
	ldy #$02 : lda #$01
	jsl !ssr_FinishOamWrite
	pla
	clc : adc #$10
	sta !dys_lastOam

	jml $01e95e!F

BonusGameOamFix:
	tya
	lsr
	lsr
	tay

	lda !dys_lastOam
	; carry clear after lsrs
	adc #$14
	sta !dys_lastOam

	jml $01dfad!F
