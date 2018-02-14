# Subroutines for Spawning Sprites

Daiyousei spawns sprites somewhat differently than original SMW and Romi's spritetool.

Before reading this page, you should learn about how
Daiyousei handles [extra bits and sprite numbers](/how-to-code/extra-bits.html).

Spawning a sprite has two stages. The first is *finding a slot*, the second is
*table initialization*.

Finding a slot is basically the same for Daiyousei as for earlier tools.
You iterate over `!spr_status`, until you find a sprite with status `$00`.
Daiyousei changes the way the sprite memory header works, so it will sometimes
allow more sprites to be spawned. There aren't any other interesting differences.

The purpose of table initialization is to load the tweaker properties for
the sprite being spawned and to set most of the other tables to 0 so the sprite's
behavior isn't changed by whatever was previously in the slot.

There are two ways to initialize a sprite’s tables, for backward-compatibility reasons.
If you stick to the new way, you shouldn’t have to think about the old way, but
the old way is documented since it explains how old sprites work.

The old way has one way to spawn a custom sprite, by setting `!spr_custNum` and
`!spr_extraBit`, and one way to spawn an original game sprite, by setting `!spr_act`
and `!spr_extraBit`. These behaviors are the same as `!ssr_InitTables` and `!ssr_InitViaAct`,
respectively. Older sprites obviously don't use those routines, but the original game's
spawn routines are all patched to act like `!ssr_InitViaAct`, and `!ssr_InitTables` was
designed to match the existing method of spawning custom sprites.

The new way is to use `!spr_custNum` and `!spr_extraBit` exclusively. You can do
this by always using `!ssr_InitTables` or `!ssr_SpawnSprite`, both of which have
this behavior.

Here are some examples of the new way of spawning sprites:
```
; Spawn a sprite that doesn't need any special initialization
!num = $123
!xbit = 0
	lda.b #!num
	sta $00
	lda.b #(((!num&$300)>>6)|(!xbit<<2)) ; -- makes ---nne--
	sta $01
	; !ssr_SpawnSprite finds a slot and initializes most of the tables for us
	jsl !ssr_SpawnSprite
	bmi .didntSpawn
.spawned:
	; put the other sprite at our current position
	lda !spr_posXL,x : sta !DP|!spr_posXL,y
	lda !spr_posXH,x : sta !spr_posXH,y
	lda !spr_posYL,x : sta !DP|!spr_posYL,y
	lda !spr_posYH,x : sta !spr_posYH,y

	; do any other initialization you want
	...

.didntSpawn:
	; deal with not spawning a sprite (often just by not doing anything)
	...
```

```
; Spawn a sprite that needs some kind of special initialization
!num = $086
!xbit = 0
	; find a slot to spawn our new sprite in
	jsl !ssr_FindFreeSlot : bmi .didntSpawn
.spawned:
	; FindFreeSlot returns the index in Y
	; `tyx` sort of makes this sprite "turn into" the one in the new slot
	tyx

	; set "our" sprite number and extra bits
	lda.b #!num
	sta !spr_custNum,x
	lda.b #(((!num&$300)>>6)|(!xbit<<2)) ; -- makes ---nne--
	sta !spr_extraBit,x

	; set up the new sprite's tables
	jsl !ssr_InitTables

	; set the sprite to run its init routine next frame
	; (you might also want to use #$08 instead of #$01 here sometimes,
	;  to skip the init routine)
	; if you don't do this, the sprite will be left in state $00,
	; so it basically doesn't get spawned
	lda #$01
	sta !spr_status,x

	; with that done, you can do whatever other initialization things you
	; wanted to
	...

	; "turn into" ourselves again
	ldx !dys_slot
	; now do whatever else you wanted
	...

.didntSpawn:
	; deal with not spawning a sprite (often just by not doing anything)
	...
```

## !ssr_SpawnSprite
**Arguments**:
- `$00`: Low byte of sprite number.
- `$01`: Sprite [extra bits](/how-to-code/extra-bits.html).

**Returns**:
- **Negative flag**: *Clear* if the sprite spawned successfully, *set* if it failed.
- **Y**: Index of spawned sprite. Invalid value if no sprite was spawned.

Finds a free sprite slot, sets it’s sprite number,
then initializes its tables, including its status (to `#$08`),
property bytes, palette, timers (to 0), etc.

Note that the sprite's position is left at `(0, 0)`,
so the spawner should probably move it somewhere else.
The extra bytes are set to `0, 0, 0, 0` as well.

This routine spawns the sprite in state `$08`, which means that the sprite's
init routine will be skipped. For most sprites, this is perfectly acceptable,
but some sprites depend on things they set up in their init routine.
For those sprites, you should use [`!ssr_FindFreeSlot`](#ssr_FindFreeSlot)
and then [`!ssr_InitTables`](#ssr_InitTables) to spawn them in state `$01`
and do any other initialization you might need.

## !ssr_InitTables
**Arguments**: none.

**Returns**: none.

Initializes a sprite, zeroing most of its miscellaneous tables
and loading its properties bytes from the Tweaker table.
The sprite’s number is taken from `!spr_custNum,x` and `!spr_extraBit,x`.

## !ssr_InitViaAct
**Arguments**: none.

**Returns**: none.

Initializes a sprite.
Its number is taken from `!spr_act,x`.

This routine is intended mainly for internal use. End users will probably not
find much use for it.

## !ssr_FindFreeSlot
**Arguments**: none.
**Returns**:
- **Negative flag**: *Clear* if the a slot was found, *set* if it failed.
- **Y**: Index of the free slot. Invalid value if no slot was found.

Search for a free slot, that the caller can spawn a sprite in.