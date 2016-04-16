
s" html5.f"		source-code-header

\ Where HTML5 is supported, JSON is too, I guess.
: stringify		js> JSON.stringify(pop()) ; // ( obj -- "json" ) Convert the object to JSON string
				/// Example:
				/// activeSheet char a char b init-hash ( Get key-value hash table from Excel )
				/// stringify char pathname.json writeTextFile ( Convert to JSON save to file )
: parse			js> JSON.parse(pop()) ; // ( "json" -- obj ) Convert the "json" string to an object.
				/// Example:
				/// char pathname.json readTextFile ( Read JSON text )
				/// parse value MyHashTable ( convert JSON text to hash table object )

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
				char (</e>|</o>|</h>) word
				compiling if literal then ; immediate
				last dup alias <o> immediate // ( <html> -- "html" ) Starting a HTML section append to output box.
				alias <h> immediate // ( <html> -- "html" ) Starting a HTML section append to <HEAD>. 
				/// Section ending can be </e> </o> or </h> which are element, outputbox, and header
				/// respectively, so far. 分開寫也可以，併成一個只是圖方便。

: </o>			( "html" -- element ) \ Delimiter of <o>, (O)utputbox.
				compiling if compile trim else trim then
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
				compiling if compile trim else trim then
				char head compiling 
				if literal compile doElement 
				else doElement then ; immediate

: </e>			( "jQuery selector" "html" -- element ) \ Delimiter of <e>, general purpose.
				compiling if compile trim else trim then 
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

: remove-script-from-HTML ( "HTML" -- "HTML'" ) \ Remove scripts and other things
				:> replace(/\n/mg,"{_cr_}")	\ replace cr with _cr_ makes below operations easier
				:> replace(/<script.*?script>/g,"")		\ remove all <script>
				:> replace(/{_cr_}/g,"\n") ;
				/// See also remove-script-from-element in ie.f.
				/// Use RexEx word processing method.
				
: remove-select-from-HTML ( "HTML" -- "HTML'" ) \ Remove scripts and other things
				:> replace(/\n/mg,"{_cr_}")	\ replace cr with _cr_ makes below operations easier
				:> replace(/<select.*?select>/g,"")		\ remove all <select>
				:> replace(/{_cr_}/g,"\n") ;
				/// Use RexEx word processing method.
				
: remove-onmouse-from-HTML ( "HTML" -- "HTML'" ) \ Remove onmouseXX="dothis"  onmouseXX=dothat onmouseXX='dowhat' listenings.
				:> replace(/\n/mg,"{_cr_}")	\ replace cr with _cr_ makes below operations easier
				<js> pop().replace(/\s+onmouse.+?=\s?\S+/g,"")</jsV> 
				:> replace(/{_cr_}/g,"\n") ;
				/// Use RexEx word processing method.
				
