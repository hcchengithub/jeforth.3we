
	s" unindent.f" source-code-header
	
	\ 本 module 定義一些補充 HTML 的命令。
	
	\ ----------- unindent -----------------
	\ unindent 讓你可以在 ~.f 檔的 HTML sections 中使用 <unindent >...</unindent >
	\ 以保持 source code 整體一致的 indention。
	\ jeforth.3we 可以跑出互動網頁做推廣教學用途  ---- (1)
	\ 因此 source code 本身的美觀也要重視。 ---- (2) 
	\ (1) 會用到很多 <pre>..</pre> section 其中 indent 與周邊不一致，因此
	\ 與 (2) 有點不合。今設計 <unindent >...</unindent > 來跟 <pre> 配合使
	\ 用，使其中的 code 在 source 中仍可用 indent 保持美觀，但是執行前用 
	\ unindent 命令把前導的 white spaces 都過濾掉以配合 <pre> 區段的原意。
	\ 本來以為很簡單，沒想到搞成一整個檔案！ hcchen 2015/11/30 

	\ ---------- Tab to spaces for <UnindenT>..</UnindenT> -------------------------------
	s"     " value tab-spaces // ( -- value ) Tab spaces setting for <unindent >..</unindent > tag.
	: (^tab>spaces) ( "string" -- "cooked" ) \ Replace ^\t* with spaces
		tab-spaces swap ( tab-spaces "input" )
		\ 先把 "^\t*\S.*"+'x' 切開成 "^\t*", "\S.*x". 
		\ Where the dummy leading \t and tailing x guarantees the pattern
		js> '\t' swap + char x + :> match(/(^\t*)(.*)/) ( tab-spaces [0:all][1:\t*][2:.*x] )
		\ 把 [1] 全部 \t 換成 space
		<js> tos()[1].replace(/\t/g,pop(1))</jsV> ( [0:all][1:\t*][2:\S.*x] "1:spaces" )
		\ 把後半部接回去並去掉 dummy x
		js> pop(1)[2] + :> slice(4,-1) ;		
		/// Value tab-spaces specifies how many spaces to replace a TAB.
		/// Works on a single line only.
		/// 只針對行首的連續 \t 轉換。

	: ^tab>spaces ( "text" -- "cooked" ) \ Replace all ^\t* with spaces
		:> split(/\r?\n\r?/) >r ( R: string-array )
		r@ :> length dup for ( total | string-array countDown )
			dup r@ - ( total i ) 
			js> rtos(1)[tos()] ( total i line[i] ) \ 拿出一行
			(^tab>spaces)  ( total i cooked ) 	   \ 轉換 ^\t*
			js: rtos(1)[pop(1)]=pop() ( total )    \ 放回去
		next drop r> :> join('\n') ;
		/// 把整個 text string 每一行的領頭 \t 都換成 tab-spaces

	\ ---------- <Unindent>...</Unindent> --------------------------------------------------
	code all-blank? ( string-array -- T/f ) \ Are string-array lines all white spaces?
		push(pop().join("").search(/\S/)==-1)
		end-code
	code <string-array	( string-array -- shifted-array ) \ Remove the 1st char of all lines
		for(var i=0,aa=pop(); i<aa.length; i++) 
			if (aa[i].length) aa[i] = aa[i].slice(1);
		end-code
		/// Sift left of the entire string-array.
		/// Do nothing to blank lines.
	code hit-left-end? ( string-array -- T/f ) \ Check if any \S at 1st char of any line.
		for(var i=0,aa=pop(),flag=false; i<aa.length; i++) {
			if (aa[i].length) {
				if (aa[i].search(/^\S/)!=-1) {
					flag = true;
					break;
				}
			}
		}		
		push(flag)
		end-code
		/// Unindent 已經完成的條件。
	: <paragraph ( "paragraph" -- "shifted" ) \ 整段 paragraph 往左 shift 到有某一行撞到左邊為止。
		^tab>spaces dup :> split(/\r?\n\r?/) >r ( string | string-array )
		r@ all-blank? if r> drop exit then drop \ leave the string, do nothing
		\ ---- 整段往左移 ----------------
		begin ( R: string-array ) \ one loop shift left one char
			r@ hit-left-end? if r> :> join('\n') exit then \ 出口
			r@ <string-array 
		again ;
	: (unindent) ( "input" -- "cooked" ) \ Shift left all "foo <unindent >..< /unindent> bar" sections
		:> split(/(<un\indent>|<\/un\indent>)/) >r \ \i == i 避免本身被掃到
		\ split 的結果：[之前][<unindenT>][中間][</unindenT>][重複]...
		"" ( cooked ) begin 
			r@ :> shift() dup undefined = if drop r> drop exit then + ( cooked )  \ 之前
			r@ :> shift() dup undefined = if drop r> drop exit then drop ( cooked )  \ <Unindent>
			r@ :> shift() dup undefined = if drop r> drop exit then <paragraph + ( cooked ) \ 中間
			r@ :> shift() dup undefined = if drop r> drop exit then drop ( cooked )  \ </Unindent>
		again ;
		/// 尚未寫出 break 為了有用到 exit 只好把 (unindent) 分離出來
		/// 否則這個 block 之後的部分執行不到。
	: unindent ( "input" -- "cooked" ) \ Shift left all <unindent >..</unindent > sections
		s" x" swap + s" x" + \ add dummy 'x' guarantee the pattern 
		(unindent) :> slice(1,-1) \ remove dummy 'x'
		;
		
	<comment> 
		\ 實驗範例
		s" unindent.f" readTextFileAuto constant ss // ( -- string ) ss 是本程式 source code
		ss . \ 看原來的 source code
		ss unindent . \ 看過濾 <unindenT>..</unindenT> 之後的結果
		
				I should be indented
				x<unindent>
				y
				I should not be indented
				x</unindent>y
				I should be indented z <unindent>
				I should not be indented </unindent> 
				I should be indented
				<unindent>
				I should not be indented
				</unindent> 
				I should be indented

	</comment>

	\ ----------- <code>escape -----------------
	\ <code> ... </code> 裡面的 < > 不希望被 HTML 認到, 以下寫出 <code>escape 命令
	\ 來避免之。方法是預先把 <code>...</code> 當中的 <> 改成 &lt;&gt;
	
	code <>escape ( "lines" -- "cooked" ) \ '<' '>' to "&lt;" "&gt;"
		var result = pop().replace(/</mg,"&lt;").replace(/>/mg,"&gt;")||"";
		push(result);
		end-code
		/// Support multiple lines
		
	: (<code>escape) ( "raw" -- "cooked" ) \ foo <code>'<' '>' to "&lt;" "&gt;"</code> bar
		\ 規定 <code> ... </code> 不能 nested, 而且要成對依序出現。
		\ foo bar 都存在時，經此 split() 之後一定是 foo,<code>,<>,</code>,bar 的形式。
		:> split(/(<code.*?>|<\/code>)/) >r \ <code foo=bar> 也要考慮
		"" ( cooked ) begin 
			r@ :> shift() dup undefined = if drop r> drop exit then + ( cooked )
			r@ :> shift() dup undefined = if drop r> drop exit then + ( cooked )
			r@ :> shift() dup undefined = if drop r> drop exit then <>escape + ( cooked )
			r@ :> shift() dup undefined = if drop r> drop exit then + ( cooked )
		again ;
		/// foo bar must be both existing
		/// Support multiple lines
	
	: <code>escape ( "raw" -- "cooked" ) \ <code>'<' '>' to "&lt;" "&gt;"</code>
		s" x" swap + s" x" + \ add dummy 'x' guarantee the pattern 
		(<code>escape)
		:> slice(1,-1) \ remove dummy 'x'
		;
		/// Support multiple lines
		/// 只針對 <code> ... </code> 裡面。
		
	\ ----------- /* remove comment */ -----------------
	: /*remove*/ ( "raw" -- "cooked" ) \ remove /* comments */ 
		:> replace(/[/]\*(.|\r|\n)*?\*[/]/mg,"") ; \ HTA 不能用 \/ 必須用 [/]
		/// 使 /* ... */ 可以用在 HTML 裡面。
		/// Support multiple comment lines in one pare of /* .. */
		/// Not support nested.
		
	\ --- End ---
	