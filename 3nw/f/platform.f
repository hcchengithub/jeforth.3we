
\ platform.f for jeforth.3nw 
\ KeyCode test page http://www.asquare.net/javascript/tests/KeyCode.html

s" platform.f"		source-code-header

also forth definitions

: {F5}			( -- boolean ) \ Hotkey handler, Confirm reload the application.
				<js> confirm("Really want to restart jeforth.3nw?") </jsV> 
				if nw :: reloadIgnoringCache() then false ;
				/// Return a false to stop the hotkey event handler chain.
				/// Must intercept onkeydown event to avoid original function.

: {F2}			( -- false ) \ Hotkey handler, Toggle input box EditMode
				." Input box EditMode = " js> kvm.EditMode=Boolean(kvm.EditMode^true) dup . cr
				if   <text> textarea:focus { border: 0px solid; background:#FFE0E0; }</text> \ pink as a warning of edit mode
				else <text> textarea:focus { border: 0px solid; background:#E0E0E0; }</text> \ grey
				then js> styleTextareaFocus.innerHTML=pop()                
				js: kvm.scrollToElement($('#endofinputbox'))
				false ;
				/// return a 'false' to stop the hotkey event handler chain.

code {F9}		( -- false ) \ Hotkey handler, Smaller the input box.
				var r = inputbox.rows;
				if(r<=4) r-=1; else if(r>8) r-=4; else r-=2;
				inputbox.rows = Math.max(r,1);
				if (!r) $("#inputbox").hide();
				kvm.scrollToElement($('#endofinputbox')); $('#inputbox').focus();
				push(false);
				end-code
				/// return a false to stop the hotkey event handler chain.

code {F10}		( -- false ) \ Hotkey handler, Bigger the input box
				$("#inputbox").show()
				var r = 1 * inputbox.rows;
				if(r<4) r+=1; else if(r>8) r+=4; else r+=2;
				inputbox.rows = Math.max(r,1);
				kvm.scrollToElement($('#endofinputbox')); $('#inputbox').focus();
				push(false);
				end-code
				/// return a false to stop the hotkey event handler chain.
				/// Must intercept onkeydown event to avoid original function.

code {F4}		( -- false ) \ Hotkey handler, copy marked string into inputbox
				var selection = getSelection();
				var start, end, ss;
				if (!selection.isCollapsed) {
					if (selection.anchorNode==selection.focusNode) {
						start = Math.min(selection.anchorOffset,selection.focusOffset);
						end   = Math.max(selection.anchorOffset,selection.focusOffset);
						ss = selection.anchorNode.data.slice(start,end);
					} else {
						if (selection.anchorNode.data){  // 我根據實例亂湊的，搞不懂對的用法。
							start = selection.anchorOffset;
							end   = selection.anchorNode.data.length;
							ss = selection.anchorNode.data.slice(start,end);
						} else {
							// 啟動時 mark "VBScript V5.8 Build:16384" 其中那個 16384 就會出這種情形！
							ss = selection.focusNode.data.slice(0,selection.anchorOffset);
						}
					}
					document.getElementById("inputbox").value += " " + ss;
				}
				kvm.scrollToElement($('#endofinputbox'));
				$('#inputbox').focus();
				push(false);
				end-code
				/// return a false to stop the hotkey event handler chain.
				/// The selection must be made from start to end.

: {esc}			( -- false ) \ Inputbox keydown handler, clean inputbox
				js: document.getElementById("inputbox").value=""
				false ;

: {up}			( -- boolean ) \ Inputbox keydown handler, get previous command history.
				<js> kvm.EditMode && !event.ctrlKey </jsV> if true else
				js: document.getElementById("inputbox").value=kvm.cmdhistory.up();
				false then ;

: {down}		( -- boolean ) \ Inputbox keydown handler, get next command history.
				<js> kvm.EditMode && !event.ctrlKey </jsV> if true else
				js: document.getElementById("inputbox").value=kvm.cmdhistory.down();
				false then ;

: {backSpace}	( -- boolean ) \ Inputbox keydown handler, erase output box when input box is empty
				js> inputbox.value if 
					true \ inputbox is not empty do the norm.
				else \ inputbox is empty, clear outputbox bottom up
					js> event==null||event.altKey \ So as to allow calling {backSpace} programmatically	
					if \ erase top down
						js> event==null||event.shiftKey \ So as to allow calling {backSpace} programmatically
						if 30 else 1 then for
							js> event&&event.ctrlKey if
								js> outputbox.firstChild ?dup if removeElement then
							else
								js> outputbox.firstChild ?dup if
									js> tos().nodeName  char BR    =
									js> tos(1).nodeName char #text =
									or if removeElement else drop then
								then
							then
						next
					else \ erase bottom up 
						js> outputbox.lastChild ?dup if
							js> tos().nodeName char BR = if removeElement else drop then
						then				
						js> event==null||event.shiftKey \ So as to allow calling {backSpace} programmatically
						if 30 else 1 then for
							js> event&&event.ctrlKey if
								js> outputbox.lastChild ?dup if removeElement then
							else
								js> outputbox.lastChild ?dup if
									js> tos().nodeName  char BR    =
									js> tos(1).nodeName char #text =
									or if removeElement else drop then
								then
							then
						next
					then	
					false
				then ;
				/// {backSpace} erase only the last <BR> and text node. To erase other node
				/// types, use Ctrl-{backSpace}. To erase faster, use Shift-{backSpace} or
				/// Shift-Ctrl-{backSpace}. To erase top down, use Alt key.

: {-}			( -- boolean ) \ Inputbox keydown handler, zoom out.
				js> !event.ctrlKey if true else nw :: zoomLevel-=0.5 false then ;
: {+}			( -- boolean ) \ Inputbox keydown handler, zoom in.
				js> !event.ctrlKey if true else nw :: zoomLevel+=0.5 false then ;

: help			( [<patthern>] -- )  \ Print help message of screened words
                char \n|\r word js> tos().length if (help) else
					<text>
						F2    : Toggle input box EditMode
						F4    : Copy marked string to input box
						F5    : Restart jeforth.3nw
						F9    : Smaller input box
						F10   : Bigger input box
						Esc   : Clear the input box
						Enter : Focus on the input box
						Ctrl+ : Bigger font size
						Ctrl- : Smaller font size
						Backspace : Refer to "help -N {backSpace}" for details

						help <pattern> : Refer to "help -N (help)" for details
						see <word>     : See details of the word
						jsc            : JavaScript console
					</text> <js> pop().replace(/^[ \t]*/gm,'\t')</jsV> . cr
				then ;
				/// Modified by platform.f for hotkey helps. The previous version is voc.f.
				/// Pattern matches name, help and comments.

<js>
	kvm.cmdhistory = {
		max:   20, // maximum length of the command history
		index: -1,
		array: [],
		push:
			function (cmd){
				cmd = cmd.replace(/^\s*/gm,''); // remove leading white spaces
				cmd = cmd.replace(/\s*$/gm,'');  // remove tailing white spaces
				if(cmd.search(/\S/)==-1) return; // skip blank lines
				if(cmd!=this.array[this.array.length-1]) this.array.push(cmd); // skip repeating command
				if (this.array.length > this.max ) this.array.shift();
				this.index = this.array.length;
			},
		up:
			function(){
				var cmd="", indexwas = this.index;
				this.index = Math.max(0, this.index-1);
				if (this.array.length > 0 && this.index >= 0 && this.index < this.array.length){
					cmd = this.array[this.index];
				}
				if (indexwas == this.index) {
					if (kvm.tick('beep')) kvm.beep();
					cmd += "  \\ the end";
				}
				return(cmd);
			},
		down:
			function(){
				var cmd="", indexwas = this.index;
				this.index = Math.min(this.array.length-1, this.index+1);
				if(this.array.length > 0 && this.index >= 0 && this.index < this.array.length){
					cmd = this.array[this.index];
				}
				if (indexwas == this.index) {
					if (kvm.tick('beep')) kvm.beep();
					cmd += "  \\ the end";
				}
				return(cmd);
			},
	};

	$("#inputbox")[0].onkeydown = function(e){
		switch(e.keyCode) {
			case 27: /* Esc  */ if(kvm.tick('{esc}'  )){kvm.execute('{esc}'  );return(kvm.pop());} break;
			case 38: /* Up   */ if(kvm.tick('{up}'   )){kvm.execute('{up}'   );return(kvm.pop());} break;
			case 40: /* Down */ if(kvm.tick('{down}' )){kvm.execute('{down}' );return(kvm.pop());} break;
			case  8: /* Back space */ if(kvm.tick('{backSpace}' )){kvm.execute('{backSpace}' );return(kvm.pop());} break; 
		}
		return (true); // pass down to following handlers
	}

	document.onkeydown = function (e) {
		switch(e.keyCode) {
			case 13:
				kvm.scrollToElement($('#endofinputbox'));
				$('#inputbox').focus();
				if (!kvm.EditMode || event.ctrlKey) { // CtrlKeyDown
					kvm.inputbox = document.getElementById("inputbox").value; // w/o the '\n' character ($10).
					document.getElementById("inputbox").value = ""; // 少了這行，如果壓下 Enter 不放，就會變成重複執行。
					kvm.cmdhistory.push(kvm.inputbox);
					kvm.forthConsoleHandler(kvm.inputbox);
					return(false);
				}
				return(true); // In EditMode
			case 109: /* -   */ if(kvm.tick('{-}'  )){kvm.execute('{-}'  );return(kvm.pop());} break;
			case 107: /* +   */ if(kvm.tick('{+}'  )){kvm.execute('{+}'  );return(kvm.pop());} break;
			case 112: /* F1  */ if(kvm.tick('{F1}' )){kvm.execute('{F1}' );return(kvm.pop());} break;
			case 113: /* F2  */ if(kvm.tick('{F2}' )){kvm.execute('{F2}' );return(kvm.pop());} break;
			case 114: /* F3  */ if(kvm.tick('{F3}' )){kvm.execute('{F3}' );return(kvm.pop());} break;
			case 115: /* F4  */ if(kvm.tick('{F4}' )){kvm.execute('{F4}' );return(kvm.pop());} break;
			case 116: /* F5  */ if(kvm.tick('{F5}' )){kvm.execute('{F5}' );return(kvm.pop());} break;
			case 117: /* F6  */ if(kvm.tick('{F6}' )){kvm.execute('{F6}' );return(kvm.pop());} break;
			case 118: /* F7  */ if(kvm.tick('{F7}' )){kvm.execute('{F7}' );return(kvm.pop());} break;
			case 119: /* F8  */ if(kvm.tick('{F8}' )){kvm.execute('{F8}' );return(kvm.pop());} break;
			case 120: /* F9  */ if(kvm.tick('{F9}' )){kvm.execute('{F9}' );return(kvm.pop());} break;
			case 121: /* F10 */ if(kvm.tick('{F10}')){kvm.execute('{F10}');return(kvm.pop());} break;
			case 122: /* F11 */ if(kvm.tick('{F11}')){kvm.execute('{F11}');return(kvm.pop());} break;
			case 123: /* F12 */ if(kvm.tick('{F12}')){kvm.execute('{F12}');return(kvm.pop());} break;
		}
		return (true); // pass down to following handlers
	}
</js>

previous definitions
