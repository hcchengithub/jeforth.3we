

\ hte.f 
\ Editor commands for HTML based applications to edit HTML documents directly
\ in jeforth window. As known as the Alt-F2 editor.
	
	\ 因為用到了 <code>escape <o>escape 所以要在 unindent.f 之後
	\ 而不能併入 html5.f
	
	include 3htm/f/unindent.f
	
	s" hte.f" source-code-header

\ Hyper Text Editor (hte) 

	null value div-hte // ( -- element ) The entire DIV node of the hte.
	
	: unenvelope ( element -- firstNode ) \ Peel an element into its children nodes
		( ele ) js> tos().childNodes.length ?dup if ( ele length ) 
			( ele length ) js> tos(1).firstChild -rot ( first0 ele length ) 
			for ( first0 ele )
				js> tos().firstChild over ( first0 ele first ele ) 
				insertBefore ( first0 ele )
			next ( first0 ele )
			removeElement ( first0 )
		then ;
		/// if the given element has no child then leave itself on the TOS.
		/// Return the first node.
	
	: hte_save ( -- ) \ Save hte to ce@ which is the target element.
		js> htetextarea.value 
		/*remove*/ <code>escape
		char <span> swap + char </span> + <o>escape </o> \ 套一圈 <span> 保證它是 one node
		dup ce@ replaceNode unenvelope ce! ; \ New nodes replace the old one then 解套
		
	: hte_close ( -- ) \ Close the hte
		begin 
			js> document.getElementById("htetextarea") if 
				\ 這個 id 必須唯一，還看得見就是有例外狀況了，可能是之前的還沒有 close。
				js> htetextarea dup :: removeAttribute("id") removeElement 
				false 
			else true then 
		until
		div-hte if 
			div-hte :> parentNode 
			if div-hte removeElement then 
		then
		null to div-hte ;
		
	: hte_saveclose ( -- ) \ Save hte to ce@ which is the target element.
		hte_save hte_close ;

	: node-source ( node -- "source" ) \ Get outerHTML or nodeValue
		dup :> outerHTML ?dup if ( node outerHTML ) nip 
		else ( node ) dup :> toString() char /* swap + js> "*/\n" + 
		swap ( /*...*/ node ) :> nodeValue ?dup if + then then ;
		
	: hte_parent ( -- ) \ Change element to ce's parent
		char .. (ce) node-source js: htetextarea.value=pop() ;

	: hte_before ( -- ) \ Change element to ce's sibling
		char < (ce) node-source js: htetextarea.value=pop() ;

	: hte_after ( -- ) \ Change element to ce's sibling
		char > (ce) node-source js: htetextarea.value=pop() ;

	: hte_pop ( -- ) \ Change element to the previous ce
		char pop (ce) node-source js: htetextarea.value=pop() ;

	: hte_refresh ( -- ) \ Reload current element
		ce@ node-source js: htetextarea.value=pop() ;

	: hte_example	( -- ) \ Show example
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
		js> '\n' + ce@ node-source + js: htetextarea.value=pop() ;

	: create-hte  ( -- ) \ Create an hte at outputbox
		char hte_close execute \ hte 只能有一個，因為其中的 htetextarea id 必須唯一。
		<text> <div>
			<textarea id=htetextarea rows=8></textarea>
			<input type=button value='<'              class="hte_before    " />
			<input type=button value=Parent           class="hte_parent    " />
			<input type=button value=Back             class="hte_pop       " />
			<input type=button value='>'              class="hte_after     " />
			<input type=button value='Refresh'        class="hte_refresh   " />
			<input type=button value='Example'        class="hte_example   " />
			<input type=button value="Save w/o close" class="hte_save      " />
			<input type=button value="Save & Close"   class="hte_saveclose " />
			<input type=button value=Close            class="hte_close     " />
			<input type=button value=Jump             class="hte_jump      " />
		</div></text> </o> dup to div-hte js> inputbox insertBefore
		<js>
			$(".hte_before    ")[0].onclick=function(){execute("hte_before    ")}
			$(".hte_parent    ")[0].onclick=function(){execute("hte_parent    ")}
			$(".hte_pop       ")[0].onclick=function(){execute("hte_pop       ")}
			$(".hte_after     ")[0].onclick=function(){execute("hte_after     ")}
			$(".hte_refresh   ")[0].onclick=function(){execute("hte_refresh   ")}
			$(".hte_example   ")[0].onclick=function(){execute("hte_example   ")}
			$(".hte_save      ")[0].onclick=function(){execute("hte_save      ")}
			$(".hte_jump      ")[0].onclick=function(){execute("jump-to-ce@       ")}
			$(".hte_saveclose ")[0].onclick=function(){dictate("hte_saveclose jump-to-ce@")}
			$(".hte_close     ")[0].onclick=function(){dictate("hte_close jump-to-ce@")}
		</js> ;

	: edit-node ( node -- ) \ Open the hte to edit the given node.
		?dup if
			ce! \ leverage ce for moving around among neighbours
			create-hte
			ce@ node-source js: htetextarea.value=pop() \ target source code
			div-hte js: window.scrollTo(0,pop().offsetTop) \ jump to hte
		then ;
		/// Having an input is for easier debug. ce@ will be used afterall.
	
	: {alt-f2} ( -- bubbling? ) \ Launch hte
		js> window.getSelection().anchorNode ce! \ Get the anchorNode to ce.
		ce@ edit-node false ( stop bubbling ) ;

		
	\ : single-click ( flag -- flag' ) \ Single-click when in {F2} EditMode launch hte
	\ 	['] {F2} :> EditMode div-hte not and if ( flag ) 
	\ 		drop inputbox-edit-mode-off \ avlid clicked again when already in editing.
	\ 		{alt-f2} \ Launch hte
	\ 	then ; 
	\ 	/// alt-f2 is good enough, single-click is annoying.
	\ 	\ Setup the handler of clicks that are poping up the hte.
	\ 	last <js>
	\ 		document.body.onclick = function(){
	\ 			push(true); // true let the river run, false stop bubbling
	\ 			execute("single-click"); // execute() does nothing if undefined yet
	\ 			return(pop()); // right-click ( flag -- ... flag' )
	\ 		}
	\ 	</js>
		
	: #text>html ( -- ) \ convert HTML tags in the ce #text node
		ce@ if create-hte \ create div-hte
		ce@ node-source js: htetextarea.value=pop() \ target source code
		hte_saveclose then ;
	
	: {ctrl-f2} ( -- false ) \ Event handler, convert HTML tags at the #text anchorNode
		js> window.getSelection().anchorNode ce! #text>html false ;

	: paste-string ( "string" -- ) \ Paste the string to anchorNode if it's a #text
		js> getSelection() ( "string" selection )
		dup :> anchorNode.nodeName=="#text" if ( "string" selection )
		js> tos().anchorNode.nodeValue.slice(0,tos().anchorOffset)+pop(1)+tos().anchorNode.nodeValue.slice(tos().anchorOffset) ( selection "new string" )
		js: pop(1).anchorNode.nodeValue=pop() 
		else ( "string" selection ) 2drop then ;
		/// Click on web page if the anchor is on a #text node then paste the given string.
		/// Press ctrl-enter to execute this command so as to allow the click and anchor to
		/// work. This command does not work if targeting in a textarea, it's not a #text
		/// node and I don't know how to insert the given string into a textarea.
		
\ -- END --