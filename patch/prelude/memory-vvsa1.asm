@include
;=============================================================================;
; Sprite constant values.                                                     ;
;=============================================================================;
	!dys_maxActive       = 20
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
	!spr_act             = $3200
	!spr_spdX            = $b6
	!spr_spdY            = $9e
	!spr_posXL           = $322c
	!spr_posYL           = $3216
	!spr_posXH           = $326e
	!spr_posYH           = $3258
	!spr_posXF           = $74de
	!spr_posYF           = $74c8
	!spr_status          = $3242

	!spr_offscreen       = $7536
	!spr_offscreenH      = $3376
	!spr_offscreenV      = $7642

	!spr_facing          = $3334
	!spr_blocked         = $334a
	!spr_onSlope         = $7520
	!spr_beingEaten      = $754c
	!spr_objectItxn      = $7562
	!spr_oamIndex        = $33a2
	!spr_tileProps       = $33b8
	!spr_loadStatIndex   = $7578
	!spr_behindScenery   = $75a4
	!spr_inWater         = $75ba
	!spr_disableCapeTime = $7fd6
	!spr_disableContact  = $32dc

	!spr_props1          = $75d0
	!spr_props2          = $75ea
	!spr_props3          = $7600
	!spr_props4          = $7616
	!spr_props5          = $762c
	!spr_props6          = $7658

	!spr_miscA           = $3216
	!spr_miscB           = $74f4
	!spr_miscC           = $750a
	!spr_miscD           = $3284
	!spr_miscE           = $329a
	!spr_miscF           = $32b0
	!spr_miscG           = $331e
	!spr_miscH           = $3360
	!spr_miscI           = $33ce
	!spr_miscJ           = $33e4
	!spr_miscK           = $758e
	!spr_miscL           = $3410

	; This one is unused by SMW, but initialized to zero on sprite load.
	!spr_miscZ           = $766e

	!spr_timeA           = $32c6
	!spr_timeB           = $32f2
	!spr_timeC           = $3308
	!spr_timeD           = $338c
	!spr_timeE           = $33fa

	; The following defines refer to ram not used in the original SMW.
	; These ones are established traditions from the old spritetools.
	!spr_extraBit        = $418b10
	!spr_type            = $418b1c
	!spr_xProps1         = $418b28
	!spr_xProps2         = $418b34
	!spr_custNum         = $418b9e ; Is the 9e bit on purpose? I bet.

	; These ones are inherited from Tessera.
	; More Tessera code may be supported in the future,
	; so I guess don't put too much stuff right next to these.
	!spr_xByte1          = $418b40
	!spr_xByte2          = $418b4c
	!spr_xByte3          = $418b58
	!spr_xByte4          = $418b64

	!spr_xClipL          = $418baa
	!spr_xClipT          = $418bb6
	!spr_xClipW          = $418bc2
	!spr_xClipH          = $418bce

	; These ones are new in Daiyousei.
	!spr_xOpts1          = $418c40
	!spr_xOpts2          = $418c4c

;=============================================================================;
; Generator data locations.                                                   ;
;=============================================================================;

	!gen_id              = $78b9
	!gen_posXY           = $418cc0
	!gen_xProps1         = $418cc1
	!gen_xProps2         = $418cc2
	!gen_extraBits       = $418cc3
	!gen_xByte1          = $418cc4
	!gen_xByte2          = $418cc5
	!gen_xByte3          = $418cc6
	!gen_xByte4          = $418cc7

;=============================================================================;
; Shooter table locations.                                                    ;
;=============================================================================;

	!dys_curSht          = $78ff

	!sht_id              = $7783
	!sht_posYL           = $778b
	!sht_posYH           = $7793
	!sht_posXL           = $779b
	!sht_posXH           = $77a3
	!sht_time            = $77ab
	!sht_loadIndex       = $77b3
	!sht_xByte1          = $418c00
	!sht_xByte2          = $418c08
	!sht_xByte3          = $418c10
	!sht_xByte4          = $418c18
	!sht_miscA           = $418c20
	!sht_miscB           = $418c28
	!sht_extraBits       = $418c30

;=============================================================================;
; Cluster sprite data locations.                                              ;
;=============================================================================;
	!dys_cls_active      = $78b8
	!cls_id              = $7892
	!cls_posYL           = $7e02
	!cls_posXL           = $7e16
	!cls_posYH           = $7e2a
	!cls_posXH           = $7e3e
	!cls_posYF           = $7e7a
	!cls_posXF           = $7e8e
	!cls_spdY            = $7e52
	!cls_spdX            = $7e66
	!cls_miscA           = $6f4a
	!cls_miscB           = $6f5e
	!cls_miscC           = $6f72
	!cls_miscD           = $6f86
	!cls_miscE           = $6f9a

;=============================================================================;
; Extended sprite data locations.                                             ;
;=============================================================================;
	!xsp_id              = $770b
	!xsp_posYL           = $7715
	!xsp_posXL           = $771f
	!xsp_posYH           = $7729
	!xsp_posXH           = $7733
	!xsp_spdY            = $773d
	!xsp_spdX            = $7747
	!xsp_posYF           = $7751
	!xsp_posXF           = $775b
	!xsp_miscA           = $7765
	!xsp_miscB           = $776f
	!xsp_behindScenery   = $7779

;=============================================================================;
; Other tables useful to sprites.                                             ;
;=============================================================================;
	!oam1_ofsX           = $6300
	!oam1_ofsY           = $6301
	!oam1_tile           = $6302
	!oam1_props          = $6303

	!oam0_ofsX           = $6200
	!oam0_ofsY           = $6201
	!oam0_tile           = $6202
	!oam0_props          = $6203

	!oam1_bitSizes       = $6410
	!oam0_bitSizes       = $6400
	!oam1_sizes          = $6460
	!oam0_sizes          = $6420

	!dys_slot            = $75e9
	; These ones are mostly used internally.
	!dys_sprLoadStatuses = $418a00
	!dys_lastOam         = $418c38
	!dys_lastLastOam     = $418c39

	!dys_oam0Index       = $418c3a
