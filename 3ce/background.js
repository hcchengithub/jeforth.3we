var isBackgroundPage = true;
//	var jeforth_project_k_virtual_machine_object = new jeForth(); // A permanent name.
//	var kvm = jeforth_project_k_virtual_machine_object; // "kvm" may not be so permanent.
//	var request, sender, response;
//    chrome.runtime.onMessage.addListener(
//        function(_request, _sender, _response) {
//			// alert("The background page received a message: " + request);
//			// alert("I think jeForth is " + jeForth)
//            // console.log(request);
//            // console.log(sender);
//            // sendResponse({aa:11,bb:22});
//			request = _request;
//			sender = _sender;
//			response = _response;
//			kvm.dictate(request);
//        }
//    )
//
//	(function(){
//		kvm.minor_version = 1; // minor version specified by each application (like here), major version is from jeforth.js kernel.
//		var version = parseFloat(kvm.major_version+"."+kvm.minor_version);
//		kvm.appname = "jeforth.3ce"; //  不要動， jeforth.3we kernel 用來分辨不同 application。
//		kvm.host = window; // DOM window is the root for 3HTM. global 掛那裡的根據。
//		kvm.path = ["dummy", "3ce", "doc", "f", "3htm/f", "3htm/canvas", "3htm", "playground"];
//		kvm.selftest_visible = true; // type() refers to it.
//		
//		// kvm.type() is the master typing or printing function.
//		// The type() called in code ... end-code is defined in the kernel jeforth.js.
//		// We need to use type() below, and we can't see the jeforth.js' type() so one 
//		// is also defined here, even just for a few convenience. The two type() functions 
//		// are both calling the same kvm.type().
//		var type = kvm.type = function (s) { 
//			try {
//				var ss = s + ''; // Print-able test
//			} catch(err) {
//				ss = Object.prototype.toString.apply(s);
//			}
//			if(kvm.selftest_visible) response(kvm.plain(ss)); 
//		}
//		
//		// kvm.panic() is the master panic handler. The panic() function defined in 
//		// project-k kernel jeforth.js is the one called in code ... end-code.
//		kvm.panic = function(state){ 
//			type(state.msg);
//			if (state.serious) debugger;
//		}
//		// We need the panic() function below but we can't see the one in jeforth.js
//		// so one is defined here for convenience.
//		function panic(msg,level) {
//			var state = {
//					msg:msg, level:level
//				};
//			if(kvm.panic) kvm.panic(state);
//		}
//		kvm.greeting = function(){
//			type("j e f o r t h . 3 c e -- v"+version+'\n');
//			type("source code http://github.com/hcchengithub/jeforth.3we\n");
//			type("Program path " + window.location.toString());
//			return(version);
//		}
//		kvm.debug = false;
//		kvm.inputbox = "";
// 		kvm.prompt = "OK";
//		kvm.bye = function(){window.close()}; // [ ] what happen if close background page? 
//		
//		// System initialization
//		jQuery(document).ready(
//			// jQuery convention, learned from W3School, make sure web page is ready.
//			function() {
//				var k = "f/jeforth.f";
//				var r = "3htm/f/readtextfile.f";
//				var q = "3htm/f/quit.f";
//				var kk = $.get(k,'text'); // callback only when success, not suitable, 
//				var rr = $.get(r,'text');
//				var qq = $.get(q,'text');
//				(function retry(){
//					if(kk.state()=="pending"||rr.state()=="pending"||qq.state()=="pending")
//						setTimeout(retry,100); 
//					else {
//						if (kk.status!=200) panic("Error! Failed to read " + k + '\n');
//						else if (rr.status!=200) panic("Error! Failed to read " + r + '\n');
//						else if (qq.status!=200) panic("Error! Failed to read " + q + '\n');
//						else kvm.dictate(kk.responseText+rr.responseText+qq.responseText);
//					}
//				})();
//			}                       
//		);                          
//		
//		// Useful common tool
//		kvm.plain = function (s) {
//			var ss = s + ""; // avoid numbers to fail at s.replace()
//			ss = ss.replace(/&/g,'&amp;')
//				   .replace(/\t/g,' &nbsp; &nbsp;')
//				   .replace(/ /g,'&nbsp;')
//				   .replace(/</g,'&lt;')
//				   .replace(/>/g,'&gt;')
//				   .replace(/\r?\n\r?/g,'<br>');
//			return ss;
//		}
//		
//		// Called from jsEvalRaw, it will handle the try{}catch{} thing. 
//		kvm.writeTextFile = function(pathname,data) { // Write string to text file.
//			panic("Error writing " + pathname + ", jeforth.3htm doesn't know how to wrtieTextFile yet.\n"); 
//		}
//
//		kvm.readTextFile = function(pathname){
//			panic("Error reading " + pathname + ", jeforth.3htm doesn't know how to readTextFile."+
//					  " Please use $.get(pathname,callback,'text') instead.\n");
//		}
//	})();
	