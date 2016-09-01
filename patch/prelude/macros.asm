;=============================================================================;
; Allocation macros.                                                          ;
;=============================================================================;

macro dys_free(type)
	free<type> cleaned
?here:
	db "DYS"
	; pushpc
		; !DYS_STORAGE_PTRS #= read3($0ef30c)+$400
		; !DYS_CNT #= read2(!DYS_STORAGE_PTRS)
		; !DYS_HERE #= !DYS_STORAGE_PTRS+(!DYS_CNT*3)+2
		; org !DYS_HERE
			; dl ?here
		; org !DYS_STORAGE_PTRS
			; dw !DYS_CNT+1
	; pullpc
endmacro

macro dys_freecode()
	%dys_free(code)
endmacro

macro dys_freedata()
	%dys_free(data)
endmacro

macro OB(opc, addr)
	if <addr> < $100
		<opc>.b <addr>
	else
		<opc>.l <addr>
	endif
endmacro

macro OBX(opc, addr)
	if <addr> < $100
		<opc>.b <addr>,x
	else
		<opc>.l <addr>,x
	endif
endmacro

macro dys_sxb()
	; 6 bytes
	and #$80 : beq + : lda #$ff : +
endmacro

macro dys_stmult_a8_y8()
	if !opt_VitorSA1 == 0
		sta $4212
		sty $4213
		if !opt_debugging
			eor #$55
		endif
	else
		sta $22?0
		%dys_sxb()
		sta $22?1
		tya
		sta $22?2
		%dys_sxb()
		sta $22?3
	endif
endmacro

macro dys_stmult_a16_y8()
	if !opt_VitorSA1 == 0
		sta $21??                         ;   3
		sty $21??                         ; + 3
		tya                               ; + 1
		%dys_sxb()                        ; + 6
		if !opt_debugging                 ;   = 13
			eor #$5555                    ; + 3
		endif                             ;   = 16
	else
		sta $22?0                         ;   3
		tya                               ; + 1
		bpl + : ora #$ff00 : +            ; + 5
		sta $22?2                         ; + 3
		if !opt_debugging                 ;   = 12
			jmp + : phd : pld : +         ; + 4
		endif                             ;   = 16
	endif
endmacro

macro dys_ldmult_a16()
	if !opt_VitorSA1 == 0
		lda $4216
	else
		lda $23??
	endif
endmacro

macro dys_ldmult_a8()
	rep #$20
	%dys_ldmult_a16()
endmacro
