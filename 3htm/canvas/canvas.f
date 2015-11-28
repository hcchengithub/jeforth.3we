
\ HTML5 canvas tutorial http://jo2.org/html5-canvas-tutorial-list/
\ HTML5 canvas reference http://www.w3schools.com/jsref/dom_obj_canvas.asp

js> window.HTMLCanvasElement [if]

s" canvas.f"	source-code-header

\ ---------------- Canvas initialization commands -----------------------------------------------
	\ canvas.f 本身不 create 任何 canvas instance，個別程式要自己 create。

	<h> <style type="text/css">canvas{border:solid 1px #CCC}</style>
	</h> constant canvasStyle // ( -- [object HTMLStyleElement] ) Canvas style is globally for all canvases.
							/// See also 'setCanvasStyle' command.
							\ canvasStyle js> pop().parentElement ==> [object HTMLHeadElement]  (object)

	: createCanvas			( -- cv ) \ cv is [object CanvasRenderingContext2D], cv.canvas is the parent object
							char body <e> <canvas width=300 height=300></canvas></e>
							js> pop().getContext('2d') ;
							/// The new canvas is appended to the end of HTML body. 
							/// Use commands e.g. replaceNode, insertBefore, or insertAfter 
							/// to move it to where you want it to be.

	null value cv			// ( -- cv ) The default cv object (CanvasRenderingContext2D)
							/// 即 js> vm.g.cv。引入 default canvas 可以簡化 canvas 操
							/// 作，避免每次都得指定 canvas。若有多個 canvas 必要時用切
							/// 換的，看來還可以。 
	
	code setWorkingCanvas	( [object CanvasRenderingContext2D] -- ) \ Make the given cv be the default canvas.
							vm.g.cv = pop() end-code

	code setCanvasSize		( width height -- )
							vm.g.cv.canvas.width=pop(1);vm.g.cv.canvas.height=pop(); end-code 
							/// Canvas size can be changed dynamically.

	: setCanvasStyle		( "canvas{border:solid 1px #CCC}" -- )
							canvasStyle :: innerHTML=pop() ; 
							/// Canvas style can be changed dynamically. border can be: dashed,solid.

\ ------------------ Drawing commands -------------------------------------------------------

							/// https://www.evernote.com/shard/s22/nl/2472143/21cd4837-e468-468b-b013-56716522dd76
	code save				vm.g.cv.save() end-code // ( -- ) Push canvas settings. 保留座標旋轉、位移、縮放等之前的狀態。
	code restore			vm.g.cv.restore() end-code // ( -- ) Pop canvas settings. 恢復座標旋轉、位移、縮放等之前的狀態。
	code translate			vm.g.cv.translate(pop(1),pop()) end-code // ( x y -- ) Move canvas origin to (x,y)
	code rotate				vm.g.cv.rotate(pop()) end-code // ( angle -- ) 旋轉座標系
	code beginPath			vm.g.cv.beginPath() end-code // ( -- ) Start a new path. http://www.tuicool.com/articles/Bb6RV3
							/// canvas 中的落筆 methods (如 stroke,fill)，都會以上一次 beginPath 之後的所有 path 為基礎下筆。
	code moveTo				vm.g.cv.moveTo(pop(1),pop()) end-code // ( x y -- ) Specify the pen to (x,y), not painted yet
	code lineTo				vm.g.cv.lineTo(pop(1),pop()) end-code // ( x y -- ) Specify a line, not painted yet
	code closePath			vm.g.cv.closePath() end-code // ( -- ) 自動閉合到 path 起點，幾乎與 beginPath 無關。 http://www.tuicool.com/articles/Bb6RV3
	code stroke				vm.g.cv.stroke() end-code // ( -- ) Verb, draw the recent path.
							/// canvas 中的落筆 methods (如 stroke,fill)，都會以上一次 beginPath 之後的所有 path 為基礎下筆。
							/// see also 'fill'

	code lineWidth			vm.g.cv.lineWidth=pop() end-code // ( n -- ) 
	code strokeStyle 		vm.g.cv.strokeStyle=pop() end-code // ( 'style' -- ) Sets or returns the color, gradient, or pattern used for strokes
							/// '#RRGGBB','rgb(255,0,0)','rgba(255,0,0,0.5)' or 'green'

							<selftest>
							*** html5 Canvas畫圖 1px 線條模糊問題
								\ html5 Canvas畫圖3：1px線條模糊問題
								\ http://jo2.org/html5-canvas%E7%94%BB%E5%9B%BE3%EF%BC%9A1px%E7%BA%BF%E6%9D%A1%E6%A8%A1%E7%B3%8A%E9%97%AE%E9%A2%98/
								createCanvas setWorkingCanvas \ To remove the canvas ==> eleBody lastChild removeElement
								100.5 100.5 moveTo	\ ctx.moveTo(100.5,100.5);
								200.5 100.5 lineTo	\ ctx.lineTo(200.5,100.5);
								200.5 200.5 lineTo	\ ctx.lineTo(200.5,100.5);
								100.5 200.5 lineTo	\ ctx.lineTo(200.5,100.5);
								100.5 100.5 lineTo	\ ctx.lineTo(200.5,100.5);
								closePath		\ ctx.closePath();
								1 lineWidth		\ ctx.lineWidth = 1;
								s' rgba(255,0,0,0.5)'
								strokeStyle		\ ctx.strokeStyle = 'rgba(255,0,0,0.5)';
								stroke			\ ctx.stroke();
								[d d] [p "createCanvas","setWorkingCanvas","moveTo","lineTo",
								"closePath","lineWidth","strokeStyle","stroke" p]
							</selftest>
	
	code clearRect			vm.g.cv.clearRect(pop(3),pop(2),pop(1),pop()) end-code // ( x y w h -- ) Clear rectangular
	code fillStyle			vm.g.cv.fillStyle=pop() end-code // ( 'style' -- ) 'color' or Gradient fill style object
	code fill				vm.g.cv.fill() end-code // ( -- ) Verb, fill the recent path
							/// canvas 中的落筆 methods (如 stroke,fill)，都會以上一次 beginPath 之後的所有 path 為基礎下筆。
							/// see also 'stroke'
							
							<selftest>	
							*** lineWidth 加寬可看出效果，減寬若被遮住看不出效果
								clearCanvas beginPath 
								100 100 moveTo 200 50 lineTo stroke 
								\ <js> confirm("clearCanva beginPath 不會清掉已有的 lineWidth strokeStyle 等")</jsV> [if] [else] \s [then]
								1 lineWidth stroke  \ <js> confirm(" lineWidth 都是 1, 看不出效果 ")</jsV> [if] [else] \s [then]
								10 lineWidth stroke \ <js> confirm("lineWidth 加寬可看出效果 ")</jsV>      [if] [else] \s [then]
								5 lineWidth stroke  \ <js> confirm(" lineWidth 減寬看不出效果 ")</jsV>     [if] [else] \s [then]
								char red strokeStyle stroke 
								\ <js> confirm(" path 不變, lineWidth, strokeStyle 與 fillStyle 可隨時改變 ")</jsV> [if] [else] \s [then]
							
								0 0 moveTo 100 100 lineTo 50 150 lineTo stroke
								fill \ black
								\ <js> confirm(" See a black triangle?")</jsV> [if] [else] \s [then]
								char green fillStyle
								fill \ green
								\ <js> confirm(" See a green triangle?")</jsV> [if] [else] \s [then]
								[d d] [p "clearCanvas","beginPath","fill" p]
							</selftest>
							
 	code fillRect			vm.g.cv.fillRect(pop(3),pop(2),pop(1),pop()) end-code // ( x y w h -- ) Fill rectangular
	code fillText			vm.g.cv.fillText(pop(2),pop(1),pop()) end-code // ( 'text' x y -- ) Fill the given text at the given position
	code strokeText			vm.g.cv.strokeText(pop(2),pop(1),pop()) end-code // ( 'text' x y -- ) Stroke (描邊) the given text at the given position
	: clearCanvas			0 0 js> vm.g.cv.canvas.width js> vm.g.cv.canvas.height clearRect ; // ( -- )
	code arc				vm.g.cv.arc(pop(5),pop(4),pop(3),pop(2),pop(1),pop()) end-code // ( x y r sAngle eAngle !clockwise -- )
							/// Example: A circle ==> 100 100 50 0 js> Math.PI*2 false arc stroke
							/// http://www.w3school.com.cn/tags/canvas_arc.asp

							<selftest>
							*** arc 
								100 100 50 0 js> Math.PI*2 false arc stroke
								[d d] [p "arc" p]
							</selftest>

	code createRadialGradient ( x0,y0,r0,x1,y1,r1 -- objStyle ) \ 宣告 style : 圓形漸層色 
							var v=vm.g.cv.createRadialGradient(pop(5),pop(4),pop(3),pop(2),pop(1),pop());
							push(v); end-code
							/// http://www.w3school.com.cn/tags/canvas_createradialgradient.asp
							/// Work with addColorStop(), fillStyle, fillRect, ...etc.
	code createLinearGradient ( x0,y0,x1,y1 -- objGradient ) \ 宣告 style : 線性漸層色 
							var v=vm.g.cv.createLinearGradient(pop(3),pop(2),pop(1),pop());
							push(v); end-code
							/// http://www.w3school.com.cn/tags/canvas_createlineargradient.asp
							/// Work with addColorStop(), fillStyle, fillRect, ...etc.
	code addColorStop		( objGradient stop color -- ) \ stop=[0..1] Specify gradient color.
							pop(2).addColorStop(pop(1),pop()) end-code
							/// http://www.w3school.com.cn/tags/canvas_addcolorstop.asp

							<selftest>
							*** grd Gradient
								\ http://www.w3school.com.cn/tags/canvas_addcolorstop.asp	
								50 50 100 100 createLinearGradient constant grd // ( -- objGradient ) linear gradient area
								grd 0   char black	 addColorStop
								grd 0.3 char magenta addColorStop
								grd 0.5 char blue	 addColorStop
								grd 0.6 char green	 addColorStop
								grd 0.8 char yellow	 addColorStop
								grd 1   char red	 addColorStop
								grd fillStyle
								40 40 60 60 fillRect
								[d d] [p "grd","fillStyle" p]
							</selftest>
							
	code font				( "font" -- ) \ Example: s" 20pt bold Arial" font
							vm.g.cv.font=pop() end-code

	: move-cv-up-into-outputbox	( -- ) \ Move the last thing, expecting a canvas, up into the outputbox.
							eleBody lastChild dup :> constructor==HTMLCanvasElement 
							( ele Boolean ) if else ( ele )
								s" Last thing's constructor is " ( ele "str" ) over 
								( ele "str" ele ) :> constructor ( ele "string" ele.constructor )
								+ s" , are you sure?" + ( ele "confirm" ) js> confirm(pop()) 
								if else drop exit then 
							then
							( ele ) eleDisplay lastChild insertAfter ;

							<selftest>
								move-cv-up-into-outputbox cr
							*** move CV up into outputbox
								[d d] [p "move-cv-up-into-outputbox" p]
							</selftest>
[then] ( window.HTMLCanvasElement [if] )












