
\ [ ] style does not work correctly as anticipated

    \ Maintain source code in HTML5 local storage directly

    \ s" ls.f"        source-code-header
    
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
		
	: eb.mode ( btn -- ) \ Toggle edit box mode between source and HTML
        (eb.parent) ( eb ) \ The input object can be any node of the editbox.
		js> $(".ebmodeflag",tos())[0].checked if
			js: $(".ebmodeflag",tos())[0].checked=false
			js:	$(".ebtextarea",tos()).hide()
			js: $(".ebhtmlarea",tos()).html($(".ebtextarea",tos())[0].value)
			js:	$(".ebhtmlarea",tos()).show()
		else
			js: $(".ebmodeflag",tos())[0].checked=true
			js:	$(".ebhtmlarea",tos()).hide()
			js: $(".ebtextarea",tos())[0].value=$(".ebhtmlarea",tos()).html()
			js:	$(".ebtextarea",tos()).show()
		then ;

    : eb.save ( btn -- ) \ Save the textarea to localStorate[name].
        (eb.parent) ( eb ) \ The input object can be any node of the editbox.
        js> $('.ebname',tos())[0].value trim ( eb name )
        js> $('.ebtextarea',tos(1))[0].value ( eb name text )
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
        js: $('.ebtextarea',tos(1))[0].value=pop()
        js: $('.ebsave',pop())[0].value="Saved" ;
    
    : eb.read ( btn -- ) \ Read the localStorate[name] to textarea.
        (eb.parent) ( eb ) \ The input object can be any node of the editbox.
        js> $('.ebname',tos())[0].value trim ( eb name ) (eb.read) ;
        
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
        js> $('.ebname',tos())[0].value trim ( eb name ) 
        js: storage.del(pop()) ( eb ) removeElement ;

    : eb.run ( btn -- ) \ Run FORTH source code of the local storage edit box.
        (eb.parent) ( eb ) \ The input object can be any node of the editbox.
        js: dictate($('textarea',pop())[0].value) ;
        
    : eb.onchange ( btn -- ) \ Event handler on local storage edit box has changed
        (eb.parent) ( eb ) \ The input object can be any node of the editbox.
        <js> $(".ebsave",pop())[0].value="Don't forget to SAVE !"</js> ;

    : init-buttons ( eb -- eb ) \ Initialize buttons of the local storage edit box.
        <js> $(".ebreadonly",tos())[0].onclick =function(e){push(this);execute("eb.readonly");return(false)}</js>
        <js> $(".ebmode",    tos())[0].onclick =function(e){push(this);execute("eb.mode");    return(false)}</js>
        <js> $(".ebsave",    tos())[0].onclick =function(e){push(this);execute("eb.save");    return(false)}</js>
        <js> $(".ebread",    tos())[0].onclick =function(e){push(this);execute("eb.read");    return(false)}</js>
        <js> $(".ebclose",   tos())[0].onclick =function(e){push(this);execute("eb.close");   return(false)}</js>
        <js> $(".ebrun",     tos())[0].onclick =function(e){push(this);execute("eb.run");     return(false)}</js> 
        <js> $(".ebdelete",  tos())[0].onclick =function(e){push(this);execute("eb.delete");  return(false)}</js> 
        <js> $(".ebtextarea",tos())[0].onchange=function(e){push(this);execute("eb.onchange");return(false)}</js> 
        <js> 
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

    : (ed) ( -- edit_box_element ) \ Create an HTML5 local storage edit box in outputbox
        <text>
            <div class=eb>
            <style type="text/css">
                .eb .box { width:90%; }
                .eb .box, .eb .ebhtmlarea { border:1px solid black; }
                .eb p { display:inline; }
				.eb .ebbody { margin: 0 0 0 0;}
            </style>
            <div class=box>
            <p>Local Storage Field </p>
            <input class=ebname type=text value=""></input>
            <p>
            <input type=checkbox class=ebreadonlyflag disabled="disabled"><input type=button value='Readonly' class=ebreadonly>
            <input type=checkbox class=ebmodeflag disabled="disabled"><input type=button value='</>' class=ebmode>
            <input type=button value='Saved' class=ebsave>
            <input type=button value='Read' class=ebread>
            <input type=button value='Delete' class=ebdelete>
            <input type=button value='Close' class=ebclose>
            <input type=button value='Run' class=ebrun>
            </p>
			<div class=ebbody style="margin:0 0 0 0;">
            <textarea class=ebtextarea rows=20 wrap="off"></textarea>
			<div class=ebhtmlarea>123</div>
			</div>
			</div>
			</div>
		</text> /*remove*/
        </o> ( eb ) js: window.scrollTo(0,tos().offsetTop-50) ( eb )
        init-buttons ;
    
    : ed (ed) drop ; // ( -- ) Create an HTML5 local storage edit box in outputbox

stop

js> $("input",$(".eb")[1])[0].value . \ the input type=text field name 
aaa bbb ccc  OK 

\ [x] ed move to above outputbox
\ js> $(".eb").length \ ==> 1 OK 
js> $(".eb")[0] js> outputbox insertBefore

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

stop
> js> $(".ebreadonly",$(".eb"))[0].outerHTML .
<input class="ebreadonly" type="checkbox"> OK 
> js> $(".ebreadonly",$(".eb"))[0].checked .
true OK 
> js> $(".ebreadonly",$(".eb"))[0].checked .
false OK 

stop
> js> $("textarea",$(".eb")).attr("readOnly",true)
 OK 
> js> $("textarea",$(".eb")).attr("readOnly",false)
 OK 
 
stop
h2  { visibility:hidden;  } <--------- 還是會占空間, 只是所站的空間呈現一片空白
> js> $("textarea",$(".eb")).hide()
 OK 
> js> $("textarea",$(".eb")).show()
 OK 
> js> $(".ebhtmlarea",$(".eb")).hide()
 OK 
> js> $(".ebhtmlarea",$(".eb")).show()
 OK   

stop
在 .ebtextareea $().hide() 時把它改掉，
> js> $(".ebtextarea").length \ ==> 1 OK 
> js> $(".ebtextarea")[0].value ==> <h3> header 333333<h3> OK 
> <js> $(".ebtextarea")[0].value="1111111111"</js>
> js> $(".ebtextarea")[0].value \ ==> 1111111111 OK 
切回 
> js> $(".ebtextarea")[0].value \ ==>  <h3> header 333333<h3></h3> OK 


 
