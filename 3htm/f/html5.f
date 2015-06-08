
s" html5.f"		source-code-header

<comment>
	<!-- script src="js/jquery-1.10.2.js"></script -->

	<h> 
	<script type="text/javascript" src="js/box2dweb/Box2dWeb-2.1.a.3.min.js"></script> 
	</h> constant Box2dWeb // ( -- obj ) The Box2dWeb.js script element
	
	char script createElement constant vbsBasic // ( -- element ) The vbs script tag element
	vbsBasic char type char text/vbscript setAttribute
	vbsBasic char id   char vbsBasic      setAttribute
	vbsBasic char src  char 3hta/vbs/basic.vbs setAttribute
	eleHead vbsBasic appendChild

	char script createElement ( -- eleScript )
	dup char src char js/jquery-1.10.2.js setAttribute ( -- eleScript )
	js> head swap ( -- eleHead eleScript ) appendChild
	
	
</comment>


: createElement	( <element> -- element ) \ Create an HTML element w/o instance yet
				js> document.createElement(pop()) ; 
				
: setAttribute  ( oElement "attr" "value" -- ) \ Set an attribute to an element
				js: pop(2).setAttribute(pop(1),pop()) ;

: appendChild	( parent element -- ) \ Append an element to the parent element
				js: pop(1).appendChild(pop()) ;
				/// element.parentElement gets parent so we can *move* 

\ include jQuery
	char script createElement ( -- eleScript )
	dup char src char js/jquery-1.10.2.js setAttribute ( -- eleScript )
	js> head swap ( -- eleHead eleScript ) appendChild

: getElementById
				( "id" -- element ) \ Get element object by ID
				js> document.getElementById(pop()) ;
				
: getAttribute  ( oElement "attr" -- ) \ Get an attribute value of an element
				js> pop(1).getAttribute(pop()) ;

: replaceNode	( Node targetNode -- ) \ Replace a HTML node
				js: tos().parentElement.replaceChild(pop(1),pop()) ;
				/// Try it yourself http://www.w3schools.com/jsref/tryit.asp?filename=tryjsref_node_replacechild

: insertBefore	( target ref -- ) \ *Move* the target element to before the reference element
				js: tos().parentElement.insertBefore(pop(1),pop()) ;
				/// insertBefore() method see https://www.evernote.com/shard/s22/nl/2472143/9d97ceec-8374-4ac8-baab-f3f599ecfba4

: insertAfter	( target ref -- ) \ *Move* the target element to after the reference element
				js> tos().nextElementSibling if 
					js> pop().nextElementSibling
					js: tos().parentElement.insertBefore(pop(1),pop()) 
				else
					js: pop().parentElement.appendChild(pop())
				then
				;
				/// insertBefore() method see https://www.evernote.com/shard/s22/nl/2472143/9d97ceec-8374-4ac8-baab-f3f599ecfba4

: lastChild		( parent -- element ) \ Get the last child of the given element.
				js> pop().lastChild ;

: lastElementChild		
				( parent -- element ) \ Get the last element child of the given element.
				js> pop().lastElementChild ;
				
: removeElement	( element -- ) \ Remove an element
				js: tos().parentNode.removeChild(pop()) ;

: eleHead		( -- element ) \ Get <head> element
				js> document.getElementsByTagName('head')[0] ;
				/// js> document.getElementsByTagName('head')[0]==$('head')[0] ==> true
				/// js> $('head')[0]==document.head ==> true
				
: eleBody		( -- element ) \ Get <body> element
				js> document.getElementsByTagName('body')[0] ;
				/// js> document.getElementsByTagName('body')[0]==$('body')[0] ==> true
				/// js> $('body')[0]==document.body ==> true

: eleDisplay 	( -- element ) \ Get console output screen element
				js> document.getElementById('outputbox') ;
				/// js> document.getElementById('outputbox')==$('#outputbox')[0] ==> true
				/// js> $('#outputbox')[0]==outputbox ==> true

: doElement		( "html" "jqSelector" -- element ) \ Run time of <e>,<h> or the likes.
				js> $(pop()).append(pop())[0] lastChild ;
				/// Example: char #outputbox char <h1>Hello</h1> doElement
				\ Must use jQuery append(), because HTMLelement.appendChild(node) is not suitable
				
: <e>			( "jQuery selector" <html> -- "html" ) \ HTML section header. Get HTML tags.
				char \s*(</e>|</o>|</h>) word \ 前置空白會變成 [object Text] 必須消除。
				compiling if literal then ; immediate
				last dup alias <o> immediate // ( <html> -- "html" ) Starting a HTML section append to output box.
				alias <h> immediate // ( <html> -- "html" ) Starting a HTML section append to <HEAD>. 
				/// Section ending can be </e> </o> or </h> which are element, outputbox, and header
				/// respectively, so far. 分開寫也可以，併成一個只是圖方便。

: </o>			( "html" -- element ) \ Delimiter of <o>, (O)utputbox.
				char #outputbox compiling 
				if literal compile doElement 
				else doElement then ; immediate

: </h>			( "html" -- element ) \ Delimiter of <h>, (H)ead section.
				char head compiling 
				if literal compile doElement 
				else doElement then ; immediate

: </e>			( "jQuery selector" "html" -- element ) \ Delimiter of <e>, general purpose.
				compiling if compile swap compile doElement 
				else swap doElement then ; immediate
				/// Example: char #outputbox <e> <h1>hi</h1></e>

: open			( "http://url" "name" -- win ) \ Open the URL return the window element named 'name' for <a> and <form>.
				js> window.open(pop(1),pop()) ;
				/// window.open() method http://www.w3schools.com/jsref/met_win_open.asp
				/// Try "win :: focus()" to switch to the browser window/tab any time.
				/// Try "win :> document.body.innerHTML ." to see HTML body
				/// Try "win :: close()" to close the window
				
				<comment>
				s" http://www.taobao.com/about/copyright.php" s" taobaoCopyright" open \ This page responses fast
				1000 sleep
				js> (tos().document.body.innerHTML).indexOf('浙江淘?网?有限公司') . \ should not be -1
				js: pop().close()
				\ http://www.taobao.com/about/copyright.php
				\ 浙江淘?网?有限公司
				</comment>

: pickFile		( -- "pathname" ) \ Pick a file through web browser's GUI
				char input createElement \ ele
				dup char type char file setAttribute \ ele
				js: $(tos()).hide() eleBody over appendChild \ 要 append 才行，是有點奇怪。
				js> tos().click();tos().value
				swap removeElement ;
				/// Works fine on HTA. The dialog works on 3htm but returns Null string. 
				/// Through excel app's GetOpenFilename method can do the same thing:
				///     excel.app js> pop().GETopenFILENAME <== with or w/o () both fine
				/// Excel's GetSaveAsFilename method too.

: input.file	( -- element ) \ Place a file input HTMLelement
				<o> <input type=file></o> ;
				\ This word is for demo. Use <e> or <o> directly is preferred. Usage: pop().value

: input.radio	( value name -- element ) \ Place a HTML radio button [object HTMLInputElement]
				<o> <input type=radio></o> dup >r ( v n e )
				swap over ( v e n e ) char name ( v e n e 'name' ) rot ( v e e 'name' n ) setAttribute ( v e )
				swap ( e v ) char value ( e v 'value' ) swap ( e 'value' v ) setAttribute r> ;
				/// We need this command for programmatic-dynamical cases.
				/// Properties are tos().value, tos().checked, tos().name 
				/// All radio buttons of the same 'name' attribute are grouped together as a [object HTMLCollection]
				/// document.body.children.hta.children.outputbox.children.<name> is the [object HTMLCollection]
				/// document.getElementsByName("<name>").item(0).checked=true Set default at a item
				/// Best use jQuery js> $('input[name=<name>]:checked').val() Note! undefined if nothing selected. 
				/// See http://stackoverflow.com/questions/596351/how-can-i-get-which-radio-is-selected-via-jquery

				<comment>
				  char value1 char rrr input.radio drop <o> <div> 1111111</div></o> drop
				  char value2 char rrr input.radio drop <o> <div> 2222222</div></o> drop
				  char value3 char rrr input.radio drop <o> <div> 3333333</div></o> drop
				  char value4 char rrr input.radio drop <o> <div> 4444444</div></o> drop
				  js> $('input[name=rrr]:checked').val() . cr \ ==> undefined until one of them is checked.
				  \ The value would thus be one of value1,value2..valuen
				</comment>
				
: ^node			( ele -- ele ) \ Get previous sibling node
				js> pop().previousSibling ;
				/// see also element.previousElementSibling
: node^			( ele -- ele ) \ Get next sibling node
				js> pop().nextSibling ;
				/// see also element.nextElementSibling

: children		( ele -- array ) \ All children of the element
				js> typeof(tos())!='object' if . ."  is not a HTML-Element!" cr [] exit then
				js> pop().firstChild ( first )
				?dup if ( first ) else ( empty ) [] exit then ( first ) 
				[] swap ( [] 1st ) begin ( [] ele )
					js> tos(1).push(tos());pop().nextSibling ( [] ele' )
				dup not until
				drop ;
				/// Leaves an empty array if the input is not an object.
				/// But the input element can have no child.

: []children	( ele n -- array ) \ Beginning n child nodes of the element
				swap js> pop().firstChild ( n first )
				?dup if ( n first ) else ( n ) drop [] exit then ( n first ) 
				[] -rot ( [] n 1st ) swap for ( [] ele )
					js> tos(1).push(tos());pop().nextSibling ( [] ele' )
					dup if else r> drop 0 >r then
				next
				drop ;
				/// Example: dropall js> outputbox 10 []children <== get an array 
				///          of leading 10 child nodes to TOS.

: children[]	( ele n -- array ) \ Ending n child nodes of the element
				swap js> pop().lastChild ( n ele )
				?dup if ( n ele ) else ( n ) drop [] exit then ( n ele ) 
				[] -rot ( [] n ele ) swap for ( [] ele )
					js> tos(1).unshift(tos());pop().previousSibling ( [] ele' )
					dup if else r> drop 0 >r then
				next
				drop ;
				/// Example: dropall js> outputbox 10 children[] <== get an array 
				///          of ending 10 child nodes to TOS.
				
<comment>

<o> <lalala></o>
 jsc>tos().nodeName ==> LALALA  (string)
 jsc>tos().nodeType ==> 1  (number)
 
jQuery   
	js> $('body')[0]==document.body . ==> true
	js> $('head')[0]==document.head . ==> true
	js> $('body').append("<h1>Hello</h1>")  ==> works fine ;-D jQuery

js> outputbox.lastChild.nodeName .
js> outputbox.lastChild.nodeValue .
js> outputbox.childNodes .s
js> $('#outputbox')[0]==outputbox ==> true

outputbox.firstChild
outputbox.lastChild
	
js> outputbox lastChild     ." nodeType:" js> tos().nodeType . ." , nodeName:" js> tos().nodeName . cr
js> pop().previousSibling   ." nodeType:" js> tos().nodeType . ." , nodeName:" js> tos().nodeName . cr
js> pop().previousSibling   ." nodeType:" js> tos().nodeType . ." , nodeName:" js> tos().nodeName . cr
js> pop().previousSibling   ." nodeType:" js> tos().nodeType . ." , nodeName:" js> tos().nodeName . cr

	element.nodeName ~.nodeValue ~.nodeType
	http://www.cnblogs.com/sweting/archive/2009/12/06/1617839.html				
				nodeName 屬性含有某個節點的名稱。
					元素節點的 nodeName 是標籤名稱
					屬性節點的 nodeName 是屬性名稱
					文本節點的 nodeName 永遠是 #text
					文檔節點的 nodeName 永遠是 #document
					注釋：nodeName 所包含的 XML 元素的標籤名稱永遠是大寫的
				nodeValue 
					對於文本節點，nodeValue 屬性包含文本。
					對於屬性節點，nodeValue 屬性包含屬性值。
					nodeValue 屬性對於文檔節點和元素節點是不可用的。
				nodeType 節點的類型。
					最重要的節點類型是：
					Element      nodeType
					元素element	    1
					屬性attr	    2
					文本text	    3
					注釋comments	8
					文檔document	9

	\ demo1		( -- ) \ Append "Hello World!" 
				char div createElement constant element1
				element1 char id char element1 setAttribute
				element1 <js> pop().innerText="Hello World! " + Date(); </js> 
				eleBody element1 appendChild

	\ demo2		( -- ) \ Append "Hello World!" 
				char pre createElement constant element2
				element2 char id char element2 setAttribute
				element2 <js> pop().innerText="Hello World! " + Date(); </js> 
				eleBody element2 appendChild

	\ demo3		( -- ) \ Append "Hello World!" 
				char code createElement constant element3
				element3 char id char element3 setAttribute
				element3 <js> pop().innerText="Hello World! " + Date(); </js> 
				eleBody element3 appendChild

	\ demo4		( -- ) \ Read and print 
				char textarea createElement constant element4
				element4 char id char element4 setAttribute
				element4 char cols char 100 setAttribute
				element4 char rows char 10  setAttribute
				eleBody element4 appendChild  \ 不掛進 body 就不需要 hide() 了吧？
				\ js: $('#element4').hide()    \ 可以這麼說，但不掛進 body jQuery 就 query 不到了！
				js: $('#element4').load('f/html5.f') \ jQuery 必須 query 得到才能 load()
				eleBody lastChild js> pop().innerText . 
				
	\ demo5 	( "src" -- ) \ Add VBScript to head or body
	            \ 希望可以 appendChild <script> 進 <head> or <body> 添加新程式。
				\ See article @ my Evernote : https://www.evernote.com/shard/s22/nl/2472143/33755fb6-46b8-46d6-870e-07c9f1a7a442

				char script createElement constant element5
				element5 char type char text/vbscript setAttribute
				element5 char src rot setAttribute
				eleBody element5 appendChild
				
	            <js> document.getElementById('vbs').src </jsV> . \ src attribute 是給定 URL 用的
	            <js> document.getElementById('js').src </jsV> .
	            <js> document.getElementById('vbs').innerText </jsV> cls cr . \ 可以看到 vbs source code 
	            <js> document.getElementById('js').innerText </jsV> cls cr .  \ 可以看到 js  source code 

		        <text> alert ("Hello World!!", 1, "VBS message") </text>
		        char script createElement constant element5
		        element5 char language char VBscript setAttribute
		        \ element5 char src rot setAttribute \ 好像不認得 src 這個 attribute. 但有 innerText attribute! 錯了， src 預期 pathname.
		        element5 char innerText rot setAttribute
		        eleHead element5 appendChild

				\ Bingo! I don't need to have a <script> of VBS section in jeforth.htm
				\ vbs code can be added this way ..... Bingo!!
				include f/html5.f
				char script createElement constant element5
				element5 char type char text/vbscript setAttribute
				element5 char src char vbs/basic.vbs setAttribute
				eleBody element5 appendChild  \ body or head, both OK
				
				include f/html5.f
				char script createElement constant element5
				element5 char type char text/vbscript setAttribute
				element5 char src char vbs/basic.vbs setAttribute
				eleHead element5 appendChild  \ body or head, both OK
				
	\ demo6 	( -- "pathname" ) \ Get file pathname through IE's U/I
				char input createElement \ oInput
				dup char type char file setAttribute \  oInput
				dup char id char GetFilePathname setAttribute \  oInput
				eleBody over appendChild
				js: document.getElementById("GetFilePathname").click()
				js> document.getElementById("GetFilePathname").value
				swap removeElement

	\ Demo Get user text line input user interactive. 
				: doButton ( -- ) \ Demo user interactive for jeforth.3hta
					cr js> document.body.children.hta.children.outputbox.children.myname.value . cr
					js> document.body.children.hta.children.outputbox.children.myaddress.value . cr ;
				." What's your name? " <o> <input type=text name=myname size=50></o> cr cr
				." Where do you live? " <o> <input type=text name=myaddress size=100></o> cr
				<o> <input type=button onclick="kvm.execute('doButton')" value=OK></o> \ "kvm." is must

	\ Demo Get radio button selection user interactive. 
				: doButton ( -- ) \ Demo user interactive for jeforth.3hta
					js> document.body.children.hta.children.outputbox.children.sex[0].value . space
					js> document.body.children.hta.children.outputbox.children.sex[1].value . space
					js> document.body.children.hta.children.outputbox.children.sex[0].checked . space
					js> document.body.children.hta.children.outputbox.children.sex[1].checked . cr
					;
				." I am a man "  <o> <input type=radio name=sex value=man ></o> ."    " 
				." I am a girl " <o> <input type=radio name=sex value=girl></o> ."    "
				<o> <input 
					type=button 
					onclick="kvm.execute('doButton')" 
					value=OK
					style="width:120px;height:40px;font-size:20px;"
				></o> drop \ "kvm." is must, don't forget to drop the element which is not used
				\ button tutorial http://www.wibibi.com/info.php?tid=117
				
	< input type="file" id="files" name="files[]" multiple />
	< output id="list">< /output>
	
	eleBody lastChild removeElement  \ remove the last element
	eleBody lastChild char class getAttribute .  \ demo1
	OK js> $('.demo1').hide()  \ hide class=demo1
	OK js> $('#demo1').show()  \ show id=demo1 
	
	js> $('.demo1').load('npm-debug.log')  \ Bingo! Root directory located at where index.html is at.
	js> $('.demo1').load('playground\\html5.f') 	\ Bingo!!			
	js> $('#demo2').load('playground\\html5.f') 	\ Bingo!!			
	js> $('#demo3').load('playground\\html5.f') 	\ Bingo!!			
	js> $('#demo4').load('playground\\html5.f') 	\ Bingo!!			
	
	\ Read 'playground\html5.f' to TOS, it works fine.
	<js> 
		var e=document.createElement('textarea'); 
		e.setAttribute('id','jeforth_f');
		document.getElementsByTagName('body')[0].appendChild(e);
		$('#jeforth_f').hide();
		$('#jeforth_f').load('playground\\html5.f',function(responseTxt,statusTxt,xhr){
			if(statusTxt=="success") push(responseTxt); else push("");
			e.parentNode.removeChild(e);
		});
	</js>
	
	
	<js> document.getElementById('jeforth_f').value == document.getElementById('jeforth_f').innerText </jsV> .
	<js> document.getElementById('jeforth_f').value = document.getElementById('jeforth_f').innerHTML </js>
	
	outputbox

	http://www.w3schools.com/jsref/dom_obj_all.asp
	Property / Method	Description
	element.accessKey	Sets or returns the accesskey for an element
	element.addEventListener()	Attaches an event handler to the specified element
	element.appendChild()	Adds a new child node, to an element, as the last child node
	element.attributes	Returns a NamedNodeMap of an element's attributes
	element.childNodes	Returns a NodeList of child nodes for an element
	element.className	Sets or returns the class attribute of an element
	element.clientHeight	Returns the viewable height of an element
	element.clientWidth	Returns the viewable width of an element
	element.cloneNode()	Clones an element
	element.compareDocumentPosition()	Compares the document position of two elements
	element.contentEditable	Sets or returns whether the content of an element is editable or not
	element.dir	Sets or returns the text direction of an element
	element.firstChild	Returns the first child of an element
	element.getAttribute()	Returns the specified attribute value of an element node
	element.getAttributeNode()	Returns the specified attribute node
	element.getElementsByClassName()	Returns a collection of all child elements with the specified class name
	element.getElementsByTagName()	Returns a collection of all child elements with the specified tagname
	element.getFeature()	Returns an object which implements the APIs of a specified feature
	element.getUserData()	Returns the object associated to a key on an element
	element.hasAttribute()	Returns true if an element has the specified attribute, otherwise false
	element.hasAttributes()	Returns true if an element has any attributes, otherwise false
	element.hasChildNodes()	Returns true if an element has any child nodes, otherwise false
	element.id	Sets or returns the id of an element
	element.innerHTML	Sets or returns the content of an element
	element.insertBefore()	Inserts a new child node before a specified, existing, child node
	element.isContentEditable	Returns true if the content of an element is editable, otherwise false
	element.isDefaultNamespace()	Returns true if a specified namespaceURI is the default, otherwise false
	element.isEqualNode()	Checks if two elements are equal
	element.isSameNode()	Checks if two elements are the same node
	element.isSupported()	Returns true if a specified feature is supported on the element
	element.lang	Sets or returns the language code for an element
	element.lastChild	Returns the last child of an element
	element.namespaceURI	Returns the namespace URI of an element
	element.nextSibling	Returns the next node at the same node tree level
	element.nodeName	Returns the name of an element
	element.nodeType	Returns the node type of an element
	element.nodeValue	Sets or returns the value of an element
	element.normalize()	Joins adjacent text nodes and removes empty text nodes in an element
	element.offsetHeight	Returns the height of an element
	element.offsetWidth	Returns the width of an element
	element.offsetLeft	Returns the horizontal offset position of an element
	element.offsetParent	Returns the offset container of an element
	element.offsetTop	Returns the vertical offset position of an element
	element.ownerDocument	Returns the root element (document object) for an element
	element.parentNode	Returns the parent node of an element
	element.previousSibling	Returns the previous element at the same node tree level
	element.querySelector()	Returns the first child element that matches a specified CSS selector(s) of an element
	document.querySelectorAll()	Returns a static NodeList containing all child elements that matches a specified CSS selector(s) of an element
	element.removeAttribute()	Removes a specified attribute from an element
	element.removeAttributeNode()	Removes a specified attribute node, and returns the removed node
	element.removeChild()	Removes a child node from an element
	element.replaceChild()	Replaces a child node in an element
	element.removeEventListener()	Removes an event handler that has been attached with the addEventListener() method
	element.scrollHeight	Returns the entire height of an element
	element.scrollLeft	Returns the distance between the left edge of an element and the view
	element.scrollTop	Returns the distance between the top edge of an element and the view
	element.scrollWidth	Returns the entire width of an element
	element.setAttribute()	Sets or changes the specified attribute, to the specified value
	element.setAttributeNode()	Sets or changes the specified attribute node
	element.setIdAttribute()	
	element.setIdAttributeNode()	
	element.setUserData()	Associates an object to a key on an element
	element.style	Sets or returns the style attribute of an element
	element.tabIndex	Sets or returns the tab order of an element
	element.tagName	Returns the tag name of an element
	element.textContent	Sets or returns the textual content of a node and its descendants
	element.title	Sets or returns the title attribute of an element
	element.toString()	Converts an element to a string
		 
	nodelist.item()	Returns the node at the specified index in a NodeList
	nodelist.length	Returns the number of nodes in a NodeList
</comment>
