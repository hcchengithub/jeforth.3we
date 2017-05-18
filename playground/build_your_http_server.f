
<comment>

\ ~@~@~@~@~@~@~@~@~ Build Your First HTTP Server in Node.js ~@~@~@~@~@~@~@~@~
\
\ https://www.diigo.com/user/hcchen/b/373115646
\ jeforth.3nw localsotrage field "node.js HTTP server"
\ ~\jeforth.3we\3nd\build_your_http_server.f 
\

\ 為了設定 node_modules 的 path 以供 httpdispatch module 能找得到，
\ 開 DOS box 如下執行 cfg.bat 設定。

	c:\Users\hcche\Documents\GitHub>jeforth.3nw\cfg.bat
	c:\Users\hcche\Documents\GitHub>set NODEJSHOME=C:\Program Files\nodejs
	c:\Users\hcche\Documents\GitHub>set NODE_PATH=C:\Program Files\nodejs\node_modules
	c:\Users\hcche\Documents\GitHub>set NODE_PATH=C:\Program Files\nodejs\node_modules;C:\Program Files\nodejs\node_modules\npm\node_modules

\ 然後如下執行 jeforth.3nw 

	c:\Users\hcche\Documents\GitHub>nw jeforth.3nw nop

\ Note!! debug 時每次重跑都要如上，光 F5 refresh 對 http server 的場合無效。

</comment>

\ Lets require/import the HTTP module and choose a port to listen
    js> require('http') constant http // ( -- HTTP-object ) Get node.js http module

\ Lets define a port we want to listen to
    8080 constant PORT // ( -- port# ) Port number HTTP server listen to
	
\ Your server should respond differently to different URL 
\ paths. This means we need a dispatcher. Dispatcher is kind 
\ of router which helps in calling the desired request handler 
\ code for each particular URL path. Now lets add a dispatcher 
\ to our program. First we will install a dispatcher module, 
\ in our case httpdispatcher. There are many modules available 
\ but lets install a basic one for demo purposes

    <js> 
		var HttpDispatcher = require('httpdispatcher');
		var dispatcher = new HttpDispatcher();dispatcher
	</jsV> constant dispatcher // ( -- obj ) HTTP dispatcher

\ We need a function which handles requests and send response
    <comment>
    <js>
        var f = function handleRequest(request, response){
            response.end('It Works!! Path Hit: ' + request.url);
        };f
    </jsV> constant handleRequest // ( -- func ) Request handler
    </comment>
	
	\ Lets use our dispatcher
    <js>
		var f = function handleRequest(request, response){
			try {
				//log the request on console
				type(request.url+'\n');
				//Disptach
				vm[context].dispatcher.dispatch(request, response);
			} catch(err) {
				type(err+'\n');
			}
		};f
    </jsV> constant handleRequest // ( -- func ) Request handler

	\ Let’s define some routes. Routes define what should 
	\ happen when a specific URL is requested through the 
	\ browser (such as /about or /contact).
	
	\ For all your static (js/css/images/etc.) set the directory name (relative path).
	dispatcher :: setStatic('doc')
	\ dispatcher :: setStatic('playground')

	\ A sample GET request    
	<js>
		var f = function(req, res) {
			res.writeHead(200, {'Content-Type': 'text/plain'});
			res.end('Page One');
		};f
	</jsV> constant get-request // ( -- function ) "Get" request handler
	dispatcher :: onGet("/page1",vm[context]["get-request"])

	
	\ A sample POST request
	<js>
		var f = function(req, res) {
			res.writeHead(200, {'Content-Type': 'text/plain'});
			res.end('Got Post Data');
		};f
	</jsV> dispatcher :: onPost("/post1",pop())
	
\ Callback triggered when server is successfully listening. Hurray!
    <js>
        var f = function callback(){
            type("Server listening on: http://localhost:"+vm[context].PORT);
        }; f
    </jsV> constant server-callback // ( -- func ) Call back function of the HTTP server

\ Create a server
    http :> createServer(vm[context].handleRequest)
    constant server // ( -- obj ) HTTP server object

\ Lets start our server
    server :: listen(vm[context].PORT,vm[context]["server-callback"])

