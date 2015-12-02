	
	\ tutor-cloth.f 玩電腦繪圖，熟悉 jeforth.3we
	\ H.C. Chen hcchen5600@gmail.com
	\ FigTaiwan http://groups.google.com/group/figtaiwan

	include unindent.f
	also forth definitions \ 怕有甚麼東西被 only 玩掉了，都放 forth 吧!

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
					font-size: 110%; /*字細所以要大一點*/
					background: #E0E0E0;
				}
				table {
					width: 100%;
				}
				.essay { 
					font-family: Microsoft Yahei;
					letter-spacing: 1px;
					line-height: 160%;
				}
				.source { /*主要是把大小恢復否則 110% 太大了*/
					font-size:100%;
					letter-spacing:0px"
					line-height: 100%;
				}
				
			</style>
		</h> drop \ /* 丟掉 <h>..</h> 留下來的 <style> element object, 用不著 */
		<o> /* <o>..</o> 是在 outputbox 裡寫 HTML */

/* ----- Greeting 前言 --------------------------------------------------------------------- */

			<div id=eleOpening class=essay> /* 將來可以 js> eleOpening 來取用這整個 DIV element */
			<blockquote><h1>玩電腦繪圖，熟悉 jeforth.3we</h1></blockquote>
			<blockquote>
			<p>	
				以下用到一些 Forth 語言的概念或語彙如 stack, push, pop, TOS 
				等等，不熟悉 Forth 語言的讀者可以「不求甚解」照著做無妨。
				若希望先讀書，我推薦 
				<A HREF="http://wiki.laptop.org/go/Forth_Lessons" target="_blank">
				OLPC (One Laptop per Child) 的 online 教材
				</A>。
				也許將來該特別為 OLPC 做一版 jeforth.OLPC 以求更完整地執行該教材的範例。
			</p>							
			<p>	
				幾年前在 Processing.js 網站上看到過我們接下來要示範的這個 
				demo，現在已經找不到了。
				以下用 jeforth 來重現經典畫出這個美麗的布料圖案，
				並且請您親手鑽進這個十分簡單的程式裡去玩一玩。
				您正在看的這個網頁是互動的，它本身就是 
				<A HREF="#3we">jeforth.3we</a> 的應用程式。
				我們一邊操作一邊自然地熟悉它的使用方式。
			</p></blockquote>
			</div>
/* -------------------------------------------------------------------------- */
		</o> ( eleOpening ) js> outputbox insertBefore /* 把這段 HTML 移到 outputbox 之前 */
	</text> 
	:> replace(/\/\*(.|\r|\n)*?\*\//mg,"") \ 清除 /* ... */ 註解。
	<code>escape 	\ convert "<>" to "&lt;&gt;" in code sections
	tib.insert   	\ execute the string on TOS
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
		</blockquote></o> js> eleOpening insertAfter
/* -------------------------------------------------------------------------- */
	</text> :> replace(/\/\*(.|\r|\n)*?\*\//mg,"") \ 清除註解。
	tib.insert
	
	\ 以下的 js> 指令執行隨後的 JavaScript statements 直到遇上 white space 為止，最
	\ 後一個 statement 的值 (or 'undefined') 放在 jeforth 的 TOS 傳回。
	
	js> inputbox  js> newinputbox  replaceNode \ replaceNode 移置過去，本來 inputbox 有很多功能皆獲保留。
	js> outputbox js> newoutputbox replaceNode \ 同上。
	cls eleBody ce! er \ 清除畫面上的小垃圾。
	include processing.f
	js> vm.g.cv :> canvas js> cvdiv replaceNode \ Place the canvas
	\ include cloth.f 
	\ 〈爽哥〉把 cloth.f 改得漂亮多了!
	\  既然接下來也要顯示 cloth.f 而且有機會修改，不如改以讀進來用 tib.insert 方式執行。
	s" cloth.f" readTextFileAuto dup tib.insert
	( 現在 TOS 是 cloth.f source code )
	<text>
		s" body" <e> /* 直接放到 <body> 後面，不必像上面那樣用 insertBefore, replaceNode 之類的手法搬動就定位 */
		<div id=article class=essay><blockquote>
/* ----- 認識操作環境 --------------------------------------------------------------------- */
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
			<img src="doc/jeforth-demo-cloth-2015-11-201.jpg">
/* -------------------------------------------------------------------------- */
			<p>
				【交談區】初看只是上下兩塊區域，沒甚麼吧？
				其實它們提供了相當完備的 Console 或 Shell 程式的常見功能。
				例如 Command auto-completion, Previous commands recalling, 
				至於 Outputbox triming 則別地方都還沒見過。
				為了到處通用，外觀宜簡約，留給應用各自去發揮。
				請嘗試在 inputbox 打入 <code>cls</code> 命令把 outputbox 清乾淨。
				打入 <code>words</code> 列出所有的 word。
				打入 <code>help *</code> 列出所有 word 的說明。
				打入 <code>help</code> 命令查看操作功能介紹。
			</p>
			<img src="doc/jeforth-demo-cloth-words-help.jpg">
/* -------------------------------------------------------------------------- */
			<h2>cloth.f 裡有些甚麼？</h2>
/* -------------------------------------------------------------------------- */
			<p>
				以上嘗試的結果，您可能也覺得 word 好多，眼花撩亂。
				它們都是各個 ~.f 檔定義的，
				我建議把每個 ~.f 檔當成一個 Forth 語言的 vocabulary
				且直接以檔名為 name。
				Vocabulary 者，義:「一大堆單字」, 音:「我看必有熱淚」
				是 Forth 歸納眾多 word 的一招。
				這麼多 words 無論是英文或 Forth 語言都令人飆淚，所以要分門整理。
				我們只想專注在 demo 程式 cloth.f 就好，
				請打入這個命令 <code>only</code> 然後再輸入 
				<code>words</code> 試試，剛才還在的大堆指令
				(Forth 的 words) 都不見了。
				這就是 only 的作用——不看除了「基本」的以外之其他 word。
				jeforth.3we 的「基本」 word 就是在名為 
				<code>forth</code> 的 vocabulary 之內的 words 皆是。
				因為是「基本」word 所以即使 words 或 help 指令都看不到的時候
				( 一般是 only 命令視需要所為 ) 還是可以執行。 
				其他 vocabulary 裡的指令於 words 或 help 看不到時
				也就執行不到了。
				請打入命令：
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
			<blockquote><pre><code /* 影響 font-size 跟 font-family */ class=source><unindent>
				> only canvas.f also cloth.f words /* 在 <pre> 裡不自動排版， white spaces 會照著呈現 */

				-------- canvas.f (30 words) --------
				canvasStyle createCanvas cv setWorkingCanvas setCanvasSize 
				setCanvasStyle save restore translate rotate beginPath moveTo 
				lineTo closePath stroke lineWidth strokeStyle clearRect 
				fillStyle fill fillRect fillText strokeText clearCanvas arc 
				createRadialGradient createLinearGradient addColorStop 
				font move-cv-up-into-outputbox 
				-------- cloth.f (14 words) --------
				w h r g b v d xB yB xE yE random >rgba draw 
				 OK
			</unindent></code></pre></blockquote></td></table>
/* -------------------------------------------------------------------------- */
			<p>
				有這些指令已足夠畫畫兒需要。
				jeforth 可以很容易地使用
				JavaScript 所以不一定要把所有的 HTML5 Canvas 指令都包裝成
				Forth 的 word.
			</p>
/* -------------------------------------------------------------------------- */
			<h2>draw a ribbon</h2>
/* -------------------------------------------------------------------------- */
			<p>
				看到 canvas.f 裡有個 clearCanvas 指令嗎？
				請用它把 canvas 畫布整個擦掉。
				試試看只敲 <code>clear</code> 然後連按幾下 
				TAB key 自動跳出類似的 word 直到
				<code>clearCanvas</code> 出現為止即予執行。			
				cloth.f 裡只有少數幾個 word ，看到其中有個 
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
			<img src="doc/jeforth-demo-cloth-2015-11-202.jpg">
/* -------------------------------------------------------------------------- */
			<p>
				那麼 draw 是怎麼畫出一條色帶的呢？下這行命令就可以查看 
				cloth.f 的 source code:
			</p>
			<table width=100%><td class=code><blockquote><code>
				s" cloth.f" readTextFileAuto .
			</code></blockquote></td></table>
			<p>
				注意最後有個小點兒，那是 forth 用來印出 TOS 
				(Top Of Stack)
				的指令不要漏掉。
				當時的 TOS 就是 cloth.f 整個檔案的 text string，的確很短。
				您輸入 readTextFileAuto 這麼長的 word 時，可以只敲 
				<code>readt</code> 然後打幾下 TAB key 就會輪到它。
			</p>
			<table width=100%><td class=code><blockquote><pre><code class=source><unindent>
				----replace-me-with-cloth.f----
			</unindent></code></pre></blockquote></td></table>
			<h2 id="play">看到甚麼都可以玩玩看</h2>
			<p>	
				其中 <code>\ 設定</code> 這一段是在設定數值，以下可以來玩一玩。
			</p>	
			<p>	
				前面試過的 <code>draw</code> 指令這回我們用 
				<code>[for] .. [next]</code> 重複執行。
				jeforth.3we 在 interpret state 有 
				<code>[for]</code> , 
				<code>[next]</code> , 
				<code>[begin]</code> , 
				<code>[again]</code> , 
				<code>[until]</code> , 
				<code>[if]</code> , 
				<code>[else]</code> , 
				<code>[then]</code>
				這幾個掌管程式流程的指令。
				它們跟不帶方括號的相似 word 功能完全一樣，差別在：
				帶方括號的只能用在 interpret state; 不帶方括號的只能用在 
				compile state. 因為前者跑迴路時是在 Forth TIB 字串裡前後跳躍；
				後者則是在 Forth dictionary 裡。
				整串動作一口氣下達如下：
			</p>
			<table width=100%><td class=code><blockquote><code>
				clearCanvas 10 lineWidth 30 [for] draw [next] 3 lineWidth 40 [for] draw [next]
			</code></blockquote></td></table>
			<p>
				 得到這幅舉世唯一的畫作，名喚《臥虎藏龍》。
			</p>
			<img src="doc/jeforth-demo-cloth-for-next_20151126111159.jpg">
			<p>	
				其中 <code>10 lineWidth</code> 跟 <code>3 lineWidth</code>
				是設定色帶線條的寬度。<code>30 [for]...</code> 跟 <code>40 [for]...</code>
				是迴圈的次數。在 
				interpret state 操作時，我老是會忘記給這些「流程指令」加上方括號，
				所以設計了 <code>run:</code> 指令，
				用它來執行帶有「流程指令」的命令行就不必一一給它們加上方括號。
			</p>
			<table width=100%><td class=code><blockquote><code>
				run: clearCanvas 10 lineWidth 30 for draw next 3 lineWidth 40 for draw next
			</code></blockquote></td></table>
			<h2>Forth 與 中文神似</h2>
			<p>	
				Forth 語言獨特在它沒有「規定好的」語法，它只是一個 word 一個 word
				執行下去而已，我們覺得有語法是這些 word 聯合起來給人的感覺。
				FigTaiwan 的前輩們指出 Forth 跟中文神似。
				中文也是一個字一個字獨立運作，句尾加上「嗎」字把句子變成疑問句，
				而不是把主詞動詞顛倒，更不靠規定句子的結構來夾帶意義。
				所以 if 不知道有 else, 而 begin 不知道有 again, 
				因此任何人都可以拿中文字來自由擺放，
				若能形成別人也看得懂的意義就對了；
				Forth 亦然，也可以拿 Forth 的 word 不照平常的用法來擺出有效果的組合。
			</p>
			<h2>Forth 的「空性」</h2>	
			<p>
				這就形成一種有趣的結果：一般電腦語言的 function 或 
				sub-routine 都是看它裡面做什麼來命名；但咱用 Forth 
				寫程式是依我們對這個 word 的「看法」來命名。
				如果同一個 word 被你看出不同意義，
				也許就該考慮給它一個適合這個不同看法的 alias, 
				或者修改本來的 name 使它更恰當點。
			</p>
			<p>	
				讀者可能猜想 run: 這個指令是把隨後一整行命令 compile 成
				temporary word 或 annoymous word 執行。
				其實不然，將它放在 
				command line 的任何一個地方，它只是用兩行 
				Regular Expression 做文字處理，
				把之後到行尾之間的流程指令都加上方括號而已。
				這樣做可能比去 compile temporary word 更好用、更少問題。
				下面這幾行都是等效的：
			</p>	
			<UL TYPE=SQUARE /* SQUARE(實體方形)/DISC(實體圓形)/CIRCLE(空心方形) */>
			/* <LH> 標題 */
			<LI> <code class=source>run: clearCanvas 10 lineWidth 30 for draw next 3 lineWidth 40 for draw next</code>
			<LI> <code class=source>clearCanvas 10 lineWidth 30 run: for draw next 3 lineWidth 40 for draw next</code>
			<LI> <code class=source>clearCanvas 10 lineWidth 30 [for] draw [next] 3 lineWidth 40 run: for draw next</code>
			</UL>				
			<p>
				您可以用 <code>see run:</code> 以及 <code>see (run:)</code> 
				命令來查看它的定義，實在跟「run、執行」毫無關係。
				看吧！ run: 就是根據「我這時候覺得它是甚麼」來命名的，
				Forth words 本身性空，意義都是我們「左看右看」隨心情給的。
				這種情形在 Forth 裡比比皆是。
				與中文神似，又加上「空性」使得設計得當的 Forth words 意味深長。
			</p>
			<h2 id="help">每個 word 都有 help</h2>
			<p>
				上面 source code 裡 <code>\ 設定</code> 區有定義 b 與 g 兩個 word。
				請分別輸入 <code>help b -N</code> 與 <code>help g -N</code>
				查看這兩個 word 的說明。加上 -N 指定 word name 
				要完全吻合而非相近的指令，詳閱 <code>help help -N</code>。
			</p>
			<img src="doc/jeforth-demo-cloth-help-b-help-g_20151126160042.png">				
			<p>
				看出來它們的「說明」是哪兒來的嗎？
				當初定義時寫下 Forth 慣用的註解跑到 help 裡來了。
				還指出了它們是在 cloth.f 裡定義的，而且是個 value。
				旁邊兩個 <code>[][]</code> 說明它們不是 <code>[IMMEDIATE][COMPILE-ONLY]</code>.
				既知是 value 即知直接 b 或 g 得其值，而 <code>123 to b</code> 
				就是賦予 b 新值 123。我們要讓名畫《臥虎藏龍》多點春天的氣息，可將 
				setup 區段裡定義的 
				b (藍色的中心強度) 跟 
				g (綠色的中心強度) 兩個 value 改一改：
				<code>100 to b 200 to g</code>
				安排好了之後照上面用過的命令重畫即得，您做做看。
				(copy 好以下 command line 按 ESC key 就馬上跳往 inputbox)
			</p>
			<table width=100%><td class=code><blockquote><code>
				run: 100 to b 200 to g clearCanvas 10 lineWidth 30 for draw next 3 lineWidth 40 for draw next
			</code></blockquote></td></table>
			
			<h2 id="JavaScriptForth">Forth 融合 JavaScript</h2>
			<p>
				Forth 無拘無束的特性使它可以順順地吸納別的語言、
				或者過渡到不同語言的語境，再過渡回來。
				同樣的目的別的有「語法」的語言也許都能做，
				但是表達方式就囉嗦到令人難以忍受了。
				我們先示範 HTML5 的 JavaScript 繪圖指令。
				請用之前用過的 <code>clearCanvas</code> 指令把畫布抹乾淨。
				然後在 inputbox 一口氣輸入以下
				command line <code>cv . help cv -N</code> 
				其中 cv 是我們的畫布 (canvas object) 隨後的小點兒是把
				cv 的值打印出來；緊接著是去看 cv 的說明。結果如下：
			</p>
			<img src="doc/jeforth-demo-cloth-cv-help.jpg">
			<p>
				只要拿到 canvas object 就可以來塗鴉了，請按幾下 F10 把 inputbox 變大一點
				(F9 把它縮小) 然後 copy-paste 以下這段命令進去執行：
			</p>
			<table width=100%><td class=code><blockquote><pre><code class=source><unindent>
				cv <js>
				tos().beginPath();
				tos().moveTo(0,0);
				tos().lineTo(100,100);
				pop().stroke();
				</js>
			</unindent></code></pre></blockquote></td></table>
			
			<p>
				看到畫布上出現了一條從座標 (0,0) 到 (100,100) 的直線？
				<code>cv</code> 指令把 canvas object 留在 TOS，隨後 
				<code> <js>...</js> </code>
				之間的都是 JavaScript statements. 其中的 <code>tos()</code> 使用
				TOS 但是不把它「用掉」，到了最後下達 stroke() 時，改用
				<code>pop()</code> 取用 TOS 這才把它給「用掉」。這是一段最基本的 HTML5
				canvas 繪圖。最後面的 <code> </js> </code>
				是「不傳回最後 statement 的 Value」，如果改用
				<code> </jsV> </code> 則會把這些 
				JavaScript statements 中最後一條的 Value
				放上 TOS 傳回。例如：
				<blockquote class=code><code>cv <js> pop().canvas.width</jsV> .s</code></blockquote>
				查出畫布的寬度，結果留在 TOS，您試試看。
				jeforth.3we 使用 JavaScript 的機會非常頻繁，我們有簡化的寫法提供當 
				statements 整串都沒有 white space 時使用，例如：
				<blockquote class=code>cv <b style=font-size:120%>js></b> pop().canvas.width</blockquote>
				是有傳回值的；
				<blockquote class=code>cv <b style=font-size:120%>js:</b> pop().beginPath()</blockquote> 
				是沒有傳回值的。
				早期我曾建議 Forther 直接引用 JavaScript 的 Object 
				語法如上，不要另訂「Forth 式的 object oriented 語法 」寫法。
				結果像上面 <code>object js> pop().something</code>
				或 <code>object js> pop()[something]</code>
				這樣的 pattern 出現得太多了，程式裡到處都是，所以有類似於： 
				<blockquote class=code>cv <b style=font-size:120%>:></b> canvas.width</blockquote>
				以及
				<blockquote class=code>cv <b style=font-size:120%>::</b> beginPath()</blockquote> 
				分別再簡化的寫法，縮減常用的 pattern。
				所有的簡化寫法都只是文字 pattern 的替代而已，所以 compile 出來是一樣的。
				而且像這樣一直點下去也是可以的：
				<blockquote class=code><code>cv :> canvas.getContext('2d').canvas.getContext('2d')</code></blockquote>
				相當於：
				<blockquote class=code><code>cv js> pop().canvas.getContext('2d').canvas.getContext('2d')</code></blockquote>
				Statements 當中有 white space 時，就必須用 
				<code><js>...</js></code> 或
				<code><js>...</jsV></code>
				的原形，不要忘記。到這裡我們可以來改寫以上的畫線程式了：
			</p>
			<table width=100%><td class=code><blockquote><pre><code class=source><unindent>
				cv :: beginPath()
				cv :: moveTo(0,0)
				cv :: lineTo(100,100)
				cv :: stroke()
			</unindent></code></pre></blockquote></td></table>
			<p>
				這四行 statements 看起來既像 Forth 又像 JavaScript, 
				分辨它們到底屬甚麼，不如著眼在整個行文給人的感覺，
				而這樣寫語意通順就對了。Forth 有融合多種語言的超能力！
			</p>
			<h2 id="bp">jeforth.3we 的 debug</h2>
			<p>
				draw 指令的定義裡面由 beginPath 到 
				strokeStyle 之間是在調製顏色。請在 source code 裡 strokeStyle 之前找到
				<code>( *debug* Draw> )</code>
				這是個 Forth 的 comment, 
				把括號去掉即可讓 Break point 指令 <code>*debug*</code>
				起來工作。
			</p>
			<p>
				請把 draw 的 source code 抄寫進 inputbox, 按一下 F2 key
				讓 inputbox toggle 進入 edit mode, 
				( 再次提醒 F9/F10 可以把 inputbox 縮小/放大 )
				然後進行上述修改。
				再按一下 F2 key 取消 edit mode，即予執行得到新的 draw 指令。
			</p>	
			<p>	
				此後 draw 執行到這裡就會暫停，回到 inputbox 
				等你的下一個命令。
				這時候大部分的 Forth word 應該都可以用，幫助你調查此瞬間一刻。
				請下達 <code>.s</code> 
				查看 stack 內容就很容易明白原來這段程式是在組合一段
				text string 準備要餵給 strokeStyle。
				進到 *debug* break point 的特徵是 <code>OK</code> 
				prompt 被改成了我們任意指定的字樣 <code>Draw></code>。
				如果一次埋下了多個 *debug* break point 就需要靠個別不同的
				prompt 來看出是哪一個 break 到了。
				最後要讓程式繼續跑下去，用 <code>q</code> 指令，
				這用 <code>also forth help *debug*</code> 也可以查得到
				( 剛才我們亂玩下過 only 這下得要 also forth 把
				forth vocabulary 加回 order
				之後 help 才看得到它裡面的 *debug* )
				
			</p>
			<table width=100%><td class=code><blockquote><pre><code class=source><unindent>
				> draw

				---- Entering *debug* ----
				 Draw> 
				> .s
					  0: rgba(76,60,148,0.53) (string)
				 Draw> 
				> q

				 ---- Leaving *debug* ----
				 OK  
			</unindent></code></pre></blockquote></td></table>

			<h2>查看本文的 source code</h2>
			<p>
			這篇文章 tutor-cloth.f 本身就是一支 jeforth.3htm 的應用程式。
			下達這段命令就可以把它讀出來放到這個網頁的最下面，請試著親手操作看看。
			您也可以把 jeforth.3we 從 GitHub 上 clone 
			下來找到 tutor-cloth.f 就是了。
			我盡量都寫了註解，請多指教。
			</p>
			<table width=100%><td class=code><blockquote><pre><code class=source><unindent>
				s" tutor-cloth.f" readTextFileAuto \ 讀取本文的 source code
				^tab>spaces \ 把行首的 Tab 都換成 tab-spaces 避免過度內縮不好看。
				<o> <textarea rows=24></textarea>&lt;/o> \ 變出一個 <textarea>, 小心 &lt;/o> 要改成 &amp;lt;/o>
				js: tos().value=pop(1) \ 把 source code 填入 <textarea>, TOS 是這個 <textarea> 的 object
				js> article \ article 是本文最後一段的 element ID
				insertAfter \ 把剛才變出來的 <textarea> 搬到 article 之後，否則就留在 outputbox 裡了。
			</unindent></code></pre></blockquote></td></table>
			
			<h2 id=3we>jeforth.3we 簡介</h2>
			<p>
				jeforth 是 「台灣符式協會 FitTaiwan」 兩位先進 
				Yap 與 爽哥 所提示之用 JavaScript 打造 Forth 系統的方法。
				我依法做出來的結果就稱為 jeforth.3we (3 Words Engine) 統稱同一個 
				kernel 在不同環境的各種版本。
				3we 當中的 3 之後加上一點點努力就是 Forth 語言的吉祥數字 4， 
				而目前「we」則有 jeforth.3htm (HTML), jeforth.3hta (Microsoft HTML Application), 
				jeforth.3nd (Node.js), jeforth.3nw (Node-Webkit or NW.js) 等。
				在本網頁上呈現的是 jeforth.3htm 的應用。
			</p>	
			<p>--- The End ---</p>	
			<p>H.C. Chen hcchen5600@gmail.com 2015.12.02</p>
			<p>FigTaiwan http://groups.google.com/group/figtaiwan</p>
		</blockquote></div>
		</e> drop \ <e>..</e> 留下的最後一個 element 沒用到，丟掉。
	</text>
	:> replace(/----replace-me-with-cloth\.f----/,pop()) \ cloth.f source code 就顯示定位
	:> replace(/\/\*(.|\r|\n)*?\*\//mg,"") \ 清除註解。
	unindent 		\ handle all <unindent >..</unindent > sections
	<code>escape	\ convert "<>" to "&lt;&gt;" in code sections
	tib.insert		\ execute the string on TOS
\ ---------- The End -----------------
	