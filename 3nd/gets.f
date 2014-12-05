1 [if]
	// http://stackoverflow.com/questions/3430939/node-js-readsync-from-stdin
	." Start testing ............... Ctrl-Z to stop it." cr
	<comment>
	function gets() {
		// http://stackoverflow.com/questions/3430939/node-js-readsync-from-stdin
		// A blocking function that returns string from STDIN (keyboard or clipboard) synchronously.
		// End by pressing Ctrl-Z
		var CHUNKSIZE=256;
		var chunk = new Buffer(CHUNKSIZE);
		var bytesRead;
		var ss = "";
		for(;;) { // Loop as long as stdin input is available. Ctrl-Z to terminate
			bytesRead = 0;
			try {
				bytesRead = kvm.fso.readSync(process.stdin.fd, chunk, 0, CHUNKSIZE);
			} catch (e) {
				if (e.code === 'EAGAIN') {
					panic('ERROR: gets() interactive stdin input not supported.\n');
				} else if (e.code === 'EOF') {
					break;          
				}
				throw e; // unexpected exception
			}
			if (bytesRead === 0) break;
			var cc = chunk.toString(null, 0, bytesRead);
			print(cc);
			ss += cc;
		}
		return (ss);
	}
	gets()
	</comment> 
	<text>
		(function(){
			var _continue_ = true;
			while(_continue_){
				print('\n' + kvm.jsc.prompt + " jsc> ");
				var _line_ = kvm.gets().replace(/(^\s*)|(\s*$)/g,''); // remove 頭尾 white spaces
				switch(_line_) {
					case "bye"  : execute("bye"); break;
					case "help" : print(kvm.jsc.help); break;
					case "exit" : case "q" : case "quit": 
						_continue_ = false; 
						print(kvm.prompt = " OK "); 
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
	</text> js: kvm.jsc.xt=pop()
	js: kvm.jsc.prompt='messsage';eval(kvm.jsc.xt)
	." End test" cr
[then]	

0 [if] 
	// http://stackoverflow.com/questions/3430939/node-js-readsync-from-stdin
	." Start testing ............... Ctrl-Z to stop it." cr
	<js>
	var fs = require('fs');
	var BUFSIZE=256;
	var buf = new Buffer(BUFSIZE);
	var bytesRead;

	while (true) { // Loop as long as stdin input is available.
		bytesRead = 0;
		try {
			bytesRead = fs.readSync(process.stdin.fd, buf, 0, BUFSIZE);
		} catch (e) {
			if (e.code === 'EAGAIN') { // 'resource temporarily unavailable'
				// Happens on OS X 10.8.3 (not Windows 7!), if there's no
				// stdin input - typically when invoking a script without any
				// input (for interactive stdin input).
				// If you were to just continue, you'd create a tight loop.
				console.error('ERROR: interactive stdin input not supported.');
				process.exit(1);
			} else if (e.code === 'EOF') {
				// Happens on Windows 7, but not OS X 10.8.3:
				// simply signals the end of *piped* stdin input.
				break;          
			}
			throw e; // unexpected exception
		}
		if (bytesRead === 0) {
			// No more stdin input available.
			// OS X 10.8.3: regardless of input method, this is how the end 
			//   of input is signaled.
			// Windows 7: this is how the end of input is signaled for
			//   *interactive* stdin input.
			break;
		}
	  // Process the chunk read.
	  console.log('Bytes read: %s; content:\n%s', bytesRead, buf.toString(null, 0, bytesRead));
	}
	</js>
	." End test" cr
[then]	

0 [if]
	<js>
	(function jsc(){
		kvm.prompt=""; 
		kvm.stdio.pause();
		kvm.stdio.question(kvm.jsc.prompt+" jsc> ", function(line) {
			kvm.stdio.resume();
			switch(line.trim()) {
				case "bye"  : execute("bye"); break;
				case "help" : console.log(kvm.jsc.help); jsc(); break;
				case "exit" : case "q" : case "quit": print(kvm.prompt = " OK "); break;
				default:
					try {
						var result = eval(line);
						// kvm.print() uses process.stdout.write() which does not print 
						// to screen now. I don't know why? Use console.log() is ok anyway.
						console.log(result + " (" + mytypeof(result) + ")");  
					} catch(err) {
						var _ss_ = "Oooops! " + err.message + "\n";
						// kvm.stdio has resumed now so we can use print()
						print(_ss_);
					}
					jsc();
			}
		});
	})()
	</js>
[then]
0 [if]
	code byebye kvm.bye() end-code
	code hi print("test.f works fine if you can see me.\n'byebye' or press Ctrl-C to exit\n") end-code
	hi
[then]
0 [if]
	<js>
	var repl = require("repl");
	repl.start({
	  prompt: "jsc>",
	  input: process.stdin,
	  output: process.stdout
	});
	print(" if you can see me, the above activity is not blocking.\n");

	</js> 
[then]
0 [if]
	<js>
	var readline = require('readline'),
		rl = readline.createInterface(process.stdin, process.stdout);

	rl.setPrompt('OHAI> ');
	rl.prompt();

	rl.on('close', function() { // Press Ctrl-D or rl.close() called
	  console.log('Have a great day!');
	  kvm.stdio.on('line', function (cmd){kvm.fortheval(cmd);kvm.print(kvm.prompt)});
	});
	rl.on('line', function(line) {
	  switch(line.trim()) {
		case 'hello':
		  console.log('world!');
		  break;
		case 'exit':
		  rl.close();  // safely exit this session
		  break;
		default:
		  console.log('Say what? I might have heard `' + line.trim() + '`');
		  break;
	  }
	  rl.prompt();
	});
	</js>
[then]