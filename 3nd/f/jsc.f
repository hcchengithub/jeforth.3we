
\ ------------------ jsc JavaScript console debugger for jeforth.3nd --------------------------------
\
\ jeforth.f is common for all applications. jsc is application dependent.
\ jeforth.f words bp, be, bd and vm.g.debugInner() refer to jsc before its birth.
\ That's ok because they are all break-point things that are interpret-only meaning
\ they are either never used in free run mode or only used after the system is ready.

\
\ Usage:
\   Put this line,
\     if(vm.debug){vm.jsc.prompt="msg";eval(vm.jsc.xt)}
\   among JavaScript code as a break point. The "msg" shows you which break point is triggered.
\
\	Example:
\	In below example, jsc can access variables aa, bb, and input.
\
\	<js>
\		function test (input) {
\			var aa = 11;
\			var bb = 22;
\	        if(1){vm.jsc.prompt="bp1>>>";eval(vm.jsc.xt)}
\		}
\		test(33);
\	</js>
\

<text>

	J a v a S c r i p t   c o n s o l e
	        for jeforth.3nd

	t : Toggle displaying the status.
	s : Single step. (bp=-1)
	p : Run until next IP. (bp=ip+1)
	r : Free run until ret. (bp=rtos)
	rr: Free run until ret. (bp=next rtos)
	bye : Terminate the program.
	help : you are reading me.
	g, q, exit, quit, or <Esc> : Stop debugging.

	Put this line,
	
		> if(vm.debug){vm.jsc.prompt="msg";eval(vm.jsc.xt)}
	
	into anywhere among JavaScript source code to drop a breakpoint. 
	"msg" indicates which breakpoint it is.

</text> js: vm.jsc={};vm.jsc.help=pop()
<text>

	// Variable        Description
	// -------------   ---------------------------------------------------------
	// vm.jsc.help    
	// vm.jsc.xt	   jsc source code called by eval(vm.jsc.xt)
	// vm.jsc.enable   Enable the break-point caught by inner()
	// vm.jsc.prompt
	// vm.jsc.cmd      static jsc command line for repeating the same command
	// -------------   ---------------------------------------------------------
	
	(function(){
		vm.jsc.enable = false; // 避免 jsc 自己用的 colon word 也 hit 到 break-point。
		for(;;) {
			if (!vm.jsc.statusToggle) {
				type(
					"\n -------- Following Instructions --------\n" +
					" " + (ip  ) + " : " + ((dictionary[(ip  )]==null) ? "RET" : ((dictionary[(ip  )]=="") ? "EXIT" : dictionary[(ip  )])) + "\n" +
					" " + (ip+1) + " : " + ((dictionary[(ip+1)]==null) ? "RET" : ((dictionary[(ip+1)]=="") ? "EXIT" : dictionary[(ip+1)])) + "\n" +
					" " + (ip+2) + " : " + ((dictionary[(ip+2)]==null) ? "RET" : ((dictionary[(ip+2)]=="") ? "EXIT" : dictionary[(ip+2)])) + "\n" +
					" " + (ip+3) + " : " + ((dictionary[(ip+3)]==null) ? "RET" : ((dictionary[(ip+3)]=="") ? "EXIT" : dictionary[(ip+3)])) + "\n" +
					" -------------- Forth Stacks ------------\n" +
					' rstack['+rstack+']:' + rstack.length + '  stack['+stack+']:' + stack.length + '\n'
					);
			}
			type(vm.jsc.prompt ); 
			var _line_ = kvm.gets();
			kvm.jsc.cmd =  // static variable so as to reuse last command
				(_line_=="\r") ? kvm.jsc.cmd||"" : _line_; // Press Enter repeat last command
			switch(vm.jsc.cmd.trim()){
				case "t" : 
					vm.jsc.statusToggle=Boolean(vm.jsc.statusToggle^true); 
					break;
				case "exit" : case "q" : case "quit": 
					execute("bd"); 
					return;
				case "s"  : 
					vm.jsc.bp=-1; 
					vm.jsc.enable = true; 
					return;
				case "p"  : 
					vm.jsc.bp=(isNaN(dictionary[ip+1]))?ip+1:dictionary[ip+1]; 
					vm.jsc.enable = true; 
					return;
				case "r"  : 
					vm.jsc.bp=rstack[rstack.length-1]; 
					vm.jsc.enable = true;
					return;
				case "rr" : 
					vm.jsc.bp=rstack[rstack.length-2]; 
					vm.jsc.enable = true;
					return;
				case "bye"  : execute("bye"); break;
				case "help" : 
					type(vm.jsc.help); 
					break;
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
</text> js: vm.jsc.xt=pop()
	
: jsc			( -- ) \ JavaScript console usage: js: vm.jsc.prompt="111>>>";eval(vm.jsc.xt)
				cr ." J a v a S c r i p t   C o n s o l e" cr
				." Usage: js: if(vm.debug){vm.jsc.prompt='msg';eval(vm.jsc.xt)}" cr
				<js> vm.jsc.prompt=" jsc>"; eval(vm.jsc.xt); </js> ;

<js>
	// vm.panic() is the master panic handler. The panic() function defined in 
	// project-k kernel projectk.js is the one called in code ... end-code. That 
	// panic() is actually calling vm.panic(). We redefine vm.panic() because jsc 
	// is ready now while F12 debugger can be called from jsc still.

	vm.panic = function(state){ 
		vm.type(state.msg);
		if (state.serious) {
			vm.jsc.prompt="Panic jsc>";
			eval(vm.jsc.xt); // was debugger;
		}
	}
</js>

