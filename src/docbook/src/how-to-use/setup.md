# Setup
Daiyousei keeps track of quite a few things, so it needs a certain directory
structure to work. The directory you run daiyousei from needs to have at least
the following stuff:
```
<your folder name>/
├── <your hack>
├── <your spritelist>
├── daiyousei.exe
├── asar.dll
└── patch/
    ├── daiyousei.asm
    └── <other asm stuff...>
```

`<your hack>` is the `.sfc`/`.smc` you file you edit all the time.
`<your spritelist>` is a text file, discussed in
[the section on sprite lists](how-to-use/sprite-list.html).
Some of these file extensions may not match up on Linux/Unix-likes.

Aside from your hack and spritelist, this is how things are laid out in the `.zip`
in which Daiyousei is distributed. So just try not to move too much.

Additionally, if you use certain features those need folders, too. So you'll
probably have a few extra folders:
```
<your folder name>/
...
├── sprites/
│   ├── some_sprite.asm
│   ├── some_sprite.cfg
│   └── ...
├── shooters/
│   ├── some_shooter.asm
│   ├── some_shooter.cfg
│   └── ...
├── generators/
│   ├── some_generator.asm
│   ├── some_generator.cfg
│   └── ...
├── cluster/
│   ├── some_cluster_sprite.asm
│   ├── some_cluster_sprite.cfg
│   └── ...
├── overworld/
│   ├── some_overworld_sprite.asm
│   ├── some_overworld_sprite.cfg
│   └── ...
└── subroutines/
    ├── some_subroutine.asm
    └── ...
```


If you don't like having a billion folders all together like this,
you can create a subdirectory named `daiyousei.d`, where daiyousei will look
for all the other folders it uses:
```
<your folder name>/
├── <your hack>
├── <your spritelist>
├── daiyousei.exe
├── asar.dll
└── daiyousei.d/
    ├── patch/
	├── sprites/
	├── shooters/
	├── generators/
	├── cluster/
	├── overworld/
	└── subroutines/
```

A few alternate setups are available for [advanced users](how-to-use/advanced.md).