# Tables

## Sprite Tables
**Table name** is the name used in code to refer to this table.

**Original addr** is the address this table has in SMW or Romi's Spritetool, if it existed then.
This might not correspond to the actual address, since in a ROM using Vitor Vilela's SA-1 patch these tables are all moved.
The original address can be used to find these tables in the [SMWCentral RAM map](https://www.smwcentral.net/?p=nmap&m=smwram).

**Init** is the value in the table when the sprite initializes. *0* indicates the value is set to 0, *Config* indicates that the value comes from
the sprite's CFG file, *Level* indicates that the value is usually taken from level data, *Other* indicates that it is initalized by other means,
and a dash (-) indicates that the value is unitialized (so that a stale value exists in the table).

| Table name           | Original addr | Init   | Purpose                                                 |
|----------------------|---------------|--------|---------------------------------------------------------|
|`!spr_act`            | `$9e`         | Config | Sprite acts-like setting                                |
|`!spr_status`         | `$14c8`       | -      | Sprite status                                           |
|`!spr_custNum`        | `$7fab9e`     | Other  | Sprite number, low byte                                 |
|`!spr_extraBit`       | `$7fab10`     | Other  | Extra bit and sprite number high bits                   |
|`!spr_spdX`           | `$b6`         | 0      | X speed                                                 |
|`!spr_spdY`           | `$aa`         | 0      | Y speed                                                 |
|`!spr_posXL`          | `$e4`         | -      | X position, low byte                                    |
|`!spr_posYL`          | `$d8`         | -      | Y position, low byte                                    |
|`!spr_posXH`          | `$14e0`       | -      | X position, high byte                                   |
|`!spr_posYH`          | `$14d4`       | -      | Y position, high byte                                   |
|`!spr_posXF`          | `$14f8`       | 0      | X position, fractional part                             |
|`!spr_posYF`          | `$14ec`       | 0      | Y position, fractional part                             |
|`!spr_facing`         | `$157c`       | 0      | Sprite direction (sometimes misc. data)                 |
|`!spr_miscA`          | `$c2`         | 0      | misc. data                                              |
|`!spr_miscB`          | `$1504`       | 0      | misc. data                                              |
|`!spr_miscC`          | `$1510`       | -      | misc. data                                              |
|`!spr_miscD`          | `$151c`       | 0      | misc. data                                              |
|`!spr_miscE`          | `$1528`       | 0      | misc. data                                              |
|`!spr_miscF`          | `$1534`       | 0      | misc. data                                              |
|`!spr_miscG`          | `$1570`       | 0      | misc. data                                              |
|`!spr_miscH`          | `$1594`       | 0      | misc. data                                              |
|`!spr_miscI`          | `$1602`       | 0      | misc. data                                              |
|`!spr_miscJ`          | `$160e`       | 0      | misc. data                                              |
|`!spr_miscK`          | `$1626`       | 0      | misc. data                                              |
|`!spr_miscL`          | `$187b`       | 0      | misc. data                                              |
|`!spr_miscZ`          | `$1fd6`       | 0      | misc. data                                              |
|`!spr_timeA`          | `$1540`       | 0      | misc. timers                                            |
|`!spr_timeB`          | `$1558`       | 0      | misc. timers                                            |
|`!spr_timeC`          | `$1564`       | 0      | misc. timers                                            |
|`!spr_timeD`          | `$15ac`       | -      | misc. timers                                            |
|`!spr_timeE`          | `$163e`       | 0      | misc. timers                                            |
|`!spr_blocked`        | `$1588`       | 0      | interaction                                             |
|`!spr_props1`         | `$1656`       | Config | multiple purposes                                       |
|`!spr_props2`         | `$1662`       | Config | multiple purposes                                       |
|`!spr_props3`         | `$166e`       | Config | multiple purposes                                       |
|`!spr_props4`         | `$167a`       | Config | multiple purposes                                       |
|`!spr_props5`         | `$1686`       | Config | multiple purposes                                       |
|`!spr_props6`         | `$190f`       | Config | multiple purposes                                       |
|`!spr_xProps1`        | `$7fab28`     | Config | user cfg data                                           |
|`!spr_xProps2`        | `$7fab34`     | Config | user cfg data, main routine control                     |
|`!spr_type`           | `$7fab1c`     | Config | useless, exists for backward compatibility              |
|`!spr_oamIndex`       | `$15ea`       | -      | used by graphics routines; changes every frame          |
|`!spr_tileProps`      | `$15f6`       | Config | tile properties for graphics routines                   |
|`!spr_offscreen`      | `$15c4`       | 0      | Sprite off-screen tracking                              |
|`!spr_offscreenH`     | `$15a0`       | 0      | Sprite off-screen tracking                              |
|`!spr_offscreenV`     | `$186c`       | -      | Sprite off-screen tracking                              |
|`!spr_onSlope`        | `$15b8`       | -      | interaction                                             |
|`!spr_inWater`        | `$164a`       | 0      | interaction                                             |
|`!spr_objectItxn`     | `$15dc`       | 0      | flag to disable interaction with level                  |
|`!spr_beingEaten`     | `$15d0`       | 0      | indicates a sprite is being eaten by yoshi              |
|`!spr_loadStatIndex`  | `$161a`       | Level  | sprite's position in level data; used to track spawning.|
|`!spr_behindScenery`  | `$1632`       | 0      | graphics                                                |
|`!spr_disableCapeTime`| `$1fe2`       | 0      | timer to disable cape damage, and other purposes        |
|`!spr_disableContact` | `$154c`       | 0      | timer to disable contact with player                    |
|`!spr_xByte1`         | N/A           | Level  | extra byte 1                                            |
|`!spr_xByte2`         | N/A           | Level  | extra byte 2                                            |
|`!spr_xByte3`         | N/A           | Level  | extra byte 3                                            |
|`!spr_xByte4`         | N/A           | Level  | extra byte 4                                            |
|`!spr_xClipL`         | N/A           | Config | custom clipping - left offset                           |
|`!spr_xClipT`         | N/A           | Config | custom clipping - top offset                            |
|`!spr_xClipW`         | N/A           | Config | custom clipping - width                                 |
|`!spr_xClipH`         | N/A           | Config | custom clipping - height                                |
|`!spr_xOpts1`         | N/A           | Config | reserved for expansion                                  |
|`!spr_xOpts2`         | N/A           | Config | daiyousei custom options                                |

## Generator data

| Table name           | Original addr | Init   | Purpose                                                 |
|----------------------|---------------|--------|---------------------------------------------------------|
|`!gen_id`             | `$18b9`       | Other  | Sprite number, low byte                                 |
|`!gen_extraBits`      | N/A           | Other  | Extra bit and sprite number high bits                   |
|`!gen_posXY`          | N/A           | Level  | Position of generator within screen (`yyyyxxxx`)        |
|`!gen_xProps1`        | N/A           | Config | user cfg data                                           |
|`!gen_xProps2`        | N/A           | Config | user cfg data                                           |
|`!gen_xByte1`         | N/A           | Level  | extra byte 1                                            |
|`!gen_xByte2`         | N/A           | Level  | extra byte 2                                            |
|`!gen_xByte3`         | N/A           | Level  | extra byte 3                                            |
|`!gen_xByte4`         | N/A           | Level  | extra byte 4                                            |


## Shooter Tables

| Table name           | Original addr | Init   | Purpose                                                 |
|----------------------|---------------|--------|---------------------------------------------------------|
|`!sht_id`             | `$1783`       | Other  | Sprite number, low byte                                 |
|`!sht_extraBits`      | N/A           | Other  | Extra bit and sprite number high bits                   |
|`!sht_posXL`          | `$179b`       | -      | X position, low byte                                    |
|`!sht_posYL`          | `$178b`       | -      | Y position, low byte                                    |
|`!sht_posXH`          | `$17a3`       | -      | X position, high byte                                   |
|`!sht_posYH`          | `$1793`       | -      | Y position, high byte                                   |
|`!sht_time`           | `$17ab`       | `$10`  | timer (usually time until a sprite is spawned)          |
|`!sht_loadIndex`      | `$17b3`       | Level  | sprite's position in level data; used to track spawning.|
|`!sht_xByte1`         | N/A           | Level  | extra byte 1                                            |
|`!sht_xByte2`         | N/A           | Level  | extra byte 2                                            |
|`!sht_xByte3`         | N/A           | Level  | extra byte 3                                            |
|`!sht_xByte4`         | N/A           | Level  | extra byte 4                                            |
|`!sht_miscA`          | N/A           | -      | misc. data                                              |
|`!sht_miscB`          | N/A           | -      | misc. data                                              |

## Cluster Sprite Tables
Cluster sprites don't have a shared initializer the way other kinds do, so there is no **Init** column
in this table.

Furthermore, cluster sprites tend to use their tables in strange ways, so most of the table names and
purposes should be taken as aspirational.

| Table name           | Original addr | Purpose                                                 |
|----------------------|---------------|---------------------------------------------------------|
|`!cls_id`             | `$1892`       | Sprite number                                           |
|`!cls_posXL`          | `$1e16`       | X position, low byte                                    |
|`!cls_posYL`          | `$1e02`       | Y position, low byte                                    |
|`!cls_posXH`          | `$1e3e`       | X position, high byte                                   |
|`!cls_posYH`          | `$1e2a`       | Y position, high byte                                   |
|`!cls_posYF`          | `$1e7a`       | X position, fractional part                             |
|`!cls_posXF`          | `$1e8e`       | Y position, fractional part                             |
|`!cls_spdY`           | `$1e52`       | X speed                                                 |
|`!cls_spdX`           | `$1e66`       | Y speed                                                 |
|`!cls_miscA`          | `$0f4a`       | misc. data                                              |
|`!cls_miscB`          | `$0f5e`       | misc. data                                              |
|`!cls_miscC`          | `$0f72`       | misc. data                                              |
|`!cls_miscD`          | `$0f86`       | misc. data                                              |
|`!cls_miscE`          | `$0f9a`       | misc. data                                              |

## Extended Sprite Tables
Like cluster sprites, extended sprtes don't have a shared initializer, so there is no **Init** column
in this table.

| Table name           | Original addr | Purpose                                                 |
|----------------------|---------------|---------------------------------------------------------|
|`!xsp_id`             | `$170b`       | Sprite number                                           |
|`!xsp_posXL`          | `$171f`       | X position, low byte                                    |
|`!xsp_posYL`          | `$1715`       | Y position, low byte                                    |
|`!xsp_posXH`          | `$1733`       | X position, high byte                                   |
|`!xsp_posYH`          | `$1729`       | Y position, high byte                                   |
|`!xsp_spdX`           | `$1747`       | X speed                                                 |
|`!xsp_spdY`           | `$173d`       | Y speed                                                 |
|`!xsp_posXF`          | `$175b`       | X position, fractional part                             |
|`!xsp_posYF`          | `$1751`       | Y position, fractional part                             |
|`!xsp_miscA`          | `$1765`       | misc. data                                              |
|`!xsp_miscB`          | `$176f`       | misc. data                                              |
|`!xsp_behindScenery`  | `$1779`       | marks sprite as behind scenery                          |


