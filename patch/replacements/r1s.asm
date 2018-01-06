@include
; This file contains run-once sprite implementations of some special cases
; that had been in SMW's load routine.

RunOnceShell:
	lda $00 : sec : sbc #$d6 : sta $00

.nospecial
	jsl !ssr_SpawnSprite : bmi .ret
	lda #$01 : sta !dys_sprLoadStatuses,x
	txa
	tyx
	sta !spr_loadStatIndex,x
	lda #$09 : sta !spr_status,x
	lda $02 : sta !spr_posXL,x
	lda $03 : sta !spr_posXH,x
	lda $04 : sta !spr_posYL,x
	lda $05 : sta !spr_posYH,x
.ret
	rtl

RunOnceGrnShell:
	lda #$04
	sta $00
	bra RunOnceShell_nospecial

RunOnceTriplePlatform:
	jsl !ssr_FindFreeSlot
	bmi .ret
	lda #$01 : sta !dys_sprLoadStatuses,x
	stx $0d
	lda #$a3 : sta $00
	lda #$02 : sta $0c
.loop
	jsl !ssr_SpawnSprite
	bmi .ret
	tyx
	ldy $0c
	lda #$01 : sta !spr_status,x
	lda .anglesL,y : sta !spr_miscI,x
	lda .anglesH,y : sta !spr_miscD,x
	lda $02 : sta !spr_posXL,x
	lda $03 : sta !spr_posXH,x
	lda $04 : sta !spr_posYL,x
	lda $05 : sta !spr_posYH,x
	lda $0d : sta !spr_loadStatIndex,x
	dec $0c
	bpl .loop
.ret
	rtl
.anglesL
db $00,$aa,$54
.anglesH
db $00,$00,$01

RunOnceFiveEeries:
	jsl !ssr_FindFreeSlot
	bmi .ret
	lda #$01 : sta !dys_sprLoadStatuses,x
	lda #$39 : sta $00
	stz $01
	lda #$04 : sta $0c
	stx $0d
.loop
	jsl !ssr_SpawnSprite
	bmi .ret
	tyx
	ldy $0c
	lda $02 : clc : adc .ofsXL,y : sta !spr_posXL,x
	lda $03 : adc .ofsXH,y : sta !spr_posXH,x
	lda $04 : sta !spr_posYL,x
	lda $05 : sta !spr_posYH,x
	lda .miscA,y : sta !spr_miscA,x
	lda $0d : sta !spr_loadStatIndex,x
	jsl !ssr_HorizPos
	lda .spdX,y : sta !spr_spdX,x
	dec $0c
	bpl .loop
.ret
	rtl

.ofsXL
	db -$20, -$10, $00,  $10, $20
.ofsXH
	db   -1,   -1,   0,    0,   0
.spdY
	db  $17, -$17, $17, -$17, $17
.miscA
	db    0,    1,    0,   1,   0
.spdX
	db $10, -$10

RunOnceCandleFlames:
	lda #$01 : sta !dys_cls_active
	sta !spr_loadStatIndex,x
	lda #$07 : sta !spr_status+3 ; Wh????
	ldy #$03
.loop
	lda #$05 : sta !cls_id,y
	lda .ofsX,y : sta !cls_posXL,y
	lda #$f0 : sta !cls_posYL,y
	tya : asl #2 : sta !cls_miscA,y
	dey : bpl .loop
	rtl

.ofsX
	db $50, $90, $d0, $10

RunOnceBooCeiling:
	lda #$01 : sta !dys_sprLoadStatuses,x
	sta !dys_cls_active
	ldx #$13
.loop
	lda #$03
	sta !cls_id,x
	; stz !cls_miscG,x
	stz !cls_miscD,x
	jsl !ssr_NewRand
	adc $1a : sta !cls_posXL,x : sta !cls_miscA,x
	lda $1b : adc #$00 : sta !cls_posXH,x
	lda $148e : and #$3f : adc #$08 : clc : adc $1c : sta !cls_posYL,x
	lda $1d : adc #$00 : sta !cls_posXH,x
	dex : bpl .loop
	inc !WB|$18ba
	rtl

RunOnceBooRingCW:
	ldy #$01 : bra +
RunOnceBooRingCCW:
	ldy #$ff
+	lda !WB|$18ba : cmp #$02 : bcs .ret
	lda #$01 : sta !dys_sprLoadStatuses,x
	sta !dys_cls_active
	sty $0f
	lda #$09 : sta $0e
	stx $0d
	ldx #$13
.loop
	lda !cls_id,x : bne .while
	lda #$04 : sta !cls_id,x
	lda !WB|$18ba : sta !cls_miscD,x
	lda $0e : sta !cls_miscC,x
	lda $0f : sta !cls_miscA,x
	stz $0f
	beq +
	ldy !WB|$18ba
	lda $02 : sta $0fb2,y
	lda $03 : sta $0fb4,y
	lda $04 : sta $0fb6,y
	lda $05 : sta $0fb8,y
	lda #$00 : sta $0fba,y
	lda $0d : sta $0fbc,y
+
	dec $0e : bmi .end
.while
	dex : bpl .loop
.end
	inc $18ba
.ret
	rtl

RunOnceSwooperCeiling:
	lda #$01 : sta !dys_sprLoadStatuses,x
	sta !dys_cls_active
	ldx #$0e
.loop
	stz !cls_spdX,x
	stz !cls_miscD,x
	lda #$08 : sta !cls_id,x
	jsl !ssr_NewRand
	adc $1a : sta !cls_posXL,x
	lda $1b : adc #$00 : sta !cls_posXH,x
	lda $04 : sta !cls_posYL,x
	lda $05 : sta !cls_posYH,x
	dex : bpl .loop
	rtl

RunOnceBooCloud:
	lda #$01 : sta !dys_sprLoadStatuses,x
	sta !dys_cls_active
	stz $190a
	ldx #$13
.loop
	lda #$07 : sta !cls_id,x
	lda .miscS,x : and #$f0 : sta !cls_spdX,x
	lda .miscS,x : asl #4 : sta !cls_spdY,x
	lda .miscP,x : and #$f0 : sta !cls_posXF,x
	lda .miscP,x : asl #4 : sta !cls_posYF,x
	dex : bpl .loop
	rtl
.miscS
	db $31,$71,$a1,$43,$93,$c3,$14,$65
	db $e5,$36,$a7,$39,$99,$f9,$1a,$7a
	db $da,$4c,$ad,$ed
.miscP
	db $01,$51,$91,$d1,$22,$62,$a2,$73
	db $e3,$c7,$88,$29,$5a,$aa,$eb,$2c
	db $8c,$cc,$fc,$5d
