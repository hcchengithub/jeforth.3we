
	\ Maintain source code in HTML5 local storage directly

	s" ls.f"		source-code-header

	: init ( -- ) \ Initialize local source
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
		
		