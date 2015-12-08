
	\ editor.f 
	\ Editor commands for 3hta and 3nw to edit HTML documents directly
	\ in jeforth window.

	s" editor.f" source-code-header
	
	char %HOMEDRIVE%%HOMEPATH%\Documents\GitHub\jeforth.3we\playground\ env@
	value working-directory // ( -- "path" ) 

	char c:\Users\hcche\Documents\GitHub\jeforth.3we\playground\editor-study.html 
	value pathname // ( -- "pathname" ) Path/Filename of the working document

	null value article // ( -- objArticle ) The DIV world of the file to be edited.

	: save ( -- ) \ Save the editing document
		js> mystyle.outerHTML+myarticle.outerHTML pathname writeTextFile ;

	: save-as ( "path-name" -- ) \ Save the editing document to the specified pathname
		cr ." Sorry, underconstruction " cr ;

	: open ( "path-name" -- ) \ Read the file to edit
		article if article :: innerHTML="" ( 清除現有頁面 ) 
		else s" body" <e> <div></div></e> to article then 
		pathname readTextFile article :: innerHTML=pop() ;
	
	null value edit-current-element-div // ( -- element ) The entire DIV node of the editing element.
	: 	temptextarea-save ( -- ) \ Current Element, ce@, is the target element.
		ce@ :: outerHTML=temptextarea.value ;
		
	: 	temptextarea-close ( -- ) \ Current Element, ce@, is the target element.
		begin 
			js> document.getElementById("temptextarea") if 
				\ 這個 id 必須唯一，還看得見就是有例外狀況了，可能是之前的還沒有 close。
				js> temptextarea dup :: removeAttribute("id") removeElement 
				false 
			else true then 
		until
		edit-current-element-div js> tos()&&tos().parentNode 
		if removeElement then null to edit-current-element-div ;
	: edit-current-element ( -- ) \ Edit the ce (current element) outerHTML.
		temptextarea-close \ 舊的都先放掉
		\ 提供一點指引
		cr 
		." Pattern of a command line:" cr
		." <table class=commandline><td><pre><code class=source>...</code></pre></td></table>" cr
		\ 變出 textarea 擺上 [Save][Close] buttons
		<o> <div>
			<textarea id=temptextarea rows=8></textarea>
			<input type=button value=Save  onclick="kvm.execute('temptextarea-save')" />
			<input type=button value=Close onclick="kvm.execute('temptextarea-close')" />
		</div></o> to edit-current-element-div
		\ 把 target 的 outerHTML 抓進編輯區
		ce@ :> outerHTML js: temptextarea.value=pop() ;
		/// [ ] [save] 過後 ce 就斷鏈了，因此不能重複實驗。有待改良。
\ -- End --
