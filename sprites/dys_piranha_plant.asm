;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Piranha Plant/Venus Fire Trap, by imamelia
;;
;; This sprite encompasses all 48 Classic Piranha Plants and Venus Fire Traps,
;; using the extra byte to determine which sprite to act like.
;;
;; Extra bytes: 1
;;
;; Bit 0: Direction.  0 = up/left, 1 = right/down.
;; Bit 1: Orientation.  0 = vertical, 1 = horizontal.
;; Bit 2: Stem length.  0 = long, 1 = short.
;; Bit 3: Color.  0 = green, 1 = red.  (Red ones move even when the player is near.)
;; Bit 4: Sprite type.  0 = Piranha Plant, 1 = Venus Fire Trap.
;; Bit 5: Number of fireballs.  0 = spit 1, 1 = spit 2.  This is used only if bit 4 is set.
;; Bit 6: Unused.
;; Bit 7: Unused.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

%dys_offsets(Main, Init)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; defines and tables
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; !spr_miscD,x = holder for the sprite's initial Y position low byte
; !spr_miscE,x = holder for the sprite's initial X position low byte

Speed:			; the Piranha Plant's speed for each sprite state (inverted for down and right plants)
db $00,$F0,$00,$10		; in the pipe, moving forward, resting at the apex, moving backward

TimeInState:		; the time the sprite will spend in each sprite state, indexed by bits 2, 4, and 5 of the behavior table

db $30,$20,$30,$20	; long Piranha Plants
db $30,$18,$30,$18	; short Piranha Plants
db $30,$20,$60,$20	; long Venus Fire Traps spitting 1 fireball
db $30,$18,$60,$18	; short Venus Fire Traps spitting 1 fireball
db $FF,$FF,$FF,$FF	; null
db $FF,$FF,$FF,$FF	; null
db $30,$20,$90,$20	; long Venus Fire Traps spitting 2 fireballs
db $30,$18,$90,$18	; short Venus Fire Traps spitting 2 fireballs

; All of these tables are indexed by ----todf,
; where f = frame, d = direction, o = orientation, and t = type.

HeadXOffset:
db $00,$00,$00,$00,$00,$00,$10,$10,$00,$00,$00,$00,$00,$00,$10,$10

HeadYOffset:
db $00,$00,$10,$10,$00,$00,$00,$00,$00,$00,$10,$10,$00,$00,$00,$00

StemXOffset:
db $00,$00,$00,$00,$10,$10,$00,$00,$00,$00,$00,$00,$10,$10,$00,$00

StemYOffset:
db $10,$10,$00,$00,$00,$00,$00,$00,$10,$10,$00,$00,$00,$00,$00,$00

; up, down, left, right
; head:
; X=00/Y=00, X=00/Y=10, X=00/Y=00, X=10/Y=00
; stem:
; X=00/Y=10, X=00/Y=00, X=10/Y=00, X=00/Y=10

StemTilemap:			; the tiles used by the stem
db $ce,$ce,$ce,$ce,$88,$88,$88,$88,$ce,$ce,$ce,$ce,$88,$88,$88,$88

HeadTilemap:			; the tiles used by the head
db $AE,$AC,$AE,$AC,$80,$c2,$80,$c2,$a8,$aa,$a8,$aa,$a8,$aa,$a8,$aa

TileFlip:				; the X- and Y-flip of each tile
db $00,$00,$80,$80,$00,$00,$40,$40,$00,$00,$80,$80,$00,$00,$40,$40

; These two are different.  They are indexed by -----olc, where c = color and l = length.
; Add 1 to each of these values if you want the tile to use the second graphics page.

StemPalette:			; the palette of the stem tiles
db $0a,$08,$0a,$08,$0a,$08,$0a,$08

HeadPalette:			; the palette of the head tiles
db $08,$08,$08,$08,$08,$08,$08,$08

; This tile will be invisible because it has sprite priority setting 0,
; but it will go in front of the plant tiles to cover it up when it is in a pipe.
; That way, the plant tiles don't need to have hardcoded priority.
; This tile should be as close to square as possible.
; Note: The default value WILL NOT completely hide the tiles unless you have changed its graphics!
; But the only completely square tile in a vanilla GFX00/01 is the message box tile, which is set to be overwritten by default.

!CoverUpTile = $40			; the invisible tile used to cover up the sprite when it is in a pipe

; these two tables are indexed by the direction and orientation

CoverUpXOffset:		;
db $00,$00,$00,$10	;

CoverUpYOffset:		;
db $00,$10,$00,$00	;

InitOffsetYLo:
db $FF,$EF,$08,$08

InitOffsetYHi:
db $FF,$FF,$00,$00

InitOffsetXLo:
db $08,$08,$FF,$EF

InitOffsetXHi:
db $00,$00,$FF,$FF

VenusFrames:		; which head tile the Venus Fire Trap should use for each sprite state
db $00,$00,$01,$00

Clipping:
db $01,$14

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; init routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Init:
	lda !spr_xByte1,x	;
	sta !spr_miscC,x	;

	and #$03	;
	tay		; direction and orientation used to index inital offsets
	lda !spr_posYL,x	;
	clc		;
	adc InitOffsetYLo,y	; Y position low byte
	sta !spr_posYL,x	;
	lda !spr_posYH,x	;
	adc InitOffsetYHi,y	; Y position high byte
	sta !spr_posYH,x	;
	lda !spr_posXL,x	;
	clc		;
	adc InitOffsetXLo,y	; X position low byte
	sta !spr_posXL,x		;
	lda !spr_posXH,x	;
	adc InitOffsetXHi,y	; X position high byte
	sta !spr_posXH,x	;

	tya		;
	lsr		;
	tay		;
	lda Clipping,y	;
	sta !spr_props2,x	;

	lda !spr_miscC,x	; get the bits for the sprite state timer index
	and #$04	; bit 2
	sta !spr_miscB,x	;
	lda !spr_miscC,x	;
	and #$10	; bit 4
	lsr		;
	ora !spr_miscB,x	;
	sta !spr_miscB,x	;
	lda !spr_miscC,x	;
	and #$30	; bits 4 and 5
	cmp #$30		; if the sprite is a Venus Fire Trap that spits 2 fireballs...
	bne No2Fireballs	;
	lda !spr_miscB,x	; then add another 4 to the index
	clc		;
	adc #$04	;
	sta !spr_miscB,x	;
No2Fireballs:	;

EndInit1:		;
	lda !spr_posYL,x	;
	sta !spr_miscD,x	; back up the sprite's initial XY position (low bytes)
	lda !spr_posXL,x	;
	sta !spr_miscE,x	;

	rtl

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; main routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

EndMain:
	rtl

Main:
	;LDA !spr_miscH,x		; if the sprite is in a pipe and the player is near...
	;BNE NoGFX		; don't draw the sprite
	lda !spr_miscA,x		;
	beq NoGFX		;

	jsr PiranhaPlantGFX		; draw the sprite

NoGFX:			;
	jsl !ssr_Offscreen_X0		;

	lda $9D			; if sprites are locked...
	bne EndMain		; terminate the main routine right here

	lda !spr_miscC,x		;
	and #$10		; if the sprite is a Venus Fire Trap...
	beq PiranhaAnimation	; use a different routine for its animation

	ldy !spr_miscA,x		;
	lda VenusFrames,y		;
	sta !spr_miscI,x		;
	cpy #$02			;
	bne SkipPiranhaAnimation	;
	jsr FacePlayer		; always face the player if the Venus Fire Trap is out of the pipe
	bra SkipPiranhaAnimation	;

Fire:			;
	jsr SpitFireball		;
	rtl

PiranhaAnimation:		;
	jsr SetAnimationFrame	; determine which frame the plant should show

SkipPiranhaAnimation:	;
	lda !spr_miscH,x		; if the plant is in a pipe...
	bne NoInteraction		; don't let it interact with the player

	jsl $01803A		; interact with the player and with other sprites

NoInteraction:		;
	lda !spr_miscC,x		;
	and #$10		; if the sprite isn't a Venus Fire Trap...
	beq NoFireCheck		; don't check to see if it should spit a fireball

	lda !spr_miscA,x		; if the sprite is a Venus Fire Trap...
	cmp #$02			; then make sure it's in the correct sprite state (resting at the apex)
	bne NoFireCheck		;

	lda !spr_timeA,x		;
	cmp #$61			; if the fire timer
	beq Fire			; is at certain numbers...
	cmp #$19			; spit a fireball
	beq Fire			;

NoFireCheck:
	lda !spr_miscA,x		; use the sprite state
	and #$03		; to determine what the sprite's speed should be
	tay			;
	lda !spr_timeA,x		; if the timer for changing states has run out...
	beq ChangePiranhaState	;

	lda !spr_miscC,x		; check whether the sprite is rightside-up/left or upside-down/right
	lsr			;
	lda Speed,y		; load the base speed
	bcc StoreSpeed		; if upside-down/right...
	eor #$FF			; flip its speed
	inc			;
StoreSpeed:		;
	tay			; transfer the speed value to Y because we need to use A
	lda !spr_miscC,x		; check the secondary sprite state
	and #$02		; check whether the sprite is vertical or horizontal
	bne MoveHorizontally	;

	sty !spr_spdY,x		; store the speed value to the sprite Y speed table
	jsl !ssr_TranslateY		; update sprite Y position without gravity
	rtl	;

MoveHorizontally:		;
	sty !spr_spdX,x			; store the speed value to the sprite X speed table
	jsl !ssr_TranslateX		; update sprite X position without gravity
	rtl			;

ChangePiranhaState:	;
	lda !spr_miscC,x		;
	and #$10		; if the sprite is a Venus Fire Trap...
	beq NoFacePlayer		;
	lda !spr_miscA,x		; and it is about to come out of the pipe...
	bne NoFacePlayer		;

	jsr FacePlayer		;

NoFacePlayer:		;
	lda !spr_miscA,x		; sprite state
	and #$03		; 4 possible states, so we need only 2 bits
	sta $00			; store to scratch RAM for subsequent use
	lda !spr_miscC,x		;
	and #$08		; if the plant is a red one...
	ora $00			; or the sprite isn't in the pipe...
	bne NoProximityCheck	; don't check to see if the player is near

	lda !spr_miscC,x			;
	and #$02			; if the sprite is a vertical one...
	bne VertCheck			; get the vertical distance between the player and the sprite 
	jsl !ssr_HorizPos		; else, get the horizontal distance between the player and the sprite
	bra SkipVertCheck		;
VertCheck:			;
	jsl !ssr_VertPos		;
SkipVertCheck:		;

	lda #$01			;
	sta !spr_miscH,x		; set the invisibility flag if necessary
	lda $0F			;
	clc			;
	adc #$1B			; if the sprite is within a certain distance...
	cmp #$37			;
	bcc EndStateChange	; don't change the sprite state

NoProximityCheck:		;
	stz !spr_miscH,x		; if the sprite is out of range, clear the invisibility flag
	lda !spr_miscA,x		;
	inc			; increment the sprite state
	and #$03		;
	sta !spr_miscA,x		;
	sta $00			;
	lda !spr_miscC,x		;
	and #$04		; use the stem length bit
	tsb $00			;
	lda !spr_miscC,x		;
	and #$30		; and the Venus Fire Trap bits
	lsr			;
	ora $00
	tay			; to set the timer for changing sprite state
	lda TimeInState,y		;
	sta !spr_timeA,x		; set the time to change state

EndStateChange:		;
	rtl

SetAnimationFrame:		;
	inc !spr_miscG,x		; !spr_miscG,x - individual sprite frame counter, in this context
	lda !spr_miscG,x		;
	lsr #3			; change image every 8 frames
	and #$01		;
	sta !spr_miscI,x		; set the resulting image
	rts

FacePlayer:		;
	jsl !ssr_VertPos		;
	tya			;
	asl			;
	sta !spr_facing,x		;

	lda !spr_miscC,x		;
	and #$02		;
	bne FixedH		; the sprite's horizontal direction is always the same if it is a horizontally-moving Venus Fire Trap

	jsl !ssr_HorizPos		;
	tya			; make it face the player
	ora !spr_facing,x		;
	sta !spr_facing,x		;

	rts			;

FixedH:
	lda !spr_miscC,x		;
	and #$01		;
	eor #$01			;
	sta $00			;
	lda !spr_facing,x		;
	and #$02		;
	ora $00			;
	sta !spr_facing,x		;

	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; graphics routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PiranhaPlantGFX:		; I made my own graphics routine, since the Piranha Plant uses a shared routine.
	jsl !ssr_GetDrawInfo		; set some variables up for writing to OAM

	lda !spr_miscC,x		;
	and #$04		; stem length
	lsr			;
	sta $04			;
	lda !spr_miscC,x		;
	and #$08		;
	lsr #3			; plus color
	tsb $04			;
	lda !spr_miscC,x		;
	and #$02		;
	asl				;
	tsb $04			; plus orientation


	lda !spr_miscI,x		;
	sta $03			; frame = bit 0 of the index
	lda !spr_miscC,x		;
	and #$03		; direction and orientation
	asl			;
	tsb $03			; bits 1 and 2 of the index
	lda !spr_miscC,x		;
	and #$10		; type
	lsr			;
	ora $03			; bit 3 of the index
	sta $03			;

	lda !spr_miscC,x		;
	and #$04		; if the plant has a short stem...
	bne AlwaysCovered		; then the stem is always partially obscured by the cover-up tile

	lda !spr_miscA,x		;
	cmp #$02			; if the sprite is all the way out of the pipe...
	beq StemOnly		; then draw just the stem

AlwaysCovered:		;
	lda !spr_miscC,x		;
	and #$01		;
	sta $08			; save the direction bit for use with the cover-up routine

	lda !spr_posYL,x		;
	sec			;
	sbc !spr_miscD,x		;
	sta $06			;
	lda !spr_posXL,x		;
	sec			;
	sbc !spr_miscE,x		;
	clc			;
	adc $06			;
	ldx $08			;
	beq NoFlipCheckVal	;
	eor #$FF			;
	inc			;
NoFlipCheckVal:		;
	clc			;
	adc #$10		;
	cmp #$20			;
	bcc CoverUpTileOnly	;

StemAndCoverUpTile:	;
	jsr DrawCoverUpTile	;
	iny #4			;
	jsr DrawStem		;
	lda #$02			;
EndGFX:			;
	pha			;
	iny #4			;
	ldx $03			;
	jsr DrawHead		; the head tile is always drawn
	pla			;
	ldy #$02			;
	ldx !dys_slot		;
	jsl !ssr_FinishOamWrite		;
	rts			;

StemOnly:		;
	jsr DrawStem		;
	lda #$01			;
	bra EndGFX		;

CoverUpTileOnly:		;

	jsr DrawCoverUpTile	;
	lda #$01			;
	bra EndGFX		;

DrawHead:
	lda $00			;
	clc			;
	adc HeadXOffset,x		; set the X offset for the head tile
	sta !oam1_ofsX,y		;

	lda $01			;
	clc			;
	adc HeadYOffset,x		; set the Y offset for the head tile
	sta !oam1_ofsY,y		;

	lda HeadTilemap,x		; set the tile for the head
	sta !oam1_tile,y

	ldx !dys_slot		;
	lda !spr_miscC,x		;
	and #$10		;
	bne VenusFlip		;

	ldx $03			;
	lda TileFlip,x		; load the XY flip for the tiles
	ldx $04			; load the palette index
	ora HeadPalette,x		; add in the palette/GFX page bits
	ora $64			; and the level's sprite priority
	sta !oam1_props,y		;

	rts

VenusFlip:		;
	lda !spr_facing,x		;
	ror #3			;
	and #$C0		;
	eor #$40			;
	ldx $04			;
	ora HeadPalette,x		;
	ora $64			;
	sta !oam1_props,y		;

	rts			;

DrawStem:
	ldx $03

	lda $00			;
	clc			;
	adc StemXOffset,x		; set the X offset for the stem tile
	sta !oam1_ofsX,y		;

	lda $01			;
	clc			;
	adc StemYOffset,x		; set the Y offset for the stem tile
	sta !oam1_ofsY,y		;

	lda StemTilemap,x		; set the tile for the stem
	sta !oam1_tile,y

	lda TileFlip,x		; load the XY flip for the tiles
	ldx $04			; load the palette index
	ora StemPalette,x		; add in the palette/GFX page bits
	ora $64			; and the level's sprite priority
	sta !oam1_props,y		;

	rts			;

DrawCoverUpTile:		;
	ldx $15E9		;

	lda !spr_miscE,x		;
	sta $09			;
	lda !spr_miscD,x		; make backups of the XY init positions
	sta $0A			;

	lda !spr_miscC,x		;
	and #$03		;
	tax

	lda $09			;
	sec			;
	sbc $1A			;
	clc			;
	adc CoverUpXOffset,x	;
	sta !oam1_ofsX,y		;

	lda $0A			;
	sec			;
	sbc $1C			;
	clc			;
	adc CoverUpYOffset,x	;
	sta !oam1_ofsY,y		;

	lda #!CoverUpTile		;
	sta !oam1_tile,y		;

	lda #$00			;
	sta !oam1_props,y		;

	rts			;

	ldx !dys_slot		; sprite index back into X
	ldy #$02			; the tiles were 16x16
	lda $05			; we drew 2 or 3 tiles
	jsl !ssr_FinishOamWrite		;

	rts			;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Venus Fire Trap fireball-spit routine
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FireXOffsetsLo:
db $0F,$FA,$0E,$00,$0E,$FE,$0D,$FE,$FB,$FB,$FE,$FE,$1D,$1D,$1D,$1D
FireXOffsetsHi:
db $00,$FF,$00,$00,$00,$FF,$00,$FF,$FF,$FF,$FF,$FF,$00,$00,$00,$00
FireYOffsetsLo:
db $09,$09,$FF,$FF,$18,$18,$13,$13,$06,$06,$01,$01,$0A,$0A,$01,$01
FireYOffsetsHi:
db $00,$00,$FF,$FF,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
FireXSpeeds:
db $08,$F8,$08,$F8
FireYSpeeds:
db $06,$06,$FA,$FA

SpitFireball:
	ldy #$07
ExSpriteLoop:
	lda !xsp_id,y : beq FoundExSlot
	dey : bpl ExSpriteLoop
	rts

FoundExSlot:
	sty $00

	lda #$02 : sta !xsp_id,y

	lda !spr_miscC,x : and #$03 : asl #2 : sta $01
	lda !spr_facing,x : tsb $01

	lda !spr_facing,x : sta $02

	lda !spr_posXL,x
	ldy $01
	clc : adc FireXOffsetsLo,y
	ldy $00
	sta !xsp_posXL,y
	lda !spr_posXH,x
	ldy $01
	adc FireXOffsetsHi,y
	ldy $00
	sta !xsp_posXH,y

	lda !spr_posYL,x
	ldy $01
	clc
	adc FireYOffsetsLo,y
	ldy $00
	sta !xsp_posYL,y
	lda !spr_posYH,x
	ldy $01
	adc FireYOffsetsHi,y
	ldy $00
	sta !xsp_posYH,y

	ldy $02
	lda FireXSpeeds,y
	ldy $00
	sta !xsp_spdX,y
	ldy $02
	lda FireYSpeeds,y
	ldy $00
	sta !xsp_spdY,y

	lda #$ff : sta !xsp_miscB,y

	rts
