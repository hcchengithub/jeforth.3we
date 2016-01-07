// hcchen5600 2014/12/17 10:40:06 
// JavaScript Console for jeforth.3wsh
(function(){
	var _continue_ = true;
	while(_continue_){
		print('\n' + kvm.jsc.prompt+" ");
		var _line_ = kvm.stdin.ReadLine().replace(/(^\s*)|(\s*$)/g,''); // remove 頭尾 white spaces
		switch(_line_) {
			case "bye"  : execute("bye"); break;
			case "help" : print(kvm.jsc.help); break;
			case "exit" : case "q" : case "quit": 
				_continue_ = false; 
				break;
			default:
				try {
					var _result_ = eval(_line_);
					print(_result_); // as-is, it shows objects very well
					print(" (" + mytypeof(_result_) + ")");  
				} catch(err) {
					var _ss_ = "Oooops! " + err.message + "\n";
					print(_ss_);
				}
		}
	}
})()
