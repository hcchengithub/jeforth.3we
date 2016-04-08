

	s" localstorage.f"		source-code-header

	\ Maintain source code in HTML5 local storage directly


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
		js> localStorage.sourcecode=sourcecode.value 
		." Saved source code textarea to local storage." cr  
		;

	: run ( -- ) \ Run text area source code (that may not saved to local storage yet)
		js> sourcecode.value tib.append ;

	: type ( -- ) \ Type local storage source code
		js> localStorage.sourcecode . ;

	: cls  ( -- ) \ Clear all #text in the outputbox elements are remained.
		ce@ ( save ) js> outputbox ce! er ce! ( restore ) ;
		/// Auto save-restore ce@ so it won't be changed.
		
		
		