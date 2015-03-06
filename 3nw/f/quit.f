
\ quit.f for jeforth.3nw
\
\ QUIT is the traditional forth system's CLI loop. jeforth.f kernel is common for all
\ applications. quit.f is the good place to define propritary features of each application.
\  

\ ------------------ Self-test of the jeforth.f kernel --------------------------------------
	\ Do the jeforth.f self-test only when there's no command line. How to see command line is
	\ application dependent. 
	\

	js> kvm.argv.length \ Do we have jobs from command line?
	[if] \ We have jobs from command line to do. Disable self-test.
		js: tick('<selftest>').enabled=false
	[else] \ We don't have jobs from command line to do. So we do the self-test.
		js> tick('<selftest>').enabled=true;tick('<selftest>').buffer tib.insert
	[then] 
	js: tick('<selftest>').buffer="" \ recycle the memory

	include voc.f			\ voc.f is basic of forth language
	include html5.f			\ leverage jeforth.3htm
	include element.f		\ HTML element manipulation
	include mytools.f		
	include nw.f
	include platform.f		\ leverage jeforth.3htm
	include process.f
	include path.f
	include fs.f
	
\ ----------------- save selftest.log -------------------------------------
	s" I want to view selftest.log" s" yes" = [if]
		js> tick('<selftest>').enabled [if]
			js> kvm.screenbuffer char selftest.log writeTextFile
		[then]
	[then]	

\ ----------------- run the command line -------------------------------------
	<js> (kvm.argv.slice()).join(" ") </jsV> tib.insert \ skip first cell which is the *.hta pathname itself.

\ ------------ End of jeforth.f -------------------
	js: kvm.screenbuffer=null \ turn off the logging
	.(  OK ) \ The first prompt after system start up.
