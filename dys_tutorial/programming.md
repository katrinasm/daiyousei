Programming sprites for Daiyousei

Basics
======

A sprite consists of at least one cfg file and an asm source file.
The cfg file is described in [[TODO]].
The asm file contains a few routines, called by the game at various times:
- The MAIN routine, called once per frame while the sprite is alive
- The INIT routine, called when the sprite is first loaded

  Note that this routine may not be called if the sprite is spawned by another
  sprite. It is safe to assume the sprite is off-screen during the INIT.

These are jsl subroutines.
They are declared using the macros %dys_offsets(main, init) or %dys_main(main).
In the case of %dys_main(), the INIT routine still exists, but is pointed to an
rtl and may be disregarded.

A valid sprite file might look something like this:

```
%dys_offsets(Main, Init)
Init:
    ; do things
    rtl
Main:
    ; do things
    rtl
```

Exports
=======

When inserting a sprite, daiyousei adds a section of code called the *prelude*
before the contents of the asm file. The prelude includes a long, long list of
definitions useful for sprites. Daiyousei's exports are almost all prefixed with
some three-letter code describing what they are for. For example, !spr_ is used
for sprite tables, !cls_ is used for cluster sprite tables, !sht_ is used for
shooter tables.
!dys_ is used for "miscellaneous" things which don't fit into other categories.

The tables most interesting to programmers can be found in
patch/prelude/memory.asm
which contains the definitions for the most commonly-used sprite tables.

Subroutines
-----------

In addition to its table definitions, Daiyousei exports a significant set of
shared subroutines.

These are prefixed with !ssr_ and all start with a capital letter afterward.

Many sprites already contain copies of similar subroutines and Daiyousei
includes some of the most common.

Daiyousei’s versions of the subroutines are usually better-optimized and using
them will take less space than inserting a copy of each routine with sprites.

Practical subroutines
---------------------

- !ssr_Offscreen_X#

    Checks if the sprite is offscreen.
    If the sprite is offscreen, it will be despawned and its slot freed.
    The # in the routine goes from 0-9 and selects the size of the sprite.
    If you are unsure which version to use, use !ssr_Offscreen_X0.

- !ssr_FindFreeSlot

    Find a free sprite slot, into which the caller may spawn a new sprite.
    Returns the slot number in Y.
    Returns with the N flag set if no slot was found.

- !ssr_Move

    Move the sprite horizontally and vertically, accelerating with gravity.

- !ssr_TranslateX

    Move the sprite horizontally, without gravity.

- !ssr_TranslateY

    Move the sprite vertically, without gravity.

- !ssr_TranslateXY

    Move the sprite horizontally and vertically, with no gravity.

- !ssr_CollidePlayer

    Processes the sprite’s interaction with the player character.
    If the sprite is set to use default interaction this can have many effects;
    if not it only checks for collision.
    Returns with the carry flag set if collision occurred.

- !ssr_CollideSpr

    Processes the sprite’s interaction with other sprites.
    This can have many effects.

- !ssr_CollideSprPlayer

    Same as calling !ssr_CollideSpr, then !ssr_CollideSprPlayer.

- !ssr_CollideLevel

    [[TODO]]

- !ssr_HurtPlayer

    Cause damage to the player.

- !ssr_InitTables

    Initializes a sprite, zeroing most of its miscellaneous tables
    and loading its properties bytes from the Tweaker table.
    The sprite’s number is taken from !spr_custNum,x and !spr_extraBit,x.
    See §Spawning for more details.

- !ssr_InitViaAct

    Initializes a sprite.
    Its number is taken from !spr_act,x.
    See §Spawning for more details.

- !ssr_HorizPos

    [[TODO]]

- !ssr_VertPos

    [[TODO]]

- !ssr_StompPoints

    Gives the player the points for stomping on a sprite.
    Does not cause the sprite to die.
    Plays a sound effect.
    Relies on !spr_miscK.

- !ssr_StarPoints

    Gives the player the points for star-killing on a sprite.
    Does not cause the sprite to die.
    Plays a sound effect.
    Relies on !spr_miscK.

- !ssr_FacePlayer

    Causes the sprite to face the player.
    Does NOT provide any of the return values of !ssr_HorizPos.
    Intended for use as an INIT routine.

- !ssr_SpawnSprite

    Finds a free sprite slot, sets it’s sprite number,
    then initializes its tables, including its status (to #$08),
    property bytes, palette, timers (to 0), etc.

    Takes sprite number lo in $00.
    Takes sprite number hi & extra bit flag in $01.
    Returns slot number in Y.
    Returns with the negative flag set if no slot could be found.

    Note that the sprite's position is left at (0, 0),
    so the spawner should probably set it somewhere else.
    The extra bytes are set to 0, 0, 0, 0 as well.

Graphical subroutines
---------------------

- !ssr_GetDrawInfo

    Gets some info about the sprite's location and checks if the sprite is
    onscreen. If the sprite is offscreen,
    GetDrawInfo will return from *the routine that called it*.

    Routines which call this *must* be jsr subroutines.

    Returns the starting OAM index in Y.
    Returns the sprite's x position relative to the screen in $00.
    Returns the sprite's y position relative to the screen in $01.

- !ssr_FinishOamWrite

    Sets the "high OAM" bits of OAM tiles drawn by a graphics routine.
    Sets the sizes of tiles, and the "negative" bit of the x position.
    If the routine determines an OAM tile is offscreen,
    it shunts it to position $f0, where it cannot be seen.

    Takes the number of tiles to check, minus 1, in 8-bit A.
    Takes a tile size setting in Y:
    - If Y = 02, make the tiles 16x16
    - If Y = 00, make the tiles 8x8
    - If Y < 00, don't set the size,
                only check the negative bit / on-screen status.
                Sprites using this setting should set the size
                bits on their own.

- !ssr_GenericGfx_##x##

    Draws a fixed-size sprite using the cfg file palette setting.
    The available variants are 16x16, 16x32, 32x16, and 32x32.

    The subroutine automatically flips the sprite horizontally,
    but not vertically.

    Takes a pointer to the tile table in 16-bit A.
    Takes a frame number in Y.
    The format of the tile table is simply 1, 2, 2, or 4-byte rows,
    depending on the sprite size, which are the tile number for
    16x16 tiles to draw.

- !ssr_GenericGfx_FTable16x16

    Draws a sprite of arbitrary size made of 16x16 tiles.

    The subroutine automatically flips the sprite horizontally,
    but not vertically.

    Takes a pointer to the frame table in 16-bit A.
    Takes a frame number in Y.
    The frame table is a table of 16-bit pointers to frames.
    Each frame consists of the following:
    - one byte: the width of the image in pixels
    - a series of four-byte tile descriptors, each as follows:
    - tile number (cannot be $ff)
    - tile properties (yxppccct)
    - offset X (-128 .. 127)
    - offset Y (-128 .. 127)
    - the byte $ff to mark the end of the frame.

- !ssr_GenericGfx_FTableMTS

    Draws a sprite of arbitrary size, using Multiple Tile Sizes.

    The subroutine automatically flips the sprite horizontally,
    but not vertically.

    Takes a pointer to the frame table in 16-bit A.
    Takes a frame number in Y.
    The frame table is a table of 16-bit pointers to frames.
    Each frame consists of the following:
    - one byte: the width of the image in pixels
    - a series of five-byte tile descriptors, each as follows:
    - tile size ($00 for 8x8, $02 for 16x16)
    - tile number (may be $ff)
    - tile properties (yxppccct)
    - offset X (-128 .. 127)
    - offset Y (-128 .. 127)
    - the byte $ff to mark the end of the frame.
