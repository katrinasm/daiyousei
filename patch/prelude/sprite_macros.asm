macro dys_offsets(main, init)
	print "MAIN ", hex(<main>)
	print "INIT ", hex(<init>)
endmacro

macro dys_main(main)
	%dys_offsets(<main>, !ssr_Nothing)
endmacro
