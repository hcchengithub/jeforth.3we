
\ jeforth.3ce Google Chrome extension 
\ For 3ce popup page and extension pages.
\ chrome.* APIs http://chrome-apps-doc2.appspot.com/trunk/extensions/api_index.html

\
\ Skip everything if is not running in Chrome extension.
\ 早期讓 3htm, 3ce 共用 index.html home page was a mistake. 分開之後這種情況不會有了。
\ 所以這段防呆只是 nice to have 其實不需要了。
\
js> typeof(chrome)!='undefined'&&typeof(chrome.extension)!='undefined' 
[if] \ Chrome extension environment.

	s" ce.f" source-code-header

    \ Chrome extension environment. May be the popup page, 
	\ the background page, or 3ce extension pages.

	\ Get the background page which is the common part of the 3ce isolated world.
	js> chrome.extension.getBackgroundPage() value background-page // ( -- window ) Get the background page's window object.

	<js>
	//	Host side onMessage event hander that receives messages from 
	//  content scripts on target pages. See 3ce SPEC of sendMessage() defined in log.json.
	chrome.runtime.onMessage.addListener(
		function ce3_host_onmessage (message, sender, sendResponse) { 
			kvm.push(message);kvm.push(sender);kvm.push(sendResponse);
			kvm.execute("host-message-handler");
		}
	)
	</js> 
		
	: host-message-handler ( message sender sendResponse -- ) \ Handle messages from target page
		2drop \ sender and sendResponse are not used so far
		<js>
			var message = pop();
			if (message.addr && message.addr!=vm.g.myTabId) return;
			if (message.type) {
				vm.type(message.type);
				vm.scroll2inputbox();inputbox.focus(); // Host side
			} 
			if (message.tos) { // Receving data from target page
				push(message.tos);
			} 
			if (message.forth) { // For fun or for tests, execute commands from target page
				vm.dictate(message.forth);
			}
		</js> ;
		/// 
		
	: open-web-page ( url activeFlag -- tab ) \ Open web page and return Chrome Extension tab object before complete loading
		<js> chrome.tabs.create(
			{url:pop(1),active:pop()},
			function(tab){push(tab);execute('stopSleeping');}  
		) </js> ( tab ) 
		1000000 sleep ; \ 實際經常回來得很快
		/// The input activeFlag specifies whether the page is to be activated
		
	: open-3ce-tab ( -- ) \ Open a jeforth.3ce tab.
		char jeforth.3ce.html true open-web-page ( tab )
		background-page :: lastTab=pop() ;
		/// 之前用 js> window.open("jeforth.3ce.html") 是可以取得新 3ce page
		/// 的 window object 也許有某種用途，記一下。如今在 lastTab 留下的是
		/// Chrome extension 的 tab object。要控制該 tab 可經由 tabid 下達
		/// 手動的 {F7} 或 (dictate) command-line。
		
	: tabs.getCurrent ( -- objTab ) \ Get the current Chrome extension tab object.
		js: chrome.tabs.getCurrent(function(tab){push(tab);execute('stopSleeping')}) 
		1000 sleep ;
		/// Used in an extension page or content script in target pages. 
		/// Returns 'undefined' if used in the popup page or background page.



	: isPopup? ( -- boolean ) \ Is this page the 3ce popup page?
		\ In Chrome extension/app is sure or this word won't be included at all.
		tabs.getCurrent boolean if 
			\ A 3ce extension page or a target page.
			false
		else
			\ it's either the popup page or the background page.
			\ background page does not have this word so it's the popup page.
			true
		then ;
	
	char popup value myTabId // ( -- tabid ) 3ce extension page's Tab ID.
							 \ assume it's the popup page at first.

	isPopup? [if]
		\
		\ Initial Chrome extension popup page appearance. The font size better be smaller.
		\
		js:	$("#body")[0].style.width="660px"; \ "100%" 不如 "660px" 大
		js:	$("#header")[0].style.fontSize="0.6em"; 
		js:	$("#outputbox")[0].style.fontSize="0.8em";
	[else]
		tabs.getCurrent :> id to myTabId
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
		
	: list-tabs ( -- ) \ List all tabs in all window
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
		/// Sometimes we can't use "the active tab" as the working tab 
		/// because it is the 3ce page. BTW, to get the active tab:
		/// js: push({active:true}) tabs.query js> tos().length \ ==> 1 (number)
		
	: get-manifest ( -- obj ) \ Get the Chrome extension/app manifest hash table.
		js> chrome.runtime.getManifest() ;
		
	: see-manifest ( -- ) \ See the Chrome extension/app manifest hash table.
		get-manifest js> JSON.stringify(pop(),"\n","\t") . ;
		
	: inject ( tabid {(file|code):source} -- [array] ) \ Inject a JavaScript source code or file to the tab.
		<js> chrome.tabs.executeScript(pop(1), pop(), 
		function(result){push(result);execute('stopSleeping')}) </js> 
		120000 sleep ;
		/// This word is the base of <ce> (Chrome Extension) commends.
		/// The result is an array which is "The result of the script in every injected frame."
		/// A result is the value of the last statement of the script file.
		
	: <ce> ( <js statements> -- "block" ) \ Get JavaScript statements to run on tabid target page 
		char </ce>|</ceV> word ; immediate
		/// chrome.tabs.executeScript() 不能用在 3ce 自己的 Extension pages。
		/// 必須是【別人的】web page。

	: (/ceV) ( "statements" -- [last statement] ) \ Retrun the value of last statement from each iframe and the target page
		{} js: tos().code=pop(1) tabid swap inject ;
		/// chrome.tabs.executeScript() 不能用在 3ce 自己的 Extension pages。
		
	: (/ce) ( "statements" -- ) \ Get JavaScript statements to run on tabid target page, no return value.
		(/ceV) drop ;
		/// chrome.tabs.executeScript() 不能用在 3ce 自己的 Extension pages。

	: </ce> ( "statements" -- ) \ Execute 3ce statements on target tabid. No return value.
		compiling if literal compile (/ce) else (/ce) then ; immediate


	: </ceV> ( "statements" -- ) \ Execute 3ce statements on target tabid. Retrun the value of last statement
		compiling if literal compile (/ceV) else (/ceV) then ; immediate

	code message->tabid ( anything -- ) \ Send a message of anything to tabid
		execute("tabid"); chrome.tabs.sendMessage(pop(),pop()) end-code
		/// Usage: anything message->tabid
		
	: (dictate) ( "forth source code" -- ) \ Run a block of forth source code on tabid.
		js: push({forth:pop()}) message->tabid ;
		/// Usage: <text> ... </text> (dictate)
		
	code {F7} ( -- ) \ Send inputbox to content script of tabid.
		// 當命令來自 host page 就盡可能把 display 切向 host page
		dictate('<ce> if(vm.tick("host.type")) vm.type = vm.g["host.type"];</ce>');
		vm.cmdhistory.push(inputbox.value);  // Share the same command history with the host
		push(inputbox.value); // command line 
		inputbox.value=""; // clear the inputbox
		execute("(dictate)"); // Let target page to execute the command line(s)
		push(false); // terminiate event bubbling
		end-code
		/// 若用 F8 則無效, 猜測是 Chrome debugger 自己要用。
		
	: (install) ( "pathname" -- ) \ Install forth source code to tabid.
		readTextFileAuto char shooo! swap + (dictate) ;
		/// shooo! avoid echoing the entire source code.
	
	: install ( <pathname> -- )  \ Install forth source code to tabid.
		char \n|\r word (install) ;

	: first-tab ( -- objTab ) \ Get first tab (the leftest) of Chrome browser.
		js: push({"index":0}) tabs.query :> [0] ;
		/// Uncertain which 'leftest tab' if there're multiple Chrome windows.
		
	: active-tab  ( -- objTab ) \ Get the active tab of Chrome browser.
		js: push({active:true}) tabs.query :> [0] ;
		/// Used by 3ce popup page.

	: attach ( tabid -- ) \ Attach 3ce to the specified target tab.
		\ Activate the target tab
		depth if ( Tab ID ) else
			isPopup? if active-tab :> id else tabid then ( Tab ID )
		then ( Tab ID ) tabid! 
		tabid js: chrome.tabs.update(pop(),{active:true})
		\ Wait for the target page to be loaded
		  500 nap active-tab :> status!="complete" if  
			." Still loading " active-tab :> title . space
			0 begin
				active-tab :> status=="complete" if 1+ then
				dup 5 > if else \ 5 complete to make sure it's very ready.
					js: vm.scroll2inputbox();inputbox.focus();
					char . . 300 nap false
				then 
			until
		  then 
		\ Inject jQuery and project-k to target tab.
		<ce> typeof(jeForth)</ceV> char function != if 	
			tabid {} js: tos().file="js/jquery-1.11.2.js" inject drop			
		then
		tabid {} js: tos().file="project-k/jeforth.js" inject drop 
		
		\ Inject the main program of jeforrth.3ce (jeforth.3htm.js equivalent)
		<ce>
			var jeforth_project_k_virtual_machine_object = new jeForth(); // A permanent name.
			var vm = jeforth_project_k_virtual_machine_object; // "vm" may not be so permanent.
			// vm is now the jeforth virtual machine object. It has no idea about the outside world
			// that can be variant applications: HTML, HTA, Node.js, Node-webkit, .. etc.
			// We need to help it a little as the following example:
			
			(function(){
				vm.minor_version = 202; // 3ce target page minor version. major version is from jeforth.js kernel.
				var version = vm.version = parseFloat(vm.major_version+"."+vm.minor_version);
				vm.appname = "jeforth.3ce"; //  不要動， jeforth.3we kernel 用來分辨不同 application。
				vm.host = window; // DOM window is the root for 3HTM. global 掛那裡的根據。
				vm.path = ["dummy", "doc", "f", "3htm/f", "3htm/canvas", "3htm", "3ce/system", "3ce/f", "3ce", "playground"];
				vm.screenbuffer = ""; // type() to screenbuffer before I/O ready; self-test needs it too.
				vm.selftest_visible = true; // type() refers to it.
				vm.debug = false;

				// Message (or F7 forth command line) from the host page needs an 
				// event handler on this target page
				function target_f7_handler (message, sender, sendResponse) { 
					// 不用管 addr: field, 本來就只有指定的 target page 才會收到這個 message。
					// 先收 data
					if (message.tos!=undefined) { // Can be "" when readTextFile failed
						vm.push(message.tos);
					} 
					// 再執行命令
					if (message.forth) {
						vm.forthConsoleHandler(message.forth);
					}
				}
				// Avoid multiple registration of the same handler.
				if (!chrome.runtime.onMessage.hasListeners()) 
					chrome.runtime.onMessage.addListener(target_f7_handler);
				
				// I/O  
				// Forth vm doesn't know how to 'type'. We need teach it by defining the vm.type().
				// vm.type() is the only mandatory I/O jeforth VM needs to know. 
				vm.type = function (s) {
					try {
						var ss = s + ''; // Print-able test
					} catch(err) {
						ss = Object.prototype.toString.apply(s);
					}
					if(vm.screenbuffer!=null) vm.screenbuffer += ss; // 填 null 就可以關掉。
					if(vm.selftest_visible) chrome.runtime.sendMessage({type:s});
				};
				
				// vm.panic() is the master panic handler. The panic() function defined in 
				// project-k kernel jeforth.js is the one called in code ... end-code.
				vm.panic = function(state){ 
					vm.type(state.msg);
					if (state.serious) debugger;
				}
				// We need the panic() function below but we can't see the one in jeforth.js
				// so one is defined here for convenience.
				function panic(msg,level) {
					var state = {
							msg:msg, level:level
						};
					if(vm.panic) vm.panic(state);
				}
				
				vm.clearScreen = function () {
					vm.screenbuffer = "";
					$('#outputbox').empty();
				}
				
				// The Forth traditional prompt 'OK' is defined and used in this application main program.
				// Forth vm has no idea about vm.prompt but your program may want to know.
				// In that case, as an example, use vm property to store the vm global variables and functions.
				vm.prompt = "OK";
	
				vm.forthConsoleHandler = function(cmd) {
					var rlwas = vm.rstack().length; // r)stack l)ength was
					// Avoid responding the ~.f source code when installing.
					if(cmd.indexOf("shooo!")!=0)
						vm.type((cmd?'\n> ':"")+cmd+'\n');
					else
						cmd = cmd.slice(6); // remove "shooo!"
					vm.dictate(cmd);  // Pass the command line to jeForth VM
					(function retry(){
						// rstack 平衡表示這次 command line 都完成了，這才打 'OK'。
						// event handler 從 idle 上手，又回到 idle 不會讓別人看到它的 rstack。
						// 雖然未 OK, 仍然可以 key in 新的 command line 且立即執行。
						if(vm.rstack().length!=rlwas)
							setTimeout(retry,100); 
						else {
							vm.type(" " + vm.prompt + " ");
							if (typeof(endofinputbox)!="undefined"){
								if ($(inputbox).is(":focus"))
									vm.scroll2inputbox();
							}
						}
					})();
				}
				
				// Take care of HTML special characters
				var plain = vm.plain = function (s) {
					var ss = s + ""; // avoid numbers to fail at s.replace()
					ss = ss.replace(/\t/g,' &nbsp; &nbsp;');
					ss = ss.replace(/ /g,'&nbsp;');
					ss = ss.replace(/</g,'&lt;');
					ss = ss.replace(/>/g,'&gt;');
					ss = ss.replace(/\n/g,'<br>');
					return ss;
				}
	
				vm.greeting = function(){
					vm.type("j e f o r t h . 3 c e -- v"+version+'\n');
					vm.type("source code http://github.com/hcchengithub/jeforth.3we\n");
					return(version);
				}
				
				vm.bye = function(){window.close()};
				
				// Called from jsEvalRaw, it will handle the try{}catch{} thing. 
				vm.writeTextFile = function(pathname,data) { // Write string to text file.
					panic("Error writing " + pathname + ", jeforth.3ce doesn't know how to wrtieTextFile yet.\n"); 
				}
	
				vm.readTextFile = function(pathname){
					panic("jeforth.3ce does not have vm.readTextFile(), please use readTextFile directly.\n");
				}
			})();
		</ceV>  drop \ Use /ceV for synchronous
		char f/jeforth.f (install)
		s" js: vm.g.myTabId=" tabid + (dictate) \ equivalent to "tabs.getCurrent :> id" on target page

		<text> shooo!
			: readTextFile ( "pathname" -- "text" ) \ Read text file from jeforth.3ce host page.
				\ 這個 word 很曲折，先由 target page 下令請 background page 讀檔，同時
				\ 還交代 background page 在讀好該檔之後打一個 message 回來, 該 message 
				\ 使 target page stopSleeping 並且把讀好的 text file 塞進 target page 
				\ 的 TOS, 因此它一旦 resume 回來 TOS 就是讀回來的 text file 了。
				s" s' " swap + s" ' readTextFile " + \ command line 以下讓 Extention page (the host page) 執行
				s" {} js: tos().forth='shooo!stopSleeping';tos().tos=pop(1) " + \ host side packing the message object
				s" message->tabid " + \ host commands after resume from file I/O
				\
				\ Above lines composed the TOS command string:
				\ stack["
				\	s' pathname' readTextFile \ background page read the file
				\	{} js: tos().forth='shooo!stopSleeping';tos().tos=pop(1) 
				\   /* packup an 3ce message object that will wake up the target page 
				\   ** and its TOS is the text file
				\   */
				\   message->tabid /* instruct the target page to do the above task */
				\ "]
				\ dictate background page to execute the above statements.
				js: chrome.runtime.sendMessage({addr:"background",forth:pop()}) 
				10000 sleep ;   
			\ 準備好 readTextFile 就可以 include 了	
			include 3ce/system/target.f
		</text> (dictate) ;
		/// Usage : 
		/// 237 ( tabid ) attach
		/// tabs.select tabid attach
		/// ( empty, tabid by default or active-tab if from popup ) attach 

		
[then] \ Chrome extension environment.

				
	
	