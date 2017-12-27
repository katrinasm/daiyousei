# The Command Line

## Basic use

Daiyousei uses the following command at its most basic:

```daiyousei romname spritelist.txt```

where `romname` is a placeholder for your hack's filename, and `spritelist.txt`
is a placeholder for [your spritelist](how-to-use/sprite-list.html)
(which should probably be a .txt file).

This will insert all of the sprites contained in the spritelist to the rom.

The basic command shown above is almost identical to `sprite_tool`, so if
you're familiar with that you can just swap `daiyousei` for `sprite_tool` and
you'll be good.

Once you run this command, Daiyousei will show you a list of the sprites it
is inserting and tell you when it is done. After this, you can place the sprites
using a SMW level editor.

## Flags
Daiyousei also offers a few flags for less core features:
### `-d`: Generate a sprite description list
By running `daiyousei -d romname spritelist`, Daiyousei will generate a
*description file* (a `.ssc` fuke) so that sprites can be hovered over in Lunar Magic.
Usually used with `-c` as well.
The description file is generated from the sprites' config files; in the absence
of a description the sprite's name will be used as the description.

In the future, this command should be able to generate an image to display the
sprites within the levels; this is not yet supported, so they all get an ugly
default image. I apologize.

### `-c`: Generate a custom collection of sprites
By running `daiyousei -c romname spritelist`, Daiyousei will generate a
*custom collection of sprites*, (one `.mw2` file and `.mwt` file), which allows
sprites to be selected from Lunar Magic's "Custom Collections of Sprites" dialog.

If run together with `-d` as `daiyousei -cd romname spritelist`, you will get
a nice list of sprites and their descriptions. (These commands might be merged
in the future...)

### `-v`: Vocal mode
By running `daiyousei -v romname spritelist`, Daiyousei will run in vocal mode.
This is a flag intended mainly for sprite programmers; in vocal mode Daiyousei
will display the code offsets of the sprites it inserts, as well as displaying
assembler warnings.

### `-V`: give version information
By running `daiyousei -V` (that's a capital V), daiyousei will display version information and
then exit immediately. Other options can technically be used with `-V`, but
won't do anything.

### Other flags
Daiyousei supports other flags, which you should probably only use if you are
ready to spend some time figuring out why it broke something. See the
[advanced section](how-to-use/advanced.html) for information on those flags.