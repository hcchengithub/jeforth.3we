
\ ------------------ jsc JavaScript console debugger  --------------------------------------------
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
	  for jeforth.[3nw|3htm|3hta]

	t : Toggle displaying the status.
	s : Single step. (bp=-1)
	p : Run until next IP. (bp=ip+1)
	r : Free run until ret. (bp=rtos)
	rr: Free run until ret. (bp=next rtos)
	erase : Erase debug message at bottom.
	bye : Terminate the program.
	help : you are reading me.
	g, q, exit, quit, or <Esc> : Stop debugging.

	Put this line,

	> if(vm.debug){vm.jsc.prompt="msg";eval(vm.jsc.xt)}

	into anywhere among JavaScript source code to drop a breakpoint. "msg" shows you which breakpoint it is.

</text> <js> vm.jsc={}; vm.jsc.help=pop().replace(/^[\t ]*/gm,""); </js> \ remove leading Tab's and spaces
<text>

	// vm.jsc.help    
	// vm.jsc.xt	   jsc source code called by eval(vm.jsc.xt)
	// vm.jsc.enable   enable the break-point caught by inner()
	// vm.jsc.prompt
	// vm.jsc.cmd      static jsc command line for repeating the same command
	
	(function(){
		var eraseCount=16;
		inputbox.value = ""; // for erase command
		vm.jsc.enable = false; // 避免 jsc 自己用的 colon word 也 hit 到 break-point。
		for(;;) {
			if (!vm.jsc.statusToggle) {
				type(
					"\n -------- F o l l o w i n g   I n s t r u c t i o n s --------\n" +
					" " + (ip  ) + " : " + ((dictionary[(ip  )]==null) ? "RET" : ((dictionary[(ip  )]=="") ? "EXIT" : dictionary[(ip  )])) + "\n" +
					" " + (ip+1) + " : " + ((dictionary[(ip+1)]==null) ? "RET" : ((dictionary[(ip+1)]=="") ? "EXIT" : dictionary[(ip+1)])) + "\n" +
					" " + (ip+2) + " : " + ((dictionary[(ip+2)]==null) ? "RET" : ((dictionary[(ip+2)]=="") ? "EXIT" : dictionary[(ip+2)])) + "\n" +
					" " + (ip+3) + " : " + ((dictionary[(ip+3)]==null) ? "RET" : ((dictionary[(ip+3)]=="") ? "EXIT" : dictionary[(ip+3)])) + "\n" +
					" -------- F o r t h   S t a c k s --------\n" +
					' rstack['+rstack+']:' + rstack.length + '  stack['+stack+']:' + stack.length + '\n'
					);
			}
			type(vm.jsc.prompt ); 
			jump2endofinputbox.click();
			vm.jsc.cmd = // static variable so as to reuse last command
				prompt("JavaScript console", vm.jsc.cmd||""); // Press Enter repeat last command
			vm.jsc.cmd = vm.jsc.cmd==null ? 'quit' : vm.jsc.cmd; // Press Esc equals to 'quit'
			vm.type("\n > " + vm.jsc.cmd + "\n");
			switch(vm.jsc.cmd){
				case "t" : 
					vm.jsc.statusToggle=Boolean(vm.jsc.statusToggle^true); 
					break;
				case "exit" : case "q" : case "quit": 
					execute("bd"); 
					return;
				case "s"  : 
					vm.g.breakPoint=-1; 
					vm.jsc.enable = true; 
					return;
				case "p"  : 
					vm.g.breakPoint=(isNaN(dictionary[ip+1]))?ip+1:dictionary[ip+1]; 
					vm.jsc.enable = true; 
					return;
				case "r"  : 
					vm.g.breakPoint=rstack[rstack.length-1]; 
					vm.jsc.enable = true;
					return;
				case "rr" : 
					vm.g.breakPoint=rstack[rstack.length-2]; 
					vm.jsc.enable = true;
					return;
				case "bye"  : execute("bye"); break;
				case "help" : 
					alert(vm.jsc.help); 
					break;
				case "erase" : 
					for(var _i_=0; _i_<eraseCount; _i_++){
						execute('{backSpace}'); pop();
					} 
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
	// project-k kernel jeforth.js is the one called in code ... end-code. That 
	// panic() is actually calling vm.panic(). We redefine vm.panic() because jsc 
	// is ready now while F12 debugger can be called from jsc still.

	vm.panic = function(state){ 
		vm.type(state.msg);
		if (state.serious) eval(vm.jsc.xt); // was debugger;
	}
</js>

