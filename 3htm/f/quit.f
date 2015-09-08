
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
		rr: Free run until ret. (bp=next rtos)
		erase : Erase debug message at bottom.
		bye : Terminate the program.
		help : you are reading me.
		Put this line,
		> if(vm.debug){vm.jsc.prompt="msg";eval(vm.jsc.xt)}
		into anywhere among JavaScript source code to drop a breakpoint. "msg" shows you which breakpoint it is.

	</text> 
	<js> 
		vm.jsc.help=pop().replace(/^[\t ]*/gm,""); // remove leading Tab's and spaces
		vm.jsc.cmd = "";
		vm.jsc.enable = true;
	</js> 
	<text>
		(function(){
			var eraseCount=12;
			for(;;) {
				type('\n -------- J a v a S c r i p t   C o n s o l e --------\n');
				// show ip which is next step
				type(
					" " + (ip  ) + " : " + ((dictionary[(ip  )]==null) ? "RET" : ((dictionary[(ip  )]=="") ? "EXIT" : dictionary[(ip  )])) + "\n" +
					" " + (ip+1) + " : " + ((dictionary[(ip+1)]==null) ? "RET" : ((dictionary[(ip+1)]=="") ? "EXIT" : dictionary[(ip+1)])) + "\n" +
					" " + (ip+2) + " : " + ((dictionary[(ip+2)]==null) ? "RET" : ((dictionary[(ip+2)]=="") ? "EXIT" : dictionary[(ip+2)])) + "\n" +
					" " + (ip+3) + " : " + ((dictionary[(ip+3)]==null) ? "RET" : ((dictionary[(ip+3)]=="") ? "EXIT" : dictionary[(ip+3)])) + "\n"
				);
				// show data stack
				type(' rstack['+rstack+']  stack['+stack+']\n');
				type(kvm.jsc.prompt ); 
				jump2endofinputbox.click();
				vm.jsc.cmd = // static variable so as to reuse last command
					prompt("JavaScript console", vm.jsc.cmd?vm.jsc.cmd:""); // Press Enter repeat last command
				vm.jsc.cmd = vm.jsc.cmd==null ? 'quit' : vm.jsc.cmd; // Press Esc equals to 'quit'
				vm.type(" > " + vm.jsc.cmd + "\n");
				switch(vm.jsc.cmd){
					case "exit" : case "q" : case "quit": execute("bd"); return;
					case "s"  : vm.g.breakPoint=-1; return;
					case "p"  : vm.g.breakPoint=(isNaN(dictionary[ip+1]))?ip+1:dictionary[ip+1]; return;
					case "r"  : vm.g.breakPoint=rstack[rstack.length-1]; return;
					case "rr" : vm.g.breakPoint=rstack[rstack.length-2]; return;
					case "bye"  : execute("bye"); break;
					case "help" : if(!confirm(vm.jsc.help)) return; break;
					case "erase" : for(var _i_=0; _i_<eraseCount; _i_++){execute('{backSpace}');pop();} break;
					default : try { // 自己處理 JScript errors 以免動不動就被甩出去
						var _result_ = eval(vm.jsc.cmd);
						vm.type(_result_);
						vm.type(" (" + mytypeof(_result_) + ")\n");
					} catch(err) {
						vm.type("Oooops! " + err.message + "\n")
					}
				}
			}
		})()
	</text>
	js: vm.jsc.xt=pop()

: cr         	( -- ) \ 到下一列繼續輸出 *** 20111224 sam
				js: type("\n") 1 nap js: jump2endofinputbox.click();inputbox.focus() ;

\ ------------------ Get args from URL -------------------------------------------------------
	js> location.href constant url // ( -- 'url' ) jeforth.3htm url entire command line 
	url :> split("?")[1] value args // ( -- 'args' ) jeforth.3htm args
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
