;==============================================================================;
; Fropper, by Katrina                                                          ;
;==============================================================================;

%dys_offsets(Main, Init)

;------------------------------------------------------------------------------;
; defines and tables                                                           ;
;------------------------------------------------------------------------------;

	!JumpV	= $60    ; Jump speed, vertical
	!JumpH	= $20    ; Jump speed, horizontal
	!JumpRange = $30 ; How close Mario should be before the sprite jumps
	!FaceRange = $60 ; How close Mario should be for the sprite change faces

; tilemap - not jumping (second tile only shown when Mario within LookRange)
	!BodyTile = $80
	!FaceTile = $a1
	
; tilemap - jumping
jumpTileNums:	db	$82, $92
jumpTileOfsX:	db	$00, $00
jumpTileOfsY:	db	$00, $08


; generated from above, don't touch
faceXOfs:	db	5, 3
HopHSpeeds:	db	!JumpH, -!JumpH

;------------------------------------------------------------------------------;
; init routine                                                                 ;
;------------------------------------------------------------------------------;
Init:
	lda #$20 : sta !spr_timeA,x 	; set facearound timer
	jml !ssr_FacePlayer

;------------------------------------------------------------------------------;
; main routine                                                                 ;
;------------------------------------------------------------------------------;
Main:
	jsl !ssr_Offscreen_X0

	lda !spr_status,x : cmp #$08 : bne .inactive
	lda $9d : beq RealMain
.inactive
	jmp MoveDone

RealMain:

.faceMario
	jsl !ssr_HorizPos
	lda !spr_timeA,x : bne .noTurn	; check facearound timer
	lda #$20 : sta !spr_timeA,x	; set facearound
	tya : sta !spr_facing,x
.noTurn

Hop:
	lda !spr_blocked,x : and #$04 : beq .noHop
	stz !spr_spdX,x
	lda $0f : bpl + : eor #$ff : inc : +	; abs($0f)
	cmp #!JumpRange : bcs .noHop
	tya : sta !spr_facing,x
	lda.b #-!JumpV : sta !spr_spdY,x
	lda HopHSpeeds,y : sta !spr_spdX,x
	lda #$08 : sta !WB|$1dfc
.noHop
	
Move:
	jsl !ssr_Move
MoveDone:
	lda !spr_status,x : cmp #$08 : bne .dontInteractMario
	jsl !ssr_CollideSpr
	jsl !ssr_CollidePlayer
.dontInteractMario
	jsr Graphics
	rtl

;------------------------------------------------------------------------------;
Itxn:
	

;------------------------------------------------------------------------------;
; graphics routines                                                            ;
;------------------------------------------------------------------------------;
Graphics:

	jsl !ssr_GetDrawInfo

	; flip and tile props
	lda !spr_tileProps,x : ora $64 : sta $02
	lda !spr_facing,x : ror #3 : and #$40 : eor #$40 : tsb $02
	
	lda !spr_blocked,x : and #$04 : bne .grnd

.jump
	phx
	ldx #$01
.jumpLoop
	lda $00 : clc : adc jumpTileOfsX,x : sta !oam1_ofsX,y
	lda $01 : clc : adc jumpTileOfsY,x : sta !oam1_ofsY,y
	lda jumpTileNums,x : sta !oam1_tile,y
	lda $02 : sta !oam1_props,y
	iny #4
	inc $05 : dex : bpl .jumpLoop
	plx
	
.finishJump
	ldy #$02
	lda #$01
	jsl !ssr_FinishOamWrite
	rts

.grnd
	stz $05
	; face tile
	; only draw if distance between Mario and sprite is < !FaceRange
	lda !spr_posXL,x : sec : sbc $94 : bpl + : eor #$ff : inc : +
	cmp #!FaceRange : bcs .body
	phx
	lda !spr_facing,x : tax
	lda $00 : clc : adc faceXOfs,x : sta !oam1_ofsX,y
	plx
	lda $01 : clc : adc #$03 : sta !oam1_ofsY,y
	lda #!FaceTile : sta !oam1_tile,y
	lda $02 : sta !oam1_props,y
	phy : tya : lsr #2 : tay
	lda #$00 : sta !oam1_sizes,y
	ply
	iny #4
	inc $05
.body
	; body tile
	lda $00 : sta !oam1_ofsX,y
	lda $01 : sta !oam1_ofsY,y
	lda #!BodyTile : sta !oam1_tile,y
	lda $02 : sta !oam1_props,y
	phy : tya : lsr #2 : tay
	lda #$02 : sta !oam1_sizes,y
	ply

.finishGrnd
	ldy #$ff
	lda $05
	jsl !ssr_FinishOamWrite
	rts
	