\s
\	playCSS.f CSS 實驗筆記
\

\ [x] 查原版的 baseStyle innerHTML
	js> styleBase ce! ce@ dup se :> innerHTML . \ ==> 仔細看下列結果，這些設定合不合理。
	[object HTMLStyleElement] id='styleBase'; innerHTML= body { font-family: courier new; font-size: 20p...
		0 : [object Text]  body { font-family: courier new; font-size: 20px; padding:20px; word-wrap:break-word;...

		body {
				color:black; /* font color */
				font-family: courier new;  /* 合理，這個字體最基本 */
				font-size: 20px; /* 合理 */
				padding:20px; /* 合理，頁面四周留白, border 到文字的距離 */ 
				word-wrap:break-word; /* 合理，wrap-around 時採英文 word 間斷折，而非 charactor */ 
				border: 1px ridge; /* 山脊，只有一條線 */
				background:#F0F0F0; /* 灰色背景 */
		}
		textarea {
				width:100%; /* 增補 body 沒有的設定 */
				border: 0px solid;  /* 改變 body 原有的設定 */
				background:#BBBBBB; /* 改變 body 原有的設定 */
		}
	OK

[x] [CSS 筆記] 如何在一個 <tag> 裡用上多個 class 以方便 CSS 控制? 有兩種主題，
	[x] 主題一是 <style> tag 出現的時間位置與目標 node 的先後關係。 
		結論：多個 style tag 即使是人家的 child 也都是 global，可任意殺掉某一
			  個，效果永遠是整個的聯集，且 overlap 部分後面蓋前面。
		
		\ 先放 element 再改 global style 有效。範圍包括 children, 如 element class=cc 者。
		<o> <div id=t1><span id=ii>My id is ii. { <span class=cc>My class is cc.</span> } </span></div></o> constant t1 // ( -- element ) <div> t1
		<text> #ii{color: blue;border: 2px solid red;}</text> js> styleBase :: innerHTML=pop()

		\ restart > 先放 element > 然後加上新的 style 去改 id=ii, ----> 有效！
		<o> <div id=t1><span id=ii>My id is ii. { <span class=cc>My class is cc.</span> } </span></div></o> constant t1 // ( -- element ) <div> t1
		<o> <style id=s1 type="text/css">#ii{border:1px solid red;background:#2020E0;}</style></o> drop
		
		\ 再改 ---> 還是有效。
		<o> <style id=s1 type="text/css">#ii{border:1px solid red;background:#a0a0a0;}</style></o> drop	
		
		\ 看看 outputbox 的 ce tree，似乎多個互相衝突的 style 設定，取最一個生效？（對）
		OK eleDisplay ce! ce
		[object HTMLDivElement] id='outputbox'; innerHTML=<div id="t1"><span id="ii">My id is ii. { <span cl...
		0 : [object HTMLDivElement] id='t1'; innerHTML=<span id="ii">My id is ii. { <span class="cc">My class is...
		1 : [object HTMLStyleElement] id='s1'; innerHTML=#ii{border:1px solid red;background:#2020E0;}...
		2 : [object HTMLStyleElement] id='s1'; innerHTML=#ii{border:1px solid red;background:#a0a0a0;}...
		3 : [object Text]  OK ...
		4 : [object Text] eleDisplay ce! ce...
		5 : [object HTMLBRElement] 

		\ Create div id=t1 到 outputbox 以外的地方（用 htmlplayground.f 其中沒有該等 style）看會怎樣。（照樣受影響）
		include htmlplayground.f 
		<p> <div id=t1><span id=ii>My id is ii. { <span class=cc>My class is cc.</span> } </span></div></p> constant t2 // ( -- element ) <div> t2 in playground
		\ 結果似乎照樣有效！ --> cls 看看 --> 果然 playground 裡的 t2 馬上失去 styleBase 以外的 styles。
		\ 證明 style s1 這樣的設定仍然是 global 的。我猜前面若殺掉後一個應該會恢復上一個的效果，（對）
		OK ce
		[object HTMLDivElement] id='outputbox'; innerHTML=<div id="t1"><span id="ii">My id is ii. { <span cl...
			0 : [object HTMLDivElement] id='t1'; innerHTML=<span id="ii">My id is ii. { <span class="cc">My class is...
			1 : [object HTMLStyleElement] id='s1'; innerHTML=#ii{border:1px solid red;background:#2020E0;}...
			2 : [object HTMLStyleElement] id='s1'; innerHTML=#ii{border:1px solid red;background:#a0a0a0;}...
			3 : [object Text]  OK ...
			4 : [object Text] ce...
			5 : [object HTMLBRElement] 
		OK ce 2
		[object HTMLStyleElement] id='s1'; innerHTML=#ii{border:1px solid red;background:#a0a0a0;}...
			0 : [object Text] #ii{border:1px solid red;background:#a0a0a0;}...
		OK ce@ removeElement
		\ 果然！！
		
		\ 表格裡有多層結構，border 不 inherit 令人糊塗。研究看看，
		\ 故意弄一個表格，裡面的 style 跟 global 不同，每個 row 也不同。
		\ 這個只有最外圈有 border 因為 border 不會 inherit, 而 color,font-size 卻會自動 inherit。
		\ jeforth.3we 的場合，會 include 東西故不適合用 global style, 盡量用 local 的配合多重 class。
		\ 以下沒有用到 multiple class 就成功了。
		<o> Before the table. 
			<style>
				.tablea td { border:5px solid blue;color: blue;font-size: 36px;}
			</style>
			<table class=tablea>
			<tr><td>11</td><td>12</td></tr>
			<tr><td>21</td><td>22</td></tr>
			</table> 
			<table>
			<tr><td>11</td><td>12</td></tr>
			<tr><td>21</td><td>22</td></tr>
			</table> 
		After the table</o> drop
		\ 以上 <tr> 在 border 上不扮演什麼角色，可能是先 <tr> 後 <td> 之故。
		\ 若先 <td> 後 <tr> 則猜想就是以 <tr> 為準。實驗如下，（錯！沒有這種）
		<o> Before the table. 
			<style>
				.tableb tr { border:5px solid blue;color: green;font-size: 36px;}
			</style>
			<table class=tableb>
			<td><tr>11</tr><tr>12</tr></td>
			<td><tr>21</tr><tr>22</tr></td>
			</table> 
			<table>
			<td><tr>11</tr><tr>12</tr></td>
			<td><tr>21</tr><tr>22</tr></td>
			</table> 
		After the table</o> drop

	[x] 主題二是 CSS 的寫法, see "Multiple Class / ID and Class Selectors" http://css-tricks.com/multiple-class-id-selectors/
		class attribute 本來就可以 multiple, see ---> http://www.w3schools.com/tags/att_global_class.asp
		class="class1 class2 class3" 醬。

	[ ] 前面討論到 'element element' selector 很高興，可以 localize 設定，但碰到 input 好像就不行
		了（行，只是後來被改了）。input 好像都是 global 的？非也，'element element' selector 對 input 有效。
		但是 input 出現在 table class=alarm 裡面不等於 input 就會繼承 .alarm 的 style。<table class=alarm> 
		只是讓這個 table 套用 .alarm 的 style, table 裡面只有 table 自己的東西 (th, tr, td 等) 套用到，現在
		回頭看，的確是這個意思。若要讓本 table 裡的 input 套用 .alarm 的 style, 明確表達為 .alarm input {}
		才對，也就是說，光 .alarm {} 且 <table class=alarm> 與 table 裡的 input 無關。
		
	[ ]	CSS 的 Specificity Rules，http://css-tricks.com/specifics-on-css-specificity/
		style 依序套上文稿，結果呈現為依序被執行的結果，越後面的生效。這是對同樣
		Specificity 的東西而言。否則，較特定的 higher specificity 生效，不論出現順序。
		所以順序是有合理的影響力，但低於特定性 Specificity。
		
	[ ]	這是個用 'element ~ element' selector 的例子。可能很有用。     hcchen5600 2015/02/12 14:41:36 
		<!DOCTYPE html>
		<html>
		<head>
		<style> 
		.project1 ~ ul {
			background: #ff0000;
		}
		.project2 ~ ul, .project2 ~ input {
			background: #00ff00;
		}
		/* .project2 ~ input {
			background: #00ff00;
		} */
		</style>
		</head>
		<body>

		<div>A div element.</div>
		<ul>
		  <li>Coffee</li>
		  <li>Tea</li>
		  <li>Milk</li>
		</ul>
		<input type=text />
		<hr class=project1>
		The first paragraph.
		<ul>
		  <li>Coffee</li>
		  <li>Tea</li>
		  <li>Milk</li>
		  <li><input type=text /></li>
		</ul>
		<input type=text />

		<hr class=project2>
		<h2>Another list</h2>
		<ul>
		  <li>Coffee</li>
		  <li>Tea</li>
		  <li>Milk</li>
		</ul>
		<input type=text />

		<hr class=project1>
		<h2>The third paragraph 不如預期，因為 style 已經執行過了，結果是最後執行到的 project2</h2>
		<ul>
		  <li>Coffee</li>
		  <li>Tea</li>
		  <li>Milk</li>
		  <li><input type=text /></li>
		</ul>
		<input type=text />

		</body>
		</html>

\ -----------------------------------------------------------------------------------------------------------

	CSS 連續的 <span> 如果都沒有設 color:green 則第一個 <span> 設了之後，以下全部變成, say, 綠色。
	一時覺得奇怪，想想這個設計也有道理，否則得全部都去寫 style attribute 不是很笨？
	
		<div id=almReset><span id=reset_button style="color:black">RESET<span><br><span id=clear_button style="color:gray">CLEAR</span></div>
		OK js> start_button :: setAttribute('style','color:black')
		OK js> start_button :: setAttribute('style','color:gray')
		OK js> start_button :: setAttribute('style','color:black')
