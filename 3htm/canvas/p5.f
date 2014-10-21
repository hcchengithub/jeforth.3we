
\ I study processing.js  Pomax's guide
\ http://processingjs.org/articles/PomaxGuide.html

include canvas.f

s" p5.f"			source-code-header

\ Initializations of the default canvas
	0	value frameCount // ( -- count ) Serial number of frames
	50 	value frameInterval // ( -- mS ) Re-draw the canvas every interval mS.
	20 	value frameRate // ( -- n ) Re-draw the canvas n times per second
	: setFrameRate	( n -- ) \ Frames per second
					to frameRate
					1000 frameRate / to frameInterval ;
					/// See also frameInterval
	createCanvas setWorkingCanvas \ Init default canvas kvm.cv

\ setup
	200 200		setCanvasSize	\ ( width height -- ) 
	60			setFrameRate	\ ( times per second )
	1			lineWidth		\ ( n -- )
	s" green" 	strokeStyle		\ ( '#RRGGBB'|'rgb(255,0,0)'|'rgba(255,0,0,0.5)'|'green'  -- ) 
	s" blue"  	fillStyle 		\ ( " )
	20 						value ball_radius // ( -- n )
	js> kvm.cv.canvas.width/2 	value ball_x // ( -- n ) initial ball coordinates
	ball_radius				value ball_y // ( -- n) initial ball coordinates
	0 						value bounce_height // ( -- n ) ball height for this frame
	0						value ball_height // ( -- n )
\ draw
	: draw ( -- ) \ Mimic processing's draw() function
		frameCount frameRate <js> 
			kvm.cv.canvas.height/2 * Math.abs(
				Math.sin( 
					Math.PI * pop(1) / pop()
				)
			)
		</jsV> to bounce_height

		bounce_height ball_radius <js> 
			kvm.cv.canvas.height - ( pop(1) + pop() )
			// because the top of the screen is 0, and the bottom is "height",
		</jsV> to ball_height 
		clearCanvas beginPath
		ball_height ( int ) to ball_y \ set the new ball y position
		ball_x ball_y ball_radius 0 [ js> Math.PI*2 ] literal false 
		arc ( x y r sAngle eAngle !clockwise -- ) fill 
	;

\ processing.js loop
	: processing ( -- ) \ Processing main loop
		[ s" push(function(){inner(" js> last().cfa + s" )})" + jsEvalNo ] literal ( -- callBackFunction )
		frameInterval [ s" push(function(){setTimeout(pop(1),pop())})" jsEvalNo , ]
		frameCount 1+ to frameCount draw
	; 
last execute
	\ 取得 colon word 本身的 cfa 有兩法 
	\ 1）[ js> last().cfa ] literal 即是
	\ 2）colon word 裡一見面 js> ip 2- 也是，但有 proprietary 之嫌。
