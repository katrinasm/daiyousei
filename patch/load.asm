@include

pushpc
	org $07f78b
		jml LoadBytesViaAct
	org $07f7a0
		jml LoadBytesViaAct
	org $07f7a4
		jml LoadBytes
pullpc
LoadBytesViaAct:
	phb
	php
	lda.b #DYS_DATA_OPTION_BYTES>>16 : pha : plb
	rep #$10
	phy

	lda #$00 : %OBX(sta, !spr_extraBit) : xba
	%OBX(lda, !spr_act) : %OBX(sta, !spr_custNum)
	bra LoadBytes_skipInit

LoadBytes:
	phb
	; We save the flags because we need to go 16-bit in Y.
	php
	lda.b #DYS_DATA_OPTION_BYTES>>16 : pha : plb
	rep #$10
	; The original saves Y, so we do too in case anyone is expecting it.
	; We don't need to save X because unlike the original we don't modify it.
	; This is also reasonably convenient for the load routine,
	; one of the main callers of this routine.
	phy

	%OBX(lda, !spr_extraBit) : lsr #3 : and #$03 : xba
	%OBX(lda, !spr_custNum)
.skipInit
	rep #$20
	asl #4
	tay
	sep #$20
	lda.w DYS_DATA_OPTION_BYTES,y    : %OBX(sta, !spr_type)
	lda.w DYS_DATA_OPTION_BYTES+1,y  : %OBX(sta, !spr_act)
	lda.w DYS_DATA_OPTION_BYTES+2,y  : %OBX(sta, !spr_props1)
	lda.w DYS_DATA_OPTION_BYTES+3,y  : %OBX(sta, !spr_props2)
	lda.w DYS_DATA_OPTION_BYTES+4,y  : %OBX(sta, !spr_props3)
	and #$0f : %OBX(sta, !spr_tileProps)
	lda.w DYS_DATA_OPTION_BYTES+5,y  : %OBX(sta, !spr_props4)
	lda.w DYS_DATA_OPTION_BYTES+6,y  : %OBX(sta, !spr_props5)
	lda.w DYS_DATA_OPTION_BYTES+7,y  : %OBX(sta, !spr_props6)
	lda.w DYS_DATA_OPTION_BYTES+8,y  : %OBX(sta, !spr_xOpts1)
	lda.w DYS_DATA_OPTION_BYTES+9,y  : %OBX(sta, !spr_xOpts2)

	lda.w DYS_DATA_OPTION_BYTES+10,y : %OBX(sta, !spr_xClipL)
	lda.w DYS_DATA_OPTION_BYTES+11,y : %OBX(sta, !spr_xClipT)
	lda.w DYS_DATA_OPTION_BYTES+12,y : %OBX(sta, !spr_xClipW)
	lda.w DYS_DATA_OPTION_BYTES+13,y : %OBX(sta, !spr_xClipH)
	lda.w DYS_DATA_OPTION_BYTES+14,y : %OBX(sta, !spr_xProps1)
	lda.w DYS_DATA_OPTION_BYTES+15,y : %OBX(sta, !spr_xProps2)

	lda #$00
	%OBX(sta, !spr_xByte1)
	%OBX(sta, !spr_xByte2)
	%OBX(sta, !spr_xByte3)
	%OBX(sta, !spr_xByte4)

	ply
	plp
	plb : rtl


pushpc
	if !opt_vitorSA1 == 0
		org $02a802
			jsl LoadSprites
			sep #$30
			rts
	else
		org $02a807
			pla : pla
			jml LoadSprites
	endif
pullpc

if !opt_largeLevels == 0
; The format of the sprite list in ROM is as follows (highest byte first):
;   offset |     + 2      + 1      + 0
;  ------- | ----~~~~ ----~~~~ ----~~~~
;     bits | nnnnnnnn xxxxssss yyyyceSY
; where nnnnnnnn = sprite number
;           xxxx = x position of sprite in screen
;          Yyyyy = y position of sprite in screen
;          Sssss = screen number of sprite
;             ce = extra bits
; X and Y postion are reversed in vertical levels.
; As many extra bytes follow as is appropriate for the sprite, given its
; sprite number and extra bits.
; (This means that the table can only be traversed forward, never back).
; After that the pattern repeats for every sprite in the level.
; See asm.txt §EXTRA BITS for more information on the 'ce' bits.
;
; The way this subroutine works is: we decide on a column (horizontal level)
; or a row (vertical) where sprites will be updated, the "update line".
; There is no way to just jump to one screen because we don't know how many
; sprites are on all the previous screens.
; So we need to walk the sprite list until we find a sprite on the same screen
; as the update line.
; Lunar Magic (and probably the original SMW) are polite enough to make
; sprites appear in the table in the same order as the appear in the level,
; wrt screen numbers, but not individual lines of that screen.
; So a sprite on screen $00 will always appear before a sprite on screen $01
; but there's no rule that a sprite on line 0 of screen $00 will appear before
; a sprite on line 1 of screen $00.
;
; So, back to walking the table, we get to a sprite on the same screen as the
; update line. Once we have that, we check every sprite for an exact match,
; until we hit a sprite on a later screen, which means there can't be any more
; exact matches. We have loaded all the possible sprites for now, and return.
; If we do find an exact match, we check its entry in the !dys_sprLoadStatuses
; table, and if it's set, we don't load it.
;
; The main thing that can go wrong during this is that `!dys_maxActive` sprites
; are on screen, which means we can't load any more without deleting one of the
; already on-screen sprites. If SMW finds out this is the case, it just
; drops the new sprite, unless that sprite is number $7b, the goal tape,
; in which case one is deleted so the level is always beatable.
; Daiyousei currently just drops it without checking anything.
;
; During this routines, direct page variables are used as follows:
; $00-$01 load line
; $02     sprite size in bytes (3 for 0 extra bytes)
; $03     zero (for a 16-bit add with $02)
; $04     sprite number low byte
; $05     sprite number section (0 = 000-0ff, 2 = 100-1ff)
; $06-$0b misc. temporaries
; $0c     index to load status table
; $0d     0 (for a 16-bit load to X)
; $0e     load line, adjusted to match ------S-----ssss as in the level data

lsret:
; This is kind of a huge routine, so we branch back here sometimes.
	plp : plb : rtl

LoadSprites:
	phb : php
	; The first thing we do is point our data bank at the sprite list in ROM.
	; Once we have $ce-$cf in y, we can use $0000,y instead of [$ce],y
	; like the original game. This saves 2 cycles and also lets us do things
	; like lda $0001,y, dodging a couple inys in inconvenient spots.
	; However, as a result, absolute addressing is no longer useful for RAM,
	; only direct page and long addressing are.
	lda $d0 : pha : plb
	stz $03
	; Set up the load line ($00)
	lda $5b : and #$01 : asl : tax
	lda $1a,x : and #$f0 : sta $00
	lda $1b,x : sta $01
	lda $55 : asl : tax
	rep #$31
	lda $00 : adc.l loadOfs,x : sta $00
	; Set up the adjusted load line ($0e)
	xba : and #$000f : sta $0e
	lda $00 : lsr #3 : and #$0200 : tsb $0e
	; Initialize the sprite table offset
	stz $0c
	ldy $ce
	iny ; We need to skip a header byte.
.scrLoop
	; If we hit bit $ff (here checked kind of funny), we hit the end. return.
	lda $0000,y : xba : cmp #$ff00 : bcs lsret
	; When we hit a sprite with a >= screen number than the load line,
	; we are to a point where we can start looking for sprites to load.
	and #$020f : cmp $0e : bcs .sprLoopInit
	; If we haven't got there yet, we need to dig up the sprite's number
	; and extra bits, and then its size, to skip it.
	sep #$20
	lda $0c : cmp.b #!dys_maxLevel : beq lsret
	inc : sta $0c
	lda $0000,y : and #$08 : lsr #2 : xba
	lda $0002,y
	tax
	lda DYS_DATA_SPRITE_SIZES,x : sta $02
	rep #$21
	tya : adc $02 : tay
	bra .scrLoop

.sprLoopInit
	ldx $0c
	; If the screen number was past the load line, it means there aren't
	; any sprites on the same screen as it. Return immediately.
.sprLoop
	cpx.w #!dys_maxLevel : bcs lsret
	lda $0000,y : xba : and #$020f : cmp $0e : bne .lsret2
	; Here we begin a possible real parse for our sprite.
	sep #$20
	lda $0000,y : and #$08 : lsr #2 : xba
	lda $0002,y
	stx $0c
	tax : lda DYS_DATA_SPRITE_SIZES,x : sta $02 ; Save sprite size
	stx $04
	ldx $0c
	; Check if the sprite is on the load line; if not, skip.
	lda $0001,y : and #$f0 : cmp $00 : bne .nextSprite
	; Check if the sprite has already been loaded; if so, skip.
	%OBX(lda, !dys_sprLoadStatuses) : bne .nextSprite
	; If it is, o miracle of miracles, we actually load it!
	lsr $05

	if !opt_manySprites
	lda $04 : cmp #$f8 : bcc +
	lda #$02 : tsb $05
	lda $0003,y : sta $04
+
	endif

	rep #$20
	lda $04 : asl #4 : tax
	sep #$20
	lda DYS_DATA_OPTION_BYTES,x

	ldx $0c

	cmp #$02 : bcc .setSprite
	beq .setGenerator
	cmp #$04
	bcc .setShooter
	beq .runOnce
	cmp #$05
	beq .setScroll
	stp

.nextSprite
	rep #$21
	tya : adc $02 : tay
	inx
	bra .sprLoop

.lsret2
	plp : plb : rtl

.setGenerator
	jsr SetGenerator
	bra .nextSprite
.setShooter
	jsr SetShooter
	bra .nextSprite
.runOnce
	jsr RunOnce
	bra .nextSprite
.setScroll
	lda !WB|$143e : ora !WB|$143f : bne +
	jsr SetScroll
+	bra .nextSprite

.setSprite
	;stx $0c
	ldx.w #!dys_maxActive-1
.findSlot
	%OBX(lda, !spr_status)
	beq .foundSlot
	dex : bpl .findSlot
	ldx $0c
	bra .nextSprite

.foundSlot
; First off, drop everything and initialize the easy tables.
; But before we do that we have to set the extra bit and sprite number.
	lda $04 : %OBX(sta, !spr_custNum)
if !opt_manySprites
	jsr GetExtraBits
	%OBX(sta, !spr_extraBit)
else
	lda $0000,y : and #$0c : %OBX(sta, !spr_extraBit)
endif

	jsl !ssr_InitTables

if !opt_manySprites
	lda $05 : bit #$02 : beq +
	iny
	dec $02
	+
endif

	lda $02 : sec : sbc #$03 : sta $0a
	beq +
	lda $0003,y : %OBX(sta, !spr_xByte1)
	dec $0a : beq +
	lda $0004,y : %OBX(sta, !spr_xByte2)
	dec $0a : beq +
	lda $0005,y : %OBX(sta, !spr_xByte3)
	dec $0a : beq +
	lda $0006,y : %OBX(sta, !spr_xByte4)
+

if !opt_manySprites
	lda $05 : bit #$02 : beq +
	dey
	inc $02
	+
endif

	jsr LoadPosition

	lda $06 : %OBX(sta, !spr_posXL)
	lda $07 : %OBX(sta, !spr_posYL)
	lda $08 : %OBX(sta, !spr_posXH)
	lda $09 : %OBX(sta, !spr_posYH)

	lda $0c
	%OBX(sta, !spr_loadStatIndex)
	lda #$01
	%OBX(sta, !spr_status)

	ldx $0c
	%OBX(sta, !dys_sprLoadStatuses)
	jmp .nextSprite

SetGenerator:
if !opt_manySprites
	jsr GetExtraBits
	%OB(sta, !gen_extraBits)
else
	lda $0000,y : and #$0c : %OB(sta, !gen_extraBits)
endif

	lsr #3 : xba
	lda $04 : %OB(sta, !gen_id)
	rep #$20
	phx
	asl #4 : tax
	lda DYS_DATA_OPTION_BYTES+14,x
	%OB(sta, !gen_xProps1)
	plx
	sep #$20
	lda $5b : lsr
	lda $0000,y : and #$f0 : xba
	lda $0001,y : and #$f0
	bcc + : xba : +
	lsr #4 : sta $06
	xba : tsb $06
	lda #$01 : %OBX(sta, !dys_sprLoadStatuses)
	jsr LoadExtraBytes
	lda $06 : %OB(sta, !gen_xByte1)
	lda $07 : %OB(sta, !gen_xByte2)
	lda $08 : %OB(sta, !gen_xByte3)
	lda $09 : %OB(sta, !gen_xByte4)
	rts

SetShooter:
	stx $0c
	ldx #$0007
	lda #$00 : xba
.findSlot
	%OBX(lda, !sht_id) : beq .foundSlot
	dex : bpl .findSlot
; if there aren’t any free slots, replace the top one
	%OB(lda, !dys_curSht)
	dec : bpl + : lda #$07 : +
	%OB(sta, !dys_curSht)
	tax
	%OBX(lda, !sht_loadIndex)
	tax
	lda #$00
	%OBX(sta, !dys_sprLoadStatuses)
	%OB(lda, !dys_curSht) : tax

.foundSlot
	lda $0c : %OBX(sta, !sht_loadIndex)

	jsr LoadPosition
	lda $06 : %OBX(sta, !sht_posXL)
	lda $07 : %OBX(sta, !sht_posYL)
	lda $08 : %OBX(sta, !sht_posXH)
	lda $09 : %OBX(sta, !sht_posYH)

	jsr LoadExtraBytes
	lda $06 : %OBX(sta, !sht_xByte1)
	lda $07 : %OBX(sta, !sht_xByte2)
	lda $08 : %OBX(sta, !sht_xByte3)
	lda $09 : %OBX(sta, !sht_xByte4)

if !opt_manySprites
	jsr GetExtraBits
	%OBX(sta, !sht_extraBits)
else
	lda $0000,y : and #$0c : %OBX(sta, !sht_extraBits)
endif

	lda $04 : %OBX(sta, !sht_id)

	lda #$00
	%OBX(sta, !sht_miscA) : %OBX(sta, !sht_miscB)

	lda #$10 : %OBX(sta, !sht_time)

	ldx $0c
	lda #$01 : %OBX(sta, !dys_sprLoadStatuses)
	rts

SetScroll:
	lda #$01 : %OBX(sta, !dys_sprLoadStatuses)
	lda $04 : sec : sbc #$e7 : sta !WB|$143e
	lda $0000,y : lsr #2 : sta !WB|$1440
	phx : phy
	pei ($00) : pei ($02) : pei ($0e)
	php
	sep #$30
	jsl $05bcd6!F
	plp
	plx : stx $00
	plx : stx $02
	plx : stx $0e
	ply : plx
	rts

RunOnce:
	phx : phy : phb
	pei ($00) : pei ($02) : pei ($0e)
	php
	lda $04 : sta $00
	lsr $05

	rep #$20
	lda $04 : asl : adc $04 : tax
	lda DYS_DATA_MAIN_PTRS,x : sta $0d
	sep #$20
	lda DYS_DATA_MAIN_PTRS+2,x : sta $0f

	jsr LoadPosition
	ldx $06 : phx
	ldx $08 : stx $04
	jsr LoadExtraBytes
	plx : stx $02

	lda $0000,y : and #$0c : sta $01

	sep #$30
	ldx $0c
	lda $0f : pha : plb
	phk : pea .retp-1
	jml [!DP|$0d]
.retp

	plp : plx : stx $00
	plx : stx $02
	plx : stx $0e
	plb : plx : ply
	rts

LoadExtraBytes:
	rep #$20
	stz $06
	stz $08
	sep #$20

if !opt_manySprites
	lda $05 : bit #$02 : bne .longform
endif

	lda $02
	sec : sbc #$03
	beq .ret
	sta $0a
	lda $0003,y : sta $06
	dec $0a : beq .ret
	lda $0004,y : sta $07
	dec $0a : beq .ret
	lda $0005,y : sta $08
	dec $0a : beq .ret
	lda $0006,y : sta $09
.ret
	rts

if !opt_manySprites
.longform
	lda $02
	sec : sbc #$04
	beq .ret
	sta $0a

	lda $0004,y : sta $06
	dec $0a : beq .ret
	lda $0005,y : sta $07
	dec $0a : beq .ret
	lda $0006,y : sta $08
	dec $0a : beq .ret
	lda $0007,y : sta $09
	rts

GetExtraBits:
	lda $0000,y : and #$0c : sta $0a
	lda $05 : bit #$02 : beq +
	lda #$10
+	ora $0a
	rts
endif

LoadPosition:
; Set up X/Y position nonsense.
	lda $0001,y : and #$f0 : sta $06
	lda $0001,y : and #$0f : sta $08
	lda $0000,y : and #$02 : asl #3 : tsb $08
	lda $0000,y : and #$f0 : sta $07
	lda $0000,y : and #$01 : sta $09

	lda $5b : lsr : bcc +
; Flip x/y if in vertical level
	rep #$20
	lda $06 : xba : sta $06
	lda $08 : xba : sta $08
	sep #$20
+	rts

loadOfs:
dw	-$30, 0, $120

else
;       +3       +2       +1       +0
; ----~~~~ ----~~~~ ----~~~~ ----~~~~
; xxxxAAAA yyyyAAAA nnnnnnnn T--nneL-
; where nnnnnnnnnn = sprite number
;                e = extra bit
;             xxxx = x position of sprite in screen
;             yyyy = y position of sprite in screen
;         AAAAAAAA = first extra byte
;                T = termination marker
;                L = length. If set, 4 further bytes follow
; the L extension is just the remaining 3 extra bytes
; and a mandatory $00 byte for alignment

; $00-$03 used by subroutines
; $08-$09 screendex index
; $0a     screen x position high byte
; $0b     screen y position high byte
; $0c-$0d sprite load index
; $0e-$0f load line (note that the X/Y direction changes)
LoadSprites:
; print "LOAD ROUTINE: ", pc
	phb : php

	lda $d0 : pha : plb

	rep #$30

.hScroll:
	lda $55 : and #$00ff : asl : tax
	lda $1a : and #$fff0
	adc.l .scrollOfs,x
	bmi .vScroll
	cmp #$2000 : bcs .vScroll
	sta $0e

.hScreens:
	lda $0e : and #$1f00 : xba : sta $06 : sta $0a
	lda $1c : and #$fff0 : sec : sbc #$0080
	bpl + : lda #$0000 : +
..topScreen:
	sta $01
	and #$1f00
	tsb $0a
	lsr #3 : ora $06
	sta $08
	;lda $01 : bit #$00f0 : beq ..alignedScreens
	;lda $08
	jsr getScreenIndices
	lda $0e : and #$f0 : sta $00
	lda #$f0 : sta $02
	jsr loadColumn

..middleScreen:
	inc $0b
	rep #$21
	lda $08
	adc #$0020
..aligned2:
	jsr getScreenIndices
	stz $01
	jsr loadColumn

..bottomScreen:
	inc $0b
	rep #$21
	lda $08
	adc #$0020
	jsr getScreenIndices
	stz $01
	lda $1c : clc : adc #$70 : sta $02
	jsr loadColumn
	bra .vScroll

..alignedScreens:
	lda #$f0 : sta $02
	and $0e : sta $00
	stz $01
	bra ..aligned2





.vScroll:
; print "vscroll: ", pc
	rep #$20
	ldx $fe
	lda $1c
	clc : adc.l .vScrollOfs,x
	bmi .end
	cmp #$2000 : bcs .end
	and #$fff0
	sta $0e

.vScreens:
	lda $1a : and #$fff0 : sec : sbc #$0080
	bpl + : lda #$0000 : +
	sta $01
	and #$1f00 : xba : sta $06 : sta $0a
	lda $0e : and #$1f00 : tsb $0a
..leftScreen:
	lsr #3 : ora $06
	sta $08
	jsr getScreenIndices
	lda $0e : and #$f0 : sta $00
	lda #$f0 : sta $02
	jsr loadRow

..middleScreen:
	inc $0a
	rep #$21
	lda $08
	inc
	jsr getScreenIndices
	stz $01
	jsr loadRow

..rightScreen:
	inc $0a
	rep #$21
	lda $08
	inc
	jsr getScreenIndices
	stz $01
	lda $1a : clc : adc #$70 : sta $02
	jsr loadRow

.end:
	plp : plb
	rtl

.scrollOfs:
dw -$30, $0000, $120
.vScrollOfs:
dw -$30, $120

; print "getScreenIndices: ", pc
getScreenIndices:
	tax
	lda.l !lvl_screenDex,x
	and #$007f : asl : adc $ce : tax
	lda $0001,x
	and #$00fe : asl : adc #$0101 : adc $ce : tay
	lda #$0000
	sep #$20
	lda $0002,x
	tax
	rts

; print "loadColumn ", pc
loadColumn:
	; $00   = col
	; $01   = min row (incl.)
	; $02   = max row (incl.)
	; $01,s = load index
	; y     = load index
	; x     = sprite index
	phy
.loop:
	lda $0000,y : bmi .end
	lda $0003,y
	and #$f0
	cmp $00 : bne .nextSpr
	lda $0002,y
	and #$f0
	inc
	cmp $01 : bcc .nextSpr
	dec
	cmp $02 : bcs .nextSpr
.onLine:
	%OBX(lda, !dys_sprLoadStatuses) : bne .nextSpr
	jsr loadSpr

.nextSpr:
	lda $0000,y
	rep #$20
	and #$0002
	asl
	adc #$0004
	adc $01,s
	sta $01,s
	tay
	sep #$20
	inx
	bra .loop

.end:
	pla : pla
	rts

; print "loadRow ", pc
loadRow:
	; $00   = row
	; $01   = min col (incl.)
	; $02   = max col (incl.)
	; $01,s = load index
	; y     = load index
	; x     = sprite index
	phy
.loop:
	lda $0000,y : bmi .end
	lda $0002,y
	and #$f0
	cmp $00 : bne .nextSpr
	lda $0003,y
	and #$f0
	inc
	cmp $01 : bcc .nextSpr
	dec
	cmp $02 : bcs .nextSpr
.onLine:
	%OBX(lda, !dys_sprLoadStatuses) : bne .nextSpr
	jsr loadSpr

.nextSpr:
	lda $0000,y
	rep #$20
	and #$0002
	asl
	adc #$0004
	adc $01,s
	sta $01,s
	tay
	sep #$20
	inx
	bra .loop

.end:
	pla : pla
	rts

loadSpr:
	phx
	lda $0000,y : and #$18 : lsr #3 : xba
	lda $0001,y
	rep #$20
	asl #4
	tax
	sep #$20
	lda.l DYS_DATA_OPTION_BYTES,x
	cmp #$02 : bcc .standard
	bne + : jmp .generator : +
	brk #$00

.standard:
	ldx.w #!dys_maxActive-1
.findSlot:
	%OBX(lda, !spr_status) : beq .foundSlot
	dex : bpl .findSlot
	ldx.w #!dys_maxActive-1

.foundSlot:
	lda $0000,y : %OBX(sta, !spr_extraBit)
	lda $0001,y : %OBX(sta, !spr_custNum)

	jsl !ssr_InitTables

	lda $0002,y : and #$f0 : %OBX(sta, !spr_posYL)
	lda $0003,y : and #$f0 : %OBX(sta, !spr_posXL)
	lda $0a : %OBX(sta, !spr_posXH)
	lda $0b : %OBX(sta, !spr_posYH)

	lda $0002,y : and #$0f : %OBX(sta, !spr_xByte1)
	lda $0003,y : asl #4
	%OBX(ora, !spr_xByte1)
	%OBX(sta, !spr_xByte1)
	lda $0000,y : bit #$02 : beq .noextension
.getxb:
	lda $0004,y : %OBX(sta, !spr_xByte2)
	lda $0005,y : %OBX(sta, !spr_xByte3)
	lda $0006,y : %OBX(sta, !spr_xByte4)
.noextension:
	lda $01,s : %OBX(sta, !spr_loadStatIndex)
	lda #$01
	%OBX(sta, !spr_status)
	plx
	%OBX(sta, !dys_sprLoadStatuses)
.end:
	rts

.generator:
;	print "generator: ", pc
	lda $0000,y : and #$1c : %OB(sta, !gen_extraBits)
	lda $0001,y : %OB(sta, !gen_id)

	lda $0002,y : and #$0f : %OB(sta, !gen_xByte1)
	lda $0003,y : asl #4
	%OB(ora, !gen_xByte1)
	%OB(sta, !gen_xByte1)

	lda $0000,y : and #$02 : beq ..noext
..ext:
	lda $0004,y : %OB(sta, !gen_xByte2)
	lda $0005,y : %OB(sta, !gen_xByte3)
	lda $0006,y : %OB(sta, !gen_xByte4)
	bra ..extdone
..noext:
	lda #$00
	%OB(sta, !gen_xByte2)
	%OB(sta, !gen_xByte3)
	%OB(sta, !gen_xByte4)
..extdone:

	lda #$01
	plx
	%OBX(sta, !dys_sprLoadStatuses)

	rts

endif

incsrc "sprite_settings.asm"
