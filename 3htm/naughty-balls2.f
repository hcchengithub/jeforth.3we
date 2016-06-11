
\ Pile it up! -- is my experiment on processing.js done on 2012
\ http://studio.sketchpad.cc/sp/pad/view/ro.9t-h7h0h5rfdB/rev.160?
\ Now ported to jeforth.3we to see how does it work with forth.

<comment>
	改寫整個參數的定義。本來都是用絕對值，圖方便以及實驗效果。如今已經證實有效，但發現有些應該是
	比例才對。例如 spring 彈性應該是速度的百分比才自然，如果用絕對值則是亂猜的，也沒有反應瞬時速度。
	結果就是參數很難調。
	[x] 可以用來做物理實驗，用 draw 一次次觀察平面上兩球相撞的逐格變化。先確定無誤之後，再看牆面的
		反彈，等。慢慢確認。
	[x] one ball virticle bouncing is infinit when wallBounce=1 & friction=0, correct. 檢查 dump 值
		無誤， vy 不會越彈越大。
	[x] one ball horizantal bouncing when wallBounce=1 & friction=0，檢查 dump 值，也沒問題。vx 絕對
		值一直固定為設定值。
	***	上面這兩個研究得出心得：要平滑 vx vy 要小，這條件下要飛得快 interval nap 就要小，考驗電腦速度。
		但最快也要 1 nap 否則根本沒時間給機器辦事。
	[x]	Two balls on the floor collision experiment,
		newBall 1 onFloor 2 onFloor 1 to spring 1 to wallBounce ( 100% 彈性 ) 
		0 to friction 0.02 to gravity
		js: vm.g.balls[2].radius=vm.g.balls[1].radius=30 \ same size
		js: vm.g.balls[2].vx=5 \ move one ball
		draw 20 nap rewind \ check 
		Wow! 看到兩球對撞時，動能全部移轉給靜止的一方之實況！（vy=-0.02～0震盪，因為 gravity=0.02，放地板上就是會有微幅震動）
			--- 1 --- radius=32.9509679753981, x=462.04903202460195, y=367.0490320246019, vx=-5, vy=0
			--- 2 --- radius=32.9509679753981, x=391.3990543308095, y=367.0490320246019, vx=0, vy=-0.02
			--- 1 --- radius=32.9509679753981, x=457.04903202460195, y=367.0490320246019, vx=-5, vy=-0.02
		==> --- 2 --- radius=32.9509679753981, x=391.14709607380575, y=367.0490320246019, vx=-0.2519582570037642, vy=0
		==>	--- 1 --- radius=32.9509679753981, x=452.3009902816057, y=367.0490320246019, vx=-4.748041742996236, vy=0
			--- 2 --- radius=32.9509679753981, x=386.14709607380575, y=367.0490320246019, vx=-5, vy=-0.02
			--- 1 --- radius=32.9509679753981, x=452.3009902816057, y=367.0490320246019, vx=0, vy=-0.02
			--- 2 --- radius=32.9509679753981, x=381.14709607380575, y=367.0490320246019, vx=-5, vy=0
			--- 1 --- radius=32.9509679753981, x=452.3009902816057, y=367.0490320246019, vx=0, vy=0
		所以 ball.collide() 正確！
	[ ] 有時會亂飛，有時會漸趨平靜，怎麼可能？多出來的動能哪來的，損失到哪去了？
		M1V1+M2V2 = M1V1' + M2V2' 這個公式應該總是守恆的。但不論速度快慢，只要是用抽樣方式模擬的，就有可能
		錯過入射時段，卻看到反射時段。動量應該會有差異，而且可變大（對撞）或變小（追撞）。取樣錯過入射段的
		可能情形有 a.速度快, b.擦邊。
		==> a球碰撞後向量 = a球碰撞前 - a球在反作用力線上的分量 + b球在反作用力上的分量 
			(ax',ay') = (ax,ay) - (ax,ay).(dx,dy)/|(dx,dy)| + (bx,by).(dx,dy)/|(dx,dy)|
			A' = A - A.D/|D| + B.D/|D| , |D|A' = |D|A - A.D + B.D , 其中 |D| 是球心距 distance 本來就必須。 
			B' = B - B.D/|D| + A.D/|D| , |D|B' = |D|B - B.D + A.D
			A 是A球向量；D 是球心線由 A 指向 B 的反作用力向量，但它只有方向有意義。
		==> 觀察下面這組實驗設計，當 D 與 y軸 夾角越小時，誤差越大。猜想因為這夾角越小越偏向「擦撞」，
			dy 幾等於 distance 而 dx 很小很小，這應該不利於 atan2(dy,dx) 所算出來的角度。(ex,ey) 投影
			又被用了好幾次，很不利。
		==> 實驗結果，上式是對的，但是如果用到 atan2(dy,dx) 經過角度計算誤差（猜想）很大。嘗試直接
			用 D，而不用 d 單位向量。看誤差會不會較小。(HTA)
		==> 改用 Chrome 看看？HTA,Chrome 結果一樣。
	==>	Test	
		newBall newBall newBall 1 to spring 1 to wallBounce ( 100% 彈性 ) 
		0 to friction 0 to gravity ( 為了做碰撞實驗，去掉重力 )
		js: vm.g.balls[1].radius=vm.g.balls[2].radius=50 \ same size
		400 300 setCanvasSize	\ ( width height -- ) 
		js: vm.g.balls[1].x=100;vm.g.balls[1].y=100; \ 擺好位置 
		js: vm.g.balls[2].x=200;vm.g.balls[2].y=101; draw
		js: kvm.debug=true
		js: vm.g.balls[1].vx=1 \ move one ball
		cut draw js: window.scrollTo(0,endofinputbox.offsetTop) 20 nap rewind \ check 
	==> 避免 atan2(dy,dx) 程式要改寫 --> naughty-balls2.f
	==> 改用 45度 角撞撞看 100*Math.cos(45*Math.PI/180)
		newBall newBall newBall 1 to spring 1 to wallBounce ( 100% 彈性 ) 
		0 to friction 0 to gravity ( 為了做碰撞實驗，去掉重力 )
		js: a=vm.g.balls[2];b=vm.g.balls[1]
		js: a.radius=b.radius=50 \ same size
		400 300 setCanvasSize	\ ( width height -- ) 
		js: a.x=100;a.y=100; \ 擺好位置 
		js: b.x=200;b.y=100+(a.radius+b.radius)*Math.cos(45*Math.PI/180);
		js: kvm.debug=false
		js: a.vx=1 \ move one ball
		cut draw js: window.scrollTo(0,endofinputbox.offsetTop) 20 nap rewind \ check 
	==> 意外發現很好玩的現象，一整沱的球會結合在一起，居然還會旋轉！
		newBall newBall newBall newBall newBall newBall newBall newBall newBall 
		newBall newBall newBall newBall newBall newBall newBall newBall newBall 
		1 to spring 1 to wallBounce ( 100% 彈性 ) 
		0 to friction 0 to gravity ( 為了做碰撞實驗，去掉重力 )
		400 400 setCanvasSize	\ ( width height -- ) 
		js: kvm.debug=false;vm.g.balls[1].vx=10
		cut draw js: window.scrollTo(0,endofinputbox.offsetTop) 20 nap rewind \ check 
	==> Name it H2O.f 
</comment>

include processing.f

s" naughty-balls2.f" source-code-header
marker ~~~
	
\ setup
	0.01 constant speed 	// ( -- f ) 調整速度
	20	value interval		// ( -- f ) 調整 frame speed 
	1	value spring 	    // ( -- f ) bounce back force's ratio. 0~1
	0.3	value gravity       // ( -- f ) falling force, increment of y downward distance every frame.
							/// 重力是所有動量的來源。如果彈力指數是 1 摩擦係數是 0 則永遠不會停。
	1	value wallBounce    // ( -- f ) 四周圍牆的材質。超過一變成超強力彈性牆。零就是超級海綿完全吸收任何撞擊。
	0	value friction    	// ( -- f ) 原本想的是摩擦係數、空氣阻力。但若放負值補償不知哪去的動能損失，變得像是加熱溫度！
	[]	value balls 		// ( -- [] ) 所有的球 is an array。第 0 個不用，因為純 for .. next 不含零。
	1200 400	setCanvasSize	\ ( width height -- ) 
	0 lineWidth \ processing.js noStroke() means no outline (balls)
	
	code newBall ( -- ) \ Create a Ball object and add into balls[]
		function Ball(ID,X,Y,RADIUS,COLOR){with(this){
			this.id=ID; // 1,2,... balls.length
			this.x=X; this.y=Y; this.radius=RADIUS; this.color=COLOR; this.vx=0; this.vy=0; 
			this.debug = function(){ debugger; }
			this.see = function(){
				print("--- "+id+" --- radius=" + this.radius);
				print(", x=" + x + ", y=" + y);
				print(", vx=" + vx + ", vy=" + vy);
				execute("cr");
			}
			this.movex = function(xx){ x=xx}
			this.movey = function(yy){ y=yy; }
			this.move = function(xx,yy){ x=xx; y=yy; }
			this.collide = function(){
				for (var i = id - 1; i >= 1; i--) {  // 只管自己 id 以下兩兩之間的 collision
					var a=vm.g.balls[id], b=vm.g.balls[i]; // a 是本球 b 是他球。這樣不會搞混。他球是一個個輪著計算的不一定是哪個。
					
					// the distance from this ball to another ball
					var dx = b.x - a.x;  // a.x == x, a.y == y
					var dy = b.y - a.y;  // (dx,dy) 是個向量，本 ball 指向 next ball 的方向跟球心距離。可能已經撞凹了。
					var distance = Math.sqrt(dx*dx + dy*dy);  // |(dx,dy)| 球心距離，碰撞時必有凹陷，所以可小於 minDist, 單位是 pixel
					var minDist = b.radius + a.radius;  // 緊貼兩 ball 的球心距離。 a.radius == radius
					if (distance < minDist) {   // 撞進球體裡面了
						
						// var angle = Math.atan2(dy, dx);  // 以本 ball 朝向 next ball 的方向。Math.atan2(y,x) 長度換算成角度（徑度）
						// var ex = dx/distance; // 反彈力的單位向量。
						// var ey = dy/distance; 
						
						// 本球向量 |(a.vx,a.vy)| 在 (ex,ey) 上的分力是兩者內積 (dot product, inner product) 乘上(ex,ey)
						// fa = [(a.vx,a.vy).(ex,ey)](ex,ey) = (a.vx*dx/distance + a.vy*dy/distance)(ex,ey)
						//	  = (a.vx*dx/distance + a.vy*dy/distance)(dx/distance,dy/distance)
						var fax = (a.vx*dx*dx + a.vy*dx*dy)/(dx*dx + dy*dy)
						var fay = (a.vx*dx*dy + a.vy*dy*dy)/(dx*dx + dy*dy)

						// fb 則是 the other ball, 另一球在反彈力方向上的投影
						// fb = [(b.vx,b.vy).(ex,ey)](ex,ey) 
						//	  = (b.vx*dx/distance + b.vy*dy/distance)(dx/distance,dy/distance)
						var fbx = (b.vx*dx*dx + b.vy*dx*dy)/(dx*dx + dy*dy); // 他球向量 (b.vx,b.vy) 在 (ex,ey) 上的投影
						var fby = (b.vx*dx*dy + b.vy*dy*dy)/(dx*dx + dy*dy);

						// 到底誰撞誰？應該是對稱平等的。做用力與反作用力 (fx,fy) 分別對雙方各施用一次看似重
						// 複，其實因兩者大小相同、方向相反，因此總動量不變，很合理。
						
						// 本球撞後向量 (a.vx',a.vy') = (a.vx,a.vy)-(fax,fay)+(fbx,fby) 自己的作用給別人，別人的作用給自己，交換作用力。
						// 他球撞後向量 (b.vx',b.vy') = (b.vx,b.vy)-(fbx,fby)+(fax,fay)
						var avx = a.vx - fax + fbx; // 本球最終向量
						var avy = a.vy - fay + fby;  
						var bvx = b.vx - fbx + fax; // 他球最終向量
						var bvy = b.vy - fby + fay;
						// 動量
						var mv1 = Math.sqrt(a.vx*a.vx + a.vy*a.vy);
						var mv2 = Math.sqrt(b.vx*b.vx + b.vy*b.vy);
						var mv1p = Math.sqrt(avx*avx + avy*avy);
						var mv2p = Math.sqrt(bvx*bvx + bvy*bvy);
						// 動量守恆嗎？忽略不守恆的情形，相當於交錯而過，互不影響。
						var diff = (mv1+mv2)-(mv1p+mv2p);
						if (Math.abs(diff) < 0.5) {
						vx = avx;  // 本球
						vy = avy;  
						vm.g.balls[i].vx = bvx;  // 他球
						vm.g.balls[i].vy = bvy;  
						}
						
					}  
				}     
			}
			this.animate = function(){
				vy += vm.g.gravity;  // 「力」表現為速度、方向的改變，而重力就是在 vy 上加成（加速度==重力）.
								  // vx,vy 是該 ball 的瞬時速度向量，單位是 pixcel/frame 畫素/每禎。
								  // 靜止在地板上時照樣施以重力，往下計算 y+=vy 會陷入地板，再往下計算，撞上地板時
								  // y 又被移回地板上，但得到一個反向(上升)的 -vm.g.gravity 速度。下一 frame 時這個速度被
								  // vy += vm.g.gravity 消除，恢復原狀態。如此不斷重複。靜止的球 vy 會如此震盪，算不算
								  // 是問題？不算。以上是 wallBounce=1 時，當 wallBounce=(0,1)之間，震盪最後 vy 會趨近
								  // 一個負值（往上彈）的附近，但仍繼續震盪。
				vx += vx>0 ? -vm.g.friction : vm.g.friction ; // 扣除摩擦係數, 每 frame 都扣，等於取一個總趨勢。
				vy += vy>0 ? -vm.g.friction : vm.g.friction ;
				vx = Math.abs(vx) < vm.g.friction? 0 : vx ; // 比摩擦力小就是零，否則可能會抖。
				vy = Math.abs(vy) < vm.g.friction? 0 : vy ;
				// vx = Math.abs(vx) > vm.g.maxvx? vm.g.maxvx*vx/Math.abs(vx) : vx ;
				// vy = Math.abs(vy) > vm.g.maxvy? vm.g.maxvy*vy/Math.abs(vy) : vy ;
				x += vx;  // 當 vx or vy 大於兩球半徑之合時，一次就直接穿越。這應該是 v 的上限。電腦模擬的限制。
				y += vy;  // 所有的動量都來自 gravity，我猜要計算從上邊落下到下邊的最後速度會不會超過。

				// 如果不考慮牆面，以上就是 move() 了！撞近牆面之前，先預測，並反應。
				// vy *= -vm.g.wallBounce;  撞牆就把分量反向，對呀！？ 但是考慮撞上上邊的情況，反彈之後
				// 開始往下加速度，這樣來回會不會越加越多？好像也不會，從地板彈回來時又都被減回去了。但是
				// 預測到撞牆時，球被直接移置到牆面上，這個處置會不會干擾物理現實？不會，不然才反而會減損
				// 重力加速度落下的距離，因而越彈越低，最後沉沒到地板之下！
				if (x + radius > vm.g.cv.canvas.width) {  // 超過 canvas 右邊
					x = vm.g.cv.canvas.width - radius;  // 無法超過牆面，位置就在牆面上。
					vx = -Math.abs(vx)*vm.g.wallBounce;               // 牆壁的反彈力
				} else if (x - radius < 0) {   // 超過 canvas 左邊
					x = radius;  
					vx = Math.abs(vx)*vm.g.wallBounce;               // 牆壁的反彈力
				}  
				if (y + radius > vm.g.cv.canvas.height) {  // 撞上地板
					y = vm.g.cv.canvas.height - radius;  
					vy = -Math.abs(vy)*vm.g.wallBounce;               // 地板的反彈力
				} else if (y - radius < 0) {  // 超過 canvas 上邊
					y = radius;  
					vy = Math.abs(vy)*vm.g.wallBounce;               // 天花板的反彈力
				}  
				// vx vy 要設限
				// if (Math.abs(vx)>radius) vx = radius*Math.abs(vx)/vx;
				// if (Math.abs(vy)>radius) vy = radius*Math.abs(vy)/vy;
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
		vm.g.balls.push(new Ball(
			vm.g.balls.length, // id
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
		js> vm.g.balls.length-1 for r@ ( -- id ) \ where id = numBalls,...,3,2,1 
			balls :: [tos()].collide()
			balls :: [tos()].animate()
			balls :: [pop()].display()
		next
	;
	: draw2 ( -- ) \ Just draw w/o collide animate and clearCanvas
		js> vm.g.balls.length-1 for r@ ( -- id ) \ where id = numBalls,...,3,2,1 
			balls :: [pop()].display()
		next
	;
	: drawOne ( n -- ) \ Mimic processing's draw() function
		clearCanvas
		balls :: [tos()].collide()
		balls :: [tos()].animate()
		balls :: [pop()].display()
	;
	: dump ( -- ) \ See all balls
		js> vm.g.balls.length-1 for r@ ( -- id ) \ where id = numBalls,...,3,2,1 
			balls :: [pop()].see()
		next
	;
	: runOne ( n count -- ) \ balls[n] drawOne count times
		for dup drawOne 20 nap next drop ;
	: run ( count -- ) \ draw count times
		for draw speed nap next ;
	: home ( -- ) \ move all balls to (0,0)
		js> vm.g.balls.length-1 for r@ ( -- id ) \ where id = numBalls,...,3,2,1 
			balls :: [pop()].move(0,0)
		next ;
	: onFloor ( id -- ) \ move the ball still on the floor
		js: vm.g.balls[tos()].move(vm.g.balls[tos()].x,vm.g.cv.canvas.height-vm.g.balls[tos()].radius)
		js: vm.g.balls[tos()].vx=0
		js: vm.g.balls[pop()].vy=0 ;
	: freeze ( -- ) \ freeze all balls
		js> vm.g.balls.length-1 for r@ ( -- id ) \ where id = numBalls,...,3,2,1 
			balls :: [tos()].vx=0
			balls :: [pop()].vy=0
		next ;
	: total-motivation ( -- f ) \ All |(vx,vy)| summation
		0 ( sum )
		js> vm.g.balls.length-1 for r@ ( -- sum id ) \ where id = numBalls,...,3,2,1 
			balls :> [tos()].vx balls :> [pop(1)].vy dup * swap dup * + 
			js> Math.sqrt(pop()) ( -- sum Mid ) +
		next ;
		/// total-motivation int dup . space 130 > [if] friction 0.001 + [then] to friction 500 nap rewind
		/// total-motivation int dup . space 100 < [if] friction 0.001 - [then] to friction 500 nap rewind
		/// cr 10000 nap rewind

	
\ start to run
newBall newBall newBall newBall newBall
newBall newBall newBall newBall newBall
js: vm.debug=true [begin] draw interval nap [again] 



