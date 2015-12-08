
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

	: save ( -- ) \ Save the editing document
		js> mystyle.outerHTML+myarticle.outerHTML pathname writeTextFile ;

	: save-as ( "path-name" -- ) \ Save the editing document to the specified pathname
		cr ." Sorry, under constructing " cr ;

	: open ( "path-name" -- ) \ Read the file to edit
		article if article :: innerHTML="" ( 清除現有頁面 ) 
		else s" body" <e> <div></div></e> to article then 
		pathname readTextFile article :: innerHTML=pop() ;
	
	null value div-editbox // ( -- element ) The entire DIV node of the editbox.
	
	: editbox  ( -- element ) \ Create an editbox at outputbox
		char editbox-close execute \ editbox 只能有一個，因為其中的 editboxtextarea id 必須唯一。
		<o> <div>
			<textarea id=editboxtextarea rows=8>
/* <table class=commandline><td><pre><code class=source>...</code></pre></td></table> */
			</textarea>
			<input type=button value=Save  onclick="kvm.execute('editbox-save')" />
			<input type=button value=Close onclick="kvm.execute('editbox-close')" />
			<input type=button value=Up onclick="kvm.execute('editbox-up')" />
		</div></o> ;
	
	: 	editbox-save ( -- ) \ ce@ is the target element.
		js> editboxtextarea.value /*remove*/ <code>escape 
		ce@ :: outerHTML=pop() ;
		
	: 	editbox-close ( -- ) \ ce@ is the target element.
		begin 
			js> document.getElementById("editboxtextarea") if 
				\ 這個 id 必須唯一，還看得見就是有例外狀況了，可能是之前的還沒有 close。
				js> editboxtextarea dup :: removeAttribute("id") removeElement 
				false 
			else true then 
		until
		div-editbox js> tos()&&tos().parentNode 
		if removeElement then null to div-editbox ;

	: 	editbox-up ( -- ) \ Change element to ce's parent
		char .. (ce) ce@ :> outerHTML \ 把 ce 的 outerHTML 抓進編輯區
		js: editboxtextarea.value="/*"+editboxtextarea.value+"*/\n"+pop() ;
		
	: edit ( -- ) \ Edit the ce (current element) outerHTML.
		editbox to div-editbox
		ce@ :> outerHTML ?dup if else ce@ :> nodeValue then 
		js: editboxtextarea.value+="\n/*--*/\n"+pop() ;
		/// [ ] [save] 過後 ce 就斷鏈了，因此不能重複實驗。有待改良。
\ -- End --
