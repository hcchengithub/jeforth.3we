
\ 	Webserver.f
\
\	Original README
\		https://gist.github.com/rpflorence/701407
\		Node.JS static file web server. Put it in your path to fire up servers in any 
\		directory, takes an optional port argument.
\
\	    ------ Check out this comment on the Github site ---------
\		Consider also python -m SimpleHTTPServer 888 
\		or twistd -n web -p 8888 --path .. 
\		The former is installed pretty much anywhere where there's Python, 
\		the latter is better performing and is bundled with many distributions 
\		including Mac OSX - no need for pasting/downloading another file.
\ 
\	Windows jeforth.3nd README -- hcchen5600 2014/10/19 17:36:20 
\		I port it to jeforth.3nd by modify nearly nothing. Except the argv order.
\		It works on jeforth.3nd and jeforth.3nw.
\
\		Usage: ~\jeforth.3we\node.exe jeforth.3nd.js include webserver.f 8888
\			   ~\jeforth.3we\nw ../jeforth.3we include webserver.f 8888
\
\	本來是現成 JavaScript 的程式改成 forth 有啥好處？如下例，可以把任何變數拉出來
\	隨時觀察，
\		push(filename); fortheval("to filename"); <== in the callback function of http.createServer
\	更厲害的是 jeforth.3nd 有 cd dir 等 dos command 所以 cd 既可以查看 working directory
\	或稱 root directory 又可以任意改變它。讚! 讚! 讚!

	0 value request
	0 value response
	0 value uri
	0 value filename
	0 value err
	0 value file
	0 value path
	0 value fs
	
	<js>
	var http = require("http"),
		url = require("url"),
		path = require("path"),
		fs = require("fs")
		port = process.argv[3] || 8888; // for jeforth.3nd it's argv[3]

	push(path); fortheval("to path");
	push(fs); fortheval("to fs");
	 
	http.createServer(function(request, response) {
		push(response); fortheval("to response"); push(request); fortheval("to request");
		var uri = url.parse(request.url).pathname, 
		    filename = path.join(process.cwd(), uri);
		push(uri); fortheval("to uri"); push(filename); fortheval("to filename");
	  
		fs.exists(filename, function(exists) {
			if(!exists) {
				response.writeHead(404, {"Content-Type": "text/plain"});
				response.write("404 Not Found\n");
				response.end();
				return;
			}
		 
			// 不會當成 directory 處理，不加這行會出錯 "Error: EISDIR, read"
			if (fs.statSync(filename).isDirectory()) filename += '/index.html';
			push(filename); fortheval("to filename");
		 
			fs.readFile(filename, "binary", function(err, file) {
				push(err); fortheval("to err"); push(file); fortheval("to file");	
				if(err) {        
					response.writeHead(500, {"Content-Type": "text/plain"});
					response.write(err + "\n");
					response.end();
					return;
				}
				response.writeHead(200);
				response.write(file, "binary");
				response.end();
			});
		});
	}).listen(parseInt(port, 10));
	switch(kvm.appname){
		case "jeforth.3nw":
			print("Static file server running at\n  => http://localhost:" + port);
			break;
		case "jeforth.3nd":
			console.log("Static file server running at\n  => http://localhost:" + port);
			break;
	}
	</js>
	



