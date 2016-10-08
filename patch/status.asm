pushpc
	org $018127
		jml Dispatch

	org $018147
		dw $8156 ; The rts this used to point to is changed to an rtl.

	org $018172
		phb
		jsl InitHandler
		plb
		rts

	org $0185c3
		phb
		jsl MainHandler
		plb
		rts

	org $02affe
		phb
		jsl GeneratorHandler
		plb
		rts

	org $02b387
		ldx #$07
	ShooterLoop:
		stx !dys_slot
		lda !sht_time,x : beq +
		lda $13 : lsr : bcc +
		dec !sht_time,x
	+	phb
		jsl ShooterHandler
		plb
	.continue:
		dex
		bpl ShooterLoop
		rts

	org $01d43e
		jsr $8133
		rtl
pullpc

Dispatch:
	; ----~~~~
	; ab------
	; a: call /only/ main routine for all states above $01
	; b: call default routine, then call main routine for state $03,
	;    and all above $09
	lda !spr_status,x
	cmp #$08 : beq .main1
	cmp #$02 : bcc .default1
	lda !spr_xProps2,x
	bit #$c0 : beq .default0
	bmi .main0

.both:
	lda !spr_status,x : pha
	jsl $01d43e!F ; jsr -> default routine -> rts -> rtl
	lda !spr_xProps2,x : asl #2
	pla
	bcc .default1
	cmp #$09 : bcs .main1
	cmp #$03 : beq .main1
.return:
	jml $018156!F ; rts

.default0:
	lda !spr_status,x
.default1:
	jml $018133!F ; default routine -> rts

.main0:
	lda !spr_status,x
.main1:
	jml $0185c3!F ; This routine needs an rts anyway. Doing this is meh.

InitHandler:
	lda #$08 : sta !spr_status,x
	lda !spr_custNum,x : sta $00
	lda !spr_extraBit,x : lsr #3 : and #$03 : sta $01
	phx
	rep #$30
	lda $00 : asl : adc $00 : tax
	lda DYS_DATA_INIT_PTRS,x
	sta $00
	sep #$20
	lda DYS_DATA_INIT_PTRS+2,x
	sep #$10
	sta $02
	pha : plb
	plx

	jml.w [!DP|$00]

MainHandler:
	stz !WB|$1491
	lda !spr_custNum,x : sta $00
	lda !spr_extraBit,x : lsr #3 : and #$03 : sta $01
CallMain:
	phx
	rep #$30
	lda $00 : asl : adc $00 : tax
	lda DYS_DATA_MAIN_PTRS,x
	sta $00
	sep #$20
	lda DYS_DATA_MAIN_PTRS+2,x
	sep #$10
	sta $02
	pha : plb
	plx

	jml.w [!DP|$00]

GeneratorHandler:
	lda !gen_extraBits : lsr #3 : and #$03 : sta $01
	lda !gen_id : sta $00
	bne CallMain
	sep #$30
	rtl

ShooterHandler:
	lda !sht_extraBits,x : lsr #3 : and #$03 : sta $01
	lda !sht_id,x : sta $00
	bne CallMain
	sep #$30
	rtl
