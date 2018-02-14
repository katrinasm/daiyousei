; This file is included by nearly all of Daiyousei's code.
; It is also attached to all included sprites before insertion.
; Neither it nor anything it includes has any actual asm in it;
; it is used for basically a giant set of defines and macros.

incsrc "options.asm"

; There’s already a bunch of code & coders out there that think that
; the SA-1 and Vitor Vilela’s SA-1 pack are the exact same thing.
; They will never be good.
; However, I, personally, refuse to do this because I have dreams.
; As such Daiyousei allows opting out of ‘auto-detecting’ the SA-1 pack
; (I seriously cannot state too many times how presumptuous this ‘detection’
;  is, it is 0% difficult to put in a separate flag byte)
; by either setting options.asm with !opt_vitorSA1 = 0 or by setting the unused
; vector $fff0 to ASCII "NO".

if read1($00ffd5) == $23 && (read1($00fff0) != 'N' || read1($00fff1) != 'O')
	!opt_vitorSA1 ?= 1
else
	!opt_vitorSA1 ?= 0
endif

if !opt_vitorSA1
	sa1rom
	!DP = $3000
	!WB = $6000
	!opt_fastrom = 0
else
	lorom
	!DP = $0000
	!WB = $0000
endif

if !opt_fastrom
	!dys_fastromOfs = $800000
	!F = |$800000
else
	!dys_fastromOfs = 0
	!F = |0
endif

!opt_largeLevels ?= 0
!opt_katysHack ?= 0

incsrc "prelude/macros.asm"

!opt_manySprites ?= 1

if !opt_largeLevels
	!opt_manySprites = 1
endif

!opt_cpuMeters ?= 0

if !opt_largeLevels
	incsrc "prelude/memory-ll.asm"
else
	if !opt_vitorSA1 == 0
		incsrc "prelude/memory.asm"
	else
		incsrc "prelude/memory-vvsa1.asm"
	endif
endif
incsrc "prelude/subroutine_ptrs.asm"

if !opt_largeLevels
	incsrc "prelude/ll_mem.asm"
endif

if !opt_katysHack
	incsrc "prelude/kt_mem.asm"
endif
