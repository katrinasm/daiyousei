%dys_offsets(Main, !ssr_Nothing)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; main sprite sprite code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    !STUN_TIMER = $78
                    !FLASH_TIMER = $58
                    !EXPLODE_TIMER = $40

                    ;org $039513             ; ROM 0x19713 start of rex

SPEED_TABLE:        db $08,$F8             ; speed of rex, right, left
                    db $00,$00             ; speed of smushed rex, right, left
                    
Main:
	jsr SUB_GFX             ; draw rex gfx
	lda !spr_status,x : cmp #$08 : bne RETURN
	lda !spr_timeA,x : beq ALIVE : dec : bne EXPLODE
	stz !spr_status,x
RETURN:
	rtl
	
EXPLODE:
	phb : lda #$02 : pha : plb
	jsl $028086!F
	plb
	rtl
	
ALIVE:
	lda $9d : bne RETURN
	jsl !ssr_Offscreen_X0
	
FREEZE_REX:
	lda !spr_blocked,x : and #$0f : beq DONT_SET_TIME
	lda.b #!EXPLODE_TIMER : sta !spr_timeA,x
	lda #$09 : sta !WB|$1dfc
	                  
DONT_SET_TIME:
	jsl !ssr_Move
	jsl !ssr_CollideSpr
	jsl !ssr_CollidePlayer
NO_CONTACT:
	rtl
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; graphics routine - specific to rex
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

                    ;org $03964C

TILEMAP: db $2d

SUB_GFX:
	ldy #$00
	rep #$20
	lda.w #TILEMAP
	jsl !ssr_GenericGfx_16x16
	rts
