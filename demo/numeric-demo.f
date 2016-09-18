
	\ numeric-demo.js
	\ http://www.numericjs.com/
	
	\ Load external modules
	include flot.f
	include numeric.f
	
    \ prepare sin wave dot array [[x0,y0],[x1,y1], ...]
		js> numeric.linspace(0,10,25) ( x ) \ the X-axis array
		js> numeric.sin(tos()) ( x y ) \ the Y-axis array where y=sin(x)
		js> numeric.transpose([pop(1),pop()]) ( [[x0,y0],[x1,y1], ...] ) \ sin wave for flot.js

    \ Plot the above sin wave 
		\ Prepare the Flot ploting zone
		cls ' flotzone [if] [else]
			<o> <div class=flotzone></div></o> constant flotzone // ( -- DIV ) Place for Flot plotings avoid CSS conflict.
			flotzone js> $(".console3we")[0] insertBefore
		[then] 
        \ Create the placeholder
		flotzone
        <o> <div id="sinwave" style="width:600px;height:300px"></div></o> ( sinwave )
        appendChild

        \ Plot the sin wave through flot.js 
		js: $.plot($("#sinwave"),[pop()],{yaxis:{max:1.5}})
