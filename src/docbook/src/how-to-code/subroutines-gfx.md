# GenericGfx

GenericGfx is a collection of subroutines designed to implement some common
types of graphics subroutine.

The GenericGfx routines have a fairly uniform interface, and they can all be
called like so:
```
Gfx:
	rep #$20
	lda.w #frameTable
	ldy !frameNumber
	jsl !ssr_GenericGfx_????
	rts

frameTable:
	; data table - format depends which variant is called
```

The main differences between the GenericGfx routines are the formats of their
data tables.

## Properties of all variants
**Arguments**:
- **A** (16-bit): Pointer to frame table.
- **Y** (8-bit): Number of frame to draw.

**Returns**: none.

After the routine ends, A, X, and Y are all 8-bit again.

The subroutines automatically flip images horizontally, but not vertically.

The frame table is always loaded from the data bank, so you could consider **DB**
to be another argument. But since Daiyousei always sets the data bank to the sprite's
code bank, and there isn't really any way to put the table outside the sprite's code
bank, it's easiest just not to think about it.



## !ssr_GenericGfx_16x16
Draws a single 16x16 tile at the sprite's current position,
using the cfg file palette setting.

The tile is positioned like so, where `@` is the sprite's position:

```
@---+
|   |
+---+
```

The table is formatted like so:
```
frameTable:
	db frame0_tile
	db frame1_tile
	db frame2_tile
	; etc.
```

## !ssr_GenericGfx_32x16
Draws two 16x16 tiles in a wide rectangle at the sprite's current position,
using the cfg file palette setting.

The tiles are positioned like so, where `@` is the sprite's position:

```
@---+---+
|   |   |
+---+---+
```

The frame table is formatted like so:
```
frameTable:
	db frame0_left, frame0_right
	db frame1_left, frame1_right
	db frame2_left, frame2_right
	; etc.
```

## !ssr_GenericGfx_16x32
Draws two 16x16 tiles in a tall rectangle at the sprite's current position,
using the cfg file palette setting.

The tiles are positioned like so, where `@` is the sprite's position:

```
+---+
|   |
@---+
|   |
+---+
```

The frame table is formatted like so:
```
frameTable:
	db frame0_top, frame0_bottom
	db frame1_top, frame1_bottom
	db frame2_top, frame2_bottom
	; etc.
```

## !ssr_GenericGfx_32x32
Draws four 16x16 tiles in a big square at the sprite's current position,
using the cfg file palette setting.

The tiles are positioned like so, where `@` is the sprite's position:

```
+---+---+
|   |   |
@---+---+
|   |   |
+---+---+
```

The frame table is formatted like so:
```
frameTable:
	db frame0_top_left, frame0_top_right, frame0_bottom_left, frame0_bottom_right
	db frame1_top_left, frame1_top_right, frame1_bottom_left, frame1_bottom_right
	db frame2_top_left, frame2_top_right, frame2_bottom_left, frame2_bottom_right
	; etc.
```


## !ssr_GenericGfx_FTable16x16
Draws a sprite of arbitrary size made of 16x16 tiles. This does *not* use
the cfg file palette setting.

Unlike the fixed size routines, the frame table is a table of 16-bit pointers to frames.
Each frame consists of the following:

- one byte: the width of the image in pixels
- a series of four-byte tile descriptors, each as follows:
	- tile number (cannot be `$ff`)
	- tile properties (yxppccct)
	- offset X (8-bit signed, so it can be in `-128 ..= 127`)
	- offset Y (8-bit signed, so it can be in `-128 ..= 127`)
- the byte `$ff` to mark the end of the frame.

Tables are like so:
```
frameTable:
	dw frame0
	dw frame1
	dw frame2
	; etc.

frame0:
	db width
	db tile, props, x, y
	db tile, props, x, y
	; etc.
	db $ff
frame1:
; etc.
```

## !ssr_GenericGfx_FTableMTS
Draws a sprite of arbitrary size using **M**ultiple **T**ile **S**izes. This does *not* use
the cfg file palette setting.

Unlike the fixed size routines, the frame table is a table of 16-bit pointers to frames.
Each frame consists of the following:

- one byte: the width of the image in pixels
- a series of five-byte tile descriptors, each as follows:
	- tile size (`$00` for 8x8, `$02` for 16x16)
	- tile number (may be `$ff`, unlike in `!ssr_GenericGfx_FTable16x16`)
	- tile properties (`yxppccct`)
	- offset X (8-bit signed, so it can be in `-128 ..= 127`)
	- offset Y (8-bit signed, so it can be in `-128 ..= 127`)
- the byte `$ff` to mark the end of the frame.
```
frameTable:
	dw frame0
	dw frame1
	dw frame2
	; etc.

frame0:
	db width
	db size, tile, props, x, y
	db size, tile, props, x, y
	; etc.
	db $ff
frame1:
; etc.
```

