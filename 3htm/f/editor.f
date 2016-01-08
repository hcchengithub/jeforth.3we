
	\ editor.f 
	\ Editor commands for 3hta and 3nw to edit HTML documents directly
	\ in jeforth window.
	
	include 3htm/f/unindent.f
	
	s" editor.f" source-code-header

\ editbox 

	null value div-editbox // ( -- element ) The entire DIV node of the editbox.
	
	\ Setup the handler of clicks that are poping up the editbox.
	<js>
		body.onclick = function(){
			push(true); // true let the river run, false stop bubbling
			execute("single-click"); // execute() does nothing if undefined yet
			return(pop()); // right-click ( flag -- ... flag' )
		}
	</js>

	: unenvelope ( element -- firstNode ) \ Break an element into its children nodes
		( ele ) js> tos().childNodes.length ?dup if ( ele length ) 
			( ele length ) js> tos(1).firstChild -rot ( first0 ele length ) 
			for ( first0 ele )
				js> tos().firstChild over ( first0 ele first ele ) 
				insertBefore ( first0 ele )
			next ( first0 ele )
			removeElement ( first0 )
		then ;
		/// if the given element has no child then leave itself on the TOS.
		/// Return the first node to be the new ce@ after editbox-save.
	
	: editbox_save ( -- ) \ Save editbox to ce@ which is the target element.
		js> editboxtextarea.value 
		/*remove*/ <code>escape
		char <span> swap + char </span> + <o>escape </o> \ 套一圈 <span> 保證它是 one node
		dup ce@ replaceNode unenvelope ce! ; \ New nodes replace the old one then 解套
		
	: editbox_close ( -- ) \ Close the editbox
		begin 
			js> document.getElementById("editboxtextarea") if 
				\ 這個 id 必須唯一，還看得見就是有例外狀況了，可能是之前的還沒有 close。
				js> editboxtextarea dup :: removeAttribute("id") removeElement 
				false 
			else true then 
		until
		div-editbox if 
			div-editbox :> parentNode 
			if div-editbox removeElement then 
		then
		null to div-editbox ;
		
	: editbox_saveclose ( -- ) \ Save editbox to ce@ which is the target element.
		editbox_save editbox_close ;

	: node-source ( node -- "source" ) \ Get outerHTML or nodeValue
		dup :> outerHTML ?dup if ( node outerHTML ) nip 
		else ( node ) dup :> toString() char /* swap + js> "*/\n" + 
		swap ( /*...*/ node ) :> nodeValue ?dup if + then then ;
		
	: editbox_parent ( -- ) \ Change element to ce's parent
		char .. (ce) node-source js: editboxtextarea.value=pop() ;

	: editbox_before ( -- ) \ Change element to ce's sibling
		char < (ce) node-source js: editboxtextarea.value=pop() ;

	: editbox_after ( -- ) \ Change element to ce's sibling
		char > (ce) node-source js: editboxtextarea.value=pop() ;

	: editbox_pop ( -- ) \ Change element to the previous ce
		char pop (ce) node-source js: editboxtextarea.value=pop() ;

	: editbox_refresh ( -- ) \ Reload current element
		ce@ node-source js: editboxtextarea.value=pop() ;

	: editbox_example	( -- ) \ Show example
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

	code editbox_smaller ( -- ) \ Smaller editbox
		var r = editboxtextarea.rows;
		if(r<=4) r-=1; else if(r>8) r-=4; else r-=2;
		editboxtextarea.rows = Math.max(r,1); end-code

	code editbox_bigger ( -- ) \ Bigger editbox
		var r = editboxtextarea.rows;
		if(r<4) r+=1; else if(r>8) r+=8; else r+=4;
		editboxtextarea.rows = Math.max(r,1); end-code

	: create-editbox  ( -- ) \ Create an editbox at outputbox
		char editbox_close execute \ editbox 只能有一個，因為其中的 editboxtextarea id 必須唯一。
		<text> <div>
			<textarea id=editboxtextarea rows=8></textarea>
			<input type=button value='<'              class="editbox_before    " />
			<input type=button value=Parent           class="editbox_parent    " />
			<input type=button value=Back             class="editbox_pop       " />
			<input type=button value='>'              class="editbox_after     " />
			<input type=button value='Refresh'        class="editbox_refresh   " />
			<input type=button value='Example'        class="editbox_example   " />
			<input type=button value=Bigger           class="editbox_bigger    " />
			<input type=button value=Smaller          class="editbox_smaller   " />
			<input type=button value="Save w/o close" class="editbox_save      " />
			<input type=button value="Save & Close"   class="editbox_saveclose " />
			<input type=button value=Close            class="editbox_close     " />
			<input type=button value=Jump             class="editbox_jump      " />
		</div></text> </o> dup to div-editbox js> inputbox insertBefore
		<js>
			$(".editbox_before    ")[0].onclick=function(){execute("editbox_before    ")}
			$(".editbox_parent    ")[0].onclick=function(){execute("editbox_parent    ")}
			$(".editbox_pop       ")[0].onclick=function(){execute("editbox_pop       ")}
			$(".editbox_after     ")[0].onclick=function(){execute("editbox_after     ")}
			$(".editbox_refresh   ")[0].onclick=function(){execute("editbox_refresh   ")}
			$(".editbox_example   ")[0].onclick=function(){execute("editbox_example   ")}
			$(".editbox_smaller   ")[0].onclick=function(){execute("editbox_smaller   ")}
			$(".editbox_bigger    ")[0].onclick=function(){execute("editbox_bigger    ")}
			$(".editbox_save      ")[0].onclick=function(){execute("editbox_save      ")}
			$(".editbox_jump      ")[0].onclick=function(){execute("jump-to-ce@       ")}
			$(".editbox_saveclose ")[0].onclick=function(){dictate("editbox_saveclose jump-to-ce@")}
			$(".editbox_close     ")[0].onclick=function(){dictate("editbox_close jump-to-ce@")}
		</js> ;

	: edit-node ( node -- ) \ Open the editbox to edit the given node.
		?dup if
			ce! \ leverage ce for moving around among neighbours
			create-editbox
			ce@ node-source js: editboxtextarea.value=pop() \ target source code
			div-editbox js: window.scrollTo(0,pop().offsetTop) \ jump to editbox
		then ;
		/// Having an input is for easier debug. ce@ will be used afterall.
	
	: {alt-f2} ( -- bubbling? ) \ Launch editbox
		js> window.getSelection().anchorNode ce! \ Get the anchorNode to ce.
		ce@ edit-node false ( stop bubbling ) ;

	: single-click ( flag -- flag' ) \ Single-click when in {F2} EditMode launch editbox
		['] {F2} :> EditMode div-editbox not and if ( flag ) 
			drop inputbox-edit-mode-off \ avlid clicked again when already in editing.
			{alt-f2} \ Launch editbox
		then ;

	: #text>html ( -- ) \ convert HTML tags in the ce #text node
		ce@ if create-editbox \ create div-editbox
		ce@ node-source js: editboxtextarea.value=pop() \ target source code
		editbox_saveclose then ;
	
	: {ctrl-f2} ( -- false ) \ Event handler, convert HTML tags at the #text anchorNode
		js> window.getSelection().anchorNode ce! #text>html false ;
	
\ log outputbox

	: log.open ( -- )  \ Get the log.json[last] back to outputbox
		\ 把整個 log.json 讀回來成一個 array。
		char log.json readTextFile js> JSON.parse(pop()) 
		:> slice(-1)[0] <o>escape </o> drop ; 
		/// 讀出最後一個 snapshot 還原到最後面不破壞現有的 outputbox。

	: log.save ( -- ) \ Save outputbox to log.json[last] replace the older.
		js> outputbox :> innerHTML ( outputbox.innerHTML )
		char log.json readTextFile js> JSON.parse(pop()) \ 把整個 log.json 讀回來成一個 array。
		:> slice(0,-1) dup ( outputbox.innerHTML array array ) :: push(pop(1))
		( array ) js> JSON.stringify(pop()) char log.json writeTextFile ;

	: log.length ( -- length )  \ Get the log.json array length
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
		dup :> pop() <o>escape </o> drop \ 取最後一個 snapshot 還原到 outputbox
		( array ) js> JSON.stringify(pop()) char log.json writeTextFile ;
		/// log.json 裡不再保留最新 snapshot 還原到最後面不破壞現有的 outputbox。

	: log.recall ( i -- )  \ Recall the log.json[i] back to outputbox
		char log.json readTextFile js> JSON.parse(pop()) \ 把整個 log.json 讀回來成一個 array。
		( i array ) :> [pop()] <o>escape </o> drop ; 
		/// No No No! Auto log.save current outputbox before recalling is a terrible idea.
		/// recall 出來放到最後面不破壞現有的 outputbox。

	: log.overwrite ( -- ) \ Drop older log.json, save outputbox to log.json[0]
		<js> confirm("Overwrite the entire jason.log! Are yous sure?")</jsV> if
		js> outputbox :> innerHTML ( outputbox.innerHTML )
		[] dup ( outputbox.innerHTML array array ) :: push(pop(1))
		( array ) js> JSON.stringify(pop()) char log.json writeTextFile then ;
		/// 這個應該都用不著，要小心。
		
\ edit-zone		

	{} constant edit-zone  // ( -- hash ) edit-zone hash table.
						/// Can be closed don't use array.
						/// {id:div1, id2:div2, ... }

	: edit-zone-load ( id -- ) \ Load the editing file
		( id ) dup char -pathname + ( id id-pathname )
		js> window[pop()].innerText trim ( id pathname ) readTextFile ( id file )
		js: window[pop(1)].innerHTML=pop() ;
	   
	: edit-zone-save ( id -- ) \ Save the editing file
		( id ) dup char -pathname + ( id id-pathname ) 
		js> window[pop()].innerText trim ( id pathname )  
		swap ( pathname id ) js> window[pop()].innerHTML ( pathname HTML ) 
		swap  ( HTML pathname ) writeTextFile ;

	: edit-zone-close ( id -- ) \ Delete the edit-zone, drop the data
		dup edit-zone :> [pop()] ( id DIV ) removeElement 
		( id ) edit-zone js: delete(pop()[pop()]) ;
		
	: edit-zone-moveup ( id -- ) \ Move the edit-zone up before its previousSibling
		edit-zone :> [pop()] ( DIV ) 
		dup :> previousSibline ( DIV previous ) 
		?dup if insertBefore else drop then ;

	: edit-zone-movedown ( id -- ) \ Move the edit-zone down under its nextSibling
		edit-zone :> [pop()] ( DIV ) 
		dup :> nextSibline ( DIV next ) 
		?dup if insertAfter else drop then ;

	: create-edit-zone ( pathname -- ) \ Create an edit-zone
		\ GetAbsolutePathName dup GetFileName ( pathname filename )
		dup :> match(/(.*[\\/])(.+)$/) ( pathname [orig,path,name] )
		?dup if js> pop()[2] else dup then ( pathname filename )
		dup char edit-zone- swap + ( pathname filename edit-zone-filename )
		random 1000 * int + ( pathname filename edit-zone-filename999 )
		-rot ( id pathname filename )
		<text> <div style="border: 2px solid white;">
			<p>
			<span style="font-size:2em">_filename_</span>
			/* <span> to make it an element avoid being erased by er */ 
			<input type=button value=Save  onclick="vm.push('_id_');vm.execute('edit-zone-save')" />
			<input type=button value=Close onclick="vm.push('_id_');vm.execute('edit-zone-close')" />
			<input type=button value=MoveUp onclick="vm.push('_id_');vm.execute('edit-zone-moveup')" />
			<input type=button value=MoveDown onclick="vm.push('_id_');vm.execute('edit-zone-movedown')" />
			<span id="_id_-pathname" style="font-size:0.8em"> _pathname_</span>
			</p>
			<hr><div id="_id_" contentEditable=true></div><hr>
			<p>&nbsp;
			<input type=button value=Save  onclick="vm.push('_id_');vm.execute('edit-zone-save')" />
			<input type=button value=Close onclick="vm.push('_id_');vm.execute('edit-zone-close')" />
			<input type=button value=MoveUp onclick="vm.push('_id_');vm.execute('edit-zone-moveup')" />
			<input type=button value=MoveDown onclick="vm.push('_id_');vm.execute('edit-zone-movedown')" />
			</p>
		</div></text> /*remove*/
		:> replace(/_filename_/gm,pop()).replace(/_pathname_/gm,pop()).replace(/_id_/gm,tos()) ( id )
		</o>
		ce! er ce@ swap ( ce@ id ) edit-zone :: [tos()]=pop(1) 
		ce@ js> outputbox insertBefore ( id ) edit-zone-load ;
		/// id is the editing <div>
		
	: open ( -- ) \ Open a HTML file to edit
		pickFile ?dup if create-edit-zone then ;

\ -- End --


<comment> old code 看甚麼時候通通丟掉	
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
		then 
		;

	: save-as ( "path-name" -- ) \ Save the editing document to the specified pathname
		cr ." Sorry, under constructing " cr ;

	: open ( -- ) \ Prompt for a file to edit
		pickFile to pathname
		pathname readTextFile ( file ) js> tos().length if
			article if article :: innerHTML="" ( 有的話清除現有頁面 ) else 
			<o> <div style="background-color:white"></div></o> to article ( 沒現成就新建頁面 )
			article js> outputbox insertBefore ( 新建的默認放在 outputbox 之前 )
			then article :: innerHTML=pop() 
		else 
			." Warning! can't read the file: " pathname . cr 
			article if article :: innerHTML="" ( 有的話清除現有頁面 ) then
			null to article 
		then ;
		
	: hide ( -- ) \ 暫時把文章 hide() 起來
		article js: $(pop()).hide() ;
		
	: show ( -- ) \ 把文章 show() 回來
		article js: $(pop()).show() ;
		
</comment>