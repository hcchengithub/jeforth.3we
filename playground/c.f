	<text>	/* <text>...</Text> 是一段可以跨行的 string。 
			** 您跳到下面查看，會發現這 string 將被交給 tib.insert 執行。
			** tib.insert 意思是：把這一大段 text 當作主人輸入 TIB 的 Forth commands 執行。 
			** 像本段這種類似 C 語言的 comments 都會在執行前被清除掉，彷彿 jeforth 認得這種
			** comment 似的？其實它不認得，但咱略施小技一小行 JavaScript 即可。本來 HTML 是
			** 很難寫註解的，用 jeforth 包裹起來寫 HTML 則無所不能！
			** 
			** 下面的 source code 有 forth, JavaScript, HTML, CSS 等多種語言混搭。
			** 您只要記得 interpreter 是 jeforth 所以切入別的語言之前一定有某個 jeforth
			** 的命令切換，下面都會解釋。我覺得閱讀起來並無困難，您覺得呢？請多多惠賜意見。
			*/
		<h> /* <h>..</h> 是寫東西進 HTML 的 <head> 裡 */
			<style type="text/css">
				code, .code { 
					font-family: courier new;
					font-size: 110%;
					background: #E0E0E0;
				}
				table {
					width: 100%;
				}
				.essay { 
					font-family: Microsoft Yahei;
					letter-spacing: 2px;
					line-height: 160%;
				}
			</style>
		</h> drop \ /* 丟掉 <h>..</h> 留下來的 <style> element object, 用不著 */
		<o> /* <o>..</o> 是在 outputbox 裡寫 HTML */

/* ----- Greeting 前言 --------------------------------------------------------------------- */

			<div id=eleOpening class=essay> /* 將來可以 js> eleOpening 來取用這整個 DIV element */
			<h1>經由電腦繪圖熟悉 jeforth.3we - 布料圖案 cloth.f</h1>
			<blockquote><p>
				jeforth 是 「台灣符式協會 FitTaiwan」 兩位先進 
				Yap 與 爽哥 所提示之用 JavaScript 打造 Forth 系統的方法。
				我依法做出來的結果就稱為 jeforth.3we (3 Words Engine) 統稱同一個 
				kernel 在不同環境的各種版本。
				3we 當中的 3 之後加上一點點努力就是 Forth 語言的吉祥數字 4， 
				而目前「we」則有 jeforth.3htm (HTML), jeforth.3hta (Microsoft HTML Application), 
				jeforth.3nd (Node.js), jeforth.3nw (Node-Webkit or NW.js) 等。
				在本網頁上呈現的是 jeforth.3htm 的應用。我會用到一些 Forth 語言的概念或語彙如 stack,
				push, pop, TOS 等等，完全不懂 Forth 語言的讀者可以「不求甚解」照著做無妨，
				若希望先讀幾個小時書，我推薦 
				<A HREF="http://wiki.laptop.org/go/Forth_Lessons" target="_blank">OLPC (One Laptop per Child)	的 online 教材：http://wiki.laptop.org/go/Forth_Lessons</A>，
				也許將來該特別為 OLPC 做一版以求更完整地執行該教材的範例。
			</p><p>	
				幾年前剛聽說 Processing.js 這個繪圖電腦語言的時候，
				上網一查就看到我們接下來要示範的這個 demo。
				別急，您現在去找已經找不到了。
				以下用 jeforth 來重現經典畫出這個美麗的布料圖案，
				並且請您親手鑽進這個十分簡單的程式裡去玩一玩，
				我們一邊操作它一邊自然地熟悉 jeforth.3we 的使用。
			</p></blockquote>
			</div>
/* -------------------------------------------------------------------------- */
		</o> ( eleOpening ) js> outputbox insertBefore /* 把這段 HTML 移到 outputbox 之前 */
	</text> :> replace(/\/\*(.|\r|\n)*?\*\//mg,"") \ 清除 /* ... */ 註解。
	tib.insert
	<text> 
	
/* ----- Playground 互動區 --------------------------------------------------------------------- */

		<o> <blockquote id=elePlayarea>
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
		<blockquote></o> js> eleOpening insertAfter
/* -------------------------------------------------------------------------- */
	</text> :> replace(/\/\*(.|\r|\n)*?\*\//mg,"") \ 清除註解。
	tib.insert
	
	\ 以下的 js> 命令執行隨後的 JavaScript statements 直到遇上 white space 為止，最
	\ 後一個 statement 的值 (or 'undefined') 放在 jeforth 的 TOS 傳回。
	
	js> inputbox  js> newinputbox  replaceNode \ replaceNode 移置過去，本來 inputbox 有很多功能皆獲保留。
	js> outputbox js> newoutputbox replaceNode \ 同上。
	cls eleBody ce! er \ 清除畫面上的小垃圾。
	include processing.f
	js> vm.g.cv :> canvas js> cvdiv replaceNode \ Place the canvas
	include cloth.f
	<text>
		s" body" <e> /* 直接放到 <body> 後面，不必像上面那樣用 insertBefore, replaceNode 之類的手法搬動就定位 */
		
/* ----- 認識操作環境 --------------------------------------------------------------------- */

			<div class=essay>
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
/* -------------------------------------------------------------------------- */
			<p>
				【交談區】初看只是上下兩塊區域，沒甚麼吧？
				其實它們提供了相當完備的 Console 或 Shell 程式的常見功能。
				例如 Command auto-completion, Previous commands recalling, 
				至於 Outputbox triming 則別地方都還沒見過。
				為了到處通用，外觀宜簡約，留給應用各自去發揮。
				請嘗試在 inputbox 打入 <code>cls</code> 命令把 outputbox 清乾淨。
				打入 <code>words</code> 列出所有的命令。
				打入 <code>help *</code> 列出所有命令的說明。
				打入 <code>help</code> 命令查看操作功能介紹。
			</p></blockquote>
/* -------------------------------------------------------------------------- */
			<h2>cloth.f 裡有些甚麼？</h2>
			<blockquote>
/* -------------------------------------------------------------------------- */
				<p>
					以上嘗試的結果，您可能也覺得命令好多，眼花撩亂。
					它們都是各個 ~.f 檔定義的，
					我建議把每個 ~.f 檔當成一個 Forth 語言的 vocabulary
					且直接以檔名為 name。
					Vocabulary 者，義:「一大堆單字」, 音:「我看必有熱淚」
					是 Forth 歸納眾多命令的一招。
					這麼多 words 無論是英文或 Forth 語言都令人飆淚，所以要分門整理。
					我們只想專注在 demo 程式 cloth.f 就好，
					請打入這個命令 <code>only</code> 然後再輸入 <code>words</code> 試試，剛才還在的大堆命令
					(Forth 的 words) 都不見了。這就是 only 的作用 — 不看除了「基本」的以外之其他命令。
					jeforth.3we 的「基本」命令就是在名為 <code>forth</code> 的 vocabulary 之內的 words 皆是。
					因為是「基本」命令所以即使 words 或 help 命令都看不到的時候還是可以執行。 
					其他 vocabulary 裡的命令於 words 或 help 看不到時也就執行不到了 
					( 一般是 only 命令視需要所為 )。 請打入命令：
				</p>
				<table>
				<td class=code /* .code 影響到整格區域的 background color 這是用上 <table> 的目的 */>
				<blockquote>
				<code>only canvas.f also cloth.f words</code>
				</blockquote></td></table>
/* -------------------------------------------------------------------------- */
				<p>
					如此列出來的 words 就只限 canvas.f 跟 cloth.f 的。
				</p>
				<table><td class=code /* 影響整格的 background color */>
				<blockquote><pre><code /* 影響 font-size 跟 font-family */>
> only canvas.f also cloth.f words /* 在 <pre> 裡不自動排版， white spaces 會照著呈現 */

-------- canvas.f (29 words) --------
canvasStyle createCanvas setWorkingCanvas setCanvasSize 
setCanvasStyle save restore translate rotate beginPath 
moveTo lineTo closePath stroke lineWidth strokeStyle 
clearRect fillStyle fill fillRect fillText strokeText 
clearCanvas arc createRadialGradient createLinearGradient 
addColorStop font move-cv-up-into-outputbox
-------- cloth.f (8 words) --------
starting-message ending-message r g b range d draw
 OK 			</code></pre></blockquote></td></table>
/* -------------------------------------------------------------------------- */
				<p>
					看到 canvas.f 裡有個 clearCanvas 命令嗎？
					請用它把 canvas 畫布整個擦掉。
					試試看只敲 <code>clear</code> 然後連按幾下 
					TAB key 自動跳出類似的命令直到
					<code>clearCanvas</code> 出現為止即予執行。			
					cloth.f 裡只有少數幾個命令，看到其中有個 
					<code>draw</code> 了嗎？
					輸入 <code>draw</code> 你會看到全白的 
					canvas 上出現了一條色帶。
					多試起次，可以按 Ctrl-Up Ctrl-Down 來喚回先前下過的命令省勞力。
					一次下一大堆將如何？
				</p>
				<table width=100%><td class=code><blockquote><code>
					draw draw draw draw draw draw draw draw draw draw draw draw
				</code></blockquote></td></table>
/* -------------------------------------------------------------------------- */
				<p>
					結果類似這樣：
				</p>
				<img src="playground/jeforth-demo-cloth-2015-11-202.jpg">
/* -------------------------------------------------------------------------- */
				<p>
					那麼 draw 是怎麼畫出一條色帶的呢？下這行命令就可以查看 
					cloth.f 的 source code:
				</p>
				<table width=100%><td class=code><blockquote><code>
					s" cloth.f" readTextFileAuto .
				</code></blockquote></td></table>
				<p>
					注意最後有個小點兒，那是 forth 用來印出 TOS 的命令不要漏掉。
					當時的 TOS 就是 cloth.f 整個檔案的 text string，的確很短。
					您輸入 readTextFileAuto 這麼長的命令時，可以只敲 readT 
					然後打幾下 TAB 就會輪到它。
					
				</p>
				<table width=100%><td class=code><blockquote>
<pre><code>> s" cloth.f" readTextFileAuto .

\ Re-produce an old processing.js demo 
\ 重現經典範例，畫出美麗的布料圖案。 

s" cloth.f"    source-code-header 
    include canvas.f 
    \ 有現成的畫布就用現成的，否則變出一個來用。 
    ' cv [if] [else] createCanvas setWorkingCanvas [then]  

\ setup 
    600 300    setCanvasSize    \ ( width height -- )  
    40        lineWidth        \ ( n -- ) 
    100        value r            // ( -- int ) Red  
    200        value g             // ( -- int ) green  
    200        value b            // ( -- int ) blue 
    55        value range        // ( -- int ) Range of colour variation 
    90        value d            // ( -- int ) Drifting distance of the 2nd point 
     
\ draw 
    : draw ( -- ) \ Mimic processing's draw() function 
        beginPath 
        char rgba(  
        r js> Math.random()*pop() int + char ,  + 
        g js> Math.random()*pop() int + char ,  + 
        b range js> Math.random()*pop()+pop() int + char ,  + \ 給 blue 優待，偏藍色系。 
        js> Math.random() + char )  + 
        ( .s jsc ) strokeStyle 
        js> Math.random()*(vm.g.cv.canvas.width+100)-50 dup >r 0 moveTo \ 上邊某一點，比 canvas 兩邊各超出 50，比較自然。 
        r> d js> Math.random()*tos()-pop()*0.5+pop() js> vm.g.cv.canvas.height lineTo \ 下邊某一點是上一點偏移的結果。 
        stroke 
    ; 

\ main 

    150 [for] draw [next] 

\ The End </code><pre>
				</blockquote></td></table>
					
					
				<p>	
					用 <code>see draw</code>
					查「看」它的定義。從下圖的結果看起來類似 Assembly 語言的
					反組譯 disassembly 之結果，其中 Assembly instruction 現在變成
					Forth word 或 JavaScript function. 這樣看到的是 draw 這個 word
					經過 Forth compile 過的程式碼，所以 Forth 常被稱為 Virtual Machine.
					請由圖中注釋了解一下 see 一個 word 的結果大概的樣子。
					注意到 property 中的 type 指出它是個 colon word。
					
				</p>
				<img src="playground/jeforth-demo-cloth-see-2015-11-241.jpg">
/* -------------------------------------------------------------------------- */
				<p>
					我們要直接參考 draw 的定義進去它裡面玩以前，先看 + 的定義比較簡單。
					請下達 <code>see +</code> 命令看到：
				</p>
				<table width=100%><td class=code><blockquote>
<pre><code>> see +
	name : + (string)
	 vid : forth (string)
	 wid : 73 (number)
	type : code (string)
	help : ( a b -- a+b) Add two numbers or concatenate two strings.  (string)
	  xt :
function (_me){ /* + */
            push(pop(1)+pop()) 
}
toString :
function (){return this.name + " " + this.help}
 OK </code></pre>
				</blockquote></td></table>
/* -------------------------------------------------------------------------- */
				<p>
					其中的 type 屬性指出 + 是個 code word。它的工作是從 Forth stack
					裡 pop 兩個 cell 出來相加以後 push 回去，這正是 + 沒錯。
					您可能還注意到我們有 push(), pop() 可用來操作 Forth data stack.
					pop() 還有個 input argument 可以不照 stack 的一般順序直接 pop 
					指定的 stack cell 出來。
					pop() 取用 TOS, 而 pop(1) 取用 TOS 的下一 cell, 可見 TOS 本身是
					pop(0) 而 0 可以省略。這些 kernel 中定義的 
					JavaScript 小工具不多，
					
				</p>
				<table width=100%><td class=code><blockquote><code>
					--- result ----
				</code></blockquote></td></table>
/* -------------------------------------------------------------------------- */
				<p>
					description
				</p>
				<table width=100%><td class=code><blockquote><code>
					--- result ----
				</code></blockquote></td></table>
/* -------------------------------------------------------------------------- */
				<p>
					description
				</p>
				<table width=100%><td class=code><blockquote><code>
					--- result ----
				</code></blockquote></td></table>
/* -------------------------------------------------------------------------- */
				<p>
					description
				</p>
				<table width=100%><td class=code><blockquote><code>
					--- result ----
				</code></blockquote></td></table>
/* -------------------------------------------------------------------------- */
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
				<table width=100%><td class=code><blockquote><code>
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
				</code></blockquote></td></table>
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
				
			</div>
		</e> drop \ <e>..</e> 留下的最後一個 element 沒用到，丟掉。
	</text> :> replace(/\/\*(.|\r|\n)*?\*\//mg,"") \ 清除註解。
	tib.insert
<comment>
> run: 200 for draw next
 OK 
> clearCanvas
 OK 
> 200 [for] draw [next]
 OK 
> .s
empty
 OK 
</comment>