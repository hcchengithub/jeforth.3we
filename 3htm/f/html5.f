
s" html5.f"		source-code-header

: stringify		js> JSON.stringify(pop()) ; // ( obj -- "json" ) Convert the object to JSON string
				/// ' + stringify --> {"name":"+","vid":"forth",...}(string)
				/// ' + stringify parse (see)

: parse			js> JSON.parse(pop()) ; // ( "json" -- obj ) Convert the "json" string to an object.
				/// ' + stringify --> {"name":"+","vid":"forth",...}(string)
				/// ' + stringify parse (see)
                \   {
                \       "name": "+",
                \       "vid": "forth",
                \       "wid": 77,
                \       "type": "code",
                \       "help": "( a b -- a+b) Add two numbers or concatenate two strings. ",
                \       "private": false,
                \       "selftest": "pass"
                \   } OK 

: createElement	( <tagName> -- element ) \ Create an HTML element w/o instance yet
				js> document.createElement(pop()) ; 
				/// tagName can be 'div','script' or anything you like.

: setAttribute  ( oElement "attr" "value" -- ) \ Set an attribute to an element
				js: pop(2).setAttribute(pop(1),pop()) ;

: appendChild	( parent element -- ) \ Append a child element to the parent element
				js: pop(1).appendChild(pop()) ;
				/// element.parentElement gets parent so we can *move* 

				<selftest>
					marker --- 
					null value aa // ( -- element )
					null value bb // ( -- element )
					*** createElement creates an HTML element, you name whatever tagName you like!
						char AAA createElement to aa aa :> tagName ( AAA )
						[d "AAA" d] [p "createElement" p]
					*** setAttribute can be any name:value pair
						aa char bbb char ccc setAttribute 
						aa char bbb getAttribute
						[d 'ccc' d] [p "setAttribute","getAttribute" p]
					js> document.getElementsByClassName [if] \ skip old IE/HTA
						*** appendChild appends child element to parent element
							char BBB createElement to bb bb :> tagName ( BBB )
							aa :> childElementCount \ 0 
							aa bb appendChild 
							aa :> childElementCount \ 1
							[d "BBB",0,1 d] [p "appendChild" p]
					[then]
					---
				</selftest>
	
: getElementById ( "id" -- element ) \ Get element object by ID
				js> document.getElementById(pop()) ;
				
: getAttribute  ( oElement "attr" -- ) \ Get an attribute value of an element
				js> pop(1).getAttribute(pop()) ;

: replaceNode  ( newNode targetNode -- ) \ Replace a HTML node or element
				js: $(pop()).replaceWith(pop()) ;
				/// jQuery replaceWith() http://api.jquery.com/replaceWith/
                /// 不在 tag 裡的文字就是 node 的一種。

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
				char (</e>|</o>|</h>|</text>) word
				compiling if literal then ; immediate
				/// Section ending can be </e> </o> or </h> for general element, outputbox, and 
				/// header respectively, so far. Also </text> for debug.
				last dup alias <o> immediate // ( <html> -- "html" ) Starting a HTML section append to output box.
				alias <h> immediate // ( <html> -- "html" ) Starting a HTML section append to <HEAD>. 
				
: /*remove*/ 	( "raw" -- "cooked" ) \ remove /* comments in multiple lines */ 
				:> replace(/[/]\*(.|\r|\n)*?\*[/]/mg,"") ; \ HTA 不能用 \/ 必須用 [/]
				/// 使 /* ... */ 可以用在 HTML 裡面。
				/// Support multiple comment lines in one pare of /* .. */
				/// Not support nested.

: </o>			( "html" -- element ) \ Delimiter of <o>, (O)utputbox.
				compiling if compile /*remove*/ compile trim else /*remove*/ trim then
				char #outputbox compiling 
				if literal compile doElement 
				else doElement then ; immediate
				
code <o>escape	( "HTML lines" -- "cooked" ) \ Convert <o> </o> to &lt;o&gt;brabrabra
				var ss = pop()||"";
				var result = ss
					.replace(/<o>/mg,"&lt;o&gt;")
					.replace(/<[/]o>/mg,"&lt;/o&gt;")
					||"";
				push(result);
				end-code
				/// Support multiple lines
				/// Usage: "string" </o> when "string" contains <o></o>.

: </h>			( "html" -- element ) \ Delimiter of <h>, (H)ead section.
				compiling if compile /*remove*/ compile trim else /*remove*/ trim then
				char head compiling 
				if literal compile doElement 
				else doElement then ; immediate

: </e>			( "jQuery selector" "html" -- element ) \ Delimiter of <e>, general purpose.
				compiling if compile /*remove*/ compile trim else /*remove*/ trim then
				compiling if compile swap compile doElement 
				else swap doElement then ; immediate
				/// Example: char #outputbox <e> <h1>hi</h1></e>

: open			( "http://url" "name" -- win ) \ Open the URL return the window element named 'name' for <a> and <form> HTML tags.
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

: (pickFile)     ( -- HTMLInputElement ) \ Pick a file through web browser's GUI
                char input createElement ( element )
                dup char type  char file      setAttribute ( element )
                dup char class char pick_file setAttribute ( element ) \ for debug, clue of the element
                \ For none 3hta only, setup the event handler
                js> vm.appname!="jeforth.3hta" if
                    js: tos().onchange=function(){execute('stopSleeping')} ( element ) 
                    js: tos().oncancel=function(){execute('stopSleeping')} ( element ) 
                then
                js> body over appendChild \ 要 append 才有作用。 ( element )
                js: tos().click() ( element ) ; 
                /// Through excel app's GetOpenFilename method can do the same thing:
                ///     excel.app js> pop().GETopenFILENAME <== with or w/o () both fine
                /// Excel's GetSaveAsFilename method too.

                \ > (pickFile) <-- 手動選一個檔案
                \ dup :> value --> C:\fakepath\607400643.993051.mp4(string)
                \ dup :> type --> file(string)
                \ dup :> files --> [object FileList](object)
                \ dup :> readOnly --> false(boolean)
                \ dup :> multiple --> false(boolean)
                \ dup :> list --> null(object)
                \ > dup :> files[0] <-- 取得 file object 
                \ > .s
                \     0: C:\fakepath\607400643.993051.mp4 (string)
                \     1: [object HTMLInputElement] (object)
                \     2: [object File] (object)  see https://developer.mozilla.org/zh-TW/docs/Web/API/File 
                \ 2020/04/21 15:29:50 以上用以前寫的 pickFile 改成傳回 element, 然後用這 element
                \     做了些實驗。但是如何讀出 file 內容，例如讀取 .f 檔，還是不會。。。 blob object 
                \     好難懂難用的感覺。3HTA 測試過OK. 

: pickFile 		( -- "pathname" ) \ Pick a file through web browser's GUI
				(pickFile) ( element ) \ @ HTA 回來就表示 user 已經完成操作, @ NW.js 則馬上回來。
				\ For none 3hta only, wait for the onchange event
				js> vm.appname!="jeforth.3hta" if
					( minutes*60*1000 ) js> 5*60*1000 sleep ( element ) then
				js> tos().value \ 即使 timeout 也不管了 ( element path )  
				swap removeElement ; ( path )  
				/// Works fine on 3hta and 3nw. The dialog works but returns Null string on 3htm 
				/// or C:\fakepath\__865.jpg on 3ce. See Ynote : "jeforth.3we fix pickFile 
				/// problem on 3nw. Get full path of local file." for my developing log.
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

: remove-script-from-HTML ( "HTML" -- "HTML'" ) \ Remove script tags
				:> replace(/\r\n/mg,"{_cr_}")	\ for Windows
				:> replace(/\n/mg,"{_cr_}")	\ replace cr with _cr_ makes below operations easier
				:> replace(/<script.*?script>/g,"")		\ remove all <script> tags
				:> replace(/{_cr_}/g,"\n") ;
				/// See also remove-script-from-element in ie.f.
				/// Use RexEx word processing method.
				
: remove-style-from-HTML ( "HTML" -- "HTML'" ) \ Remove CSS style tags
				:> replace(/\r\n/mg,"{_cr_}")	\ for Windows
				:> replace(/\n/mg,"{_cr_}")	\ replace cr with _cr_ makes below operations easier
				:> replace(/<style.*?style>/g,"")		\ remove all <style> tags
				:> replace(/{_cr_}/g,"\n") ;
				/// See also remove-script-from-element in ie.f.
				/// Use RexEx word processing method.
				
: remove-select-from-HTML ( "HTML" -- "HTML'" ) \ Remove scripts and other things
				:> replace(/\r\n/mg,"{_cr_}")	\ for Windows
				:> replace(/\n/mg,"{_cr_}")	\ replace cr with _cr_ makes below operations easier
				:> replace(/<select.*?select>/g,"")		\ remove all <select>
				:> replace(/{_cr_}/g,"\n") ;
				/// Use RexEx word processing method.
				
: remove-onmouse-from-HTML ( "HTML" -- "HTML'" ) \ Remove onmouseXX="dothis"  onmouseXX=dothat onmouseXX='dowhat' listenings.
				:> replace(/\r\n/mg,"{_cr_}")	\ for Windows
				:> replace(/\n/mg,"{_cr_}")	\ replace cr with _cr_ makes below operations easier
				<js> pop().replace(/\s+onmouse.+?=\s?\S+/g,"")</jsV> 
				:> replace(/{_cr_}/g,"\n") ;
				/// Use RexEx word processing method.

