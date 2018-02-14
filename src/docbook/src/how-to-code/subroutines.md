# Subroutines
These subroutines are of broad purpose, and could be used by most sprites.

Some subroutines are aliases for SMW subroutines.

These pages cover only those subroutines exported by the prelude, and not
any user subroutines which may be in use.

## !ssr_Offscreen_X#
**Arguments**: none.

**Returns**: none.

Checks if the sprite is offscreen.
If the sprite is offscreen, it will be despawned and its slot freed.
The # in the routine goes from 0-9 and selects the size of the sprite.
If you are unsure which version to use, use `!ssr_Offscreen_X0`.



## !ssr_Offscreen_A
**Arguments**:
- **A**: Index to sprite size table. (valid values: `0..=9`)

**Returns**: none.

This is like [`!ssr_Offscreen_X#`](#ssr_Offscreen_X), except it retrieves its
size from register A instead of having a hardcoded one.



## !ssr_Move
**Arguments**: none.

**Returns**: none.

Move the sprite horizontally and vertically, accelerating with gravity.



## !ssr_TranslateX
**Arguments**: none.

**Returns**: none.

Move the sprite horizontally, without accounting for gravity.



## !ssr_TranslateY
**Arguments**: none.

**Returns**: none.

Move the sprite vertically, without accounting for gravity.



## !ssr_TranslateXY
**Arguments**: none.

**Returns**: none.

Move the sprite horizontally and vertically, without accounting for gravity.
This is a convenience routine that calls [`!ssr_TranslateX`](#ssr_TranslateX),
then [`!ssr_TranslateY`](#ssr_TranslateY).



## !ssr_CollidePlayer
**Arguments**: none.

**Returns**:
- **Carry flag**: *Set* if this sprite collided with the player, *clear* otherwise

Processes the sprite’s interaction with the player character.
If the sprite is set to use default interaction this can have many effects;
if not it only checks for collision.
Returns with the carry flag set if collision occurred.



## !ssr_CollideSpr
**Arguments**: none.

**Returns**: none.

Processes the sprite’s interaction with other sprites.
This can have many effects, depending on the sprite's property values.



## !ssr_CollideSprPlayer
**Arguments**: none.

**Returns**:
- **Carry flag**: *Set* if this sprite collided with the player, *clear* otherwise

Processes the sprite’s interaction with other sprites
(via [`!ssr_CollideSpr`](#ssr_CollideSpr)),
then with the player (via [`!ssr_CollidePlayer`](#ssr_CollidePlayer)).



## !ssr_CollideLevel

{{TODO}}



## !ssr_HurtPlayer
**Arguments**: none.

**Returns**: none.

**Alias for**: `$00f5b7`

Immediately cause damage to the player.



## !ssr_FacePlayer
**Arguments**: none.

**Returns**: none.

Updates `!spr_facing,x` to face the player.

This is intended mainly for use as an init routine, like so:

```%dys_offsets(Main, !ssr_FacePlayer)```



## !ssr_Nothing
**Arguments**: none.

**Returns**: none.

**Alias for**: `$00fade`

Returns immediately, without doing anything.
This mainly exists for internal use.
It can be used as an init routine:

```%dys_offsets(Main, !ssr_Nothing)```

However, `%dys_main(Main)` has the same meaning.



## !ssr_GetDrawInfo
**Arguments**: none.

**Returns**: none.
- **Y**: Starting OAM index.
- `$00`: Sprite X position, relative to screen.
- `$01`: Sprite Y position, relative to screen.

Gets some info about the sprite's location and checks if the sprite is
onscreen.

If the sprite is offscreen, GetDrawInfo will return from *the routine that called it*.

Routines which call this *must* be jsr subroutines.



## !ssr_FinishOamWrite
**Arguments**:
- **A**: Number of tiles to update, minus 1.
- **Y**: Size for tiles to update.
	- `$00`: Make the tiles 8x8.
	- `$02`: Make the tiles 16x16.
	- `$ff`: Don't update the tile sizes.

**Returns**: none.

**Alias for**: `$01b7b3`

Sets the "high OAM" bits of OAM tiles drawn by a graphics routine.
Sets the sizes of tiles, and the "negative" bit of the x position.
If the routine determines an OAM tile is offscreen,
it shunts it to position $f0, where it cannot be seen.

Note that although this routine is technically an alias for a SMW routine,
Daiyousei applies a patch to that routine that optimizes it considerably.
