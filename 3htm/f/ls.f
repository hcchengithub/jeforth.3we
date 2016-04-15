
	\ Maintain source code in HTML5 local storage directly

	s" ls.f"		source-code-header

	: (eb.parent) ( node -- eb ) \ Get the parent edit box object of the given node/element.
		js> $(pop()).parents('.eb')[0] ( eb ) ;
		/// local storage edit box 

	: eb.edit ( btn -- ) \ Make the textarea and the name editable.
		(eb.parent) ( eb ) \ The input object can be any node of the editbox.
		js: $('.ebname',tos())[0].contentEditable=true
		js: $('textarea',pop())[0].readOnly=false ;
		
	: eb.readonly ( btn -- ) \  Make the textarea and the name read-only.
		(eb.parent) ( eb ) \ The input object can be any node of the editbox.
		js: $('.ebname',tos())[0].contentEditable=false
		js: $('textarea',pop())[0].readOnly=true ;

	: eb.save ( btn -- ) \ Save the textarea to localStorate[name].
		(eb.parent) ( eb ) \ The input object can be any node of the editbox.
		js> $('.ebname',tos())[0].innerText trim ( eb name )
		js> $('textarea',tos(1))[0].value ( eb name text )
		js: localStorage[pop(1)]=pop() ( eb )
		js: $('.ebsave',pop())[0].value="Saved" ;
		
	: eb.read ( btn -- ) \ Read the localStorate[name] to textarea.
		(eb.parent) ( eb ) \ The input object can be any node of the editbox.
		js> $('.ebname',tos())[0].innerText trim ( eb name )
		js> localStorage[pop()]  ( eb text|undefined ) 
		js> tos()==undefined if  ( eb text|undefined ) 
			<js> alert("Error! can't find that local storage field.")</js>
			2drop exit
		then  ( eb text )
		js> $('.ebsave',tos(1))[0].value=="Save" if  ( eb text )
			<js> confirm("Unsaved local storage edit box will be overwritten, are you sure?") </jsV> 
			if else 2drop exit then
		then  ( eb text )
		js: $('textarea',tos(1))[0].value=pop()
		js: $('.ebsave',pop())[0].value="Saved" ;
		
	: eb.close ( btn -- ) \ Close the local storage edit box to stop editing.
		(eb.parent) ( eb ) \ The input object can be any node of the editbox.
		js> $('.ebsave',tos())[0].value=="Save" if 
			<js> confirm("Are you sure you want to clsoe the unsaved local storage edit box?") </jsV> 
			if else exit then
		then ( eb ) removeElement ;

	: eb.delete ( btn -- ) \ Delete the local storage edit box and the local storage field.
		(eb.parent) ( eb ) \ The input object can be any node of the editbox.
		<js> $('textarea',tos())[0].value.indexOf("delete me no regret")!=0</jsV>
		if <js> alert('Place "delete me no regret" at the very beginning of the textarea to demonstrate yor guts.') </js> drop exit then
		js> $('.ebname',tos())[0].innerText trim ( eb name ) 
		js: delete(localStorage[pop()]) ( eb ) removeElement ;

	: eb.run ( btn -- ) \ Run FORTH source code of the local storage edit box.
		(eb.parent) ( eb ) \ The input object can be any node of the editbox.
		js: dictate($('textarea',pop())[0].value) ;
		
	: eb.onchange ( btn -- ) \ Event handler on local storage edit box has changed
		(eb.parent) ( eb ) \ The input object can be any node of the editbox.
		js: $(".ebsave",pop())[0].value="Save" ;

	: init-buttons ( eb -- ) \ Initialize buttons of the local storage edit box.
		<js> $(".ebsave",    tos())[0].onclick=function(e){push(this);vm.execute("eb.save");    return(false)}</js>
		<js> $(".ebread",    tos())[0].onclick=function(e){push(this);vm.execute("eb.read");    return(false)}</js>
		<js> $(".ebedit",    tos())[0].onclick=function(e){push(this);vm.execute("eb.edit");    return(false)}</js>
		<js> $(".ebreadonly",tos())[0].onclick=function(e){push(this);vm.execute("eb.readonly");return(false)}</js>
		<js> $(".ebclose",   tos())[0].onclick=function(e){push(this);vm.execute("eb.close");   return(false)}</js>
		<js> $(".ebrun",     tos())[0].onclick=function(e){push(this);vm.execute("eb.run");     return(false)}</js> 
		<js> $(".ebdelete",  tos())[0].onclick=function(e){push(this);vm.execute("eb.delete");  return(false)}</js> 
		<js> $(".ebtextarea",tos())[0].onchange=function(e){push(this);vm.execute("eb.onchange");  return(false)}</js> 
		drop ;
	
	: eb ( -- element ) \ Create an HTML5 local storage edit box in outputbox
		<text> <div class=eb style="width:90%;border:1px solid black;">
			<p class=ebname style="display:inline;padding-left:2px;font-size:1.25em;border:0.75px solid gray;" contentEditable> Edit the title of this textarea </p>
			<p style="display:inline;margin-left:2em">
			<input type=button value='Saved' class=ebsave>
			<input type=button value='Read' class=ebread>
			<input type=button value='Edit' class=ebedit>
			<input type=button value='Delete' class=ebdelete>
			<input type=button value='Read only' class=ebreadonly>
			<input type=button value='Close' class=ebclose>
			<input type=button value='Run' class=ebrun></p>
			<textarea class=ebtextarea style="margin-top:1em;"></textarea>
		</div></text> 
		:> replace(/[/]\*(.|\r|\n)*?\*[/]/mg,"") \ clean /* comments */ 
		</o> ( eb ) init-buttons ; interpret-only
	
	: init ( -- ) \ Initialize local source 1) create textarea, 2) init textarea with localStorage.sourcecode.
		<o> <textarea id=sourcecode></textarea></o>
		js> localStorage.sourcecode if
			js: pop().value=localStorage.sourcecode
		else
			js: localStorage.sourcecode=""
			js> localStorage.sourcecode==="" if else
				abort" Error! localStorage is not supported." cr
			then
		then ;

	: save ( -- ) \ Save textarea source code to localStorage
		js: localStorage.sourcecode=sourcecode.value 
		\ Don't use cr in event handler!! 
		\ 又被 event handler 再電一次!! cr 有用到 nap 所以不能用。
		<js> type("\nSaved source code textarea to local storage.\n");</js> 
		;

	: run ( -- ) \ Run text area source code (that may not saved to local storage yet)
		js> sourcecode.value tib.append ;

	: type ( -- ) \ Type local storage source code
		js> localStorage.sourcecode . ;

	: cls  ( -- ) \ Clear all #text in the outputbox elements are remained.
		ce@ ( save ) js> outputbox ce! er ce! ( restore ) ;
		/// Auto save-restore ce@ so it won't be changed.
		
	: {s} ( -- bubbling ) \ Ctrl-Shift-s like 'save' but is a Hotkey handler.
		js> event&&event.ctrlKey if 
			save false ( terminate bubbling )
		else 
			true ( pass down the 's' key ) 
		then ;
		/// Ctrl-s 一定會被 Chrome 收到 for "save the web page" 加上
		/// Shift key 即可避免之。
	
	: list ( -- ) \ List all localStorage field keys
		js> localStorage obj>keys . ;
		/// To delete a field,
		/// js: delete(localStorage.<key>)
		
