
	s" ad.f" source-code-header

	\ Ad remover, remove annoying ad's from a web page

	: list-divs-that-have-position  ( -- ) \ Run in a target page
	  js> $("div").length ( length )
	  ?dup if dup for dup r@ - ( COUNT i ) 
		 >r
		 js> $("div")[rtos()].style.position
		 js> $("div")[rtos()].getAttribute("class") dup if char _note_ + then
		 js> $("div")[rtos()].id dup if char _note_ + then
		 r>
		 ." index:" . ."  ID: " . ."  Class: " . ."  style.position: " . cr \ the cr provides an important nap time 
	  ( COUNT ) next drop then ; 
	  /// Run on jeforth.3ce target page

	: get-divs-that-have-style.position  ( -- [DIVs] ) \ Run in a target page
		[] js> $("div").length ( [] length )
		?dup if dup for dup r@ - ( [] COUNT i ) 
			js> $("div")[pop()] ( [] COUNT div )
			dup :> style.position  ( [] COUNT div position )
			if   ( [] COUNT div )
				js: tos(2).push(pop())
			else ( [] COUNT div )
				drop
			then ( [] COUNT )
		( [] COUNT ) next drop then ; 
		/// Run on jeforth.3ce target page
		/// <DIV> that have style.position CSS are usually annoying Ad's.

	: removeElements ( [elements] -- ) \ Remove all elements
		begin js> tos().length while
			js> tos().pop() removeElement
		repeat drop ;
		/// Usage: Remove Ad's
		/// get-divs-that-have-style.position removeElements

		