
	: (ed2) ( -- edit_box_element ) \ Create an HTML5 local storage edit box in outputbox
		<text> 
			<style type="text/css">
				.eb div { 
					width:90%;
					border:1px solid black;
				}
				.eb p {
					display:inline;
				}
			</style>
            <div class=eb>
			<p>Local Storage Field </p>
			<input class=ebname type=text value=""></input>
			<p>
			<input type=button value='Saved' class=ebsave>
			<input type=button value='Read' class=ebread>
			<input type=button value='Edit' class=ebedit>
			<input type=button value='Delete' class=ebdelete>
			<input type=button value='Read only' class=ebreadonly>
			<input type=button value='Close' class=ebclose>
			<input type=button value='Run' class=ebrun>
			</p>
			<textarea class=ebtextarea style="margin-top:1em;" rows=20 wrap="off"></textarea>
		</div></text> 
		:> replace(/[/]\*(.|\r|\n)*?\*[/]/mg,"") \ clean /* comments */ 
		</o> ( eb ) js: window.scrollTo(0,tos().offsetTop-50) ( eb )
		init-buttons ;
	
	: ed2 (ed2) drop ; // ( -- ) Create an HTML5 local storage edit box in outputbox
stop	
<o> <input type=file></input></o> tib. \ Choose a file from local computer
<o> <input type=checkbox></input></o> tib. \ A toggling check box
<o> <input type=hidden></input></o> tib. \ 看不出甚麼東西
<o> <input type=image></input></o> tib. \ Image, what image?
<o> <input type=password></input></o> tib. \ It's a text input box
<o> <input type=radio></input></o> tib. \ Radio button expected
<o> <input type=reset></input></o> tib. \ Reset button
<o> <input type=submit></input></o> tib. \ Submit button
<o> <input type=text></input></o> tib. \ 類似 textarea or password 的 text box

	\ Maintain source code in HTML5 local storage directly

	s" ls.f"		source-code-header
	
	: (eb.parent) ( node -- eb ) \ Get the parent edit box object of the given node/element.
		js> $(pop()).parents('.eb')[0] ( eb ) ;

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
		js: storage.set(pop(1),pop()) ( eb )
		js: $('.ebsave',pop())[0].value="Saved" ;
		
	: (eb.read) ( eb field_name -- ) \  Read the localStorate[name] to textarea of the given edit box.
		js> storage.get(tos())  ( eb name text|undefined ) 
		js> tos()==undefined if  ( eb name text|undefined ) 
			<js> alert("Error! can't find '" + pop(1) + "' in local storage.")</js>
			2drop exit
		then  nip ( eb text )
		js> $('.ebsave',tos(1))[0].value=="Save" if  ( eb text )
			<js> confirm("Unsaved local storage edit box will be overwritten, are you sure?") </jsV> 
			if else 2drop exit then
		then  ( eb text )
		js: $('textarea',tos(1))[0].value=pop()
		js: $('.ebsave',pop())[0].value="Saved" ;
	
	: eb.read ( btn -- ) \ Read the localStorate[name] to textarea.
		(eb.parent) ( eb ) \ The input object can be any node of the editbox.
		js> $('.ebname',tos())[0].innerText trim ( eb name ) (eb.read) ;
		
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
		js: storage.del(pop()) ( eb ) removeElement ;

	: eb.run ( btn -- ) \ Run FORTH source code of the local storage edit box.
		(eb.parent) ( eb ) \ The input object can be any node of the editbox.
		js: dictate($('textarea',pop())[0].value) ;
		
	: eb.onchange ( btn -- ) \ Event handler on local storage edit box has changed
		(eb.parent) ( eb ) \ The input object can be any node of the editbox.
		<js> $(".ebsave",pop())[0].value="Don't forget to SAVE !"</js> ;

	: init-buttons ( eb -- eb ) \ Initialize buttons of the local storage edit box.
		<js> $(".ebsave",    tos())[0].onclick =function(e){push(this);execute("eb.save");    return(false)}</js>
		<js> $(".ebread",    tos())[0].onclick =function(e){push(this);execute("eb.read");    return(false)}</js>
		<js> $(".ebedit",    tos())[0].onclick =function(e){push(this);execute("eb.edit");    return(false)}</js>
		<js> $(".ebreadonly",tos())[0].onclick =function(e){push(this);execute("eb.readonly");return(false)}</js>
		<js> $(".ebclose",   tos())[0].onclick =function(e){push(this);execute("eb.close");   return(false)}</js>
		<js> $(".ebrun",     tos())[0].onclick =function(e){push(this);execute("eb.run");     return(false)}</js> 
		<js> $(".ebdelete",  tos())[0].onclick =function(e){push(this);execute("eb.delete");  return(false)}</js> 
		<js> $(".ebtextarea",tos())[0].onchange=function(e){push(this);execute("eb.onchange");return(false)}</js> 
		<js> 
			$(".ebtextarea",tos())[0].onkeydown = function(e) {
				e = (e) ? e : event; 
				var keycode = (e.keyCode) ? e.keyCode : (e.which) ? e.which : false;
				switch(keycode) {
					case  83: /* s */
						if (e&&e.ctrlKey) {
							push(this); // ( textarea ) 
							execute("eb.save");
							var temp=this.value;this.value="";this.value=temp; // Saved already so clear the onchange status
							e.stopPropagation ? e.stopPropagation() : (e.cancelBubble=true); // stop bubbling
							return(false);
						}
					default: return (true); // pass down to following handlers
				}
			}
		</js> ;

js> $("input",$(".eb")[1])[0].value . \ the input type=text field name 
aaa bbb ccc  OK 
