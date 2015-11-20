
\ Re-produce a very old processing.js demo
\ 重現經典範例，畫出美麗的布料圖案。

include processing.f

s" cloth.f"	source-code-header

\ messages
	: starting-message ( -- )
		." Start . . . " ;
	: ending-message ( -- ) 
		." Done!" cr ;
	
\ setup
	600 300	setCanvasSize	\ ( width height -- ) 
	15		setFrameRate	\ ( times per second ) 60 已經快到頂了，電腦速度跟不上了。
	130		setFrameCountLimit \ ( n -- ) we don't run it infinitly
	40		lineWidth		\ ( n -- )
	100		value r			// ( -- int ) Red 
	200		value g	 		// ( -- int ) green 
	200		value b			// ( -- int ) blue
	55		value range		// ( -- int ) Range of colour variation
	90		value d			// ( -- int ) Drifting distance of the 2nd point
	
\ draw
	: draw ( -- ) \ Mimic processing's draw() function
		beginPath
		char rgba( 
		r js> Math.random()*pop() int + char ,  +
		g js> Math.random()*pop() int + char ,  +
		b range js> Math.random()*pop()+pop() int + char ,  + \ 給 blue 優待，偏藍色系。
		js> Math.random() + char )  +
		( .s jsc ) strokeStyle
		js> Math.random()*(kvm.cv.canvas.width+100)-50 dup >r 0 moveTo \ 上邊某一點，比 canvas 兩邊各超出 50，比較自然。
		r> d js> Math.random()*tos()-pop()*0.5+pop() js> kvm.cv.canvas.height lineTo \ 下邊某一點是上一點偏移的結果。
		stroke
	;

\ start to run
	processing

<comment>
	include awk.f
	<o>
		<div id=eleOpening>
		<h4>A jeforth demo (for htm, hta, and nw.js)</h4>
		<h1>經由電腦繪圖熟悉 jeforth - 布料圖案 cloth.f</h1>
		<p>
			幾年前剛聽說 processing 電腦語言的時候一上網就看到我們接下來要示範的這個
			demo，現在已經找不到它了。以下用 jeforth 來重現經典，畫出美麗的布料圖案。
		</p>
		</div>
	</o> ( eleOpening ) js> outputbox insertBefore
	<text>
		<o>
		/* Table 寬度 90% 正好 */
		<table id=elePlayarea align=center width=100% border=2 cellspacing=0 cellpadding=4 bordercolor=white>
			<tr>
				<td rowspan="2" valign="bottom">
					<div id=cvdiv></div> /* reserved for the canvas */
				</td> 
				<td width=90% valign="TOP"> /* 故意佔 90% 寬度讓旁邊的 canvas 擠滿它的區域 */
					<div id=newoutputbox></div>  /* reserved for the outputbox */
				</td>
			</tr>
			<tr>
				<td height=10%>  /* 縮到 10% 故意讓 inputbox 沉到底下 */
					<textarea id=newinputbox>\ Enter your commands here, ESC to clear.</textarea>
				</td>
			</tr>
		</table> 
		</o> js> eleOpening insertAfter
	</text> <replace> /\*.*\*/<flags> g<to> </replace> tib.insert
	js> inputbox  js> newinputbox  replaceNode \ 
	js> outputbox js> newoutputbox replaceNode
	cls eleBody ce! er
	include processing.f
	js> vm.cv :> canvas js> cvdiv replaceNode \ Place the canvas
	include cloth.f
	<o>
		<div id=eleTopic1>
		<h3>認識環境</h3>
		
		<p>
			上面看到的畫布、Output box、Input box 等分別標註如下圖。jeforth 可以自由設計版面，
			我們現在是為了要示範 cloth.f 而設計成這樣子。
			Input box 以及 Output box 所處的右半邊是 User(您) 與 forth 電腦語言(jeforth) 的交談區；
			左半邊放 Canvas 畫布。
			用繪圖來示範比較直覺，jeforth 可以做的遠不只於此：
			自動化 Excel 簡化辦公室工作、網管、工程科學上的應用等。
			然而要在本頁面上講解，還是用繪圖比較方便。
		</p>
		<p>
			jeforth 的交談區初看只是上下兩塊區域，
			其實它們提供了相當完備的 Console 或 Shell 程式常見功能方便操作，
			例如 Command auto-complete, Recall command history, Output box triming 等。
			外觀簡約到極致，以便使它們可以適應所有應用場合。
			請在 inputbox 打入 help 命令查看完整的功能介紹。
		</p>
		<blockquote><img src="playground/jeforth-demo-cloth-2015-11-201.jpg"></blockquote>
		</div>
	</o> ( eleOpening ) js> elePlayarea insertAfter
</comment>

<comment>
	\ 想要讓 outputbox 能 word-wrap 的努力都失敗了,因為 type 是用 $().append() 做的,
	\ 它不吃 text-wrap 這一套。想不通都是在 <div> 裡面，怎麼會無效？
	include awk.f
	<text>
		cls s" body" <e>
		/* Table 寬度 90% 正好 */
		<table align=center width=90% border=2 cellspacing=0 cellpadding=4 bordercolor=white>
			<tr>
				<td rowspan="2" valign="bottom">
					<div id=cvdiv></div> /* reserved for the canvas */
				</td> 
				<td width=90% valign="TOP"> /* 故意佔 90% 寬度讓旁邊的 canvas 擠滿它的區域 */
					<div id=newoutputbox></div>  /* reserved for the outputbox */
				</td>
			</tr>
			<tr>
				<td height=10%>  /* 縮到 10% 故意讓 inputbox 沉到底下 */
					<textarea id=newinputbox>\ Enter your commands here, ESC to clear.</textarea>
				</td>
			</tr>
		</table> 
		</e> drop \ <e>..</e> 傳回最後一個 element object, 我們不用，把它丟掉。
		js> inputbox  js> newinputbox  replaceNode \ 
		js> outputbox js> newoutputbox replaceNode
		eleBody ce! er
		<o> <textarea></textarea></o> constant notepad // ( -- element ) My Notepad 
		notepad js> outputbox insertBefore notepad :: rows=10 \ 變出一塊區域處理文字
		: 2notepad notepad :: value+=vm.screenbuffer cls ; // ( -- ) Save screenbuffer to notepad.
		include processing.f
		js> vm.cv :> canvas js> cvdiv replaceNode \ Position the canvas
		include cloth.f
	</text> 
	<replace> /\*.*\*/<flags> g<to> </replace>
	tib.append
</comment>
