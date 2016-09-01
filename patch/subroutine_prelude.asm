incsrc "prelude.asm"
macro ssr(name)
	print "!","ssr_<name> = $", pc
<name>:
endmacro
%dys_freecode()
