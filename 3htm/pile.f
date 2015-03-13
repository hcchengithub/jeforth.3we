
\ Pile it up! -- is my experiment on processing.js done on 2012
\ http://studio.sketchpad.cc/sp/pad/view/ro.9t-h7h0h5rfdB/rev.160?
\ Now ported to jeforth.3we to see how does it work with forth.

include processing.f

\ s" pile-it-up.f" source-code-header
marker ~~~

\ messages
	: starting-message ( -- )
		." Pile-it-up! start running . . ." cr ;
	: ending-message ( -- ) 
		." Done!" cr ;
	
\ setup

	15  value numBalls      // ( -- int ) number of Balls
	0.5 value spring 	    // ( -- f ) bounce back force
	0.9 value gravity       // ( -- f ) falling force
	0.6 value wallBounce    // ( -- f ) 四周圍牆的材質。超過一變成超強力彈性牆。零就是超級海綿完全吸收任何撞擊。
	0.06 value friction      // ( -- f ) 摩擦係數
	50  value maxvx         // ( -- n ) 最高速度如果不加限制，惡搞之下有時候會整個失控變成無限高速亂飛一團。
	50  value maxvy         // ( -- n ) 最高速度如果不加限制，惡搞之下有時候會整個失控變成無限高速亂飛一團。
	[]  value balls        // ( -- [] ) 所有的球 is an array。
	
	code newBall ( id x y radius others -- Ball ) \ Create a Ball object
		function Ball(ID,X,Y,RADIUS,OTHERS){with(this){
			this.id=ID; this.x=X; this.y=Y; this.radius=RADIUS; this.vx=0; this.vy=0;
			var others=OTHERS, diameter=2*RADIUS, mousepressed=false;
			this.debug = function(){ debugger; }
			this.see = function(){
				print("--- "+id+" --- radius=" + this.radius);
				print(", x=" + x + ", y=" + y);
				print(", radius=" + radius);
				print(", vx=" + vx + ", vy=" + vy);
				print("\n");
			}
			this.move = function(xx,yy){ x=xx; y=yy; }
			this.collide = function(){
				for (var i = id - 1; i >= 1; i--) {  // 只管自己 id 以後兩兩之間的 collision
					// the distance from this ball to another ball
					var dx = others[i].x - x;  
					var dy = others[i].y - y;  
					var distance = Math.sqrt(dx*dx + dy*dy);  // 碰撞時的球心距離，有凹陷，所以可小於 minDist
					var minDist = others[i].radius + radius;  // 緊貼兩 ball 的球心距離。
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
					
						var ax = (targetX - others[i].x) * g.spring;  // 另一球當在的位置與目前互相撞進球體之內的差距 乘上 彈性係數。方向是另一球該修正的方向。
						var ay = (targetY - others[i].y) * g.spring;
						vx -= ax;  // 本球該修正的方向與另一球相反。
						vy -= ay;  

						others[i].vx += ax;  
						others[i].vy += ay;  
					}  
				}     
			}
			this.animate = function(){
				if (mousepressed) return;
				vy += g.gravity;  // 「力」表現為位移的幅度，而重力就是在 vy 上加成.  vx,vy 是該 ball 的瞬時向量。
				vx += vx>0 ? -g.friction : g.friction ; // 扣除摩擦係數
				vy += vy>0 ? -g.friction : g.friction ;
				vx = Math.abs(vx) < g.friction? 0 : vx ; // 比摩擦力小就是零，否則會抖。
				vy = Math.abs(vy) < g.friction? 0 : vy ;
				vx = Math.abs(vx) > g.maxvx? g.maxvx*vx/Math.abs(vx) : vx ; // 這啥？ [ ]
				vy = Math.abs(vy) > g.maxvy? g.maxvy*vy/Math.abs(vy) : vy ;
				
				x += vx;  
				y += vy;  
				// 如果不考慮牆面，以上就是 move() 了！
				
				if (x + radius > kvm.cv.canvas.width) {  // 超過 canvas 右邊
					x = kvm.cv.canvas.width - radius;  // 無法超過牆面，位置就在牆面上。
					vx *= -g.wallBounce;               // 牆壁的反彈力 [ ] 為何這裡用加的，而下面卻用乘的？ 用加的可能是 typo! 改正之。
				} else if (x - radius < 0) {   // 超過 canvas 左邊
					x = radius;  
					vx *= -g.wallBounce;  
				}  
				if (y + radius > kvm.cv.canvas.height) {  // 撞上 canvas 地板
					y = kvm.cv.canvas.height - radius;  
					vy *= -g.wallBounce;   
				} else if (y - radius < 0) {  // 超過 canvas 上邊
					y = radius;  
					vy *= -g.wallBounce;  
				}  
			}
			this.display = function(){
				kvm.cv.beginPath();
				kvm.cv.arc (x, y, radius, 0, Math.PI*2, false);
				kvm.cv.fill(); 
				// fill(0); // specify font color text color 
				// text(id, x, y);  
			}
		}};
		push(new Ball(pop(4),pop(3),pop(2),pop(1),pop()));
		end-code
	
	\ Event handlers
	: onmousedown ( -- ) \ This is a Callback-Function
		numBalls for r@ ( -- id ) \ where id = numBalls,...,3,2,1 
			balls :: [pop()].mousePressed()
		next ;
	 
	: onmouseup ( -- ) \ This is a Callback-Function
		\ 看到 mouse release 就全 release
		numBalls for r@ ( -- id ) \ where id = numBalls,...,3,2,1 
			balls :: [pop()].mouseReleased()
		next ;
	 
	: onmousemove ( -- ) \ This is a Callback-Function
		\ 即 processing.js 的 mouseDragged() ，也是各自做自己的
		numBalls for r@ ( -- id ) \ where id = numBalls,...,3,2,1 
			balls :: [pop()].mouseDragged()
		next ;
	: onmouseenter onmouseup ; // ( -- ) This is a Callback-Function
	: onmouseleave onmouseup ; // ( -- ) This is a Callback-Function
	
	: setup ( -- ) \ Mimic the processing.js' setup section
		1200 400		setCanvasSize	\ ( width height -- ) 
		60			setFrameRate	\ ( times per second ) 60 已經快到頂了，電腦速度跟不上了。
		Infinity	setFrameCountLimit \ ( n -- )
		0 lineWidth \ processing.js noStroke() means no outline (balls)
		s" green"  	fillStyle 		\ ( " )
		\ create all the balls id=1,2,3...numBalls
			numBalls for r@ ( -- id ) \ where id = numBalls,...,3,2,1 
				js> Math.random()*kvm.cv.canvas.width	\ x position
				js> Math.random()*kvm.cv.canvas.height	\ y position
				js> Math.random()*(55-10)+10			\ radius=[10~55]
				balls newBall ( id x y radius balls -- ball ) balls :: unshift(pop())
			next
			balls :: unshift(0)
		\ Arrange event handlers
			\ <js> 
			\  kvm.cv.canvas.onmouseup   =function(e){if(tick('onmouseup'   )){push(e);execute('onmouseup'   )}};
			\  kvm.cv.canvas.onmousedown =function(e){if(tick('onmousedown' )){push(e);execute('onmousedown' )}};
			\  kvm.cv.canvas.onmousemove =function(e){if(tick('onmousemove' )){push(e);execute('onmousemove' )}};
			\  kvm.cv.canvas.onmouseenter=function(e){if(tick('onmouseenter')){push(e);execute('onmouseenter')}};
			\  kvm.cv.canvas.onmouseleave=function(e){if(tick('onmouseleave')){push(e);execute('onmouseleave')}};
			\ </js>
	;

\ draw
	: draw ( -- ) \ Mimic processing's draw() function
		clearCanvas
		numBalls for r@ ( -- id ) \ where id = numBalls,...,3,2,1 
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
		numBalls for r@ ( -- id ) \ where id = numBalls,...,3,2,1 
			balls :: [pop()].see()
		next
	;
	: runOne ( n count -- ) \ balls[n] drawOne count times
		for dup drawOne 20 nap next drop ;
	: run ( count -- ) \ draw count times
		for draw 20 nap next ;
		
\ start to run
	js: tib=tib.slice(ntib);ntib=0
	setup 500 run js: ntib=0


