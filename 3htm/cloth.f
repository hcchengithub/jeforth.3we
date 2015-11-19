
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
