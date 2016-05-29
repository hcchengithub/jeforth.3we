
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

	: eb.appearance.code ( eb -- ) \ Switch edit box appearance
		js: $(".ebmodeflag",tos())[0].checked=true
		js:	$(".ebhtmlarea",tos()).hide()
		js:	$(".ebtextarea",pop()).show() ;
		/// only appearance, content as is.

	: eb.appearance.browse ( eb -- ) \ Switch edit box appearance
		js: $(".ebmodeflag",tos())[0].checked=false
		js:	$(".ebtextarea",tos()).hide()
		js:	$(".ebhtmlarea",pop()).show() ;
		/// only appearance, content as is.

	code textarea.value->innertext ( eb -- ) \ Copy all textarea.value to its own innerText
		if (vm.appname != "jeforth.3hta")
			$("textarea",pop()).each(function(){this.innerText = this.value});
		else pop();
		end-code
		/// Only HTA textarea.innerHTML always catches up with its value.
		/// Other browsers need this word.

	: eb.content.browse ( eb -- ) \ Use browse mode content
		dup textarea.value->innertext \ browse mode 之下萬一有 textarea 通通生效到各自的 innerText。
		js: $(".ebtextarea",tos())[0].value=$(".ebhtmlarea",pop())[0].innerHTML
		;
		/// Copy $(".ebhtmlarea").innerHTML to $(".ebtextarea").value

		
	code living-tag-confirmed?  ( "article" -- boolean ) \ Does the article has script, style, etc special tags etc?
	    var flag = true,
		    warn =  
				tos().indexOf("<script")!=-1 ||
				tos().indexOf("<link")!=-1 ||
				tos().indexOf("<style")!=-1 ||
				tos().indexOf("<iframe")!=-1;  // pop() 不能用在這裡面, 因為不一定會被執行到。
		pop();	// drop() 必須獨立放在會執行到的地方。
		if (warn) flag = confirm("Tag of script,link,style, or iframe found, let them go alive?");
		push(flag);
		end-code 
		/// Those tags may cause problems if went live in a .ebhtmlarea.
		/// Check this before calling eb.content.code.
		
	: eb.content.code ( eb -- ) \ Use code mode content
	    js> $(".ebtextarea",tos())[0].value ( eb article )
		js: $(".ebhtmlarea",pop(1)).html(pop()) ;
		/// Copy $(".ebtextarea").value to $(".ebhtmlarea").html()

	: eb.mode.toggle ( btn -- ) \ Toggle edit box between code mode and browse mode
        (eb.parent) ( eb ) \ The input object can be any node of the target editbox.
		js> $(".ebmodeflag",tos())[0].checked ( codeMode? ) if
			\ Now codeMode to be browse mode
			\ Warn &gt; translation may clutter your code.
			<js> 
				confirm(
					"HTML Browsing mode may clutter your code,\n" +
				    "e.g. '>' become '&gt;', Continue?\n" +
					"Make a Save even if you're only to view."
				) 
			</jsV> 
			if else exit then ( eb )
			\ Warn living tag found
			js> $(".ebtextarea",tos())[0].value ( eb article )
			living-tag-confirmed? if
				( eb ) dup eb.content.code \ use current, code mode's content
				eb.appearance.browse
			else drop then
		else
			\ switch to code mode
			dup eb.content.browse \ use current, browse mode's content
			eb.appearance.code
		then ;
		/// Some GT LT will be changed to &gt; &lt; unexpectedly 
		/// when switching to HTML borwsing mode. Save is suggested.

    : eb.save ( btn -- ) \ Save the edit box to localStorate[name].
        (eb.parent) ( eb ) \ The input object can be any node of the editbox.
		\ Use recent mode's content
			js> $(".ebmodeflag",tos())[0].checked ( eb mode? )
			if else dup eb.content.browse then \ now .ebtextarea is what to be saved ( eb ) 
		\ Get object ready
			js> $('.ebname',tos())[0].value trim ( eb name ) \ get field name
			js> $('.ebtextarea',tos(1))[0].value ( eb name text ) \ get code
			js> storage.get(tos(1)) ( eb name text hash ) \ get target object
			js: if(!tos()||typeof(tos())!="object"){pop();push({})} \ in case the field is not existing nor an object
			( eb name text hash ) 
		\ Start modifying the object
			js: tos().doc=pop(1) ( eb name hash' ) \ code 
			js: tos().mode=$(".ebmodeflag",tos(2))[0].checked ( eb name hash' ) \ mode flag
			js: tos().readonly=$(".ebreadonlyflag",tos(2))[0].checked \ read only flag
			( eb name hash' ) 
		\ Write the object back to local storage
			js: storage.set(pop(1),pop()) ( eb ) \ save code to field
		\ Adjust the saved flag
			js: $(".ebsaveflag",pop())[0].checked=true 
		;
		/// Data structure of a local storage field:
		/// localStorage['fieldname'] = JSON.stringify (
		///   { doc:string, mode:boolean, readonly:boolean }
		/// )

    : eb.close ( btn -- ) \ Close the local storage edit box to stop editing.
        (eb.parent) ( eb ) \ The input object can be any node of the editbox.
        js> $(".ebsaveflag",tos())[0].checked not if 
            <js> confirm("Are you sure you want to clsoe the unsaved local storage edit box?") </jsV> 
            if else exit then
        then ( eb ) removeElement ;

    : eb.delete ( btn -- ) \ Delete the local storage edit box and the local storage field.
        (eb.parent) ( eb ) \ The input object can be any node of the editbox.
        <js> 
			var guts = "delete me no regret";
			$('.ebtextarea',tos())[0].value.toLowerCase().indexOf(guts)<0 &&
		    $('.ebhtmlarea',tos())[0].innerText.toLowerCase().indexOf(guts)<0
		</jsV> ( eb flag )
        if <js> alert('Place "delete me no regret" in the document to demonstrate yor guts.') </js> drop exit then
        js> $('.ebname',tos())[0].value trim ( eb name ) 
        js: storage.del(pop()) ( eb ) removeElement ;

    : eb.run ( btn -- ) \ Run FORTH source code of the local storage edit box.
        (eb.parent) ( eb ) \ The input object can be any node of the editbox.
        js: dictate($('textarea',pop())[0].value) ;
        
    : eb.onchange ( btn -- ) \ Event handler on local storage edit box has changed
        (eb.parent) ( eb ) \ The input object can be any node of the editbox.
        js: $(".ebsaveflag",pop())[0].checked=false ;
		/// [ ] Don't know how to handle it if is changed in browse mode.

    code eb.settings ( eb -- ) \ Set edit box settings according to checkboxes
		// call eb.settings 時 eb 都在 code mode, 然後視 checkbox 切換。
		if ($(".ebreadonlyflag",tos())[0].checked){
			$('textarea',tos()).attr("readOnly",true);
			$('.ebhtmlarea',tos())[0].contentEditable=false;
		} else {
			$('textarea',tos()).attr("readOnly",false);
			$('.ebhtmlarea',tos())[0].contentEditable=true;
		}
		// 只管外觀，不切換 content, 因為要不要 copy the content from the other mode is uncertain.
		if ($(".ebmodeflag",tos())[0].checked){
			execute("eb.appearance.code");
		} else {
			execute("eb.appearance.browse");
		}
		end-code
		/// 外觀 code mode or browse mode, editable or not, whether read only.
	
    : eb.init-buttons ( eb -- ) \ Initialize buttons of the local storage edit box.
        <js> $(".ebreadonly",tos())[0].onclick =function(e){push(this);execute("eb.readonly");return(false)}</js>
        <js> $(".ebmode",    tos())[0].onclick =function(e){push(this);execute("eb.mode.toggle");    return(false)}</js>
        <js> $(".ebsave",    tos())[0].onclick =function(e){push(this);execute("eb.save");    return(false)}</js>
        <js> $(".ebread",    tos())[0].onclick =function(e){push(this);execute("eb.read");    return(false)}</js>
        <js> $(".ebclose",   tos())[0].onclick =function(e){push(this);execute("eb.close");   return(false)}</js>
        <js> $(".ebrun",     tos())[0].onclick =function(e){push(this);execute("eb.run");     return(false)}</js> 
        <js> $(".ebdelete",  tos())[0].onclick =function(e){push(this);execute("eb.delete");  return(false)}</js> 
        <js> $(".ebtextarea",tos())[0].onchange=function(e){push(this);execute("eb.onchange");return(false)}</js> 
        <js> // ( eb ) 以下類似的 handler 寫兩次 to be fool and safe.
            $(".ebtextarea",tos())[0].onkeydown = function(e) {
                e = (e) ? e : event; 
                var keycode = (e.keyCode) ? e.keyCode : (e.which) ? e.which : false;
                switch(keycode) {
                    case  83: /* s */
                        if (e&&e.ctrlKey) {
                            push(this); // ( textarea ) 
                            execute("eb.save");
							// Saved already so clear the onchange status
								this.innerText=this.value; 
								// this.value=this.innerText; 這會造成 3nw 把整個 textarea 都清掉!! 幸好用不著。
                            e.stopPropagation ? e.stopPropagation() : (e.cancelBubble=true); // stop bubbling
                            return(false);
                        }
                    default: return (true); // pass down to following handlers
                }
            } // ( eb )
            $(".ebhtmlarea",pop())[0].onkeydown = function(e) { // ( empty )
                e = (e) ? e : event; 
                var keycode = (e.keyCode) ? e.keyCode : (e.which) ? e.which : false;
                switch(keycode) {
                    case  83: /* s */
                        if (e&&e.ctrlKey) {
                            push(this); // ( htmlarea ) 
                            execute("eb.save");
                            e.stopPropagation ? e.stopPropagation() : (e.cancelBubble=true); // stop bubbling
                            return(false);
                        }
                    default: return (true); // pass down to following handlers
                }
            }
        </js> ;

    : (ed) ( -- edit_box_element ) \ Create an HTML5 local storage edit box above outputbox
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
			<div class=ebbody>
            <textarea class=ebtextarea rows=12 wrap="off"></textarea>
			<div class=ebhtmlarea></div>
			</div>
			</div>
			</div>
		</text> /*remove*/ </o> ( eb ) 
        dup eb.init-buttons 
		js:	$(".ebsaveflag",tos())[0].checked=true;
		js:	$(".ebmodeflag",tos())[0].checked=true;
		js:	$(".ebreadonlyflag",tos())[0].checked=false;
		dup eb.settings 
		dup js> outputbox insertBefore
		js: inputbox.blur();window.scrollTo(0,tos().offsetTop-50) ( eb ) ;

	: local-storage-field-editable? ( name -- name field boolean ) \ Check if the object is a local storage editable or awared document
		js> storage.get(tos()) >r 
		js> typeof(rtos())=="object" if
			js> typeof(rtos().doc)=="string"
			js> typeof(rtos().mode)=="boolean"
			js> typeof(rtos().readonly)=="boolean"
			and and ( boolean )
		else 
			false ( boolean )
		then r> swap ;
		/// eb.open check it out, if not editable JSON.stringify() 
		/// can make it a string and show. and by the way check readonly.

    : (eb.read) ( eb name -- ) \ Read the localStorate[name] to textarea of the given edit box.
		\ Idiot-proof first of all
			js> $(".ebsaveflag",tos(1))[0].checked not if  ( eb name )
				<js> confirm("Overwrite unsaved edit box, are you sure?") </jsV> 
				if else 2drop exit then
			then  
			( eb name )
		\ check the field name 	
			local-storage-field-editable? ( eb name field editable? )
			rot ( eb field editable? name ) js> Boolean(tos(2)) if else
				<js> alert("Error! can't find '" + pop() + "' in local storage.")</js>
				drop 2drop exit
			then drop
			( eb field editable? )
		\ Load the edit box with the hash
			js: $(".ebsaveflag",tos(2))[0].checked=true \ the field is Saved 
			( eb field editable? ) \ editable means it's a ls.f ed awared local storage field/document
			if ( eb field )
				<js>
					$('.ebtextarea',tos(1))[0].value = tos().doc;
					$(".ebreadonlyflag",tos(1))[0].checked = tos().readonly;
				</js>
				js> $(".ebmodeflag",tos(1))[0].checked=tos().mode;  ( eb field mode )
				if  ( eb field ) 
					drop ( eb ) 
				else \ Take care of Browse mode   ( eb field )
					:> doc ( eb doc ) living-tag-confirmed? ( eb flag ) if 
						( eb ) dup eb.content.code \ copy code mode's content to browse mode  ( eb )
					else ( eb )
						js: $(".ebmodeflag",tos())[0].checked=true \ user refused, so stay in code mode
					then ( eb )	
				then ( eb )
			else ( eb field )
				<js>
				$(".ebreadonlyflag",tos(1))[0].checked = true;
				$(".ebmodeflag",tos(1))[0].checked = true;					
				$('.ebtextarea',tos(1))[0].value = JSON.stringify(pop());
				</js>
			then  ( eb )
		\ Activate settings ( eb )
			eb.settings ;
		/// 讀進來固定都先放 .ebtextarea, 好像有好處, [ ] 待分析清楚。		
		/// [ ] 解決 snapshot 讀回來發現有 textarea.value 而 htmlarea.innerHTML 卻是空的的問題。
    
    : eb.read ( btn -- ) \ Read the localStorate[name] to textarea.
        (eb.parent) ( eb ) \ The input object can be any node of the editbox.
        js> $('.ebname',tos())[0].value 
		trim ( eb name ) (eb.read) ;
	
    : ed ( <field name> -- ) \ Edit local storage field
		(ed) ( eb ) char \n|\r word trim ( eb name ) 
		js> tos()!="" if  ( eb name ) 
			js: $('.ebname',tos(1))[0].value=tos() ( eb name ) (eb.read) 
		else 2drop then ; 

	: (run)  ( "local storage field name" -- ) \ Run local storage source code.
		js> storage.get(pop()).doc tib.append ;
		
	: run ( <local storage field name> -- ) \ Run local storage source code.
		char \n|\r word trim (run) ;
		/// 一整行都當 field name 可以有空格。

	: (export) ( "string" -- ) \ Export the string to a textarea in a new window
		\ HTA can open only one window, don't know why. Use that one anyway.
		js> window.open('about:blank','export') ( field window )
		js> tos().document.getElementsByTagName("html").length ( field window count )
		if js: tos().document.removeChild(tos().document.getElementsByTagName("html")[0]) then 
		( field window )
		<js> 
			// 如果不弄個 textarea 來顯示, 恐怕有些東西會被翻譯成 HTML。
			tos().document.write(
				'<html><body>' +
				'<textarea ' +
				'id=exportbox ' +
				'style="width:100%;font-size:1.3em"' +
				'rows=20>' +
				'</textarea></body></html>'
			);
			pop().document.getElementById("exportbox").value=pop();
		</js> ;
		
	: export ( <field> -- ) \ Create a window to export a local storage field.
		char \n|\r word trim ( field-name )
		js> storage.get(pop()) ( field-obj )
		js> JSON.stringify(pop()) ( "json of the field" )
		(export) ;
		
	: export-all ( -- ) \ Create a window to export entire local storage in JSON format.
		js> JSON.stringify(storage.all()) (export) ;
		/// The format is compatible with (3hta or 3nw )\localstorage.json 
		/// 手動 copy-paste 到 text editor 然後存檔，此為 jeforth.3hta, 3ca 等不能存檔
		/// 的環境而設。

	code import-all ( "string" -- ) \ Import entire localStorage in the format of export-all 
		var ss = pop();
		// if is from 3hta then it's utf-8 with BOM (EF BB BF) that bothers NW.js JSON.parse()
		// ss.charCodeAt(0)==65279 that's utf-8 BOM 
		if (ss.charCodeAt(0)==65279) ss = ss.slice(1); // resolve the utf-8 BOM issue for jeforth.3nw
		var ls = JSON.parse(ss);
		for (var i in ls) storage.set(i,ls[i]);
		end-code
		/// The format is compatible with (3hta or 3nw )\localstorage.json 
		/// 手動 <text> ...</text> import-all 即可 import 來自 export-all 的整個 local storage。
		/// Example: jeforth.3ce 讀取 3hta 的整個 local storage
		///     char 3hta/localstorage.json readTextFile import-all
   : (vb) ( -- vb ) \ Create view box in outputbox, view a localStorage field
        <text>
            <div class=vb>
            <style type="text/css">
                .vb .box { width:90%; }
                .vb .box, .vb .vbhtmlarea { border:1px solid black; }
                .vb p { display:inline; } /* [ ] <P> 不該有套疊,故多餘的很容易可以消除 */
				.vb .vbname { font-size: 1.1em; }
            </style>
            <div class=box>
				<p class=vbpathname>vb path name</p> &gt; <b class=vbfieldname>vb field name</b>
				<div class=vbbody>
					<textarea class=vbtextarea rows=12 wrap="off"></textarea>
					<div class=vbhtmlarea></div>
				</div>
			</div>
			</div>
		</text> /*remove*/ </o> ( vb ) 
		js: $('.vbtextarea',tos()).attr("readOnly",true)
		js: $('.vbhtmlarea',tos())[0].contentEditable=false
		js: inputbox.blur();window.scrollTo(0,tos().offsetTop-50) ( vb ) ;

	: vb.load ( vb hash fieldname -- ) \ Load data into a view box 
*debug* 0011>>		
		js: $(".vbfieldname",tos(2)).html(tos())  ( vb hash fieldname ) 
*debug* 0022>>		
		js> pop(1)[pop()] ( vb "field" )
		<js> try {
			var data = JSON.parse(tos()); // The field is an object
		} catch(err) {
			data = tos(); // Not an object
		}; push(data) </js> nip ( vb field )
		dup :> doc ( vb field doc )
*debug* 11>>		
		js> tos()==undefined if 
			drop 
		else
		then 
		swap ( vb doc field )
*debug* 22>>		
		:> mode ( vb doc mode ) if ( vb doc )
*debug* 33>>		
			js:	$(".vbhtmlarea",tos(1)).hide() 
			js: $('.vbtextarea',pop(1))[0].value=pop() ( empty )
		else ( vb doc )
*debug* 44>>		
			js: $(".vbtextarea",tos(1)).hide()
			js: $(".vbhtmlarea",pop(1)).html(pop()) ( empty )
		then ; 

	: (ls.dump) ( pathname -- ) \ Dump the entire json file in localstorage.json format 
		dup >r readTextFile ( "json" ) 
		\ resolve utf-8 BOM ss.charCodeAt(0)==65279 that's utf-8 BOM 
		js> tos().charCodeAt(0)==65279 if js> pop().slice(1) then ( "json" )
		js> JSON.parse(pop()) ( hash )
		dup obj>keys swap ( array hash ) 
*debug* 2233>>		
		js> tos(1).length ?dup if for ( array hash )
*debug* 223344>>		
			(vb) js: $(".vbpathname",tos()).html(rtos(1)) ( vb )
			over ( array hash vb hash )
*debug* 223355>>		
			js> tos(3).pop() cr dup . cr ( array hash vb hash fieldname )
*debug* 223366>>		
			vb.load
*debug* 223377>>		
		next then ( array hash ) 2drop r> drop ;

    : ls.dump ( <field name> -- ) \ Dump the entire localstorage.json formated file
		char \n|\r word trim ( pathname ) (ls.dump) ;

	: autoexec ( -- ) \ Run localStorage.autoexec
		js> storage.get("autoexec").doc js> tos() if  ( autoexec )
			tib.insert
		then ;

	: list ( -- ) \ List all localStorage fields, click to open
		\ Print How to use,
			<text> <unindent><br>
				HTML5 Local storage field '<code>autoexec</code>' is run when start-up.
				'<code>run <field name></code>' runs the local storage field, you make sure it's executable.
				'<code>ed <field-name or blank></code>' opens local storage editor, 
				hotkey <code>{F9},{F10}</code> resize the textarea, <code>{Ctrl-S}</code> saves
				it to local storage.
				'<code>export-all</code>' exports the entire local storage in JSON format.
				<br><br>
			</unindent></text> <code>escape </o> drop
		\ main loop 印出所有的 fields 
			js> storage.all() obj>keys ( array ) \ array of field names
			<o> <div class=lslist></div></o> swap ( DIV array ) \ 放整個 list 的 DIV, 非必要但可避免被 er 刪除。
			begin js> tos().length while ( DIV array )
				js> tos().pop()  ( DIV array fieldname )
				<o>	<input class=lsfieldexport type=button value=Export></o> ( DIV array fieldname INPUT )
					dup  ( DIV array fieldname INPUT INPUT ) 
					char fieldname   ( DIV array fieldname INPUT INPUT "fieldname" ) 
					js> tos(3)   ( DIV array fieldname INPUT INPUT "fieldname" fieldname ) 
					setAttribute ( DIV array fieldname INPUT ) 
					js> tos(3) swap appendChild  ( DIV array fieldname ) 
				<o> <input class=lsfieldopen type=button value=Open></o> ( DIV array fieldname INPUT ) 
					dup char fieldname js> tos(3) setAttribute ( DIV array fieldname INPUT ) 
					js> tos(3) swap appendChild  ( DIV array fieldname ) 
				s" <span> " swap + char <br></span> + </o> ( DIV array SPAN ) 
				js> tos(2) swap appendChild ( DIV array ) 
			repeat 2drop 
		\ 給以上變出來的 buttons 畫龍點睛
			<js> 
				$("input.lsfieldopen").click(function(){
					execute("(ed)"); 
					push(this.getAttribute("fieldname")); // ( eb name ) 
					$('.ebname',tos(1))[0].value=tos();
					execute("(eb.read)");
				})
				$("input.lsfieldexport").click(function(){
					push(storage.get(this.getAttribute("fieldname"))); // ( field-obj ) 
					push(JSON.stringify(pop())); // ( json-string )
					execute("(export)");
				})
			</js> 
		;

	: snapshot ( -- ) \ Save outputbox to a ed
		(ed) ( eb ) \ default is editable, saved, code mode
		s" Snapshot " now t.dateTime + ( eb "now" ) 
		js: $(".ebname",tos(1))[0].value=pop() ( eb )
		dup textarea.value->innertext ( eb ) \ let textarea.innerText = its.value
		js: $(".ebhtmlarea",tos())[0].innerHTML=outputbox.innerHTML ( eb ) \ load the content, let &lt; translation happen.
		dup eb.appearance.browse ( eb ) 
		js: $(".ebsaveflag",pop())[0].checked=false ; \ Not saved yet, up to users decision
 
	\ Setup default autoexec, ad, and pruning if autoexec is not existing
	
	js> storage.get("autoexec") [if] [else] 
		<text> <unindent>
			js: outputbox.style.fontSize="1.5em"
			cr .( Launch the briefing ) cr
			<o> <iframe src="http://note.youdao.com/share/?id=79f8bd1b7d0a6174ff52e700dbadd1b2&type=note"
			name="An introduction to jeforth.3ce" align="center" width="96%" height="1000px"
			marginwidth="1" marginheight="1" frameborder="1" scrolling="Yes"> </iframe></o> drop
			cr cr 
			.( execute the 'list' command ) cr
			list
		</unindent></text> unindent 
		{} js: tos().doc=pop(1) js: tos().readonly=true js: tos().mode=true
		js: storage.set("autoexec",pop())

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
			</unindent></text> unindent 
			{} js: tos().doc=pop(1) js: tos().readonly=true js: tos().mode=true
			js: storage.set("ad",pop())
		[then]

		js> storage.get("pruning") [if] [else] \ Default pruning if it's not existing
			<text> <unindent>
				\ Make the target page editable for pruning. 把 target page 搞成 editable 以便修剪。
				active-tab :> id tabid! <ce> document.getElementsByTagName("body")[0].contentEditable=true </ce>
			</unindent></text> unindent 
			{} js: tos().doc=pop(1) js: tos().readonly=true js: tos().mode=true
			js: storage.set("pruning",pop())
		[then]
	[then]

	autoexec \ Run localStorage.autoexec when jeforth starting up

