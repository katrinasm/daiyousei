;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; , adapted by mikeyk
;;
;; Description: 
;;   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;big boo, boo, boo block
 
                    BLOCK_SPRITE_NUM    = $AF
                    BIG_BOO_SPRITE_NUM  = $28
                    
%dys_offsets(Main, Init)

Init:
	jsl !ssr_NewRand
	sta !spr_miscG,x
	rtl

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
T_EBB4:             db $01,$FF
T_F8CF:             db $08,$F8
T_F8D1:             db $01,$02,$02,$01

Main:
	jsl !ssr_Offscreen_X0
	lda #$10 : sta !WB|$18b6
	lda !spr_status,x : cmp #$08 : bne LBL_01
	lda $9d : beq LBL_02
LBL_01:
	jmp LBL_17
	
LBL_02:
	jsl !ssr_HorizPos
	lda !spr_timeA,x : bne LBL_03
	lda #$20 : sta !spr_timeA,x
	
	lda !spr_miscA,x : beq LBL_20
	lda $0f : clc : adc #$0a : cmp #$14 : bcc LBL_04
	
LBL_20:
	stz !spr_miscA,x
	cpy $76 : beq LBL_03
	inc !spr_miscA,x

LBL_03:
	lda $0f : clc : adc #$0a : cmp #$14 : bcc LBL_04
	lda !spr_timeE,x : bne LBL_12
	tya : cmp !spr_facing,x : beq LBL_04
	lda #$1f : sta !spr_timeE,x
	bra LBL_12

LBL_04:
	stz !spr_miscI,x : lda !spr_miscA,x : beq LBL_14
	lda #$03 : sta !spr_miscI,x
	ldy !spr_act,x : lda #$00 : inc ; ?
; This accelerates the boo if possible/necessary.
LBL_05:
	and $13 : bne LBL_11
	inc !spr_miscG,x : lda !spr_miscG,x : bne LBL_06
	lda #$20 : sta !spr_timeC,x
LBL_06:
	lda !spr_spdX,x : beq LBL_08 : bpl LBL_07
	inc #2
LBL_07:
	dec
LBL_08:
	sta !spr_spdX,x
	
	lda !spr_spdY,x : beq LBL_10 : bpl LBL_09
	inc #2
LBL_09:
	dec
LBL_10:
	sta !spr_spdY,x
LBL_11:
	bra LBL_16
	

LBL_12:
	cmp #$10 : bne LBL_13
	
	pha : lda !spr_facing,x : eor #$01 : sta !spr_facing,x : pla
	
LBL_13:
	lsr #3 : tay
	lda T_F8D1,y : sta !spr_miscI,x
LBL_14:
	stz !spr_miscG,x
	lda $13 : and #$07 : bne LBL_16
	jsl !ssr_HorizPos
	lda !spr_spdX,x : cmp T_F8CF,y : beq LBL_15
	clc : adc T_EBB4,y : sta !spr_spdX,x
	
LBL_15:
	lda $d3
	pha
	sec : sbc !WB|$18b6
	sta $d3
	lda $d4
	pha
	sbc #$00
	sta $d4
	
	jsl !ssr_VertPos
	
	pla : sta $d4
	pla : sta $d3
	
	lda !spr_spdY,x : cmp T_F8CF,y : BEQ LBL_16
	clc : adc T_EBB4,y : sta !spr_spdY,x
	
LBL_16:
	jsl !ssr_TranslateX
	jsl !ssr_TranslateY

LBL_17:
	lda !spr_status,x : cmp #$08 : bne LBL_19
	jsl !ssr_CollidePlayer
LBL_19:
	jsl $038398!F ; Boo graphics routines
	rtl                

T_FA37: db $8C,$C8,$CA
T_FA3A: db $0E,$02,$02

