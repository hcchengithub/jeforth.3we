	
	\ ShellWindows object https://msdn.microsoft.com/en-us/library/windows/desktop/bb773974(v=vs.85).aspx
	\ Windows Internet Explorer object https://msdn.microsoft.com/library/aa752084(v=vs.85).aspx

	s" ie.f"	source-code-header

	: see-ie 			( -- count ) \ List all IE processes and return the count
						s" where name = 'iexplore.exe'" see-process ;
						/// IE process 的個數不能用，它的意義不明，與 ShellWindows count 不符。
						/// 第一次 Run iexplore.exe 會跑出兩個 IE process 一主一副。
						
	: kill-ie 			( -- bodyCount ) \ Kill all IE processes return the count.
						<js> var f=confirm("Kill IEs are you sure? ShellWindows.count will not be reduced");f</jsV>
						if s" where name = 'iexplore.exe'" kill-them then ;
						/// 但是，當 (Win8) IE 被徹底用 processID 殺掉之後, ShellWindows :> count 
						/// 仍不會減去! Kill IE process 不是正常使用的動作。

	shell.application :> windows() constant ShellWindows // ( -- obj ) shell.application (IE) windows object.
						/// 這個 collection 就是所有的 IE windows. ShellWindows :> count 就是 IE 頁面
						/// 的總數。ShellWindows :> item(0,1,2,3...) 即 IE objects 與 DOM window 不同。
						/// ShellWindows 整合所有的 IE 頁面，但 ShellWindows 本身沒有開啟 IE 頁面的功
						/// 能。我本來以為 ShellWindows :> count >= 1 時 ShellWindows :> item(0) 可以
						/// 當作 defauult IE object 來操作。可是 item(0) 常常是 null! 
						
	\ IE run 起來有幾種方式
	\ 1. s" iexplore ibm.com" (fork) 當 ShellWindows.count==0 時要用這個，還不如都用這個。
	\ 2. ShellWindows.item(0).navigate("url") 當 ShellWindows.count==0 時不能用。
	\ 3. GetObject("","InternetExplorer.Application") 取得一個沒有 document 的 IE object
	\ 4. CreateObject("InternetExplorer.Application") 用不著，不必研究。
	\ 有了 ShellWindows 可以隨時 access 所有的 IE web 頁面, 後三者都用不著了。
	
	: ie(i)				( i -- ie|null ) \ Get IE object of the indexed window
						s" g.ShellWindows.item(_i_)" :> replace(/_i_/,pop()) jsEval ;
						/// IE run 起來之前是 null 即無 IE process。若照下面這樣把最後
						/// 一個 window 關掉: 0 ie() :> document.parentWindow :: close() 
						/// 也會把 IE process 關掉,當然 0 ie(i) 也是 null。
	
	0 value theIE // ( -- i ) Make ShellWindows.item(i) the default IE object
						
	: ie 				( -- ie|null ) \ Get the ShellWindows.item(theIE) IE object
						\ js> g.ShellWindows.item(g.theIE) [ ] 不能直接用變數,很奇怪,是個 bug 吧!
						theIE s" g.ShellWindows.item(_i_)" :> replace(/_i_/,pop()) jsEval ;
						/// IE run 起來之前是 null 即無 IE process。若照下面這樣把最後
						/// 一個 window 關掉: ie :> document.parentWindow :: close() 
						/// 也會把 IE process 關掉,當然 ie 也是 null。但 ie(0) 有時候是 null
						/// 即使 ie(1) 有東西，故需要用 theIE 來指定 active IE object。
						
	last alias available? // ( -- objIe|null ) Is the ShellWindows.item(0) IE object available?
						/// ie 可能是存在的, 但沒有 connect 任何網址, 此時 ReadyState 也是 4, 
						/// 也有 document, 但是 document 裡 innerHTML 是 undefined。 這樣就
						/// available 了, 可以 navigate() 了。如果不 available 則推薦用
						/// s" iexplore" (fork) 把 IE run 起來。
	
						
	: window(i)			( i -- window|null ) \ Get window object of the indexed ie tab
						ie(i) ?dup if ( ie ) 
							dup :> ReadyState if ( ie ) \ [ ] 不是 0 就有 document 是真的嗎? 直接 check document 不就好了?
								:> document.parentWindow exit
							then
						then drop null ;
						/// [ ] 疑問 ie.ReadyState 不是 0 就有 document 是真的嗎?
						/// ie(i).ReadyState == 0 就不會有 document。即使
						/// 有 document 也不一定有 innerHTML 的內容。

	: window			( -- window|null ) \ Get the ShellWindows.item(0) window object
						ie ?dup if ( ie ) 
							dup :> ReadyState if ( ie ) \ [ ] 不是 0 就有 document 是真的嗎? 直接 check document 不就好了?
								:> document.parentWindow exit
							then
						then drop null ;
						/// [ ] 疑問 ie.ReadyState 不是 0 就有 document 是真的嗎?
						/// ie(i).ReadyState == 0 就不會有 document。
						/// 有 document 也不一定有 innerHTML 的內容。
						
	: isIe?				( ie -- ie flag ) \ Is it an IE object?
						<js> typeof(tos())=="object"&&tos().name=="Windows Internet Explorer"</jsV> ;
						
	: check-ie			( ie -- ie ) \ Pass or abort
						isIe? if else drop abort" Error! Need an IE object (from ShellWindows)." then ;

	: list-ie-windows	( -- count ) \ List all IE windows' locationName and URL
		\ 0 begin dup ie(i) ( count IE ) dup while ( count IE ) 
		\ over . space dup :> LocationName . space :> LocationURL . cr ( count )
		\ 1+ repeat ( count IE ) drop ;
		ShellWindows :> count ?dup if dup for dup r@ - ( COUNT i )
		dup . space ( COUNT i ) ie(i) ?dup if dup :> LocationName . space :> LocationURL . else ." Null" then cr
		next drop then ;
		/// 有時候存在沒有內容的空 ie(i) 連 ie(0) 都有可能。
		last alias list

	\ 我不知道哪個 IE window 是 activated
	\ 以下命令固定用 ShellWindows.item(theIE) 來做 automation。
						
	: ready				( -- ) \ Wait ShellWindows.item(theIE) to become ready
						ie ?dup if 
							dup :> ReadyState if ( ie )
								begin dup :> ReadyState==4 if drop space exit else char . . then 200 nap again
							else
							drop abort" Error! The given IE object is empty, nothing to do with 'ready'."
							then
						else \ 還沒有實體
							drop abort" Error! The given IE object is NULL, nothing to do with 'ready'."
						then ;
						/// 因為是 Wait ready 所以出問題要 abort。要預防,用 available? 先查。
						
	: not-busy			( -- ) \ Wait ShellWindows.item(0) to become not-busy
						ie begin ( ie )
							dup :> busy if char * . else drop space exit then
						200 nap again ;
						/// Wait ready first it checks IE object existence.
						
	: document			( -- obj ) \ Get ShellWindows.item(theIE).document object
						ie :> document ;
	: locationName		( -- "name" ) \ Get ShellWindows.item(theIE).locationName string
						ie :> locationName ;
	: locationUrl		( -- obj ) \ Get ShellWindows.item(theIE).locatonUrl string
						ie :> locationUrl ;
	: visible			( -- ) \ Make ShellWindows.item(theIE) visible
						js: g.ShellWindows.item(theIE).visible=true ;
	: visible?			( -- flag ) \ Get ShellWindows.item(theIE).visible setting
						ie :> visible ;
	: (navigate)		( "url" -- ) \ ShellWindows.item(theIE) to visit the URL
						ie :: navigate(pop(),"_top") ;
	: navigate			( <url> -- ) \ ShellWindows.item(theIE) to visit the URL
						BL word ie :: navigate(pop(),"_top") ;
	: source 			( -- "HTML" ) \ Get source code of the ShellWindows.item(theIE) page
						ready not-busy document :> body.innerHTML ;
	
	<comment>	
		AddressBar
		/// Sets or gets a value indicating whether the address bar of the object is visible or hidden.
		Application
		/// Gets the automation object for the application that is hosting the WebBrowser Control. 就是 IE object 自己。
		Busy
		/// Gets a value that indicates whether the object is engaged in a navigation or downloading operation.
		Container
		/// Gets an object reference to a container. [ ] 不知是啥,讀出來是 NULL。
		Document
		/// Gets the automation object of the active document, if any. ==> [object Document] (object)
		FullName
		/// FullName may be altered or unavailable in subsequent versions of the operating system or product.
		/// Retrieves the fully qualified path of the Internet Explorer executable.
		FullScreen
		/// Sets or gets a value that indicates whether Internet Explorer is in full-screen mode or normal window mode.
		Left
		/// Sets or gets the coordinate of the left edge of the object.
		LocationName
		/// (ReadOnly) Retrieves the path or title of the resource that is currently displayed.
		LocationURL
		/// (ReadOnly) Gets the URL of the resource that is currently displayed.
		MenuBar
		/// Sets or gets a value that indicates whether the Internet Explorer menu bar is visible.
		Offline
		/// Sets or gets a value that indicates whether the object is operating in offline mode.
		Parent
		/// Gets the parent of the object.
		Path
		/// Path may be altered or unavailable in subsequent versions of the operating system or product. Retrieves the system folder of the Internet Explorer executable.
		ReadyState
		/// Gets the ready state of the object. READYSTATE_UNINITIALIZED = 0, READYSTATE_LOADING = 1, READYSTATE_LOADED = 2, READYSTATE_INTERACTIVE = 3, READYSTATE_COMPLETE = 4
		RegisterAsBrowser
		/// Sets or gets a value that indicates whether the object is registered as a top-level browser window.
		RegisterAsDropTarget
		/// Sets or gets a value that indicates whether the object is registered as a drop target for navigation.
		Silent
		/// Sets or gets a value that indicates whether the object can display dialog boxes.
		StatusBar
		/// Sets or gets a value that indicates whether the status bar for the object is visible.
		TheaterMode
		/// Sets or gets whether the object is in theater mode.
		ToolBar
		/// Sets or gets whether toolbars for the object are visible.
		TopLevelContainer
		/// Gets a value that indicates whether the object is a top-level container.
		Type
		/// Gets the user type name of the contained document object.
		Visible
		/// Sets or gets a value that indicates whether the object is visible or hidden.
	</comment>	
		
		
		
		
	
	