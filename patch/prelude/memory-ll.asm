@include
;=============================================================================;
; Sprite constant values.                                                     ;
;=============================================================================;
	!dys_maxActive       = 12
	!dys_maxLevel        = 255
	!dys_maxCls          = 20

	!dys_firstOam        = $30

;=============================================================================;
; Sprite table locations.                                                     ;
;-----------------------------------------------------------------------------;
; These cannot be moved without also updating old custom sprites that use     ;
; the raw hex addresses, which are most of them, as well as SMW's sprites.    ;
; The existence of these labels is to help sprites in the future,             ;
; for e.g. SA-1 conversion.                                                   ;
;=============================================================================;
	!spr_act             = $9e
	!spr_spdX            = $b6
	!spr_spdY            = $aa
	!spr_posXL           = $e4
	!spr_posYL           = $d8
	!spr_posXH           = $14e0
	!spr_posYH           = $14d4
	!spr_posXF           = $14f8
	!spr_posYF           = $14ec
	!spr_status          = $14c8

	!spr_offscreen       = $15c4
	!spr_offscreenH      = $15a0
	!spr_offscreenV      = $186c

	!spr_facing          = $157c
	!spr_blocked         = $1588
	!spr_onSlope         = $15b8
	!spr_beingEaten      = $15d0
	!spr_objectItxn      = $15dc
	!spr_oamIndex        = $15ea
	!spr_tileProps       = $15f6
	!spr_loadStatIndex   = $161a
	!spr_behindScenery   = $1632
	!spr_inWater         = $164a
	!spr_disableCapeTime = $1fe2
	!spr_disableContact  = $154c

	!spr_props1          = $1656
	!spr_props2          = $1662
	!spr_props3          = $166e
	!spr_props4          = $167a
	!spr_props5          = $1686
	!spr_props6          = $190f

	!spr_miscA           = $c2
	!spr_miscB           = $1504
	!spr_miscC           = $1510
	!spr_miscD           = $151c
	!spr_miscE           = $1528
	!spr_miscF           = $1534
	!spr_miscG           = $1570
	!spr_miscH           = $1594
	!spr_miscI           = $1602
	!spr_miscJ           = $160e
	!spr_miscK           = $1626
	!spr_miscL           = $187b

	; This one is unused by SMW, but initialized to zero on sprite load.
	!spr_miscZ           = $1fd6

	!spr_timeA           = $1540
	!spr_timeB           = $1558
	!spr_timeC           = $1564
	!spr_timeD           = $15ac
	!spr_timeE           = $163e

	; The following defines refer to ram not used in the original SMW.
	; These ones are established traditions from the old spritetools.
	!spr_extraBit        = $7ee000
	!spr_type            = $7ee00c
	!spr_xProps1         = $7ee018
	!spr_xProps2         = $7ee024
	!spr_custNum         = $7ee030

	; These ones are inherited from Tessera.
	; More Tessera code may be supported in the future,
	; so I guess don't put too much stuff right next to these.
	!spr_xByte1          = $7ee03c
	!spr_xByte2          = $7ee048
	!spr_xByte3          = $7ee054
	!spr_xByte4          = $7ee060

	; These ones are new in Daiyousei.
	!spr_xClipL          = $7ee06c
	!spr_xClipT          = $7ee078
	!spr_xClipW          = $7ee084
	!spr_xClipH          = $7ee090

	!spr_xOpts1          = $7ee09c
	!spr_xOpts2          = $7ee0a8

;=============================================================================;
; Generator data locations.                                                   ;
;=============================================================================;

	!gen_id              = $18b9
	!gen_extraBits       = $7ee0b4
	!gen_posXY           = $7ee0b5
	!gen_xByte1          = $7ee0b6
	!gen_xByte2          = $7ee0b7
	!gen_xByte3          = $7ee0b8
	!gen_xByte4          = $7ee0b9

;=============================================================================;
; Shooter table locations.                                                    ;
;=============================================================================;

	!dys_curSht          = $18ff

	!sht_id              = $1783
	!sht_posYL           = $178b
	!sht_posYH           = $1793
	!sht_posXL           = $179b
	!sht_posXH           = $17a3
	!sht_time            = $17ab
	!sht_loadIndex       = $17b3
	!sht_xByte1          = $7ee0c0
	!sht_xByte2          = $7ee0c8
	!sht_xByte3          = $7ee0d0
	!sht_xByte4          = $7ee0d8
	!sht_miscA           = $7ee0e0
	!sht_miscB           = $7ee0e8
	!sht_extraBits       = $7ee0f0

;=============================================================================;
; Cluster sprite data locations.                                              ;
;=============================================================================;
	!dys_cls_active      = $18b8
	!cls_id              = $1892
	!cls_posYL           = $1e02
	!cls_posXL           = $1e16
	!cls_posYH           = $1e2a
	!cls_posXH           = $1e3e
	!cls_posYF           = $1e7a
	!cls_posXF           = $1e8e
	!cls_spdY            = $1e52
	!cls_spdX            = $1e66
	!cls_miscA           = $0f4a
	!cls_miscB           = $0f5e
	!cls_miscC           = $0f72
	!cls_miscD           = $0f86
	!cls_miscE           = $0f9a

;=============================================================================;
; Extended sprite data locations.                                             ;
;=============================================================================;
	!xsp_id              = $170b
	!xsp_posYL           = $1715
	!xsp_posXL           = $171f
	!xsp_posYH           = $1729
	!xsp_posXH           = $1733
	!xsp_spdY            = $173d
	!xsp_spdX            = $1747
	!xsp_posYF           = $1751
	!xsp_posXF           = $175b
	!xsp_miscA           = $1765
	!xsp_miscB           = $176f
	!xsp_behindScenery   = $1779

;=============================================================================;
; Other tables useful to sprites.                                             ;
;=============================================================================;
	!oam1_ofsX           = $0300
	!oam1_ofsY           = $0301
	!oam1_tile           = $0302
	!oam1_props          = $0303

	!oam0_ofsX           = $0200
	!oam0_ofsY           = $0201
	!oam0_tile           = $0202
	!oam0_props          = $0203

	!oam1_bitSizes       = $0410
	!oam0_bitSizes       = $0400
	!oam1_sizes          = $0460
	!oam0_sizes          = $0420

	!dys_slot            = $15e9

	!dys_wiggleTables    = $7ee200

	; These ones are mostly used internally.
	!dys_sprLoadStatuses = $1938
	!dys_lastOam         = $7ee0f8
	!dys_lastLastOam     = $7ee0f9

	!dys_oam0Index       = $7ee0fa

	!dys_loadLineMemo    = $7ee0fb
	!dys_loadOfsMemo     = $7ee0fd
	!dys_loadStatMemo    = $7ee0ff

	!dys_wiggleTblOwners = $7ee100
	!dys_wiggleTblIds    = $7ee104

