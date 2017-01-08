
\ Pile it up! -- is my experiment on processing.js done on 2012
\ http://studio.sketchpad.cc/sp/pad/view/ro.9t-h7h0h5rfdB/rev.160?
\ Now ported to jeforth.3we to see how does it work with forth.

include processing.f

s" blowing-in-the-wind.f" source-code-header

true constant privacy private // ( -- true ) All words in this module are private
marker ~~~
	
\ setup
	0.01 constant speed // ( -- f ) 調整速度
	30	value interval		// ( -- f ) slow motion or fast motion
	20  value numBalls      // ( -- int ) number of Balls
	0.4 speed * value spring 	    // ( -- f ) bounce back force
	1	speed * value gravity       // ( -- f ) falling force
	3   speed * value wallBounce    // ( -- f ) 四周圍牆的材質。超過一變成超強力彈性牆。零就是超級海綿完全吸收任何撞擊。
	-0.01 value friction      // ( -- f ) 摩擦係數
	50  value maxvx         // ( -- n ) 最高速度如果不加限制，惡搞之下有時候會整個失控變成無限高速亂飛一團。
	50  value maxvy         // ( -- n ) 最高速度如果不加限制，惡搞之下有時候會整個失控變成無限高速亂飛一團。
	[]	value balls 		// ( -- [] ) 所有的球 is an array。第 0 個不用，因為純 for .. next 不含零。
	1200 400	setCanvasSize	\ ( width height -- ) 
	0 lineWidth \ processing.js noStroke() means no outline (balls)
	
	code newBall ( -- ) \ Create a Ball object and add into balls[]
		function Ball(ID,X,Y,RADIUS,COLOR){with(this){
			this.id=ID; this.x=X; this.y=Y; this.radius=RADIUS; this.color=COLOR;
			this.vx=0; this.vy=0; 
			this.debug = function(){ debugger; }
			this.see = function(){
				type("--- "+id+" --- radius=" + this.radius);
				type(", x=" + x + ", y=" + y);
				type(", radius=" + radius);
				type(", vx=" + vx + ", vy=" + vy);
				type("\n");
			}
			this.move = function(xx,yy){ x=xx; y=yy; }
			this.collide = function(){
				for (var i = id - 1; i >= 1; i--) {  // 只管自己 id 以後兩兩之間的 collision
					// the distance from this ball to another ball
					var dx = vm[context].balls[i].x - x;  
					var dy = vm[context].balls[i].y - y;  
					var distance = Math.sqrt(dx*dx + dy*dy);  // 碰撞時的球心距離，有凹陷，所以可小於 minDist
					var minDist = vm[context].balls[i].radius + radius;  // 緊貼兩 ball 的球心距離。
					if (distance < minDist) {   // 撞上了！ 當兩球相撞時，總動量不變。
						var angle = Math.atan2(dy, dx);  // 以本 ball 朝向 next ball 的方向。Math.atan2(y,x) 長度換算成角度（徑度）
						// 到底誰撞誰？應該是對稱平等的。
					
						// 我覺得不必如此費事算角度、算投影。我覺得 targetX,targetY 不就是 dx,dy 嗎？ 一試結果不對。
						// 首先，(dx,dy) 已經小於 minDist 了，不是個能用的超現實數據。 但是角度應該一致吧？也不對。
						// 加上 (x,y) 以後就不然了。我想 (targetX,targetY) 既然是 (x,y) 加上 (cos(angle)*minDist, 
						// sin(angle)*minDist) 那豈不就是跟它相撞的球「當在的位置」了嗎？ 對了！
						
						// (targetX,targetY) 是跟本球相撞的球當在的位置。 目前已經撞進球體裡面來了。
						var targetX = x + Math.cos(angle) * minDist;  // 球心連線在 x 軸上的投影加上 x 即為另一球的 x軸 位置。
						var targetY = y + Math.sin(angle) * minDist;  
					
						var ax = (targetX - vm[context].balls[i].x) * vm[context].spring;  // 另一球當在的位置與目前互相撞進球體之內的差距 乘上 彈性係數。方向是另一球該修正的方向。
						var ay = (targetY - vm[context].balls[i].y) * vm[context].spring;
						vx -= ax;  // 本球該修正的方向與另一球相反。
						vy -= ay;  

						vm[context].balls[i].vx += ax;  
						vm[context].balls[i].vy += ay;  
					}  
				}     
			}
			this.animate = function(){
				vy += vm[context].gravity;  // 「力」表現為位移的幅度，而重力就是在 vy 上加成.  vx,vy 是該 ball 的瞬時向量。
				vx += vx>0 ? -vm[context].friction : vm[context].friction ; // 扣除摩擦係數
				vy += vy>0 ? -vm[context].friction : vm[context].friction ;
				vx = Math.abs(vx) < vm[context].friction? 0 : vx ; // 比摩擦力小就是零，否則會抖。
				vy = Math.abs(vy) < vm[context].friction? 0 : vy ;
				// vx = Math.abs(vx) > vm[context].maxvx? vm[context].maxvx*vx/Math.abs(vx) : vx ;
				// vy = Math.abs(vy) > vm[context].maxvy? vm[context].maxvy*vy/Math.abs(vy) : vy ;
				x += vx;  
				y += vy;  
				// 如果不考慮牆面，以上就是 move() 了！
				
				if (x + radius > vm.g.cv.canvas.width) {  // 超過 canvas 右邊
					x = vm.g.cv.canvas.width - radius;  // 無法超過牆面，位置就在牆面上。
					vx *= -vm[context].wallBounce;               // 牆壁的反彈力
				} else if (x - radius < 0) {   // 超過 canvas 左邊
					x = radius;  
					vx *= -vm[context].wallBounce;  
				}  
				if (y + radius > vm.g.cv.canvas.height) {  // 撞上 canvas 地板
					y = vm.g.cv.canvas.height - radius;  
					vy *= -vm[context].wallBounce;   
				} else if (y - radius < 0) {  // 超過 canvas 上邊
					y = radius;  
					vy *= -vm[context].wallBounce;  
				}  
			}
			this.display = function(){
				vm.g.cv.beginPath();
				vm.g.cv.arc (x, y, radius, 0, Math.PI*2, false);
				vm.g.cv.fillStyle=color;
				vm.g.cv.fill(); 
				// fill(0); // specify font color text color 
				// text(id, x, y);  
			}
		}};
		vm[context].balls.push(new Ball(
			vm[context].balls.length, // id
			Math.random()*vm.g.cv.canvas.width, // x
			Math.random()*vm.g.cv.canvas.height,	// y
			Math.random()*(50-20)+20,			// radius=[20~50]
			(function(){
				var r=120,g=80,b=60,range=55,c="rgba(";
				c += parseInt(Math.random()*r) + ',';
				c += parseInt(Math.random()*g) + ','; // 給 green 優待，偏綠色系。
				c += parseInt(Math.random()*range+b) + ',';
				c += Math.random()*0.5+0.5 + ')';
				return c;
			})()
		));
		end-code

\ draw
	: draw ( -- ) \ Mimic processing's draw() function
		clearCanvas
		js> vm[context].balls.length-1 for r@ ( -- id ) \ where id = numBalls,...,3,2,1 
			balls :: [tos()].collide()
			balls :: [tos()].animate()
			balls :: [pop()].display()
		next
	;
	: drawOne ( n -- ) \ Mimic processing's draw() function
		clearCanvas beginPath
		balls :: [tos()].collide()
		balls :: [tos()].animate()
		balls :: [pop()].display()
		fill
	;
	: dump ( -- ) \ See all balls
		js> vm[context].balls.length-1 for r@ ( -- id ) \ where id = numBalls,...,3,2,1 
			balls :: [pop()].see()
		next
	;
	: runOne ( n count -- ) \ balls[n] drawOne count times
		for dup drawOne 20 nap next drop ;
	: run ( count -- ) \ draw count times
		for draw speed nap next ;
	: trigger ( -- ) \ move all balls up 
		js> vm[context].balls.length-1 for r@ ( -- id ) \ where id = numBalls,...,3,2,1 
			balls :: [pop()].move(0,0)
		next ;
	
\ start to run
	newBall newBall newBall newBall newBall
	newBall newBall newBall newBall newBall
	newBall newBall newBall newBall newBall
	cut draw interval nap rewind \ cut...rewind TIB 不斷重複

	

