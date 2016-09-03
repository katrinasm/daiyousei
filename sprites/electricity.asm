;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Electricity, by mikeyk
;;
;; Description: This sprite bounces between two surfaces and can only be killed with a
;; star.
;;
;; Uses first extra bit: YES
;; If the first extra bit is set, the sprite will bounce vertically between two surfaces.
;; Otherwise the sprite will bounce horizontally between two surfaces.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%dys_offsets(Main, !ssr_FacePlayer)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite main code 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

RETURN:
	rtl
Main:
	jsr SPRITE_GRAPHICS
	lda !spr_status,x : cmp #$08 : bne RETURN
	jsl !ssr_Offscreen_X0
	lda $9d : bne RETURN
	
	lda !spr_extraBit,x : and #$04 : beq HORIZ_MOVEMENT
	jsr HANDLE_VERT
	bra CHECK_CONTACT
HORIZ_MOVEMENT:
	jsr HANDLE_HORIZ

CHECK_CONTACT:
	jsl !ssr_CollidePlayer : bcc RETURN
SPRITE_WINS:
	lda !spr_beingEaten,x : bne RETURN
	lda !WB|$1490 : bne HAS_STAR
	lda !WB|$187a : bne RETURN
	jml !ssr_HurtPlayer
	
HAS_STAR:
	lda #$02 : sta !spr_status,x
	jml !ssr_StarPoints

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

X_SPEED:
	db $18, -$18
HANDLE_HORIZ:
	ldy !spr_facing,x : lda X_SPEED,y : sta !spr_spdX,x
	stz !spr_spdY,x : jsl !ssr_Move
	
	lda !spr_blocked,x : and #$03 : beq .ret
	lda !spr_facing,x : eor #$01 : sta !spr_facing,x
.ret
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


Y_SPEED:
	db $18, -$18
HANDLE_VERT:
	ldy !spr_facing,x : lda Y_SPEED,y : sta !spr_spdY,x
	stz !spr_spdX,x : jsl !ssr_Move
	
	lda !spr_blocked,x : and #$0c : beq .ret
	lda !spr_facing,x : eor #$01 : sta !spr_facing,x
.ret
	rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; sprite graphics routine
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TILEMAP:
	db $e6, $c8

SPRITE_GRAPHICS:
	lda $14 : lsr #2 : clc : adc !dys_slot : and #$01 : tay
	rep #$20
	lda.w #TILEMAP
	jsl !ssr_GenericGfx_16x16
	rts
