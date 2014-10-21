// hcchen5600 2014/10/15 17:15:16 
// JavaScript Console for jeforth.3nd
(function(){
	var _continue_ = true;
	while(_continue_){
		print('\n' + kvm.jsc.prompt+" ");
		var _line_ = kvm.gets().replace(/(^\s*)|(\s*$)/g,''); // remove 頭尾 white spaces
		switch(_line_) {
			case "bye"  : execute("bye"); break;
			case "help" : print(kvm.jsc.help); break;
			case "exit" : case "q" : case "quit": 
				_continue_ = false; 
				break;
			default:
				try {
					var _result_ = eval(_line_);
					console.log(_result_); // as-is, it shows objects very well
					print(" (" + mytypeof(_result_) + ")");  
				} catch(err) {
					var _ss_ = "Oooops! " + err.message + "\n";
					print(_ss_);
				}
		}
	}
})()
