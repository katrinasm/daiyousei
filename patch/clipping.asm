pushpc
	org $03b69f
		jml ClipA
	org $03b6e5
		jml ClipB
pullpc

ClipA:
	lda !spr_xOpts1,x : bit #$10 : bne .custClip
.origClip
	phy : phx
	txy
	lda !spr_props2,x
	jml $03b6a5!F

.custClip
	stz $0f
	lda !spr_xClipL,x : bpl +
	dec $0f
+	clc : adc !spr_posXL,x : sta $04
	lda !spr_posXH,x : adc $0f : sta $0a

	stz $0f
	lda !spr_xClipT,x : bpl +
	dec $0f
+	clc : adc !spr_posYL,x : sta $05
	lda !spr_posYH,x : adc $0f : sta $0b

	lda !spr_xClipW,x : sta $06
	lda !spr_xClipH,x : sta $07
	rtl

ClipB:
	lda !spr_xOpts1,x : bit #$10 : bne .custClip
.origClip
	phy : phx
	txy
	lda !spr_props2,x
	jml $03b6eb!F

.custClip
	stz $0f
	lda !spr_xClipL,x : bpl +
	dec $0f
+	clc : adc !spr_posXL,x : sta $00
	lda !spr_posXH,x : adc $0f : sta $02

	stz $0f
	lda !spr_xClipT,x : bpl +
	dec $0f
+	clc : adc !spr_posYL,x : sta $01
	lda !spr_posYH,x : adc $0f : sta $03

	lda !spr_xClipW,x : sta $08
	lda !spr_xClipH,x : sta $09
	rtl
