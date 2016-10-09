;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Birdo, by mikeyk
;;
;; Description: Birdo walks back and forth spitting eggs at Mario
;;
;; Uses first extra bit: NO
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%dys_offsets(Main, Init)
    !jumpTimer  = !spr_timeE
	!throwTimer = !spr_timeB

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TILEMAP:
	db $8e, $ae
	db $8e, $ee
	db $ce, $ae

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; init JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Init:
	txa : and #$03 : asl #5
	sta !jumpTimer,x
	adc #$22 : sta !throwTimer,x
	jml !ssr_FacePlayer

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main sprite JSL
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main sprite routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

X_SPEED:     db $00,-$08, $00, $08 ;rest at bottom, moving up, rest at top, moving down
TIME_IN_POS: db $50, $20, $50, $20 ;moving up, rest at top, moving down, rest at bottom

RETURN:
	rtl
Main:
	jsl !ssr_FacePlayer
	jsr SUB_GFX
	lda !spr_status,x : cmp #$08 : bne RETURN
	lda $9d : bne RETURN

	jsl !ssr_Offscreen_X0
	inc !spr_miscG,x

	lda !spr_miscD,x : and #$01 : beq +
	lda !spr_miscG,x : lsr #3 : and #$01
+	sta !spr_miscI,x


	lda !throwTimer,x : cmp #$10 : bcs JUMP_BIRDO  ; if Birdo is about to spit,
	lda #$02 : sta !spr_miscI,x                    ; change pose to spitting
	; Birdo isn’t counted as moved this frame
	inc !spr_timeA,x
	inc !jumpTimer,x
	stz !spr_spdX,x
	lda !throwTimer,x : bne NO_RESET
	lda #$90 : sta !throwTimer,x
NO_RESET:
	cmp #$05 : bne NO_THROW
	jsr SUB_HAMMER_THROW
NO_THROW:
	bra APPLY_SPEED

JUMP_BIRDO:
	lda !jumpTimer,x
	cmp #$28                ;  |   just go to normal walking code
	bcs WALK_BIRDO          ; /
	inc !spr_timeA,x             ; we didn't move birdo this frame, so we don't want a decrement
	stz !spr_spdX,x               ; stop birdo from moving
	lda !jumpTimer,x
	cmp #$20
	bne NO_JUMP2
	lda #!spr_posYL                ; \  y speed
	sta !spr_spdY,x               ; /
	bra APPLY_SPEED
NO_JUMP2:
	cmp #$00
	bne NO_JUMP
	lda #$ff
	sta !jumpTimer,x
NO_JUMP:
	bra APPLY_SPEED         ;


WALK_BIRDO:
	lda !spr_miscD,x             ;
	and #$03
	tay                     ;
	lda !spr_timeA,x             ;
	beq CHANGE_SPEED        ;
	lda X_SPEED,y           ; | set y speed
	sta !spr_spdX,x               ; /
	bra APPLY_SPEED

CHANGE_SPEED:
	lda TIME_IN_POS,y       ;A:0001 X:0007 Y:0000 D:0000 DB:01 S:01F5 P:envMXdiZCHC:0654 VC:057 00 FL:24235
	sta !spr_timeA,x             ;A:0020 X:0007 Y:0000 D:0000 DB:01 S:01F5 P:envMXdizCHC:0686 VC:057 00 FL:24235
	inc !spr_miscD,x

APPLY_SPEED:
	jsl !ssr_Move            ; update position based on speed values

	lda !spr_blocked,x             ; \ if hammer bro is touching the side of an object...
	and #$03                ;  |
	beq DONT_CHANGE_DIR     ;  |
	inc !spr_miscD,x             ; /

DONT_CHANGE_DIR:
	jsl !ssr_CollideSpr      ; interact with other sprites
	jsl !ssr_CollidePlayer   ; check for mario/hammer bro contact
NO_CONTACT:
	rtl                     ; return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; hammer routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

X_OFFSET:           db $06,-$06
X_OFFSET2:          db $00,-$01

SUB_HAMMER_THROW:
	lda !spr_offscreenH,x             ; \ no egg if off screen
	ora !spr_offscreenV,x             ;  |
	ora !spr_beingEaten,x
	bne .ret

	lda !spr_xProps1,x : lsr : bcs .custom
.bulletBill
	stz $01
	lda #$1c : sta $00
	bra +
.custom
	lda !spr_extraBit,x : sta $01
	lda !spr_custNum,x : inc : sta $00
+
	jsl !ssr_SpawnSprite
	bmi .ret
	lda #$20 : sta !WB|$1df9

	phy
	lda !spr_facing,x : tay
	lda !spr_posXL,x : clc : adc X_OFFSET,y
	ply
	sta !DP|!spr_posXL,y

	phy
	lda !spr_facing,x : tay
	lda !spr_posXH,x : adc X_OFFSET2,y
	ply
	sta !DP|!spr_posXH,y

	lda !spr_posYL,x : sec : sbc #$0e : sta !DP|!spr_posYL,y
	lda !spr_posYH,x : sbc #$00 : sta !DP|!spr_posYH,y

	lda !spr_facing,x
	tyx
	; The bullet bill uses miscA for its direction instead of facing like other sprites.
	; This is, presumably, because SMW wanted to be a nuisance to ROM-hackers.
	sta !spr_facing,x : sta !DP|!spr_miscA,y
	ldx !dys_slot
.ret
	rtl


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SUB_GFX:
	rep #$20
	ldy !spr_miscI,x
	lda.w #TILEMAP
	jsl !ssr_GenericGfx_16x32
	rts
