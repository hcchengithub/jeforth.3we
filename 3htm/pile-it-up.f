
\ Pile it up! -- is my experiment on processing.js done on 2012
\ http://studio.sketchpad.cc/sp/pad/view/ro.9t-h7h0h5rfdB/rev.160?
\ Now ported to jeforth.3we to see how does it work with forth.

include processing.f

s" pile-it-up.f" source-code-header
true  constant privacy // ( -- true ) All words in this module are private"

\ messages
	: starting-message ( -- )
		." Pile-it-up! start running . . ." cr ;
	: ending-message ( -- ) 
		." Done!" cr ;
	
\ setup

	15 	value numBalls      // ( -- int ) number of Balls
	0.7 value spring 	    // ( -- f ) bounce back force
	0.9 value gravity       // ( -- f ) falling force
	0.9 value wallBounce    // ( -- f ) 四周圍牆的材質。超過一變成超強力彈性牆。零就是超級海綿完全吸收任何撞擊。
	0.4 value friction      // ( -- f ) 摩擦係數
	30  value maxvx         // ( -- n ) 最高速度如果不加限制，惡搞之下有時候會整個失控變成無限高速亂飛一團。
	30  value maxvy         // ( -- n ) 最高速度如果不加限制，惡搞之下有時候會整個失控變成無限高速亂飛一團。
	[]  value balls        // ( -- [] ) 所有的球 is an array。
	
	code newBall ( id x y radius -- Ball ) \ Create a Ball object
		function Ball(ID,X,Y,RADIUS){
			var id=ID, x=X, y=Y, radius=RADIUS, diameter=2*RADIUS, vx=0, vy=0, mousepressed=false;
			this.x = x; this.y = y; this.radius = radius;
			this.collide = function(){
				for (var i = id+1; i <= vm[context].numBalls; i++) {  // 只管自己 id 以後兩兩之間的 collision
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
			this.move = function(){
				if (mousepressed) return;
				vy += vm[context].gravity;  // 「力」表現為位移的幅度，而重力就是在 vy 上加成.  vx,vy 是該 ball 的瞬時向量。
				vx += vx>0 ? -vm[context].friction : vm[context].friction ; // 扣除摩擦係數
				vy += vy>0 ? -vm[context].friction : vm[context].friction ;
				vx = Math.abs(vx) < vm[context].friction? 0 : vx ; // 比摩擦力小就是零，否則會抖。
				vy = Math.abs(vy) < vm[context].friction? 0 : vy ;
				vx = Math.abs(vx) > vm[context].maxvx? vm[context].maxvx*vx/Math.abs(vx) : vx ; // 這啥？ [ ]
				vy = Math.abs(vy) > vm[context].maxvy? vm[context].maxvy*vy/Math.abs(vy) : vy ;
				
				x += vx;  
				y += vy;  
				// 如果不考慮牆面，以上就是 move() 了！
				
				if (x + radius > vm.g.cv.canvas.width) {  // 超過 canvas 右邊
					x = vm.g.cv.canvas.width - radius;  // 無法超過牆面，位置就在牆面上。
					vx *= -vm[context].wallBounce;               // 牆壁的反彈力 [ ] 為何這裡用加的，而下面卻用乘的？ 用加的可能是 typo! 改正之。
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
				vm.g.cv.closePath();
				vm.g.cv.fill();
			}
		};
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
		400 400		setCanvasSize	\ ( width height -- ) 
		60			setFrameRate	\ ( times per second ) 60 已經快到頂了，電腦速度跟不上了。
		Infinity	setFrameCountLimit \ ( n -- )
		0 lineWidth \ processing.js noStroke() means no outline (balls)
		s" green"  	fillStyle 		\ ( " )
		\ create all the balls id=1,2,3...numBalls
			numBalls for r@ ( -- id ) \ where id = numBalls,...,3,2,1 
				js> Math.random()*vm.g.cv.canvas.width	\ x position
				js> Math.random()*vm.g.cv.canvas.height	\ y position
				js> Math.random()*(40-20)+20			\ radius=[40~75]
				balls newBall ( id x y radius balls -- ball ) balls :: unshift(pop())
			next
			balls :: unshift(0)
		\ Arrange event handlers
		\	<js> 
		\		vm.g.cv.canvas.onmouseup   =function(e){if(tick('onmouseup'   )){push(e);execute('onmouseup'   )}};
		\		vm.g.cv.canvas.onmousedown =function(e){if(tick('onmousedown' )){push(e);execute('onmousedown' )}};
		\		vm.g.cv.canvas.onmousemove =function(e){if(tick('onmousemove' )){push(e);execute('onmousemove' )}};
		\		vm.g.cv.canvas.onmouseenter=function(e){if(tick('onmouseenter')){push(e);execute('onmouseenter')}};
		\		vm.g.cv.canvas.onmouseleave=function(e){if(tick('onmouseleave')){push(e);execute('onmouseleave')}};
		\	</js>
	;

\ draw
	: draw ( -- ) \ Mimic processing's draw() function
		clearCanvas
		numBalls for r@ ( -- id ) \ where id = numBalls,...,3,2,1 
			balls :: [tos()].collide()
			balls :: [tos()].move()
			balls :: [pop()].display()
		next
	;
	
		
\ start to run
	\ processing

<comment>
\ 	Pile it up!
\ 
\ 	// 這個盒子裡的球有很大的摩擦力，所以小心一點放，你可以把它們堆高起來。找人來比賽，一人一次，看誰先把球堆到天花板？ 秘訣提示：該你時，如果覺得基礎不穩，不妨先輕輕用一個球來把它們擠穩一點。這樣做事很像高手喔！？
\ 	 
\ 	// 你也可以一起來改下面的程式，讓它更好玩。 歡迎來信 hcchen5600@gmail.com 提供你的意見。  hcchen5600 2012/07/08 12:08:47 
\ 	 
\ 	// 改良 'Balls' from http://studio.sketchpad.cc/sp/pad/view/ro.9yKXNlKdKxFqH/rev.126
\ 	 
\ 	frameRate = 60;
\ 	int numBalls = 15;    //int declares numBalls as 15 (assigning it a value type)
\ 	float spring = 0.7;  //float is a continuous value, 
\ 	float gravity = 0.9;  
\ 	float wallBounce = 0.9;  // original -0.9 , 四周圍牆的材質。超過一變成超強力彈性牆。零就是超級海綿完全吸收任何撞擊。
\ 	float friction = 0.4;   // 我給它加上「摩擦係數」 hcchen5600 2012/07/01 10:38:49 
\ 	float maxvx = 50;  // 最高速度如果不加限制，惡搞之下有時候會整個失控變成無限高速亂飛一團。
\ 	float maxvy = 50;
\ 	Ball[] balls = new Ball[numBalls];  //[] gives you access to the array - variable name[] access  
\ 	 
\ 	void setup()   
\ 	{  
\ 	  size(400, 400);  
\ 	  noStroke();    //means no outline
\ 	  // stroke(#0000FF);     // black ball ID text is not controled by stroke()
\ 	  // smooth();    //all drawn with smooth edges
\ 	 
\ 	  // create all the balls
\ 	  for (int i = 0; i < numBalls; i++) {  
\ 		balls[i] = new Ball(random(width), random(height), random(75, 40), i, balls);  
\ 	  }  
\ 	}  
\ 	 
\ 	// --------------- 單步執行 debug 用的 ----------------------
\ 	int onestep = 0;
\ 	 
\ 	void keyReleased()
\ 	{
\ 	  onestep = 0;
\ 	}
\ 	//-----------------------------------------------------------
\ 	 
\ 	void draw()   
\ 	{  
\ 	  // if (!keyPressed || onestep) return;  // 單步執行 debug 用的 
\ 	  background(35, 89, 35);  
\ 	  for (int i = 0; i < numBalls; i++) {  
\ 		balls[i].collide();  
\ 		balls[i].move();  
\ 		balls[i].display();    
\ 	  }  
\ 	  // onestep = 1; // 單步執行 debug 用的 
\ 	}  
\ 	  
\ 	class Ball {  
\ 	  // 這些是 Ball() 的 properties
\ 	  float x, y;  // position 
\ 	  float diameter;  // 直徑
\ 	  float radius; // 半徑
\ 	  float vx = 0;    // throws  to the right
\ 	  float vy = 0;    // 地心引力方向. 一開始的動量 (vx,vy) 是靜止的。每 frame vy 皆加上 gravity 此呈現為加速度是即地心引力，這麼簡單！
\ 	  int id;  
\ 	  Ball[] others;  // 咦! each Ball has its own image of (all) others. Simply to have the symbol of the array.
\ 	  boolean mousepressed = false;
\ 	   
\ 	  Ball(float xin, float yin, float din, int idin, Ball[] oin) {  
\ 		x = xin;  
\ 		y = yin;  
\ 		diameter = din;  
\ 		radius = diameter / 2; 
\ 		id = idin;  
\ 		others = oin;  
\ 	  }   
\ 		
\ 	  void collide() {  
\ 		for (int i = id + 1; i < numBalls; i++) {  // 不管以前的 ball 只管自己以後兩兩之間的 collision
\ 	 
\ 		  // the distance from this ball to next ball
\ 		  float dx = others[i].x - x;  
\ 		  float dy = others[i].y - y;  
\ 		  float distance = Math.sqrt(dx*dx + dy*dy);  
\ 		  float minDist = others[i].radius + radius;  // 緊貼兩 ball 的球心距離。
\ 	 
\ 		  //println("frameCount is " + frameCount);
\ 		  //for (int j=0; j<numBalls; j++){
\ 		  //  println("Ball" +j+ " diameter=" +others[j].diameter+ " x=" +others[j].x+ " y=" +others[j].y );
\ 		  //}
\ 		  //println("id=" +id+ " i=" +i);
\ 		  //println("distance=" +distance+ " minDist="+minDist);
\ 	 
\ 		  if (distance < minDist) {   // 撞上了！ 當兩球相撞時，總動量不變。
\ 			  float angle = atan2(dy, dx);  // 以本 ball 朝向 next ball 的方向。物理上，到底誰撞誰？應該是對稱平等的。
\ 	 
\ 			// 我覺得不必如此費事算角度、算投影。我覺得 targetX,targetY 不就是 dx,dy 嗎？ 一試結果不對。
\ 			// 首先，(dx,dy) 已經小於 minDist 了，不是個能用的超現實數據。 但是角度應該一致吧？也不對。加上 (x,y) 以後就不然了。
\ 			// 我想 (targetX,targetY) 既然是 (x,y) 加上 (cos(angle)*minDist, sin(angle)*minDist) 那豈不就是跟它相撞的球「當在的位置」了嗎？ 對了！
\ 			
\ 			// (targetX,targetY) 是跟本球相撞的球當在的位置。 目前已經撞進球體裡面來了。
\ 			float targetX = x + cos(angle) * minDist;  // 球心連線在 x 軸上的投影加上 x 即為另一球的 x軸 位置。
\ 			float targetY = y + sin(angle) * minDist;  
\ 	 
\ 			float ax = (targetX - others[i].x) * spring;  // 另一球當在的位置與目前互相撞進球體之內的差距 乘上 彈性係數。方向是另一球該修正的方向。
\ 			float ay = (targetY - others[i].y) * spring;
\ 			vx -= ax;  // 本球該修正的方向與另一球相反。
\ 			vy -= ay;  
\ 	 
\ 			//println("angle=" +angle);
\ 			//println("targetX=" + targetX);
\ 			//println("targetY=" + targetY);
\ 			//println("dx=" +dx);
\ 			//println("dy=" +dy);
\ 			//println("ax=" +ax);
\ 			//println("ay=" +ay);
\ 			//println("vx=" +vx);
\ 			//println("vy=" +vy);
\ 			
\ 			others[i].vx += ax;  
\ 			others[i].vy += ay;  
\ 		  }  
\ 		}     
\ 	  }  
\ 	 
\ 	  // move() 移動球體時，一併考慮計算牆面、地板的反彈。
\ 	  // 把「力」看成 (vx,vy) 即相對於目前位置要改變多少的瞬時位移，分別在兩個座標軸上算出來。「瞬時」使得「速度」與「加速度」都反應為「位移」。
\ 	  // 本來還以為要算反射角、入射角的，根本不必！ 適時把 vx 或 vy 倒向就好了。
\ 	  void move() {
\ 		if (mousepressed) return;
\ 		vy += gravity;  // 由此看出，「力」表現為位移的幅度，而重力就是在 vy 上加成.  vx,vy 是該 ball 的瞬時向量。
\ 		vx += vx>0? -friction : friction ;
\ 		vy += vy>0? -friction : friction ;
\ 		vx = Math.abs(vx)<friction? 0 : vx ;
\ 		vy = Math.abs(vy)<friction? 0 : vy ;
\ 		vx = Math.abs(vx)>maxvx? maxvx*vx/Math.abs(vx) : vx ;
\ 		vy = Math.abs(vy)>maxvy? maxvy*vy/Math.abs(vy) : vy ;
\ 		
\ 		x += vx;  
\ 		y += vy;  
\ 		// 如果不考慮牆面，以上就是 move() 了！
\ 		
\ 		if (x + radius > width) {  // 超過 canvas 右邊
\ 		  x = width - radius;  // 無法超過牆面，位置就在牆面上。
\ 		  vx *= -wallBounce;               // 牆壁的反彈力 [ ] 為何這裡用加的，而下面卻用乘的？ 用加的可能是 typo! 改正之。
\ 		} else if (x - radius < 0) {   // 超過 canvas 左邊
\ 		  x = radius;  
\ 		  vx *= -wallBounce;  
\ 		}  
\ 		if (y + radius > height) {  // 撞上 canvas 地板
\ 		  y = height - radius;  
\ 		  vy *= -wallBounce;   
\ 		} else if (y - radius < 0) {  // 超過 canvas 上邊
\ 		  y = radius;  
\ 		  vy *= -wallBounce;  
\ 		}  
\ 	  }  
\ 		
\ 	  void display() {  
\ 		fill(255, 204);  // specify ball color
\ 		ellipse(x, y, diameter, diameter);  
\ 		fill(0); // specify font color text color 
\ 		text(id, x, y);  
\ 	  }  
\ 	 
\ 	  boolean mouseOver(int mx, int my) {
\ 		return Math.sqrt((x-mx)*(x-mx) + (y-my)*(y-my)) <= radius;  // 勾股弦定理 check if the distance from (x,y) to (mx,my) is less than radius.
\ 	  }
\ 	 
\ 	  boolean mousePressed() {
\ 		if (mouseOver(mouseX,mouseY)){
\ 		  mousepressed = true;
\ 		}
\ 	  }
\ 	 
\ 	  boolean mouseReleased() {
\ 		  mousepressed = false;
\ 	  }
\ 	 
\ 	  boolean mouseDragged() {
\ 		if (mousepressed){
\ 		  x = mouseX;
\ 		  y = mouseY;
\ 		  vx = 0;
\ 		  vy = 0;
\ 		}
\ 	  }
\ 	}  
\ 	 
\ 	// ------------- Balls drag and drop ---------------------------------------
\ 	 
\ 	void mousePressed() {  // This is a callback function
\ 	  for(int i=0, end=balls.length; i<end; i++) {   // 一個個 ball 檢查自己對 mouse pressed 的工作。
\ 		balls[i].mousePressed(); 
\ 	  }
\ 	}
\ 	 
\ 	void mouseReleased() {  // This is a callback function
\ 	  for(int i=0, end=balls.length; i<end; i++) {  // 看到 mouse release 就全 release
\ 		balls[i].mouseReleased();
\ 	  }
\ 	}
\ 	 
\ 	void mouseDragged() { // This is a callback function 
\ 	  for(int i=0, end=balls.length; i<end; i++) {  // mouseDragged() 時也是各自做自己的
\ 		balls[i].mouseDragged();
\ 	  }
\ 	}
</comment>
	 
	 
