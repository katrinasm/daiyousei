;==============================================================================;
; Substitute Bullet Bill, by Katrina                                           ;
;------------------------------------------------------------------------------;
; A replacement for SMW’s Bullet Bill.                                         ;
;==============================================================================;
%dys_offsets(Main, Init)

;------------------------------------------------------------------------------;
; Customizations                                                               ;
;------------------------------------------------------------------------------;

;                               ^    |     ^   ^     /   \ 
;                     <-   ->   |    v    /     \   v     v
tiles:            db $a6, $a6, $a4, $a4, $a6, $a6, $a8, $a8
props:            db $42, $02, $03, $83, $03, $43, $03, $43
speedsX:          db $20,-$20, $00, $00, $18, $18,-$18,-$18
speedsY:          db $00, $00,-$20, $20,-$18, $18, $18,-$18

;------------------------------------------------------------------------------;
; Init routine                                                                 ;
;------------------------------------------------------------------------------;
Init:
	jsl !ssr_HorizPos : tya : sta !spr_miscA,x
	lda #$10 : sta !spr_timeA,x
	rtl
	
;------------------------------------------------------------------------------;
; Main routine                                                                 ;
;------------------------------------------------------------------------------;
Main:
	lda #$01 : sta !spr_facing,x
	lda $9d : bne .frozen

	ldy !spr_miscA,x
	lda props,y : sta !spr_tileProps,x
	lda speedsX,y : sta !spr_spdX,x
	lda speedsY,y : sta !spr_spdY,x
	jsl !ssr_TranslateX
	jsl !ssr_TranslateY
	jsl $019138!F
	jsl !ssr_CollideSprPlayer
	
.frozen
	jsl !ssr_Offscreen_X0
	
	ldy !spr_miscA,x
	lda !spr_timeA,x : bne .drawBehind
	rep #$20
	lda.w #tiles
	jml !ssr_GenericGfx_16x16

.drawBehind
	lda $64 : pha
	lda #$10 : sta $64
	rep #$20
	lda.w #tiles
	jsl !ssr_GenericGfx_16x16
	pla : sta $64
	rtl
