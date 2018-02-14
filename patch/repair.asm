@include

macro put_rtl(addr)
	pushpc
		org <addr>
			rtl
	pullpc
endmacro

macro put_jsr(addr, label)
	pushpc
		org <addr>
			jsr <label>
	pullpc
endmacro

if !opt_noOriginals == 0
pushpc
;=============================================================================;
; Original game: rts -> rtl                                                   ;
;=============================================================================;

;-----------------------------------------------------------------------------;
; Miscellaneous fixes                                                         ;
;-----------------------------------------------------------------------------;
; Because Daiyousei makes no use of it, and nothing else should either,
; we use the sprite init pointer table as a bit of bank 1 freespace.

	org $01817d!F
	EraseSprite:
		; This is part of bank 1's suboffscreen, which some bank 1 sprites
		; jump to (as in jmp) to erase themselves. Of course this suboffscreen
		; is an rts subroutine, so it'll crash the sprites, which need an rtl.
		; So here we call it and then rtl! magical.
		jsr $ac80
	Bank1Rtl:
		rtl
		; Several sprites call the exploding block initializer with jsr.
	ExplodeBlock:
		jsl $0183a4!F : rts
		; FaceMario is actually the end of a sprite initializer, so it needs
		; to be rtl, so here we have another stupid fix.
	FaceMario:
		jsl $01857c!F : rts

		; Graphics routines, even when shared, need to be rts because of
		; how getdrawinfo works. Awesome, right?
	SubSprGfx2Entry1:
		jsr $9f0d : rtl
	SubSprGfx0Entry0:
		jsr $9cf3 : rtl

	Flower:
		jsr $c349 : rtl
	Powerups:
		jsr $c353 : rtl
	Feather:
		jsr $c6ed : rtl
	BulletBill:          ; jmp -> rts
		jsr $8fe7 : rtl
	KoopaKid:
		jsr $fac1 : rtl
	Podoboo:             ; jmp -> rts
		jsr $e093 : rtl
	BossFireball:        ; Calls GetDrawInfo
		jsr $d44e : rtl
	Yoshi:
		jsr $ebca : rtl
	Parachute:
		jsr $d4fb : rtl
	Platforms2:          ; Calls GetDrawInfo
		jsr $b563 : rtl
	OrangePlatform:      ; Calls Platforms2 (jesus)
		jsr $b536 : rtl
	SpikeBall:           ; jmp -> rts
		jsr $b559 : rtl
	Keyhole:             ; Calls GetDrawInfo
		jsr $e1c8 : rtl
	LakitusCloud:        ; jmp -> Calls GetDrawInfo -> rts
		jsr $e7a4 : rtl
	Lakitu:              ; jmp -> rts
		jsr $8f97 : rtl

	org $0185cc!F
	ExecPtrRtl:
		sty $03
		ply
		sty $00
		asl
		tay
		rep #$30
		iny
		pla
		sta $01
		lda [$00],y
		sta $00
		sep #$30
		ldy $03
		pea Bank1Rtl-1
		jml [$0000]

	WhistlinChuck:
		lda #$d3 : sta !gen_id
		lda #$00 : sta !gen_extraBits
		rtl

	ShellessKoopas:
		jsr $8904 : rtl

	Spr0to13Start:
		jsr $8afc : rtl
	GreenParaKoopa:
		jsr $8c4d : rtl
	RedHorzParaKoopa:
		jsr $8cbe : rtl
	RedVertParaKoopa:
		jsr $8cc3 : rtl
	Bobomb:
		jsr $8ae5 : rtl
	WingedGoomba:
		jsr $8d2e : rtl
	FlyingItem:
		jsr $c1f2 : rtl
	YoshiEgg:
		jsr $a2b5 : rtl
	LineGuideEnd:
		jsl $01d74d!F : rts
	LinePlats:
		jsl $01d74a!F : rts
	StunSpringboard:
		jsl $01e6f0!F : rts

;-----------------------------------------------------------------------------;
; Init routines                                                               ;
;-----------------------------------------------------------------------------;
; Note that some oddities in this part occur because a few routines just jump
; to another one, and those ones are changed in the init table in
; sprite_settings.asm.

		%put_rtl($018313) ; grey lava platform
		%put_rtl($018325) ; bowser statue
		%put_rtl($018334) ; timed platforms
		%put_rtl($01834b) ; yoshi egg
		%put_rtl($01835a) ; "diag bouncer"
		%put_rtl($01836a) ; wood spike 1
		%put_rtl($01837c) ; sumo bro, sliding koopa
		%put_rtl($018386) ; growing/shrinking pipe
		%put_rtl($01839f) ; grey chain platform / ball 'n' chain
		%put_rtl($0183b2) ; exploding block
		%put_rtl($0183d9) ; scale platform mushrooms
		%put_rtl($0183df) ; message/side exit
		%put_rtl($0183ee) ; yoshi
		%put_rtl($018434) ; Rip Van Fish, urchin
		%put_rtl($01843a) ; key, baby yoshi
		%put_rtl($01843d) ; changing item
		%put_rtl($01844d) ; wall springboard (pea thing)
		%put_rtl($018465) ; p switch
		; lakitu (partial), monty mole, wood spike 2, creating/eating block,
		; probably more; it's basically the "change state based on xpos & 1" thing
		%put_rtl($0184d5)
		%put_rtl($0184e8) ; bullet bill
		%put_rtl($018525) ; various chucks (1)
	org $01851c!F : jsr FaceMario ; various chucks (2)
		%put_rtl($018583) ; a lot, incl. koopas, and many sprites that face mario
		%put_rtl($01858d) ; powerups
		%put_rtl($0185c2) ; piranha plants
		%put_rtl($018892) ; moving ledge
		%put_rtl($01e1c7) ; keyhole
		%put_rtl($01b011) ; vertical fish
		%put_rtl($01b01c) ; other fish
		%put_rtl($01bdce) ; magikoopa (1)
		%put_rtl($01bdd5) ; magikoopa (2)
		%put_rtl($01b968) ; net koopas
		%put_rtl($01aea2) ; thwomp
		%put_rtl($01f88b) ; eerie, big boo, boo
	org $01f8cc!F : jmp SubSprGfx2Entry1
	org $01fb8b!F : jsr FaceMario ; Koopa Kids
		%put_rtl($01cd4d)         ; Koopa Kids
	org $01cd5a!F : jmp $857c     ; Koopa Kids
		%put_rtl($01cd5d)
		%put_rtl($01cd86)
		%put_rtl($01cd91)
		%put_rtl($01ba94) ; climbing door
	org $01b216!F : jsr FaceMario ; Floating spike ball
		%put_rtl($01b235) ; platforms
		%put_rtl($01b25d) ; Floating platforms
		%put_rtl($01b261) ; checkerboard platforms
		%put_rtl($01b267) ; more platforms
		%put_rtl($01c772) ; brown chain platform
	org $01d6e3!F : jsr LinePlats ; line guided stuff
	org $01d6e6!F : jsr LinePlats ; line guided stuff
		%put_rtl($01d6ec) ; line guided stuff
		%put_rtl($01d716) ; line guided stuff
		%put_rtl($01ad67) ; flying "?" blocks
	org $018317!F : jsr ExplodeBlock ; Bowser statue explodeblock call
	org $01834e!F : jsr FaceMario ; "Diag bouncer" facemario call
	org $01838d!F : jmp EraseSprite ; Banzai Bill erasesprite jmp
		%put_rtl($018395) ; Banzai Bill?
	org $01852e!F : jsr FaceMario ; Feathered super koopa facemario call
		%put_rtl($018546) ; Feathered super koopa (1)
		%put_rtl($01854a) ; Feathered super koopa (2)
	org $01846b!F : ldy.b #!dys_maxActive-1 ; lakitu
	org $018468!F : jmp EraseSprite ; Lakitu erasesprite jmp

		%put_rtl($01e07a) ; Podoboo
		%put_rtl($01ba94) ; Climbing Net Door


		; Now then, a bunch of sprites init routines go and call each other to save
		; a few bytes here and there. Since SMW used jsr's and we're using jsls, we
		; have to rewrite a couple things to make space for the extra opcode byte.
	org $0183f2!F
		; This init is 1 byte shorter than the original even with the jsl,
		; so the next routine also has room for a jsl now.
	InitSpikeTop:
		jsr $ad30 ; bank 1 subhorizpos
		lda .pos,y
		jsl $01841d!F
		stz !spr_inWater,x
		bra InitFuzzSpark_stcall
	.pos
		db $10, $00
	InitWallUrchin:
		inc !spr_posYL,x : bne + : inc !spr_posYH,x : +
	InitFuzzSpark:
		jsl $01841b!F
	.stcall
		lda !spr_miscD,x : eor #$10 : sta !spr_miscD,x
		lsr #2 : sta !spr_miscA,x
		rtl

	org $01c089!F ; Goal tape init (extra bits)
		lda !spr_extraBit,x : sta !spr_miscL,x
		lda !spr_posYH,x : sta !spr_miscF,x
		rtl


	; Bonus game
	; this sprite normally overwrites itself, but because Daiyousei puts it in a
	; different slot it doesn’t. fortunately there is room enough
	; to make sure it always deletes itself.

	org $01ddac!F
		stz !spr_status,x
		lda !WB|$1b94 : beq + : rtl : +
	%put_rtl($01de10)

;-----------------------------------------------------------------------------;
; Main routines                                                               ;
;-----------------------------------------------------------------------------;
		%put_rtl($018788)                ; goal sphere
	org $018c49!F : jmp SubSprGfx0Entry0 ; spiny egg
	org $01895b!F : jsr FaceMario        ; Koopas
	org $018b6c!F : jsr FaceMario        ; Koopas
		%put_rtl($018ec7)                ; piranha plants (1)
		%put_rtl($018eee)                ; piranha plants (2)
		%put_rtl($018f4f)                ; hopping flame
	org $019679!F : jsr FaceMario        ; Koopas (stunned)
	org $018c38!F : jsr FaceMario        ; spiny egg
	org $018d74!F : jsr FaceMario        ; winged goomba
	org $018f61!F : jsr FaceMario        ; hopping flame
	org $0198ba!F : jsr FaceMario        ; koopas et al?
		%put_rtl($01ae7e)                ; flying "?" block
	org $01aeb9!F : jsl ExecPtrRtl       ; Thwomp
	org $01b008!F : jmp SubSprGfx0Entry0 ; Thwimp
	org $01b00b!F : jsr FaceMario        ; vertical fish
		%put_rtl($01b129)                ; fish
		%put_rtl($01b1b0)                ; generator fish
		%put_rtl($01b2c2)                ; platforms
		%put_rtl($01b6b1)                ; horizontal / vertical turn block bridge
		%put_rtl($01b9fa)
		%put_rtl($01b6e6)                ; horitontal only turn block bridge
		%put_rtl($01ba7e)
		%put_rtl($01bacc)                ; Climbing Net Door (1)
		%put_rtl($01bc1c)                ; Climbing Net Door (2)
	org $01bde6!F : jsl ExecPtrRtl ; Magikoopa
		%put_rtl($01bcbc)                ; magikoopa's magic
		%put_rtl($01bcdf)                ; magikoopa's magic
	org $01c1c8!F : jmp EraseSprite      ; Growing vine (1)
		%put_rtl($01c1ed)                ; Growing vine (2)
		%put_rtl($01c344)                ; Changing item
		%put_rtl($01c0a4)                ; Goal tape (1)
		%put_rtl($01c12c)                ; Goal tape (2)
		%put_rtl($01c21c)                ; flying items (1)
		%put_rtl($01c286)                ; flying items (3)
		%put_rtl($01c2cd)                ; flying items (4)
		%put_rtl($01c2d2)                ; flying items (5)
		%put_rtl($01c30e)                ; flying items (6)
		%put_rtl($01c312)                ; flying items (7)
	org $01c9b3!F : jsr $c9ec : rtl      ; brown chained platform
	org $01cd5a!F : jsr FaceMario        ; koopa kids
	org $01d75e!F : jsl ExecPtrRtl       ; line guided stuff
	org $01d9dc!F : jsr LineGuideEnd     ; line guided stuff
		%put_rtl($01da09)                ; line guided stuff
		%put_rtl($01da8f)                ; line guided stuff
	org $01dae3!F : jsr LineGuideEnd     ; line guided stuff
		%put_rtl($01db43)                ; line guided stuff
		%put_rtl($01db95)                ; grinder
		%put_rtl($01de40)                ; Bonus game
		%put_rtl($01deaf)                ; Bonus game
		%put_rtl($01ded6)                ; Bonus game
	org $01e2d4!F : jsl ExecPtrRtl       ; Monty Mole (1)
	org $01e320!F : jsr FaceMario        ; monty mole (2)
	org $01e3a9!F : jsr FaceMario        ; Monty Mole
	org $01e44f!F : jsr FaceMario        ; dry bones, bony beetle
	org $01e55e!F : jsr FaceMario        ; dry bones, bony beetle
	org $01e60d!F : jsr FaceMario        ; dry bones, bony beetle
		%put_rtl($01e4bf)                ; dry bones, bony beetle
		%put_rtl($01e5c3)                ; dry bones, bony beetle
		%put_rtl($01e6fc)                ; springboard
		%put_rtl($01e76e)                ; p-switch
		%put_rtl($01f798)                ; yoshi egg (1)
		%put_rtl($01f7c1)                ; yoshi egg (2)
		%put_rtl($01f866)                ; yoshi egg (3)
	org $01f867!F : jml !ssr_InitViaAct  ; yoshi egg (4)
	org $01f870!F : jmp YoshiEgg         ; yoshi egg (4)
		%put_rtl($01fa36)                ; boos (1)
		%put_rtl($01fa4b)                ; boos (2)
		%put_rtl($01fab3)                ; Iggy's ball
	org $01fac3!F : jsl ExecPtrRtl       ; Koopa kids

		%put_rtl($02b42c) ; Torpedo Ted launcher (1)
	org $02b3ca!F : bne TedRet ; Torpedo Ted launcher (2)
	org $02b3d6!F : bne TedRet ; Torpedo Ted launcher (3)
	org $02b42c!F : TedRet:
		%put_rtl($02b463) ; Torpedo Ted launcher (4)

		%put_rtl($02b4dd) ; Bullet Bill shooter

		%put_rtl($02b031) ; Turn off generator 2
		%put_rtl($02b035) ; turn off generator 1
		%put_rtl($02b07b) ; fire generator
		%put_rtl($02b0c8) ; bullet bill generator
		%put_rtl($02b0f9) ; four-way bullet bill generator
		%put_rtl($02b1b7) ; jumping fish generator
		%put_rtl($02b206) ; super koopa generator
		%put_rtl($02b259) ; bubble sprite generator
		%put_rtl($02b287) ; dolphin generator (1)
		%put_rtl($02b2cf) ; dolphin generator (2)
		%put_rtl($02b31e) ; eerie generator
		%put_rtl($02b386) ; para-sprite generator
		%put_rtl($038489) ; grey falling platform
		%put_rtl($0384f4) ; blurp (1) | swooper (1)
		%put_rtl($03852a) ; blurp (2)
		%put_rtl($038586) ; Porcu-Puffer
		%put_rtl($03871a) ; grey lava platform
		%put_rtl($038733) ; grey lava platform, mega mole
		%put_rtl($03881d) ; mega mole
		%put_rtl($03882a) ; mega mole
		%put_rtl($0389e2) ; sliding blue koopa (1)
		%put_rtl($0389eb) ; sliding blue koopa (2)
		%put_rtl($0389fe) ; sliding blue koopa (3)
		%put_rtl($038086) ; bouncing football
		%put_rtl($0388df) ; swooper (2)
		%put_rtl($038904) ; swooper (3)
		%put_rtl($038935) ; swooper (4)
		%put_rtl($038a68) ; bowser statue
		%put_rtl($038abe) ; bowser statue
		%put_rtl($038ac6) ; bowser statue
		%put_rtl($038c21) ; Carrot lift
		%put_rtl($038ce3) ; Carrot lift
		%put_rtl($038dba) ; info box
		%put_rtl($038def) ; timed lift
		%put_rtl($038dfe) ; timed lift
		%put_rtl($038ea7) ; castle block
		%put_rtl($038f06) ; bowser statue fireball
		%put_rtl($038ff1) ; boo beam
		%put_rtl($0390ea) ; Fishin' Boo
		%put_rtl($039261) ; falling spike
		%put_rtl($03926b) ; falling spike
		%put_rtl($03926e) ; falling spike
		%put_rtl($039533) ; rex (1)
		%put_rtl($0395c0) ; rex (2)
		%put_rtl($0395c9) ; rex (3)
	org $0395d9!F : jml $00f5b7!F ; rex (4)
		%put_rtl($0395dd) ; rex (5)
		%put_rtl($0395f1) ; rex (6)
		%put_rtl($039624) ; rex (7)
		%put_rtl($03972a) ; fishbone
		%put_rtl($039755) ; fishbone
		%put_rtl($03975d) ; fishbone
		%put_rtl($039772) ; fishbone
		%put_rtl($039775) ; fishbone
		%put_rtl($03977d) ; fishbone
		%put_rtl($03932b) ; creating/eating block (1)
		%put_rtl($039386) ; creating/eating block (1)
		%put_rtl($03938a) ; creating/eating block (1)
		%put_rtl($039ca3) ; dino rhino
		%put_rtl($039d00) ; dino rhino
		%put_rtl($039d9d) ; dino rhino
		%put_rtl($039af7) ; reznor
		%put_rtl($03a263) ; bowser
		%put_rtl($03a12d) ; invisible mushroom
		%put_rtl($03a151) ; firework
		%put_rtl($03a15a) ; peach
		%put_rtl($03a163) ; big boo boss
		%put_rtl($03a221) ; wooden spikes
		%put_rtl($03a245) ; blargg
		%put_rtl($03b306) ; mechakoopa
		%put_rtl($03b1d4) ; bowling ball
		%put_rtl($03c25a) ; light switch block
		%put_rtl($03c38f) ; ninji
		%put_rtl($03c4f9) ; dark room sprite
		%put_rtl($03c625) ; dark room sprite

	org $01e7db!F
		ldy.b #!dys_maxActive-1
	org $028139!F
		ldy.b #!dys_maxActive-1
	org $02a0b8!F
		ldx.b #!dys_maxActive-1
	org $02db64!F
		ldy.b #!dys_maxActive-1
	org $03c20b!F ; fix from an earlier version that erroneously overwrote this
		sty !WB|$1df9
	org $03c20f!F
		ldy.b #!dys_maxActive-1
	org $03c4e1!F
		ldy.b #!dys_maxActive-1


;-----------------------------------------------------------------------------;
; Cluster sprites                                                             ;
;-----------------------------------------------------------------------------;


;----- bonus 1-up
		%put_rtl($02fe70)

;----- castle candle flame
		%put_rtl($02fa83)

	org $02f825!F
	ClsBooCeiling:
		jsr $fbc7 : rtl
	ClsBooRing:
		jsr $fa98 : rtl
	ClsBooCloud:
		jsr $f83d : rtl
	ClsSwooper:
		jsr $fbc7 : rtl

;----- sumo fire
	%put_rtl($02f93b)
	%put_rtl($02f93f)

;-----------------------------------------------------------------------------;
; Generators                                                                  ;
;-----------------------------------------------------------------------------;
;----- bullet bill generators ($0d6-$0d7, originally $0c-$0d)
	org $02b0e4!F
		ldy !WB|$18b9
		lda $b0c9-$d6,y
		ldx $b0cb-$d6,y
;----- dolphin generators ($0cf-$0d0, originally $05-$06)
	org $02b275!F
		ldx $b268-$cf,y
		lda $b26a-$cf,y
	org $02b2ba!F
		adc $b25e-$cf,y
	org $02b2c1!F
		adc $b260-$cf,y
	org $02b2c7
		lda $b262-$cf,y
;----- paragoomba/bomb generators ($cc-$ce, originally $02-$04)
	org $02b348
		lda $b31f-$cc,y

;=============================================================================;
; Other weird broken things                                                   ;
;=============================================================================;

	org $02c3a1!F ; whistlin’ chuck: spawning generator
		lda #$09 : sta !WB|$18fd
		lda !spr_posXL,x
		and #$10
		beq +
		jsl WhistlinChuck
	+	rts

	; For some reason Peach uses $1feb directly instead of using x.
	; That causes a crash when she’s not in slot 9, which Daiyousei doesn’t put
	; her in, so... we fix it.
	org $03aed4!F : sta.w !spr_disableCapeTime,x
	org $03c7b9!F : lda.w !spr_disableCapeTime,x
	org $03c802!F : sta.w !spr_disableCapeTime,x

	; Likewise, Morton & Roy assume things will be in slot 9 which aren’t anymore.
	; These ones are used by other routines so we can’t just drop ,x in there.
	; We move:
	; $153d ($1534,x) -> $1905
	; $1617 ($160e,x) -> $1906

	org $00f92c!F : lda !WB|$1906
	org $00f939!F : lda !WB|$1905
	org $01cd89!F : sta !WB|$1905
	org $01cd8e!F : sta !WB|$1906
	org $01ceca!F : sta !WB|$1906
	org $01cf05!F : lda !WB|$1906
	org $01d176!F : inc !WB|$1905
	                dec !WB|$1906
	                lda !WB|$1905
	org $01d187!F : lda !WB|$1906
	org $01d1a7!F : cmp !WB|$1905
	org $01d1ae!F : cmp !WB|$1906
	; org $01d771!F : ldy $1905
	; org $01d777!F : inc $1905
	; org $01d784!F : inc $1905
	                ; lda $1905
	org $0283ce!F : lda !WB|$1905
	org $0283d6!F : lda !WB|$1906

	org $01a229!F : jmp StunSpringboard
pullpc
endif
