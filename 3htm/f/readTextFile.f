
	: getTextFile	( "pathname" -- string ) \ "" if file not found
		js> pop().replace(/^\s*|\s*$/g,'') \ remove white spaces ( -- pathname )
		<js>
			var f = $.get(pop(),'text'); // callback only when success, not suitable, 
			(function run(){
				if (f.state()=="pending") 
					setTimeout(run,100); 
				else {
					if (f.status==200) push(f.responseText); 
					else push(""); 
					execute("stopSleeping");
				}
			})();
		</js>
		10000 sleep
		;

	\ Replace instead of redefine, because it has been used.
	js: tick('readTextFile').cfa=tick('getTextFile').cfa
	js: tick('readTextFile').creater=tick('getTextFile').creater
	js: tick('readTextFile').xt=tick('getTextFile').xt

	\	$.get() 有 cache 的現象，在 IE 特別嚴重，根本不去讀新版！
	\	http://stackoverflow.com/questions/367786/prevent-caching-of-ajax-call
	\	http://stackoverflow.com/questions/10610034/jquery-get-caching-working-too-well
	\	I choose the global setting as my solution : $.ajaxSetup({cache:false})
	js: $.ajaxSetup({cache:false})
	
	
	