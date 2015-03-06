
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
		s : Single step. (bp=-1)
		p : Run until next IP. (bp=ip+1)
		r : Free run until ret. (bp=rtos)
		erase : Erase debug message at bottom.
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
				_cmd_ = prompt("JavaScript debug console\nBreak point:"+kvm.jsc.prompt, _cmd_?_cmd_:"");
				_cmd_ = _cmd_==null ? 'q' : _cmd_; // Press Esc equals to press 'q'
				print(kvm.jsc.prompt + " " + _cmd_ + "\n");
				switch(_cmd_){
					case "exit" : case "q" : case "quit": bp=0; return;
					case "s" : bp=-1; return; // 
					case "p" : bp=ip+1; return;
					case "r" : bp=rstack[rstack.length-1]; return;
					case "bye"  : execute("bye"); break;
					case "help" : if(!confirm(kvm.jsc.help)) return; break;
					case "erase" : 
						inputbox.value = "";
						for(var i=0; i<5; i++){execute('{backSpace}');pop();} break;
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

\ ------------------ Get args from URL -------------------------------------------------------
	js> location.href constant url // ( -- 'url' ) jeforth.3htm url entire command line 
	url :> split("?")[1] value args // ( -- 'args' ) jeforth.3htm args
	args [if] char %20 args + :> split('%') <js>
		for (var ss="",i=1; i<tos().length; i++){
			ss += String.fromCharCode("0x"+tos()[i].slice(0,2)) + tos()[i].slice(2);
		};ss
	</jsV> nip to args [then]

\ ------------------ Self-test of the jeforth.f kernel --------------------------------------
	\ Do the jeforth.f self-test only when there's no command line. How to see command line is
	\ application dependent. 
	\

	args [if] \ jobs to do, disable self-test.
		js: tick('<selftest>').enabled=false
	[else] \ no job, do the self-test.
		js> tick('<selftest>').enabled=true;tick('<selftest>').buffer tib.insert
	[then] 
	js: tick('<selftest>').buffer="" \ recycle the memory

	include voc.f			\ voc.f is basic of forth language
	include html5.f			\ html5.f is basic of jeforth.3htm
	include element.f		\ HTML element manipulation
	include platform.f		
	include mytools.f		

\ ----------------- run the command line -------------------------------------
	args tib.insert

\ ------------ End of jeforth.f -------------------
	js: kvm.screenbuffer=null \ turn off the logging
	.(  OK ) \ The first prompt after system start up.
