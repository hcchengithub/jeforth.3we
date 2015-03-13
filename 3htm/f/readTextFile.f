
	\	[ ] 人家說用 jQuery 是 over kill, 直接用 http 值得探討，
	\	http://stackoverflow.com/questions/247483/http-get-request-in-javascript

	\	$.get() 有 cache 的現象，在 IE 特別嚴重，根本不去讀新版！
	\	http://stackoverflow.com/questions/367786/prevent-caching-of-ajax-call
	\	http://stackoverflow.com/questions/10610034/jquery-get-caching-working-too-well
	\	I choose the global setting as my solution : $.ajaxSetup({cache:false})
	js: $.ajaxSetup({cache:false})

	\ : old-getTextFile	( "pathname" -- string ) \ "" if file not found
	\ 	js> pop().replace(/^\s*|\s*$/g,'') \ remove white spaces ( -- pathname )
	\ 	<js>
	\ 		var f = $.get(pop(),'text'); // callback only when success, not suitable because readTextFileAuto try-n-error. 
	\ 		(function run(){
	\ 			if (f.state()=="pending") 
	\ 				mySetTimeout(run,100); 
	\ 			else {
	\ 				if (f.status==200) push(f.responseText); 
	\ 				else push(""); 
	\ 				execute("stopSleeping");
	\ 			}
	\ 		})();
	\ 	</js>
	\ 	120000 sleep \ 聽說過 typical 要等兩分鐘
	\ 	\ [ ] 太早回來目前不知如何是好。
	\ 	;
	
	: getTextFile	( "pathname" -- string ) \ "" if file not found
		<js> 
			var pathname = pop().replace(/^\s*|\s*$/g,''); // remove white spaces
			$.get(pathname, function(data){
				push(data); // 成功，傳回讀到的檔案
				// alert('Success reading '+pathname);
			}).fail(function(){
				push(""); // 失敗，傳回 ""
				// alert('Failed reading '+pathname);
			}).always(function() {
				execute("stopSleeping");
				// alert('End of reading '+pathname);
			})
		</js>
		120000 sleep \ 聽說過 typical 要等兩分鐘。[ ] 若還不夠而太早回來目前不知如何是好。
		;

	\ Replace instead of redefine, because it has been used.
	js: tick('readTextFile').cfa=tick('getTextFile').cfa
	js: tick('readTextFile').type=tick('getTextFile').type
	js: tick('readTextFile').xt=tick('getTextFile').xt

	
	
	