
	\ numeric.js
	\ http://www.numericjs.com/
	
	\ Get the plotter 
	include flot.f
	
	s" numeric.f" source-code-header

	s" external modules/numeric/numeric-1.2.6.js"
	\ or from the net directly if is 3htm : char http://www.numericjs.com/lib/numeric-1.2.6.js
	readTextFile \ 先讀取 .js 檔, 但不能直接用
	<text> 
	window.numeric = numeric;  // 先對 source 做一點必要的加工, 把 numeric 掛上 global 
	</text> + </js> \ 然後才執行	

	\ At this point, we have js> window.numeric object already 
	\ or simply js> numeric object which is the same thing.
	
    \ prepare sin wave dot array [[x0,y0],[x1,y1], ...]
		js> numeric.linspace(0,10,25) ( x ) \ the X-axis array
		js> numeric.sin(tos()) ( x y ) \ the Y-axis array where y=sin(x)
		js> numeric.transpose([pop(1),pop()]) ( [[x0,y0],[x1,y1], ...] ) \ sin wave for flot.js

    \ Plot the above sin wave 
        \ Create the placeholder
        flotzone
        <o> <div id="sinwave" style="width:600px;height:300px"></div></o> ( sinwave )
        appendChild

        \ Plot the sin wave through flot.js 
		js: $.plot($("#sinwave"),[pop()],{yaxis:{max:1.5}})
