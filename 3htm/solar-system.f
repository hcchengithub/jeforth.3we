
\ solar-system.f for jeforth.3we

<comment>

	jeforth.3we 模擬行星軌道，蠻好玩的：
	
		http://figtaiwan.org/project/jeforth/jeforth.3we-master/index.html?include solar-system.f

	談電腦

	特別說明，jeforth (或 jsForth?) 都是 event driven 的系統（有別於傳統的 win32Forth.exe 或 DOS 
	時代的 eforth.com ）。這什麼意思？這表示，每一行從 forth console 下達的命令（即 TIB）就是一個
	活生生的 "event handler", 處理本身這行 TIB.那又怎樣？一般下達 ." Hello World!!" cr 做完就沒有
	了，回到 forth console 去 idle 則與傳統無異。但若下達 ." Hello World!!" cr 50 sleep 0 #TIB ! 
	則形成一迴路，就會變成常駐程式。其中 50 sleep 讓出 50 mS 的時間給別人用，這很重要，否則 forth
	thread 就會吃掉所有的時間，當機。 0 #TIB ! 是我為了方便同好理解舉的示意例。實際上請用 rewind 
	命令。 see rewind 可見其定義正是個執行 ntib=0 的 function 與示意同義。而 sleep 改用 nap 原因恕
	略。讓出來的這 50 mS 時間使得 jeforth (jsForth) console 又專心地聆聽你的下一個命令。畫面上還不
	斷印著 ."Hello World!!" cr 好像沒它的事一般。

	因此，上述行星軌道模擬程式並沒有「主程式」，而是  draw 20 nap rewind 一行程式，或可稱為 forth 
	console event handler。這樣用有麻煩，打字較多；也有好處，控制靈活有趣，且少定義一個呆板的主程
	式。更可以不斷下達更多行 forth console event handler 製造效果。例如以上 URL 執行起來就是個太陽
	系的模擬動畫，該太陽是靜止不動的。我們可以另外下達一個不斷 rewind 的 TIB line 讓它去微調太陽的
	位置，使其左右來回移動，如下：

		( 讓太陽左右來回移動 ) js: e=d=0.5 cut js: h=g.stars[0].x+=e 
		js> h>=(kvm.cv.canvas.width-kvm.cv.canvas.height/2) [if] js: e=-d [then] 
		js> h<=kvm.cv.canvas.height/2 [if] js: e=d [then] 50 nap rewind ( rewind
		回到 cut 之後重複執行，50 nap 交還控制權給 host 休息 50 mS 之後回來繼續。
		太陽一動起來，行星維持繞日公轉而不焚毀或飛走就越加困難了。 )

	此後就有了兩個「常駐程式」不斷執行，前一個負責太陽系動畫模擬行星軌道；後一個移動太陽慢慢左右來
	回。各做各的事。可輸入 stop 命令把所有「常駐程式」都停掉（即停掉所有 TIB loop) 或照 Windows 的
	慣例 Ctrl-Break 也可以，有時候程式‘寫得不好 inputbox 上不了手，有 Ctrl-Break 很好。
	
	談物理、數學、天體

	數學，只用到高中向量；物理只用到兩條公式 f=G(m1xm2)/r^2 跟著名的 f=ma。但問題不在這裡，問題是
	宇宙真的非常非常遼闊，寫這個模擬時如果事先沒有概念一定會很困惑、挫折。幸好我看過 Discovery channel 
	介紹太陽系時形容：如果太陽是足球場中央的一顆籃球，那麼火星是場邊一顆綠豆（這還好），很快地球已
	經在球場外的街上了，而外環的海王星、天王星之類的軌道則得打計程車跳表好多好多次才到得了。即使縮
	小到電腦畫面上，中央畫一顆太陽，然後咱們就會無聊到爆。因為眾行星將會照縮小比例分佈到螢幕之外，
	到隔壁菜市場去了 ── 根本看不到！

	所以要作弊，沒有人願意坐在電腦前面等著看行星，一等好幾十分鐘看不到一顆。一顆來了，又與太陽擦身
	而過，絕大部分都這樣。有的終於進入繞日公轉了，又大部分撞進太陽裡焚毀。真正被太陽捕獲為行星而能
	長久繞日公轉的，少之又少。

	我的辦法是：在畫面外偷偷動手腳，每禎畫面都把畫布外的行星運動速度縮小十倍成 (vx/10, vy/10) 其中
	(vx, vy) 是該行星的運動速度向量。這樣一來就可以把時間縮小到可以忍受的範圍，連行星軌道也被縮小到
	畫面之內。沒有任何一顆亂數產生的行星會飛走了，因為一飛出螢幕（畫布）之外就會變慢，然後就會被太
	陽拉回來。即使過程很緩慢，也只在幾分鐘之內而已。

	至於那些撞毀在太陽裡的犧牲者也有所補償，每當有一個行星撞毀，就有一顆被亂數產生。但地點在畫面之外
	，所以它會受太陽引力慢慢拉進到畫面裡來。可以用 newStar 命令多加幾顆行星，也可以把行星的半徑改成 
	0 隨後它就會被回收湮滅掉。

	請多指教，希望您也覺得好玩。

	陳厚成 敬上

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

	
</comment>

include processing.f

vocabulary solar-system.f also solar-system.f definitions

marker ~~~
	
\ setup
	20	value interval		// ( -- f ) 調整 frame speed 
	2000 value gravity       // ( -- f ) falling force, increment of y downward distance every frame.
	0	value friction		// ( -- f ) 負的摩擦力好像有「加溫」的效果。
	30 value maxPlanet		// ( -- n ) Maximum radius of a planet 
	1200 400	setCanvasSize	\ ( width height -- ) 
	0 lineWidth \ processing.js noStroke() means no outline (balls)
	
\ 建立 stars array 以及 star 專屬的 properties, methods.
	
	[] value stars // ( -- [] ) The stars array
	0 value istar // ( -- index ) The current star of the solar system. Word 裡用到 istar 都要 save-restore.
	: to ( n <value> -- ) \ A proprietory 'to' command that assigns n to a 'star.property'.
		' ( n word ) 
		js> tos().type!="star.property" ?abort" Error! Assigning to a none star.property."
		compiling if ( n word ) 
			<js> var s='var f;f=function(){/* to star.property */ g.stars[g.istar]["'+pop().name+'"]=pop()}';push(eval(s))</js> ( f ) ,
		else ( n word )
			js: g.stars[g.istar][pop().name]=pop()
		then ; immediate
		/// 以下要用 Function Overloading 的手法把專為 'star.property' 寫就的這個 'to' command 加
		/// 回原 'to' 使它能處理多種 type。

	: to ( n <Var> -- ) \ Function Overloadingly assign n to a 'value' or a 'star.property' variable.
		#tib ' ( #tib word ) \ 在 compiling 時先偷看下一個 word,
		js> tos().type=="value" if ( #tib word ) \ 判斷它的 type 
			drop #tib! forth [compile] to exit \ 確定 type 之後選定正確的 'to' （forth [compile] to 
			\ 所留下的）緊接著上手做這個 definition 真正的工作，'to' 自己會判斷 state 故這樣就可以了。
		then
		js> tos().type=="star.property" if ( #tib word )
			drop #tib! solar-system.f [compile] to exit
		then
		abort" Error! 'to' neither a 'star.property' nor a 'value'."
		; immediate
		///     這個 Function Overloaded 'to' 命令可有可無。有則免去需正確切換 vocabulary 的麻煩
		/// 跟隱憂；無則用切換 vocabulary 的方式指定是哪個 'to' 亦可。Overloading 手法自動分辨隨
		/// 後的 value's type 是哪一種來採用對應的 'to', 其中回吐 #tib 的妙法大成功，使 immediate 
		/// word 在兩個 state 都運作正常。
		///     不管哪個 'to' 都是 immediate word, Function overloaded 'to' 經臨時判斷後執行正確
		///	的 （forth to） 或 （solar-system.f to）亦即以整個 word 來執行另一個 word，這方法應該
		/// 很有用吧！

	: property ( <name> -- ) \ Create a property of a stars[istar]
		BL word (create) <js> 
		last().type = "star.property";
		var s = 'var f;f=function(){push(g.stars[g.istar]["' 
				+ last().name 
				+ '"])}';
		last().xt = eval(s);
		// g.stars[g.istar][last().name] = undefined;
		</js> reveal ;
		/// A property is a global variable but pointed by a common index, istar.
		/// Like 'value', use 'to' to assign data into a property. You may need to use 
		/// a vocabulary selector to specify the correct 'to' to use unless they've 
		/// been organized into a compound 'to' command as we've done above. 
		/// Initial value of a property is undefined. You always need to create an 
		/// instance by 'new' or the likes that initializes the object.

	property x  // ( -- n ) stars[istar] position x-axis
	property y  // ( -- n ) stars[istar] position y-axis
	property vx // ( -- n ) stars[istar] speed vector x-component 
	property vy // ( -- n ) stars[istar] speed vector y-component 
	property radius	// ( -- n ) stars[istar] radius
	property ax // ( -- n ) stars[istar] acceleration of gravity vector x-component
	property ay // ( -- n ) stars[istar] acceleration of gravity vector y-component  
	property rx // ( -- n ) stars[istar] distance to the sun vector x-component
	property ry // ( -- n ) stars[istar] distance to the sun vector y-component
	property color // ( -- string ) stars[istar] fillStyle
	property r // ( -- n ) stars[istar] normalized (rx,ry), distance to the sun
	
	\	這些 properties 都是 forth words 也就都是 global。它們之所以能 access 個別的
	\	stars[istar] 靠的是 istar 當作 index 指定了特定的 object。 所有對 istar 寫值的
	\	word 都要 save-restore 只有 forth console 本身不必。
	\	不設計成: property x y vx vy ... 一行搞定是要讓每個 word 都能寫 help。
	
	: newStar ( -- ) \ Create a New stars[istar]
		istar ( save ) stars :> length to istar \ point to the last star which is the New Star
		js: if(!g.stars[g.istar])g.stars[g.istar]={} \ if it's empty then declair
		<js>  // get color fillStyle string
			(function(){
			var r=80,g=80,b=100,range=100,c="rgba(";
			c += parseInt(Math.random()*r) + ',';
			c += parseInt(Math.random()*g) + ',';
			c += parseInt(Math.random()*range+b) + ',';
			c += Math.random()*0.45+0.30 + ')';
			push(c)})() 
		</js> to color
		js> Math.random()*(30-10)+10 to radius \ radius 10 ~ 30
		js> Math.random()*g.maxPlanet+kvm.cv.canvas.width to x \ 座標位置，初值在畫面之外
		js> Math.random()*g.maxPlanet+kvm.cv.canvas.height to y
		js> Math.random()*5-2.5 to vx \ 速度向量 between -2.5 ~ 2.5 
		js> Math.random()*5-2.5 to vy
		0 to ax 0 to ay \ 重力加速度
		0 to rx 0 to ry \ 與太陽距離向量
		0 to r  \ 與太陽距離純量
		( restore ) to istar ;

	: collide ( -- ) \ Collision of istar and friends or 算出重力加速度
		stars :> [0] >r ( == sun )
		r@ :> x x - to rx \ (rx,ry) 是 planet 指向 the sun 的向量
		r@ :> y y - to ry 
		rx rx * ry ry * + js> Math.sqrt(pop()) to r \ 與太陽距離純量
		r r@ :> radius radius + > if \ not in_the_sun
			gravity rx * r r * r * / to ax \ 算出重力加速度
			gravity ry * r r * r * / to ay
		else \ the planet is hiting the sun
			\ 當距離很近時重力加速度會變成無限大，所以行星進入到太陽的範圍就要焚毀否則無法處理。
			0 to radius 
		then r> drop ;
		
	: animate ( -- ) \ 動畫前的準備工作
		vx ax + to vx    vy ay + to vy \ 速度一直加 (ax,ay) 上去，所以叫「加速度」
		x vx + to x      y vy + to y
		\ 在畫布範圍外看不見的地方動手腳
		x radius - js> kvm.cv.canvas.width > if
			vx 10 / to vx \ 跑出視野的就偷偷把它減速
		else x radius + 0< if
			vx 10 / to vx
		then then
		y radius - js> kvm.cv.canvas.height > if
			vy 10 / to vy \ 跑出視野的就偷偷把它減速
		else y radius + 0< if
			vy 10 / to vy
		then then ;
		
	: display ( -- ) \ Display the stars[istar]
		beginPath 
		x y radius 0 js> Math.PI*2 false arc 
		color fillStyle 
		fill ;
		
	: seeStar ( id -- ) \ See istar
		." --" . ." -- " ." radius=" radius .
		." , x=" x . ." , y=" y . 
		." , vx=" vx . ." , vy=" vy . 
		cr ;

\ draw
	: draw ( -- ) \ Mimic processing's draw() function
		clearCanvas
		istar ( save )
		0 to istar display \ The sun
		stars :> length-1 for r@ to istar \ where istar : numBalls,...,3,2,1 
			collide animate display
		next
		stars :> length-1 for r@ to istar \ where istar : numBalls,...,3,2,1 
			\ 垃圾清理撞進太陽湮滅掉的行星，換一個新的上去
			radius if else stars :: splice(g.istar,1) newStar then
		next
		( restore ) to istar
	;
	
\ tools
	: dump ( -- ) \ See all stars
		istar ( save )
		stars :> length-1 for r@ to istar \ where istar : numBalls,...,3,2,1 
			istar seeStar
		next
		0 to istar istar seeStar
		( restore ) to istar
	;
	: total-momentum ( -- f ) \ All |(vx,vy)| summation
		istar ( save )
		0 ( sum )
		stars :> length-1 for r@ to istar ( -- sum ) \ where istar : #stars,...,3,2,1 
			vx vx * vy vy * + js> Math.sqrt(pop()) ( -- sum Momentum[istar] ) +
		next 
		( restore ) to istar ;
		/// total-momentum int dup . space 130 > [if] friction 0.001 + [then] to friction 500 nap rewind
		/// total-momentum int dup . space 100 < [if] friction 0.001 - [then] to friction 500 nap rewind
		/// cr 10000 nap rewind
	
\ start to run

	newStar newStar newStar newStar newStar newStar \ 太陽 行星

	\ the Sun
		0 to istar 40 to radius 0 to vx 0 to vy 200 to x 200 to y 
		char rgba(255,166,47,0.6) to color display \ 太陽的顏色，金色 http://www.computerhope.com/htmcolor.htm
	\ description
	<text> 
	一度孤獨的太陽在太空中慢慢捕獲它的五顆行星，過程可能要半小時，期間很多都撞進太陽裡湮滅了。。。。
	手動 Copy-paste 下列整段命令到 inputbox 命令區執行，可讓太陽左右來回移動，
	
		( 讓太陽左右來回移動 ) js: e=d=0.5 cut js: h=g.stars[0].x+=e 
		js> h>=(kvm.cv.canvas.width-kvm.cv.canvas.height/2) [if] js: e=-d [then] 
		js> h<=kvm.cv.canvas.height/2 [if] js: e=d [then] 50 nap rewind ( rewind
		回到 cut 之後重複執行，50 nap 交還控制權給 host 休息 50 mS 之後回來繼續。
		太陽一動起來，行星維持繞日公轉而不焚毀或飛走就越加困難了。 )
	
	此後就有了兩個「常駐程式」不斷執行，前一個負責太陽系動畫模擬行星軌道；後一個移
	動太陽慢慢左右來回，各做各的事。可輸入 stop 命令把所有「常駐程式」都停掉（即停
	掉所有 TIB loop) 或照 Windows 的慣例 Ctrl-Break 也可以。

	可以玩的還很多，條列如下：
	
		0.	1 to istar \ 指定觀測一號行星
		1.	r 100 < [if]  ." 一號行星接近太陽了" stop [then] 10 nap rewind \ 監視器。一號行星接近時系統暫停以便觀察數據。
		2.	r . \ ==> 查看與太陽的球心距離
		3.	vx . space vy . cr \ ==> 查看一號行星速度向量。
		4.	x . space y . cr \ ==> 查看一號行星位置。
		5.	s" yellow" to color \ 改一號行星的顏色。
		6	3 to vx \ 往右輕推一號行星一把，故意擾動它的路線。
		7.	10 to radius \ 改一號行星的大小。
		8.	js: g.stars=g.stars.slice(0,3) \ 只留 0,1,2 三顆星體，其他都刪掉。其中 0 是太陽。用 newStar 命令則可添加行星。
	
	當你在 inputbox 輸入這些命令時，等於是在給 jeforth 系統加派工作。如果像剛才 copy
	- past 上去的整段命令末尾有 50 nap rewind 者則成為又一個「常駐程式」，有如 event 
	handler。可見 jeforth console 的一行命令本身既是個獨立的 event 又是這個 event 之
	專屬的 handler 擁有自己的 TIB、#TIB、以及除非有意放手（如 50 nap 休息 50 mS）不會
	被打斷的執行時間。
	
	Happy programming !
	
	Try 'help'
	</text> .

	\ the main loop
	<task> 
		draw 20 nap rewind 
	</task>
	<task>
		( 讓太陽左右來回移動 ) js: e=d=0.5 cut js: h=g.stars[0].x+=e 
		js> h>=(kvm.cv.canvas.width-kvm.cv.canvas.height/2) [if] js: e=-d [then] 
		js> h<=kvm.cv.canvas.height/2 [if] js: e=d [then] 50 nap rewind ( rewind
		回到 cut 之後重複執行，50 nap 交還控制權給 host 休息 50 mS 之後回來繼續。
		太陽一動起來，行星維持繞日公轉而不焚毀或飛走就越加困難了。 )
	</task>


