
\ quit.f for jeforth.3htm
\
\ QUIT is the traditional forth system's CLI loop. jeforth.f kernel is common for all
\ applications. quit.f is the good place to define propritary features of each application.
\  

\ ------------------ jsc JavaScript console debugger  --------------------------------------------
	\ jeforth.f is common for all applications. jsc is application dependent. So the definition of 
	\ kvm.jsc.xt has been moved to quit.f of each application for propritary treatments.
	\ The initial module of each application, e.g. jeforth.hta and jeforth.htm, should provide a dummy 
	\ kvm.jsc.xt before quit.f being available.
	\
	\ Usage:
	\   Put this line,
	\     if(kvm.debug){kvm.jsc.prompt="msg";eval(kvm.jsc.xt)}
	\   among JavaScript code as a break point. The "msg" shows you which break point is triggered.
	\
	\	Example:
	\	Debugger can see variables aa, bb, and input in below example.
	\
	\	<js>
	\		function test (input) {
	\			var aa = 11;
	\			var bb = 22;
	\	if(1){kvm.jsc.prompt="bp1>>>";eval(kvm.jsc.xt)}
	\		}
	\		test(33);
	\	</js>
	\

	<text>
		J a v a S c r i p t   c o n s o l e
		q, exit, quit, or <Esc> : Stop debugging.
		bye : Terminate the program.
		help : you are reading me.
		Put this line,
		  if(kvm.debug){kvm.jsc.prompt="msg";eval(kvm.jsc.xt)}
		into anywhere among JavaScript source code
		to drop a breakpoint. "msg" shows you which
		breakpoint it is.

	</text> <js> kvm.jsc.help=pop().replace(/^[\t ]*/gm,"")</js> \ remove leading Tab's and spaces
	<text>
		(function(){
			var _cmd_ = "";
			for(;;) {
				var _ss_, _result_; _ss_ = _result_ = "";
				kvm.scrollToElement($('#endofinputbox')); $('#inputbox').focus();
				_cmd_ = prompt("JavaScript debug console\nBreak point:"+kvm.jsc.prompt, _cmd_?_cmd_:"");
				_cmd_ = _cmd_==null ? 'q' : _cmd_; // Press Esc equals to press 'q'
				print(kvm.jsc.prompt + " jsc>" + _cmd_ + "\n");
				switch(_cmd_){
					case "exit" : case "q" : case "quit": return;
					case "bye"  : execute("bye"); break;
					case "help" : if(!confirm(kvm.jsc.help)) return; break;
					default : try { // 自己處理 JScript errors 以免動不動就被甩出去
						_result_ = eval(_cmd_);
						// if (typeof(_result_)=="undefined") _ss_ += "undefined\n";
						// else _ss_ += _result_ + "  (" + mytypeof(_result_) + ")\n";
						print(_result_);
						print(" (" + mytypeof(_result_) + ")\n");
						// if(!confirm(_ss_ + "\nGo on debugging?")) return;
					} catch(err) {
						_ss_ = "Oooops! " + err.message + "\n";
						print(_ss_)
						// alert(_ss_);
					}
				}
			}
		})()
	</text> js: kvm.jsc.xt=pop()

\ ------------------ Self-test of the jeforth.f kernel --------------------------------------
	\ Do the jeforth.f self-test only when there's no command line. How to see command line is
	\ application dependent. 
	\

	js> kvm.argv.length 1 > \ Do we have jobs from command line?
	[if] \ We have jobs from command line to do. Disable self-test.
		js: tick('<selftest>').enabled=false
	[else] \ We don't have jobs from command line to do. So we do the self-test.
		js> tick('<selftest>').enabled=true;tick('<selftest>').buffer tib.insert
	[then] 
	js: tick('<selftest>').buffer="" \ recycle the memory

	include voc.f			\ voc.f is basic of forth language
	include html5.f			\ html5.f is basic of jeforth.3htm
	include platform.f		
	include mytools.f		

\ ------------ End of jeforth.f -------------------
	.(  OK ) \ The first prompt after system start up.
	js: kvm.scrollToElement($('#inputbox'));$('#inputbox').focus(); \ jump to the inputbox, so user knows the selftest is completed.
