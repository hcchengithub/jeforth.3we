
	\ platform.f for jeforth.3hta
	\ KeyCode test page http://www.asquare.net/javascript/tests/KeyCode.html


	also forth definitions  \ 本 word-list 太重要，必須放進 root vocabulary。

	\ 用 storage 取代 localStorage 以便在不 support localStorage 的 3HTA 中模擬之。
	\ 為了讓 localStorage 也能放 object 故看到就要翻成 JSON, 若非 object 則照放, 除
	\ 了 object 都沒問題。 "localStorage" 是 HTA 的保留字, 所以要改成 
	\ window.local_storage 用在 storage.<method> 裡面，外面一律就用 window.storage.<mothods>()
	
    js> window.localStorage==undefined [if] js: window.local_storage={} [then]
    js> window.storage==undefined [if] <js>
		window.storage = {};
		storage.restore = function(pathname){
			// Restore localStorage from the given json file or default localstorage.json
			push(pathname ? pathname : "3nta/localstorage.json");
			execute("readTextFile");
			var ss = pop();
			// if is from 3hta then it's utf-8 with BOM (EF BB BF) that bothers NW.js JSON.parse()
			// ss.charCodeAt(0)==65279 that's utf-8 BOM 
			if (ss.charCodeAt(0)==65279) ss = ss.slice(1); // resolve the utf-8 BOM issue
			var ls = JSON.parse(ss);
			for (var i in ls) localStorage[i] = ls[i];
		}
		storage.save = function(pathname){
			// Save localStorage to the json file or default localstorage.json
			push(JSON.stringify(localStorage)); // entire localStorage string
			push(pathname ? pathname : "3hta/localstorage.json");
			execute("writeTextFile");
		}
		// storage.all = function(){
		// 	dictate("char 3hta/localstorage.json readTextFile");
		// 		// 3HTA's readTextFile, actually ADO, is asynchronous.
		// 	var ss = pop();
		// 	return ( ss === "" ? undefined : JSON.parse(ss) );
		// }
		// storage.set = function(key,data){
		// 	var ls = storage.all(); // entire localStorage
		// 	if(typeof data == "object") {
		// 		ls[key] = JSON.stringify(data);
		// 	} else {
		// 		ls[key] = data; // Assume it's a string
		// 	}
		// 	push(JSON.stringify(ls)); // entire localStorage
		// 	dictate("char 3hta/localstorage.json writeTextFile");
		// }
		// storage.get = function(key){
		// 	dictate("char 3hta/localstorage.json readTextFile");
		// 		// 3HTA's readTextFile, actually ADO, is asynchronous.
		// 	var ss = pop();
		// 	if( ss == "" ) return (undefined); // Local storage can be empty
		// 	var ls = JSON.parse(ss); // the entire local storage
		// 	ss = ls[key];
		// 	if(!ss) return (undefined); // the field is not existing
		// 	try {
		// 		var data = JSON.parse(ss); // The field is an object
		// 	} catch(err) {
		// 		data = ss; // Not an object
		// 	}
		// 	return(data)
		// }
		// storage.del = function(key){
		// 	var ls = storage.all();
		// 	delete(ls[key]);
		// 	push(JSON.stringify(ls));
		// 	dictate("char 3hta/localstorage.json writeTextFile");
		// }
	</js> [then]

	previous definitions
		
	include 3htm/f/platform.f \ 沿用 3htm 的 platform 特性
