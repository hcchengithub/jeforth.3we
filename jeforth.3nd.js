
// 
// jeofrth.3nd.js											hcchen5600 2014/10/14 08:49:06 
// Use the same kernel with jeforth.3hta.
// Usage: node.exe jeofrth.3nd.js cr .' Hello World!!' cr bye
//

global.kvm = require('./kernel/jeforth.js').kvm;
kvm.host = global;
kvm.appname = "jeforth.3nd";
kvm.path = ["dummy", "kernel", "f", "3nd/f", "3nd", "3nd/eforth.com", "playground"];
var print = kvm.print = function (s) { 
			try {
				var ss = s + ''; // Print-able test to avoid error 'JavaScript error on word "." : invalid data'
			} catch(err) {
				var ss = Object.prototype.toString.apply(s);
			}
			kvm.screenbuffer += ss;
			process.stdout.write(ss);
		}; 
kvm.version = "1.00";
kvm.greeting = function(){
			print("j e f o r t h . 3 n d -- r"+kvm.version+'\n');
			print("Node.js "+process.version+'\n');
			print("Source code http://github.com/hcchengithub/jeforth.3we\n");
			print("Executing " + process.execPath + '\n');
			print("argv " + process.argv + '\n');
			return(parseFloat(kvm.version));
		}; 
kvm.greeting();
kvm.fso = require('fs');
kvm.readTextFile = function(pathname){return(kvm.fso.readFileSync(pathname,'utf-8'))}
kvm.writeTextFile = function(pathname,data){kvm.fso.writeFileSync(pathname,data,'utf8')}
kvm.bye = function(n){process.exit(n)}
kvm.gets = function(){
			// http://stackoverflow.com/questions/3430939/node-js-readsync-from-stdin
			// A blocking function that returns string from STDIN (keyboard or clipboard) synchronously.
			// End by pressing Ctrl-Z when kvm.gets.editMode==True, or normally by <Enter>.
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
				if (bytesRead === 0) break; else {
					var cc = chunk.toString(null, 0, bytesRead);
					print(cc);
					ss += cc;
					if ((cc=='\n'||cc=='\r')&&!arguments.callee.editMode) break;
				}
			}
			return (ss);
		}
kvm.gets.editMode = false;
kvm.debug = false;
kvm.screenbuffer = "";
kvm.prompt = "OK";
kvm.argv = process.argv; 
kvm.exec = kvm.argv.shift(); // remove node.exe to compatible with jeforth.hta
kvm.base = 10;
kvm.jsc = {prompt:""};
kvm.jsc.help = kvm.fso.readFileSync('./3nd/f/jsc.hlp','utf-8');
kvm.jsc.xt = kvm.fso.readFileSync('./3nd/f/jsc.js','utf-8');
kvm.clearScreen = function(){console.log('\033c')} // '\033c' or '\033[2J' http://stackoverflow.com/questions/9006988/node-js-on-windows-how-to-clear-console

// kvm.beep
// kvm.inputbox
// kvm.EditMode
// kvm.forthConsoleHandler
// kvm.scrollToElement
// kvm.plain
// kvm.cmdhistory
// kvm.process
// kvm.BinaryStream
// kvm.BinaryFile
// kvm.objWMIService
// kvm.cv
 
kvm.stdio = require('readline').createInterface({input: process.stdin,output: process.stdout});
kvm.stdio.on('line', function (cmd){kvm.fortheval(cmd);kvm.print(' '+kvm.prompt+' ')});
kvm.stdio.setPrompt(' '+kvm.prompt+' ',4);
kvm.init();
kvm.fortheval(kvm.fso.readFileSync('kernel/jeforth.f','utf-8')+kvm.fso.readFileSync('3nd/f/quit.f','utf-8'));
// fortheval() 之後不能再有任何東西，否則因為有 sleep/suspend/resume 之故，會被意外執行到。

