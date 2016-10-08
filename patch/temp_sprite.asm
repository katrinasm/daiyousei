incsrc "sprite_prelude.asm"
%dys_main(Main)

Main:
	lda !sht_time,x : beq .try
.ret
	rtl

.try
	lda #$60 : sta !sht_time,x

	lda !sht_posYL,x : cmp $1c
	lda !sht_posYH,x : sbc $1d
	bne .ret

	lda !sht_posXL,x : cmp $1a
	lda !sht_posXH,x : sbc $1b
	bne .ret

	lda !sht_posXL,x
	sec : sbc $1a : clc : adc #$10
	cmp #$10 : bcc .ret

.generate
	lda #$33 : sta $00
	stz $01
	jsl !ssr_SpawnSprite : bmi .ret
	lda #$17 : sta !WB|$1dfc
	; x, y = y, x
	tya : txy : tax

	lda !sht_posXL,y : sta !spr_posXL,x
	lda !sht_posXH,y : sta !spr_posXH,x
	lda !sht_posYL,y : sta !spr_posYL,x
	lda !sht_posYH,y : sta !spr_posYH,x
	lda #$01 : sta !spr_miscA,x
	asl !spr_props5,x : lsr !spr_props5,x
	tyx
	rtl
