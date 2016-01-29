
\ jeforth.3ce for Google Chrome extension 
\ chrome.* APIs http://chrome-apps-doc2.appspot.com/trunk/extensions/api_index.html

s" ce.f" source-code-header

\
\ Skip everything if is not running in Chrome extension.
\
js> typeof(chrome)!='undefined'&&typeof(chrome.runtime)!='undefined' [if] \ Chrome extension environment.

	js> chrome.extension.getBackgroundPage() value background-page // ( -- window ) Get the background page's window object.

	: open-3ce-tab ( -- ) \ Open a jeforth.3ce tab.
		js> window.open("index.html") background-page :: lastTab=pop() ;
		
	: tabs.getCurrent ( -- objTab ) \ Get the current tab object.
		js: chrome.tabs.getCurrent(function(tab){push(tab);execute('stopSleeping')}) 
		1000 sleep ;
		/// Used in an extension page or content script in target pages. 
		/// Returns 'undefined' if used in the popup page or background page.

	tabs.getCurrent [if] [else]
		\
		\ In Chrome extension/app is sure.
		\ Initial Chrome extension popup page appearance. The font size better be smaller.
		\
		js:	$("#body")[0].style.width="660px"; 
		js:	$("#header")[0].style.fontSize="0.6em"; 
		js:	$("#outputbox")[0].style.fontSize="0.8em";
	[then]

	: tabs.query ( {title:"*anual*"} -- array ) \ Get an array of tabs that match the given hash.
		<js> chrome.tabs.query(pop(),function(tabs){
			push(tabs);
			execute('stopSleeping')
		})</js> 10000 sleep ;
		/// The input is a hash table, like :
		/// {} tabs.query -- get all tabs.
		/// js: push({active:true}) tabs.query -- get active tabs of every window.
		/// js: push({title:"*anual*"}) tabs.query -- title pattern supports wildcard character '*'.
		/// js: push({url:"http://*ibm*/*"}) tabs.query -- url pattern supports wildcard too.
		/// <scheme>://<host><path> see http://chrome-apps-doc2.appspot.com/trunk/extensions/match_patterns.html
		/// Should return an array, 'undefined' indicates invalid pattern.
		
	: list-tabs ( -- ) \ List Tabs in the current window
		{} tabs.query ( array ) dup :> length ( array length )
		?dup if for ( array )
		r@ 1- js> tos(1) :> [pop()] ( array tab )
		dup :> id . space ( array tab )
		:> title . cr ( array )
		next drop then ;
		/// {} tabs.query (see) to see them in details.

	: tabid ( -- tabid ) \ The working tab's id.
		background-page :> workingTabId ;
	 
	: tabid! ( tabid -- ) \ Set working tab id.
		background-page :: workingTabId=pop() ;
	: tabs.get ( tabid -- tabObj ) \ Get the specified tab object.
		<js> chrome.tabs.get(pop(),function(tab){
			push(tab);
			execute('stopSleeping')
		})</js> 10000 sleep ;

	: tabs.select ( -- ) \ Set ce.f's working tabid. 
		begin 
			<js> alert("Select the working Chrome tab in 3 seconds, ready?")</js>
			3000 nap
			js: push({active:true}) tabs.query ( array )
			dup :> length 1 > ?abort" You have multiple Chrome windows, one only please."
			:> [0].id tabid! 
			s" It's '" tabid tabs.get :> title + s" ' right?" +
			js> confirm(pop()) 
		until ;
		
	: get-manifest ( -- obj ) \ Get the Chrome extension/app manifest hash table.
		js> chrome.runtime.getManifest() ;
		
	: see-manifest ( -- ) \ See the Chrome extension/app manifest hash table.
		get-manifest js> JSON.stringify(pop(),"\n","\t") . ;
		
	: inject ( pathname -- result ) \ Inject a JavaScript file to tabid
		tabid <js> chrome.tabs.executeScript(pop(), {file:pop()}, 
		function(result){push(result);execute('stopSleeping')}) </js> 
		120000 sleep ;
		/// Have content script to include project-k:
		/// > char project-k/jeforth.js indect drop 
		/// The CallBack returns an array which is "The result of the script in every injected frame."
		/// A result is the value of the last statement of the script file.
		/// In case of project-k it returns an array: ["uses strict"].
		/// In case of 3ce/background.js it returns an array: [null].

	: <ce> ( <js statements> -- "block" ) \ Get JavaScript statements
		char </ce>|</ceV> word ; immediate

	code (/ce) ( "statements" -- ) \ No return value
		execute('tabid');
		chrome.tabs.executeScript(pop(),{"code": pop()}); 
		end-code

	: </ce> ( "statements" -- ) \ Execute 3ce statements on target tabid. No return value.
		compiling if literal compile (/ce) else (/ce) then ; immediate

	: (/ceV) ( "statements" -- ) \ Retrun the value of last statement
		tabid <js> chrome.tabs.executeScript(pop(),{"code": pop()},
		function(result){push(result);execute('stopSleeping')}) </js> 
		50000 sleep ;

	: </ceV> ( "statements" -- ) \ Execute 3ce statements on target tabid. Retrun the value of last statement
		compiling if literal compile (/ceV) else (/ceV) then ; immediate

	\
	\ Host side setup to receiving messages (forth commands) from content scripts
	\ Extension page <==> Content Script or Target page 之間雙向的 message 都是 forth command string.
	\
		{}		value sender // ( -- obj ) Refer to obj.url or obj.tab.title for who sent the message.
		null	value sendResponse // ( -- function ) Use sendResponse({response}) to reply the sender.
		<js>
			var f = function(message, _sender, _sendResponse) {
				vm.g.sender = _sender;
				vm.g.sendResponse = _sendResponse;
				if (message.isCommand) dictate(message.text);
				else type(message.text);
				window.scrollTo(0,endofinputbox.offsetTop);inputbox.focus();
			};f
		</jsV> value messageHandler // ( -- function ) Host side Chrome extension handler that receives messages from content scripts.
		js: chrome.runtime.onMessage.addListener(vm.g.messageHandler)
		
	: {F7} ( -- ) \ Send inputbox to content script of tabid.
		tabid <js>
			vm.cmdhistory.push(inputbox.value);
			push(inputbox.value);
			inputbox.value="";
			chrome.tabs.sendMessage(pop(1),pop())
		</js> false ( terminiate event bubbling ) ;
		/// 若用 F8 則無效, 猜測是 Chrome debugger 自己要用。


	: (dictate) ( "forth source code" -- ) \ Run a block of forth source code on tabid.
		tabid <js>
			chrome.tabs.sendMessage(pop(),pop())
		</js> false ( terminiate event bubbling ) ;
		/// Usage: <text> ... </text> (dictate)
		
	: (install) ( "pathname" -- ) \ Install forth source code to tabid.
		readTextFileAuto char shooo! swap + (dictate) ;
		/// shooo! avoid echoing the entire source code.
	
	: install ( <pathname> -- )  \ Install forth source code to tabid.
		char \n|\r word (install) ;

	: attach	( -- ) \ Attach 3ce to the first tab.
		js: push({"index":0}) tabs.query :> [0].id tabid!
		\ tabs.select \ tabid is the target tab.
		\ Install jQuery and project-k to target tab.
			<ce> typeof(jeForth)</ceV> char function != if 
				char js/jquery-1.11.2.js inject drop			
				char project-k/jeforth.js inject drop 
			then
		\ Install the main program of jeforrth.3ce
			<ce> typeof(jeforth_project_k_virtual_machine_object)</ceV> char object != if 
				<ce>
					var jeforth_project_k_virtual_machine_object = new jeForth(); // A permanent name.
					var kvm = jeforth_project_k_virtual_machine_object; // "kvm" may not be so permanent.
					// kvm is now the jeforth virtual machine object. It has no idea about the outside world
					// that can be variant applications: HTML, HTA, Node.js, Node-webkit, .. etc.
					// We need to help it a little as the following example:
					
					(function(){
						kvm.minor_version = 1; // minor version specified by each application (like here), major version is from jeforth.js kernel.
						var version = parseFloat(kvm.major_version+"."+kvm.minor_version);
						kvm.appname = "jeforth.3ce"; //  不要動， jeforth.3we kernel 用來分辨不同 application。
						kvm.host = window; // DOM window is the root for 3HTM. global 掛那裡的根據。
						kvm.screenbuffer = ""; // type() to screenbuffer before I/O ready; self-test needs it too.
						kvm.selftest_visible = true; // type() refers to it.
			
						var cmd, sender, sendResponse;
						chrome.runtime.onMessage.addListener(
							function(message, _sender, _sendResponse) {
								cmd = message;
								sender = _sender;
								sendResponse = _sendResponse;
								forthConsoleHandler(cmd);
							}
						)
						
						// I/O  
						// Forth vm doesn't know how to 'type'. We need teach it by defining the kvm.type().
						// kvm.type() is the only mandatory I/O jeforth VM needs to know. 
						var type = kvm.type = function (s) {
							try {
								var ss = s + ''; // Print-able test
							} catch(err) {
								ss = Object.prototype.toString.apply(s);
							}
							if(kvm.screenbuffer!=null) kvm.screenbuffer += ss; // 填 null 就可以關掉。
							if(kvm.selftest_visible) chrome.runtime.sendMessage({text:s});
						};
						
						// kvm.panic() is the master panic handler. The panic() function defined in 
						// project-k kernel jeforth.js is the one called in code ... end-code.
						kvm.panic = function(state){ 
							type(state.msg);
							if (state.serious) debugger;
						}
						// We need the panic() function below but we can't see the one in jeforth.js
						// so one is defined here for convenience.
						function panic(msg,level) {
							var state = {
									msg:msg, level:level
								};
							if(kvm.panic) kvm.panic(state);
						}
						
						// The Forth traditional prompt 'OK' is defined and used in this application main program.
						// Forth vm has no idea about kvm.prompt but your program may want to know.
						// In that case, as an example, use kvm property to store the vm global variables and functions.
						kvm.prompt = "OK";
			
						function forthConsoleHandler(cmd) {
							// Avoid responding the ~.f source code when installing.
							if(cmd.indexOf("shooo!")!=0)
								type((cmd?'\n' + document.title + '> ':"")+cmd+'\n');
							else
								cmd = cmd.slice(6); // remove "shooo!"
							kvm.dictate(cmd);  // Pass the command line to jeForth VM
							type(" " + kvm.prompt + " ");
						}
			
						// Take care of HTML special characters
						var plain = kvm.plain = function (s) {
							var ss = s + ""; // avoid numbers to fail at s.replace()
							ss = ss.replace(/\t/g,' &nbsp; &nbsp;');
							ss = ss.replace(/ /g,'&nbsp;');
							ss = ss.replace(/</g,'&lt;');
							ss = ss.replace(/>/g,'&gt;');
							ss = ss.replace(/\n/g,'<br>');
							return ss;
						}
			
						kvm.greeting = function(){
							type("j e f o r t h . 3 c e -- v"+version+'\n');
							type("source code http://github.com/hcchengithub/jeforth.3we\n");
							return(version);
						}
						
						kvm.bye = function(){window.close()};
						
						// Called from jsEvalRaw, it will handle the try{}catch{} thing. 
						kvm.writeTextFile = function(pathname,data) { // Write string to text file.
							panic("Error writing " + pathname + ", jeforth.3htm doesn't know how to wrtieTextFile yet.\n"); 
						}
			
						kvm.readTextFile = function(pathname){
							panic("Error reading " + pathname + ", jeforth.3htm doesn't know how to readTextFile."+
									  " Please use $.get(pathname,callback,'text') instead.\n");
						}
					})();
				</ce>
				\ quit.f equivalent 
				char f/jeforth.f (install)
				<text>
				js> tick('<selftest>').enabled=true;tick('<selftest>').buffer tib.insert
				js: tick('<selftest>').buffer="" \ recycle the memory
				</text> (dictate)
				char f/voc.f (install)
				char 3htm/f/html5.f (install)
				<text>
					char body <e> 
						<div id=console3ce class=ce3>
						<style>
							.ce3 {
								color:black;
								word-wrap:break-word;
								border: 1px ridge;
								background:#F0F0F0;
								padding:20px;
							}
							.ce3 div {
								font: 20px "courier new";
							}
							.ce3 textarea {
								width:100%;
								font: 20px "courier new";
								padding:4px;
								border: 0px solid;
								background:#BBBBBB;
							}
						</style>
						<div id=outputbox>this is the outputbox</div>
						<textarea id=inputbox>I am the inputbox id is inputbox</textarea>
						</div>
					</e> drop				
				</text> (dictate)
				char 3htm/f/element.f (install)
				<text> .( jeforth.3ce is ready on the target tab. ) </text> (dictate)
			then 
		;

[then] \ Not Chrome extension environment.

				
	
	