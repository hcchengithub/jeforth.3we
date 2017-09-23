
	// jeforth for Chrome Extension, jeforth.3ce 
	
	// jeforth.3ce.html is the index.html home page of popup page and extension pages, 
	// jeforth.3ce.js   is the Javascript portion of the jeforth.3ce.html home page.
	// jeforth.3ce.background.html is the index.html of the background page
	// 3ce target page's ~.html and ~.js are all covered by target.f 

	var jeforth_project_k_virtual_machine_object = new jeForth(); // A permanent name.
	var kvm = jeforth_project_k_virtual_machine_object; // "kvm" may not be so permanent.
	(function(){
		kvm.minor_version = jeforth3we_minor_version;
		var version = parseFloat(kvm.major_version+"."+kvm.minor_version);
		kvm.appname = "jeforth.3ce"; //  不要動， jeforth.3we kernel 用來分辨不同 application。
		kvm.host = window; // DOM window is the root for global 掛那裡的根據。
		kvm.path = ["dummy", "doc", "f", "3htm/f", "3htm/canvas", "3htm", "3ce", "demo", "playground"];
		kvm.screenbuffer = ""; // type() to screenbuffer before I/O ready; self-test needs it too.
		kvm.selftest_visible = true; // type() refers to it.
		
		// kvm.type() is the master typing or printing function.
		// The type() called in code ... end-code is defined in the kernel projectk.js.
		// We need to use type() below, and we can't see the projectk.js' type() so one 
		// is also defined here, even just for a few convenience. The two type() functions 
		// are both calling the same kvm.type().
		var type = kvm.type = function (s) { 
			try {
				var ss = s + ''; // Print-able test
			} catch(err) {
				ss = Object.prototype.toString.apply(s);
			}
			if(kvm.screenbuffer!=null) kvm.screenbuffer += ss; // 填 null 就可以關掉。
			if(kvm.selftest_visible) $('#outputbox').append(kvm.plain(ss)); 
		}
		
		// kvm.panic() is the master panic handler. The panic() function defined in 
		// project-k kernel projectk.js is the one called in code ... end-code.
		kvm.panic = function(state){ 
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
		
		kvm.clearScreen = function () {
			kvm.screenbuffer = "";
			$('#outputbox').empty();
		}
		kvm.greeting = function(){
			type("j e f o r t h . 3 h t m -- v"+version+'\n');
			type("source code http://github.com/hcchengithub/jeforth.3we\n");
			type("Program path " + window.location.toString());
			return(version);
		}
		kvm.debug = false;
 		kvm.prompt = "OK";
		kvm.bye = function(){window.close()};
		
		// System initialization
		jQuery(document).ready(
			// jQuery convention, learned from W3School, make sure web page is ready.
			function() {
				$('#rev').html(version); // also .commandLine, .applicationName, ...
				$('#location').html(window.location.toString()); // it's built-in in DOM
				$('.appname').html(kvm.appname); // 一次填好所有 appname
				document.onkeydown = hotKeyHandler; // Must be using onkeydown so as to grab the control.
				var k = "f/jeforth.f";
				var r = "3htm/f/readtextfile.f";
				var q = "3ce/quit.f";
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
						else kvm.dictate(kk.responseText+rr.responseText+qq.responseText);
					}
				})();
			}                       
		);                          
                                    
		// There's no main loop, event driven call back function is this.
		kvm.scroll2inputbox = function(){window.scrollTo(0,endofinputbox.offsetTop)}
		kvm.forthConsoleHandler = function(cmd) {
			var rlwas = kvm.rstack().length; // r)stack l)ength was
            type((cmd?'\n> ':"")+cmd+'\n');
			kvm.dictate(cmd);  // Pass the command line to KsanaVM
			(function retry(){
				// rstack 平衡表示這次 command line 都完成了，這才打 'OK'。
				// event handler 從 idle 上手，又回到 idle 不會讓別人看到它的 rstack。
				// 雖然未 OK, 仍然可以 key in 新的 command line 且立即執行。
				if(kvm.rstack().length!=rlwas)
					setTimeout(retry,100); 
				else {
					type(" " + kvm.prompt + " ");
					if ($(inputbox).is(":focus")) kvm.scroll2inputbox();
				}
			})();
		}

		// onkeydown,onkeypress,onkeyup
		// event.shiftKey event.ctrlKey event.altKey event.metaKey
		// KeyCode test page http://www.asquare.net/javascript/tests/KeyCode.html
		function hotKeyHandler(e) {
			// document.onkeydown() initial version defined in jeforth.3thm.js
			// will be reDef by platform.f
			e = (e) ? e : event; var keyCode = (e.keyCode) ? e.keyCode : (e.which) ? e.which : false;
			switch(keyCode) {
				case 13: /* Enter */
					var cmd = inputbox.value; // w/o the '\n' character ($10). 
					inputbox.value = ""; // 少了這行，如果壓下 Enter 不放，就會變成重複執行。
					kvm.forthConsoleHandler(cmd);
					return(false); 
			}
			return (true); // pass down to following handlers 
		}
		
		// Useful common tool
		kvm.plain = function (s) {
			var ss = s + ""; // avoid numbers to fail at s.replace()
			ss = ss.replace(/&/g,'&amp;')
				   .replace(/\t/g,' &nbsp; &nbsp;')
				   .replace(/ /g,'&nbsp;')
				   .replace(/</g,'&lt;')
				   .replace(/>/g,'&gt;')
				   .replace(/\r?\n\r?/g,'<br>');
			return ss;
		}
		
		// Called from jsEvalRaw, it will handle the try{}catch{} thing. 
		kvm.writeTextFile = function(pathname,data) { // Write string to text file.
			panic("Error writing " + pathname + ", jeforth.3ce doesn't know how to wrtieTextFile yet.\n"); 
		}

		kvm.readTextFile = function(pathname){
			panic("Error reading " + pathname + ", jeforth.3ce doesn't know how to readTextFile."+
					  " Please use $.get(pathname,callback,'text') instead.\n");
		}
	})();
