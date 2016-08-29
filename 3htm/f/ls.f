
	\ Maintain source code in HTML5 local storage directly

	s" ls.f"		source-code-header

	\   localStorge 以及 storage.all() 的格式定義為:
    \   
	\   	{ 
	\   		"key1":"string1",
	\   		"key2":"string2", 
	\   		... 
	\   	}
    \   
	\   string 部分是 stringified JSON 格式定義為
    \   
	\   	{
	\   		"doc":string,
	\   		"mode":boolean, /* true is source code mode in opposed to HTML mode */
	\   		"readonly":boolean /* Note! not string e.g. "true" or "false" */
	\   	}
	\
	\   參見 is-editbox-field? command 的定義，如果三個 key 及
	\   其 type 都符合就被當成是一筆 localStorage edit box field. 否則就是
	\   普通 object 的 JSON.stringify(). 遇到困難用比對的方式查出問題。
	

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
		/// only affect the appearance, content as is.

	: eb.appearance.browse ( eb -- ) \ Switch edit box appearance
		js: $(".ebmodeflag",tos())[0].checked=false
		js:	$(".ebtextarea",tos()).hide()
		js:	$(".ebhtmlarea",pop()).show() ;
		/// only affect the appearance, content as is.

	code textarea.value->innertext ( eb -- ) \ Copy all textarea.value to its own innerText
		$("textarea",pop()).each(function(){this.innerText = this.value});
		end-code
		/// Only HTA textarea.innerHTML always catches up with its value.
		/// Other browsers need this word. HTA 多做無妨. 下例遍及整頁:
		/// js: $("textarea").each(function(){this.innerText=this.value});

	: eb.content.browse ( eb -- ) \ Use browse mode content
		dup textarea.value->innertext \ browse mode 之下萬一有 textarea 通通生效到各自的 innerText。
		js: $(".ebtextarea",tos())[0].value=$(".ebhtmlarea",pop())[0].innerHTML
		;
		/// Copy $(".ebhtmlarea").innerHTML to $(".ebtextarea").value

		
	code living-tag?  ( "article" -- boolean ) \ Does the article has script, style, etc special tags etc?
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
		/// Check this before calling eb.content.code that brings textarea.value
		/// into .ebhtmlarea.html
		
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
			living-tag? if
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

    code eb.settings ( eb -- ) \ Effects of readonly and code/HTML mode
		if ($(".ebreadonlyflag",tos())[0].checked){
			$('textarea',tos()).attr("readOnly",true);
			$('.ebhtmlarea',tos())[0].contentEditable=false;
		} else {
			$('textarea',tos()).attr("readOnly",false);
			$('.ebhtmlarea',tos())[0].contentEditable=true;
		}
		// 只管外觀，不切換 content, 因為要不要 copy the content from the 
		// other mode is uncertain. Content 切成 HTML 要經過 user 確認。
		if ($(".ebmodeflag",tos())[0].checked){
			execute("eb.appearance.code");
		} else {
			execute("eb.appearance.browse");
		}
		end-code
		/// Note! call eb.settings 時 eb 都在 code mode, 然後視 checkbox 切換。
	
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

	: editbox-style ( -- ) \ Setup local storage edit box CSS style if it's undefined
		js> typeof(ebstyle)=="undefined" if
		<h> <style id=ebstyle type="text/css">
			.eb .box { width:90%; font-size:1.5em; /* filename */ } 
			.eb .box, .eb .ebhtmlarea { border:1px solid black; }
			.eb .ebtextarea { font-size:1.5em }
			.eb input { font-size:0.7em /* buttons */ }
			.eb p { display:inline; }
			.eb .ebname { font-size: 1em; }
			</style>
		</h> drop then ;
		
	: hidden-div ( -- div ) \ Get the hidden <DIV> element 
		js> typeof(hiddendiv)=="undefined" if \ removeElement 之後就是如此
			<o> <div id="hiddendiv" style="display: none;"></div></o>
			[ last literal ] :: element=tos() ( div )
		else [ last literal ] :> element ( div ) then ;
		/// a hidden <DIV> is used in localstorage.html save-restore
		\ Print something into the hiden DIV:
		\   char #hiddendiv <e> again I am in the hidden div </e> drop
		\ Show or hide the hidden DIV:
		\   js: $("#hiddendiv").show()		
		\   js: $("#hiddendiv").hide()		
		\ js> $("#hiddendiv")[0] hidden-div === \ ==> true
		\ move-all-editbox-to-a-temp-hidden-div
	
	: create-raw-editbox ( -- element ) \ Create an edit box in outputbox
        editbox-style
		<text>
            <div class=eb>
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
		</text> /*remove*/ </o> ( eb ) 	;
		/// Only HTML tags, no script.
	
    : (create-editbox) ( -- edit_box_element ) \ Create an empty HTML5 local storage edit box in outputbox
        create-raw-editbox ( eb ) \ create the eb element
        dup eb.init-buttons \ setup scripts
		\ init check boxes
			js:	$(".ebsaveflag",tos())[0].checked=true;
			js:	$(".ebmodeflag",tos())[0].checked=true;
			js:	$(".ebreadonlyflag",tos())[0].checked=false;
		\ adjust the eb according to checkbox settings
			dup eb.settings ;
	
    : create-editbox ( -- edit_box_element ) \ Create an empty HTML5 local storage edit box above outputbox
		(create-editbox) dup js> outputbox insertBefore
		js: inputbox.blur();window.scrollTo(0,tos().offsetTop-50) ( eb ) ;
		/// WWW browser moves the focus to the editbox also.

	: is-editbox-field? ( obj -- boolean ) \ Is the object an local storage edit box field?
	    >r js> typeof(rtos())=="object" if
			js> typeof(rtos().doc)=="string"
			js> typeof(rtos().mode)=="boolean"
			js> typeof(rtos().readonly)=="boolean"
			and and ( boolean )
		else 
			false ( boolean )
		then r> drop ;

    : (eb.read) ( eb field -- ) \ Load eb with field
		\ Idiot-proof first of all
			js> $(".ebsaveflag",tos(1))[0].checked not if  ( eb field )
				<js> confirm("Overwrite unsaved edit box, are you sure?") </jsV> 
				if else 2drop exit then
			then  
			( eb field )
		\ check the field name 	
			js> Boolean(tos()) if else
				js> $('.ebname',tos(1))[0].value
				<js> alert("Can't find '" + pop() + "', is it new?")</js>
				drop 2drop exit \ nothing to do
			then ( eb field )
		\ Load the edit box with the field
			js: $(".ebsaveflag",tos(1))[0].checked=true \ the field must have been Saved 
			( eb field ) dup is-editbox-field? if ( eb field )
				<js>
					$('.ebtextarea',tos(1))[0].value = tos().doc;
					$(".ebreadonlyflag",tos(1))[0].checked = tos().readonly;
				</js>
				js> $(".ebmodeflag",tos(1))[0].checked=tos().mode;  ( eb field mode )
				if  ( eb field ) 
					drop ( eb ) 
				else \ Take care of Browse mode   ( eb field )
					:> doc ( eb doc ) living-tag? ( eb flag ) if 
						\ copy code mode's content to browse mode
						( eb ) dup eb.content.code ( eb )
					else ( eb )
						\ user refused, so stay in code mode
						js: $(".ebmodeflag",tos())[0].checked=true 
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
		
    : eb.read ( btn -- ) \ Read the localStorate[name] to textarea.
        (eb.parent) ( eb ) \ The input object can be any node of the editbox.
        js> $('.ebname',tos())[0].value trim ( eb name ) 
		js> storage.get(pop()) ( eb field ) (eb.read) ;
		
	: fieldname>eb ( name -- eb ) \ Get eb object if it is opened, null otherwise
		trim <js> 
			var o = null;
			$(".eb").each(function(){
				if ($(".ebname",this)[0].value == tos())o = this;
			});
			pop(); // drop the field name 
			push(o); // eb object
		</js> ;
	
	: jump-to-it ( name -- ) \ Jump to the opened field
		trim fieldname>eb ( eb ) ?dup if (eb)
			js: inputbox.blur()
			js: window.scrollTo(0,pop().offsetTop-50);
		then ;
		
    : {ed} ( {field} name -- ) \ Open the field in an edit box 
		trim create-editbox ( field name eb )
		js: $('.ebname',tos())[0].value=pop(1)  ( field eb ) 
		swap (eb.read) ; 
		/// According to ls.f localStorage field definition, it 
		/// has no name in its structure. The given {field} can
		/// be anything actually but when it's not a edit box field
		/// then it's readonly, for viewing the thing only.
	
    : (ed) ( "field name" -- ) \ Edit local storage field
		trim js> tos()!="" if ( name ) 
			dup fieldname>eb if jump-to-it exit then ( name )
		    js> storage.get(tos()) swap ( field name ) {ed}
		else drop then ; 
		/// If field name is null string then do nothing
		/// If the field has been opened then jump to it.
		
    : ed ( <field name> -- ) \ Edit local storage field
		char \n|\r word (ed) ; 
		/// A new name creates a new field.
		/// If field name is null string then do nothing
		/// If the field has been opened then jump to it.

	: (full-screen) ( "fieldname" -- ) \ The whole tab alone for the field, you lose outputbox.
		trim ( fieldname ) (ed) ( empty )
		cls js> $(".eb").length 1- ( name i ) js> $(".eb")[pop()] ( eb )
		js> $(".console3we")[0] swap appendChild ( empty ) \ 本來在
		js> $(".ebname")[0].value ( name )
		js: document.title=pop()+"-EditBox" ( empty )
		js> header removeElement js> outputbox removeElement js> inputbox removeElement ;
		/// For non-3ce applications, use this command to edit 

	js> vm.appname=="jeforth.3ce" [if]
	
	: full-screen ( <fieldname> -- ) \ Open a new 3ce tab and edit box alone for the field 
		char \r|\n word trim js> tos().length if else 
			drop js> $(".eb").length js> tos()==0 ?abort" Which field?" 
			1- ( i ) js> $(".eb")[pop()] ( eb )
			js> $(".ebname",pop())[0].value ( name )
		then ( name ) 
		dup fieldname>eb ( name eb ) js> $(".ebmode",pop()) ( name button )
		dup eb.save ( name button ) eb.close ( name )
		s" jeforth.3ce.html?<text> " 
		swap + \ [ ] 直接用 url 的方式使得中文 field name 失效! 
		s" </text> (full-screen)" +
		true open-web-page drop ;
		/// 缺省 <fieldname> 用目前最後一個 edit box，若再無就報錯。
		/// Only 3ce can do this. Common local storage among 
		/// different 3ce tabs, control another 3ce tab, etc.

	[then]

	: (run)  ( "local storage field name" -- ) \ Run local storage source code.
		js> storage.get(pop()).doc tib.append ;
		
	: run ( <local storage field name> -- ) \ Run local storage source code.
		char \n|\r word trim (run) ;
		/// 一整行都當 field name 可以有空格。
		
	: type>textarea ( "string" "class" -- ) \ Type the string into a textarea in outputbox
		<text> <textarea class=_class_ style="width:100%;" rows=14></textarea></text>
		:> replace(/_class_/,pop()) </o> :: value=pop() ;
		
	: (export-one-field) ( "field-name" -- ) \ Export the local storage field in JSON format into a textarea in outputbox
		trim ( field-name )
		js> storage.get(tos()) ( field-name field-obj ) \ storage.get() can be object, localStorge can't.
		( name obj ) {} dup :: [pop(2)]=pop(1)
		js> JSON.stringify(pop()) ( "json of the field" )
		s" <text> " swap + s" </text> (import)" + \ 這樣比較乾脆
		char export-one-field \ class attribute of the textarea
		type>textarea cr ;
		/// 直接 copy-paste 該內容在 inputbox 執行即覆寫或新增該 field
		/// 目前 <text> 還不能 nested, 萬一碰上了則須修改一下改用下法:
		///   js> $("textarea")[n].value import \ you find the n in prior
		
	: export-one-field ( <field-name> -- ) \ Export the local storage field in JSON format into a textarea in outputbox
		char \n|\r word (export-one-field) ;
		/// 直接 copy-paste 該內容在 inputbox 執行即覆寫或新增該 field。
		
	: export ( -- ) \ Export entire local storage in JSON format into a textarea in outputbox.
		js> JSON.stringify(storage.all()) char export type>textarea ;
		/// The format is compatible with (3hta or 3nw )\localstorage.json 
		/// 此為 jeforth.3htm, jeforth.3ca 等不能存檔的環境而設。
		/// 手動 copy-paste 到 text editor 然後存檔成 filename.json.
		/// 參見 help import 了解更多。

	code (import) ( "string" -- ) \ Import entire localStorage in JSON format
		var ss = pop();
		// if is from 3hta then it's utf-8 with BOM (EF BB BF) that bothers NW.js JSON.parse()
		// ss.charCodeAt(0)==65279 that's utf-8 BOM 
		if (ss.charCodeAt(0)==65279) ss = ss.slice(1); // resolve the utf-8 BOM issue for jeforth.3nw
		var ls = JSON.parse(ss);
		for (var i in ls) storage.set(i,ls[i]);
		end-code
		/// 手動 <text> ...</text> (import) 即可 import 來自 export 的整個
		/// local storage 或者來自 export-one-field 的一個 field. 經改良 <text> 
		/// 可 nested 了, 可安心使用。或者如下用法也行：
		///   char 3hta/localstorage.json readTextFile (import)
		/// 但這樣會疊加且覆蓋原有的 localStorage 小心使用。最好用 dump 命令
		/// 只 save 部分 fields 更理想。
		/// save restore import export .. etc 等相關命令能在所有 jeforth.3we 
		/// applications 上使用, 但只有 3ce, 3htm 有絕對必要，因為 3nw, 3hta
		/// 本來就會自動 save-restore localStorage。
		
	: import ( [<pathname.json>] -- ) \ Import entire pathname.json or default if absent
		char \r|\n word trim ( pathname ) 
		js> tos()=="" if \ use default 
			drop js> vm.appname :> match(/(.+)\.(.+)/) :> [2] ( 3ca|3htm|3nw|3hta )
			char private/ swap + char .json +
		then 
		js> tos()=="" if ." Error! file not found: " . cr exit then
		readTextFile (import) ;
		/// 疊加且覆蓋現有的 localStorage from the specified JSON file,
		/// default from private/3ce.json or private/3htm.json。
		/// 若想整個蓋掉而不只是疊加上去，則需先清除整個 local storage. 
		/// 要非常小心，方法是:
		///   js: localStorage.clear() \ for none 3HTA
		///   js: window.storage.local_storage={} \ for 3HTA
		/// save restore import export .. etc 等相關命令能在所有 jeforth.3we 
		/// applications 上使用, 但只有 3ce, 3htm 有絕對必要，因為 3nw, 3hta
		/// 會自動 save-restore localStorage。

	: move-all-editbox-to-outputbox ( -- ) \ Move all local storage edit boxes into outputbox
		js> $(".eb") dup :> length ?dup if dup for dup r@ - ( array lengh i )
			js> tos(2)[pop()] ( array length eb )
			js> outputbox swap appendChild ( array length )
		next 2drop then 
		\ Multiple appendChild may not completed yet now!!
			1 nap \ Take a break for DOM to complete its jobs
		;
		/// 方便一次全都 cls 掉。
		
	: move-all-editbox-to-a-temp-hidden-div ( -- ) \ For localstorage.html restoring
		\ <o> <div id="tempHiddenEditbox" style="display:none;"></div></o> drop
		js> $(".eb") dup :> length ?dup if dup for dup r@ - ( array lengh i )
			js> tos(2)[pop()] ( array length eb )
			hidden-div swap appendChild ( array length )
		next 2drop then 
		\ Multiple appendChild may not completed yet now!!
			1 nap \ Take a break for DOM to complete its jobs
		;
		/// 用於避免擾畫面、方便一次全都 remove 掉。

	: standardize-editbox ( -- ) \ Standardize local storage edit boxes
		\ 處理 textarea innerHTML 與 value 不同步的問題
			js: $("textarea").each(function(){this.innerText=this.value})
		\ 給重要欄位的值都留下線索 
			<js> 
				$(".eb").each(function(){
					$(".ebmodeflag",this).attr("flag",$(".ebmodeflag",    this)[0].checked);
					$(".ebreadonlyflag",this).attr("flag",$(".ebreadonlyflag",this)[0].checked);
					$(".ebname",this).attr("placeholder",$(".ebname",this)[0].value);
				})
			</js> 
		;
		/// 處理 textarea innerHTML 與 value 不同步的問題
		/// 給重要欄位的值都留下線索 

	: close-all-edit-box ( -- ) \ Ignore and close all opened edit box 
		js> $(".eb").length ?dup if for 
			js> $(".eb")[0] removeElement
		next then ;

	: (dump) ( "pathname" -- ) \ Dump local storage edit box fields 
		trim ( pathname ) js> tos()!="" if
			readTextFile ( "json" )
			js> tos().charCodeAt(0)==65279 if js> pop().slice(1) then ( "json" )
			js> JSON.parse(pop()) ( hash )
		else
			drop js> storage.all() ( hash )
		then
		dup obj>keys ( hash array ) \ array of field names
        :> sort(function(b,a){return(a.localeCompare(b))}) \ sorted ( hash array ) 
		begin js> tos().length while ( hash array )
			js> tos().pop() ( hash array fieldname )
			js> storage.get(tos(),tos(2)) ( hash array fieldname field ) 
			is-editbox-field? ( hash array fieldname boolean ) if 
				( hash array fieldname ) 
				js> storage.get(tos(),tos(2)) swap 
				( hash array field fieldname ) 
				{ed} ( hash array )
			else drop then ( hash array )
		repeat 2drop move-all-editbox-to-outputbox standardize-editbox ;
		/// Dump localStorage if the given pathname is a "".
		/// 配合 Chrome 的 Ctrl-S 把 local storage 整個 save 成 .html 檔, 將來
		/// 可以 restore 回來。非 edit box editable 的 objects 不含。
        /// 下法可 view 任何 localStorage field :
        ///   js> storage.get("field-name") (see)

	: dump ( <pathname> -- ) \ Dump local storage edit box fields 
		char \r|\n word (dump) ;
		/// Dump localStorage if the given pathname is missing.
		/// 配合 Chrome 的 Ctrl-S 把 local storage 整個 save 成 .html 檔, 將來
		/// 可以 restore 回來。非 edit box editable 的 objects 不含。
        /// 下法可 view 任何 localStorage field :
        ///   js> storage.get("field-name") (see)
		
		
	: read-localstorage.html ( "pathname" -- jQobj ) \ Read localstorage.html
		\ clean older garbage
			hidden-div removeElement 
		\ read the localstorage.html and clean it up
			readTextFile ( "html" )
			remove-script-from-HTML remove-style-from-HTML
			:> replace(/id="inputbox"/g,'id="input_box"')
			:> replace(/id="outputbox"/g,'id="output_box"')
			:> replace(/id="endofinputbox"/g,'id="endofinput_box"')
			:> replace(/class="console3we"/g,'class="ls_hash"')
		\ bring "html" into hidden-div
			char # hidden-div :> getAttribute("id") + swap ( #hiddendiv html )
			</e> drop \ The entire localstorage.html in hidden-div
		\ translate hidden-div into jquery object array
			js> $(".box",$(".ls_hash")) \ jQuery collection of fields
		;
		/// The entire localstorage.html will be in hidden-div in outputbox
		/// The result is an jQueryObject which is a collection of 
		/// editbox field DOM elements that are class="box". hidden-div consumes
		/// memory that can be released by cls or removeElement.

	: element>field ( element -- jsObj ) \ Convert a local storage DOM element to js object
		{} ( element obj )
		js: tos().name=$(".ebname",tos(1)).attr("placeholder")
		js: tos().readonly=$(".ebreadonlyflag",tos(1)).attr("flag")==="true"?true:false
		js> tos().mode=$(".ebmodeflag",tos(1)).attr("flag")==="true"?true:false
		char true == if js: tos().doc=$(".ebtextarea",tos(1))[0].value
		else js: tos().doc=$(".ebhtmlarea",tos(1))[0].innerHTML then
		nip ;

	\ Test, both words work fine.
	\	char private/jeforth.3ce.html read-localstorage.html ( jQueryObj )
	\	dup :> [0] element>field ( obj ) (see) ( objQuery ) cr
	\	dup :> [1] element>field ( obj ) (see) ( objQuery ) cr
	\	dropall

	: jqo>localstorage ( jQobj -- ) \ Restore jquery object to local storage
		\ get count of fields in the given jqo
			( jqo ) js> tos().length ( jqo length )
		\ loop all fields
		?dup if dup for dup r@ -
			\ Bring each field from jqo into local storage
				( jqo COUNT i ) js> tos(2)[pop()] ( jqo COUNT jqo[i] )
				element>field  ( jqo COUNT fieldObj ) 
				dup :> name ( jqo COUNT fieldObj name )
				js: storage.set(pop(),pop())
		( jqo COUNT ) next drop then drop ;
		/// jqo is from localstorage.html

	: restore-localstorage.html ( "pathname" -- ) \ Restore localstorage.html to local storage
		read-localstorage.html ( jQueryObj )
		jqo>localstorage hidden-div removeElement ;
		/// char private/jeforth.3ce.html restore-localstorage.html

	: autoexec ( -- ) \ Run localStorage.autoexec
		js> storage.get("autoexec").doc ( "autoexec" )
		js> tos() if ( "autoexec" ) tib.insert else ( "autoexec" ) drop then ;

	: list ( -- ) \ List all localStorage fields, click to open
		\ Print How to use,
			<text> <unindent><br>
				HTML5 Local storage field '<code>autoexec</code>' is run when start-up.
				'<code>run <field name></code>' runs the local storage field, you make sure it's executable.
				'<code>ed <field-name or blank></code>' opens local storage editor, 
				hotkey <code>{F9},{F10}</code> resize the textarea, <code>{Ctrl-S}</code> saves
				it to local storage.
				'<code>export</code>' exports the entire local storage in JSON format.
				'<code>help export</code>' for details.
				<br><br>
			</unindent></text> <code>escape </o> drop
		\ main loop 印出所有的 fields 
			js> storage.all() obj>keys ( array ) \ array of field names
            :> sort(function(b,a){return(a.localeCompare(b))}) \ sorted 
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
					push(this.getAttribute("fieldname")); // ( name ) 
					execute("(ed)");
				})
				$("input.lsfieldexport").click(function(){
					push(this.getAttribute("fieldname")); // ( field-name ) 
					execute("(export-one-field)");
				})
			</js> 
		;

	: save ( -- ) \ Save all local storage edit box to localstorage.html
		"" (dump) <js>
		alert("Press ctrl-s to save all edit boxes to private/3ce.html or private/3htm.html. I guess your are using Google Chrome Browser.")
		</js> ;
        /// 3ce/localstorage.html, 3htm/localstorage.html for public logs.
        /// or private/3ce.html, private/3htm.html for private info.
		/// save restore import export .. etc 等相關命令能在所有 jeforth.3we 
		/// applications 上使用, 但只有 3ce, 3htm 有絕對必要，因為 3nw, 3hta
		/// 會自動 save-restore localStorage。

    : restore ( -- ) \ Restore all local storage edit box from localstorage.html
        js> vm.appname=="jeforth.3ce" if 
            char private/3ce.html restore-localstorage.html 
        then
        js> vm.appname=="jeforth.3htm" if 
            char private/3htm.html restore-localstorage.html 
        then
        list ;
		/// save restore import export .. etc 等相關命令能在所有 jeforth.3we 
		/// applications 上使用, 但只有 3ce, 3htm 有絕對必要，因為 3nw, 3hta 
		/// 會自動 save-restore localStorage。
        
	: snapshot ( -- ) \ Save outputbox to a ed
		create-editbox ( eb ) \ default is editable, saved, code mode
		s" Snapshot " now t.dateTime + ( eb "now" ) 
		js: $(".ebname",tos(1))[0].value=pop() ( eb )
		js> outputbox textarea.value->innertext ( eb ) \ let textarea.innerText = its.value
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

