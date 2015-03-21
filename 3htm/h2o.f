
\ h2o.f 
\ Modified from Pile it up! -- is my experiment on processing.js done on 2012
\ http://studio.sketchpad.cc/sp/pad/view/ro.9t-h7h0h5rfdB/rev.160?
\ Now ported to jeforth.3we to see how does it work with forth.

<comment>
	[ ] 有時會亂飛，有時會漸趨平靜，怎麼可能？多出來的動能哪來的，損失到哪去了？
		M1V1+M2V2 = M1V1' + M2V2' 這個公式應該總是守恆的。
		猜想，不論速度快慢，只要是用抽樣方式模擬的，就有可能錯過入射時段，卻看到反射時段。動量的計算
		也許應該會有差異，應該反彈的變成推送，或反之。這可能容易發生在撞擦邊球時。但這個猜想與實驗結
		果不符。水平接近，以45度角碰撞時，第一瞬間就已經不平衡了。想不通，需求教高明。
		
	[x]	a球碰撞後向量 = a球碰撞前 - a球在反作用力線上的分量 + b球在反作用力上的分量 <-- 我想應該是這樣
		A' = A - A.D/|D| + B.D/|D| , A、B分別是兩球向量，D 是球心線由 A 指向 B 的反作用力向量，只方向有意義。
		B' = B - B.D/|D| + A.D/|D| , |D| 是球心距 distance.
		(ax',ay') = (ax,ay) - (ax,ay).(dx,dy)/|(dx,dy)| + (bx,by).(dx,dy)/|(dx,dy)|
		(bx',by') = (bx,by) - (bx,by).(dx,dy)/|(dx,dy)| + (ax,ay).(dx,dy)/|(dx,dy)|
		這樣算正確吧？

	==> 意外發現很好玩的現象，一整沱的球會結合在一起，居然還會旋轉！這是當發現動量不平
		衡時乾脆不做反作用力處理，「不做」意外產生「粘性」，而粘性進而導致團體的旋轉。
		不做事反而產生豐富的效果，妙不可言。
	==> 總動量會一直上升，多出來的應該就是來自上述不平衡的結果。但想不通的是，它居然還
		會自動穩定下來（不是固定下來），莫名其妙！
	
	newBall newBall newBall newBall newBall newBall newBall newBall newBall 
	newBall newBall newBall newBall newBall newBall newBall newBall newBall 
	1 to spring 1 to wallBounce ( 100% 彈性 ) 
	0 to friction 0 to gravity ( 為了做碰撞實驗，去掉重力 )
	800 400 setCanvasSize	\ ( width height -- ) 
	js: kvm.debug=false;g.balls[1].vx=5;g.balls[1].vy=3 \ 初始擾動
	0 value count cut 
	draw total-motivation . space \ 畫一禎印總動量
	count 1+ dup to count 3000 > [if] cls 0 to count [then] \ 避免網頁太長怕 browser 受不了。
	js: jump2endofinputbox.click() 20 nap \ 畫面跳到 inputbox 下，喘口氣讓 browser 工作。
	rewind \ 在 TIB 內重複以上 cut 之後的動作

	==> Name it h2o.f 
	
</comment>

include processing.f

s" h2o.f" source-code-header

marker ~~~
	
\ setup
	20	value interval		// ( -- f ) 調整 frame speed 
	1	value spring 	    // ( -- f ) bounce back force's ratio. 0~1
	0.3	value gravity       // ( -- f ) falling force, increment of y downward distance every frame.
							/// 重力是所有動量的來源。如果彈力指數是 1 摩擦係數是 0 則永遠不會停。
	1	value wallBounce    // ( -- f ) 四周圍牆的材質。超過一變成超強力彈性牆。零就是超級海綿完全吸收任何撞擊。
	0	value friction    	// ( -- f ) 原本想的是摩擦係數、空氣阻力。但若放負值補償不知哪去的動能損失，變得像是加熱溫度！
	0.58 value sticky		// ( -- f ) 動量不平衡的上限，超過就忽略該反作用力，這會造成「粘性」。
	[]	value balls 		// ( -- [] ) 所有的球 is an array。第 0 個不用，因為純 for .. next 不含零。
	800 400	setCanvasSize	\ ( width height -- ) 
	0 lineWidth \ processing.js noStroke() means no outline (balls)
	
	code newBall ( -- ) \ Create a Ball object and add into balls[]
		function Ball(ID,X,Y,RADIUS,COLOR){with(this){
			this.id=ID; // 1,2,... balls.length
			this.x=X; this.y=Y; this.radius=RADIUS; this.color=COLOR; this.vx=0; this.vy=0; 
			this.see = function(){
				print("--- "+id+" --- radius=" + this.radius);
				print(", x=" + x + ", y=" + y);
				print(", vx=" + vx + ", vy=" + vy);
				execute("cr");
			}
			this.collide = function(){
				for (var i = id - 1; i >= 1; i--) {  // 只管自己 id 以下兩兩之間的 collision
					var a=g.balls[id], b=g.balls[i]; // a 是本球 b 是他球。這樣不會搞混。他球是一個個輪著計算的不一定是哪個。
					
					// the distance from this ball to another ball
					var dx = b.x - a.x;  // a.x == x, a.y == y
					var dy = b.y - a.y;  // (dx,dy) 是個向量，本 ball 指向 next ball 的方向跟球心距離。可能已經撞凹了。
					var distance = Math.sqrt(dx*dx + dy*dy);  // |(dx,dy)| 球心距離，碰撞時必有凹陷，所以可小於 minDist, 單位是 pixel
					var minDist = b.radius + a.radius;  // 緊貼兩 ball 的球心距離。 a.radius == radius
					if (distance < minDist) {   // 撞進球體裡面了
						// 本球向量 |(a.vx,a.vy)| 在 (ex,ey) 上的分力是兩者內積 (dot product, inner product) 乘上(ex,ey)
						// fa = [(a.vx,a.vy)。(ex,ey)](ex,ey) = (a.vx*dx/distance + a.vy*dy/distance)(ex,ey)
						//	  = (a.vx*dx/distance + a.vy*dy/distance)(dx/distance,dy/distance)
						//	  = (a.vx*dx + a.vy*dy)/distance(dx,dy)/distance
						//	  = (a.vx*dx + a.vy*dy)(dx,dy)/distance^2
						//	  = (a.vx*dx + a.vy*dy)(dx,dy)/(dx*dx + dy*dy)
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
						var mv1 = Math.sqrt(a.vx*a.vx + a.vy*a.vy); // 碰撞前
						var mv2 = Math.sqrt(b.vx*b.vx + b.vy*b.vy);
						var mv1p = Math.sqrt(avx*avx + avy*avy); // 碰撞後
						var mv2p = Math.sqrt(bvx*bvx + bvy*bvy);
						// 動量守恆嗎？忽略不守恆的情形，相當於交錯而過，互不影響。
						var diff = (mv1+mv2)-(mv1p+mv2p);
if(kvm.debug>2) print("diff="+diff+" "); // [ ]
if(kvm.debug>10){kvm.jsc.prompt='222>>>';eval(kvm.jsc.xt)} // [ ]
						if (Math.abs(diff) < g.sticky) {  // 據實驗觀察，正常情況下動量不平衡似乎皆小於 0.42。
							vx = avx;  // 本球
							vy = avy;  
							g.balls[i].vx = bvx;  // 他球
							g.balls[i].vy = bvy;  
						}
						
					}  
				}     
			}
			this.animate = function(){
				vy += g.gravity;  // 「力」表現為速度、方向的改變，而重力就是在 vy 上加成（加速度==重力）.
								  // vx,vy 是該 ball 的瞬時速度向量，單位是 pixcel/frame 畫素/每禎。
								  // 靜止在地板上時照樣施以重力，往下計算 y+=vy 會陷入地板，再往下計算，撞上地板時
								  // y 又被移回地板上，但得到一個反向(上升)的 -g.gravity 速度。下一 frame 時這個速度被
								  // vy += g.gravity 消除，恢復原狀態。如此不斷重複。靜止的球 vy 會如此震盪，算不算
								  // 是問題？不算。以上是 wallBounce=1 時，當 wallBounce=(0,1)之間，震盪最後 vy 會趨近
								  // 一個負值（往上彈）的附近，但仍繼續震盪。
				vx += vx>0 ? -g.friction : g.friction ; // 扣除摩擦係數, 每 frame 都扣，等於取一個總趨勢。
				vy += vy>0 ? -g.friction : g.friction ;
				vx = Math.abs(vx) < g.friction? 0 : vx ; // 比摩擦力小就是零，否則可能會抖。
				vy = Math.abs(vy) < g.friction? 0 : vy ;
				x += vx;  // 當 vx or vy 大於兩球半徑之合時，一次就直接穿越。這應該是 v 的上限。電腦模擬的限制。
				y += vy;  // 所有的動量都來自 gravity，我猜要計算從上邊落下到下邊的最後速度會不會超過。

				// 如果不考慮牆面，以上就是 move() 了！撞近牆面之前，先預測，並反應。
				// vy *= -g.wallBounce;  撞牆就把分量反向，對呀！？ 但是考慮撞上上邊的情況，反彈之後
				// 開始往下加速度，這樣來回會不會越加越多？好像也不會，從地板彈回來時又都被減回去了。但是
				// 預測到撞牆時，球被直接移置到牆面上，這個處置會不會干擾物理現實？不會，不然才反而會減損
				// 重力加速度落下的距離，因而越彈越低，最後沉沒到地板之下！
				if (x + radius > kvm.cv.canvas.width) {  // 超過 canvas 右邊
					x = kvm.cv.canvas.width - radius;  // 無法超過牆面，位置就在牆面上。
					vx = -Math.abs(vx)*g.wallBounce;               // 牆壁的反彈力
				} else if (x - radius < 0) {   // 超過 canvas 左邊
					x = radius;  
					vx = Math.abs(vx)*g.wallBounce;               // 牆壁的反彈力
				}  
				if (y + radius > kvm.cv.canvas.height) {  // 撞上地板
					y = kvm.cv.canvas.height - radius;  
					vy = -Math.abs(vy)*g.wallBounce;               // 地板的反彈力
				} else if (y - radius < 0) {  // 超過 canvas 上邊
					y = radius;  
					vy = Math.abs(vy)*g.wallBounce;               // 天花板的反彈力
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
			g.balls.length, 	// id
			Math.random()*kvm.cv.canvas.width, // x
			Math.random()*kvm.cv.canvas.height,	// y
			Math.random()*(50-20)+20,			// radius=[20~50]
			(function(){
				var r=60,g=60,b=80,range=50,c="rgba(";
				c += parseInt(Math.random()*r) + ',';
				c += parseInt(Math.random()*g) + ','; // 給 green 優待，偏綠色系。
				c += parseInt(Math.random()*range+b) + ',';
				c += Math.random()*0.45+0.30 + ')';
				return c;
			})()
		));
		end-code

\ draw
	: draw ( -- ) \ Mimic processing's draw() function
		clearCanvas
		js> g.balls.length-1 for r@ ( -- id ) \ where id = numBalls,...,3,2,1 
			balls :: [tos()].collide()
			balls :: [tos()].animate()
			balls :: [pop()].display()
		next
	;
	: dump ( -- ) \ See all balls
		js> g.balls.length-1 for r@ ( -- id ) \ where id = numBalls,...,3,2,1 
			balls :: [pop()].see()
		next
	;
	: total-motivation ( -- f ) \ All |(vx,vy)| summation
		0 ( sum )
		js> g.balls.length-1 for r@ ( -- sum id ) \ where id = numBalls,...,3,2,1 
			balls :> [tos()].vx balls :> [pop(1)].vy dup * swap dup * + 
			js> Math.sqrt(pop()) ( -- sum Mid ) +
		next ;
		/// total-motivation int dup . space 130 > [if] friction 0.001 + [then] to friction 500 nap rewind
		/// total-motivation int dup . space 100 < [if] friction 0.001 - [then] to friction 500 nap rewind
		/// cr 10000 nap rewind
	
\ start to run
	newBall newBall newBall newBall newBall newBall newBall newBall newBall 
	newBall newBall newBall newBall newBall newBall newBall newBall newBall 
	1 to spring 1 to wallBounce ( 100% 彈性 ) 
	0 to friction 0 to gravity ( 為了做碰撞實驗，去掉重力 )
	800 400 setCanvasSize	\ ( width height -- ) 
	js: kvm.debug=false;g.balls[1].vx=5;g.balls[1].vy=3 \ 初始擾動
	0 value count cut 
	draw \ total-motivation . space \ 畫一禎印總動量
	count 1+ dup to count 3000 > [if] cls 0 to count [then] \ 避免網頁太長怕 browser 受不了。
	js: jump2endofinputbox.click() 20 nap \ 畫面跳到 inputbox 下，喘口氣讓 browser 工作。
	rewind \ 在 TIB 內重複以上 cut 之後的動作


