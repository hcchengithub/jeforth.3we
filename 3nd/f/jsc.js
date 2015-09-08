// JavaScript Console for jeforth.3nd
// hcchen5600 2014/10/15 17:15:16 
// hcchen5600 2015/09/07 16:19:30 porting to use project-k kernel
(function(){
	// kvm.jsc.xt is a string, the point that executes eval(kvm.jsc.xt) decides what it can see.
	var _continue_ = true;
	while(_continue_){
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
		var _line_ = kvm.gets();
		kvm.jsc.cmd =  // static variable so as to reuse last command
			(_line_=="\r") ? kvm.jsc.cmd||"" : _line_; // Press Enter repeat last command
		switch(kvm.jsc.cmd.trim()) {
			case "exit" : case "q" : case "quit": _continue_ = false; execute("bd"); return;
			case "s"  : kvm.g.breakPoint=-1; return;
			case "p"  : kvm.g.breakPoint=(isNaN(dictionary[ip+1]))?ip+1:dictionary[ip+1]; return;
			case "r"  : kvm.g.breakPoint=rstack[rstack.length-1]; return;
			case "rr" : kvm.g.breakPoint=rstack[rstack.length-2]; return;
			case "bye"  : execute("bye"); break;
			case "help" : type(kvm.jsc.help); break;
			default:
				try {
					var _result_ = eval(kvm.jsc.cmd);
					console.log(_result_); // as-is, it shows objects very well
					type(" (" + mytypeof(_result_) + ")");  
				} catch(err) {
					type("Oooops! " + err.message + "\n");
				}
		}
	}
})()
