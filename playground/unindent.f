
	s" unindent.f" source-code-header
	

	\ 本程式讓你可以在 ~.f 檔的 HTML sections 中使用 <unindent >...</unindent >
	\ 以保持 source code 整體一致的 indention。
	
	\ tutor-cloth.f 是第一個例子
	\ jeforth.3we 可以跑出互動網頁做推廣教學用途  ---- (1)
	\ 因此 source code 本身的美觀也要重視。 ---- (2) 
	\ (1) 會用到很多 <pre>..</pre> section 其中 indent 與周邊不一致，因此
	\ 與 (2) 有點不合。今設計 <unindent >...</unindent > 來跟 <pre> 配合使
	\ 用，使其中的 code 在 source 中仍可用 indent 保持美觀，但是執行前用 
	\ unindent 命令把前導的 white spaces 都過濾掉以配合 <pre> 區段的原意。
	
	\ 本來以為很簡單，沒想到搞成一整個檔案！ hcchen 2015/11/30 

	\ ---------- Tab to spaces for <UnindenT>..</UnindenT> -------------------------------
	s"     " value tab-spaces // ( -- value ) Tab spaces setting for <unindent >..</unindent > tag.
	: ^tab>spaces ( "string" -- "cooked" ) \ Replace ^\t* with spaces
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
		dup :> split(/\r?\n\r?/) >r ( string | string-array )
		r@ all-blank? if r> drop exit then drop \ leave the string, do nothing
		\ ---- 轉換行首的 TAB ------------
		r@ :> length dup for ( total | string-array countDown )
			dup r@ - ( total i ) 
			js> rtos(1)[tos()] ( total i line[i] ) \ 拿出一行
			^tab>spaces  ( total i cooked ) 	   \ 轉換 ^\t*
			js: rtos(1)[pop(1)]=pop() ( total )    \ 放回去
		next drop 
		\ ---- 整段往左移 ----------------
		begin ( R: string-array ) \ one loop shift left one char
			r@ hit-left-end? if r> :> join('\n') exit then \ 出口
			r@ <string-array 
		again ;
	: (unindent) ( "input" -- "cooked" ) \ Shift left all "foo <unindent >..< /unindent> bar" sections
		:> split(/(<un\indent>|<\/un\indent>)/) >r \ \i == i 
		\ split 的結果：[之前][<Un\indent>][中間][</Un\indent>][重複]...
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
		(unindent) :> slice(1,-1) ( remove dummy 'x' ) ;
		
	<comment> 
		\ 實驗範例
		s" unindent.f" readTextFileAuto constant ss // ( -- string ) ss 是本程式 source code
		ss . \ 看原來的 source code
		ss unindent . \ 看過濾 <unindenT>..</unindenT> 之後的結果
		
				I should be indented
				<unindent>
				I should not be indented
				</unindent> 
				I should be indented
				<unindent>
				I should not be indented
				</unindent> 
				I should be indented
				<unindent>
				I should not be indented
				</unindent> 
				I should be indented
				<unindent>
				I should not be indented
				</unindent> 
	</comment>
	