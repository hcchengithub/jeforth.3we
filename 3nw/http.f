
s" http.f"	source-code-header

js> require("http") constant http // ( -- obj ) Node.js HTTP module
		
	<selftest>
	: serverServiceRoutine ." Someone visits me now!" cr ; "" tib.
	// ( -- ) A very simple HTTP server service routine
	http :> createServer(function(request,respone){execute("serverServiceRoutine")}) constant server "" tib.
	// ( -- obj ) HTTP server
	server :: listen(8888) "" tib.
	.( *** Now, use a browser to visit localhost:8888 and see the ) cr 
	.( *** corresponding message on the server side ) cr
	.( *** You have 10 minute to play before next demo. ) cr
	.( *** "stopSleeping" command jump to next demo. ) cr
	js> 1000*60*10 sleep
	server :: close() "" tib.
	.( *** server closed ) cr cr
	</selftest>
	
	