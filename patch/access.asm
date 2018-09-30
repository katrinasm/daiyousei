@include
; Vitor’s SA-1 patch already goofs on the vast majority of memory accesses
; in the game, let alone the sprite memory accesses.
if !opt_vitorSA1 == 0
	pushpc
		org $07f722
		ZeroSpriteTables:
			stz !spr_inWater,x
			stz !spr_behindScenery,x
			stz !spr_miscA,x
			stz !spr_miscD,x
			stz !spr_miscE,x
			stz !spr_miscF,x
			stz !spr_facing,x
			stz !spr_blocked,x
			stz !spr_offscreen,x
			stz !spr_miscI,x
			stz !spr_timeA,x
			stz !spr_disableContact,x
			stz !spr_timeB,x
			stz !spr_timeC,x
			stz !spr_disableCapeTime,x
			stz !spr_miscK,x
			stz !spr_miscG,x
			stz !spr_spdX,x
			stz !spr_posXF,x
			stz !spr_spdY,x
			stz !spr_posYF,x
			stz !spr_objectItxn,x
			stz !spr_beingEaten,x
			stz !spr_timeE,x
			; The original game knocked out the sprite property values here,
			; but this routine is only called right before LoadSpriteTables.
			; So there's no need to do this unless custom sprites use this
			; for some really weird shit.
			if 0
				stz !spr_props1,x
				stz !spr_props2,x
				stz !spr_props3,x
				stz !spr_props4,x
				stz !spr_props5,x
			endif
			stz !spr_miscL,x
			stz !spr_miscJ,x
			stz !spr_miscH,x
			stz !spr_miscB,x
			stz !spr_miscZ,x
			lda.b #$01
			sta !spr_offscreenH,x
			rtl

		org $02abf2
		InitLoadStatus:
			ldx.b #!dys_maxLevel
		-	stz !dys_sprLoadStatuses-1,x
			dex
			bne -

		org $01ac9e
			sta !dys_sprLoadStatuses,y
		org $02d08a
			sta !dys_sprLoadStatuses,y
		org $02fae9
			stz !dys_sprLoadStatuses,x
		org $02ff17
			sta !dys_sprLoadStatuses,y
		org $038714
			sta !dys_sprLoadStatuses,y
		org $03b8bc
			sta !dys_sprLoadStatuses,y

	org $02a9de
	FindFreeSlotLowPri:
		ldy.b #!dys_maxActive-3
		bra FindFreeSprSlot_loop

	org $02a9e4
	FindFreeSprSlot:
		ldy.b #!dys_maxActive-1
	.loop
		lda !spr_status,y
		beq .found
		dey
		bpl .loop
	.found
		tya
		rtl

	pullpc
endif
