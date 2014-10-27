// hcchen5600 2014/10/22 23:30:03 
// JavaScript Console for jeforth.3nw
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
