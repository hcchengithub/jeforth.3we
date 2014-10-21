
                            j e f o r t h . 3 w e
							    develop log
  ~%~%~%~%~%~%~%~  The jeforth which has a three words engine ~%~%~%~%~%~%~%~

How to run:

	HTA
		jeforth.hta 
		jeforth.hta cls .' Hello world' cr 3000 sleep bye
	Node	
		node jeforth.3nd
		node jeforth.3nd cls .' Hello world' cr 3000 sleep bye
	HTM
		http://localhost:8888/jeforth.htm
	

[x] first line of jeforth.f is strange. I skip it now. Need to find out the reason someday.  hcchen5600 2014/01/28 11:39:49 
[x] why UTF-8 chinese characters are not shown correctly? ==> big5 is ok!  
[X] jquery.terminal-0.7.7.js  ==> I give up jQuery-terminal when it comes to HTA.

    > 552           var data = $.Storage.get(name + 'commands');
    >       alert(name+"==>"+data);     
    > 553           data = data ? new Function('return ' + data + ';')() : [];
    > 554           var pos = data.length-1;
    
	How to make a Terminal (comamnd line, shell like) U/I on Web page?
    See this answer ==> evernote:///view/2472143/s22/bf00c410-9727-401f-98a7-221c8fc00558/bf00c410-9727-401f-98a7-221c8fc00558/
    
[x] the screen output is a little strange, messy. Find a SRP.
    ==> print() probably is the root cause, it wrap around long lines. Looks like the jQuery-terminal 
        thinks of the right-edge with a wrong number.  
    ==> When use 'body' instead of a DIV component, the jQuery-terminal can not scroll up and the 
        bottom line can not see!
    ==> So, give up using jQuery-terminal? Sure, ok this is it!
        ==> [/] simplify the SRP and report to the jQuery-terminal author.
    ==> [/] also consider to use termlib.js @ evernote:///view/2472143/s22/6df50a24-f3b8-4ae4-afc5-45d7e180b3dc/6df50a24-f3b8-4ae4-afc5-45d7e180b3dc/
    ==> [x] Try normal HTML terminal first
        ------ http://jsfiddle.net/hcchen/9Kr5E/ hcchen/jsfiddle ------------------
        << HTML section >>
            <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.10.2/jquery.min.js"></script>
            <div id="screenoutput">恭喜發財！</div>
            <div id="keyboardinput"> 
                <span>root@host</span>&nbsp;
                <keyboardinput type="text" id="command" />
            </div>
 
        << JavaScript section >>
            
            $("#command").keyup(function (e) {
                if (e.keyCode == 13) {
                    submit();
                }
            });
    
            var submit = function () {
                var command = document.getElementById("command").value;
                var outputel = document.getElementById("screenoutput");
                var div = document.createElement("div");
                div.innerHTML = "root@host " + command;
                outputel.appendChild(div);
                document.getElementById("command").value = "";
            };
    ==> I give up jQuery-terminal when it comes to HTA.
    
[x] In .3nw jsEvalRaw's return value spec was quirky, it was ( data errormsg ), make it simpler
    ( data, errormsg, flag) ? 
    jsEvalRaw is a very useful word. By using jsEvalRaw, we don't need to try{}catch{} every
    system call. E.g. readTextFile() and writeTextFile() become much easier.

[x] Now start to port wsh.f (wmi.f excel.f ... )

[x] Make <vbs> .... </vbs> <=== 研究 WSC 就是為了要 support 這組有趣的命令
    Study how to combine VBscipt and JScript
    HTC http://msdn.microsoft.com/en-us/library/ms532146(v=vs.85).aspx
    WSC or WSH gui interface with IE or HTA http://computer-programming-forum.com/61-wsh/9dad42d8c1e3a878.htm
	
	hcchen5600 2014/07/01 08:44:41 It's very easy. See below hcchen5600 2014/06/30 17:22:40
    
[/] WSC can be used in VBScript even wthout registered.
    Ask Michael Harris, if same thing can be done in JScript? ==> Now I realized, even if it 
    would turn out that only VBscript can GetObject(..wsc..) is good enough. jeforth.hta uses
    that VBScript to launch jeforth.js would be fine.
    [x] Put the jeforth.js into jeforth.wsc, Open jeforth.WSC in jeforth.hta
        ==> use <script src='jeforth.js'></script> to include jeforth.js in WSC is ok.
    [ ] we can publicate properties and methods but how to publicate objects?
        <public>
        <property name="propertyname"/>
        <property name="kvm"/>
        <method name="methodname"/>
        </public>
        ==> If you are thinking of a <object> tag, see this http://msdn.microsoft.com/en-us/library/thwwf7y9(v=vs.84).aspx
            But it's wrong anyway. An object is simply a property I guess.
    [ ] Note! Only define things in WSC, don't try to run anything in WSC.
	[ ]	By the experiments of Dropbox\learnings\JavaScript\WSC , if run 2.vbs then
		JS section in 2.wsc doesn't know about WScript.echo but MsgBox of VBS works fine.
		why? WSC do not have any I/O? unless that are VBS built-in, right? This is great!
		VBScript has many built-in U/I functions.
		
[x] Recent jeforth.3hta on Github is v1.00, it prints to a <div> immediately but they
	do not appear on the web page immediately! <=== Note, because jeforth for-next loop is a blocking
	process. Thus, "print" and "accept" need to refer to plateform.f in jeforth.3nw which is my best
	practice dealing with none-blocking programming.
	
	\ By using 'sleep' command introduced since jeforth.3nw, I can make KVM none-blocking. See below
	\ example, it works fine on jeforth.3hta v1.00 too.
	: test for r@ . space 1 sleep next ;
	cls 1000 last execute

	\ But I find another way without using 'sleep' and it's much mush faster,
	: test for r@ . space js> scrollToElement($('#endofpage')) next ;
	cls 1000 last execute

[/] 承上, I should designe a word to scroll to end of the display area. 
    Calling the scrolling system call gives the browser some time to breathe.
	==> scrollToElement() is good enough. If you are thinking about jeforth's example, it's,
	    <js> 
	        var o = document.getElementById('outputbox');
	        o.scrollTop = o.scrollHeight;
	    </js>

[x] Now by utilizing WSC, I think that I can combine jeforth.3wsh and jeforth.3hta or even jeforth.3wsf
    Because they all based on the same jeforth.wsc.
	HTA is really a sinking boat http://social.technet.microsoft.com/Forums/scriptcenter/en-US/c21b847c-35b4-46ab-a609-17e7fd47638e/how-to-open-the-f12-key-debugger-in-hta-like-ie?forum=ITCG#c21b847c-35b4-46ab-a609-17e7fd47638e
	==> No need to complicate wsc this way, see 2014/02/07 13:48:05
	
[x] hcchen5600 2014/02/07 13:48:05 
    WSC's purpose is letting jeforth to support <vb> </vb> commands then we don't need to
    bring entire jeforth.js into the wsc file!!
	==> Yeah! True. My .wsc has only a vbscript section that exports properties and methods.
		then they can be accessed from jeforth by wsc.propertyname and wsc.methodname().
	
	<text>
		' Disk.vbs
		' Sample VBS WMI
		' Author Guy Thomas http://computerperformance.co.uk/
		' http://www.computerperformance.co.uk/vbscript/wmi_basics.htm
		' Version 1.5 - November 2010
		' -----------------------------------------------' 
		Option Explicit
		Dim objWMIService, objItem, colItems, strComputer, intDrive
		
		' On Error Resume Next
		strComputer = "."
		intDrive = 0
		
		' WMI connection to Root CIM
		Set objWMIService = GetObject("winmgmts:\\" _
		& strComputer & "\root\cimv2")
		Set colItems = objWMIService.ExecQuery(_
		"Select * from Win32_DiskDrive")
		
		' Classic For Next Loop
		For Each objItem in colItems
		intDrive = intDrive + 1
		print "DiskDrive " & intDrive & vbCrLf & _ 
		"Caption: " & objItem.Caption & vbCrLf & _ 
		"Description: " & objItem.Description & vbCrLf & _ 
		"Manufacturer: " & objItem.Manufacturer & vbCrLf & _ 
		"Model: " & objItem.Model & vbCrLf & _ 
		"Name: " & objItem.Name & vbCrLf & _ 
		"Partitions: " & objItem.Partitions & vbCrLf & _ 
		"Size: " & objItem.Size & vbCrLf & _ 
		"Status: " & objItem.Status & vbCrLf & _ 
		"SystemName: " & objItem.SystemName & vbCrLf & _ 
		"TotalCylinders: " & objItem.TotalCylinders & vbCrLf & _ 
		"TotalHeads: " & objItem.TotalHeads & vbCrLf & _ 
		"TotalSectors: " & objItem.TotalSectors & vbCrLf & _ 
		"TotalTracks: " & objItem.TotalTracks & vbCrLf & _ 
		"TracksPerCylinder: " & objItem.TracksPerCylinder 
		Next
		
		' End of Sample Disk VBScript
	</text> js> vbs.displayBuffer="";vbs.exec(pop());vbs.displayBuffer cls .

	-------------------------------------------------------------------------------
	W/O using WSC works fine too
	-------------------------------------------------------------------------------
	<text>
		' Disk.vbs
		' Sample VBS WMI
		' Author Guy Thomas http://computerperformance.co.uk/
		' http://www.computerperformance.co.uk/vbscript/wmi_basics.htm
		' Version 1.5 - November 2010
		' -----------------------------------------------' 
		Option Explicit
		Dim objWMIService, objItem, colItems, strComputer, intDrive
		
		' On Error Resume Next
		strComputer = "."
		intDrive = 0
		
		' WMI connection to Root CIM
		Set objWMIService = GetObject("winmgmts:\\" _
		& strComputer & "\root\cimv2")
		Set colItems = objWMIService.ExecQuery(_
		"Select * from Win32_DiskDrive")
		
		' Classic For Next Loop
		For Each objItem in colItems
		intDrive = intDrive + 1
		print "DiskDrive " & intDrive & vbCrLf & _ 
		"Caption: " & objItem.Caption & vbCrLf & _ 
		"Description: " & objItem.Description & vbCrLf & _ 
		"Manufacturer: " & objItem.Manufacturer & vbCrLf & _ 
		"Model: " & objItem.Model & vbCrLf & _ 
		"Name: " & objItem.Name & vbCrLf & _ 
		"Partitions: " & objItem.Partitions & vbCrLf & _ 
		"Size: " & objItem.Size & vbCrLf & _ 
		"Status: " & objItem.Status & vbCrLf & _ 
		"SystemName: " & objItem.SystemName & vbCrLf & _ 
		"TotalCylinders: " & objItem.TotalCylinders & vbCrLf & _ 
		"TotalHeads: " & objItem.TotalHeads & vbCrLf & _ 
		"TotalSectors: " & objItem.TotalSectors & vbCrLf & _ 
		"TotalTracks: " & objItem.TotalTracks & vbCrLf & _ 
		"TracksPerCylinder: " & objItem.TracksPerCylinder 
		Next
		
		' End of Sample Disk VBScript
	</text> js> vbExecute(pop())

[x] We totally don't need WSC if the purpose is letting jeforth to support <vb> </vb> commands.
	HTA allows different language sections to reference each other! Shit, I didn't know.
	
[x] wsh.f Try to support the 'include' command to auto-search the given file.
	done! hcchen5600 2014/07/13 15:38:04 

[x] http://www.104case.com.tw/memberp/member_seek_qa.cfm?seekno=815367042306027563&mode=2
	黃嘉祥
	服務的金額這確實是令人頭痛的問題,有時候只是”江湖一點訣”根本沒什麼,要收費我也收的很不好意思,像
	您104貼的那個問題,只要加上浮動設定就可以解決了
	＜div id=”keyboardinput” style=”position:absolute; bottom:0;”＞
	除非您有更進一步的需求再做調整。 我目前的配合方式：1.單件報價 - 次月或累積到一定的金額($5000)時
	再付款。 2.月聘維護 - 依公司維護需求/等級定價(這部分可能要詳談)。 我通常都建議初期採用單件，除非
	很確定需求和內容，不然採用月聘容易產生誤會(ex:錢付了,結果整個月只處理兩件小事，或一個月內超過20
	件複雜案，超過維護門檻)如果是像104那個小問題，沒有時間壓力要馬上解決的話...我看我們就交個朋友，透
	過mail處理掉就ok了
	2014/02/12 04:49
	
[x] Wrtie a debug console, 'jsc' command. 
    See jeforth.js function panic(msg,severity) when severity!=false.
	Consider to use VBScript's MsgBox and InpubBox. 
	No need to use VB, JavaScript has similar built-in functions: 
	    js: alert('msg')  js> confirm('msg')  js> prompt('msg')
	[x] hcchen5600 2014/07/16 10:09:47 利用 eval() 會認得 local variable 的特性。
	==> Bingo!!
		kvm.jsc.prompt = "111";eval(kvm.jsc.xt);
	
[x] 目前 gitHub 上有一版基本版 voc.f ready -- hcchen5600 2014/02/28 15:25:14 
    
[x] hcchen5600 2014/06/30 14:08:56 還在搞 <vb> ... </vb> 的準備。在 Github 上弄了個 Develop branch 方便 backup 用。
    jeforth.3hta\playground\vb.f 有些進展。
    先把本來 jeforth.hta 裡的 vbs section 整個弄走，放進 vbs/basic.vbs ----> 
	vb.f 裡實驗用 vbExecute(pop()) 來定義 vbs function or subroutine 有成功！但只能在同一個 block 裡存在。如何把
	它 assign 給一個 name ?
	If not doable, then being able to include ~.vbs is good enough.
	hcchen5600 2014/06/30 17:22:40 <vb> ... </vb> is ok now at playground/vb.f.

[x] hcchen5600 2014/06/30 17:23:43 
    kvm.something can be accessed in <vb> section.
    js> kvm obj>keys .
	I got ===> init,reset,panic,*fortheval*,see,suspendForthVM,resumeForthVM,stack,words OK <vb> 
	many of kvm export functions are not used at all, and we need push() and pop(). ===> done!
	All kvm memvers can be used in <vb> section happily.
	Example:
    <vb> kvm.push(kvm.tos()) </vb> <------- this works like 'DUP' command.
	vb: vb> are done too. Commit it.
	
[x] Many useful VBS examples are here 
    http://msdn.microsoft.com/en-us/library/aa394599(v=vs.85).aspx
    http://technet.microsoft.com/en-us/library/ee692768.aspx

[x] tos(),pop(),push() can be used in forth code directly but not VBS code.
    Unless jeforth.hta introduces them to global. Let's do it ..... done!
	Now we can use them directly in <vb> sections.
	
[x]	玩 self 或 window object 時，發現新大陸！ window.prompt() 本來就有，可以用來
	收 input line !! 所以 prompt = 'OK ' 要改名成 kvmPrompt. ==> 3hta, 3nw both done. hcchen5600 2014/07/03 10:41:56 
	
	在 jeforth console 下，用 JavaScript 的 self 就可以看到這些東西。我覺得這時
	的 self 應該是 kvm 但其實是 window。搞不懂！

	OK js> self obj>keys .           \  ----- 3HTA -----
	Refer to MSDN @ http://msdn.microsoft.com/en-us/library/ie/ms535873(v=vs.85).aspx
	
	 $, jQuery, kvm, WshShell, document, styleMedia, clientInformation, 
	clipboardData, closed, defaultStatus, event, external, 
	maxConnectionsPerServer, offscreenBuffering, onfocusin, onfocusout, 
	onhelp, onmouseenter, onmouseleave, screenLeft, screenTop, status, 
	innerHeight, innerWidth, outerHeight, outerWidth, pageXOf fset, 
	pageYOffset, screen, screenX, screenY, frameElement, frames, history, 
	leng th, location, name, navigator, onabort, onafterprint, 
	onbeforeprint, onbeforeun load, onblur, oncanplay, oncanplaythrough, 
	onchange, onclick, oncontextmenu, on dblclick, ondrag, ondragend, 
	ondragenter, ondragleave, ondragover, ondragstart , ondrop, 
	ondurationchange, onemptied, onended, onerror, onfocus, onhashchange, 
	oninput, onkeydown, onkeypress, onkeyup, onload, onloadeddata, 
	onloadedmetadat a, onloadstart, onmessage, onmousedown, onmousemove, 
	onmouseout, onmouseover, o nmouseup, onmousewheel, onoffline, ononline, 
	onpause, onplay, onplaying, onprog ress, onratechange, 
	onreadystatechange, onreset, onresize, onscroll, onseeked, onseeking, 
	onselect, onstalled, onstorage, onsubmit, onsuspend, ontimeupdate, o 
	nunload, onvolumechange, onwaiting, opener, parent, self, top, window, 
	localStor age, performance, sessionStorage, addEventListener, 
	dispatchEvent, removeEven tListener, attachEvent, detachEvent, 
	createPopup, execScript, item, moveBy, mov eTo, msWriteProfilerMark, 
	navigate, resizeBy, resizeTo, showHelp, showModeless Dialog, 
	toStaticHTML, scroll, scrollBy, scrollTo, getComputedStyle, alert, blur 
	, close, confirm, focus, getSelection, open, postMessage, print, prompt, 
	showModa lDialog, toString, clearInterval, clearTimeout, setInterval, 
	setTimeout OK 

	OK js> self .s
      0: [object Window] (object)  <------------ 果然是 window object !

	用 ~.3nw 也看看 . . . 

	OK js> self .
	[object Window]   <------------ 確定是 window object !
	OK js> self js> window = .
	true   <------------ 再次確定是 window object !  ~.3hta 結果也一樣。

	OK  js> self obj>keys .           \  ----- 3nw -----
	top, window, location, nwDispatcher, Intl, v8Intl, document, global, 
	process, Buffer, root, require, $, jQuery, kvm, gui, revision, debug, 
	indebug, fs, screenbuffer, print, prompt, tabcompletion, keyboard, 
	forthConsoleHandler, base, stackwas, jQuery11020015018620295450091, 
	path, __nwWindowId, win, speechSynthesis, webkitNotifications, 
	localStorage, sessionStorage, applicationCache, webkitStorageInfo, 
	indexedDB, webkitIndexedDB, crypto, CSS, performance, console, 
	devicePixelRatio, styleMedia, parent, opener, frames, self, 
	defaultstatus, defaultStatus, status, name, length, closed, pageYOffset, 
	pageXOffset, scrollY, scrollX, screenTop, screenLeft, screenY, screenX, 
	innerWidth, innerHeight, outerWidth, outerHeight, offscreenBuffering, 
	frameElement, clientInformation, navigator, toolbar, statusbar, 
	scrollbars, personalbar, menubar, locationbar, history, screen, 
	postMessage, close, blur, focus, ondeviceorientation, ontouchcancel, 
	ontouchend, ontouchmove, ontouchstart, ontransitionend, 
	onwebkittransitionend, onwebkitanimationstart, 
	onwebkitanimationiteration, onwebkitanimationend, onsearch, onreset, 
	onwaiting, onvolumechange, onunload, ontimeupdate, onsuspend, onsubmit, 
	onstorage, onstalled, onselect, onseeking, onseeked, onscroll, onresize, 
	onratechange, onprogress, onpopstate, onplaying, onplay, onpause, 
	onpageshow, onpagehide, ononline, onoffline, onmousewheel, onmouseup, 
	onmouseover, onmouseout, onmousemove, onmousedown, onmessage, 
	onloadstart, onloadedmetadata, onloadeddata, onload, onkeyup, 
	onkeypress, onkeydown, oninvalid, oninput, onhashchange, onfocus, 
	onerror, onended, onemptied, ondurationchange, ondrop, ondragstart, 
	ondragover, ondragleave, ondragenter, ondragend, ondrag, ondblclick, 
	oncontextmenu, onclick, onchange, oncanplaythrough, oncanplay, onblur, 
	onbeforeunload, onabort, getSelection, stop, open, showModalDialog, 
	alert, confirm, find, scrollBy, scrollTo, scroll, moveBy, moveTo, 
	resizeBy, resizeTo, matchMedia, setTimeout, clearTimeout, setInterval, 
	clearInterval, requestAnimationFrame, cancelAnimationFrame, 
	webkitRequestAnimationFrame, webkitCancelAnimationFrame, 
	webkitCancelRequestAnimationFrame, atob, btoa, addEventListener, 
	removeEventListener, getComputedStyle, getMatchedCSSRules, 
	webkitConvertPointFromPageToNode, webkitConvertPointFromNodeToPage, 
	dispatchEvent, webkitRequestFileSystem, webkitResolveLocalFileSystemURL, 
	openDatabase, TEMPORARY, PERSISTENT 

	js> document obj>keys .      \ -------- 3HTA ----------------
	doctype, documentElement, implementation, inputEncoding, xmlEncoding, 
	xmlStandalone, xmlVersion, styleSheets, defaultView, URL, activeElement, 
	alinkColor, all, anchors, applets, bgColor, body, characterSet, charset, 
	compatMode, cookie, defaultCharset, designMode, dir, domain, embeds, 
	fgColor, forms, head, images, lastModified, linkColor, links, location, 
	onabort, onblur, oncanplay, oncanplaythrough, onchange, onclick, 
	oncontextmenu, ondblclick, ondrag, ondragend, ondragenter, ondragleave, 
	ondragover, ondragstart, ondrop, ondurationchange, onemptied, onended, 
	onerror, onfocus, oninput, onkeydown, onkeypress, onkeyup, onload, 
	onloadeddata, onloadedmetadata, onloadstart, onmousedown, onmousemove, 
	onmouseout, onmouseover, onmouseup, onmousewheel, onpause, onplay, 
	onplaying, onprogress, onratechange, onreadystatechange, onreset, 
	onscroll, onseeked, onseeking, onselect, onstalled, onsubmit, onsuspend, 
	ontimeupdate, onvolumechange, onwaiting, plugins, readyState, referrer, 
	scripts, title, vlinkColor, URLUnencoded, compatible, documentMode, 
	frames, media, msCapsLockWarningOff, namespaces, onactivate, 
	onafterupdate, onbeforeactivate, onbeforedeactivate, onbeforeeditfocus, 
	onbeforeupdate, oncellchange, oncontrolselect, ondataavailable, 
	ondatasetchanged, ondatasetcomplete, ondeactivate, onerrorupdate, 
	onfocusin, onfocusout, onhelp, onmssitemodejumplistitemremoved, 
	onmsthumbnailclick, onpropertychange, onrowenter, onrowexit, 
	onrowsdelete, onrowsinserted, onselectionchange, onselectstart, onstop, 
	onstoragecommit, parentWindow, security, uniqueID, selection, 
	fileCreatedDate, fileModifiedDate, fileSize, fileUpdatedDate, mimeType, 
	nameProp, protocol, rootElement, adoptNode, createAttribute, 
	createAttributeNS, createCDATASection, createComment, 
	createDocumentFragment, createElement, createElementNS, 
	createProcessingInstruction, createTextNode, getElementById, 
	getElementsByTagName, getElementsByTagNameNS, importNode, createEvent, 
	createRange, createNodeIterator, createTreeWalker, elementFromPoint, 
	close, execCommand, getElementsByClassName, getElementsByName, 
	getSelection, hasFocus, open, queryCommandEnabled, queryCommandIndeterm, 
	queryCommandState, queryCommandSupported, queryCommandText, 
	queryCommandValue, write, writeln, attachEvent, detachEvent, 
	createEventObject, fireEvent, execCommandShowHelp, focus, 
	releaseCapture, updateSettings, createStyleSheet, removeNode, 
	replaceNode, swapNode, querySelector, querySelectorAll, attributes, 
	childNodes, firstChild, lastChild, localName, namespaceURI, nextSibling, 
	nodeName, nodeType, nodeValue, ownerDocument, parentNode, prefix, 
	previousSibling, textContent, addEventListener, dispatchEvent, 
	removeEventListener, appendChild, cloneNode, compareDocumentPosition, 
	hasAttributes, hasChildNodes, insertBefore, isDefaultNamespace, 
	isEqualNode, isSameNode, isSupported, lookupNamespaceURI, lookupPrefix, 
	normalize, removeChild, replaceChild, ATTRIBUTE_NODE, 
	CDATA_SECTION_NODE, COMMENT_NODE, DOCUMENT_FRAGMENT_NODE, DOCUMENT_NODE, 
	DOCUMENT_POSITION_CONTAINED_BY, DOCUMENT_POSITION_CONTAINS, 
	DOCUMENT_POSITION_DISCONNECTED, DOCUMENT_POSITION_FOLLOWING, 
	DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC, DOCUMENT_POSITION_PRECEDING, 
	DOCUMENT_TYPE_NODE, ELEMENT_NODE, ENTITY_NODE, ENTITY_REFERENCE_NODE, 
	NOTATION_NODE, PROCESSING_INSTRUCTION_NODE, TEXT_NODEOK 


	js: document.onmouseout=function(){alert(222)}  \ 靠！真的會在 mouse 移開時打 alert()
	js: document.onmouseout=null
	js: document.onmouseout=function(){fortheval('hi')} \ It works!!
	: test begin 80 for char * . 100 sleep next cr again ; \ 弄一個印 * 的 long run 程式。
	jeforth.hta inputbox 本身就是個最兇的 event 他會改 stack. 別的 event handler 都得負責恢復 stack.
	
[ ] Found a bug!! This bug is still in ~.3wsh and ~.3nw
    wsh.f run command reads the whole line as a command line. The old definition
	
		10 ASCII>char ( \n ) word (run)
	
	was a mistake. It should be 
	
		char \n|\r word (run) ; interpret-only 
		
	The first match of either \r or \n terminates the command line. This is important
	otherwise the extra \n may pollute the command line.
	
[x] To test 'run' command and siblings, I need to run command line therefore the parser is needed.
	Copy from ~.3nw, it's easy but not so easy. Recent approach is not good. I need to impove it.
	argv should neat at beginning.
	===> done! but there's a unexpected thing in stack [x] UI, tib.insert 吃到 empty stack 時會留下
	      undefined at TOS. This is a mistake. 解法是在原來 pop() 處改成 (pop()||"") 就不會在 stack
		  empty 時 pop() 成 'undefined'.
	==> Ok now, include wsh.f then "run jeforth.hta 123 bye" you get 123 at TOS, bingo!!!
	
[x] textarea cmd input has a problem. Press <enter> at middle of a string cuts the string <=== should not!
    then pass the string to fortheval. I guess keydown/keyup needs fine tune <=== Yes! done.
	Keycode 13 (Enter) handled in Keydown has fixed the problem.
	
[x] Now I am working on wsh.f and html5.f, the <input.file> element can be drop on jeforth.display 
	so how about other HTML elements? 
	==> Now I have <element> or <e> <input type=file /></e> , Bingo!!

[x] wsh.f (dir) selftest's print outs should be redirected to selftest.log if printing is necessary.

[x] docode() 裡面的 local variables 可以被 js> 看見！因為 JavaScript eval() 時，看得見。故 eval() 的
	時機不能再 docode() 裡面。有機會嗎？==> done!! hcchen5600 2014/07/12 20:51:19 

[x] 用 sendkey 時，不能是中文輸入法，如何禁用？ 似乎有解 http://bbs.csdn.net/topics/80079918
	js> $('#cmd').hide() 1000 sleep js> $('#cmd').show() 果然是他
	document.myform.text1.style.imeMode="disabled";  禁用輸入法的方法
	js> $('#cmd')[0].style.imeMode="disabled";
	js> $('#cmd')[0].style.imeMode="auto";
	js> $('#cmd')[0].style.imeMode="active";
	js> $('#cmd')[0].style.imeMode="inactive";
	<input type=text style="ime-mode: auto; "> 
	$('#cmd')[0].style.imeMode="disabled";  成功！！！
	能不能連 keyboard 都禁掉？
	==> 改用 clipboard 已經成功，不怕中文輸入模式。 hcchen5600 2014/07/12 20:27:46 

[x] jeforth.3hta 因為 input textarea 本身就是 multiple line 的，word 就是跨行的了！故我把 3nw 具有的
	text command 拿掉了。然而，還是有些 word 具有原始 forth 的跨行特性，例如 : ... ; 定義就是。但
	code ... end-code 不跨行。相較之下， jeforth.3nw 的 code ... end-code 是可跨行的。
	==> 就這樣吧！不管他了。

[ ] 又抓到一個 bug, jeforth.3nw still has the problem
	// keyboard.waiting = false; // jeforth.3nw 的 jeforth.js 裡有這種 platform dependent 的東西！不應該啊 []
	// term.set_prompt(prompt); // restore default jQuery-terminal prompt constant

[ ] Bug found: 
    keycode 13 時，keyup 清除 textarea 不對，當 EditMode=true 時就糗了。hcchen5600 2014/07/13 17:48:07 
	正在幫 vb.f 寫 selftest, 構想每個 word command 該怎麼測試。。。

[x] Shift-keys seem to be locked at start up. Back-space doesn't work. Check it out ...
	js> ShiftKeyDown . cr false
	js> CtrlKeyDown  . cr false
	js> AltKeyDown   . cr true <---------- I felt that too! Now why?
	==> 這是測 wsh.f selftest 用到 alt-F4 關 calc.exe 時留下來的。多 sendkeys 按一下 Alt key 即解。

[x] 玩一玩 HTA 下的 elements. 確定 name attribute 的用法，真的可以用點的，但很長。要攔腰命名以縮短之。

	js> document.body obj>keys .
	bgColor, background, noWrap, onafterprint, onbeforeprint, onbeforeunload, onblur,onerror, ... snip ...

	js> document.body.children.jeforth obj>keys .
	windowState,borderStyle,version,maximizeButton, ... snip ...

	js> $('outputbox') obj>keys .
	length, prevObject, context, selector, jquery, ... snip ...

	js> $('#outputbox').parent() .  \ 查看我寫的東西掛哪裡？
	[object Object] OK 
	js> $('#outputbox').parent()[0] .  \ 這個 element 是 jeforth 
	[object HTMLUnknownElement] OK 

	js> $('#outputbox').parent()[0].id . \ 整個頁面都屬 jeforth element
	jeforth OK 

	char Hello!!! .
	js> document.body.children.jeforth.children.outputbox.textContent .  \ outputbox 是 name attribute

	: jeforth js> document.body.children.jeforth.children ;     \ 攔腰給個名字，縮短 object chain.
	jeforth js: pop().outputbox.textContent="1111"           \ 真的可以！

	OK 
	js> $('#outputbox')[0] 
	js> document.body.children.jeforth.children.outputbox \ name attribute 可以這樣用，直接點。
	= .
	true OK 

	OK 
	js> $('outputbox')[0] \ 誤會了！此處的 name 不是 name='foo' 之類的 attribute 而是 tag name, like 'p' of <p>.
	js> document.body.children.jeforth.children.outputbox
	= .
	false OK 


	js: $('textarea')[0].textContent=123  \ 真的在輸入區中置入了 '123'

	true OK js> $("#outputbox")[0].id .  \ 這個參考法對 id 有效， id 要小寫。如下，對 name 無效。
	outputbox OK 
	js> $("#outputbox")[0].getAttribute("ID") . \ 這樣也可以。
	outputbox OK 

	jeforth OK js> $('#outputbox').parent()[0].getAttribute("id") 
	js> $('#outputbox').parent()[0].id = .
	true OK

	OK js> $("#outputbox")[0].name .  	\ name 不能用點的，只有 id 可以。
	undefined 
	OK js> $("#outputbox")[0].getAttribute("name") .  \ 要用 getAttribute()
	outputbox 
	OK js> $("#outputbox")[0].getAttribute("name") .
	outputbox OK 
	js> $("#outputbox")[0].name .
	undefined OK 

	js> $("#outputbox")[0].name . cr						\ undefined
	js> $("#outputbox")[0].getAttribute("name") . cr     \ outputbox
	js> $("#outputbox")[0].class . cr                    \ undefined     看來只有 id 可以直接點
	js> $("#outputbox")[0].getAttribute("class") . cr    \ outputbox

	用 jeforth.3nw 的 F12 debugger 輕易就把這玩意兒搞懂了
	OK <e> sdfsdfsd </e>
	OK js> document.body.children.outputbox.lastChild . ===> [object Text]
	OK js> document.body.children.outputbox.lastChild.data . ===> sdfsdfsd 
	OK js> document.body.children.outputbox.lastChild.baseURI . ===> file:///D:/hcchen/Dropbox/learnings/github/jeforth.3nw/index.html
	OK js> document.body.children.outputbox.lastChild.nodeName . ===> #text
	OK js> document.body.children.outputbox.lastChild.nodeType . ===> 3
	OK js> document.body.children.outputbox.lastChild.nodeValue . ===> sdfsdfsd 

	js: document.body.children.outputbox.lastChild.data="11223344"
	js> document.body.children.outputbox.lastChild.data . ===> 11223344

	看來是 jeforth.3hta 的問題，～.3nw 下 lastChild 跟 lastElementChild 是一樣的
	OK <e> <input type=file></e>
	OK js> document.body.children.outputbox.lastChild.nodeName . ===> INPUT
	OK js> document.body.children.outputbox.lastElementChild.nodeName . ===> INPUT

	js> document.body.children.jeforth.children.outputbox.lastChild.nodeName .
	js> document.body.children.jeforth.children.outputbox.lastChild.nodeValue .
	js> document.body.children.jeforth.children.outputbox.childNodes .s
	js> document.body.children.jeforth.children.outputbox.childNodes[1].nodeName .
	js> document.body.children.jeforth.children.outputbox.childNodes[1].nodeValue .

	來看看 jeforth.3hta 的 outputbox element 有哪些 members ?
	js> document.body.children.jeforth.children.outputbox obj>keys .
		align, noWrap, dataFld, dataFormatAs, dataSrc, currentStyle, runtimeStyle, 
		accessKey, className, contentEditable, dir, disabled, id, innerHTML, 
		isContentEditable, lang, offsetHeight, offsetLeft, offsetParent, offsetTop, 
		offsetWidth, onabort, onblur, oncanplay, oncanplaythrough, onchange, onclick, 
		oncontextmenu, ondblclick, ondrag, ondragend, ondragenter, ondragleave, 
		ondragover, ondragstart, ondrop, ondurationchange, onemptied, onended, 
		onerror, onfocus, oninput, onkeydown, onkeypress, onkeyup, onload, onloadeddata, 
		onloadedmetadata, onloadstart, onmousedown, onmousemove, onmouseout, 
		onmouseover, onmouseup, onmousewheel, onpause, onplay, onplaying, onprogress, 
		onratechange, onreadystatechange, onreset, onscroll, onseeked, onseeking, 
		onselect, onstalled, onsubmit, onsuspend, ontimeupdate, onvolumechange, 
		onwaiting, outerHTML, style, tabIndex, title, all, behaviorUrns, canHaveChildren, 
		canHaveHTML, children, document, filters, hideFocus, innerText, isDisabled, 
		isMultiLine, isTextEdit, language, onactivate, onafterupdate, onbeforeactivate, 
		onbeforecopy, onbeforecut, onbeforedeactivate, onbeforeeditfocus, onbeforepaste, 
		onbeforeupdate, oncellchange, oncontrolselect, oncopy, oncut, ondataavailable, 
		ondatasetchanged, ondatasetcomplete, ondeactivate, onerrorupdate, onfilterchange, 
		onfocusin, onfocusout, onhelp, onlayoutcomplete, onlosecapture, onmouseenter, 
		onmouseleave, onmove, onmoveend, onmovestart, onpaste, onpropertychange, onresize, 
		onresizeend, onresizestart, onrowenter, onrowexit, onrowsdelete, onrowsinserted, 
		onselectstart, outerText, parentElement, parentTextEdit, readyState, recordNumber, 
		scopeName, sourceIndex, tagUrn, uniqueID, uniqueNumber, blur, click, focus, 
		getElementsByClassName, insertAdjacentHTML, scrollIntoView, componentFromPoint, 
		doScroll, attachEvent, detachEvent, addBehavior, addFilter, applyElement, 
		clearAttributes, contains, dragDrop, getAdjacentText, insertAdjacentElement, 
		insertAdjacentText, mergeAttributes, releaseCapture, removeBehavior, removeFilter, 
		replaceAdjacentText, setActive, setCapture, createControlRange, removeNode, 
		replaceNode, 
		http://www.w3schools.com/jsref/tryit.asp?filename=tryjsref_node_replacechild
		swapNode, clientHeight, clientLeft, clientTop, clientWidth, scrollHeight, 
		scrollLeft, scrollTop, scrollWidth, tagName, childElementCount, firstElementChild, 
		lastElementChild, nextElementSibling, previousElementSibling, getAttribute, 
		getAttributeNS, getAttributeNode, getAttributeNodeNS, getBoundingClientRect, 
		getClientRects, getElementsByTagName, getElementsByTagNameNS, hasAttribute, 
		hasAttributeNS, removeAttribute, removeAttributeNS, removeAttributeNode, setAttribute, 
		setAttributeNS, setAttributeNode, setAttributeNodeNS, fireEvent, msMatchesSelector, 
		querySelector, querySelectorAll, attributes, childNodes, firstChild, lastChild, 
		localName, namespaceURI, nextSibling, nodeName, nodeType, nodeValue, ownerDocument, 
		parentNode, prefix, previousSibling, textContent, addEventListener, dispatchEvent, 
		removeEventListener, appendChild, cloneNode, compareDocumentPosition, hasAttributes, 
		hasChildNodes, insertBefore, isDefaultNamespace, isEqualNode, isSameNode, isSupported, 
		lookupNamespaceURI, lookupPrefix, normalize, removeChild, replaceChild, ATTRIBUTE_NODE, 
		CDATA_SECTION_NODE, COMMENT_NODE, DOCUMENT_FRAGMENT_NODE, DOCUMENT_NODE, 
		DOCUMENT_POSITION_CONTAINED_BY, DOCUMENT_POSITION_CONTAINS, DOCUMENT_POSITION_DISCONNECTED, 
		DOCUMENT_POSITION_FOLLOWING, DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC, 
		DOCUMENT_POSITION_PRECEDING, DOCUMENT_TYPE_NODE, ELEMENT_NODE, ENTITY_NODE, 
		ENTITY_REFERENCE_NODE, NOTATION_NODE, PROCESSING_INSTRUCTION_NODE, TEXT_NODE OK 

[x] 亂定一堆 global variable 很令人不安，例如 kernelfso 等。 乾脆全部掛給 kvm 好過掛給 window ?
    jeforth.hta 裡就要做 closure 才對。
	==> 本來在 jeforth.hta 裡的東西都是 global, 加上 closure 之後都不是了！這樣對，但如何修改？
	    在 index.htm (即 jeforth.hta) 中變個 global object 出來，把所有屬 global 的東西都往裡倒。
		kvm.init() 時把 global 傳進去即可。 ====> Done!!! commit 一版。
		
	[17:18:26] h.c.chen: 請教問題。jeforth 最上層是 index.html , 裡頭 script include 進 jeforth.js . 
						我想把 index.html 裡的程式都 closure，以避免 global。這麼一來，要讓 jeforth.js 
						看得到 index.html 定義的東西有何建議？
						我現在想的是在 index.html 裡弄一個 global object 把要用到的東西全放裡面。
						kvm.init(global) 傳過去給 jeforth.js ，這樣 ok？
	[17:23:24] yap @ Forth: 建議用 browersify.js 或component.js
	[17:24:02] h.c.chen: 有幾分鐘可以接電話嗎？
	[17:25:39] h.c.chen: 我先看看 browserify.js 或component.js 謝謝！
	
[x]	js> window obj>keys . ==> kvm,tos,pop,push,base,stackwas,htaProcess,WshShell,f,document, ... 
	應該只有 kvm 其他都不要！
	[x] base ==> kvm.base 才對
	[x] stackwas 要仔細檢討
	[x] tos, pop, push 改 call kvm.tos(), 等.
	[x] htaProcess 改放 kvm.process, WshShell 保留在 window 裡。
	[x] f 根本是個錯誤，哪來的？ ==> 用到時忘了用 var f; 先定義成 local 所造成。
	最終，只有 kvm 與 WshShell 兩個 window global.
	
[x] something wrong on voc.f .... yeah, it's kernel. Well I will clarify it out.	
	==> 抓 \uedit-backup\ 舊版回來就好了。我想錯了， voc.f 不可能比照 vocabulary 慣例。
	
[x] 要不要改良 selftest.f 裡的 ****  ==>judge 讓 'pass', 'failed' 自動找到對的位置顯示？

[x] ." 是 compile-only 有必要嗎？ wmi.f 裡用了一堆 ==> 變成 dual mode 了

[x] <e> 拿到的 <input type=file /> element 是 [object Text] 好像不對。
	<e> 拿到的 <form> element 也是 [object Text]，不能用。
	==> 原因找到了！哈哈題。</e> 之前如果有空格就會傳回這個空格的 element 也就是 [object Text] 
		這沒錯，錯在 <input ...></e> 或 </form></e> 之間不該留空格。 或者該自動把 </e> 之前的空
		格消除！ ===> <e> 123   </e> <e> 456    </e> --> 123456 Bingo!!! 

[x] char excel.exe kill-them 殺不掉，大小寫？ ==> input must be a leagal where clause.

[x] 發現 Node-webkit 果然有用到 global 所以我的 global 要恢復成 kvm, 如此只用到 kvm 更好。

[x] selftest.log 也不全面，只有 jeforth.f 有在 save log 應該全面都 save log.

[x] Selftest 很長很長，怎麼樣知道已經做完了？應該自動 jump 到 inputbox. 
	js: kvm.scrollToElement($('#header')); 3000 sleep   \ this doesn't work
	js: kvm.scrollToElement($('#header')); 3000 freeze  \ this works

[x] 輸出叫做 outputbox 吧！(was outputscreen)
	輸入叫做 inputbox 吧！ (was cmd)

[x] <selftest> ... </selftest> are interpret-only

[x] forth macro 可以用 tib.insert 來做 <==== Yes! source-code-header is an example.
[x] include 可以自動幫 ~.f 檔加上 \ --EOF-- 結尾。 So ~.f file's header can be further simplified.
	看到 \s 或 \ --EOF-- 就自動把該處當成 EOF 切掉之後的部份。
	定義 source-code-header 為
	<text>
		?skip2 --EOF-- \ skip it if already included
		dup .( Including ) . cr char -- over over + + 
		js: tick('<selftest>').masterMarker=tos()+"selftest--";
		also forth definitions (marker) (vocabulary) 
		last execute definitions
		<selftest> 
			js> tick('<selftest>').masterMarker (marker)
			include kernel/selftest.f
		</selftest>
	</text> constant source-code-header
	tib.insert
	==> 一次成功！
	尾巴要自動完成。由 header 去找第一個 \\\s+--EOF-- , 後面切除，加上以下
	<selftest> 
	js> tick('<selftest>').masterMarker tib.insert
	js> kvm.screenbuffer char selftest.log writeTextFile \ save selftest log file
	</selftest>
	js> tick('<selftest>').enabled [if] js> tick('<selftest>').buffer tib.insert [then] 
	js: tick('<selftest>').buffer="" \ recycle the memory
	\ --EOF--

	試驗：
		tib.slice(ntib); ntib = 0;
		start-here <js> kvm.screenbuffer.indexOf("thernet",pop())!=-1 </jsV> \ true  Ethernet
		<js> ("aabbcc\tddeeff\n\\--EOF--   gg\\shhii").search(/\\\s*--EOF--|\\s/) </jsV> .
		<js> 
			var ss = "aabbcc\tddee\nff\\--EOF--   gg\\shhii";
			ss = (ss+" ").slice(0,ss.search(/\\\s*--EOF--|\\s/)); // 一開始多加一個 space 讓 search 結果 -1 時吃掉。
		</jsV> .	
	試驗成功，以下動作要在 include 裡做。 ss 是讀進來的整個 ~.f source code.
		<js> 
			ss = (ss+'x').slice(0,ss.search(/\\\s*--EOF--|\s\\s\s/)); // 一開始多加一個 'x' 讓 search 結果 -1 時吃掉。
			ss += "\\ --EOF--\n"; 
		</js>
	debug 的技巧
		<js> kvm.jsc.prompt="111";eval(kvm.jsc.xt); </js>   \ jsc breakpoint
		js: clipboardData.setData("text",tib.slice(ntib))         \ 利用 clipboard+notepad 來查看常內容

		<js> if(tos().indexOf("wmi.f")!=-1) window.xx=true;</js> 
		js> window.xx [if] *debug* jjj>>> [then]

[x]	writeTextFile 用來 save selftest.log 有時候會有問題，改用 writeBinaryFile 看看。。。
	==> modify ok, [x] test my desktop at home.

[x] jsc has been used in panic(). I need jsc for experiments. So, make it a command word.

[X] excle.f selftest not completed yet
	Including excel.f
	*** excel... pass
	*** excel.visible excel.invisible ... pass
	*** new... pass
	*** excel... pass
	*** excel... pass
	reDef WORKBOOK
	*** get-sheet gets worksheet object ... pass
	*** get-sheet gets worksheet object ... pass
	*** get-cell gets cell object ... pass
	*** cell@ cell! ... pass
[X] Bug found! selftest ***** treats any . as the end of the description! should be \.$

[x] jeforth.3hta starting greeting 看久了有一點煩，太干擾。簡化之。。。
[x] Don't allow long lines. use CSS3 "word-wrap:break-word"
[X] remove blank line and repeated line from cmdhistory 
[x] beeps when moves cmdhistory over the top or under the bottom.

[x] voc.f help is very poor. Improve it. Better not to show empty 
	vocabularies, pattern should accept white spaces.
[x] help shows word.comment but very poor. Use RegEx to indent comments.
	js> ("aaa\nbbb\nccc").replace(/^\s*/gm,"\t") .

[ ] 已經開著的 excel 如何控制？
	Try open some excel, try to see them then control them....
	==> int hwnd = (int)Process.GetProcessById(excelId).MainWindowHandle    http://stackoverflow.com/questions/770173/how-to-get-excel-instance-or-excel-instance-clsid-using-the-process-id
		This is for .NET not JavaScript.

[ ] Tab auto-complete
	
[X]	F2  toggle EditMode
	F9  shrink input box
	F10 enlarge input box
	F4 copy marked text into inputbox.
	
	study IE9 window.getSelection()
		: test 
			." Get 3 selections " cr
			1000 sleep 1 . 1000 sleep 2 . 1000 sleep 3 . 1000 sleep 4 . 1000 sleep 5 . js> getSelection().anchorNode cr
			1000 sleep 1 . 1000 sleep 2 . 1000 sleep 3 . 1000 sleep 4 . 1000 sleep 5 . js> getSelection().anchorNode cr
			1000 sleep 1 . 1000 sleep 2 . 1000 sleep 3 . 1000 sleep 4 . 1000 sleep 5 . js> getSelection().anchorNode cr
			." done !!" cr
		; last execute
	發現 getSelection() 取得的 object 只存在於 selection 還在時。
	
	Property		Description
	anchorNode		Returns the element or node that contains the start of the selection.
	anchorOffset	Retrieves the starting position of a selection that is relative to the anchorNode.
	focusNode		Retrieves the element or node that contains the end of a selection.
	focusOffset		Retrieves the end position of a selection that is relative to the focusNode.
	isCollapsed		Retrieves whether a selection is collapsed or empty.
					It's null when "true". 
	rangeCount		Returns the number of ranges in a selection
					It's always 1. I don't understand.
	
		variable selection 
		1000 sleep 1 . beep 
		1000 sleep 2 . beep 
		1000 sleep 3 . beep 
		1000 sleep 4 . beep 
		1000 sleep 5 . beep cr
		js> getSelection() selection !
		selection @ js> pop().anchorNode      constant anchorNode
		selection @ js> pop().anchorOffset	  constant anchorOffset	
		selection @ js> pop().focusNode		  constant focusNode		
		selection @ js> pop().focusOffset	  constant focusOffset	
		selection @ js> pop().isCollapsed	  constant isCollapsed	
		selection @ js> pop().rangeCount	  constant rangeCount	
		<e> <H3>Done!!</H3></e> drop beep
		
	Mark 區域是 
	code {F4}	( -- ) \ Copy marked string into inputbox
		var selection = getSelection();
		var start, end;
		if (selection.isCollapsed) return; // Nothing selected
		if (selection.anchorNode==selection.focusNode) {
			start = Math.min(selection.anchorOffset,selection.focusOffset);
			end   = Math.max(selection.anchorOffset,selection.focusOffset);
		} else {
			start = selection.anchorOffset;
			end   = selection.anchorNode.data.length;
		}
		var ss = selection.anchorNode.data.slice(start,end);
		document.getElementById("inputbox").value += ss;
		$('#inputbox').focus();
		end-code
[x]	dot . prints things, some objects are not printable that triggers an error:
	Error msg: JavaScript error on word "." : Object doesn't support this property or method
	從 dot . 下手有成功，但是不完整。應該要從 print() and see() 下手才會完整。
	===> much better now!
	try :   s" where name like 'chrome%'" get-them .s
	
[x] "save" command to save definitions to jeforth.JSON to speed up the starting up time.
	==> They may be objects in dictionary, so no way!!
	
[x] remove ^\s* from cmdhistory.

[x] include , sinclude redefined in wsh.f so as to auto-search the source code file.
	if forth gets the higher priority over wsh.f in vocabulary order then older definitions
	will be taking the effects. The correct solution is not bringing wsh.f into kernel but
	simply to use the 'definition' vocabulary command to redefine special words into the 'forth'
	vocabulary. Thus even the forth word-list has higher priority than wsh.f the older 
	include/sinclude commands won't be unexpectedly used.
	==> Test, what happen after forget to --wsh.f-- marker? .... new words will be forgotten.

[x] Hotkey F10 needs two press to make one effect. Try to print 'F10' at beginning of the handler
	sees the same thing <==== check again.
	==> Now I am sure, root cause is the focus has gone to HTA's menu bar due to F10.
	    Under a condition, F10 can disable by this way ==> (https://www.evernote.com/shard/s22/sh/205fe9d0-4c7f-41db-a33a-98aacbc91a01/39cc5075538a71b51d150c24af8b9663)
	    , must be document.onkeydown not .onkeypress. So as to take over the control.
	
[x] Hotkey handler should not be in input box. Because input box will be hide when rows <= 0 therefore
	no way to get focus and then no way to get it back.
	
[x] Source code file should not use "UTF-8 file with BOM" format, 
	jsc>stack[0].charCodeAt(0) ==> 22172  (number)
	jsc>stack[0].charCodeAt(1) ==> 29854  (number)
	As shown above, leading bytes become problem.

[x] jsc support Esc as the 'q' command equivlant.
	
[x] see kvm.fso	==> JavaScript error on word "(see)" : Object doesn't support this property or method
    ==> RI: print(tab + dictionary[i] + ...) 時，某些 object 沒有 .toString() 無法做 + operation.
	==> 應該幫所有不具 toString() method 的 object 都加上 toString()。 <=== Not allowed!
	e.g. kvm.fso.FolderExists() is a method in fso. 但用 jsc 去檢查 kvm.fso.FolderExists 結果是 undefined!
	所有未知的 object 真不知道該怎麼 see ??? [ ] 
[x] Constant() 能不能也屬於 Word()? 一致，且 see() 較簡單。 ==> 不 merge, 但一併考慮。
[x]	dump, see, dot, print 功能重複，疊床架屋 ==> 慢慢適應吧！

[x] subFolders helps redefine sinclude and include ... failed!
	ha ha bug.
	
[x] help without pattern prints hotkey helps.
	
[x] jsc improve the prompt(), use last command line to be the default.

[x] {backSpace} erace last outputbox, {F2} improved.

[x] define 'value' command and is,to,..etc corresponding commands.

[ ] Output box 2 and input box 2, dual pannel like Norton commander.

[x] List elements of outputbox. 
    []nodes ( ele n -- array ) Beginning n nodes of the element
	nodes[] ( ele n -- array ) Ending n nodes of the element

[x] mimic processing.js, setup an environment. Say canvas.f, setup{} and draw{}
    So that we'll be familiar with canvas programming and go on completing the clock.
    Study clock.f first... Done! see p5.f, clock3.f
    	
[x] 用了那麼多 kvm.var 能不能利用 eval() & arguments.callee 來隨時增加 vm 內部的 global variable?
	==> No way.

[ ] {backSpace} 的 bottom up 跟 top down 程式都類似，可以再簡化。	

[x] Now jeforth.3hta default is float instead of integer. Try input 123.456 .s and 0x7fffff .s 
    This is for HTML5 canvas.

[x] words and help need options, 
	-n for matching only name pattern, case insensitive.
	-N for exactly name only, case sensitive.
	-v for matching vocabulary, case insensitive.
	===> jeforth.f (words) [x] debug version, Add one more input 'option' to (words)
	===> modify voc.f to distinguish options. 
	
[x] Other than <element> we need a <h> command to generate header element.
	==> <o></o> for ouputbox, <h></h> for head, element <e></e> append to the element
	==> done! now go back to complete the clock.f improvement.
[x] Stop F2 hotkey to change the textarea size				
[x] canvas.f better to put the canvas below the inputbox textarea, easier to see it all the time.
[x] Re-write clock2.f with an strong arm of canvas.f				
[x] Different textarea background color for different EditModes. Modify the style in jeforth.hta
	==> review how do I modify canvas style in canvas.f --> simply modify ele.innerHTML 
	==> try to view jeforth.hta style --> id=style ok --> js> style obj>keys . ok 
	==> style element is just like other elements having all those object members.
		The problem is all 3 sections (body, textarea:focus, and textarea) are in the same style element.
		If I only want to modify one, how to do that? 
		[x] Create a new style in <h></h> may work. ==> No. 
		[x] Try modify 'style' itself. --> Bingo!!
			<text>
				body {
					font-family: courier new;
					font-size: 20px;
					padding:20px;
					word-wrap:break-word;
					border: 1px ridge;
					background:#F0F0F0;
				}
				textarea {
					font-family: courier new;
					color:black;
					font-size: 20px;
					width:100%;
					border: 0px solid;
					background:#BBBBBB;
				}
				textarea:focus {
					border: 0px solid;
					background:#FFE0E0; Pink or #F0E0E0; Gray
				}
			</text> js> style.innerHTML=pop()		
		[x] Try to make a new style to modify only textarea:focus --> Failed
			<h> <style id=newStyle type="text/css"></style></h> drop
			<text>
				textarea:focus {
					border: 0px solid;
					background:#E0F0E0;
				}
			</text> js> newStyle.innerHTML=pop()
		[x] A separate style in jeforth.hta for textarea:focus --> ok!
[ ] 應該把 jeforth.3wsh jeforth.3hta jeforth.3nd jeforth.3nw jeforth.3htm 五套融合成一套，共享所有的 .f 檔。
[ ] canvas.f works on kvm.cv is good, so we can work on many CV's. 
	But it needs an assignment process, instead of being the default only one.
[ ] Reviewed Processing.js, try to go through "~\Dropbox\learnings\processing\Pomax's guide to Processing.js.pdf" 
	practice on jeforth.hta --> working on playground\p5.f
[ ] html5.f does not have self-test yet. </e> was wrong when in compiling mode, now fixed.
[x] To support multiple canvas, clock2.f timeout() needs fine tune.
[ ] see 把 canvas object 都鑽進去印出來，太多了當掉。
[x] clock3.f seems ok, but only the last clock can run. 
	By my debugging logic, make a simplified case to try. 
    : hi me ." Hello " js> setTimeout(pop().xt,1000) . space ; last execute
    Hello 141  OK Hello 142  Hello 143  Hello 144  Hello 145  \ 這個OK 
    : wo me ." world!" js> setTimeout(pop().xt,1000) . space ; \ 才剛定義好新的 word 不論 colon word 或 code word
    world!376 world!377 world!378 world!379 world!380 . . . \ 都會變成下一個 timeout 被執行的對象！
	' wo ' hi  js> pop().xt=pop().xt \ 如果以為是 xt 的問題，錯！ colon word 的 xt 即使是同一個一切依然
	連新定義出來的 code word 也會被 timeout 到，這就是線索了!
	不要懷疑 timeout 收到的 function. 成功過就對了。 奇怪的是，為何總是執行最後一個 word 的 xt ?
	直接定義一個 ' hi timeout(pop().xt,1000) 來試呀! 果然複製出問題了。結論是 colon word 的 xt 如果
	這樣執行 ' hi js> pop().xt() 就沒問題，因為參考到的正是 colon word object 本身無誤。如果 
	' hi js> pop().xt execute 這樣執行就令人困惑了。困惑不如實測證實，
	code tt11 print("he he he 112233") end-code \ 故意弄一個 code word 當成 last
	js> inner(this.cfa) \ 直接執行 colon word 之 xt 裡的這行
    he he he 112233 OK  \ 果然就是這樣！
	結論是 colon word 的 xt 不能用來當 call back function 用。這下問題來了，colon word 有 recentcolonword
	可以取得本身的 object 那麼 code word 呢？抄 recentcolonword 的定義即可，這表示 code word 的自身 object
	就是 this. 實驗看看：
	code ttestt push(this) end-code ttestt . ==> 果然無誤 Bingo!
	進一步弄成利用 timeout 重複執行的 code word,
	code rr print(Date()); setTimeout(this.xt,1000) end-code 執行後，第一個 timeout 有印出 Date() 但是
	隨後的 setTimeout() 造成 run time error 'invalid argument'. 我怕是其中的 this 到時候變成別的東西，沒
	有 xt 造成 error 凸顯問題反而是好事。嘗試從 JavaScript 的 recursive 裡找答案 ==> arguments.callee
	code rr print(Date()); setTimeout(arguments.callee,1000) end-code ==> 徹底成功了！！！
	[x] ==> 這下子，clock3.f 的 '時鐘' 產生的 colon word 要如何包裝成 function() 來當 call back function?
	==> colon words can be executed by inner(cfa), thus 
		code t inner(2730);setTimeout(arguments.callee,1000) end-code last execute
		can launch the clock correctly. Where 2730 is Taipei's cfa.
		==> 取得 colon word 本身的 cfa 有兩法 
			1）colon word 裡一見面 me/recentcolonword js> pop().cfa 即是
			2）colon word 裡一見面 js> ip 2- 也是
			前者若是由 call-back-function 透過 inner() 發動的，就會出錯！！！ [ ] 實驗看看。可能 recentcolonword 要另想更好的辦法。
	==> -1 時鐘 tokyo
		' tokyo js> pop().cfa dump
		02739: 2693 (number)
		02740: -3600000 (number)
		... snip ...
		code t2 inner(2739);setTimeout(arguments.callee,1000) end-code last execute
		成功地 run 出第二個時鐘了！
[ ]	The jeforth.js global variable 'context' is useless. When no vocabulary, context is 'forth'.
	When with vocabulary, forth get-context command replaces the old context command. So why do we 
	have the 'context' command? ===> ask FigTaiwan
[ ] current_word_list() defined in jeforth.js 應該是為了嫌 words[current] 有點 proprietary 而設。
	實際上 words[current] 還是有在用，那何必有 current_word_list()? 乾脆取消。
[x] new Word() 馬上會把 new word 加進 wordhash{}，這無可厚非沒什麼不對。萬一 colon definition 失敗
	words[current].pop() 把 last 丟掉之後，只能 rescan-word-hash 才能恢復 reDef 被蓋掉的 original.
[x]	取得 colon word 本身的 cfa 有兩法 
	1）colon word 裡一見面 me/recentcolonword js> pop().cfa 即是
	2）colon word 裡一見面 js> ip 2- 也是
	前者若是由 call-back-function 透過 inner() 發動的，就會出錯！！！
	[x] 實驗看看。可能 recentcolonword 要另想更好的辦法。==> the two statements 
			push(newname); execute("(create)"); 
		in ';' definition should be moved to ':' , so we have last() in colon definition.
		To drop the last use words[current].pop() when something wrong. words[current].pop() 
		把 last 丟掉之後，只能 rescan-word-hash 才能恢復 reDef 被蓋掉的 original.
	--> try :: and ;; 
	==> 要用 last 取得 colon word 自身時，要注意 last 必須 immediate! 
		正確寫法是 :: myself [ last ] literal ;; 
	==> [x] 基本上 ok 但是過不了 selftest, selftest 好耶！
			問題出在 sinclude 的定義裡會用到原來的 sinclude, 此時新定義的 sinclude 已經在 wordhash
			裡取代了，故造成無窮迴路。
	==> 所以，一直以來 new Word() 直接把 newword 加進 wordhash 的作法有問題。要讓 ; 來做此事。
		See ebook <<Moving Forth>> @ https://www.evernote.com/shard/s22/nl/2472143/e572d6b8-8e2c-44bf-8d9b-e916ac0f9a2c
		有提到此事，果然就是用舊版 word 定義新版時、或者 recurse 時會碰到的問題。傳統 forth 用 hide 
		reveal 這一對開關來解決。我的 jeforth 不直接從 words[] 裡找 word 而是用 wordhash hash table,
		故控制 new word 加進 wordhash 的時機也是一樣的效果。
	==> 改掉 Word() 不要自動加 newname 進 wordhash, 增加新 command 'reveal' 用來把 newname 加進
		wordhash. ==> done!
	==> 原來用到 recentcolonword 的地方都找出來改掉

[x]	jeforth.f has a problem "如果不 writeBinaryFile [x] 好像 wmi.f 會有 error ????"
	that made me to use writeBinaryFile command which is not defined yet in jeforth.f
	==> jeforth.hta used to use fso, but fso doesn't support utf-8, ANSI only. My souce code and 
		actual printed strings were having utf-8. bla bla bla, that's the problem.
		Fixed by using ADO that supports utf-8.

[x] 大目標！改寫 jsEval jsEvalNo ([x] jsEvalRaw is useless) 讓他們在 compiling mode 時直接 compile 成
	function("jsEvalNo") 或 function(jsEval;push(lastStatement))。靈感來自 p5.f 裡的 call back function.
		: processing ( -- ) \ Processing main loop
			[ s" push(function(){inner(" js> last().cfa + s" )})" + jsEvalNo ] literal ( -- callBackFunction )
			frameInterval [ s" push(function(){setTimeout(pop(1),pop())})" jsEvalNo , ]
			frameCount 1+ to frameCount draw
		; last execute
	其中有取得 call back function 放在 TOS 的範例，以及直接 compile 一個 function 的範例。
	==> This regEx works fine : s" aaaaa;bbbb;ccc" js> pop().match(/^(.*;)(.*)$/) .
		Returns [entire string,fore part,last statement]
		Note 1. when there's no ';' the result is NULL. 
			 2. Nothing or only \s after the last ';' the result is [entire string,entire 
				string w/o ending \s,NULL] 此時用
			 3. normal "aaa;bbb;ccc"
		這樣狀況有種嫌太多了。
	==> 先把尾部的 ";\s*$" 消除。統一狀況。
		s" aaaaa;bbbb;ccc;;;      " js> "\n\t\r" + js> pop().replace(/;*(\s+)$/,'') .  \ the end
	==> 整合起來，最後只剩兩種狀況
		s"  aaa;bbb;ccc" js> "\n\t\r" + js> pop().replace(/;*(\s+)$/,'') js> pop().match(/^(.*;)(.*)$/) .	
		Note 1. when there's no previous ';' the result is NULL. ==> 整行抓去用
			 2. otherwise the result is [entire string,fore part,last statement]
		這樣簡單多了。

		: jsFunc ( "statements" -- function ) \ Compile JavaScript to a function() that returns last statement
			js> pop().replace(/^\s*/,'')
			js> pop().replace(/;*\s*$/,'') dup
			js> pop().match(/^(.*;)(.*)$/) ?dup \ statement [entire string,fore part,last statement]|NULL
			if \ statement [entire string,fore part,last statement]
				nip
				s" push(function(){" js> tos(1)[1] +
				s" push(" + js> pop(1)[2] + s" )" +
				s" })" +
				jsEvalNo
			else \ statement
				s" push(function(){push(" swap + s" )})" +
				jsEvalNo
			then ;
				
		: jsFuncNo ( "statements" -- function ) \ Compile JavaScript to a function()
				s" push(function(){" swap + s" })" + jsEvalNo ;

	[x] jsEval jsEvalNo 保留不改，新增命令 jsFunc jsFuncNo。 先完成 jsFuncNo
		( "js statements" -- function ) 

[x] objRet in jeforth.f 還有用嗎？ ==> 有用。
[ ] 當 marker 是個 vocabulary 時，順便 previous 把多出來的 forth drop 掉。
	==> 改 voc.f (marker) 應該很簡單。Selftest 的測法可能造成問題。
	==> 改 --filename.f-- 的定義才對。只有 --filename.f-- 這類 marker 才可以做 previous。

[x] merge.f 的「對話表」可以一次全部印出來。HTML 可以回頭補任意位置的內容，只要在
	資料不全時把 [Go!] 灰掉即可。
[x] Working on playground/merge2.f ==> Done!!
[x] Merge.f 很好用。其他 excel 的程式也該 port 到 jeforth.3hta 來！
	==> 拆分混合個部門的總表成多個 Excel 檔。===> split.f done!!

[ ]	Very very strange thing:
	jsc>kvm.dictionary
	Oooops! Object doesn't support this property or method	
	jsc>kvm.stack
	Oooops! Object doesn't support this property or method	
	===> 又是 see 的問題，嘗試顯示出來時失敗的現象。
	
	
-------------- jeforth for node.js console mode ----------------------

[x]	jeforth.3we 就是這樣來的！
	我計畫讓 Windows 下所有的 jeforth.3xxx 都共享同樣的 source code , 如 jeforth.js, jeforth.f 等。
	node.js 版的 jeforth.js 有這行,
		exports.constructor = KsanaVm;
	到時候是用 require() 讀進去的，希望 require 接受 string。我就可以用加的把這行加進去。
	==> 爽哥的 ~\multitaskjavascripteforth-master\jeForthVM.js 似乎有解，

			if (typeof exports==='undefined') window .jeForthVM=jeForthVM	// export for web cliend APP
			else exports.jeForthVM=jeForthVM	// export for node.js APP

		As shown above, node.js 'exports' is a system object not a 宣告指令。

[x] readTextFile is from jeforth.hta, needs to be defined in index.js

[x] bye is platform dependent. Needs kvm.bye()
	code bye ( ERRORLEVEL -- ) \ Exit to shell with TOS as the ERRORLEVEL.
		var errorlevel = pop();
		errorlevel = typeof(errorlevel)=='number' ? errorlevel : 0;
		kvm.bye(errorlevel);
	end-code

[x] 這個要想一想。定樣在 jeforth.hta 中的 kvm 是個 global 可以反過來在 jeforth.js 裡看得見。
	但是定義在 node.js 的 index.js 裡的 kvm, fs 等則不然。既然 kvm 跟 KsanaVm() 裡面參考自己的
	vm 是同一個，何不在 jeforth.js 裡直接就稱為 kvm？如果還是照以前稱為 vm 就得像下面這般繁複地
	補救。
		function KsanaVm() {
			var vm = this; // "this" is very confusing to me. Now I am sure 'vm' is 'kvm'.
			if(typeof(kvm)=="undefined"){var kvm=vm} // kvm defined in jeforth.hta is visible but not node.js index.js
		...snip....
	稱為 vm 目的可能是想跑 multiple VM. 這點我看是不會發生了。但讓 global 的 kvm 跟 closure 裡的 kvm 
	同名，也有點令人不安。繁複就繁複吧！
[x] Word.help 尾巴都有個 \r\n 要拿掉。
	OK ' + js> pop().help
	OK .s
		 0: + ( a b -- a+b) Add two numbers or concatenate two strings.
	(string)  <=== This is the clue of that there's something like \r\n at the end
	> dup binary-string>array <=== defined in 80286asm.f, useful here.
	 OK .s
		  0: + ( a b -- a+b) Add two numbers or concatenate two strings.
	 (string)
		  1: 43,32,40,32,97,32,98,32,45,45,32,97,43,98,41,32,65,100,100,32,116,119,111,32,110,117,109,98,101,114,115,32,111,
	114,32,99,111,110,99,97,116,101,110,97,116,101,32,116,119,111,32,115,116,114,105,110,103,115,46,13 (array)
	 OK
	==> The ending is a \r (13) , remove it ! jeforth.js I guess.

[x] nexttoken('RegEx string') escape string and RegEd work together can be a little strange. 
    Sometimes simply JS escape string works fine like :  nexttoken('\r|\n')
	Sometimes we need to double the back slash like : nexttoken('\\)\\)')
	Because what we want from the front one is '#13','|','#10' and it works fine.
	Yet we want from the rear one is literally '\)\)' which can not be 
	nexttoken('))') nor nexttoken('\)\)').

[ ] vb.f 有了現在的 html5.f 可以改寫得更好。

[x] 讓 include 自動找目錄，不用等到 wsh.f ==> readTextFileAuto ( "pathname" -- file ) \ Search and read
	==> Use kvm.path=[...] to specify path space and the order.

[ ] Ask FigTaiwan 請教先進。 jeforth 有這個問題。
	發現一個 jeforth 的大大大問題。 exit 用來結束一個 colon word, 但是 exit 用在 for..next 裡面時
	就不一樣了！要先 r> drop 才行吧？！ ==> Yes!!!

[x] execute ( cmd -- ... ) command 針對 cmd==string 時，要順便把前後的 \s 去掉。

[x] ~\jeforth.3hta\playground\86ef202.f compile 出來，跑不起來。要重視原因！
	==> 懷疑是用 writeTextFile 有問題，checksum 其實一樣。
		d:\hcchen\Dropbox\learnings\github\jeforth.3hta>d:\Download\BATCH\SUM.EXE eforth.com
		 This program was written by Eddy Chuang 1991.
		 -- The checksum of file:eforth.com is '20633D' on base 16 --
		d:\hcchen\Dropbox\LEARNI~1\github\JEFORT~1.3HT>

		target-space 0x100 DICSIZE array-slice
		<js> var sum=0; for( var i=0; i<12032; i++) {sum+=tos()[i]}; sum</jsV> 
		1:     2122557      20633dh (number)
	==> 接下來用 symdeb.exe 檢查了。。。 --> COLD1: entry should be 1097h ( "see COLD1:" command )
		but symdeb traced it's 1200h
	==> 看到原因了！本來 (create) 現在要改成 (create) reveal !!!
		
[x] include 80286asm.f 很奇怪，新舊版會夾雜的感覺。Source code 怎麼改都無效。總是 include 到舊版的！
	==> Run jeforth.hta new session then OK.
	
[x] The method 86ef202.f writes file to eforth.com needs think twice.
    Node.js and nw can use writeTextFile, but I guess not on HTA.
	==> The reason why 3nd can use it is Node.js' global class Buffer(). It handles binary data.
		So this project is 3nd and 3nw dependent!

[x] Many other .f files should be moved to hta/ They are all HTA dependent.
	==> Every platform has its own kvm.path space now.
[x]	readTextFileAuto 自帶 platform dependent 的 path array, 不好。
	應該有個 kvm.path 在 jeforth.3nd.js jeforth.html jeforth.hta 中定義好來，這樣才對。
	==>	3hta, 3nw, 3nd, 3wsh, 3htm 意外的好處是這些 platform folder 都是 3 開頭，自然會聚在一起。

[x] include 吃掉一整行，這樣並不好。 check the reason.
	==> RI, 因為 include test.f dsdf sfds 的 test.f 當中最後一行是 \ comment , 在 tib.insert 
		之後，這個 comment 延續到之後去，造成這個結果。
	==> 只要在 sinclude 裡，去掉 --EOF-- 之後，加一個 \n 到 file 最後即可。

[ ]	The leading two lines in jeforth.3nd.js, FigTaiwan acadamic topic.
		var z = require('./kernel/jeforth.js')
		var kvm = z.kvm;
	this means: the 'kvm' virtual machine object is and will be the only one. Older code was,
		var z = require('./kernel/jeforth.js')
		var kvm = new z.KsanaVm()  // get the jeForth VM
	which means KsanaVm() constructor can be used multiple times, I don't think so.
	
[x]	With selftest, 3nd can't show things after jeforth.f in the main .js
	==> Not "selftest-invisible" ---> try 1/2 sort.... Wow! strange. Post jeforth.f
		instructions are executed when at the first *** command in selftest !
	==> RI, because selftest '***' command uses 'sleep' command, that's why. Wow, jeforth
		is amazing. The 'sleep' command really suspend the VM.
		當初 1 sleep 是為了要讓 selftest message 一行行地印出來，不要突然一下全倒出來。
	==> 既然有 sleep, 表示我的 jeforth 裡 fortheval(jeforth.f) 這一行必須是最後一行。
		很重要的大發現！否則，它後面的東西會被意外執行到。
	==> So, the first OK prompt must be printed by jeforth.f not jeforth.3nd.js
	
[x]	jsc for 3node. ( demo to FigTaiwan )
	How to switch Node.js readline.on() ?
	==>	應該可以，但非置入式地（也必定是 blocking 的）方式，光切換 forth / jsc 也沒啥用了。
		jeforth.hta has alert(), prompt(), confirm() that are blocking functions.
		==> 利用 kvm.stdio.question() 做成 macro kvm.jsc.xt 置入式地應用可以了。但 readline
			is none-blocking, 結果還是沒有用。
	==>	找到辦法了！ http://stackoverflow.com/questions/3430939/node-js-readsync-from-stdin
		So now I have kvm.gets() which is a blocking function.

[ ]	jeforth.3nd can use kvm.gets() to support multiple line input!		

[x]	These two files,
		2014/10/15  17:01               448 jsc.hlp
		2014/10/15  17:00               733 jsc.js
	are not defined in jeforth.3nd.js directly because it's not convenient to define multiple
	line string, as far as I know. jsc.js will go to kvm.jsc.xt in text form so it will be a
	string too.
	
	If use <text> ... </text> to define kvm.jsc.help and kvm.jsc.xt then sure it's easy but 
	then platform.f is supposed to do that. Then kvm.jsc life cycle will be delaied. I want 
	jsc to be available earlier before jeforth.f.
		
[x]	Node.js 本身的 REPL 可以 'see' object 效果超好，怎麼應用？
	==> 那是 console.log() 的效果。 考慮 3nd 的 print() 裡面應該就用 console.log()
	
[ ]	FigTaiwan academic topic:
	o	jeforth can compile all function() into dictionary, instead of Word()'s. Hard to read the dictionary
		tho'. 
	o	jeforth can drop the inner() interpreter. Use functions unnest() next() like eforth.com 
		instead. 

[x] jeforth.3nd how to clear screen?
	kvm.clearScreen = function(){console.log('\033c')} 
	'\033c' or '\033[2J' 
	http://stackoverflow.com/questions/9006988/node-js-on-windows-how-to-clear-console

[x] jeforth.hta (jeforth.commandLine + " ").split(/\s+/).slice(0,-1); // An array, 這麼麻煩是為了要自動把行尾的 white spaces 去掉。
	should use .replace() <=== No! the result is expected to be an array. The above method is smart.
	
-------------- jeforth for HTML ----------------------  hcchen5600 2014/10/16 10:45:41 
[x]	一開始寫 jeforth.3htm 馬上發現當初 jeforth.3hta 的網頁結構可以更合理。
	[x] kvm.platform = "3hta"; 直接改成 ==> kvm.appname = "jeforth.3hta" 因為本來就有用到。
	[x] HTA:APPLICATION 設定裡的 ID 稱為 jeforth 並不好用。應該成為 hta 更好懂。

[ ] jeforth.hta 執行時的 working directory 當成 root folder. 這限制了它的用法。 
		c:\>node64 c:\Users\8304018.WKSCN\Dropbox\learnings\github\jeforth.3hta\jeforth.3nd.js
		fs.js:427
		  return binding.open(pathModule._makeLong(path), stringToFlags(flags), mode);
						 ^
		Error: ENOENT, no such file or directory 'c:\3nd\jsc.hlp' <========== Problem!
			at Object.fs.openSync (fs.js:427:18)	
		.... snip .....
			
	我的舊 jeforth.3nw 有解決過這個問題。

[ ] 有兩種 run jeforth.htm 的方法，透過 web server、從 local 直接 run. 看能不能兩種都 support?
	從 local 直接 run
	要解決 read data file 的問題，已經有解了。缺點是必須人工操作。
    https://www.evernote.com/shard/s22/nl/2472143/62b103ca-c162-48eb-99b3-eeecef88e2db	

	透過 web server 可能最合理。可用 Python one liner 當 server 很簡單。
		set path=c:\Program Files (x86)\OpenOffice 4\program; <== python.exe v2.7.5 is there
		python -m SimpleHTTPServer 8888
	"Anonymous Person" provided the iframe solution, as URL below. I tried, it works fine.
	http://stackoverflow.com/questions/12760852/how-to-access-plain-text-content-retrieved-via-script-type-text-plain-src 
	https://www.evernote.com/shard/s22/nl/2472143/f8a48817-933d-4681-a6bb-90eb10649fcd

[x]	用 iframe 的方式 include text file, extended filename can not be .f or it will be saved to 
	local disk directly. 暫時改名 jeforth.f==>jeforth.txt, voc.f==>voc.txt 
	Study ...
	
	The problem is similar to this page,
	"Bug 235363 - When opening a .php file inside of an <iframe> promts for download."
	https://bugzilla.mozilla.org/show_bug.cgi?id=235363.
	
	Set / Change MIME type of iFrame? ==> No way!
	http://stackoverflow.com/questions/12144554/set-change-mime-type-of-iframe.
	
	好像必須從 Web server 端解決這個問題，
	//设置输出文件类型为excel文件。 
            Response.ContentType = "application/ms-excel"; <============== Solution??
            Response.WriteFile(fileName);
            Response.Flush();
            Response.Close();
            Response.End();
	http://blog.163.com/zyc951018@126/blog/static/1397628992011111543924384/
	
	B i n g o !! This is my solution,
	http://stackoverflow.com/questions/12144554/set-change-mime-type-of-iframe/26420811#26420811
	
[x]	Don't use iframe, use $.get() instead
	jeforth.3htm, 
	iframe 抓進來的時間是個問題。 jQuery('iframe').load() 只解決第一個 iframe而已。可能寫法要改精確
	一點。我用最後一個來代替，有成功，如下。但這不可靠吧？
	jQuery('#html5f').load()

[ ]	bug! found in jeforth.f run by jeforth.3htm, when forth comment \ at end of a line then the
	next line will be eaten. ==> jeforth.hta 是因為 source code 用 ANSI Big5 可能對 JScript host 有問
	題。改用 ADO 讀 utf-8 source code 之後應該好了。

[x]	Start design readTextFile for 3htm. ==> 3htm/f/readtextfile.f
	: readTextFile	( "pathname" -- string ) \ "" if file not found
		js> pop().replace(/^\s*|\s*$/g,'') \ remove white spaces
		s" <iframe src='" swap + char ' + s"  hidden></iframe>" + </h> ( -- iframe )
		js: $(tos()).load(function(){execute('stopSleeping')}) 10000 sleep
		js> tos().contentDocument.body.lastChild.innerText
		swap removeElement ( -- string )
		js> tos().indexOf('404')!=-1 ( -- string 404? )
		<js> tos(1).toLowerCase().indexOf('not found')!=-1</jsV> ( -- string 404? notFound? )
		js> tos(2).length<100 ( -- string 404? notFound? length<100 )
		and and if drop "" then
		;
[x]	char f/mytools.f readTextFile <=== failed, still run to the old one!!
	cfa, creater, don't foget to replace xt too!!
[x] improve the jeforth.htm iframe ready sequence. This is the recent working version,
		// System initialization
		jQuery(document).ready(
			// jQuery convention, learned from W3School, make sure web page is ready.
			function() {
				jQuery('#readtextfilef').load(
					// for iframes, use load() instead of ready(). http://stackoverflow.com/questions/205087/jquery-ready-in-a-dynamically-inserted-iframe
					function() {
						$('#rev').html(kvm.version); // also .commandLine, .applicationName, ...
						$('#location').html(window.location.toString()); // it's built-in in DOM
						$('.appname').html(kvm.appname);
						document.onkeydown = hotKeyHandler; // Must be using onkeydown so as to grab the control.
						kvm.init();  // setup platform related I/O
						var kernel = jeforthf.contentDocument.body.lastChild.innerText;
						jeforthf.parentElement.removeChild(jeforthf); // suicide
						// jeforthf.contentDocument.body.lastChild.innerText=""; // 否則會不斷累積！不知是前後端哪一端的問題。
						kvm.fortheval(kernel);  // Run jeforth.f once. 
						// fortheval() 之後不能再有任何東西，否則因為有 sleep/suspend/resume 之故，會被意外執行到。
					}
				)
			}
		);
	下面這個方法 Chrome 下有時候會等不到！
		// System initialization
		jQuery(document).ready(
			// jQuery convention, learned from W3School, make sure web page is ready.
			function() {
				$('#rev').html(kvm.version); // also .commandLine, .applicationName, ...
				$('#location').html(window.location.toString()); // it's built-in in DOM
				$('.appname').html(kvm.appname);
				document.onkeydown = hotKeyHandler; // Must be using onkeydown so as to grab the control.
				kvm.init();
				jQuery('#jeforthf').load( // for iframes, use load() instead of ready(). http://stackoverflow.com/questions/205087/jquery-ready-in-a-dynamically-inserted-iframe
					function(){jQuery('#vocf').load(function(){jQuery('#selftestf').load(
					function(){jQuery('#html5f').load(function(){jQuery('#readtextfilef').load(
						function() {
							var jef = jeforthf.contentDocument.body.lastChild.innerText;
							var voc = vocf.contentDocument.body.lastChild.innerText;
							var rea = readtextfilef.contentDocument.body.lastChild.innerText;
							var htm = html5f.contentDocument.body.lastChild.innerText;
							jeforthf.parentElement.removeChild(jeforthf); // suicide 否則會不斷累積！
							vocf.parentElement.removeChild(vocf); // suicide
							readtextfilef.parentElement.removeChild(readtextfilef); // suicide
							html5f.parentElement.removeChild(html5f); // suicide
							kvm.fortheval(jef+voc+rea+htm);  // Run jeforth.f once. 
							// 之後不能再有任何東西，否則因為有 sleep/suspend/resume 之故，會被意外執行到。
						}
					)})})})}		
				)                   
			}                       
		);         
	改成這樣，還是會漏接：
		// System initialization
		var jef,voc,rea,htm,sel; jef=voc=rea=htm=sel="";
		jQuery('#jeforthf').load(
			function() {
				jef = jeforthf.contentDocument.body.lastChild.innerText;
				jeforthf.parentElement.removeChild(jeforthf); // suicide 否則會不斷累積！
			}
		);
		jQuery('#vocf').load(
			function() {
				voc = vocf.contentDocument.body.lastChild.innerText;
				vocf.parentElement.removeChild(vocf); // suicide 否則會不斷累積！
			}
		);
		jQuery('#selftestf').load(
			function() {
				sel = selftestf.contentDocument.body.lastChild.innerText;
				selftestf.parentElement.removeChild(selftestf); // suicide 否則會不斷累積！
			}
		);
		jQuery('#html5f').load(
			function() {
				htm = html5f.contentDocument.body.lastChild.innerText;
				html5f.parentElement.removeChild(html5f); // suicide 否則會不斷累積！
			}
		);
		jQuery('#readtextfilef').load(
			function() {
				rea = readtextfilef.contentDocument.body.lastChild.innerText;
				readtextfilef.parentElement.removeChild(readtextfilef); // suicide 否則會不斷累積！
			}
		);
		jQuery(document).ready(
			// jQuery convention, learned from W3School, make sure web page is ready.
			function() {
				$('#rev').html(kvm.version); // also .commandLine, .applicationName, ...
				$('#location').html(window.location.toString()); // it's built-in in DOM
				$('.appname').html(kvm.appname);
				document.onkeydown = hotKeyHandler; // Must be using onkeydown so as to grab the control.
				kvm.init();
				(function run(){
					if(sel&&jef&&voc&&htm&&rea){
						kvm.fortheval(jef+voc+htm+rea);  
						// 之後放東西要很小心，因為有 sleep 之故，會被意外執行到。
					} else setTimeout(run,100);
				})();
			}                       
		);                          
                 
[x]	想到一個技巧。JavaScript 常常撞上 Cannot read property 'x' of undefined ( or null )
	造成程式中斷。這可以用 && || 的特性來避免。
		: test js> kvm.a.b . space js> kvm.a.b . space ;
	執行 test ==> P A N I C ! JavaScript error on word "test" : Cannot read property 'b' of undefined
	改成以下寫法，run TSR 不會出錯終止程式,
		: TSR 100 for js> kvm.a&&kvm.a.b . space 1000 sleep next ;
	隨後再根據失敗的線索，回頭去定義 kvm.a 而非一失敗就終止程式。
	jeforth.hta 裡，讀取 iframe 很容易失敗，造成程式中止，
		jef = jeforthf.contentDocument.body.lastChild.innerText;
	改成
		jef = (jef=jeforthf.contentDocument.body.lastChild||"")&&jef.innerText;
	即可。

[x] iframe is a 旁門左道。好好的去讀 server 端的資料就好了呀！怎麼做？
	$.get('1.htm',"text") ==> The result is an object {readyState,getResponseHeader,getAllResponseHeaders,
	setRequestHeader,overrideMimeType,statusCode,abort,state,always,then,promise,pipe,done,fail,progress,
	complete,success,error,responseText,status,statusText}
	==> tos().responseText is the data
	==> tos().status ==> 200(c8h) or 404(194h) number, HTML status code
	Shit! so easy.
	==> It returns the object immediately. But the obj.status will be 'undefined' at first and become
		200 or 404 later.
	==> use $.get('1.htm',callback,"text") to get called back
	==> Shit! tos().status is not always there!
		Try f js> pop().state() . "resolved" or "pending"
		See this experiment,
			<js>
				var f = $.get("1.htm",'text');
				f
			</jsV> constant ff 
			ff js> pop().state() . space 1 sleep
			ff js> pop().state() . space 1 sleep 
			ff js> pop().state() . space 1 sleep
			ff js> pop().state() . space 1 sleep 
			ff js> pop().state() . space 1 sleep 
			ff js> pop().state() . space 1 sleep 
			==> pending OK pending resolved resolved resolved resolved
	[x]	$.get() 有 cache 的問題，在 IE 特別嚴重，根本不去讀新版！
		http://stackoverflow.com/questions/367786/prevent-caching-of-ajax-call
		http://stackoverflow.com/questions/10610034/jquery-get-caching-working-too-well
		I choose the global setting as my solution : $.ajaxSetup({cache:false})
		This issue is jeforth.3htm 特有的問題。改 3htm/readTextFile.f。
		
[ ]	The whole project's name jeforth.3WE three words engine

[x]	==> Root cause 出在用 fso 讀text不support utf-8, 所以 kernel jeforth.f 是用 ANSI Big5, IE 又出問題。
		改用 utf-8, jeforth.hta 不用 fso 改用 ADO 即可讀 utf-8, 皆大歡喜。
	jeforth.3htm has bug on IE 10.0.9. I should also try FF and Linux. 
	==> IE's debugger easily finds the growing words.forth stop at 'create'. Strange thing is
		tick('create') => 0 ! The last 3 words have the same problem. 
			roll . space compile create
		the . is dispeared, and tick later three gets 0. <=== problem.
	==> first colon word : space ... ; would replace the previous word . dot.
		The bug is in ; colon or ; semi-colon or reveal.
	==> IE debugger F12 is as good as Chrome's. 
			if(kvm.debug&&(kvm.debug=333)) debugger;
		But you need to enable by click the [Start Debugging]
		button. Instruction 'debugger' is also supported. --> something wrong in (create) , after
		(create) words.forth is still same <--- new word 'test' created by : test [ is expected.
		so everything supposed to go to last() goes to '.' !! <=== Cause !!
	==> Why current_word_list().push(new Word([newname,function(){}])) does not work?
		--> current_word_list().push(123) --> OK
		--> current_word_list().push(new Word(['tteesstt'])) --> OK
		--> single step trace : test 112233 ; ---> OK! strange???
		--> bp in ';' --> Proved the wrong last() happened before ';' <-- shoooo! good progress.
			should have created words.forth[109] for the new word : tst 112233 ; but didn't <--- problem!
		--> move bp earlier to where the new word is supposed to be created.
			yeah, it has happened after (create) --> move bp earlier into (create) --> very very strange
			finding! see below, the entire line before bp.11 is missing!!!!! because the previous comment
			is ended with chinese characters and thus it *eat* the next line, as shown below,

				newxt=function(){ /* (create) */
								if(!(newname=pop())) panic("Create what?\n", tib.length-ntib>100);
								if(isReDef(newname)) print("reDef "+newname+"\n"); // ?Y??tick(newname) ?N??                current_word_list().push(new Word([newname,function(){}]));
				if(kvm.debug&&(kvm.debug=11)) debugger;
								last().vid = current; // vocabulary ID
								last().wid = current_word_list().length-1; // word ID
								last().creater = ["code"];
								last().creater.push(this.name); // this.name is "(create)"
								last().help = newname + " " + packhelp(); // help messages packed

			Add space after the ending chinese character '了' can fix the problem. But I don't like it.
			
            My jeforth.f is ANSI Big5. I use Big5 because jeforth.hta has problem with UTF-8.
			Now I guess that was "utf-8 with BOM" (3 bytes: EF BB BF) leading marks that caused 
			the jeforth.hta problem. <== YES!!
			If use 'utf-8 without BOM' then jeforth.hta become ok with utf-8, *AND* if IE were ok <== YES!!
			with utf-8 even comment with chinese character at the end of line, <=== YES!!
			then let's switch to use utf-8 without BOM encoding for source code. <==== YES!
			
			By the way, jeforth.f encoded in utf-8 with BOM works fine on 3htm+IE and 3nd. So, only
			3hta has problem. So, Microsoft's HTA does not work with utf-8 with BOM and IE does not work
			with Big5, so Microsoft engineers only work on utf-8 without BOM.
			
		[x]	3HTA has big problem with utf-8! clock3.f does not work because it contains Chinese
			named words! Those words become garbage and are not working correctly. <==== problem!!
			==> Root cause 出在用 fso 讀text不support utf-8, 改用 ADO 即可。
			
	[x]	I have this line, ==> Root cause 出在用 fso 讀text不support utf-8, 改用 ADO 即可。
			<meta charset="utf-8" />
		in jeforth.hta. But it shows utf-8 chineses as garbage while Big5 good. Why? <=== HTA is wrong!
		The funny thing is, in jeforth.htm the situation is reversed: Big5 garbage and utf-8 OK. <== Correct.
		==> Change <meta charset="utf-8" /> to something else to reverse 3htm behavior. Make sure this line
			is the key. --> Failed!! modify jeforth.htm to <meta charset="ansi" />
		==>	How to use codes instead of string? So as to control characters.

		[x] I found, under DOS box running jeforth.3nd. js> "\377" . prints HTML code &#255, a y with
			strange	looking <==== Surprise, ASCII 255h is blank !!!!!!
			往下看！我後來發現在 Window 8 DOS box 下 jeforth.3nd 可以同時顯示正、簡體的中文！取決於
			print() 所用的 function。
		[x]	Similar situaion in jeforth.hta, after OK prompt, type char &#255
			it shows char y <== strange y. But it's "&#255" at TOS.
		
	[x]	jsc is now in trouble under jeforth.htm !!!
		OK jsc

		J a v a S c r i p t   C o n s o l e
		Usage: js: kvm.jsc.prompt='messsage';eval(kvm.jsc.xt)

		------------------- P A N I C ! -------------------------
		JavaScript error on word "jsc" : Cannot set property 'prompt' of undefined
		abortexec: false
		compiling: false .... snip ......
		===> 靠！忘了 jsc in jeforth.f is for 3hta only 啦！ 有替 3nd 寫好了 jsc, 3htm 還沒有啦！
		[x]	嘗試把 jeforth.f 裡的 jsc 定義拉出來，各個 application 放在前面一點的地方。

	[x]	jeforth.htm selftest failed so far on IE. (Chrome ok)
		==> 因為 voc.f 又是 Big5 coded !!
		==> 改成 utf-8 .... still failed. tick ' undefined! <==== 
			==> cache 搞鬼 voc.f 怎麼改都無效。
			--> char kernel/voc.f readTextFile . <==== 改過了，還是讀到舊資料。
			竟然又真的是 cache 的問題，voc.f 讀到 cache 版了。
			--> Ctrl-F5 無效，必須把 IE 整個關掉重開才行。
		==> 確定 voc.f 本來是 Big5 改成 utf-8 encoding 就好了。
[x]	HTA 其實可以顯示中文。手動輸入 
	: test ; /// 中文注视
	/// 繁體也型 
	，即可見得。js> tick('test').comment binary-string>array 得
	0: 9,20013,25991,27880,35270,10,9,32321,39636,20063,22411,10 (array)
	--- chinese.f -----
	: chinese ; /// 中文注视
	/// 繁體也型
	-------------------
	include chinese.f 來看，help -n chinese 顯示亂碼！
	js> tick('chinese').comment binary-string>array 得
	1: 9,37533,21084,63,30236,21051,63,10,9,34652,61247,63,37515,60929,63,10 (array)
	==> 試 char chinese.f readTextFile . 印出來就是亂碼
	==> 查 readTextFile 的寫法。。。var data = kvm.readTextFile(pop()); 
		var txtFile = kvm.fso.OpenTextFile( 
			pathname, 
			1,                 // ForReading 
			false, 
			0                // TristateFalse <==== 問題出在這裡, 只能放 0, -1 並不是 utf-8 !
		); 
		TristateUseDefault  –2  使用系统缺省打开文件。    
		TristateTrue    –1  以 Unicode 格式打开文件。 UCS-2 Big Endian 或 UCS-2 Little Endian 都不是 utf-8!!
		TristateFalse      0  以 ASCII 格式打开文件。
	==> This is the answer http://stackoverflow.com/questions/13851473/read-utf-8-text-file-in-vbscript
		Dim objStream, strData
		Set objStream = CreateObject("ADODB.Stream")
		objStream.CharSet = "utf-8"
		objStream.Open
		objStream.LoadFromFile("C:\Users\admin\Desktop\ArtistCG\folder.txt")
		strData = objStream.ReadText()
		objStream.Close

		kvm.readTextFile = function(pathname) {
			var strData, objStream = CreateObject("ADODB.Stream");
			objStream.CharSet = "utf-8";
			objStream.Open();
			objStream.LoadFromFile(pathname);
			strData = objStream.ReadText();
			objStream.Close();
			return(strData);
		}
		Bingo!!!
	==> Try how to saveToFile
		The below experiment works fine, Bingo!!		
			<js> new ActiveXObject("ADODB.Stream") </jsV> value objStream
			objStream js: pop().CharSet="utf-8"
			objStream js: pop().Open();
			objStream js: pop().LoadFromFile("readme.txt")
			objStream js: pop().SaveToFile("3.txt",2) \ adSaveCreateOverWrite=2, adSaveCreateNotExist=1(can't overwite)
			objStream js: pop().Close()
		Try to write my string, it works fine, Bingo!!		
			<js> new ActiveXObject("ADODB.Stream") </jsV> value objStream
			objStream js: pop().CharSet="utf-8"
			objStream js: pop().Open();
			objStream js: pop().WriteText("11"); \ option: adWriteChar =0(default), adWriteLine =1(\r\n)
			objStream js: pop().WriteText("22"); \ option: adWriteChar =0(default), adWriteLine =1(\r\n)
			objStream js: pop().SaveToFile("3.txt",2) \ adSaveCreateOverWrite=2, adSaveCreateNotExist=1(can't overwite)
			objStream js: pop().Close()
	[x]	改寫 kvm.writeTextFile

[ ]	binary.f does not need VB module, use new ActiveXObject("ADODB.Stream");
[x] Make utf-8 with BOM leading EF BB BF a nop word : EFBBBF ;
	==> No need I guess. 3HTA was a bug of using the incorrect fso module which does not support utf-8.
	
[x]	Node.js DOS box 顯示 utf-8 可能有妙用 <=== 確認可以！
	正體中文顯示在 DOS box 之下本來是得注意 chcp 950 Code Page 的設定。而且簡中系統也不好切 chcp 950.
	跑 jeforth.3nd source code 都是 utf-8 顯示中文倒是都正常。試試簡中系統。。。。
        这几个自是简体中文，在正体 DOS 下显示正常否？
	Ha! 兩種字體同時在 Window 8 DOS box 下正常顯示！
	
[ ]	所以，將來弄 jeforth.3dos 時，print() 的寫法要講究，有機會也能顯示 utf-8 中文正、簡通用！
	
------------------- jeforth.3we 誕生 hcchen5600 2014/10/21 15:28:15 -------------------------------

[x] improve canvas.f self-test, was too annoying.
[ ] improve html5.f self-test, was too rough for such an important module.

[ ]	在 include source.f 裡面 skip 到 --EOF-- 的方法：
	js> confirm("要執行 canvas.f self-test 嗎?") [if] [else] <js> 
		push("--E"+"OF--");execute("word"); // 如果不用 JavaScript code, 到這裡檔尾的 "--EOF--" 將成為下一個指令！
		pop();execute("BL");execute("word");pop();
		execute("--canvas.f--selftest--")
	</js> [then]
	