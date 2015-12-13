
	s" element.f" source-code-header

	<comment>

			☆☆☆ 類似 DOS cd + dir 的 ce 命令組，用來探索 HTML 結構 ☆☆☆

	這組命令方便咱對網頁內容的探索。類似 CP/M, MS-DOS 對 directory 的探索用 cd 命令，咱
	對 HTML 網頁樹狀結構的探索則用 ce 命令。同一個命令有兩個意思： change element 用來移
	動目光焦點； 而 current element 則列出目光焦點上的 element ── 取決於隨後的 argument。
	
	element 是帶有 children 的 node -- node 比較廣泛，但因我們通常對 HTML element
	比較感興趣，故 ce 命令引 element 為名，其實探索 HTML tree 時遇到 none element 的
	node 也是照樣使用。
	
	Pointing to the 目光焦點所在的 current element 是個 stack 結構，而非單一 variable. 原因
	是調皮的 HTML 探索者可以把 current-element 殺掉（html5.f 有 removeElement 命令），此後 
	current-element 就斷鏈了， current-element 是個 stack ( ce-history ) 結構，前一任
	的 current-element 就可以 pop 回來頂替。為避免出錯，我選擇從 ce@ 讀取 current-element
	命令時下手。
	
	如何得知 ce-history.tos 是個 dead element? ==> parentNode == null 
	注意 window 沒有 parentNode 屬性， window.document 的 parentNode 是 null。要特別處理。 
	
	</comment>
	

	[] constant ce-history // ( -- array ) Visited current-element history

	: ce! ce-history js: pop().push(pop()) ; // ( element -- ) Set current-element
		/// 非 element 的雜物可以放進去,但 ce@ 有防呆會把它丟掉。
	
	js> outputbox ce! \ Default current-element points to the display area of the forth console
	: ce@ ( -- element ) \ Get current-element
		ce-history :> length if else js> window.document ce! then \ guarantee history is not empty
		ce-history js> tos()[pop().length-1] ( history.tos )
		js> typeof(tos())=='object'&&tos().parentNode  ( history.tos flag ) if else \ element may be destroyed 
		js> tos()==window.document if else 
			cr ." Warning! Abnormal current-element. Go back to previous ce." cr cr
			drop ce-history js> tos().pop();tos()[pop().length-1] 
		then
		then ;
		/// Error proof, return previous history ce, or window.document if history is empty.

	: se ( element -- ) \ See the element
		dup children ( -- element array ) <js> 
			var i=0, a=pop(), element=pop(); if (typeof(element)=='object') {
				type(node(element)+'\n');
				for(; i<a.length; i++){
					push(i);dictate('5 .r');
					type(" : " + node(a[i]) + '\n');
				}
			}
			function attr(ele,att) {
				var v = "";
				if (ele.getAttribute && ele.getAttribute(att)) {
					v = att + "='" + ele.getAttribute(att) + "'; ";
				}
				return v;
			}
			function text(len, s) {
 				return (s.replace(/\s+/gm,' ').slice(0,100-len) + '...');
			}
			function node(ele){
				var s = ele.toString() + ' ';
				s += attr(ele,'id') + attr(ele,'class') + attr(ele,'name');
				if (ele.innerHTML) s += 'innerHTML=' + text(s.length+10,ele.innerHTML);
				else if (ele.textContent) s += text(s.length,ele.textContent);
				return s;
			}
		</js> ;
		/// Error-proof, do nothing if given element illegal.

	code (ce) ( destination -- ce@ ) \ Change element like cd does. Destination:(index,"..",'<','>','pop')
		var index=pop(); execute("ce@");/*ce@ 有防呆*/ var ce=pop();
		switch( index ){
			case "..": ce = ce.parentNode; break; // can be null
			case "<" : ce = ce.previousSibling; break; // can be null
			case ">" : ce = ce.nextSibling; break; // can be null
			case "pop" : dictate("ce-history :: pop() ce@");ce=pop(); break; // can be null
			default  : 
				if(isNaN(index)) ce=null;
				else ce = ce.childNodes[parseInt(index)]; // can be undefined
		}
		if (!ce) panic("Error! illegal destination: " + index + ". Stay recent ce.\n");
		else { push(ce); execute("ce!"); }
		execute("ce@");
		end-code
		/// Stay recent ce if destination 
		
	: ce ( [<'index'>] -- ) \ change element to current-element[index] or '..' to parent element.
		BL word ( -- 'index' ) ?dup if (ce) else ce@ then se ; interpret-only
		/// if nothing given then see current element
		/// Use 'se' in compiling mode if that's what you want to do.

	: ce< ( -- ) \ Change element to the previous current-element
		ce-history :: pop() ce@ se ;
	
	: (er) ( element -- ) \ Erase children of [object Text]
		children ( -- array ) <js> 
			for(var a=pop(),i=a.length-1; i>=0; i--) {
				// if (a[i].toString()=='[object Text]'||a[i].toString()=='[object HTMLBRElement]') {
				if (a[i].nodeName=='#text'||a[i].nodeName=='BR') {
					push(a[i]);
					execute('removeElement');
				}
			}
		</js> ;

	: er ce@ (er) ; // ( -- ) Erase current element text node and br

	: list-links ( element -- ) \ List HTML links under the element
		:> links ?dup if dup :> length ?dup if ( links length ) 
		dup for dup r@ - ( links length i ) 
		dup . space js> tos(2)[pop()].innerHTML </o> drop cr
		next drop then then ;
	\ 這裡面的 on???="..." 這些 attributes 都要先刪掉。如何取得?
		
<comment>
	page js> tos()[tos().length-1].toString() .s
	
	0 value body.children // ( -- array ) the window.body children array
	: test
	eleBody js> vm.appname char jeforth.3hta == if :> firstChild then ( -- body or HTA )
	100 []children to body.children
	body.children dup :> length ( -- array len )
	<js> for(var i=0,l=pop(),a=pop(); i<l; i++) {
		type(i+":"+a[i].toString()+'\n')
	} </js>
	;
	
	it works fine on jeforth.3htm
		0:[object Text]
		1:[object HTMLDivElement]
		2:[object Text]
		3:[object HTMLDivElement]
		4:[object HTMLParagraphElement]
		5:[object HTMLDivElement]
		6:[object Text]
		7:[object HTMLDivElement]
		8:[object HTMLDivElement]
		9:[object HTMLDivElement]
		10:[object HTMLDivElement]	
		
	but not so good on jeforth.3hta
		OK test
		0:[object HTMLUnknownElement]
		OK 	
	because HTA has a layer between eleBody and the real thing. Let's see
	
	this is 3HTA
	OK eleBody :> firstChild .
	[object HTMLUnknownElement] OK  <===== 應該就是 HTA
	eleBody :> firstChild.parentElement .
	[object HTMLBodyElement] OK  <============================== 往上沒問題 HTA 同 HTM	
	eleBody :> firstChild.parentElement.parentElement .
	[object HTMLHtmlElement] OK  <============================== 往上沒問題 HTA 同 HTM 
	
	eleBody :> firstChild.firstChild . <===== <body> 以下的第一個 child 應該是 HTA 
	[object Text] OK 						  在往下才是一般的 elements
	
	eleBody :> firstChild obj>keys . <==== 看看這一層神祕的 element 有啥東西。。。
	windowState,borderStyle,version,maximizeButton,minimizeButton,selection,border,
	innerBorder,commandLine,scroll,caption,applicationName,scrollFlat,showInTaskBar,
	singleInstance,contextMenu,sysMenu,icon,recordset,namedRecordset,currentStyle,
	runtimeStyle,accessKey,className,contentEditable,dir,disabled,id,innerHTML,
	isContentEditable,lang,offsetHeight,offsetLeft,offsetParent,offsetTop,offsetWidth	
	其中有 commandLine 印出來看，證實這個直屬於 <body> 的 element 正是 HTA. 所以
	eleBody :> firstChild.commandLine .  ==> "C:\Users\8304018.WKSCN\Dropbox\learnings\github\jeforth.3we\jeforth.hta" cls include alarm.f OK 
	OK eleBody :> firstChild.scopeName . ==> HTA 證實是他沒錯。
	eleBody :> firstChild.commandLine . <=== 也可以。 不懂為何放在 <body> 之下？因為每個 <body> 可以有
	自己的 HTA 嗎？ 有可能，因此乾脆全部都放在 <body> 下面，贊成！
	
	this is 3htm
	OK eleBody :> firstChild .
    [object Text] OK 
	OK eleBody :> firstChild.parentElement .
	[object HTMLBodyElement] OK  <============================== 往上沒問題 HTA 同 HTM 
	eleBody :> firstChild.parentElement.parentElement .
	[object HTMLHtmlElement] OK  <============================== 往上沒問題 HTA 同 HTM
	OK eleBody :> firstChild  .   <===== <body> 以下的第一個 child 是正常的 elements
	[object Text] OK 
	eleBody :> firstChild.firstChild . ==> null 
	
	查所有已知的 element 看有何共同特性，查 dead element 的 parentNode (不一定有 parentElement)
	[object Window] top,window,location,external,chrome,document,$,jQuery,kvm,script1423203618871,speechSynthesis,webkitStorageInfo,indexedDB,webkitIndexedDB,crypto,localStorage,sessionStorage,applicationCache,CSS,performance,console,devicePixelRatio,styleMedia,parent,opener,frames,self,defaultstatus,defaultStatus,status,name,length,closed,pageYOffset,pageXOffset,scrollY,scrollX,screenTop,screenLeft,screenY,screenX,innerWidth,innerHeight,outerWidth,outerHeight,offscreenBuffering,frameElement,clientInformation,navigator,toolbar,statusbar,scrollbars,personalbar,menubar,locationbar,history,screen,ondeviceorientation,ondevicemotion,postMessage,close,blur,focus,onautocompleteerror,onautocomplete,ontouchstart,ontouchmove,ontouchend,ontouchcancel,onunload,onstorage,onpopstate,onpageshow,onpagehide,ononline,onoffline,onmessage,onlanguagechange,onhashchange,onbeforeunload,onwaiting,onvolumechange,ontoggle,ontimeupdate,onsuspend,onsubmit,onstalled,onshow,onselect,onseeking,onseeked,onscroll,onresize,onreset,onratechange,onprogress,onplaying,onplay,onpause,onmousewheel,onmouseup,onmouseover,onmouseout,onmousemove,onmouseleave,onmouseenter,onmousedown,onloadstart,onloadedmetadata,onloadeddata,onload,onkeyup,onkeypress,onkeydown,oninvalid,oninput,onfocus,onerror,onended,onemptied,ondurationchange,ondrop,ondragstart,ondragover,ondragleave,ondragenter,ondragend,ondrag,ondblclick,oncuechange,oncontextmenu,onclose,onclick,onchange,oncanplaythrough,oncanplay,oncancel,onblur,onabort,onwheel,onwebkittransitionend,onwebkitanimationstart,onwebkitanimationiteration,onwebkitanimationend,ontransitionend,onsearch,getSelection,print,stop,open,alert,confirm,prompt,find,scrollBy,scrollTo,scroll,moveBy,moveTo,resizeBy,resizeTo,matchMedia,getComputedStyle,getMatchedCSSRules,requestAnimationFrame,cancelAnimationFrame,webkitRequestAnimationFrame,webkitCancelAnimationFrame,webkitCancelRequestAnimationFrame,captureEvents,releaseEvents,btoa,atob,setTimeout,clearTimeout,setInterval,clearInterval,TEMPORARY,PERSISTENT,webkitRequestFileSystem,webkitResolveLocalFileSystemURL,openDatabase,addEventListener,removeEventListener,dispatchEvent	
	[object HTMLDocument] vlinkColor,linkColor,alinkColor,fgColor,bgColor,compatMode,all,onautocompleteerror,onautocomplete,ontouchstart,ontouchmove,ontouchend,ontouchcancel,rootElement,childElementCount,lastElementChild,firstElementChild,children,onwaiting,onvolumechange,ontoggle,ontimeupdate,onsuspend,onsubmit,onstalled,onshow,onselect,onseeking,onseeked,onscroll,onresize,onreset,onratechange,onprogress,onplaying,onplay,onpause,onmousewheel,onmouseup,onmouseover,onmouseout,onmousemove,onmouseleave,onmouseenter,onmousedown,onloadstart,onloadedmetadata,onloadeddata,onload,onkeyup,onkeypress,onkeydown,oninvalid,oninput,onfocus,onerror,onended,onemptied,ondurationchange,ondrop,ondragstart,ondragover,ondragleave,ondragenter,ondragend,ondrag,ondblclick,oncuechange,oncontextmenu,onclose,onclick,onchange,oncanplaythrough,oncanplay,oncancel,onblur,onabort,onwebkitfullscreenerror,onwebkitfullscreenchange,webkitFullscreenElement,webkitFullscreenEnabled,webkitCurrentFullScreenElement,webkitFullScreenKeyboardInputAllowed,webkitIsFullScreen,fonts,currentScript,webkitHidden,webkitVisibilityState,hidden,visibilityState,onwheel,onselectstart,onselectionchange,onsearch,onreadystatechange,onpointerlockerror,onpointerlockchange,onpaste,oncut,oncopy,onbeforepaste,onbeforecut,onbeforecopy,pointerLockElement,activeElement,selectedStylesheetSet,preferredStylesheetSet,characterSet,readyState,defaultCharset,charset,location,lastModified,anchors,scripts,forms,links,plugins,embeds,applets,images,head,body,cookie,URL,domain,referrer,title,designMode,dir,contentType,styleSheets,defaultView,documentURI,xmlStandalone,xmlVersion,xmlEncoding,inputEncoding,documentElement,implementation,doctype,parentElement,textContent,baseURI,localName,namespaceURI,ownerDocument,nextSibling,previousSibling,lastChild,firstChild,childNodes,parentNode,nodeType,nodeValue,nodeName,open,close,write,writeln,clear,captureEvents,releaseEvents,createDocumentFragment,createTextNode,createComment,createCDATASection,createProcessingInstruction,createAttribute,getElementsByTagName,importNode,createAttributeNS,getElementsByTagNameNS,getElementById,adoptNode,createEvent,createRange,createNodeIterator,createTreeWalker,getOverrideStyle,execCommand,queryCommandEnabled,queryCommandIndeterm,queryCommandState,queryCommandSupported,queryCommandValue,getElementsByName,elementFromPoint,caretRangeFromPoint,getSelection,getCSSCanvasContext,getElementsByClassName,hasFocus,exitPointerLock,registerElement,createElement,createElementNS,webkitCancelFullScreen,webkitExitFullscreen,querySelector,querySelectorAll,createExpression,createNSResolver,evaluate,createTouch,createTouchList,insertBefore,replaceChild,removeChild,appendChild,hasChildNodes,cloneNode,normalize,isSameNode,isEqualNode,lookupPrefix,isDefaultNamespace,lookupNamespaceURI,compareDocumentPosition,contains,ELEMENT_NODE,ATTRIBUTE_NODE,TEXT_NODE,CDATA_SECTION_NODE,ENTITY_REFERENCE_NODE,ENTITY_NODE,PROCESSING_INSTRUCTION_NODE,COMMENT_NODE,DOCUMENT_NODE,DOCUMENT_TYPE_NODE,DOCUMENT_FRAGMENT_NODE,NOTATION_NODE,DOCUMENT_POSITION_DISCONNECTED,DOCUMENT_POSITION_PRECEDING,DOCUMENT_POSITION_FOLLOWING,DOCUMENT_POSITION_CONTAINS,DOCUMENT_POSITION_CONTAINED_BY,DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC,addEventListener,removeEventListener,dispatchEvent
	[object Comment]
	[object DocumentType]
	[object HTMLBRElement]
	[object HTMLBodyElement]
	[object HTMLCanvasElement] height,width,onautocompleteerror,onautocomplete,onwaiting,onvolumechange,ontoggle,ontimeupdate,onsuspend,onsubmit,onstalled,onshow,onselect,onseeking,onseeked,onscroll,onresize,onreset,onratechange,onprogress,onplaying,onplay,onpause,onmousewheel,onmouseup,onmouseover,onmouseout,onmousemove,onmouseleave,onmouseenter,onmousedown,onloadstart,onloadedmetadata,onloadeddata,onload,onkeyup,onkeypress,onkeydown,oninvalid,oninput,onfocus,onerror,onended,onemptied,ondurationchange,ondrop,ondragstart,ondragover,ondragleave,ondragenter,ondragend,ondrag,ondblclick,oncuechange,oncontextmenu,onclose,onclick,onchange,oncanplaythrough,oncanplay,oncancel,onblur,onabort,spellcheck,isContentEditable,contentEditable,outerText,innerText,accessKey,hidden,webkitdropzone,draggable,tabIndex,dir,translate,lang,title,ontouchstart,ontouchmove,ontouchend,ontouchcancel,childElementCount,lastElementChild,firstElementChild,children,onwebkitfullscreenerror,onwebkitfullscreenchange,nextElementSibling,previousElementSibling,onwheel,onselectstart,onsearch,onpaste,oncut,oncopy,onbeforepaste,onbeforecut,onbeforecopy,shadowRoot,dataset,classList,className,outerHTML,innerHTML,scrollHeight,scrollWidth,scrollTop,scrollLeft,clientHeight,clientWidth,clientTop,clientLeft,offsetParent,offsetHeight,offsetWidth,offsetTop,offsetLeft,localName,prefix,namespaceURI,id,style,attributes,tagName,parentElement,textContent,baseURI,ownerDocument,nextSibling,previousSibling,lastChild,firstChild,childNodes,parentNode,nodeType,nodeValue,nodeName,toDataURL,getContext,click,getAttribute,setAttribute,removeAttribute,getAttributeNode,setAttributeNode,removeAttributeNode,getElementsByTagName,hasAttributes,getAttributeNS,setAttributeNS,removeAttributeNS,getElementsByTagNameNS,getAttributeNodeNS,setAttributeNodeNS,hasAttribute,hasAttributeNS,matches,focus,blur,scrollIntoView,scrollIntoViewIfNeeded,getElementsByClassName,insertAdjacentElement,insertAdjacentText,insertAdjacentHTML,webkitMatchesSelector,createShadowRoot,getDestinationInsertionPoints,getClientRects,getBoundingClientRect,requestPointerLock,animate,remove,webkitRequestFullScreen,webkitRequestFullscreen,querySelector,querySelectorAll,ALLOW_KEYBOARD_INPUT,insertBefore,replaceChild,removeChild,appendChild,hasChildNodes,cloneNode,normalize,isSameNode,isEqualNode,lookupPrefix,isDefaultNamespace,lookupNamespaceURI,compareDocumentPosition,contains,ELEMENT_NODE,ATTRIBUTE_NODE,TEXT_NODE,CDATA_SECTION_NODE,ENTITY_REFERENCE_NODE,ENTITY_NODE,PROCESSING_INSTRUCTION_NODE,COMMENT_NODE,DOCUMENT_NODE,DOCUMENT_TYPE_NODE,DOCUMENT_FRAGMENT_NODE,NOTATION_NODE,DOCUMENT_POSITION_DISCONNECTED,DOCUMENT_POSITION_PRECEDING,DOCUMENT_POSITION_FOLLOWING,DOCUMENT_POSITION_CONTAINS,DOCUMENT_POSITION_CONTAINED_BY,DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC,addEventListener,removeEventListener,dispatchEvent OK
	[object HTMLDivElement] align,onautocompleteerror,onautocomplete,onwaiting,onvolumechange,ontoggle,ontimeupdate,onsuspend,onsubmit,onstalled,onshow,onselect,onseeking,onseeked,onscroll,onresize,onreset,onratechange,onprogress,onplaying,onplay,onpause,onmousewheel,onmouseup,onmouseover,onmouseout,onmousemove,onmouseleave,onmouseenter,onmousedown,onloadstart,onloadedmetadata,onloadeddata,onload,onkeyup,onkeypress,onkeydown,oninvalid,oninput,onfocus,onerror,onended,onemptied,ondurationchange,ondrop,ondragstart,ondragover,ondragleave,ondragenter,ondragend,ondrag,ondblclick,oncuechange,oncontextmenu,onclose,onclick,onchange,oncanplaythrough,oncanplay,oncancel,onblur,onabort,spellcheck,isContentEditable,contentEditable,outerText,innerText,accessKey,hidden,webkitdropzone,draggable,tabIndex,dir,translate,lang,title,ontouchstart,ontouchmove,ontouchend,ontouchcancel,childElementCount,lastElementChild,firstElementChild,children,onwebkitfullscreenerror,onwebkitfullscreenchange,nextElementSibling,previousElementSibling,onwheel,onselectstart,onsearch,onpaste,oncut,oncopy,onbeforepaste,onbeforecut,onbeforecopy,shadowRoot,dataset,classList,className,outerHTML,innerHTML,scrollHeight,scrollWidth,scrollTop,scrollLeft,clientHeight,clientWidth,clientTop,clientLeft,offsetParent,offsetHeight,offsetWidth,offsetTop,offsetLeft,localName,prefix,namespaceURI,id,style,attributes,tagName,parentElement,textContent,baseURI,ownerDocument,nextSibling,previousSibling,lastChild,firstChild,childNodes,parentNode,nodeType,nodeValue,nodeName,click,getAttribute,setAttribute,removeAttribute,getAttributeNode,setAttributeNode,removeAttributeNode,getElementsByTagName,hasAttributes,getAttributeNS,setAttributeNS,removeAttributeNS,getElementsByTagNameNS,getAttributeNodeNS,setAttributeNodeNS,hasAttribute,hasAttributeNS,matches,focus,blur,scrollIntoView,scrollIntoViewIfNeeded,getElementsByClassName,insertAdjacentElement,insertAdjacentText,insertAdjacentHTML,webkitMatchesSelector,createShadowRoot,getDestinationInsertionPoints,getClientRects,getBoundingClientRect,requestPointerLock,animate,remove,webkitRequestFullScreen,webkitRequestFullscreen,querySelector,querySelectorAll,ALLOW_KEYBOARD_INPUT,insertBefore,replaceChild,removeChild,appendChild,hasChildNodes,cloneNode,normalize,isSameNode,isEqualNode,lookupPrefix,isDefaultNamespace,lookupNamespaceURI,compareDocumentPosition,contains,ELEMENT_NODE,ATTRIBUTE_NODE,TEXT_NODE,CDATA_SECTION_NODE,ENTITY_REFERENCE_NODE,ENTITY_NODE,PROCESSING_INSTRUCTION_NODE,COMMENT_NODE,DOCUMENT_NODE,DOCUMENT_TYPE_NODE,DOCUMENT_FRAGMENT_NODE,NOTATION_NODE,DOCUMENT_POSITION_DISCONNECTED,DOCUMENT_POSITION_PRECEDING,DOCUMENT_POSITION_FOLLOWING,DOCUMENT_POSITION_CONTAINS,DOCUMENT_POSITION_CONTAINED_BY,DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC,addEventListener,removeEventListener,dispatchEvent
	[object HTMLHeadElement]
	[object HTMLHtmlElement] version,onautocompleteerror,onautocomplete,onwaiting,onvolumechange,ontoggle,ontimeupdate,onsuspend,onsubmit,onstalled,onshow,onselect,onseeking,onseeked,onscroll,onresize,onreset,onratechange,onprogress,onplaying,onplay,onpause,onmousewheel,onmouseup,onmouseover,onmouseout,onmousemove,onmouseleave,onmouseenter,onmousedown,onloadstart,onloadedmetadata,onloadeddata,onload,onkeyup,onkeypress,onkeydown,oninvalid,oninput,onfocus,onerror,onended,onemptied,ondurationchange,ondrop,ondragstart,ondragover,ondragleave,ondragenter,ondragend,ondrag,ondblclick,oncuechange,oncontextmenu,onclose,onclick,onchange,oncanplaythrough,oncanplay,oncancel,onblur,onabort,spellcheck,isContentEditable,contentEditable,outerText,innerText,accessKey,hidden,webkitdropzone,draggable,tabIndex,dir,translate,lang,title,ontouchstart,ontouchmove,ontouchend,ontouchcancel,childElementCount,lastElementChild,firstElementChild,children,onwebkitfullscreenerror,onwebkitfullscreenchange,nextElementSibling,previousElementSibling,onwheel,onselectstart,onsearch,onpaste,oncut,oncopy,onbeforepaste,onbeforecut,onbeforecopy,shadowRoot,dataset,classList,className,outerHTML,innerHTML,scrollHeight,scrollWidth,scrollTop,scrollLeft,clientHeight,clientWidth,clientTop,clientLeft,offsetParent,offsetHeight,offsetWidth,offsetTop,offsetLeft,localName,prefix,namespaceURI,id,style,attributes,tagName,parentElement,textContent,baseURI,ownerDocument,nextSibling,previousSibling,lastChild,firstChild,childNodes,parentNode,nodeType,nodeValue,nodeName,click,getAttribute,setAttribute,removeAttribute,getAttributeNode,setAttributeNode,removeAttributeNode,getElementsByTagName,hasAttributes,getAttributeNS,setAttributeNS,removeAttributeNS,getElementsByTagNameNS,getAttributeNodeNS,setAttributeNodeNS,hasAttribute,hasAttributeNS,matches,focus,blur,scrollIntoView,scrollIntoViewIfNeeded,getElementsByClassName,insertAdjacentElement,insertAdjacentText,insertAdjacentHTML,webkitMatchesSelector,createShadowRoot,getDestinationInsertionPoints,getClientRects,getBoundingClientRect,requestPointerLock,animate,remove,webkitRequestFullScreen,webkitRequestFullscreen,querySelector,querySelectorAll,ALLOW_KEYBOARD_INPUT,insertBefore,replaceChild,removeChild,appendChild,hasChildNodes,cloneNode,normalize,isSameNode,isEqualNode,lookupPrefix,isDefaultNamespace,lookupNamespaceURI,compareDocumentPosition,contains,ELEMENT_NODE,ATTRIBUTE_NODE,TEXT_NODE,CDATA_SECTION_NODE,ENTITY_REFERENCE_NODE,ENTITY_NODE,PROCESSING_INSTRUCTION_NODE,COMMENT_NODE,DOCUMENT_NODE,DOCUMENT_TYPE_NODE,DOCUMENT_FRAGMENT_NODE,NOTATION_NODE,DOCUMENT_POSITION_DISCONNECTED,DOCUMENT_POSITION_PRECEDING,DOCUMENT_POSITION_FOLLOWING,DOCUMENT_POSITION_CONTAINS,DOCUMENT_POSITION_CONTAINED_BY,DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC,addEventListener,removeEventListener,dispatchEvent
	[object HTMLMetaElement]
	[object HTMLParagraphElement] align,onautocompleteerror,onautocomplete,onwaiting,onvolumechange,ontoggle,ontimeupdate,onsuspend,onsubmit,onstalled,onshow,onselect,onseeking,onseeked,onscroll,onresize,onreset,onratechange,onprogress,onplaying,onplay,onpause,onmousewheel,onmouseup,onmouseover,onmouseout,onmousemove,onmouseleave,onmouseenter,onmousedown,onloadstart,onloadedmetadata,onloadeddata,onload,onkeyup,onkeypress,onkeydown,oninvalid,oninput,onfocus,onerror,onended,onemptied,ondurationchange,ondrop,ondragstart,ondragover,ondragleave,ondragenter,ondragend,ondrag,ondblclick,oncuechange,oncontextmenu,onclose,onclick,onchange,oncanplaythrough,oncanplay,oncancel,onblur,onabort,spellcheck,isContentEditable,contentEditable,outerText,innerText,accessKey,hidden,webkitdropzone,draggable,tabIndex,dir,translate,lang,title,ontouchstart,ontouchmove,ontouchend,ontouchcancel,childElementCount,lastElementChild,firstElementChild,children,onwebkitfullscreenerror,onwebkitfullscreenchange,nextElementSibling,previousElementSibling,onwheel,onselectstart,onsearch,onpaste,oncut,oncopy,onbeforepaste,onbeforecut,onbeforecopy,shadowRoot,dataset,classList,className,outerHTML,innerHTML,scrollHeight,scrollWidth,scrollTop,scrollLeft,clientHeight,clientWidth,clientTop,clientLeft,offsetParent,offsetHeight,offsetWidth,offsetTop,offsetLeft,localName,prefix,namespaceURI,id,style,attributes,tagName,parentElement,textContent,baseURI,ownerDocument,nextSibling,previousSibling,lastChild,firstChild,childNodes,parentNode,nodeType,nodeValue,nodeName,click,getAttribute,setAttribute,removeAttribute,getAttributeNode,setAttributeNode,removeAttributeNode,getElementsByTagName,hasAttributes,getAttributeNS,setAttributeNS,removeAttributeNS,getElementsByTagNameNS,getAttributeNodeNS,setAttributeNodeNS,hasAttribute,hasAttributeNS,matches,focus,blur,scrollIntoView,scrollIntoViewIfNeeded,getElementsByClassName,insertAdjacentElement,insertAdjacentText,insertAdjacentHTML,webkitMatchesSelector,createShadowRoot,getDestinationInsertionPoints,getClientRects,getBoundingClientRect,requestPointerLock,animate,remove,webkitRequestFullScreen,webkitRequestFullscreen,querySelector,querySelectorAll,ALLOW_KEYBOARD_INPUT,insertBefore,replaceChild,removeChild,appendChild,hasChildNodes,cloneNode,normalize,isSameNode,isEqualNode,lookupPrefix,isDefaultNamespace,lookupNamespaceURI,compareDocumentPosition,contains,ELEMENT_NODE,ATTRIBUTE_NODE,TEXT_NODE,CDATA_SECTION_NODE,ENTITY_REFERENCE_NODE,ENTITY_NODE,PROCESSING_INSTRUCTION_NODE,COMMENT_NODE,DOCUMENT_NODE,DOCUMENT_TYPE_NODE,DOCUMENT_FRAGMENT_NODE,NOTATION_NODE,DOCUMENT_POSITION_DISCONNECTED,DOCUMENT_POSITION_PRECEDING,DOCUMENT_POSITION_FOLLOWING,DOCUMENT_POSITION_CONTAINS,DOCUMENT_POSITION_CONTAINED_BY,DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC,addEventListener,removeEventListener,dispatchEvent
	[object HTMLQuoteElement]
	[object HTMLScriptElement]
	[object HTMLStyleElement]
	[object HTMLTableElement]
	[object HTMLTextAreaElement] selectionDirection,selectionEnd,selectionStart,labels,validationMessage,validity,willValidate,textLength,value,defaultValue,type,wrap,rows,required,readOnly,placeholder,name,minLength,maxLength,form,disabled,dirName,cols,autofocus,onautocompleteerror,onautocomplete,onwaiting,onvolumechange,ontoggle,ontimeupdate,onsuspend,onsubmit,onstalled,onshow,onselect,onseeking,onseeked,onscroll,onresize,onreset,onratechange,onprogress,onplaying,onplay,onpause,onmousewheel,onmouseup,onmouseover,onmouseout,onmousemove,onmouseleave,onmouseenter,onmousedown,onloadstart,onloadedmetadata,onloadeddata,onload,onkeyup,onkeypress,onkeydown,oninvalid,oninput,onfocus,onerror,onended,onemptied,ondurationchange,ondrop,ondragstart,ondragover,ondragleave,ondragenter,ondragend,ondrag,ondblclick,oncuechange,oncontextmenu,onclose,onclick,onchange,oncanplaythrough,oncanplay,oncancel,onblur,onabort,spellcheck,isContentEditable,contentEditable,outerText,innerText,accessKey,hidden,webkitdropzone,draggable,tabIndex,dir,translate,lang,title,ontouchstart,ontouchmove,ontouchend,ontouchcancel,childElementCount,lastElementChild,firstElementChild,children,onwebkitfullscreenerror,onwebkitfullscreenchange,nextElementSibling,previousElementSibling,onwheel,onselectstart,onsearch,onpaste,oncut,oncopy,onbeforepaste,onbeforecut,onbeforecopy,shadowRoot,dataset,classList,className,outerHTML,innerHTML,scrollHeight,scrollWidth,scrollTop,scrollLeft,clientHeight,clientWidth,clientTop,clientLeft,offsetParent,offsetHeight,offsetWidth,offsetTop,offsetLeft,localName,prefix,namespaceURI,id,style,attributes,tagName,parentElement,textContent,baseURI,ownerDocument,nextSibling,previousSibling,lastChild,firstChild,childNodes,parentNode,nodeType,nodeValue,nodeName,checkValidity,reportValidity,setCustomValidity,select,setRangeText,setSelectionRange,click,getAttribute,setAttribute,removeAttribute,getAttributeNode,setAttributeNode,removeAttributeNode,getElementsByTagName,hasAttributes,getAttributeNS,setAttributeNS,removeAttributeNS,getElementsByTagNameNS,getAttributeNodeNS,setAttributeNodeNS,hasAttribute,hasAttributeNS,matches,focus,blur,scrollIntoView,scrollIntoViewIfNeeded,getElementsByClassName,insertAdjacentElement,insertAdjacentText,insertAdjacentHTML,webkitMatchesSelector,createShadowRoot,getDestinationInsertionPoints,getClientRects,getBoundingClientRect,requestPointerLock,animate,remove,webkitRequestFullScreen,webkitRequestFullscreen,querySelector,querySelectorAll,ALLOW_KEYBOARD_INPUT,insertBefore,replaceChild,removeChild,appendChild,hasChildNodes,cloneNode,normalize,isSameNode,isEqualNode,lookupPrefix,isDefaultNamespace,lookupNamespaceURI,compareDocumentPosition,contains,ELEMENT_NODE,ATTRIBUTE_NODE,TEXT_NODE,CDATA_SECTION_NODE,ENTITY_REFERENCE_NODE,ENTITY_NODE,PROCESSING_INSTRUCTION_NODE,COMMENT_NODE,DOCUMENT_NODE,DOCUMENT_TYPE_NODE,DOCUMENT_FRAGMENT_NODE,NOTATION_NODE,DOCUMENT_POSITION_DISCONNECTED,DOCUMENT_POSITION_PRECEDING,DOCUMENT_POSITION_FOLLOWING,DOCUMENT_POSITION_CONTAINS,DOCUMENT_POSITION_CONTAINED_BY,DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC,addEventListener,removeEventListener,dispatchEvent
	[object HTMLTitleElement]
	[object Text] wholeText,nextElementSibling,previousElementSibling,length,data,parentElement,textContent,baseURI,localName,namespaceURI,ownerDocument,nextSibling,previousSibling,lastChild,firstChild,childNodes,parentNode,nodeType,nodeValue,nodeName,splitText,replaceWholeText,getDestinationInsertionPoints,substringData,appendData,insertData,deleteData,replaceData,remove,insertBefore,replaceChild,removeChild,appendChild,hasChildNodes,cloneNode,normalize,isSameNode,isEqualNode,lookupPrefix,isDefaultNamespace,lookupNamespaceURI,compareDocumentPosition,contains,ELEMENT_NODE,ATTRIBUTE_NODE,TEXT_NODE,CDATA_SECTION_NODE,ENTITY_REFERENCE_NODE,ENTITY_NODE,PROCESSING_INSTRUCTION_NODE,COMMENT_NODE,DOCUMENT_NODE,DOCUMENT_TYPE_NODE,DOCUMENT_FRAGMENT_NODE,NOTATION_NODE,DOCUMENT_POSITION_DISCONNECTED,DOCUMENT_POSITION_PRECEDING,DOCUMENT_POSITION_FOLLOWING,DOCUMENT_POSITION_CONTAINS,DOCUMENT_POSITION_CONTAINED_BY,DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC,addEventListener,removeEventListener,dispatchEvent 
	
</comment>