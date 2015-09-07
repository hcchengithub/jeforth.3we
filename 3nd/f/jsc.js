// JavaScript Console for jeforth.3nd
// hcchen5600 2014/10/15 17:15:16 
// hcchen5600 2015/09/07 16:19:30 porting to use project-k kernel
// kvm.jsc.xt 整個是個 string, 執行時間、地點決定 vm 或 kvm 看不看得見。以下都用 kvm 應用較廣。
// 我想,只要能看見 kvm 的地方就可以用 jsc 來 debug。因為 kvm 是 global 所以 jsc 應開可以用來 debug jQuery !

(function(){
	var _continue_ = true;
	while(_continue_){
		type('\n ------------- jsc ---------------\n');
		// show ip which is next step
		type(
			" ip " + ip + " : " + 
			((dictionary[ip]==null) ? "RET" : ((dictionary[ip]=="") ? "EXIT" : dictionary[ip])) + "\n" 
			+ kvm.jsc.prompt 
		);
		// show data stack
		type('\n stack ['+stack+']\n');
		var _line_ = kvm.gets();
		kvm.jsc.cmd = (_line_=="\r") ? kvm.jsc.cmd||"" : _line_; // Press Enter repeat last command
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
