
\ quit.f for jeforth.3wsh
\
\ QUIT is the traditional forth system's CLI loop. jeforth.f kernel is common for all
\ applications, e.g. jeforth.hta or jeforth.htm,..etc. quit.f is the good place to 
\ define propritary features of each application.
\  

	js> WScript.arguments constant args // ( -- obj ) Command line arguments they are args.Unnamed("key") and args.Named(i).
	js> kvm.argv          constant argv // ( -- array ) Command line unnamed arguments array
	js> kvm.argv.length   constant argc // ( -- n ) Command line unnamed arguments count

	\ ---------- Self-Test of jeforth.f kernel ----------------------------------------
	\ Do the jeforth.f self-test only when there's no command line
	js> kvm.argv.length>=1 \ Do we have jobs from command line?
	[if] \ We have jobs from command line to do. Disable self-test.
		js: tick('<selftest>').enabled=false
	[else] \ We don't have jobs from command line to do. So we do the self-test.
		js> tick('<selftest>').enabled=true;tick('<selftest>').buffer tib.insert
	[then] js: tick('<selftest>').buffer="" \ recycle the memory

	\ ---------------- include other modules ------------------------------------------
	include voc.f
	include mytools.f

\ ----------------- save selftest.log -------------------------------------
	s" I want to view selftest.log" s" yes" = [if]
		js> tick('<selftest>').enabled [if]
			js> kvm.screenbuffer char selftest.log writeTextFile
		[then]
	[then]	

\ ---------------- Run command line -----------------------------------------------
	<js> kvm.argv.join(" ") </jsV> tib.insert \ skip first cell which is the jeforth.3nd.js pathname itself.

\ ---------------- End of quit.f -----------------------------------------------
	.(  OK ) \ The first prompt after system start up.

