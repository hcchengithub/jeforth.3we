
\ jeforth.3ce for Google Chrome extension 
\ chrome.* APIs http://chrome-apps-doc2.appspot.com/trunk/extensions/api_index.html

s" ce.f" source-code-header

\
\ Skip everything if is not running in Chrome extension.
\
js> typeof(chrome)!='undefined'&&typeof(chrome.runtime)!='undefined' [if]


	js> chrome.extension.getBackgroundPage() value background-page // ( -- window ) Get the background page's window object.

	: new-3ce-tab ( -- ) \ Open a new jeforth.3ce tab.
		js> window.open("index.html") background-page :: lastTab=pop() ;
		
	: tabs.getCurrent ( -- objTab ) \ Get the current tab object.
		js: chrome.tabs.getCurrent(function(tab){push(tab);execute('stopSleeping')}) 
		1000 sleep ;
		/// Returns an 'undefined' if used in the popup page or background page.
		/// Normally used in an extension page. Yet can be used in content script 
		/// too if it has jeforth.3ce injected.

	tabs.getCurrent [if] [else]
		\
		\ ------------ initial Chrome extension popup page appearance --------------------------------
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
		/// tabs.query (see) to see them.
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
		50000 sleep ;
		/// Have content script to include project-k:
		/// > char project-k/jeforth.js indect drop 
		/// The CallBack returns an array which is "The result of the script in every injected frame."
		/// A result is the value of the last statement of the script file.
		/// In case of project-k it returns an array: ["uses strict"].
		/// In case of 3ce/background.js it returns an array: [null].

	: <ce> ( <js statements> -- "block" ) \ Get JavaScript statements
		char </ce>|</ceV> word ; immediate

	code </ce> ( "statements" -- ) \ No return value
		execute('tabid');
		chrome.tabs.executeScript(pop(),{"code": pop()}); 
		end-code immediate

	: </ceV> ( "statements" -- ) \ Retrun the value of last statement
		tabid <js> chrome.tabs.executeScript(pop(),{"code": pop()},
		function(result){push(result);execute('stopSleeping')}) </js> 
		50000 sleep ; immediate

	\ Receive messages from content scripts
		{}		value sender // ( -- obj ) Refer to obj.url or obj.tab.title for who sent the message.
		null	value sendResponse // ( -- function ) Use sendResponse({response}) to reply the sender.
		<js>
			var f = function(_request, _sender, _sendResponse) {
				type(_request);
				vm.g.sender = _sender;
				vm.g.sendResponse = _sendResponse;
			};f
		</jsV> value ce_messageHandler // ( -- function ) Chrome extension handler who receives messages from content scripts.
		js: chrome.runtime.onMessage.addListener(vm.g.ce_messageHandler)

	<comment>

	: attach	( -- ) \ Attach 3ce to a tab.
		tabs.select \ tabid is the target tab.
		<ce> typeof(jeforth_project_k_virtual_machine_object)</ceV> char object != if
			\ Install project-k to target tab.
			<ce>
				var jeforth_project_k_virtual_machine_object = new jeForth(); // A permanent name.
				var kvm = jeforth_project_k_virtual_machine_object; // "kvm" may not be so permanent.

				// kvm is now the jeforth virtual machine object. It has no idea about the outside world
				// that can be variant applications: HTML, HTA, Node.js, Node-webkit, .. etc.
				// We need to help it a little as the following example:
				
				(function(){

					var cmd, sender, sendResponse;
					chrome.runtime.onMessage.addListener(
						function(_request, _sender, _sendResponse) {
							cmd = _request;
							sender = _sender;
							sendResponse = _sendResponse;
							forthConsoleHandler(cmd);
						}
					)
					
					// I/O  
					// Forth vm doesn't know how to 'type'. We need teach it by defining the kvm.type().
					// kvm.type() is the only mandatory I/O jeforth VM needs to know. 
					var type = kvm.type = function (s) {
						chrome.runtime.sendMessage("", s) 		
					};
					
					// The Forth traditional prompt 'OK' is defined and used in this application main program.
					// Forth vm has no idea about kvm.prompt but your program may want to know.
					// In that case, as an example, use kvm property to store the vm global variables and functions.
					kvm.prompt = "OK";

					function forthConsoleHandler(cmd) {
						type((cmd?'\n' + document.title + '> ':"")+cmd+'\n');
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
				})();
			</ce>
			
		then ;
		
		\ Then send the command through messag,
		: {F8} ( -- ) \ Send inputbox to content script of tabid.
			tabid js: chrome.tabs.sendMessage(pop(),inputbox.value) ;

		
		\ So, try to send baby examples over...
		<js> chrome.tabs.sendMessage(287,"code . kvm.type(pop()) end-code 123 . ") </js>
		
	</comment>
		
[then]


				
	
	