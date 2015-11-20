
	<o>
		<div id=eleOpening>
		<h4>A jeforth demo (for htm, hta, and nw.js)</h4>
		<h1>經由電腦繪圖熟悉 jeforth - 布料圖案 cloth.f</h1>
		<p>
			幾年前剛聽說 Processing.js 這個繪圖電腦語言的時候，
			上網一查就看到我們接下來要示範的這個 demo，
			現在已經找不到它了。
			以下用 jeforth 來重現經典畫出美麗的布料圖案，
			並且請您親手鑽進這個十分簡單的程式裡去玩一玩，
			說不定您現在還看得到下面的【布料圖案】還在畫布上逐漸完成中？
			這表示這塊區域是活的，
			我們一邊操作它一邊自然地熟悉 jeforth 的使用。
		</p>
		</div>
	</o> ( eleOpening ) js> outputbox insertBefore
	<text>
		<o>
		/* 本來 HTML 是很難寫註解的，用 jeforth 包裹起來寫 HTML 則無所不能！！ */
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
	</text> 
	:> replace(/\/\*.*\*\//g,"") \ 清除註解。
	tib.insert
	js> inputbox  js> newinputbox  replaceNode \ replaceNode 移置過去，本來 inputbox 有很多功能皆獲保留。
	js> outputbox js> newoutputbox replaceNode \ 同上。
	cls eleBody ce! er \ 清除畫面上的小垃圾。
	include processing.f
	js> vm.cv :> canvas js> cvdiv replaceNode \ Place the canvas
	include cloth.f
	<o>
		<div id=eleTopic1>
		<h2>認識環境</h2>
		<p>
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
		<blockquote><img src="playground/jeforth-demo-cloth-2015-11-201.jpg"></blockquote>
		<p>
			【交談區】初看只是上下兩塊區域，看起來幾乎沒甚麼。
			不要被騙了，其實它們提供了相當完備的 Console 或 Shell 程式的常見功能。
			例如 Command auto-completion, Command history recall, 
			甚至 Outputbox triming 別地方還沒見過。
			為了到處通用，外觀宜簡約，以便呈交給各個應用接管。
			否則每多一樣東西外顯，應用場合就會有更多限制而不自由。
			請嘗試在 inputbox 打入 cls 命令把 outputbox 清乾淨。
			打入 words 列出所有的命令。
			打入 help * 列出所有命令的說明。
			打入 help (比上面少掉 *) 命令查看操作功能介紹。
		</p>
		<h2>看看 cloth.f 裡有些甚麼？</h2>
		<p>
			看到以上嘗試的結果，您可能也覺得命令好多，眼花撩亂。
			它們都是各個 ~.f 檔定義的，
			我習慣把每個 ~.f 檔當成一個 Forth 語言的 vocabulary
			且直接以檔名為 vocabulary name。
			Vocabulary 是分門別類的意思，是 Forth 歸納眾多命令的方式。
			我們只想專注在 demo 程式 cloth.f 就好，
			請打入這組命令:
		</p>
		<pre><code>
	only cloth.f words 
		</code></pre>
		<p>
			如此列出來的命令就只限 cloth.f 裡面的了。
			隨後我們要用到 canvas.f 裡的命令來把 canvas 抹乾淨。
			然而剛才下達的 <code>only</code> 命令排除掉了所有的 vocabulary，
			我們得把 canvas.f 請回來，請打入這組命令:
		</p>
		<pre><code>
	also canvas.f
		</code></pre>
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

		<p>
			看到 canvas.f 裡有個 clearCanvas 命令嗎？
			請用它把 canvas 抹乾淨。
			
		</p>
		<pre><code>
	clearCanvas
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
		

		</div>
	</o> ( eleOpening ) js> elePlayarea insertAfter
