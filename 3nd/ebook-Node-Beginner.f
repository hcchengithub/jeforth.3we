
	\
	\ Node Beginner 作者： Manuel Kiessling
	\ http://www.nodebeginner.org/index-zh-tw.html
	\ https://www.evernote.com/shard/s22/nl/2472143/1da6fa2f-a93e-436c-a328-8204ebba556a
	\
	
	s" ebook-Node-Beginner.f"	source-code-header

	js> require("http") constant http // ( -- obj ) Node.js HTTP module
	js> require("url") constant url // ( -- obj ) Node.js URL module
	js> require("child_process") constant child_process // ( -- obj ) Node.js shell module
	js> require("querystring") constant querystring // ( -- obj ) Node.js POST data parser module
	js> require('util') constant util // ( -- obj ) Node.js utility module, was the 'sys' module

				process :> env.NODEJSHOME char \node_modules\formidable + >path/ 
	js> require(pop()) constant formidable // ( -- module ) Node.js external module

	<comment>
	cr cr cr
	**** ~\learnings\JavaScript\node.js\ebook NODE.js\NODE.js.pdf 
	**** This HTTP server does almost nothing, only print msg at host console.

		( A very simple HTTP server service routine ) : onRequest ." Someone visits me now!" cr js> rstack.length if 0 >r then ; "" tib.
		
	**** Arrange the HTTP server
	
		http :> createServer(function(request,respone){execute("onRequest")}) constant server "" tib.
		// ( -- obj ) HTTP server
		( 本「沒反應」網頁開張了！) server :: listen(8888) "" tib. 
		
	**** Now, use a browser to visit localhost:8888 and see the
	**** corresponding message on the server side
	**** You have 10 minute to play before next demo.
	**** "stopSleeping" command jump to next demo.
	
		js> 1000*60*10 sleep
		server :: close() "" tib.
		
	**** 查 _connections , （要等，或好像 client 端來 request 過才會變成 0，有點費解。）
	**** 此時 server :> _connections \ ==> 0 所以 server.close() 才會生效。我根據的是
	**** "Someone visits me now!" 不會再隨著 client 來嘗試而出現了。此時，再重新 
	**** server :: listen(8888) 會怎樣？==> 果然又恢復 servicing 了！用 iPad 跟 local 電腦本身分別
	**** 試過後，查 server :> _connections tib. 果然有 3 個 connections. 過一會兒，又自動變 0 了。
	*debug* 11>>
	</comment>

	<comment>
	cr cr cr
	**** Create a HTTP server that always says Hello-World.
	**** Visit http://localhost:8888 to see it.
		: MyWebServer ( request response -- ) \ Web server on HTTP request
			." Someone visits me now!" cr 
		  \ dup :: writeHead(200,{"Content-Type":"text/plain"})
		  \ dup :: write("Hello-World")
			nip :: end("Hello-World") \ The above two lines can be ommited
			js> rstack.length if 0 >r then ; \ rule for all service
		code onRequest ( request, response ) \ Call_back_function, request:arguments[0], response:arguments[1]
			push(arguments[0]);push(arguments[1]);execute('MyWebServer');
		end-code
		http :> createServer(tick('onRequest').xt) constant server "" tib.
		// ( -- obj ) HTTP server
		( 網頁開張了！) server :: listen(8888) "" tib. 
		
	**** Now, use a browser to visit localhost:8888
	**** You have 10 minute to play before next demo.
	**** "stopSleeping" command jump to next demo.
	
		js> 1000*60*10 sleep
		\ server :: close() "" tib. 依以下討論，取消 server.close() 這個動作。
		
	**** 很奇怪，我發現過即使跑這段程式的 jeforth.3we/3nw reload 過了，遠端還是可以看到
	**** hello-word 直到進 jsc 或把整個 jeforth.3nw window 都關掉才終止。再複製一遍，真的是這樣！
	**** 前一個 demo 的 server :: close() 倒是有終止，差別在哪裡？<== 前一個練習完全沒有對 client 回應，可能 socket 沒有建立。
	**** 此時 server :> _connections \ ==> 2 or 3 <-------- 線索！
	**** 把前一個的 call back function 也改成 code code 看看 ... 結果一樣。
	**** server :> close() 之後，再查 _connections ,
	**** 此時 server :> _connections \ ==> 1 奇怪！
	**** 答案 ==> http://stackoverflow.com/questions/5263716/graceful-shutdown-of-a-node-js-http-server
	****	also http://stackoverflow.com/questions/14626636/how-do-i-shutdown-a-node-js-https-server-immediately
	****	[ ] 他們都沒有提到我在 serverCallBack(request,response) 裡發現的 jsc> tos().shouldKeepAlive == true
	**** remove listener 倒可以停止 the HTTP server ==> server :> removeAllListeners() tib.
	**** 靠！既然這麼難停，那表示人家不要你停。要改，改 handler 就好了。
	**** 如果真的停了，又將引發如何繼續的問題 ==> How to resume the server is a question. The below try was failed,
	**** http :> createServer(tick('onRequest').xt) constant server
	**** server :: listen(8888)
	**** ---> events.js:72
    **** throw er; // Unhandled 'error' event
    ****       ^
	**** Error: listen EADDRINUSE
	**** at errnoException (net.js:901:11)
	**** .... snip ....
	*debug* 22>> 
	</comment>

	<comment>
	**** 來看看 request, response 的內容，嘿嘿！
	**** 不用怕在改程式的同時收到的 request 會怎樣。The beauty of single threaded 不會有那種事發生。
	**** 我打賭，隨時可以亂改 MyWebServer 不會有問題。

		: MyWebServer ( request response -- ) \ Web server on HTTP request
			cr ." Someone visits me now!"
			cr ." request  : " over obj>keys . cr
			cr ." response : " dup  obj>keys . cr
			jsc \ 好好玩！此時可以進 jsc 去「專心」慢慢玩，例如 tos(1).url 就可以看到 client 從網址列送來的東西。
		    nip now :> toString() swap :: end(pop())
			js> rstack.length if 0 >r then ; \ rule for all service

	**** 啊！但現在改 onRequest 沒有用吧！的確沒用了。所以，onRequest 要標準化，一次到位。
		\ code onRequest ( request, response ) \ Call_back_function, request:arguments[0], response:arguments[1]
		\ 	push(arguments[0]);push(arguments[1]);execute('MyWebServer');
		\ end-code

	*debug* 33>> 
	</comment>
	
	<comment>
		: MyWebServer	( request response -- ) \ Web server on HTTP request
						url :> parse(pop(1).url).pathname ( -- resp pathname )
						." Request for " . ."  received." cr ( -- response )
						js: tos().writeHead(200,{"Content-Type":"text/plain"})
						js: tos().write("Hello_World\n") 
						now :> toString() js: pop(1).end(pop())
						js> rstack.length if 0 >r then ; \ rule for all colon word service
				
		code onRequest	( request, response ) \ Call_back_function, request:arguments[0], response:arguments[1]
						push(arguments[0]);push(arguments[1]);execute('MyWebServer'); end-code
				
						http :> createServer(tick('onRequest').xt) 
		constant server // ( -- obj ) HTTP server
			
		: start			( -- ) \ Start HTTP Server and listening to port.
						8888 server :: listen(pop()) ." Server has started." cr ; 
	</comment>
		
	<comment>
		\ .... But the server doesn't need the thing. It only needs to get something done, and to 
		\ get something done, you don't need things at all, you need actions. You don't need nouns, 
		\ you need verbs. <=========== forth 也的確可以把「動詞」當 parameter 來傳，如 route,
		
		: route		( pathname -- ) \ HTTP backend dispatch requests to their code 
						." About to route a request to " . cr ;

		: doOnRequest	( route request response -- ) \ Web server on HTTP request
						url :> parse(pop(1).url).pathname ( -- route response pathname )
						." Request for " dup . ."  received." cr ( -- route response pathname )
						( pathname ) rot execute ( -- response )
						js: tos().writeHead(200,{"Content-Type":"text/plain"})
						js: tos().write("Hello_World\n") 
						now :> toString() js: pop(1).end(pop())
						js> rstack.length if 0 >r then ; \ rule for all colon word service
				
		code onRequest	( request, response ) \ Call_back_function, request:arguments[0], response:arguments[1]
						push(tick('route'));
						push(arguments[0]);
						push(arguments[1]);
						execute('doOnRequest'); 
						end-code
				
						http :> createServer(tick('onRequest').xt) 
		constant server // ( -- obj ) HTTP server

		: start			( -- ) \ Start HTTP Server and listening to port.
						8888 server :: listen(pop()) ." Server has started." cr ; 
	</comment>
	
	<comment>
	
		\ Page 39
		
		vocabulary requestHandlers // ( -- word-list ) 
		also requestHandlers definitions
		
		: start			( -- ) \ Request handler
						." Request handler 'start' was called." cr ;
						
		: upload		( -- ) \ Request handler
						." Request handler 'upload' was called." cr ;

		vocabulary HTTPserver // ( -- word-list ) 
		also HTTPserver definitions
		
		{} constant handle // ( -- hash ) \ Table of request handlers, {name, function} pairs.
		' start  handle :: ["/"]=pop()
		' start  handle :: ["/start"]=pop()
		' upload handle :: ["/upload"]=pop()
						
		: route			( pathname -- ) \ HTTP backend dispatch requests to their code 
						." About to route a request to " dup . cr 
						handle :> [tos()] ( -- pathname handle[pathname] )
						js> tos()&&tos().constructor==Word nip if ( -- pathname )
							handle :> [pop()] execute
						else  ( -- pathname handle[pathname])
							." No request handler found for " . cr
						then
						;

		: doOnRequest	( request response -- ) \ Web server on HTTP request
						url :> parse(pop(1).url).pathname ( -- response pathname )
						." Request for " dup . ."  received." cr ( -- response pathname )
						( pathname ) route ( -- response )
						js: tos().writeHead(200,{"Content-Type":"text/plain"})
						js: tos().write("Hello_World\n") 
						now :> toString() js: pop(1).end(pop())
						js> rstack.length if 0 >r then ; \ rule for all colon word service
				
		code onRequest	( request, response ) \ Call_back_function, request:arguments[0], response:arguments[1]
						push(arguments[0]);
						push(arguments[1]);
						execute('doOnRequest'); 
						end-code
				
						http :> createServer(tick('onRequest').xt)
		constant server // ( -- obj ) HTTP server
		
		: startListening ( -- ) \ Start HTTP Server and listening to port.
						8888 server :: listen(pop()) ." Server has started." cr ; 
	</comment>

	<comment>
	
		\ Page 41,43
		\ The author tried to say, return msg from start, upload is not a good method. They are blocking processes.
		\ So, what then? Use callback function?
		
		vocabulary requestHandlers // ( -- word-list ) 
		also requestHandlers definitions
		
		: start			( -- msg ) \ Request handler
						." Request handler 'start' was called." cr 
						s" Hello start" ;
						
		: upload		( -- msg ) \ Request handler
						." Request handler 'upload' was called." cr 
						s" Hello upload" ;

		vocabulary HTTPserver // ( -- word-list ) 
		also HTTPserver definitions
		
		{} constant handle // ( -- hash ) \ Table of request handlers, {name, function} pairs.
		' start  handle :: ["/"]=pop()
		' start  handle :: ["/start"]=pop()
		' upload handle :: ["/upload"]=pop()
						
		: route			( pathname -- msg ) \ HTTP backend dispatch requests to their code 
						." About to route a request to " dup . cr 
						handle :> [tos()] ( -- pathname handle[pathname] )
						js> tos()&&tos().constructor==Word nip if ( -- pathname )
							handle :> [pop()] execute
						else  ( -- pathname handle[pathname])
							." No request handler found for " . cr
							s" 404 Not found"
						then
						;

		: doOnRequest	( request response -- ) \ Web server on HTTP request
						url :> parse(pop(1).url).pathname ( -- response pathname )
						." Request for " dup . ."  received." cr ( -- response pathname )
						( pathname ) route ( -- response msg )
						js: tos(1).writeHead(200,{"Content-Type":"text/plain"})
						js: tos(1).write(pop()) ( -- response)
						js: tos(1).write('\n') ( -- response)
						now :> toString() js: pop(1).end(pop())
						js> rstack.length if 0 >r then ; \ rule for all colon word service
				
		code onRequest	( request, response ) \ Call_back_function, request:arguments[0], response:arguments[1]
						push(arguments[0]);
						push(arguments[1]);
						execute('doOnRequest'); 
						end-code
				
						http :> createServer(tick('onRequest').xt)
		constant server // ( -- obj ) HTTP server
		
		: startListening ( -- ) \ Start HTTP Server and listening to port.
						8888 server :: listen(pop()) ." Server has started." cr ; 
	</comment>

	<comment>
	
		\ Page 44
		\ Try blocking design and see the bad of it.
		\ Try to browse localhost:8888/start and ~/upload at the same time from two browser pages, they
		\ both got blocked for 10 seconds, even only /start is a blocking process while /upload is not.
		\ ==> Yes, sure, that's what happened as I tried.
		
		vocabulary requestHandlers // ( -- word-list ) 
		also forth requestHandlers definitions
		
		: start			( -- msg ) \ Request handler
						." Request handler 'start' was called." cr 
						10000 freeze
						s" Hello start" ;
						
		: upload		( -- msg ) \ Request handler
						." Request handler 'upload' was called." cr 
						s" Hello upload" ;

		vocabulary HTTPserver // ( -- word-list ) 
		also forth HTTPserver definitions
		
		{} constant handle // ( -- hash ) \ Table of request handlers, {name, function} pairs.
		' start  handle :: ["/"]=pop()
		' start  handle :: ["/start"]=pop()
		' upload handle :: ["/upload"]=pop()
						
		: route			( pathname -- msg ) \ HTTP backend dispatch requests to their code 
						." About to route a request to " dup . cr 
						handle :> [tos()] ( -- pathname handle[pathname] )
						js> tos()&&tos().constructor==Word nip if ( -- pathname )
							handle :> [pop()] execute
						else  ( -- pathname handle[pathname])
							." No request handler found for " . cr
							s" 404 Not found"
						then
						;

		: doOnRequest	( request response -- ) \ Web server on HTTP request
						url :> parse(pop(1).url).pathname ( -- response pathname )
						." Request for " dup . ."  received." cr ( -- response pathname )
						( pathname ) route ( -- response msg )
						js: tos(1).writeHead(200,{"Content-Type":"text/plain"})
						js: tos(1).write(pop()) ( -- response)
						js: tos().write('\n') ( -- response)
						now :> toString() js: pop(1).end(pop())
						js> rstack.length if 0 >r then ; \ rule for all colon word service
				
		code onRequest	( request, response ) \ Call_back_function, request:arguments[0], response:arguments[1]
						push(arguments[0]);
						push(arguments[1]);
						execute('doOnRequest'); 
						end-code
				
						http :> createServer(tick('onRequest').xt)
		constant server // ( -- obj ) HTTP server
		
		: startListening ( -- ) \ Start HTTP Server and listening to port.
						8888 server :: listen(pop()) ." Server has started." cr ; 
	</comment>

	<comment>
	
		\ Page 52 成功，但有疑問
		\ Page 54 start2 become an I/O bound process but none blocking. 成功。
		\ 
		\ 改用 event driven 的觀念做事情 ── 本來是國王等著官員回報，以便進行下一步驟。這製造出「等」回
		\ 應的需要。現在改成：國王派工作下去時，同時給他超人水晶，callback 時透過水晶，把工作完成。
		\ 非必要不必再靠國王調派工作。local.f 定義從 return stack 取得以 bp 相對位置參考的 variable 空間。

		include local.f
		
		vocabulary requestHandlers // ( -- word-list ) 
		also forth requestHandlers definitions
		
		: start			( -- ) \ Request handler
						(   request response handle pathname   )
						(   bp+4    bp+3     bp+2   bp+1       )
						." Request handler 'start' was called." cr 
						child_process <js> pop().exec("dir", function(error, stdout, stderr){
							js: rstack[bp+3].writeHead(200,{"Content-Type":"text/plain"});
							js: rstack[bp+3].write(stdout);
							js: rstack[bp+3].end();
						})</js> ;

		: start2			( -- ) \ Request handler
						(   request response handle pathname   )
						(   bp+4    bp+3     bp+2   bp+1       )
						." Request handler 'start' was called." cr 
						child_process <js> pop().exec("dir c:\\ /s ", {
							timeout:10000, maxBuffer: 1000*1000*500
						}, function(error, stdout, stderr){
							js: rstack[bp+3].writeHead(200,{"Content-Type":"text/plain"});
							js: rstack[bp+3].write(stdout);
							js: rstack[bp+3].end();
						})</js> ;
						
		: upload		( -- ) \ Request handler
						(   request response handle pathname   )
						(   bp+4    bp+3     bp+2   bp+1       )
						." Request handler 'upload' was called." cr 
						js: rstack[bp+3].writeHead(200,{"Content-Type":"text/plain"});
						<js> rstack[bp+3].write("Hello Upload"); </js>
						js: rstack[bp+3].end();
						;

		vocabulary HTTPserver // ( -- word-list ) 
		also forth HTTPserver definitions
		
		{} constant handle // ( -- hash ) \ Table of request handlers, {name, function} pairs.
		' start  handle :: ["/"]=pop()
		' start  handle :: ["/start"]=pop()
		' start2 handle :: ["/start2"]=pop()
		' upload handle :: ["/upload"]=pop()
						
		: route			( -- ) \ HTTP backend dispatch requests to their code 
						(   request response handle pathname   )
						(   bp+4    bp+3     bp+2   bp+1       )
						." About to route a request to " js> rstack[bp+1] . cr 
						js> rstack[bp+2][rstack[bp+1]] ( -- handle[pathname] )
						js> tos()&&tos().constructor==Word if ( -- handle[pathname] )
							execute ( -- )
						else  ( -- handle[pathname] )
							drop ." No request handler found for " js> rstack[bp+1] . cr
							js: rstack[bp+3].writeHead(404,{"Content-Type":"text/plain"}) 
							<js> rstack[bp+3].write("404 not found") </js>
							js: rstack[bp+3].end()
						then ;

		: doOnRequest	( request response -- ) \ Web server on HTTP request
						handle url :> parse(tos(2).url).pathname 
						(   request response handle pathname   )
						(-- bp+4    bp+3     bp+2   bp+1     --)
						." Request for " dup . ."  received." cr ( -- request response handle pathname )
						route ( -- )
						0 >r ; \ Protect TSR's return stack, we have data in it.
				
		code onRequest	( request, response ) \ Call_back_function, request:arguments[0], response:arguments[1]
						push(arguments[0]);
						push(arguments[1]);
						execute('doOnRequest'); 
						end-code
				
						http :> createServer(tick('onRequest').xt)
		constant server // ( -- obj ) HTTP server
		
		: startListening ( -- ) \ Start HTTP Server and listening to port.
						8888 server :: listen(pop()) ." Server has started." cr ; 
	</comment>

	<comment>
		jsc> see(rstack)
		0,/start,[object Object],[object Object],[object Object],0,0,/upload,[
		t],[object Object],[object Object],0,12,/,[object Object],[object Obje
		 Object],0,24,/upload,[object Object],[object Object],[object Object],
		  0 :   [object Number]
		  1 :   /start
		  2 :   [object Object]
		  3 :   [object Object]
		  4 :   [object Object]
		  5 :   [object Number]
		  6 :   [object Number]
		  7 :   /upload
		  8 :   [object Object]
		  9 :   [object Object]
		  10 :   [object Object]
		  11 :   [object Number]
		  12 :   6
		  13 :   /
		  14 :   [object Object]
		  15 :   [object Object]
		  16 :   [object Object]
		  17 :   [object Number]
		  18 :   12
		  19 :   /
		  20 :   [object Object]
		  21 :   [object Object]
		  22 :   [object Object]
		  23 :   [object Number]
		  24 :   18
		  25 :   /
		  26 :   [object Object]
		  27 :   [object Object]
		  28 :   [object Object]
		  29 :   [object Number]
		  30 :   24
		  31 :   /upload
		  32 :   [object Object]
		  33 :   [object Object]
		  34 :   [object Object]
		  35 :   [object Number]
		  36 :   [object Number]
		undefined
		 (undefined)

		visit 一遍 /upload 果然多出一段。這下疑惑了，當要收工時，如何讓每一段單獨湮滅？
		怎麼知道啥是「收工」？當網頁從 client 端被關掉時，不會有消息給 server 端。可以透過 bp 
		追朔回所有的 local 結構。該等結構應該可以是異質的，釋放可以收掉的。我覺得到這裡，事情
		已經有點太複雜了？每個 instance 都要設自己的 timeout() 到時候來收工。這變成每個 instance 
		要記住自己的 BP 這已經是 create-does word 的特性了。我們動態產生的結構都是 annonymous 
		的，不是那種的。

		  35 :   [object Number]
		  36 :   30
		  37 :   /upload
		  38 :   [object Object]
				  jsc> see(rstack[38])
					[object Object]
					  / :   start ( -- ) Request handler
					  /start :   start ( -- ) Request handler
					  /upload :   upload ( -- ) Request handler
					undefined
					 (undefined)
		  39 :   [object Object] <=== response
		  40 :   [object Object] <=== request
		  41 :   [object Number] <=== 0
		  42 :   [object Number] <=== 0
		undefined
		 (undefined)		
	</comment>
	
	<comment>
	
		\ 
		\ page 56 OK now hcchen5600 2014/11/08 17:33:08 
		\ Start using 'listening' on 'data' and 'end' event to collect POST data from client before
		\ calling router which then pass down the data to the correct handler according to the given address
		\ on the address line from the client.
		\ 

		include local.f
		
		vocabulary requestHandlers // ( -- word-list ) 
		also forth requestHandlers definitions

		
		: start			( -- ) \ Request handler
						(   request response handle pathname   )
						(   bp+4    bp+3     bp+2   bp+1       )
						." Request handler 'start' was called." cr 
						js: rstack[bp+3].writeHead(200,{"Content-Type":"text/html"})
						<text>
							<html>
							<head>
							<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
							</head>
							<body>
							<form action="/upload" method="post">
							<textarea name=text rows=20 cols=60></textarea>
							<input type="submit" value="Submit text" />
							</form>
							</body>
							</html>
						</text>
						js: rstack[bp+3].write(pop())
						js: rstack[bp+3].end() 
						;

		: upload		( -- ) \ Request handler
						(   request response handle pathname   )
						(   bp+4    bp+3     bp+2   bp+1       )
						." Request handler 'upload' was called." cr 
						js: rstack[bp+3].writeHead(200,{"Content-Type":"text/plain"});
						<js> rstack[bp+3].write("Hello Upload"); </js>
						js: rstack[bp+3].end();
						;

		also forth definitions
		vocabulary HTTPserver // ( -- word-list ) 
		HTTPserver definitions
		
		{} constant handle // ( -- hash ) \ Table of request handlers, {name, function} pairs.
		' start  handle :: ["/"]=pop()
		' start  handle :: ["/start"]=pop()
		' upload handle :: ["/upload"]=pop()
						
		: route			( -- ) \ HTTP backend dispatch requests to their code 
						(   request response handle pathname   )
						(   bp+4    bp+3     bp+2   bp+1       )
						." About to route a request to " js> rstack[bp+1] . cr 
						js> rstack[bp+2][rstack[bp+1]] ( -- handle[pathname] )
						js> tos()&&tos().constructor==Word if ( -- handle[pathname] )
							execute ( -- )
						else  ( -- handle[pathname] )
							drop ." No request handler found for " js> rstack[bp+1] . cr
							js: rstack[bp+3].writeHead(404,{"Content-Type":"text/plain"}) 
							<js> rstack[bp+3].write("404 not found") </js>
							js: rstack[bp+3].end()
						then ;

		: doOnData		( -- ) \ Receving POST data chunk. Called by the event directly
						js> rstack[bp+5]+=pop()
						." Received POST data chunk '" . ." '" cr ;
						
		code onData		( chunk ) \ Receving POST data chunk. Called by the event directly
						push(arguments[0]); execute('doOnData'); end-code
						
		: doOnEnd		( -- ) \ Pass to router at the right timing.
						route ;
						
		code onEnd		( void ) \ POST end. Called by the event directly
						execute('doOnEnd');  end-code
						
		: doOnRequest	( request response -- ) \ Web server on HTTP request
						handle url :> parse(tos(2).url).pathname 
						." Request for " dup . ."  received." cr ( -- request response handle pathname )
						js: push("",4) \ local variable postData initial 不放 TOS 是為了沿用先前的結構順序
						(   postData request response handle pathname   )
						(-- bp+5     bp+4    bp+3     bp+2   bp+1     --)
						js> rstack[bp+4] :: setEncoding('utf8')
						js> rstack[bp+4] :: addListener("data",tick('onData').xt)
						js> rstack[bp+4] :: addListener("end",tick('onEnd').xt)
						0 >r ; \ Protect TSR's return stack, we have data in it.

		code onRequest	( request, response ) \ Call_back_function, request:arguments[0], response:arguments[1]
						push(arguments[0]);
						push(arguments[1]);
						execute('doOnRequest'); 
						end-code
				
						http :> createServer(tick('onRequest').xt)
		constant server // ( -- obj ) HTTP server
		
		: startListening ( -- ) \ Start HTTP Server and listening to port.
						8888 server :: listen(pop()) ." Server has started." cr ; 
	</comment>

	<comment>
	
		\ 
		\ page 61 Let /upload handler show the data ---> 成功！
		\ 我前一個實作觀念不太清楚 -- request handlers 應該是獨立在外的 functions 故看不見 doOnRequest closure
		\ 內的 variables. 因此 arguments 要透過正常管道從 data stack 傳遞過去。[ ] 在 forth 裡，如何讓 doOnRequest 
		\ closure 裡 (也就是 server) 的東西只有 server 看得見？ [ ] Ask FigTaiwan
		\ router 既不屬 server 也不屬 request handler 故東西也是從 data stacck 傳過來的才對，然後又 pass 給 
		\ request handlers.
		\

		include local.f
		
		vocabulary requestHandlers // ( -- word-list ) 
		also forth requestHandlers definitions

		
		: start			( postData response -- ) \ Request handler
						." Request handler 'start' was called." cr 
						js: tos().writeHead(200,{"Content-Type":"text/html"})
						<text>
							<html>
							<head>
							<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
							</head>
							<body>
							<form action="/upload" method="post">
							<textarea name=text rows=20 cols=60></textarea>
							<textarea name=text2 rows=10 cols=60></textarea>
							<input type="submit" value="Submit text" />
							</form>
							</body>
							</html>
						</text>
						js: tos(1).write(pop())
						js: tos().end() 
						2drop
						;

		: upload		( postData response -- ) \ Request handler
						." Request handler 'upload' was called." cr 
						js: tos().writeHead(200,{"Content-Type":"text/plain"});
						querystring :> parse(tos(1)).text ( -- postData response text )
						<js> tos(1).write("You've send:" + pop(2) + " \nWhere text is:" + pop()); </js>
						js: pop().end();
						;

		also forth definitions
		vocabulary HTTProuter // ( -- word-list ) 
		HTTProuter definitions
		
		{} constant handle // ( -- hash ) \ Table of request handlers, {name, function} pairs.
		' start  handle :: ["/"]=pop()
		' start  handle :: ["/start"]=pop()
		' upload handle :: ["/upload"]=pop()
						
		: route			( handle pathname postData response -- ) \ HTTP backend dispatch requests to their code 
						." About to route a request to " js> tos(2) . cr 
						js> pop(3)[tos(2)] ( -- pathname postData response handle[pathname] )
						js> tos()&&tos().constructor==Word if ( -- pathname postData response handle[pathname] )
							execute ( pathname postData response handle[pathname] -- pathname )
							drop
						else  ( -- pathname postData response handle[pathname] )
							." No request handler found for " js> pop(3) . cr ( -- postData response handle[pathname] )
							js: tos(1).writeHead(404,{"Content-Type":"text/plain"}) 
							<js> tos(1).write("404 not found") </js>
							js: tos(1).end() ( -- postData response handle[pathname] )
							3 drops 
						then ;

		also forth definitions
		vocabulary HTTPserver // ( -- word-list ) 
		HTTPserver definitions

		: doOnData		( -- ) \ Receving POST data chunk. Called by the event directly
						js> rstack[bp+5]+=pop()
						." Received POST data chunk '" . ." '" cr ;
						
		code onData		( chunk ) \ Receving POST data chunk. Called by the event directly
						push(arguments[0]); execute('doOnData'); end-code
						
		: doOnEnd		( -- ) \ Pass to router at the right timing.
						js> rstack[bp+2] js> rstack[bp+1] js> rstack[bp+5] js> rstack[bp+3]
						route ( handle pathname postData response -- )
						;
						
		code onEnd		( void ) \ POST end. Called by the event directly
						execute('doOnEnd');  end-code
						
		: doOnRequest	( request response -- ) \ Web server on HTTP request
						handle url :> parse(tos(2).url).pathname 
						." Request for " dup . ."  received." cr ( -- request response handle pathname )
						js: push("",4) \ local variable postData initial 不放 TOS 是為了沿用先前的結構順序
						(   postData request response handle pathname   )
						(-- bp+5     bp+4    bp+3     bp+2   bp+1     --)
						js> rstack[bp+4] :: setEncoding('utf8')
						js> rstack[bp+4] :: addListener("data",tick('onData').xt)
						js> rstack[bp+4] :: addListener("end",tick('onEnd').xt)
						0 >r ; \ Protect TSR's return stack, we have data in it.

		code onRequest	( request, response ) \ Call_back_function, request:arguments[0], response:arguments[1]
						push(arguments[0]);
						push(arguments[1]);
						execute('doOnRequest'); 
						end-code
				
						http :> createServer(tick('onRequest').xt)
		constant server // ( -- obj ) HTTP server
		
		: startListening ( -- ) \ Start HTTP Server and listening to port.
						8888 server :: listen(pop()) ." Server has started." cr ; 
	</comment>

	<comment>
		Use full pathh for nw to require existing external module in Node.js folder, for example:
		char c:\Users\8304018\Dropbox\learnings\JavaScript\node.js\node_modules\formidable >path/ js> require(pop())
		constant formidable // ( -- module ) Node.js external module
	</comment>

	<comment>
	
		\ 
		\ page 66 Formidable example , it works. But 收到的 files object 都是空的 [ ] 先不管了。
		\ 用 rstack 傳 closure 的資料除了用完去不掉，使用上也相當繁瑣。
		\ 

		include local.f
		
		also forth definitions
		vocabulary HTTPserver // ( -- word-list ) 
		HTTPserver definitions
						
		: doOnRequest	( request response -- ) \ Web server on HTTP request
						util -rot char formDummy ( -- util request response form )
						(-- util request response form --)
						(   bp+4  bp+3   bp+2     bp+1   )
						js> rstack[bp+3].url=="/upload"&&rstack[bp+3].method.toLowerCase()=="post" 
						if ( -- util request response )
							\ parse a file upload
							formidable <js> rstack[bp+1] = new pop().IncomingForm()</js>
							<js> 
								rstack[bp+1].parse(rstack[bp+3],function(err, fields, files){
									rstack[bp+2].writeHead(200,{"Content-Type":"text/plain"});
									rstack[bp+2].write("Received upload:\n\n");
									rstack[bp+2].end(rstack[bp+4].inspect({fields:fields, files:files}));
									print("Leaving files on TOS ...");push(files);print("\n");
									print("Leaving fields on TOS ...");push(fields);print("\n");
									print("Leaving err on TOS ...");push(err);print("\n");
								})
							</js>
						else ( -- request response )
							js: rstack[bp+2].writeHead(200,{"Content-Type":"text/html"}) 
							<text>
								<form action="/upload" encrypt="multipart/form-data" method=post>
								<input type=text name=title><br>
								<input type=file name=upload multiple=multiple><br>
								<input type=submit value=upload></form>
							</text>
							js: rstack[bp+2].end(pop())
						then
						0 >r ; \ Protect TSR's return stack, we have data in it.

		code onRequest	( request, response ) \ Call_back_function, request:arguments[0], response:arguments[1]
						push(arguments[0]);
						push(arguments[1]);
						execute('doOnRequest'); 
						end-code
				
						http :> createServer(tick('onRequest').xt)
		constant server // ( -- obj ) HTTP server
		
		: startListening ( -- ) \ Start HTTP Server and listening to port.
						8888 server :: listen(pop()) ." Server has started." cr ; 
	</comment>

	<comment>
	
		\ 
		\ page 69 it works. 
		\ Upload a text file and it shows back on the client browser window.
		\ localhost:8888/show is a stand alone feature. It prints the ~\jeforth.3we\test.png on the client
		\ browser window no matter what file is uploaded.
		\
		\ The major difference from the previous one is that the previous requet handler 'start' and 'upload'
		\ were not setting up any call back function. But now the coming 'show' does. (1) The underlaing call 
		\ back function must be grounded. (2) The input data must be prepared by router if follow the previous
		\ case. The problem is that passing down the 'response' object from router to request handler through
		\ data stack simply because router itself is a call back function. Now 'show' would further setup 
		\ another call back function and pass down the 'request' object again that needs to generate return
		\ stack local variable structure with identical data , no good! Therefore, I am thinking of .....
		\ using onRequest's rstack local variables directly.
		\
		\ 用 forth 來取代 JavaScript 少了 closure 裡繼承 local variable 的能力，勉強
		\ 用 (-- ... --) 做到的既不好用也不周延，倒不如直接用 JavaScript 好。如此一來 forth 能扮演什麼角色？
		\ 感覺有很大的機會但想不清楚，[ ] 請教 FigTaiwan 吧！
		\

		include local.f
		
		vocabulary requestHandlers // ( -- word-list ) 
		also forth requestHandlers definitions

		
		: start			( postData response -- ) \ Request handler
						." Request handler 'start' was called." cr 
						js: tos().writeHead(200,{"Content-Type":"text/html"})
						<text>
							<html>
							<head>
							<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
							</head>
							<body>
							<form action="/upload" enctype="multipart/form-data" method="post">
							<input type="file" name="upload">
							<textarea name=text rows=20 cols=60></textarea>
							<input type="submit" value="Upload file" />
							</form>
							</body>
							</html>
						</text>
						js: tos(1).write(pop())
						js: tos().end() 
						2drop
						;

		: upload		( postData response -- ) \ Request handler
						." Request handler 'upload' was called." cr 
						js: tos().writeHead(200,{"Content-Type":"text/plain"})
						querystring :> parse(tos(1)).text ( -- postData response text )
						<js> tos(1).write("You've send:" + pop(2) + " \nWhere text is:" + pop()); </js>
						js: pop().end()
						;

		: doShow		( err file -- ) \ The run time of 'show'
						over if
							drop
							js> rstack[bp+3] :: writeHead(500,{"Content-Type":"text/plain"})
							js> rstack[bp+3] :: write(pop()+"\n")
							js> rstack[bp+3] :: end()
						else
							nip
							js> rstack[bp+3] :: writeHead(200,{"Content-Type":"image/png"})
							js> rstack[bp+3] :: write(pop(),"binary")
							js> rstack[bp+3] :: end()
						then
						;
						
		: show			( postData response -- ) \ Request handler, show uploaded data
						." Request handler 'show' was called." cr 
						<js> kvm.fso.readFile("test.png","binary",function(e,f){
							push(arguments[0]); 
							push(arguments[1]);
							execute('doShow'); 
						}); </js> ;
						/// test.png is expected at ~\jeforth.3we\test.png 
						
		also forth definitions
		vocabulary HTTProuter // ( -- word-list ) 
		HTTProuter definitions
		
		{} constant handle // ( -- hash ) \ Table of request handlers, {name, function} pairs.
		' start  handle :: ["/"]=pop()
		' start  handle :: ["/start"]=pop()
		' upload handle :: ["/upload"]=pop()
		' show   handle :: ["/show"]=pop()
						
		: route			( handle pathname postData response -- ) \ HTTP backend dispatch requests to their code 
						." About to route a request to " js> tos(2) . cr 
						js> pop(3)[tos(2)] ( -- pathname postData response handle[pathname] )
						js> tos()&&tos().constructor==Word if ( -- pathname postData response handle[pathname] )
							execute ( pathname postData response handle[pathname] -- pathname )
							drop
						else  ( -- pathname postData response handle[pathname] )
							." No request handler found for " js> pop(3) . cr ( -- postData response handle[pathname] )
							js: tos(1).writeHead(404,{"Content-Type":"text/plain"}) 
							<js> tos(1).write("404 not found") </js>
							js: tos(1).end() ( -- postData response handle[pathname] )
							3 drops 
						then ;

		also forth definitions
		vocabulary HTTPserver // ( -- word-list ) 
		HTTPserver definitions

		: doOnData		( -- ) \ Receving POST data chunk. Called by the event directly
						js> rstack[bp+5]+=pop()
						." Received POST data chunk '" . ." '" cr ;
						
		code onData		( chunk ) \ Receving POST data chunk. Called by the event directly
						push(arguments[0]); execute('doOnData'); end-code
						
		: doOnEnd		( -- ) \ Pass to router at the right timing.
						js> rstack[bp+2] js> rstack[bp+1] js> rstack[bp+5] js> rstack[bp+3]
						route ( handle pathname postData response -- )
						;
						
		code onEnd		( void ) \ POST end. Called by the event directly
						execute('doOnEnd');  end-code
						
		: doOnRequest	( request response -- ) \ Web server on HTTP request
						handle url :> parse(tos(2).url).pathname 
						." Request for " dup . ."  received." cr ( -- request response handle pathname )
						js: push("",4) \ local variable postData initial 不放 TOS 是為了沿用先前的結構順序
						(   postData request response handle pathname   )
						(-- bp+5     bp+4    bp+3     bp+2   bp+1     --)
						js> rstack[bp+4] :: setEncoding('utf8')
						js> rstack[bp+4] :: addListener("data",tick('onData').xt)
						js> rstack[bp+4] :: addListener("end",tick('onEnd').xt)
						0 >r ; \ Protect TSR's return stack, we have data in it.

		code onRequest	( request, response ) \ Call_back_function, request:arguments[0], response:arguments[1]
						push(arguments[0]);
						push(arguments[1]);
						execute('doOnRequest'); 
						end-code
				
						http :> createServer(tick('onRequest').xt)
		constant server // ( -- obj ) HTTP server
		
		: startListening ( -- ) \ Start HTTP Server and listening to port.
						8888 server :: listen(pop()) ." Server has started." cr ; 
	</comment>
	
	
	\ <comment>
	
		\ 
		\ page 71
		\ o 前面先確定 server 有能力把 test.png 顯示給 client。現在要把 client 提供的圖片顯示回去。
		\ o 前面用來蒐集 POST 傳來檔案資料的方法，得 postData，不錯呀！well, 這會兒又不要了。
		\ o 改讓 router pass down request 而非 postData.
		\ [ ] 發現之前的,  
		\     execute ( pathname postData response handle[pathname] -- pathname )
		\     drop
		\     有問題，handler forth words 並沒有留下 pathname。
		\ o show > doShow 不要了，直接在 show 裡面用 JavaScript 設定 readFile 的 callback. Forth 沒有
		\	closure 向子孫遺傳 variables 的能力，我投降了。 [ ] report to FigTaiwan
		\ o 先前 onRequest 有設定 listener for data and end
		\

		include local.f
		
		vocabulary requestHandlers // ( -- word-list ) 
		also forth requestHandlers definitions

		
		: start			( request response -- ) \ Request handler
						." Request handler 'start' was called." cr 
						js: tos().writeHead(200,{"Content-Type":"text/html"})
						<text>
							<html>
							<head>
							<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
							</head>
							<body>
							<form action="/upload" enctype="multipart/form-data" method="post">
							<input type="file" name="upload">
							<input type="submit" value="Upload file" />
							</form>
							</body>
							</html>
						</text>
						js: tos(1).write(pop())
						js: tos().end() 
						2drop
						;

		: upload		( request response -- ) \ Request handler
						." Request handler 'upload' was called." cr 
						formidable ( -- request response formidable )
						<js> 
							var form = new pop().IncomingForm(); var response=pop(), request=pop();
							print("About to parse\n");
							form.parse(request, function(err, fields, files){
								print("Parsing done\n");
								kvm.fso.renameSync(files.upload.path, "test.png");
								response.writeHead(200,{"Content-Type":"text/html"});
								response.write("received image:<br/>");
								response.write("<img src='/show' />");
								response.end();
							})
						</js> ;

		\ : doShow		( err file -- ) \ The run time of 'show'
		\ 				over if
		\ 					drop
		\ 					js> rstack[bp+3] :: writeHead(500,{"Content-Type":"text/plain"})
		\ 					js> rstack[bp+3] :: write(pop()+"\n")
		\ 					js> rstack[bp+3] :: end()
		\ 				else
		\ 					nip
		\ 					js> rstack[bp+3] :: writeHead(200,{"Content-Type":"image/png"})
		\ 					js> rstack[bp+3] :: write(pop(),"binary")
		\ 					js> rstack[bp+3] :: end()
		\ 				then
		\ 				;
						
		: show			( request response -- ) \ Request handler, show uploaded data
						." Request handler 'show' was called." cr 
						<js> 
							var response = pop(), request = pop();
							kvm.fso.readFile("test.png", "binary", function(error, file) {
								if(error) {
									response.writeHead(500, {"Content-Type": "text/plain"});
									response.write(error + "\n");
									response.end();
								} else {
									response.writeHead(200, {"Content-Type": "image/png"});
									response.write(file, "binary");
									response.end();
								}
						}); </js> ;
						/// test.png is expected at ~\jeforth.3we\test.png 
						
		also forth definitions
		vocabulary HTTProuter // ( -- word-list ) 
		HTTProuter definitions
		
		{} constant handle // ( -- hash ) \ Table of request handlers, {name, function} pairs.
		' start  handle :: ["/"]=pop()
		' start  handle :: ["/start"]=pop()
		' upload handle :: ["/upload"]=pop()
		' show   handle :: ["/show"]=pop()
						\ old handle pathname request response
		: route			( request response handle pathname -- ) \ HTTP backend dispatch requests to their code 
						." About to route a request to " dup . cr 
						js> pop(1)[tos()] ( -- request response pathname handle[pathname] )
						js> tos()&&tos().constructor==Word if ( -- request response pathname handle[pathname] )
							nip ( -- request response handle[pathname] ) 
							execute 
						else  ( -- request response pathname handle[pathname] )
							." No request handler found for " swap . cr ( -- request response handle[pathname] )
							js: tos(1).writeHead(404,{"Content-Type":"text/plain"}) 
							<js> tos(1).write("404 not found") </js>
							js: tos(1).end() ( -- request response handle[pathname] )
							3 drops 
						then ;

		also forth definitions
		vocabulary HTTPserver // ( -- word-list ) 
		HTTPserver definitions

		\ : doOnData		( -- ) \ Receving POST data chunk. Called by the event directly
		\ 				js> rstack[bp+5]+=pop()
		\ 				." Received POST data chunk '" . ." '" cr ;
		\ 				
		\ code onData		( chunk ) \ Receving POST data chunk. Called by the event directly
		\ 				push(arguments[0]); execute('doOnData'); end-code
		\ 				
		\ : doOnEnd		( -- ) \ Pass to router at the right timing.
		\ 				js> rstack[bp+2] js> rstack[bp+1] js> rstack[bp+5] js> rstack[bp+3]
		\ 				route ( handle pathname postData response -- )
		\ 				;
		\ 				
		\ code onEnd		( void ) \ POST end. Called by the event directly
		\ 				execute('doOnEnd');  end-code
		\

		: doOnRequest	( request response -- ) \ Web server on HTTP request
						handle url :> parse(tos(2).url).pathname 
						." Request for " dup . ."  received." cr ( -- request response handle pathname )
						( -- request response handle pathname ) route
						\ (-- bp+4    bp+3     bp+2   bp+1     --)
						\ js> rstack[bp+4] :: setEncoding('utf8')
						\ js> rstack[bp+4] :: addListener("data",tick('onData').xt)
						\ js> rstack[bp+4] :: addListener("end",tick('onEnd').xt)
						0 >r ; \ Protect TSR's return stack, we have data in it.

		code onRequest	( request, response ) \ Call_back_function, request:arguments[0], response:arguments[1]
						push(arguments[0]);
						push(arguments[1]);
						execute('doOnRequest'); 
						end-code
				
						http :> createServer(tick('onRequest').xt)
		constant server // ( -- obj ) HTTP server
		
		: startListening ( -- ) \ Start HTTP Server and listening to port.
						8888 server :: listen(pop()) ." Server has started." cr ; 
	</comment>
	
	
	
	
		
	
	