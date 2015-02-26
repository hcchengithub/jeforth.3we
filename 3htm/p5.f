
\ I study processing.js  Pomax's guide
\ http://processingjs.org/articles/PomaxGuide.html
\ ~\Dropbox\learnings\processing\Pomax's guide to Processing.js.pdf

include canvas.f

s" p5a.f"			source-code-header

\ Initializations of the default canvas
	0	value timeOutId // ( -- int ) setTimeout() returns the ID, clearTimeout(id) to stop it.
	0	value frameCount // ( -- count ) Serial number of frames
	1	value frameRate // ( -- n ) Re-draw the canvas n times per second
	<js> // 給 setTimeout() 用的 Interval 時間得隨時修正才準。
		var t0,interval,deltaA,deltaB; // static variables。開始時間，動態 interval 時間，觀察兩次偏時間。
		push({
			init: function(){ // Usage: interval :: init()
				// kvm.temp=[]; // <--- 研究電腦速度能到多少，結論是 frameRate 約 60 就已經快滿檔了。
				// kvm.r=[]; // <-- 研究每個 tick 的 now 與理想時間 fc*fi + t0 之間的差距。
				t0 = (new Date()).getTime(); // 單位是 mS JavaScript 既有的 timer 已經很準了
				fortheval('0 to frameCount frameRate'); 
				interval=1000/pop();
				deltaA = deltaB = 0; // 一開始假設時間都是準的。
			}, 
			value: function(){
				var now = (new Date()).getTime(); // 單位是 mS JavaScript 既有的 timer 已經很準了
				execute('frameRate'); var frameInterval = 1000/pop(); // 可以動態被改所以要每次重抓。
				execute('frameCount'); var frameCount = pop();
				deltaA = deltaB;	
				deltaB = frameInterval*frameCount + t0 - now ; // 理想時間從 frameCount 推算而來，優點是絕對正確，伴隨的條件是 frameRate 改了就得重新 interval.init()。
				if(Math.abs(deltaB)>501) {this.init()} // 自動校正，防 debug 時被搞亂。
				if (deltaA*deltaB <= 0 || Math.abs(deltaB) >= Math.abs(deltaA)) 
					// 異號，表示過頭了，或者差距擴大時，都要修正。只有同號且差距縮小時不必修正。
					if(deltaB>0) interval += 1; // 正的表示實際時間落後，表示跑太快了，interval 要加一點。
					else interval = Math.max(interval-1,1);
				// kvm.temp.push(interval); // study
				// kvm.r.push(deltaB); // study
				return(interval);
			}
		})
	</js> constant interval // ( -- obj ) interval.init(), interval.value(), precise dynamic interval time for setTimeout()
	: setFrameRate	( n -- ) \ Frames per second
					to frameRate interval :: init() ;

	createCanvas setWorkingCanvas \ Init default canvas kvm.cv

\ setup
	200 200		setCanvasSize	\ ( width height -- ) 
	60			setFrameRate	\ ( times per second ) 60 已經快到頂了，電腦速度跟不上了。
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
					Math.PI * (pop(1) % tos()) / pop()
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

\ processing.js loop is usually setTimeout() triggered when in interpreter waiting state, rstack.length
\ is supposed to be 1. If triggered in suspending state then rstack.length>1, we have to avoid using the 
\ working rstack by pushing a dummy 0 into rstack so as to return to interpreter waiting state which is
\ where it was from. see (4) below This is very important for any TSR. 

	: processing ( -- ) \ Processing main loop
		[ s" push(function(){inner(" js> last().cfa + s" )})" + </js> ] literal ( -- callBackFunction )
		interval :> value() ( -- callBackFunction interval ) js> setTimeout(pop(1),pop()) to timeOutId
		frameCount 1+ to frameCount 
		[ last ] literal js: tos().cvwas=kvm.cv;kvm.cv=pop().cv \ save 人家的 cv 換成自己的 --- (1)
		draw
		[ last ] literal js: kvm.cv=pop().cvwas \ restore 別人家的 cv ----- (2)
		js> rstack.length 1 > if 0 >r then \ ----------- (4)
		; interpret-only
	last js: pop().cv=kvm.cv \ initial 自己的 cv ------ (3) 
	interval :: init() processing  


	\ 取得 colon word 本身的 cfa 有下列方法 
	\ a）[ js> last().cfa ] literal 即是
	\ b） [ last ] literal :> cfa 同上，這個不 optimize。
	\ c）colon word 裡一見面 js> ip 2- 也是，但有 proprietary 之嫌。

	\ 設定、取得 colon word 本身裡的 static variable 的方法，
	\ : test2 [ last dup js: pop().vv=1111 ] literal js> pop().vv ;

