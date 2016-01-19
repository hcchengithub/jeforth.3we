
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
	
: tabs.getCurrent ( -- objTab ) \ Get the current tab object where this script is running.
	js: chrome.tabs.getCurrent(function(tab){push(tab);execute('stopSleeping')}) 
	1000 sleep ;
	/// Returns an 'undefined' if used in the popup page or background page.

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
	
	
: tab.console.log ( tabid "message" -- ) \ For exparimental fun
	<js> chrome.tabs.executeScript(pop(1)/*tabid*/,
	{code:'console.log("Hello")'}
	//,function(result){
	//	push(result);
	//	dictate(".s .' Done!!' cr");
	//}
	)</js>
	;
	
: get-manifest ( -- obj ) \ Get the Chrome extension/app manifest hash table.
	js> chrome.runtime.getManifest() ;
	
: see-manifest ( -- ) \ See the Chrome extension/app manifest hash table.
	get-manifest js> JSON.stringify(pop(),"\n","\t") . ;
	
code inject-project-k-kernel ( tabid -- ) \ Inject project-k kernel to the Tab.
	chrome.tabs.executeScript(
		pop(),
		{
			file:'project-k/jeforth.js'
		}
	) end-code

[then]

<comment>
	<text>
	chrome.runtime.onMessage.addListener(
		function(request, sender, sendResponse) {
			console.log(request);
			console.log(sender);
			sendResponse("This is my response"); // <----- make a response string.
		}
	)
	</text> <js> 
	chrome.tabs.executeScript (
		225,{
			"code": pop()
		},
		function(result){push(result)}
	) </js> . // <----- See result
		



	: <chrome.tabs.executeScript> ( <js statements> -- result ) \ Execute Script statements on itab
					char </js>|</jsV>|</jsN>|</jsRaw> word ; immediate

	: </jsN> 		( "statements" -- ) \ No return value
					compiling if jsFuncNo , else jsEvalNo then ; immediate
					/// 可以用來組合 JavaScript function
					last alias </js>  immediate

	: </jsV> 		( "statements" -- ) \ Retrun the value of last statement
					compiling if jsFunc , else jsEval then ; immediate
					/// 可以用來組合 JavaScript function

</comment>

				
	
	