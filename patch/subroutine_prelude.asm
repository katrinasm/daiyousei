incsrc "prelude.asm"
macro ssr(name)
	print "!","ssr_<name> = $", pc
endmacro
macro smw_ssr(name, offset)
	print "!","ssr_<name> = $", hex(<offset>)
	<name> = <offset>
endmacro
%dys_freecode()
