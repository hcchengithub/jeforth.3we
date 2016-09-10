
\ quit.f for jeforth.3nd
\
\ QUIT is the traditional forth system's CLI loop. jeforth.f kernel is common for all
\ applications, e.g. jeforth.hta or jeforth.htm,..etc. quit.f is the good place to 
\ define propritary features of each application.
\  

\ ---------- Self-Test of jeforth.f kernel ----------------------------------------
\ Do the jeforth.f self-test only when there's no command line
	<js> (kvm.argv.slice(1)).join(" ") </jsV> \ skip first cell which is the jeforth.3nd.js pathname itself.
    trim value args // ( -- string ) The command line 
	\ Do we have jobs from command line?
	args [if] \ Yes, disable self-test.
		js: tick('<selftest>').enabled=false
	[else] \ No, so we do the self-test.
		js> tick('<selftest>').enabled=true;tick('<selftest>').buffer tib.insert
	[then] js: tick('<selftest>').buffer="" \ recycle the memory

\ ---------------- jeforth.3nd special section ------------------------------------

	js> vm.appname char jeforth.3nd = [if] \ for 3nd only
	: e 		( -- ) \ Multiple line input mode, not 'edit mode' yet though. Ctrl-z to end.
				cr ." ---- Edit Mode ---- (End by ctrl-z)" cr 
				js: vm.gets.editMode=true 
				js> vm.gets()
				js: vm.gets.editMode=false
				tib.insert ;
	[then]

\ ---------------- include other modules ------------------------------------------
	include jsc.f
	include voc.f
	include misc.f
	include process.f
	include path.f
	include fs.f

\ ---------------- Run command line -----------------------------------------------
    args tib.insert 
\ ---------------- End of quit.f -----------------------------------------------
	js: kvm.screenbuffer=null \ turn off the logging
	.(  OK ) \ The first prompt after system start up.
