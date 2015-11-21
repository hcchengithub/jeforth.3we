	<text> /* <text>...</Text> 是一段可以跨行的 string */
		<h> /* <h>..</h> 是寫東西進 head 裡 */
			<style type="text/css">
				code,.code { 
					font-family: courier new;
					background: #E0E0E0;
				}
				.essay { 
					font-family: Microsoft Yahei;
					letter-spacing: 2px;
					line-height: 160%;
				}
			</style>
		</h> drop
		<o> /* <o>..</o> 是在 outputbox 裡寫 HTML */
		    /* 本來 HTML 是很難寫註解的，用 jeforth 包裹起來寫 HTML 則無所不能！！ */
			<div id=eleOpening class=essay > /* 將來可以 js> eleOpening 來取用這整個 DIV element */
			<h1>經由電腦繪圖熟悉 jeforth - 布料圖案 cloth.f</h1>
			<blockquote><p>
				幾年前剛聽說 Processing.js 這個繪圖電腦語言的時候，
				上網一查就看到我們接下來要示範的這個 demo，
				可是現在已經找不到了。
				以下用 jeforth 來重現經典畫出這個美麗的布料圖案，
				並且請您親手鑽進這個十分簡單的程式裡去玩一玩，
				說不定您現在還看得到下面的【布料圖案】仍在畫布上逐漸完成中？
				這表示這塊區域是活的，
				我們一邊操作它一邊自然地熟悉 jeforth 的使用。
			</p></blockquote>
			</div>
		</o> ( eleOpening ) js> outputbox insertBefore /* 把這段 HTML 移到 outputbox 之前 */
	</text> :> replace(/\/\*.*\*\//g,"") \ 清除 /* ... */ 註解。
	tib.insert
	<text>
		<o>
		<table id=elePlayarea align=center width=90% border=2 cellspacing=0 cellpadding=4 bordercolor=white>
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
	</text> :> replace(/\/\*.*\*\//g,"") \ 清除註解。
	tib.insert
	js> inputbox  js> newinputbox  replaceNode \ replaceNode 移置過去，本來 inputbox 有很多功能皆獲保留。
	js> outputbox js> newoutputbox replaceNode \ 同上。
	cls eleBody ce! er \ 清除畫面上的小垃圾。
	include processing.f
	js> vm.cv :> canvas js> cvdiv replaceNode \ Place the canvas
	include cloth.f
	<o>
		<div id=eleTopic1 class=essay>
		<h2>認識環境</h2>
		<blockquote><p>
			上面看到的畫布、Outputbox、Inputbox 等分別標註如下圖。
			jeforth 可以自由設計版面，
			我們現在是為了要示範 cloth.f 而設計成這樣子。
			Inputbox 以及 Outputbox 所處的右半邊是 User(您) 與
			forth 電腦語言(jeforth) 的【交談區】；
			左半邊放 Canvas 畫布。
			jeforth 的應用很廣泛，例如自動化 Excel 試算表簡化工作、
			網管、工程科學上的應用等，沒甚麼限制。
			然而要在本頁面上講解，還是用【繪圖】當作實例比較方便。
		</p>
		<img src="playground/jeforth-demo-cloth-2015-11-201.jpg">
		<p>
			【交談區】初看只是上下兩塊區域，看起來幾乎沒甚麼。
			不要被騙了，其實它們提供了相當完備的 Console 或 Shell 程式的常見功能。
			例如 Command auto-completion, Command history recall, 
			至於 Outputbox triming 則別地方都還沒見過。
			為了到處通用外觀宜簡約，留給應用各自去發揮，
			否則每多一樣東西外顯，應用場合就會更不自由。
			請嘗試在 inputbox 打入 cls 命令把 outputbox 清乾淨。
			打入 words 列出所有的命令。
			打入 help * 列出所有命令的說明。
			打入 help (比上面少掉 *) 命令查看操作功能介紹。
		</p></blockquote>
		<h2>cloth.f 裡有些甚麼？</h2>
		<blockquote><p>
			以上嘗試的結果，您可能也覺得命令好多，眼花撩亂。
			它們都是各個 ~.f 檔定義的，
			我建議把每個 ~.f 檔當成一個 Forth 語言的 vocabulary
			且直接以檔名為 vocabulary name。
			Vocabulary 是分門別類的意思，是 Forth 歸納眾多命令的方式。
			我們只想專注在 demo 程式 cloth.f 就好，
			請打入這組命令:
		</p>
		<table><td><pre class=code> only cloth.f words </pre></td></table>
		<p>
			如此列出來的命令就只限 cloth.f 裡面的了。
			隨後我們要用到 canvas.f 裡的命令來把 canvas 抹乾淨。
			然而剛才下達的 <code>only</code> 命令排除掉了所有的 vocabulary，
			我們得把 canvas.f 請回來，請打入這組命令:
		</p>
		<pre><code><blockquote>	also canvas.f </blockquote></code></pre>
		<p>
			然後重新查看我們有那些命令可用，
		</p>
		<pre><code>
	words
		</code></pre>
		<p>
			這整串動作可以一次完成，(以這串命令而言，重複做無妨)
		</p>
		<pre><code>
	only cloth.f also canvas.f words	
		</code></pre>
		<p>
			結果類似這樣，
		</p>
		<pre><code>
	> only cloth.f also canvas.f words

	-------- cloth.f (8 words) --------
	starting-message ending-message r g b range d draw 
	-------- canvas.f (29 words) --------
	canvasStyle createCanvas setWorkingCanvas setCanvasSize ... snip ...
	 OK 
		</code></pre>

			看到 canvas.f 裡有個 clearCanvas 命令嗎？
			請用它把 canvas 整個擦掉。
			試試看只敲 clear 然後連按幾下 TAB key 即自動跳出類似的命令直到
			clearCanvas 出現為止即予執行。			
			cloth.f 裡只有少數幾個命令，看到其中有個 draw 了嗎？
			輸入 draw 執行看看，你會看到全白的 canvas 上出現了一條色帶。
			多試起次，可以按 Ctrl-Up Ctrl-Down 來重複先前下過的命令省勞力。
			然後一次下達一大堆看看會怎樣？
		</p>
		<pre><code>
	draw draw draw draw draw draw draw draw draw draw draw draw  ....
		</code></pre>
		
		<p>
			結果類似這樣：
		</p>
		<img src="playground/jeforth-demo-cloth-2015-11-202.jpg">
		<p>
			--- description ---
		</p>
		<pre><code>
	-------- code ---------------
		</code></pre>
		
		<p>
			--- description ---
		</p>
		<pre><code>
	-------- code ---------------
		</code></pre>
		
		<p>
			--- description ---
		</p>
		<pre><code>
	-------- code ---------------
		</code></pre>
		
		<p>
			--- description ---
		</p>
		<pre><code>
	-------- code ---------------
		</code></pre>
		
		<p>
			--- description ---
		</p>
		<pre><code>
	-------- code ---------------
		</code></pre>
		
		<p>
			--- description ---
		</p>
		<pre><code>
	-------- code ---------------
		</code></pre>
		
		<p>
			--- description ---
		</p>
		<pre><code>
	-------- code ---------------
		</code></pre>
		
		<p>
			--- description ---
		</p>
		<pre><code>
	-------- code ---------------
		</code></pre>
		
		<p>
			--- description ---
		</p>
		<pre><code>
	-------- code ---------------
		</code></pre>
		
		<p>
			--- description ---
		</p>
		<pre><code>
	-------- code ---------------
		</code></pre>
		<p>
			被 only 命令排除掉的 vocabulary 都還在 memory 裡面，
			但是都移出了 order 列表。order 列表是搜尋 Forth 命令時，
			循序查訪諸 vocabulary 的先後順序。不在 order 表裡的 vocabulary
			即使已經在 memory 裡面了 words, help 以及 Forth interpreter 都看不見它們。
			下達 vocs 命令即可查看 memory 裡面有哪些 vocabulary。
			這麼一查如果找不到你要用到的 vocabulary 就得用 
			include vocabulary-name.f 命令把它 load 進 memory。
			用 order 命令可查看上述的先後順序，
		</p>
		<pre><code>
	> vocs /* 查看 memory 裡有哪些 vocabulary */
	vocs: forth,html5.f,element.f,platform.f,mytools.f,canvas.f,processing.f,cloth.f
	 OK 
	> order /* 查看 Forth interpreter 搜尋命令的優先順序 */
	search: forth,html5.f,element.f,platform.f,mytools.f,canvas.f,processing.f,cloth.f
	define: cloth.f
	 OK 
	> only /* 把 order 列表都清除 */  
	 OK 
	> order /* order 列表都被清除了的結果 */
	search: /* search 部分空了 */
	define: cloth.f
	 OK 
	> cloth.f /* 把 cloth.f 加回 order 列表 */
	 OK 
	> order /* 看看結果 */
	search: cloth.f
	define: cloth.f
	 OK 
	> also canvas.f /* 再把 canvas.f 也加回 order 列表 */
	 OK 
	> order /* 再看看結果 */
	search: cloth.f,canvas.f
	define: cloth.f
	 OK 	
		</code></pre>
		<p>
			如上，其實 order 列表還分 search 的 order 跟 define 的去處兩部分。
			前者正是上述的搜尋命令時之先後順序，上例中最右邊的這個 cloth.f 
			或最後的例子裡的 canvas.f ( 也就是 order[order.length-1] ) 
			是最優先的，也就是越之後加進 order 的越優先。
			【優先】的意思是當同名的命令 ( Forth word ) 重複出現在多個
			vocabulary 裡時，Forth interpreter 該執行或 compile 哪一個。
			因此同一個 word name 可以重複使用，配合指定 
			vocabulary 的優先順序即可無誤地使用。
			
		</p>
		

		</div></blockquote>
	</o> ( eleOpening ) js> elePlayarea insertAfter
