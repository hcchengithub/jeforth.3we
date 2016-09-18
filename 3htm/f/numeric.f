
	\ numeric.js
	\ http://www.numericjs.com/
	
	s" numeric.f" source-code-header

	s" external modules/numeric/numeric-1.2.6.js"
	\ or from the net directly if is 3htm : char http://www.numericjs.com/lib/numeric-1.2.6.js
	readTextFile \ 先讀取 .js 檔, 但不能直接用
	<text> 
	window.numeric = numeric;  // 先對 source 做一點必要的加工, 把 numeric 掛上 global 
	</text> + </js> \ 然後才執行	

	\ At this point, we have js> window.numeric object already 
	\ or simply js> numeric object which is the same thing.
	\ Try numeric-demo.f 
	