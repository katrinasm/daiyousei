macro dys_offsets(main, init)
	print "MAIN ", hex(<main>)
	print "INIT ", hex(<init>)
endmacro

macro dys_main(main)
	%dys_offsets(<main>, !ssr_Nothing)
endmacro

macro dys_offsets3(main, init, drop)
	print "MAIN ", hex(<main>)
	print "INIT ", hex(<init>)
	print "DROP ", hex(<drop>)
endmacro
