pushpc
	org $00a1b2
		jsl DropBeforeZero
		bra +
		nop #3
	+	sep #$10
		rts

	if !opt_vitorSA1 == 0
	org $008a5c
		jml ClearDropFlagsOnBoot
	else
	org $008a57
		jsl ClearDropFlagsOnBoot
		rts
	endif
pullpc

DropBeforeZero:
	sep #$10
	ldx.b #!dys_maxActive-1
.loop
	stx !dys_slot
	jsl DropHandler
	dex : bpl .loop
	rep #$10

	ldx #$07ce
-	stz !WB|$13d3,x
	dex : bpl -
	rtl

ClearDropFlagsOnBoot:
if !opt_vitorSA1 == 0
		sep #$30
		ldx.b #!dys_maxActive-1
		lda #$00
	.droploop:
		sta !spr_xOpts2,x
		dex : bpl .droploop
		rep #$30

		ldx #$00fe
	.zploop:
		stz $00,x
		dex #2
		bpl .zploop

		jml $008a66!F
else
		ldx.b #!dys_maxActive-1
		lda #$00
	.loop:
		sta !spr_xOpts2,x
		dex : bpl .loop
		rtl
endif
