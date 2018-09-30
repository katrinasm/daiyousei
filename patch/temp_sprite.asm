incsrc "sprite_prelude.asm"
%dys_offsets3(Main, Init, Drop)

!tile = !spr_miscZ

Init:
	lda #$01 : jsl !ssr_DynAlloc
	bcc +
	sta $01
	inc : sta !tile,x
	lda #$01 : sta $00
	lda.b #bin : sta $02
	lda.b #bin>>8 : sta $03
	lda.b #bin>>16 : sta $04
	jsl !ssr_DynUpload
+	rtl

Main:
	jsl !ssr_Offscreen_X0
	jsl !ssr_FacePlayer
	jsr Gfx
	rtl

Drop:
	lda !tile,x : beq +
	dec
	jsl !ssr_DynFree
+	rtl

Gfx:
	jsl !ssr_GetDrawInfo
	lda $00 : sta !oam1_ofsX,y
	lda $01 : sta !oam1_ofsY,y
	lda #$01 : ora $64 : sta !oam1_props,y
	lda !tile,x : dec : sta !oam1_tile,y
	ldy #$02
	lda #$00
	jsl !ssr_FinishOamWrite
	rts

frames:
	db $2a

bin:
	incbin "../sprites/drop_test.bin"
