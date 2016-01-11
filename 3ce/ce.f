

: tabs.query ( -- array ) \ Get an array of all tabs of the current window
	<js> chrome.tabs.query({},function(tabs){
		push(tabs);
		execute('stopSleeping')
	})</js> 10000 sleep ;
	
: list-tabs ( -- ) \ List Tabs in the current window
	tabs.query ( array ) dup :> length ( array length )
	?dup if for ( array )
	r@ 1- js> tos(1) :> [pop()] ( array tab )
	dup :> id . space ( array tab )
	:> title . cr ( array )
	next drop then ;

: tab.console.log ( tabid "message" -- ) \ For exparimental fun
	<js> chrome.tabs.executeScript(pop(1)/*tabid*/,
	{code:'console.log("Hello")'}
	//,function(result){
	//	push(result);
	//	dictate(".s .' Done!!' cr");
	//}
	)</js>
	;
	
