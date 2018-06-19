@include
; The labels in this file are read via Asar and their data written
; to by the tool. These *have to* exist, or daiyousei will
; throw an error and exit.
; Also, because of the way the stuff in load.asm is written,
; it has to be in the same bank as the load routine etc.

macro fillIfMany(len)
	if !opt_manySprites
		fill <len>
	endif
endmacro

pushpc
%dys_freedata()
	; Set up a dummy sprite size table.
	; This will be filled in by the tool during insertion.
	; Note that the tool sets up $100-$1ff to be equal to $000-$0ff,
	; and $300-$3ff equal to $200-$2ff, for the sake of
	; extra bit compatibility.
	DYS_DATA_SPRITE_SIZES:
		fillbyte 3
		fill $f8 : db $04, $05, $06, $07, $08, $03, $03, $03
		fill $f8 : db $04, $05, $06, $07, $08, $03, $03, $03
		fill $f8 : db $04, $05, $06, $07, $08, $03, $03, $03
		fill $f8 : db $04, $05, $06, $07, $08, $03, $03, $03
		fillbyte 0 ; Put the fillbyte back to something expected

	DYS_DATA_STORAGE_PTRS:
		dw 0
		fill 1024*3

; This data is filled in by a mixture of data of the original game's data
; and data generated by the tool from cfg files and such.
; but this way we get to use the same code everywhere instead of checking for
; the original sprites.
; The layout of this table is similar to that used by the original SpriteTool:
; 00    - sprite type
; 01    - acts-like setting
; 02-07 - tweaker bytes
; 08-09 - daiyousei option bytes (xOpts1, xOpts2) (changed from spritetool)
; 10-13 - clipping setting
; 14-15 - extra property bytes
; In spritetool, 08-10 was the init pointer and 11-13 was the main pointer.
; In daiyousei these have been moved to separate tables.
	DYS_DATA_OPTION_BYTES:
	; This one is missing the !reinsertOriginals block because
	; the original option tables may well have been modified,
	; so we need the tool to copy it for us. I love to be alive.
		fill $200*16
		%fillIfMany($200*16)

	; Lunar Magic needs a pointer to the sprite size table.
	pushpc
		org $0ef30c
			dl DYS_DATA_SPRITE_SIZES
			db $42
	pullpc

	; This table contains the init routine pointers for standard sprites.
	; Note that the pointers to SMW’s sprites do not all point to the original
	; routine - a lot of rts -> rtl substituion needs moving some things around,
	; and !ssr_FacePlayer is better than the original.
	DYS_DATA_INIT_PTRS:
	if !opt_noOriginals
		fill $200*3
	else
		dl $018575!F       ; 00 - Green Koopa, no shell
		dl $018575!F       ; 01 - Red Koopa, no shell
		dl $018575!F       ; 02 - Blue Koopa, no shell
		dl $018575!F       ; 03 - Yellow Koopa, no shell
		dl $018575!F       ; 04 - Green Koopa
		dl $018575!F       ; 05 - Red Koopa
		dl $018575!F       ; 06 - Blue Koopa
		dl $018575!F       ; 07 - Yellow Koopa
		dl $018575!F       ; 08 - Green Koopa, flying left
		dl $01856e!F       ; 09 - Green bouncing Koopa
		dl $018575!F       ; 0A - Red vertical flying Koopa
		dl $018575!F       ; 0B - Red horizontal flying Koopa
		dl $018575!F       ; 0C - Yellow Koopa with wings
		dl $01855d!F       ; 0D - Bob-omb
		dl $01e1b8!F       ; 0E - Keyhole
		dl $018575!F       ; 0F - Goomba
		dl $018575!F       ; 10 - Bouncing Goomba with wings
		dl $018575!F       ; 11 - Buzzy Beetle
		dl !ssr_Nothing    ; 12 - Unused
		dl $018575!F       ; 13 - Spiny
		dl $018575!F       ; 14 - Spiny falling
		dl !ssr_Nothing    ; 15 - Fish, horizontal
		dl $01b00b!F       ; 16 - Fish, vertical
		dl $01b014!F       ; 17 - Fish, created from generator
		dl $01b014!F       ; 18 - Surface jumping fish
		dl $0183da!F       ; 19 - Display text from level Message Box
		dl $0185b0!F       ; 1A - Classic Piranha Plant
		dl !ssr_Nothing    ; 1B - Bouncing football in place
		dl $0184dd!F       ; 1C - Bullet Bill
		dl $018575!F       ; 1D - Hopping flame
		dl $01846b!F       ; 1E - Lakitu
		dl $01bdb8!F       ; 1F - Magikoopa
		dl !ssr_Nothing    ; 20 - Magikoopa's magic
		dl !ssr_FacePlayer ; 21 - Moving coin
		dl $01b948!F       ; 22 - Green vertical net Koopa
		dl $01b948!F       ; 23 - Red vertical net Koopa
		dl $01b93e!F       ; 24 - Green horizontal net Koopa
		dl $01b93e!F       ; 25 - Red horizontal net Koopa
		dl $01ae96!F       ; 26 - Thwomp
		dl !ssr_Nothing    ; 27 - Thwimp
		dl $01f884!F       ; 28 - Big Boo
		dl $01cd2f!F       ; 29 - Koopa Kid
		dl $01859a!F       ; 2A - Upside down Piranha Plant
		dl !ssr_Nothing    ; 2B - Sumo Brother's fire lightning
		dl $018339!F       ; 2C - Yoshi egg
		dl $018435!F       ; 2D - Baby green Yoshi
		dl InitSpikeTop    ; 2E - Spike Top (see repair.asm)
		dl !ssr_Nothing    ; 2F - Portable spring board
		dl !ssr_FacePlayer ; 30 - Dry Bones, throws bones
		dl !ssr_FacePlayer ; 31 - Bony Beetle
		dl !ssr_FacePlayer ; 32 - Dry Bones, stay on ledge
		dl $01e050!F       ; 33 - Fireball (Podoboo)
		dl !ssr_Nothing    ; 34 - Boss fireball
		dl $0183e0!F       ; 35 - Green Yoshi
		dl !ssr_Nothing    ; 36 - Unused
		dl $01f884!F       ; 37 - Boo
		dl $01f87c!F       ; 38 - Eerie
		dl $01f87c!F       ; 39 - Eerie, wave motion
		dl $01841b!F       ; 3A - Urchin, fixed
		dl $01841b!F       ; 3B - Urchin, wall detect
		dl InitWallUrchin  ; 3C - Urchin, wall follow (see repair.asm)
		dl $018431!F       ; 3D - Rip Van Fish
		dl $01844e!F       ; 3E - POW
		dl !ssr_Nothing    ; 3F - Para-Goomba
		dl !ssr_Nothing    ; 40 - Para-Bomb
		dl !ssr_Nothing    ; 41 - Dolphin, horizontal
		dl !ssr_Nothing    ; 42 - Dolphin2, horizontal
		dl !ssr_Nothing    ; 43 - Dolphin, vertical
		dl !ssr_Nothing    ; 44 - Torpedo Ted
		dl !ssr_Nothing    ; 45 - Directional coins
		dl $018508!F       ; 46 - Diggin' Chuck
		dl !ssr_Nothing    ; 47 - Swimming/Jumping fish
		dl !ssr_Nothing    ; 48 - Diggin' Chuck's rock
		dl $018381!F       ; 49 - Growing/shrinking pipe end
		dl !ssr_Nothing    ; 4A - Goal Point Question Sphere
		dl $0185b0!F       ; 4B - Pipe dwelling Lakitu
		dl $0183a4!F       ; 4C - Exploding Block
		dl $0184ce!F       ; 4D - Ground dwelling Monty Mole
		dl $0184ce!F       ; 4E - Ledge dwelling Monty Mole
		dl $0185b0!F       ; 4F - Jumping Piranha Plant
		dl $0185b0!F       ; 50 - Jumping Piranha Plant, spit fire
		dl !ssr_FacePlayer ; 51 - Ninji
		dl $018890!F       ; 52 - Moving ledge hole in ghost house
		dl !ssr_Nothing    ; 53 - Throw block sprite
		dl $01ba87!F       ; 54 - Climbing net door
		dl $01b25e!F       ; 55 - Checkerboard platform, horizontal
		dl !ssr_Nothing    ; 56 - Flying rock platform, horizontal
		dl $01b25e!F       ; 57 - Checkerboard platform, vertical
		dl !ssr_Nothing    ; 58 - Flying rock platform, vertical
		dl !ssr_Nothing    ; 59 - Turn block bridge, horizontal and
		dl !ssr_Nothing    ; 5A - Turn block bridge, horizontal
		dl $01b236!F       ; 5B - Brown platform floating in water
		dl $01b22b!F       ; 5C - Checkerboard platform that falls
		dl $01b236!F       ; 5D - Orange platform floating in water
		dl $01b22e!F       ; 5E - Orange platform, goes on forever
		dl $01c74a!F       ; 5F - Brown platform on a chain
		dl !ssr_Nothing    ; 60 - Flat green switch palace switch
		dl $02ed82!F       ; 61 - Floating skulls
		dl $01d711!F       ; 62 - Brown platform, line-guided
		dl $01d6d2!F       ; 63 - Checker/brown platform, line-guide
		dl $01d6c4!F       ; 64 - Rope mechanism, line-guided
		dl $01d6ed!F       ; 65 - Chainsaw, line-guided
		dl $01d6ed!F       ; 66 - Upside down chainsaw, line-guided
		dl $01d6ed!F       ; 67 - Grinder, line-guided
		dl $01d6ed!F       ; 68 - Fuzz ball, line-guided
		dl !ssr_Nothing    ; 69 - Unused
		dl !ssr_Nothing    ; 6A - Coin game cloud
		dl !ssr_Nothing    ; 6B - Spring board, left wall
		dl $01843e!F       ; 6C - Spring board, right wall
		dl !ssr_Nothing    ; 6D - Invisible solid block
		dl $018558!F       ; 6E - Dino Rhino
		dl $018558!F       ; 6F - Dino Torch
		dl $01854b!F       ; 70 - Pokey
		dl $018528!F       ; 71 - Super Koopa, red cape
		dl $018528!F       ; 72 - Super Koopa, yellow cape
		dl $01852e!F       ; 73 - Super Koopa, feather
		dl $01858b!F       ; 74 - Mushroom
		dl $01858b!F       ; 75 - Flower
		dl $01858b!F       ; 76 - Star
		dl $01858b!F       ; 77 - Feather
		dl $01858b!F       ; 78 - 1-Up
		dl !ssr_Nothing    ; 79 - Growing Vine
		dl !ssr_Nothing    ; 7A - Firework
		dl $01c075!F       ; 7B - Goal Point
		dl !ssr_Nothing    ; 7C - Princess Peach
		dl !ssr_Nothing    ; 7D - Balloon
		dl !ssr_Nothing    ; 7E - Flying Red coin
		dl !ssr_Nothing    ; 7F - Flying yellow 1-Up
		dl $018435!F       ; 80 - Key
		dl $01843b!F       ; 81 - Changing item from translucent blo
		dl $01ddac!F       ; 82 - Bonus game sprite
		dl $01ad59!F       ; 83 - Left flying question block
		dl $01ad59!F       ; 84 - Flying question block
		dl !ssr_Nothing    ; 85 - Unused (Pretty sure)
		dl $02eff2!F       ; 86 - Wiggler
		dl !ssr_Nothing    ; 87 - Lakitu's cloud
		dl !ssr_Nothing    ; 88 - Unused (Winged cage sprite)
		dl !ssr_Nothing    ; 89 - Layer 3 smash
		dl !ssr_Nothing    ; 8A - Bird from Yoshi's house
		dl !ssr_Nothing    ; 8B - Puff of smoke from Yoshi's house
		dl $0183da!F       ; 8C - Fireplace smoke/exit from side scr
		dl !ssr_Nothing    ; 8D - Ghost house exit sign and door
		dl !ssr_Nothing    ; 8E - Invisible "Warp Hole" blocks
		dl $0183b5!F       ; 8F - Scale platforms
		dl !ssr_FacePlayer ; 90 - Large green gas bubble
		dl !ssr_Nothing    ; 91 - Chargin' Chuck
		dl $018504!F       ; 92 - Splittin' Chuck
		dl $018504!F       ; 93 - Bouncin' Chuck
		dl $018500!F       ; 94 - Whistlin' Chuck
		dl $0184e9!F       ; 95 - Clapin' Chuck
		dl !ssr_Nothing    ; 96 - Unused (Chargin' Chuck clone)
		dl $0184fc!F       ; 97 - Puntin' Chuck
		dl $0184ed!F       ; 98 - Pitchin' Chuck
		dl !ssr_Nothing    ; 99 - Volcano Lotus
		dl $018373!F       ; 9A - Sumo Brother
		dl !ssr_Nothing    ; 9B - Hammer Brother
		dl !ssr_Nothing    ; 9C - Flying blocks for Hammer Brother
		dl $018564!F       ; 9D - Bubble with sprite
		dl $018396!F       ; 9E - Ball and Chain
		dl $018387!F       ; 9F - Banzai Bill
		dl $03a0f1!F       ; A0 - Activates Bowser scene
		dl !ssr_Nothing    ; A1 - Bowser's bowling ball
		dl !ssr_Nothing    ; A2 - MechaKoopa
		dl $01839a!F       ; A3 - Grey platform on chain
		dl $01b216!F       ; A4 - Floating Spike ball
		dl InitFuzzSpark   ; A5 - Fuzzball/Sparky, ground-guided (see repair.asm)
		dl InitFuzzSpark   ; A6 - HotHead, ground-guided (see repair.asm)
		dl !ssr_Nothing    ; A7 - Iggy's ball
		dl !ssr_Nothing    ; A8 - Blargg
		dl $039872!F       ; A9 - Reznor
		dl $01858e!F       ; AA - Fishbone
		dl !ssr_FacePlayer ; AB - Rex
		dl $01835b!F       ; AC - Wooden Spike, moving down and up
		dl $0184ce!F       ; AD - Wooden Spike, moving up/down first
		dl !ssr_Nothing    ; AE - Fishin' Boo
		dl !ssr_Nothing    ; AF - Boo Block
		dl $01834e!F       ; B0 - Reflecting stream of Boo Buddies
		dl $0184d6!F       ; B1 - Creating/Eating block
		dl !ssr_Nothing    ; B2 - Falling Spike
		dl $018584!F       ; B3 - Bowser statue fireball
		dl !ssr_FacePlayer ; B4 - Grinder, non-line-guided
		dl !ssr_Nothing    ; B5 - Sinking fireball used in boss battles
		dl $01834e!F       ; B6 - Reflecting fireball
		dl !ssr_Nothing    ; B7 - Carrot Top lift, upper right
		dl !ssr_Nothing    ; B8 - Carrot Top lift, upper left
		dl !ssr_Nothing    ; B9 - Info Box
		dl $018326!F       ; BA - Timed lift
		dl !ssr_Nothing    ; BB - Grey moving castle block
		dl $018314!F       ; BC - Bowser statue
		dl $01837d!F       ; BD - Sliding Koopa without a shell
		dl !ssr_Nothing    ; BE - Swooper bat
		dl !ssr_FacePlayer ; BF - Mega Mole
		dl $01830f!F       ; C0 - Grey platform on lava
		dl $0184ce!F       ; C1 - Flying grey turnblocks
		dl !ssr_FacePlayer ; C2 - Blurp fish
		dl !ssr_FacePlayer ; C3 - Porcu-Puffer fish
		dl !ssr_Nothing    ; C4 - Grey platform that falls
		dl !ssr_FacePlayer ; C5 - Big Boo Boss
		dl $018313!F       ; C6 - Dark room with spot light
		dl !ssr_Nothing    ; C7 - Invisible mushroom
		dl !ssr_Nothing    ; C8 - Light switch block for dark room

		dl !ssr_Nothing    ; C9 - Bullet Bill shooter
		dl !ssr_Nothing    ; CA - Torpedo Ted launcher

		dl !ssr_Nothing    ; CB - Eerie generator
		dl !ssr_Nothing    ; CC - Para-goomba generator
		dl !ssr_Nothing    ; CD - Para-bomb generator
		dl !ssr_Nothing    ; CE - Para-bomb/goomba generator
		dl !ssr_Nothing    ; CF - Dolphin generator, left
		dl !ssr_Nothing    ; D0 - Dolphin generator, right
		dl !ssr_Nothing    ; D1 - Jumping fish generator
		dl !ssr_Nothing    ; D2 - Turn off generator 2
		dl !ssr_Nothing    ; D3 - Super koopa generator
		dl !ssr_Nothing    ; D4 - Bubble w/ sprite generator
		dl !ssr_Nothing    ; D5 - Bullet Bill generator
		dl !ssr_Nothing    ; D6 - Bullet Bill 4-way generator
		dl !ssr_Nothing    ; D7 - Bullet Bill diagonal generator
		dl !ssr_Nothing    ; D8 - Bowser statue fire breath generator
		dl !ssr_Nothing    ; D9 - Turn off standard generators
		fill $138*3
	endif

	%fillIfMany($200*3)

	; This contains the pointers to standard sprite main routines,
	; as well as the main routines for generators (gen), shooters (sht),
	; and run-once sprites (r1s).
	; This is mainly because they were conflated by the original game’s data
	; format, and not because they particularly need to be grouped.
	; Like the init ptrs, the original game’s sprites aren’t all perfectly
	; where they used to be.
	DYS_DATA_MAIN_PTRS:
	if !opt_noOriginals
		fill $200*3
	else
		dl ShellessKoopas   ; 00 - Green Koopa, no shell
		dl ShellessKoopas   ; 01 - Red Koopa, no shell
		dl ShellessKoopas   ; 02 - Blue Koopa, no shell
		dl ShellessKoopas   ; 03 - Yellow Koopa, no shell
		dl Spr0to13Start    ; 04 - Green Koopa
		dl Spr0to13Start    ; 05 - Red Koopa
		dl Spr0to13Start    ; 06 - Blue Koopa
		dl Spr0to13Start    ; 07 - Yellow Koopa
		dl GreenParaKoopa   ; 08 - Green Koopa, flying left
		dl GreenParaKoopa   ; 09 - Green bouncing Koopa
		dl RedVertParaKoopa ; 0A - Red vertical flying Koopa
		dl RedHorzParaKoopa ; 0B - Red horizontal flying Koopa
		dl Spr0to13Start    ; 0C - Yellow Koopa with wings
		dl Bobomb           ; 0D - Bob-omb
		dl Keyhole          ; 0E - Keyhole
		dl Spr0to13Start    ; 0F - Goomba
		dl WingedGoomba     ; 10 - Bouncing Goomba with wings
		dl Spr0to13Start    ; 11 - Buzzy Beetle
		dl !ssr_Nothing     ; 12 - Unused
		dl Spr0to13Start    ; 13 - Spiny
		dl $018c18!F        ; 14 - Spiny falling
		dl $01b033!F        ; 15 - Fish, horizontal
		dl $01b033!F        ; 16 - Fish, vertical
		dl $01b192!F        ; 17 - Fish, created from generator
		dl $01b1b4!F        ; 18 - Surface jumping fish
		dl $01e75b!F        ; 19 - Display text from level Message Box
		dl $018e76!F        ; 1A - Classic Piranha Plant
		dl $038012!F        ; 1B - Bouncing football in place
		dl BulletBill       ; 1C - Bullet Bill
		dl $018f0d!F        ; 1D - Hopping flame
		dl Lakitu           ; 1E - Lakitu
		dl $01bdd6!F        ; 1F - Magikoopa
		dl $01bc38!F        ; 20 - Magikoopa's magic
		dl Powerups         ; 21 - Moving coin
		dl $01b97f!F        ; 22 - Green vertical net Koopa
		dl $01b97f!F        ; 23 - Red vertical net Koopa
		dl $01b97f!F        ; 24 - Green horizontal net Koopa
		dl $01b97f!F        ; 25 - Red horizontal net Koopa
		dl $01aea3!F        ; 26 - Thwomp
		dl $01af9f!F        ; 27 - Thwimp
		dl $01f8d5!F        ; 28 - Big Boo
		dl $01fac1!F        ; 29 - Koopa Kid
		dl $018e76!F        ; 2A - Upside down Piranha Plant
		dl $02dea8!F        ; 2B - Sumo Brother's fire lightning
		dl $01f764!F        ; 2C - Yoshi egg
		dl !ssr_Nothing     ; 2D - Baby green Yoshi
		dl $02bcdb!F        ; 2E - Spike Top
		dl $01e623!F        ; 2F - Portable spring board
		dl $01e42b!F        ; 30 - Dry Bones, throws bones
		dl $01e42b!F        ; 31 - Bony Beetle
		dl $01e42b!F        ; 32 - Dry Bones, stay on ledge
		dl Podoboo          ; 33 - Fireball (Podoboo)
		dl BossFireball     ; 34 - Boss fireball
		dl Yoshi            ; 35 - Green Yoshi
		dl !ssr_Nothing     ; 36 - Unused
		dl $01f8dc!F        ; 37 - Boo
		dl $01f890!F        ; 38 - Eerie
		dl $01f890!F        ; 39 - Eerie, wave motion
		dl $02bcdb!F        ; 3A - Urchin, fixed
		dl $02bcdb!F        ; 3B - Urchin, wall detect
		dl $02bcdb!F        ; 3C - Urchin, wall follow
		dl $02bfcd!F        ; 3D - Rip Van Fish
		dl $01e75b!F        ; 3E - POW
		dl Parachute        ; 3F - Para-Goomba
		dl Parachute        ; 40 - Para-Bomb
		dl $02bb94!F        ; 41 - Dolphin, horizontal
		dl $02bb94!F        ; 42 - Dolphin2, horizontal
		dl $02bb94!F        ; 43 - Dolphin, vertical
		dl $02b882!F        ; 44 - Torpedo Ted
		dl $02e215!F        ; 45 - Directional coins
		dl $02c1f5!F        ; 46 - Diggin' Chuck
		dl $02e71f!F        ; 47 - Swimming/Jumping fish
		dl $02e7b5!F        ; 48 - Diggin' Chuck's rock
		dl $02e82d!F        ; 49 - Growing/shrinking pipe end
		dl $018763!F        ; 4A - Goal Point Question Sphere
		dl $02e935!F        ; 4B - Pipe dwelling Lakitu
		dl $02e417!F        ; 4C - Exploding Block
		dl $01e2cf!F        ; 4D - Ground dwelling Monty Mole
		dl $01e2cf!F        ; 4E - Ledge dwelling Monty Mole
		dl $02e0c5!F        ; 4F - Jumping Piranha Plant
		dl $02e0c5!F        ; 50 - Jumping Piranha Plant, spit fire
		dl $03c34c!F        ; 51 - Ninji
		dl $02e5b4!F        ; 52 - Moving ledge hole in ghost house
		dl !ssr_Nothing     ; 53 - Throw block sprite (???)
		dl $01bacd!F        ; 54 - Climbing net door
		dl $01b26c!F        ; 55 - Checkerboard platform, horizontal
		dl $01b26c!F        ; 56 - Flying rock platform, horizontal
		dl $01b26c!F        ; 57 - Checkerboard platform, vertical
		dl $01b26c!F        ; 58 - Flying rock platform, vertical
		dl $01b6a5!F        ; 59 - Turn block bridge, horizontal and
		dl $01b6da!F        ; 5A - Turn block bridge, horizontal
		dl Platforms2       ; 5B - Brown platform floating in water
		dl Platforms2       ; 5C - Checkerboard platform that falls
		dl Platforms2       ; 5D - Orange platform floating in water
		dl OrangePlatform   ; 5E - Orange platform, goes on forever
		dl $01c773!F        ; 5F - Brown platform on a chain
		dl $02cd2d!F        ; 60 - Flat green switch palace switch
		dl $02edd0!F        ; 61 - Floating skulls
		dl $01d74a!F        ; 62 - Brown platform, line-guided
		dl $01d74a!F        ; 63 - Checker/brown platform, line-guide
		dl $01d719!F        ; 64 - Rope mechanism, line-guided
		dl $01d719!F        ; 65 - Chainsaw, line-guided
		dl $01d719!F        ; 66 - Upside down chainsaw, line-guided
		dl $01d73a!F        ; 67 - Grinder, line-guided
		dl $01d74a!F        ; 68 - Fuzz ball, line-guided
		dl $01d6c3!F        ; 69 - Unused
		dl $02eea9!F        ; 6A - Coin game cloud
		dl $02cdcb!F        ; 6B - Spring board, left wall
		dl $02cdcb!F        ; 6C - Spring board, right wall
		dl $01b44f!F        ; 6D - Invisible solid block
		dl $039c47!F        ; 6E - Dino Rhino
		dl $039c47!F        ; 6F - Dino Torch
		dl $02b636!F        ; 70 - Pokey
		dl $02eb27!F        ; 71 - Super Koopa, red cape
		dl $02eb27!F        ; 72 - Super Koopa, yellow cape
		dl $02eb27!F        ; 73 - Super Koopa, feather
		dl Powerups         ; 74 - Mushroom
		dl Flower           ; 75 - Flower
		dl Powerups         ; 76 - Star
		dl Feather          ; 77 - Feather
		dl Powerups         ; 78 - 1-Up
		dl $01c183!F        ; 79 - Growing Vine
		dl $03a14e!F        ; 7A - Firework
		dl $01c098!F        ; 7B - Goal Point
		dl $03a157!F        ; 7C - Princess Peach
		dl $01c1f2!F        ; 7D - Balloon
		dl $01c1f2!F        ; 7E - Flying Red coin
		dl $01c1f2!F        ; 7F - Flying yellow 1-Up
		dl $01c1f2!F        ; 80 - Key
		dl $01c317!F        ; 81 - Changing item from translucent blo
		dl $01de2a!F        ; 82 - Bonus game sprite
		dl $01ad6e!F        ; 83 - Left flying question block
		dl $01ad6e!F        ; 84 - Flying question block
		dl $01ad59!F        ; 85 - Unused (Pretty sure)
		dl $02f029!F        ; 86 - Wiggler
		dl LakitusCloud     ; 87 - Lakitu's cloud
		dl $02cbfe!F        ; 88 - Unused (Winged cage sprite)
		dl $02d3ea!F        ; 89 - Layer 3 smash ko
		dl $02f30f!F        ; 8A - Bird from Yoshi's house
		dl $02f42c!F        ; 8B - Puff of smoke from Yoshi's house
		dl $02f4cd!F        ; 8C - Fireplace smoke/exit from side scr
		dl $02f594!F        ; 8D - Ghost house exit sign and door
		dl $02ead2!F        ; 8E - Invisible "Warp Hole" blocks
		dl $02e495!F        ; 8F - Scale platforms
		dl $02e303!F        ; 90 - Large green gas bubble
		dl $02c1f5!F        ; 91 - Chargin' Chuck
		dl $02c1f5!F        ; 92 - Splittin' Chuck
		dl $02c1f5!F        ; 93 - Bouncin' Chuck
		dl $02c1f5!F        ; 94 - Whistlin' Chuck
		dl $02c1f5!F        ; 95 - Clapin' Chuck
		dl $02c1f5!F        ; 96 - Unused (Chargin' Chuck clone)
		dl $02c1f5!F        ; 97 - Puntin' Chuck
		dl $02c1f5!F        ; 98 - Pitchin' Chuck
		dl $02df8b!F        ; 99 - Volcano Lotus
		dl $02dcaf!F        ; 9A - Sumo Brother
		dl $02da52!F        ; 9B - Hammer Brother
		dl $02db4c!F        ; 9C - Flying blocks for Hammer Brother
		dl $02d8ad!F        ; 9D - Bubble with sprite
		dl $02d617!F        ; 9E - Ball and Chain
		dl $02d617!F        ; 9F - Banzai Bill
		dl $03a259!F        ; A0 - Activates Bowser scene
		dl $03b163!F        ; A1 - Bowser's bowling ball
		dl $03b2a9!F        ; A2 - MechaKoopa
		dl $02d617!F        ; A3 - Grey platform on chain
		dl SpikeBall        ; A4 - Floating Spike ball
		dl $02bcdb!F        ; A5 - Fuzzball/Sparky, ground-guided (see repair.asm)
		dl $02bcdb!F        ; A6 - HotHead, ground-guided (see repair.asm)
		dl $01fa58!F        ; A7 - Iggy's ball
		dl $03a242!F        ; A8 - Blargg
		dl $039890!F        ; A9 - Reznor
		dl $0396f6!F        ; AA - Fishbone
		dl $039517!F        ; AB - Rex
		dl $03a21e!F        ; AC - Wooden Spike, moving down and up
		dl $03a21e!F        ; AD - Wooden Spike, moving up/down first
		dl $039065!F        ; AE - Fishin' Boo
		dl $01f8dc!F        ; AF - Boo Block
		dl $038f7a!F        ; B0 - Reflecting stream of Boo Buddies
		dl $039284!F        ; B1 - Creating/Eating block
		dl $039214!F        ; B2 - Falling Spike
		dl $038eec!F        ; B3 - Bowser statue fireball
		dl $01db5c!F        ; B4 - Grinder, non-line-guided
		dl $01e093!F        ; B5 - Sinking fireball used in boss battles
		dl $038f75!F        ; B6 - Reflecting fireball
		dl $038c2f!F        ; B7 - Carrot Top lift, upper right
		dl $038c2f!F        ; B8 - Carrot Top lift, upper left
		dl $038d6f!F        ; B9 - Info Box
		dl $038dbb!F        ; BA - Timed lift
		dl $038e79!F        ; BB - Grey moving castle block
		dl $038a3c!F        ; BC - Bowser statue
		dl $038958!F        ; BD - Sliding Koopa without a shell
		dl $0388a3!F        ; BE - Swooper bat
		dl $038770!F        ; BF - Mega Mole
		dl $0386ff!F        ; C0 - Grey platform on lava
		dl $0385f6!F        ; C1 - Flying grey turnblocks
		dl $0384ca!F        ; C2 - Blurp fish
		dl $03852f!F        ; C3 - Porcu-Puffer fish
		dl $038454!F        ; C4 - Grey platform that falls
		dl $03a160!F        ; C5 - Big Boo Boss
		dl $03c4dc!F        ; C6 - Dark room with spot light
		dl $03a12a!F        ; C7 - Invisible mushroom
		dl $03c1f5!F        ; C8 - Light switch block for dark room
		dl $02b466!F        ; C9 - Bullet Bill shooter
		dl $02b3b6!F        ; CA - Torpedo Ted launcher
		dl $02b2d6!F        ; CB - Eerie generator
		dl $02b329!F        ; CC - Para-goomba generator
		dl $02b329!F        ; CD - Para-bomb generator
		dl $02b329!F        ; CE - Para-bomb/goomba generator
		dl $02b26c!F        ; CF - Dolphin generator, left
		dl $02b26c!F        ; D0 - Dolphin generator, right
		dl $02b15b!F        ; D1 - Jumping fish generator
		dl $02b02b!F        ; D2 - Turn off generator 2
		dl $02b1bc!F        ; D3 - Super koopa generator
		dl $02b207!F        ; D4 - Bubble w/ sprite generator
		dl $02b07c!F        ; D5 - Bullet Bill generator
		dl $02b0cd!F        ; D6 - Bullet Bill 4-way generator
		dl $02b0cd!F        ; D7 - Bullet Bill diagonal generator
		dl $02b036!F        ; D8 - Bowser statue fire breath generator
		dl $02b032!F        ; D9 - Turn off standard generators
		dl RunOnceShell          ; DA - Koopa shell, green
		dl RunOnceShell          ; DB - Koopa shell, red
		dl RunOnceShell          ; DC - Koopa shell, blue
		dl RunOnceShell          ; DD - Koopa shell, yellow
		dl RunOnceFiveEeries     ; DE - Five eeries, wave motion
		dl RunOnceGrnShell       ; DF - Koopa shell, green
		dl RunOnceTriplePlatform ; E0 - three platforms
		dl RunOnceBooCeiling     ; E1
		dl RunOnceBooRingCCW     ; E2
		dl RunOnceBooRingCW      ; E3
		dl RunOnceSwooperCeiling ; E4
		dl RunOnceBooCloud       ; E5
		dl RunOnceCandleFlames   ; E6 - Candle flame spawner
		fill $138*3
	endif

	%fillIfMany($200*3)

	DYS_DATA_CLS_PTRS:
	if !opt_noOriginals
		fill $100*3
	else
		dl !ssr_Nothing   ; 00 - empty slot
		dl $02fdbc!F      ; 01 - bonus game 1-up
		dl 0              ; 02 - unused
		dl ClsBooCeiling  ; 03 - boo ceiling boo
		dl ClsBooRing     ; 04 - boo ring boo
		dl $02fa16!F      ; 05 - castle candle flame
		dl $02f91c!F      ; 06 - sumo brother lightning flame
		dl ClsBooCloud    ; 07 - boo cloud boo
		dl ClsSwooper     ; 08 - swooper
		fill $f7*3
	endif

	DYS_DATA_XSP_PTRS:
		fill $80*3

	DYS_DATA_MXS_PTRS:
		fill $80*3

pullpc
