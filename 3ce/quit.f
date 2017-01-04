
\ quit.f for jeforth.3ce popup page and extenstion pages
\
\ QUIT is the traditional forth system's CLI loop. jeforth.f kernel is common for all
\ applications. quit.f is the good place to define propritary features of each application.
\  

: cr         	( -- ) \ 到下一列繼續輸出 *** 20111224 sam
				js: type("\n") 1 nap js: vm.scroll2inputbox();inputbox.focus() ;
				/// redefined in quit.f, 1 nap 使輸出流暢。
				/// Focus the display around the inputbox.
				\ 早一點 redefine 以便流暢 include 諸 ~.f 時的 selftest messages.
				
: {F5}			( -- boolean ) \ Hotkey handler, Confirm the Chrome extension window refresh
				<js> confirm("Really want to restart?") </jsV> 
				if js: chrome.tabs.reload() false else true then ;
				/// Defined in 3ce/quit.f
				/// Return a false to stop the hotkey event handler bubbling.
				/// Must intercept onkeydown event to avoid original function.

\ ------------------ Get args from URL -------------------------------------------------------
	js> location.href constant url // ( -- 'url' ) jeforth.3ce entire URL
	url :> split("?")[1]||"" \ Command line can be an undefined when not given
    trim value args // ( -- 'args' ) jeforth.3ce command line  
	args [if] char %20 args + :> split('%') <js>
		for (var ss="",i=1; i<tos().length; i++){
			// %20 is space and also many others need to be translated 
			ss += String.fromCharCode("0x"+tos()[i].slice(0,2)) + tos()[i].slice(2);
		};ss
	</jsV> nip to args [then]
	// Facebook always turn space to + that we need to support _ as space. 
	args ?dup [if] <js> pop().replace(/_/g," ") </jsV> to args [then]

\ ------------------ Self-test of the jeforth.f kernel --------------------------------------
	\ Do the jeforth.f self-test only when there's no command line. How to see command line is
	\ application dependent. 
	\

	args [if] \ jobs to do, disable self-test.
		warning-off
		js: tick('<selftest>').enabled=false
	[else] \ no job, do the self-test.
		warning-on
		js> tick('<selftest>').enabled=true;tick('<selftest>').buffer tib.insert
	[then] 
	js: tick('<selftest>').buffer="" \ recycle the memory
	
	\ 發現透過 rawgit.com 可以直接執行發佈在 GitHub 上的 jeforth.3htm
	\ 為了加快速度,以下都用絕對位址。避免讓 readTextFileAuto 順著 path
	\ 慢慢嘗試錯誤。
	include 3htm/f/jsc.f		    \ JavaScript debug console in 3htm/f
	include f/voc.f					\ voc.f is basic of forth language
	include 3htm/f/html5.f			\ html5.f is basic of jeforth.3htm
	include 3htm/f/element.f		\ HTML element manipulation
	include 3htm/f/platform.f		
	include f/misc.f		
	include 3htm/f/hte.f
	include 3ce/ce.f
	include 3htm/f/ls.f
	
\ ------------ End of jeforth.f -------------------
	js: vm.screenbuffer=null \ turn off the logging
	.(  OK ) \ The first prompt after system start up.
	js: vm.scroll2inputbox();inputbox.focus()

\ ----------------- run the command line -------------------------------------
	args tib.insert

\ The End 




