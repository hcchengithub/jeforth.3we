
	\
	\ Child_process module is how Node.js do the shell jobs
	\ child_process obj>keys . ==> fork,_forkChild,exec,execFile,spawn OK
	\ 

	js> require("child_process") constant child_process // ( -- obj ) Node.js built-in module
	child_process :> exec constant exec // ( -- function ) Node.js child_process method 

	<selftest>
		**** Demo the usage of child_process.exec(), Note! it's actually the cmd.exe shell interpreter.
		exec :: ('dir',function(e,o,i){print(o+'\ndone!done!')})
	</selftest>

	<comment>
	print("hello\n");
	var exec = require("child_process").exec;
	exec('notepad.exe',function(e,o,i){console.log('done')}) <== 若進 jsc 實驗將看不到 'done' 因為 callback 在等 jsc 結束讓出控制權。
	exec('dir',function(e,o,i){console.log('done')})

	var content = "empty";
	exec('cmd.exe', function (error, stdout, stdin){
		push(stdout);
		push(error);
	});
	</comment>
