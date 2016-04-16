
\ quit.f for jeforth.3nw
\
\ QUIT is the traditional forth system's CLI loop. jeforth.f kernel is common for all
\ applications. quit.f is the good place to define propritary features of each application.
\  

: cr         	( -- ) \ 到下一列繼續輸出 *** 20111224 sam
				js: type("\n") 1 nap js: window.scrollTo(0,endofinputbox.offsetTop);inputbox.focus() ;
				/// redefined in quit.f, 1 nap 使輸出流暢。
				/// Focus the display around the inputbox.
				\ 早一點 redefine 以便流暢 include 諸 ~.f 時的 selftest messages.

\ ------------------ Self-test of the jeforth.f kernel --------------------------------------
	\ Do the jeforth.f self-test only when there's no command line. How to see command line is
	\ application dependent. 
	\

	js> vm.argv.length \ Do we have jobs from command line?
	[if] \ We have jobs from command line to do. Disable self-test.
		js: tick('<selftest>').enabled=false
	[else] \ We don't have jobs from command line to do. So we do the self-test.
		js> tick('<selftest>').enabled=true;tick('<selftest>').buffer tib.insert
	[then] 
	js: tick('<selftest>').buffer="" \ recycle the memory

	include jsc.f			\ JavaScript debug console
	include voc.f			\ voc.f is basic of forth language
	include html5.f			\ leverage jeforth.3htm
	include element.f		\ HTML element manipulation
	include mytools.f		
	include nw.f
	include platform.f		\ leverage jeforth.3htm
	include process.f
	include path.f
	include fs.f
	include editor.f
	include ls.f

\ ----------------- run the command line -------------------------------------
	<js> (vm.argv.slice()).join(" ") </jsV> tib.insert \ skip first cell which is the *.hta pathname itself.

\ ------------ End of quit.f -------------------
	js: vm.screenbuffer=null \ turn off the logging
	.(  OK ) \ The first prompt after system start up.
	js: window.scrollTo(0,endofinputbox.offsetTop);inputbox.focus()
