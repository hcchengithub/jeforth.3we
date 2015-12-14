
	\ editor.f 
	\ Editor commands for 3hta and 3nw to edit HTML documents directly
	\ in jeforth window.
	
	include unindent.f
	
	s" editor.f" source-code-header
	
	char %HOMEDRIVE%%HOMEPATH%\Documents\GitHub\jeforth.3we\playground\ env@
	value working-directory // ( -- "path" ) 

	char c:\Users\hcche\Documents\GitHub\jeforth.3we\playground\editor-study.html 
	value pathname // ( -- "pathname" ) Path/Filename of the working document

	null value article // ( -- objArticle ) The DIV world of the file to be edited.
	<text>
		<h> /* <h>..</h> 是寫東西進 HTML 的 <head> 裡 */
			<style id=mystyle type="text/css">
				/* 整篇文章的默認設定 */
				.default { 
					/* https://zh.wikipedia.org/zh-tw/Font_family_(HTML) */
					/* https://zh.wikipedia.org/wiki/%E9%BB%91%E4%BD%93_(%E5%AD%97%E4%BD%93) */
					/* 微軟正黑(tw) Microsoft JhengHei; 微軟雅黑(cn) Microsoft Yahei; */
					/* 標楷體(tw) DFKai-SB;  courier new; */
					font-family: Microsoft JhengHei;  /* 微軟正黑(tw) */
					letter-spacing: 0px;
					line-height: 160%;
					tab-size:4; /* IE,Edge 無效(hcchen5600 2015/12/07 11:51:34); Chrome 有效  */
				}
				/* <code> 除了 style 還標示要做 < &lt; > &gt; 轉換的區域，所以一定是最內層 */
				code { 
					font-family: courier new;
					font-size: 110%; /* 通常夾在字裡行間 courier 的筆畫細所以要大一點 */
					background: #E0E0E0; /* <code> 夾在字裡行間時凸顯之 */
				}
				/* .commandline 跟 .source 能不能合併成 .code 一個就好，大家都用？ */
				.commandline { /* 用來修飾 <table class=commandline> */
					width: 90%;
					background: #E0E0E0; /* <code> */
				}
				.source {  /* 用來修飾 <code class=source> */
					font-size: 100%;   /* againt the in-line bigger font-size of <code> */
					line-height: 120%; /* againt the default */
				}
			</style>
		</h> drop \ /* 丟掉 <h>..</h> 留下來的 <style> element object, 用不著 */
	</text> 
	/*remove*/ 		\ :> replace(/\/\*(.|\r|\n)*?\*\//mg,"") \ 清除註解。
	unindent 		\ handle all <unindent >..</unindent > sections
	<code>escape	\ convert "<>" to "&lt;&gt;" in code sections
	tib.insert		\ execute the string on TOS

	: save ( -- ) \ Save the editing document
		char log.save execute \ also save the recent outputbox
		article if \ avoid destroy the file with empty
			js> mystyle.length \ 可能跟 editor.f 的重複定義了
			if js> mystyle[mystyle.length-1] \ 用最後一個
			else js> mystyle then 
			( mystyle ) :> outerHTML+myarticle.outerHTML
			pathname writeTextFile 
		then ;

	: save-as ( "path-name" -- ) \ Save the editing document to the specified pathname
		cr ." Sorry, under constructing " cr ;


	: old-open ( "path-name" -- ) \ Read the file to edit
		article if article :: innerHTML="" ( 有的話清除現有頁面 ) else 
		<o> <div style="background-color:white"></div></o> to article ( 沒現成就新建頁面 )
		article js> outputbox insertBefore ( 新建的默認放在 outputbox 之前 )
		then pathname readTextFile article :: innerHTML=pop() ;
	: open ( "path-name" -- ) \ Read the file to edit
		pathname readTextFile ( file ) js> tos().length if
			article if article :: innerHTML="" ( 有的話清除現有頁面 ) else 
			<o> <div style="background-color:white"></div></o> to article ( 沒現成就新建頁面 )
			article js> outputbox insertBefore ( 新建的默認放在 outputbox 之前 )
			then article :: innerHTML=pop() 
		else ." Warning! can't read the file: " pathname . cr then ;
	
	null value div-editbox // ( -- element ) The entire DIV node of the editbox.
	
	: editbox  ( -- element ) \ Create an editbox at outputbox
		char editbox-close execute \ editbox 只能有一個，因為其中的 editboxtextarea id 必須唯一。
		<text> <div>
			<textarea id=editboxtextarea rows=8></textarea>
			<input type=button value=Save  onclick="kvm.execute('editbox-save')" />
			<input type=button value=Bigger onclick="kvm.execute('editbox-bigger')" />
			<input type=button value=Smaller onclick="kvm.execute('editbox-smaller')" />
			<input type=button value='<' onclick="kvm.execute('editbox-before')" />
			<input type=button value=Parent onclick="kvm.execute('editbox-parent')" />
			<input type=button value=Back onclick="kvm.execute('editbox-pop')" />
			<input type=button value='>' onclick="kvm.execute('editbox-after')" />
			<input type=button value='Refresh' onclick="kvm.execute('editbox-refresh')" />
			<input type=button value='Example' onclick="kvm.execute('editbox-example')" />
			<input type=button value=Close onclick="kvm.execute('editbox-close')" />
		</div></text> </o> ;

	:  editbox-save ( -- ) \ ce@ is the target element.
		js> editboxtextarea.value 
		/*remove*/ <code>escape
		</o> dup ce@ replaceNode ce! 
		jump-to-ce@ ;  
		
	: 	editbox-close ( -- ) \ ce@ is the target element.
		begin 
			js> document.getElementById("editboxtextarea") if 
				\ 這個 id 必須唯一，還看得見就是有例外狀況了，可能是之前的還沒有 close。
				js> editboxtextarea dup :: removeAttribute("id") removeElement 
				false 
			else true then 
		until
		div-editbox js> tos()&&tos().parentNode 
		if removeElement then null to div-editbox 
		jump-to-ce@ ;

	: node-source ( node -- "source" ) \ Get outerHTML or nodeValue
		dup :> outerHTML ?dup if ( node outerHTML ) nip 
		else ( node ) dup :> toString() char /* swap + js> "*/\n" + 
		swap ( /*...*/ node ) :> nodeValue ?dup if + then then ;
		
	: 	editbox-parent ( -- ) \ Change element to ce's parent
		char .. (ce) node-source js: editboxtextarea.value=pop() ;

	: 	editbox-before ( -- ) \ Change element to ce's sibling
		char < (ce) node-source js: editboxtextarea.value=pop() ;

	: 	editbox-after ( -- ) \ Change element to ce's sibling
		char > (ce) node-source js: editboxtextarea.value=pop() ;

	: 	editbox-pop ( -- ) \ Change element to the previous ce
		char pop (ce) node-source js: editboxtextarea.value=pop() ;

	: editbox-refresh ( -- ) \ Reload current element
		ce@ node-source js: editboxtextarea.value=pop() ;

	: editbox-example ( -- ) \ Show example
		<text> <unindent>
		/* Source code 區塊
			<table class=commandline style="margin-left: 2em;">
			<td><pre><code class=source>
			...
			</code></pre></td></table> 
		*/
		/*
			<span style="font:italic small-caps bold 12px/1.2em Arial;"></span>
		*/
		/* 貼圖
		    <img src="doc/editor.png"> */
		/* HTML, CSS 參考資料
			HKIWC 香港網頁學院 www.hkiwc.com/html/index.html 
			梦之都 CSS www.dreamdu.com 
		*/
		</unindent></text> unindent
		js> '\n' + ce@ node-source + js: editboxtextarea.value=pop() ;

	code editbox-smaller ( -- ) \ Smaller editbox
		var r = editboxtextarea.rows;
		if(r<=4) r-=1; else if(r>8) r-=4; else r-=2;
		editboxtextarea.rows = Math.max(r,1); end-code

	code editbox-bigger ( -- ) \ Bigger editbox
		var r = editboxtextarea.rows;
		if(r<4) r+=1; else if(r>8) r+=4; else r+=2;
		editboxtextarea.rows = Math.max(r,1); end-code

	: edit ( -- ) \ Edit the ce (current element) outerHTML.
		editbox to div-editbox \ create editbox and get its object
		ce@ node-source js: editboxtextarea.value=pop() \ target source code
		div-editbox js> $(pop()).offset().top \ get editbox position
		js: window.scrollTo(0,pop()) \ jump to editbox
		;
	
	: content-handler ( -- ) \ Launch the Editbox to edit ce@ which is the anchorNode.
		<js> confirm("jeforth: You double-clicked at a node, want to Edit it?")</jsV> if
			outputbox-edit-mode-off
			js> window.getSelection().anchorNode ce! edit 
			false
		else true then ;
		/// Ctrl-F2 or Double-Click
		
	: hide ( -- ) \ 暫時把文章 hide() 起來
		article js: $(pop()).hide() ;
		
	: show ( -- ) \ 把文章 show() 回來
		article js: $(pop()).show() ;
		
	: log.open ( -- )  \ Get the log.json[last] back to outputbox
		char log.json readTextFile js> JSON.parse(pop()) \ 把整個 log.json 讀回來成一個 array。
		:> slice(-1) ( char <div> swap + char </div> + ) </o> drop ; 
		/// 讀出最後一個 snapshot 還原到最後面不破壞現有的 outputbox。

	: log.save ( -- ) \ Save outputbox to log.json[last] replace the older.
		js> outputbox :> innerHTML ( outputbox.innerHTML )
		char log.json readTextFile js> JSON.parse(pop()) \ 把整個 log.json 讀回來成一個 array。
		:> slice(0,-1) dup ( outputbox.innerHTML array array ) :: push(pop(1))
		( array ) js> JSON.stringify(pop()) char log.json writeTextFile ;

	: log.length ( i -- )  \ Get the log.json array length
		char log.json readTextFile js> JSON.parse(pop()) \ 把整個 log.json 讀回來成一個 array。
		:> length ; 

	: log.push ( -- ) \ Push outputbox to log.json.
		js> outputbox :> innerHTML ( outputbox.innerHTML )
		char log.json readTextFile js> JSON.parse(pop()) \ 把整個 log.json 讀回來成一個 array。
		dup ( outputbox.innerHTML array array ) :: push(pop(1))
		( array ) js> JSON.stringify(pop()) char log.json writeTextFile ;
		/// 這個應該用得不多，要臨時把 outputbox 保存起來時有用。
		
	: log.pop ( -- )  \ Pop log.json back to outputbox
		char log.json readTextFile js> JSON.parse(pop()) \ 把整個 log.json 讀回來成一個 array。
		dup :> pop() ( char <div> swap + char </div> + ) </o> drop \ 取最後一個 snapshot 還原到 outputbox
		( array ) js> JSON.stringify(pop()) char log.json writeTextFile ;
		/// log.json 裡不再保留最新 snapshot 還原到最後面不破壞現有的 outputbox。

	: log.recall ( i -- )  \ Recall the log.json[i] back to outputbox
		char log.json readTextFile js> JSON.parse(pop()) \ 把整個 log.json 讀回來成一個 array。
		( i array ) :> [pop()] ( char <div> swap + char </div> + ) </o> drop ; 
		/// No No No! Auto log.save current outputbox before recalling is a terrible idea.
		/// recall 出來放到最後面不破壞現有的 outputbox。

	: log.overwrite ( -- ) \ Drop older log.json, save outputbox to log.json[0]
		<js> confirm("Overwrite the entire jason.log! Are yous sure?")</jsV> if
		js> outputbox :> innerHTML ( outputbox.innerHTML )
		[] dup ( outputbox.innerHTML array array ) :: push(pop(1))
		( array ) js> JSON.stringify(pop()) char log.json writeTextFile then ;
		/// 這個應該都用不著，要小心。
\ -- End --
