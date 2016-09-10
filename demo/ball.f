
\ I study processing.js  Pomax's guide
\ http://processingjs.org/articles/PomaxGuide.html
\ ~\Dropbox\learnings\processing\Pomax's guide to Processing.js.pdf

\ processing.f 下了功夫使時間精確。 

include processing.f

s" ball.f" source-code-header

\ messages
	: starting-message ( -- ) ." Start bouncing . . ." cr ;
	: ending-message ( -- ) ." Stop bouncing." cr ;

\ setup
	200 200		setCanvasSize	\ ( width height -- ) 
	60			setFrameRate	\ ( times per second ) 60 已經快到頂了，電腦速度跟不上了。
	Infinity	setFrameCountLimit \ ( n -- ) None stop
	1			lineWidth		\ ( n -- )
	s" green" 	strokeStyle		\ ( '#RRGGBB'|'rgb(255,0,0)'|'rgba(255,0,0,0.5)'|'green'  -- ) 
	s" blue"  	fillStyle 		\ ( '#RRGGBB'|'rgb(255,0,0)'|'rgba(255,0,0,0.5)'|'green'  -- ) 
	20 			value ball_radius // ( -- n )
	js> vm.g.cv.canvas.width/2 	value ball_x // ( -- n ) initial ball coordinates
	ball_radius	value ball_y // ( -- n) initial ball coordinates
	0 			value bounce_height // ( -- n ) ball height for this frame
	0			value ball_height // ( -- n )
	
\ draw
	: draw ( -- ) \ Mimic processing's draw() function
		frameCount frameRate <js> 
			vm.g.cv.canvas.height/2 * Math.abs(
				Math.sin( 
					Math.PI * (pop(1) % tos()) / pop()
				)
			)
		</jsV> to bounce_height

		bounce_height ball_radius <js> 
			vm.g.cv.canvas.height - ( pop(1) + pop() )
			// because the top of the screen is 0, and the bottom is "height",
		</jsV> to ball_height 
		clearCanvas beginPath
		ball_height ( int ) to ball_y \ set the new ball y position
		ball_x ball_y ball_radius 0 [ js> Math.PI*2 literal ] false 
		arc ( x y r sAngle eAngle !clockwise -- ) fill 
	;

\ arm
	processing
	
	