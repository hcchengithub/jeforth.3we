
\ http://stackoverflow.com/questions/13428532/using-a-local-file-as-a-data-source-in-javascript

include nw.f

s" server.f"	?skip2 --EOF-- \ skip it if already included
				dup .( Including ) . cr char -- over over + + 
			 	also forth definitions (marker) (vocabulary) 
			 	last execute definitions
				
.( ----- server.f 11 ----- ) cr

<selftest> marker --server.f-self-test-- </selftest>

.( ----- server.f 22 ----- ) cr
code webpage	( "html" port -- ) \ web page
				var port=pop(), html=pop(); execute("http"); var http=pop();
				http.createServer(function(request,response){
					print("Request received ...");
					response.writeHead(200,{"Content-Type":"text/html"}); // or "Content-Type":"text/plain"
					response.write(html);
					response.end();
					print(" web page replied.\n");
				}).listen(port);
				end-code
.( ----- server.f 33 ----- ) cr

<selftest>
	true [if]
		char <h1>Hello!!</h1> 99 webpage \ Create a page at http://localhost:99
	[then]
</selftest>

.( ----- server.f 44 ----- ) cr

<selftest> --server.f-self-test-- </selftest>
js> tick('<selftest>').enabled [if] js> tick('<selftest>').buffer tib.insert [then] 
js: tick('<selftest>').buffer="" \ recycle the memory
\ --EOF--
