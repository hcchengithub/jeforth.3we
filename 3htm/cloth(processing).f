
\ Re-produce an old processing.js demo
\ 重現經典範例，畫出美麗的布料圖案。

include processing.f

s" cloth.f"	source-code-header

\ messages
	: starting-message ( -- )
		." Start . . . " ;
	: ending-message ( -- ) 
		." Done!" cr ;
	
\ setup
	600 300	setCanvasSize	\ ( width height -- ) 
	15		setFrameRate	\ ( times per second ) 60 已經快到頂了，電腦速度跟不上了。
	130		setFrameCountLimit \ ( n -- ) we don't run it infinitly
	40		lineWidth		\ ( n -- )
	100		value r			// ( -- int ) Red 
	200		value g	 		// ( -- int ) green 
	200		value b			// ( -- int ) blue
	55		value range		// ( -- int ) Range of colour variation
	90		value d			// ( -- int ) Drifting distance of the 2nd point
	
\ draw
	: draw ( -- ) \ Mimic processing's draw() function
		beginPath
		char rgba( 
		r js> Math.random()*pop() int + char ,  +
		g js> Math.random()*pop() int + char ,  +
		b range js> Math.random()*pop()+pop() int + char ,  + \ 給 blue 優待，偏藍色系。
		js> Math.random() + char )  +
		( .s jsc ) strokeStyle
		js> Math.random()*(vm.g.cv.canvas.width+100)-50 dup >r 0 moveTo \ 上邊某一點，比 canvas 兩邊各超出 50，比較自然。
		r> d js> Math.random()*tos()-pop()*0.5+pop() js> vm.g.cv.canvas.height lineTo \ 下邊某一點是上一點偏移的結果。
		stroke
	;

\ start to run
	processing

\ The End

