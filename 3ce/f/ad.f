
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

<comment>

	\ 上面的方法要求先 attach 到 target page, 當初方便 study。如今已經證實方法可行,只要用
	\ 以下這段 code 在 3ce popup page 上執行就可以了。配合 local storage 很方便。
	
	\ Remove all annoying floating ad boxes. 刪除所有惱人的懸浮框。
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

	\ Make the target page editable for pruning. 把 target page 搞成 editable 以便修剪。
	active-tab :> id tabid! <ce> document.getElementsByTagName("body")[0].contentEditable=true </ce>
	
</comment>
		