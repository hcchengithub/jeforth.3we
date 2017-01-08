
\ quit.f for jeforth.3nw
\
\ QUIT is the traditional forth system's CLI loop. jeforth.f kernel is common for all
\ applications. quit.f is the good place to define propritary features of each application.
\  

: cr         	( -- ) \ 到下一列繼續輸出 *** 20111224 sam
				js: type("\n") 1 nap js: vm.scroll2inputbox();inputbox.focus() ;
				/// redefined in quit.f, 1 nap 使輸出流暢。
				/// Focus the display around the inputbox.
				\ 早一點 redefine 以便流暢 include 諸 ~.f 時的 selftest messages.

\ ------------------ Self-test of the jeforth.f kernel --------------------------------------
	\ Do the jeforth.f self-test only when there's no command line. How to see command line is
	\ application dependent. 
	\
	<js> (vm.argv.slice()).join(" ") </jsV> trim value args // ( -- string ) The command line 
	\ Do we have jobs from command line?
	args [if] \ Yes, disable self-test.
		warning-off
		js: tick('<selftest>').enabled=false
	[else] \ No, so we do the self-test.
		warning-on
		js> tick('<selftest>').enabled=true;tick('<selftest>').buffer tib.insert
	[then] 
	js: tick('<selftest>').buffer="" \ recycle the memory

	include 3htm/f/jsc.f	\ JavaScript debug console
	include voc.f			\ voc.f is basic of forth language
	include html5.f			\ leverage jeforth.3htm
	include element.f		\ HTML element manipulation
	include misc.f		
	include nw.f
	include platform.f		\ leverage jeforth.3htm
	include process.f
	include path.f
	include fs.f
	include hte.f
	include ls.f

\ ------------ End of quit.f -------------------
	js: vm.screenbuffer=null \ turn off the logging
	.(  OK ) \ The first prompt after system start up.
	js: vm.scroll2inputbox();inputbox.focus()

\ ----------------- run the command line -------------------------------------
    args tib.insert 

\ The End





	
	