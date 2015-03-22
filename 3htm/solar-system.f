
\ solar-system.f for jeforth.3we

<comment>
	＝＝ 物理定律、公式 ＝＝
	F = m1.a = G(m1.m2)/r^2  // m1 is planet's mass, G=9.81, m2 is the sun's mass. a 是太陽施加於行星的「重力加速度」。
	a = G.m2/r^2 = gravity/r^2  // G and m2 are both constants therefore merged into gravity.
	r = |(rx,ry)| // (rx,ry) is a vector from the planet to the sun
	  = |(sun.x,sun.y)-(p.x,p.y)|  // p is a planet
	  = |rx=sun.x-p.x, ry=sun.y-p.y|
	  = Math.sqrt(rx*rx,ry*ry)
	(ex,ey) = (rx,ry)/r // 由 planet 指向 the sun 的 unit vector
	a(ex,ey) // 行星朝向太陽的重力加速度向量
	  = (gravity/r^2)(rx/r,ry/r)
	aex = gravity*rx/r^3  // a(ex,ey) 在 x 座標上的分量
	aey = gravity*ry/r^3  // a(ex,ey) 在 y 座標上的分量
	p.vx += aex  // 行星的瞬時速度：每 frame 都加上「重力加速度」, x 分量
	p.vy += aey  // 行星的瞬時速度：每 frame 都加上「重力加速度」, y 分量

	＝＝ 可以下的命令 ＝＝
	balls :> [1].r 100 < [if]  ." 一號行星接近太陽了" stop [then] 10 nap rewind \ 監視器。一號行星接近時系統暫停以便觀察數據。
	balls :> [1].r balls :> [1].radius balls :> [0].radius + < [if] ." 一號行星撞上太陽了" stop [then] 10 nap rewind \ 監視器。
	balls :> [1].r . \ ==> 55.00161016347886 查看與太陽的球心距離
	balls :> [1].vx . space balls :> [1].vy . cr ==> 62.05511125127198 22.80213651293407 \ 查看一號行星速度向量。
	balls :> [1].x . space balls :> [1].y . cr ==> 62.05511125127198 22.80213651293407 \ 查看一號行星位置。
	( 讓太陽左右來回移動 ) js: e=d=0.5 cut js: h=g.balls[0].x+=e js> h>=(kvm.cv.canvas.width-kvm.cv.canvas.height/2) [if] js: e=-d [then] js> h<=kvm.cv.canvas.height/2 [if] js: e=d [then] 50 nap rewind
	balls :: [1].vx=3 \ 往右輕推一號行星一把，故意擾動它的路線。
	balls :: [1].color='red' \ 改一號行星的顏色。
	balls :: [1].radius=10 \ 改一號行星的大小。
</comment>

include processing.f

s" solar-system.f" source-code-header

marker ~~~
	
\ setup
	20	value interval		// ( -- f ) 調整 frame speed 
	2000 value gravity       // ( -- f ) falling force, increment of y downward distance every frame.
	0	value friction		// ( -- f ) 負的摩擦力好像有「加溫」的效果。
	[]	value balls 		// ( -- [] ) 所有的球 is an array。第 0 個不用，因為純 for .. next 不含零。
	1200 400	setCanvasSize	\ ( width height -- ) 
	0 lineWidth \ processing.js noStroke() means no outline (balls)
	
	code newBall ( -- ) \ Create a Ball object and add into balls[]
		function Ball(X,Y,VX,VY,RADIUS,COLOR){with(this){
			this.x=X; this.y=Y; 
			this.vx=VX; this.vy=VY; 
			this.radius=RADIUS; 
			this.color=COLOR;
			this.aex = this.aey = 0; // 重力加速度
			this.see = function(id){
				print("-- " + id + " -- ");
				print("radius=" + this.radius);
				print(", x=" + x + ", y=" + y);
				print(", vx=" + vx + ", vy=" + vy);
				execute("cr");
			}
			this.collide = function(){
				var sun=g.balls[0], p=this; // sun 是太陽 p 是本行星
				p.rx = sun.x-p.x; // (rx,ry) 是 planet 指向 the sun 的向量
				p.ry = sun.y-p.y;
				p.r = Math.sqrt(rx*rx + ry*ry);
				// 當距離很近時重力加速度會變成無限大，所以若行星進入到太陽的範圍就要另外
				// 想個規定，因為已經撞上了，與行星軌道無關，我可以自由規定此後的物理。
				if ( p.r > p.radius + sun.radius ) {
					p.aex = g.gravity*rx/(r*r*r) // 行星朝向太陽的重力加速度向量
					p.aey = g.gravity*ry/(r*r*r)
				} else {
					// 撞上太陽後的物理學可以自己規定
					// p.aex = p.rx/p.r; p.aey = p.ry/p.r; 	// gravity=1
					// p.aex = 0; p.aey = 0; 				// gravity=0
					p.radius = 0; 							// destroy
				}
			}
			this.animate = function(){
				vx += aex; // 速度是加上去的，所以叫「加速度」
				vy += aey;
				vx += vx>0 ? -g.friction : g.friction ; // 扣除摩擦係數, 每 frame 都扣，等於取一個總趨勢。
				vy += vy>0 ? -g.friction : g.friction ;
				x += vx;  // 當 vx or vy 大於兩球半徑之合時，一次就直接穿越。這應該是 v 的上限。電腦模擬的限制。
				y += vy;  // 所有的動量都來自 gravity，我猜要計算從上邊落下到下邊的最後速度會不會超過。

				// 如果不考慮牆面，以上就是 move() 了！
				if (x - radius > kvm.cv.canvas.width) {  // 整個行星都超過 canvas 右邊
					// x = -radius;  // 從左邊出現。
					vx /= 10; // 跑出視野的就偷偷把它減速
				} else if (x + radius < 0) {   // 超過 canvas 左邊
					// x = radius + kvm.cv.canvas.width;  
					vx /= 10; // 跑出視野的就偷偷把它減速
				}  
				if (y - radius > kvm.cv.canvas.height) {  // 撞上地板
					// y = -radius;  
					vy /= 10; // 跑出視野的就偷偷把它減速
				} else if (y + radius < 0) {  // 超過 canvas 上邊
					// y = radius + kvm.cv.canvas.height;  
					vy /= 10; // 跑出視野的就偷偷把它減速
				}  
			}
			this.display = function(){
				kvm.cv.beginPath();
				kvm.cv.arc (x, y, radius, 0, Math.PI*2, false);
				kvm.cv.fillStyle=color;
				kvm.cv.fill(); 
			}
		}};
		g.balls.push(new Ball(
			// 遞補湮滅的行星，從外面進來，才不會突然出現很唐突
			(g.balls.length>4) ? Math.random()*30 + kvm.cv.canvas.width : Math.random()*kvm.cv.canvas.width,  // x
			(g.balls.length>4) ? Math.random()*30 + kvm.cv.canvas.height : Math.random()*kvm.cv.canvas.height,	// y
			Math.random()*5-2.5, // vx
			Math.random()*5-2.5, // vy
			Math.random()*(30-10)+10,			// radius=[10~30]
			(function(){ // color
				var r=60,g=60,b=80,range=50,c="rgba(";
				c += parseInt(Math.random()*r) + ',';
				c += parseInt(Math.random()*g) + ',';
				c += parseInt(Math.random()*range+b) + ',';
				c += Math.random()*0.45+0.30 + ')';
				return c;
			})()
		));
		end-code

\ draw
	: draw ( -- ) \ Mimic processing's draw() function
		clearCanvas
		balls :: [0].display() \ The sun
		js> g.balls.length-1 for r@ ( -- id ) \ where id = numBalls,...,3,2,1 
			balls :: [tos()].collide()
			balls :: [tos()].animate()
			balls :: [pop()].display()
		next
		js> g.balls.length-1 for r@ ( -- id ) \ where id = numBalls,...,3,2,1 
			\ 垃圾清理撞進太陽湮滅掉的行星，換一個新的上去
			balls :> [tos()].radius if drop else balls :: splice(pop(),1) newBall then
		next
	;
	: dump ( -- ) \ See all balls
		js> g.balls.length-1 for r@ ( -- id ) \ where id = numBalls,...,3,2,1 
			balls :: [tos()].see(pop())
		next
		balls :: [0].see()
	;
	: total-momentum ( -- f ) \ All |(vx,vy)| summation
		0 ( sum )
		js> g.balls.length-1 for r@ ( -- sum id ) \ where id = numBalls,...,3,2,1 
			balls :> [tos()].vx balls :> [pop(1)].vy dup * swap dup * + 
			js> Math.sqrt(pop()) ( -- sum Mid ) +
		next ;
		/// total-momentum int dup . space 130 > [if] friction 0.001 + [then] to friction 500 nap rewind
		/// total-momentum int dup . space 100 < [if] friction 0.001 - [then] to friction 500 nap rewind
		/// cr 10000 nap rewind
	
\ start to run
	newBall newBall newBall newBall newBall newBall \ 太陽 行星
	balls :: [0].radius=40 \ the Sun
	js: g.balls[0].vx=0;g.balls[0].vy=0; \ 太陽靜止
	js: g.balls[0].x=200;g.balls[0].y=200 \ 太陽放在左邊、中央。
	js: g.balls[0].color="rgba(255,166,47,0.6)";g.balls[0].display() \ 太陽的顏色，金色 http://www.computerhope.com/htmcolor.htm
	cls .( 一度孤獨的太陽在太空中慢慢捕獲它的五顆行星，過 ) cr
	    .( 程可能要半小時，期間很多都撞進太陽裡湮滅了。。。。 ) cr
	cut draw 20 nap rewind
	
