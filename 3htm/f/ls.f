
	\ Maintain source code in HTML5 local storage directly
	s" ls.f"		source-code-header
	
    : (eb.parent) ( node -- eb ) \ Get the parent edit box object of the given node/element.
        js> $(pop()).parents('.eb')[0] ( eb ) ;

    : eb.readonly ( btn -- ) \  Toggle read-only of the edit box.
        (eb.parent) ( eb ) \ The input object can be any node of the editbox.
		js> $(".ebreadonlyflag",tos())[0].checked if
			js: $(".ebreadonlyflag",tos())[0].checked=false
			js: $('textarea',tos()).attr("readOnly",false) \ 
			js: $('.ebhtmlarea',pop())[0].contentEditable=true \ last one use pop()
		else
			js: $(".ebreadonlyflag",tos())[0].checked=true
			js: $('textarea',tos()).attr("readOnly",true) \ 
			js: $('.ebhtmlarea',pop())[0].contentEditable=false \ last one use pop()
		then
		;
		
	code textarea.value->innerhtml ( scope -- ) \ Copy all textarea.value to its own innerHTML
		$("textarea",pop()).each(
			function()this.innerHTML = this.value;
		) end-code
		/// Only HTA textarea.innerHTML always catches up with its value.

	: eb.appearance.code ( eb -- ) \ Switch edit box appearance
		js: $(".ebmodeflag",tos())[0].checked=true
		js:	$(".ebhtmlarea",tos()).hide()
		js:	$(".ebtextarea",tos()).show()
		drop ;
		/// only appearance, content as is.
	
	: eb.appearance.browse ( eb -- ) \ Switch edit box appearance
		js: $(".ebmodeflag",tos())[0].checked=false
		js:	$(".ebtextarea",tos()).hide()
		js:	$(".ebhtmlarea",tos()).show()
		drop ;
		/// only appearance, content as is.
		
	: eb.content.browse ( eb -- ) \ Switch edit box to use browse mode content
	
	code eb.content.code ( eb -- ) \ Switch edit box to use code mode content
		$(".ebhtmlarea",pop()).html($(".ebtextarea",tos())[0].value)
		end-code
	

	: eb.mode.toggle ( btn -- ) \ Toggle edit box between code mode and browse mode
        (eb.parent) ( eb ) \ The input object can be any node of the editbox.
		js> $(".ebmodeflag",tos())[0].checked if
			
			eb.mode.browse
		else
			\ Overwrite all textarea innerHTML with its own value
			js: $("textarea",tos()).each(function(){this.innerHTML=this.value})
			js: $(".ebtextarea",tos())[0].value=$(".ebhtmlarea",tos()).html()
			eb.mode.code
		then drop ;
		
	
    : eb.save ( btn -- ) \ Save the edit box to localStorate[name].
        (eb.parent) ( eb ) \ The input object can be any node of the editbox.
		\ Switch to source mode to get borwser mode's value
		js> $(".ebmodeflag",tos())[0].checked dup if else over eb.mode then swap ( mode eb )
        js> $('.ebname',tos())[0].value trim ( mode eb name ) \ get field name
        js> $('.ebtextarea',tos(1))[0].value ( mode eb name text ) \ get code
		js> storage.get(tos(1)) ( mode eb name text hash )
		js: tos().data=pop(1) ( mode eb name hash' )
		js: tos().mode=tos(3) ( mode eb name hash' )
		js: tos().readonly=$(".ebmodeflag",tos(2))[0].checked
        js: storage.set(pop(1),pop()) ( mode eb ) \ save code to field
		js: $(".ebsaveflag",tos())[0].checked=true ( mode eb ) 
		swap if else eb.mode then ;
		/// localStorage['fieldname']=JSON.stringify({data:string,mode:boolean,readonly:boolean})
        
    : eb.close ( btn -- ) \ Close the local storage edit box to stop editing.
        (eb.parent) ( eb ) \ The input object can be any node of the editbox.
        js> $(".ebsaveflag",tos())[0].checked not if 
            <js> confirm("Are you sure you want to clsoe the unsaved local storage edit box?") </jsV> 
            if else exit then
        then ( eb ) removeElement ;

    : eb.delete ( btn -- ) \ Delete the local storage edit box and the local storage field.
        (eb.parent) ( eb ) \ The input object can be any node of the editbox.
        <js> $('textarea',tos())[0].value.indexOf("delete me no regret")!=0</jsV>
        if <js> alert('Place "delete me no regret" at the very beginning of the textarea to demonstrate yor guts.') </js> drop exit then
        js> $('.ebname',tos())[0].value trim ( eb name ) 
        js: storage.del(pop()) ( eb ) removeElement ;

    : eb.run ( btn -- ) \ Run FORTH source code of the local storage edit box.
        (eb.parent) ( eb ) \ The input object can be any node of the editbox.
        js: dictate($('textarea',pop())[0].value) ;
        
    : eb.onchange ( btn -- ) \ Event handler on local storage edit box has changed
        (eb.parent) ( eb ) \ The input object can be any node of the editbox.
        js: $(".ebsaveflag",pop())[0].checked=false ;

    code eb.init-modes ( eb -- eb ) \ Initialize modes of the edit box.
		if ($(".ebreadonlyflag",tos())[0].checked){
			$('textarea',tos()).attr("readOnly",true);
			$('.ebhtmlarea',tos())[0].contentEditable=false;
		} else {
			$('textarea',tos()).attr("readOnly",false);
			$('.ebhtmlarea',tos())[0].contentEditable=true;
		}
		if ($(".ebmodeflag",tos())[0].checked){
			$(".ebtextarea",tos()).show();
			$(".ebhtmlarea",tos()).hide();
		} else {
			$(".ebtextarea",tos()).hide();
			$(".ebhtmlarea",tos()).show();
		}
		end-code
	
    : eb.init-buttons ( eb -- eb ) \ Initialize buttons of the local storage edit box.
        <js> $(".ebreadonly",tos())[0].onclick =function(e){push(this);execute("eb.readonly");return(false)}</js>
        <js> $(".ebmode",    tos())[0].onclick =function(e){push(this);execute("eb.mode");    return(false)}</js>
        <js> $(".ebsave",    tos())[0].onclick =function(e){push(this);execute("eb.save");    return(false)}</js>
        <js> $(".ebread",    tos())[0].onclick =function(e){push(this);execute("eb.read");    return(false)}</js>
        <js> $(".ebclose",   tos())[0].onclick =function(e){push(this);execute("eb.close");   return(false)}</js>
        <js> $(".ebrun",     tos())[0].onclick =function(e){push(this);execute("eb.run");     return(false)}</js> 
        <js> $(".ebdelete",  tos())[0].onclick =function(e){push(this);execute("eb.delete");  return(false)}</js> 
        <js> $(".ebtextarea",tos())[0].onchange=function(e){push(this);execute("eb.onchange");return(false)}</js> 
        <js> 
			$(".ebsaveflag",tos())[0].checked = true;
			$(".ebmodeflag",tos())[0].checked = true;
			$(".ebreadonlyflag",tos())[0].checked = false;
            $(".ebtextarea",tos())[0].onkeydown = function(e) {
                e = (e) ? e : event; 
                var keycode = (e.keyCode) ? e.keyCode : (e.which) ? e.which : false;
                switch(keycode) {
                    case  83: /* s */
                        if (e&&e.ctrlKey) {
                            push(this); // ( textarea ) 
                            execute("eb.save");
                            this.innerHTML=this.value;this.value=this.innerHTML; // Saved already so clear the onchange status
                            e.stopPropagation ? e.stopPropagation() : (e.cancelBubble=true); // stop bubbling
                            return(false);
                        }
                    default: return (true); // pass down to following handlers
                }
            }
        </js> ;

    : (ed) ( -- edit_box_element ) \ Create an HTML5 local storage edit box in outputbox
        <text>
            <div class=eb>
            <style type="text/css">
                .eb .box { width:90%; }
                .eb .box, .eb .ebhtmlarea { border:1px solid black; }
                .eb p { display:inline; } /* [ ] <P> 不該有套疊,故多餘的很容易可以消除 */
				.eb .ebname { font-size: 1.1em; }
            </style>
            <div class=box>
            <p>Local Storage</p>
            <input class=ebname type=text placeholder="field name"></input> /* HTA not support 'placeholder' yet */
            <p>
            <input type=checkbox class=ebreadonlyflag disabled="disabled"><input type=button value='R/O' class=ebreadonly>
            <input type=checkbox class=ebmodeflag disabled="disabled"><input type=button value='</>' class=ebmode>
            <input type=checkbox class=ebsaveflag disabled="disabled"><input type=button value='Saved' class=ebsave>
            <input type=button value='Read' class=ebread>
            <input type=button value='Delete' class=ebdelete>
            <input type=button value='Close' class=ebclose>
            <input type=button value='Run' class=ebrun>
            </p>
			<div class=ebbody style="margin:0 0 0 0;">
            <textarea class=ebtextarea rows=20 wrap="off"></textarea>
			<div class=ebhtmlarea></div>
			</div>
			</div>
			</div>
		</text> /*remove*/
        </o> ( eb ) 
		dup js> outputbox insertBefore
		js: window.scrollTo(0,tos().offsetTop-50) ( eb )
        eb.init-buttons eb.init-modes ;
    
    : ed (ed) drop ; // ( -- ) Create an HTML5 local storage edit box in outputbox
	
    : (eb.read) ( eb field_name -- ) \  Read the localStorate[name] to textarea of the given edit box.
		over js: $(".ebmodeflag",tos())[0].checked=false eb.mode \ use code mode
        js> storage.get(tos())  ( eb name hash|undefined ) 
        js> tos()==undefined if  ( eb name hash|undefined ) 
            <js> alert("Error! can't find '" + pop(1) + "' in local storage.")</js>
            2drop exit
        then  nip ( eb hash )
        js> $(".ebsaveflag",tos(1))[0].checked not if  ( eb hash )
            <js> confirm("Unsaved edit box will be overwritten, are you sure?") </jsV> 
            if else 2drop exit then
        then  ( eb hash )
        js: $('.ebtextarea',tos(1))[0].value=tos().data 
		js: $(".ebsaveflag",tos(1))[0].checked=true 
		js: $(".ebreadonlyflag",tos(1))[0].checked=tos().readonly
		js: $(".ebmodeflag",tos(1))[0].checked=tos().mode
		eb.init-modes ;
		/// 讀進來固定用 code mode 顯示
    
    : eb.read ( btn -- ) \ Read the localStorate[name] to textarea.
        (eb.parent) ( eb ) \ The input object can be any node of the editbox.
        js> $('.ebname',tos())[0].value trim ( eb name ) (eb.read) ;
	
	: autoexec ( -- ) \ Run localStorage.autoexec
		js> storage.get("autoexec") js> tos() if  ( autoexec )
			tib.insert
		then ;

	: (run)  ( "local storage field name" -- ) \ Run local storage source code.
		js> storage.get(pop()) tib.append ;
		
	: run ( <local storage field name> -- ) \ Run local storage source code.
		char \n|\r word trim (run) ;

	\ : cls  ( -- ) \ Clear all #text in the outputbox elements are remained.
	\ 	ce@ ( save ) js> outputbox ce! er ce! ( restore ) ;
	\ 	/// Auto save-restore ce@ so it won't be changed.
	
	: list ( -- ) \ List all localStorage fields, click to open
		<text> <unindent><br>
			Local storage field '<code>autoexec</code>' is run when start-up.
			'<code>run <field name></code>' to run the local storage field.
			'<code>ed</code>' opens local storage editor and when in this editor,
			hotkey <code>{F9},{F10}</code> resize the textarea and <code>{Ctrl-S}</code> saves
			the textarea to local storage.
			'<code>export-all</code>' exports the entire local storage in JSON format.
			<br><br>
		</unindent></text> <code>escape </o> drop
		js> storage.all() obj>keys ( array )
		begin js> tos().length while ( array )
			js> tos().pop()  ( array- fieldname )
			<text>
				<li> _fieldname_ 
				<input class=lsfieldopen fieldname='_fieldname_' type=button value=Open> 
				<input class=lsfieldexport fieldname='_fieldname_' type=button value=Export>
				</li>
			</text>	( array- fieldname HTML )
			:> replace(/_fieldname_/mg,pop()) </o> drop
		repeat drop cr
		<js> 
			$("input.lsfieldopen").click(function(){
				execute("(ed)"); 
				push(this.getAttribute("fieldname")); // ( eb name ) 
				$('.ebname',tos(1))[0].value=tos();
				execute("(eb.read)");
			})
			$("input.lsfieldexport").click(function(){
				push(null); // ( null ) 
				push(storage.get(this.getAttribute("fieldname"))); // ( null text ) 
				execute("(export)");
			})
		</js> ;
		
	: (export) ( null|window "text" -- ) \ Export the given text string to a window
		js> tos(1) if else nip js> window.open() swap then ( window "text" )
		js: pop(1).document.write("<html><body><pre>"+pop()+"</pre></body></html>") ;
		
	: export ( <field> -- ) \ Create a window to export a local storage field.
		null char \n|\r word trim js> storage.get(pop()) (export) ;
		
	: export-all ( -- ) \ Create a window to export entire local storage in JSON format.
		null js> JSON.stringify(storage.all(),"\n","\t") (export) ;
stop

	\ Setup default autoexec, ad, and pruning if autoexec is not existing
	js> storage.get("autoexec") [if] [else] 
		<text> <unindent>
			js: outputbox.style.fontSize="1.5em"
			cr cr 
			." Hello world!! says 'autoexec' field" cr
			." from published jeforth.3ce. "
			cr cr 
			.( Launch the briefing ) cr
			<o> <iframe src="http://note.youdao.com/share/?id=79f8bd1b7d0a6174ff52e700dbadd1b2&type=note"
			name="An introduction to jeforth.3ce" align="center" width="96%" height="1000px"
			marginwidth="1" marginheight="1" frameborder="1" scrolling="Yes"> </iframe></o> drop
			cr cr 
			.( execute the 'list' command ) cr
			list
		</unindent></text> unindent js: storage.set("autoexec",pop())

 		js> storage.get("ad") [if] [else] \ Default ad if it's not existing
			<text> <unindent>
				\ Remove all annoying floating ad boxes. 刪除所有惱人的廣告框。
				active-tab :> id tabid! <ce>
				var divs = document.getElementsByTagName("div");
				for (var i=divs.length-1; i>=0; i--){
				  if(divs[i].style.position){
					divs[i].parentNode.removeChild(divs[i]);
				  }
				}
				for (var i=divs.length-1; i>=0; i--){
				  if(parseInt(divs[i].style.width)<600){ // <---- 任意修改
					divs[i].parentNode.removeChild(divs[i]);
				  }
				}
				</ce>
			</unindent></text> unindent js: storage.set("ad",pop())
		[then]

		js> storage.get("pruning") [if] [else] \ Default pruning if it's not existing
			<text> <unindent>
				\ Make the target page editable for pruning. 把 target page 搞成 editable 以便修剪。
				active-tab :> id tabid! <ce> document.getElementsByTagName("body")[0].contentEditable=true </ce>
			</unindent></text> unindent js: storage.set("pruning",pop())
		[then]
	[then]

	autoexec \ Run localStorage.autoexec when jeforth starting up
	
	
<comment>
storage {


}
js> window.storage==undefined [if]
    js: window.storage={}
    js: window.storage.set=function(key,data){localStorage[key]=data}
    js: window.storage.get=function(key){return(localStorage[key])}
    js: window.storage.all=function(){return(localStorage)}
    js: window.storage.del=function(key){delete(localStorage[key])}
    js: window.storage.field=function(key){return(localStorage[key])} \ 
[then]

</comment>