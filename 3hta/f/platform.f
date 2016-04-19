
\ platform.f for jeforth.3hta
\ KeyCode test page http://www.asquare.net/javascript/tests/KeyCode.html


also forth definitions  \ 本 word-list 太重要，必須放進 root vocabulary。

	\ 用 storage 取代 localStorage 以便在不 support localStorage 的 3HTA 中模擬之。
    js> window.storage==undefined [if] <js>
		window.storage = {};
		storage.all = function(){
			dictate("char 3hta/localstorage.json readTextFile");
				// 3HTA's readTextFile, actually ADO, is asynchronous.
			var ss = pop();
			return ( ss === "" ? undefined : JSON.parse(ss) );
		}
		storage.set = function(key,data){
			var ls = storage.all();
			ls[key] = data;
			push(JSON.stringify(ls));
			dictate("char 3hta/localstorage.json writeTextFile");
		}
		storage.get = function(key){
			dictate("char 3hta/localstorage.json readTextFile");
				// 3HTA's readTextFile, actually ADO, is asynchronous.
			var ss = pop();
			var ls = ss === "" ? undefined : JSON.parse(ss);
			return(ls[key])
		}
		storage.del = function(key){
			var ls = storage.all();
			delete(ls[key]);
			push(JSON.stringify(ls));
			dictate("char 3hta/localstorage.json writeTextFile");
		}
		
	</js> [then]

previous definitions
	
include 3htm/f/platform.f \ 沿用 3htm 的 platform 特性
