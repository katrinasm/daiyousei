@include
pushpc
	org $02f808
		jml CallCls
pullpc

CallCls:
	phb
	ldx.b #!dys_maxCls-1
.loop
	lda !cls_id,x : beq +
	stx !dys_slot
	jsl .call
+	dex : bpl .loop
	
	plb
	rtl
	
; This is a jsl so that when sprites rtl, it returns to the + above.
.call
	sta $00 : asl : clc : adc $00
	tax
	rep #$20
	lda DYS_DATA_CLS_PTRS,x
	sta $00
	sep #$20
	lda DYS_DATA_CLS_PTRS+2,x
	sta $02
	pha : plb
	ldx !dys_slot
	jml [!DP|$00]
