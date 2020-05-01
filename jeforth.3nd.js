
// 
// jeofrth.3nd.js											hcchen5600 2014/10/14 08:49:06 
// Use the same kernel with jeforth.3hta.
// Usage: node.exe jeofrth.3nd.js cr .' Hello World!!' cr bye
//

var jeForth = require('./project-k/projectk.js').jeForth;
global.kvm = global.jeforth_project_k_virtual_machine_object = new jeForth()
kvm.minor_version = require("./js/version.js").jeforth3we_minor_version;
kvm.host = global;  // global 掛那裡的根據。
kvm.appname = "jeforth.3nd";
kvm.path = ["dummy", "f", "3nd/f", "3nd", "3nd/eforth.com", "demo", "playground"];
kvm.screenbuffer = ""; // used by both inside and outside vm.
kvm.selftest_visible = true; // used by both inside and outside vm.
global.lang = 'forth'; // 'js' or 'forth' let console support two languages

// kvm.type() is the master typing or printing function.
// The type() called in code ... end-code is defined in the kernel projectk.js.
// We need to use type() below, and we can't see the projectk.js' type() so one 
// is also defined here, even just for a few convenience. The two type() functions 
// are both calling the same kvm.type().
var type = kvm.type = function (s) { 
			try {
				var ss = s + ''; // Print-able test to avoid error 'JavaScript error on word "." : invalid data'
			} catch(err) {
				var ss = Object.prototype.toString.apply(s);
			}
			if(kvm.screenbuffer!=null) kvm.screenbuffer += ss; // 填 null 就可以關掉。
			if (kvm.selftest_visible) process.stdout.write(ss);
		}; 

// application specific
kvm.clearScreen = 
		function(){console.log('\033c')} 
		// '\033c' or '\033[2J' http://stackoverflow.com/questions/9006988/node-js-on-windows-how-to-clear-console
		
// kvm.panic() is the master panic handler. The panic() function defined in 
// project-k kernel projectk.js is the one called in code ... end-code.
kvm.panic = function (state) { 
			type(state.msg);
			if (state.serious) debugger;
		}
// We need the panic() function below but we can't see the one in projectk.js
// so one is defined here for convenience.
function panic(msg,level) {
	var state = {
			msg:msg, level:level
		};
	if(kvm.panic) kvm.panic(state);
}

// must be defined by each application
kvm.greeting = function(){
			var version = parseFloat(kvm.major_version+"."+kvm.minor_version);
			type("j e f o r t h . 3 n d -- r"+version+'\n');
			type("Node.js "+process.version+'\n');
			type("Source code http://github.com/hcchengithub/jeforth.3we\n");
			type("Executing " + process.execPath + '\n');
			type("argv " + process.argv + '\n');
			return(version);
		}; 
kvm.greeting(); // print greeting message.
kvm.fso = require('fs'); // Node.js specific
kvm.readTextFile = function(pathname){return(kvm.fso.readFileSync(pathname,'utf-8'))} // application dependent
kvm.writeTextFile = function(pathname,data){kvm.fso.writeFileSync(pathname,data,'utf8')} // application dependent
kvm.bye = function(n){process.exit(n)} // application dependent
kvm.gets = function(){ // Node.js specific
			// http://stackoverflow.com/questions/3430939/node-js-readsync-from-stdin
			// A blocking function that returns string from STDIN (keyboard or clipboard) synchronously.
			// End by pressing Ctrl-Z when kvm.gets.editMode==True, or normally by <Enter>.
			var CHUNKSIZE=256;
			var chunk = new Buffer(CHUNKSIZE);
			var bytesRead; // 收到的 byte 數，敲鍵盤回 1 包括 cr 亦然，Ctrl-z 回 0，copy-past 得實際長度。
			var ss = "";
			for(;;) { // Loop as long as stdin input is available. Ctrl-Z to terminate
				bytesRead = 0; // this loop repeats on every key
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
					type(cc);
					if (cc=='\b') ss=ss.slice(0,-1);
					else ss += cc;
					if ((cc=='\n'||cc=='\r')&&!arguments.callee.editMode) break;
				}
			}
			return (ss);
		}
kvm.gets.editMode = false;
kvm.debug = false; // needed to be turned on/off outside vm
kvm.prompt = "OK"; // application specific
kvm.argv = process.argv; // application specific
kvm.argv.shift(); // remove node.exe to compatible with jeforth.hta

// This JavaScript Debug Console was importent when developing jeforth.f, now replaced by jsc.f
// kvm.jsc = {};
// kvm.jsc.help = kvm.fso.readFileSync('./3nd/f/jsc.hlp','utf-8');
// kvm.jsc.xt = kvm.fso.readFileSync('./3nd/f/jsc.js','utf-8');

// There's no main loop, event driven call back function is this.
// 2020/05/01 17:57:32 為 support lang='js' 改寫
kvm.consoleHandler = function(cmd) {
    if (global.lang == 'js' || global.lang != 'forth'){
        type((cmd?'\n> ':"")+cmd+'\n');
        result = eval(cmd);
        type(result + "\n");
    }else{
        var rlwas = kvm.rstack().length; // r)stack l)ength was
        // type((cmd?'\n> ':"")+cmd+'\n');
        kvm.dictate(cmd);  // Pass the command line to KsanaVM
        (function retry(){
            // rstack 平衡表示這次 command line 都完成了，這才打 'OK'。
            // event handler 從 idle 上手，又回到 idle 不會讓別人看到它的 rstack。
            // 雖然未 OK, 仍然可以 key in 新的 command line 且立即執行。
            if(kvm.rstack().length!=rlwas)
                setTimeout(retry,100); 
            else {
                type(" " + kvm.prompt + " ");
            }
        })();
    }
}
 
kvm.stdio = require('readline').createInterface({input: process.stdin,output: process.stdout});
kvm.stdio.on('line', kvm.consoleHandler);
kvm.stdio.setPrompt(' '+kvm.prompt+' ',4);
kvm.dictate(kvm.fso.readFileSync('f/jeforth.f','utf-8')+kvm.fso.readFileSync('3nd/f/quit.f','utf-8'));
// dictate() 之後不能再有任何東西，否則因為有 sleep/suspend/resume 之故，會被意外執行到。

