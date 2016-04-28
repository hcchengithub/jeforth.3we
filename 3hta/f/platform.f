
\ platform.f for jeforth.3hta
\ KeyCode test page http://www.asquare.net/javascript/tests/KeyCode.html


also forth definitions  \ 本 word-list 太重要，必須放進 root vocabulary。

	\ 用 storage 取代 localStorage 以便在不 support localStorage 的 3HTA 中模擬之。
	\ 為了讓 localStorage 也能放 object 故看到就要翻成 JSON, 若非 object 則照放, 除了 object 都沒問題。
	\ set() 新 field 會自動產生, 不必先 new(), 故沒有 new()。
	
    js> window.storage==undefined [if] <js>
		window.storage = {};
		storage.all = function(){
			dictate("char 3hta/localstorage.json readTextFile");
				// 3HTA's readTextFile, actually ADO, is asynchronous.
			var ss = pop();
			return ( ss === "" ? undefined : JSON.parse(ss) );
		}
		storage.set = function(key,data){
			var ls = storage.all(); // entire localStorage
			if(typeof data == "object") {
				ls[key] = JSON.stringify(data);
			} else {
				ls[key] = data; // Assume it's a string
			}
			push(JSON.stringify(ls)); // entire localStorage
			dictate("char 3hta/localstorage.json writeTextFile");
		}
		storage.get = function(key){
			dictate("char 3hta/localstorage.json readTextFile");
				// 3HTA's readTextFile, actually ADO, is asynchronous.
			var ss = pop();
			if( ss == "" ) return (undefined); // Local storage can be empty
			var ls = JSON.parse(ss); // the entire local storage
			ss = ls[key];
			if(!ss) return (undefined); // the field is not existing
			try {
				var data = JSON.parse(ss); // The field is an object
			} catch(err) {
				data = ss; // Not an object
			}
			return(data)
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
