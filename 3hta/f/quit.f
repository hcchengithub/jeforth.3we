
\ quit.f for jeforth.3hta
\
\ QUIT is the traditional forth system's CLI loop. jeforth.f kernel is common for all
\ applications. quit.f is the good place to define propritary features of each application.
\  
				
: cr         	( -- ) \ 到下一列繼續輸出 *** 20111224 sam
				js: type("\n") 1 nap js: jump2endofinputbox.click();inputbox.focus() ;
				/// redefined in quit.f, 1 nap 使輸出流暢。
				/// Focus the display around the inputbox.
				\ 早一點 redefine 以便流暢 include 諸 ~.f 時的 selftest messages.

\ ------------------ Self-test of the jeforth.f kernel --------------------------------------
	\ Do the jeforth.f self-test only when there's no command line. How to see command line is
	\ application dependent. 
	\
	js> vm.argv.length 1 > \ Do we have jobs from command line?
	[if] \ We have jobs from command line to do. Disable self-test.
		js: tick('<selftest>').enabled=false
	[else] \ We don't have jobs from command line to do. So we do the self-test.
		js> tick('<selftest>').enabled=true;tick('<selftest>').buffer tib.insert
	[then] js: tick('<selftest>').buffer="" \ recycle the memory
	
	include jsc.f		\ JavaScript debug console in 3htm/f
	include voc.f		\ voc.f is basic of forth language
	include html5.f		\ HTML5 is HTA's plateform feature
	include jquery.f    \ Avoid Windows XP, Windows 7 HTA problems from happening immediately
	include element.f	\ HTML element manipulation
	include platform.f 	\ Hotkey handlers and platform features
	include vb.f		\ Being able to run VBS is what HTA is for.
	include wsh.f		\ Windows Shell Host
	include env.f 		\ Windows environment variables
	include beep.f		\ Define the beep command
	include binary.f	\ Read/Write binary file
	include shell.application.f
	include wmi.f
	include excel.f
	include canvas.f
	include mytools.f
	
\ ----------------- run the command line -------------------------------------
	<js> (vm.argv.slice(1)).join(" ") </jsV> tib.insert \ skip first cell which is the *.hta pathname itself.

\ ------------ End of jeforth.f -------------------
	js: vm.screenbuffer=null \ turn off the logging
	.(  OK ) \ The first prompt after system start up.
