
s" ce.f" source-code-header

: tabs.query ( -- array ) \ Get an array of all tabs of the current window
	<js> chrome.tabs.query({},function(tabs){
		push(tabs);
		execute('stopSleeping')
	})</js> 10000 sleep ;
	/// tabs.query (see) to see them.
	
: list-tabs ( -- ) \ List Tabs in the current window
	tabs.query ( array ) dup :> length ( array length )
	?dup if for ( array )
	r@ 1- js> tos(1) :> [pop()] ( array tab )
	dup :> id . space ( array tab )
	:> title . cr ( array )
	next drop then ;
	/// tabs.query (see) to see them in details.

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
	
