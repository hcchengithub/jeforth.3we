
\ solar-system.f for jeforth.3we

cls 
include processing.f

vocabulary solar-system.f also solar-system.f definitions
true  constant privacy private // ( -- true ) All words in this module are private"

marker ~~~
	
\ description
	
	<o> <h2><a id=description href=https://www.evernote.com/shard/s22/sh/5066a906-fa5b-4594-9ff8-35fe3d180a14/d1f964de9e7e9b0550911410578482c2>說明</a></h2>
	</o> js> $(".console3we")[0] insertBefore er 
	
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
			<js> var s='var f;f=function(){/* to star.property */ vm[context].stars[vm[context].istar]["'+pop().name+'"]=pop()}';push(eval(s))</js> ( f ) ,
		else ( n word )
			js: vm[context].stars[vm[context].istar][pop().name]=pop()
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
		var s = 'var f;f=function(){push(vm[context].stars[vm[context].istar]["' 
				+ last().name 
				+ '"])}';
		last().xt = eval(s);
		// vm[context].stars[vm[context].istar][last().name] = undefined;
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
		js: if(!vm[context].stars[vm[context].istar])vm[context].stars[vm[context].istar]={} \ if it's empty then declair
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
		js> Math.random()*vm[context].maxPlanet+vm.g.cv.canvas.width to x \ 座標位置，初值在畫面之外
		js> Math.random()*vm[context].maxPlanet+vm.g.cv.canvas.height to y
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
		x radius - js> vm.g.cv.canvas.width > if
			vx 10 / to vx \ 跑出視野的就偷偷把它減速
		else x radius + 0< if
			vx 10 / to vx
		then then
		y radius - js> vm.g.cv.canvas.height > if
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
			radius if else stars :: splice(vm[context].istar,1) newStar then
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

	\ the main loop
		er [begin]	draw 20 nap [again]
	
	\ 讓太陽左右來回移動
	\ 上面是個 infinit loop 所以根本不會下來，必須手動 copy-paste 在 inputbox 執行。
	js: e=d=0.5 
	[begin]
		js: h=vm[context].stars[0].x+=e 
		js> h>=(vm.g.cv.canvas.width-vm.g.cv.canvas.height/2) [if] js: e=-d [then] 
		js> h<=vm.g.cv.canvas.height/2 [if] js: e=d [then] 50 nap
	[again]


