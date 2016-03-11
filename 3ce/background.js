
	// jeforrth.3ce background page main script program

	var isBackgroundPage = "Yes, I am in the background.js.";
	var jeforth_project_k_virtual_machine_object = new jeForth(); // A permanent name.
	var bvm = jeforth_project_k_virtual_machine_object; // (B)ackground page VM, a shorter name that identifies itself also.
	(function(vm){
		vm.minor_version = 1; // minor version specified by each application (like here), major version is from jeforth.js kernel.
		var version = parseFloat(vm.major_version+"."+vm.minor_version);
		vm.appname = "jeforth.3ce.background"; //  不要動， jeforth.3we kernel 用來分辨不同 application。
		vm.host = window; // DOM window is the root for 3HTM. global 掛那裡的根據。
		vm.path = ["dummy", "doc", "f", "3htm/f", "3htm/canvas", "3htm", "3ce", "playground"];
		vm.screenbuffer = ""; // type() to screenbuffer before I/O ready; self-test needs it too.
		vm.selftest_visible = true; // Dummy, background page does not have a display.
		
		// vm.type() is the master typing or printing function.
		// The type() called in code ... end-code is defined in the kernel jeforth.js.
		// type to vm.screenbuffer, although background page has no display.
		vm.type = function (s) { 
			try {
				var ss = s + ''; // Print-able test
			} catch(err) {
				ss = Object.prototype.toString.apply(s);
			}
			if(vm.screenbuffer!=null) 
				vm.screenbuffer += ss; // 填 null 就可以關掉。
		}
		
		// vm.panic() is the master panic handler. The panic() function defined in 
		// project-k kernel jeforth.js is the one called in code ... end-code.
		vm.panic = function(state){ 
			vm.type(state.msg);
			if (state.serious) debugger;
		}
		
		// Even in 3ce background page we still need the panic() function below 
		// but we can't see the one in jeforth.js so one is defined here for convenience.
		function panic(msg,level) {
			var state = {
					msg:msg, level:level
				};
			if(vm.panic) vm.panic(state);
		}
		
		vm.clearScreen = function () {
			vm.screenbuffer = "";
		}
		vm.greeting = function(){
			vm.type("j e f o r t h . 3 c e . b a c k g r o u n d -- v"+version+'\n');
			vm.type("source code http://github.com/hcchengithub/jeforth.3we\n");
			vm.type("Program path " + window.location.toString());
			return(version);
		}
		vm.debug = false;
 		vm.prompt = "OK";
		vm.bye = function(){window.close()};
		
		// System initialization
		jQuery(document).ready(
			// jQuery convention, learned from W3School, make sure web page is ready.
			function() {
				var k = "f/jeforth.f";
				var r = "3htm/f/readtextfile.f";
				var q = "3ce/background.f";
				var kk = $.get(k,'text'); 
				var rr = $.get(r,'text');
				var qq = $.get(q,'text');
				// $.get() callback only when success, so it's not suitable.
				// this is my workaround:
				(function retry(){
					if(kk.state()=="pending"||rr.state()=="pending"||qq.state()=="pending")
						setTimeout(retry,100); 
					else {
						if (kk.status!=200) panic("Error! Failed to read " + k + '\n');
						else if (rr.status!=200) panic("Error! Failed to read " + r + '\n');
						else if (qq.status!=200) panic("Error! Failed to read " + q + '\n');
						else vm.dictate(kk.responseText+rr.responseText+qq.responseText);
					}
				})();
			}                       
		);                          
		
		// Called from jsEvalRaw, it will handle the try{}catch{} thing. 
		vm.writeTextFile = function(pathname,data) { // Write string to text file.
			panic("Error writing " + pathname + ", jeforth.3htm doesn't know how to wrtieTextFile yet.\n"); 
		}

		vm.readTextFile = function(pathname){
			panic("Error reading " + pathname + ", jeforth.3htm doesn't know how to readTextFile."+
					  " Please use $.get(pathname,callback,'text') instead.\n");
		}
	})(bvm);

