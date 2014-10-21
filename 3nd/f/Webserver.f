
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
\
\		Usage: d:\jeforth\node.exe jeforth.3nd.js include webserver.f 888
\

	<js>
	var http = require("http"),
		url = require("url"),
		path = require("path"),
		fs = require("fs")
		port = process.argv[3] || 8888; // for jeforth.3nd it's argv[3]
	 
	http.createServer(function(request, response) {
	 
	  var uri = url.parse(request.url).pathname
		, filename = path.join(process.cwd(), uri);
	  
	  path.exists(filename, function(exists) {
		if(!exists) {
		  response.writeHead(404, {"Content-Type": "text/plain"});
		  response.write("404 Not Found\n");
		  response.end();
		  return;
		}
	 
		if (fs.statSync(filename).isDirectory()) filename += '/index.html';
	 
		fs.readFile(filename, "binary", function(err, file) {
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
	 
	console.log("Static file server running at\n  => http://localhost:" + port + "/\nCTRL + C to shutdown");
	</js>
	



