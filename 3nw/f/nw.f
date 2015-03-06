
\ https://github.com/rogerwang/node-webkit/wiki/Native-UI-API-Manual

s" nw.f"	source-code-header

<comment>
	We have 'kvm.gui' already which is defined in the main program jeforth.3nw.html. The 
	definition is something like,
	
		js> require('nw.gui') constant gui // Node-webkit GUI module

	Forth statement "kvm.gui (see)" or "console.log(kvm.gui)" shows the entire nw.gui object. 
	By this way, we don't even need to read any document (where is it?) before we can use it.
	
	I don't think it's useful to translate all nw.gui methods and properties into forth 
	words unless for fun. But I list the URL and feature some useful things.
</comment>

js> kvm.gui.Window.get() constant nw // ( -- object ) the Window object of the nw.exe session

				\ nw obj>keys .
				\ routing_id,_events,addListener,on,handleEvent,window,x,y,width,height,title,
				\ zoomLevel,menu,isFullscreen,isKioskMode,moveTo,moveBy,resizeTo,resizeBy,focus,
				\ blur,show,hide,close,maximize,unmaximize,minimize,restore,enterFullscreen,
				\ leaveFullscreen,toggleFullscreen,enterKioskMode,leaveKioskMode,toggleKioskMode,
				\ showDevTools,__setDevToolsJail,setMinimumSize,setMaximumSize,setResizable,
				\ setAlwaysOnTop,requestAttention,setPosition,reload,reloadIgnoringCache,
				\ reloadOriginalRequestURL,reloadDev,capturePage,setMaxListeners,emit,once,
				\ removeListener,removeAllListeners,listeners

				<selftest> 
				***** nw :> window is window but window's parent is itself ..... 
				marker -%-%-%-%-%- 
				js: kvm.screenbuffer=kvm.screenbuffer?kvm.screenbuffer:""; \ enable kvm.screenbuffer, it stops working if is null.
				js> kvm.screenbuffer.length constant start-here // ( -- n ) 開始測試前的 kvm.screenbuffer 尾巴。 
				( ------------ Start to do anything --------------- ) 
				nw :> window==window dup tib. ( -- true )
				nw obj>keys tib. ( -- [nw's members] )
				( ------------ done, start checking ---------------- ) 
				start-here <js> kvm.screenbuffer.slice(pop()).indexOf("requestAttention")!=-1 </jsV> \ true 
				js> stack.slice(0) <js> [true,true] </jsV> isSameArray >r dropall r> 
				-->judge [if] <js> [ 
					'nw'
				] </jsV> all-pass [else] *debug* selftest-failed->>> [then] 
				-%-%-%-%-%- 
				</selftest>
				
				<selftest> 
				nw :> routing_id tib.
				nw :> window tib.
				nw :> x tib.
				nw :> y tib.
				nw :: maximize() "" tib. 100 sleep
				nw :> width dup tib. value width
				nw :> height dup tib. value height
				nw :> title tib.
				nw :> zoomLevel tib.
				nw :> isFullscreen tib.
				nw :> isKioskMode tib.
				nw :: moveTo(200,200) "" tib. 100 sleep
				nw :: moveBy(-200,-200) "" tib. 100 sleep

				width height nw :: resizeTo(pop(1)-50,pop()-50) "" tib. 100 sleep
				width height nw :: resizeTo(pop(1)-100,pop()-100) "" tib. 100 sleep
				width height nw :: resizeTo(pop(1)-150,pop()-150) "" tib. 100 sleep
				nw :: resizeBy(150,150) "" tib.
				.( ----------- You won't see me for a while :-> -------------- ) cr
				nw :: hide() "" tib. 100 sleep
				nw :: show() "" tib.
				nw :: maximize() "" tib. 100 sleep
				nw :: unmaximize() "" tib. 100 sleep
				nw :: minimize() "" tib. 100 sleep
				nw :: restore() "" tib. 100 sleep
				nw :: enterFullscreen() "" tib. 100 sleep
				nw :: leaveFullscreen() "" tib. 100 sleep
				nw :: toggleFullscreen() "" tib. 100 sleep
				nw :: toggleFullscreen() "" tib. 100 sleep
				nw :: enterKioskMode() "" tib. 100 sleep
				nw :: leaveKioskMode() "" tib. 100 sleep
				nw :: toggleKioskMode() "" tib. 100 sleep
				nw :: toggleKioskMode() "" tib. 100 sleep
				nw :: setMinimumSize(700,400) "" tib.
				width height nw :: setMaximumSize(pop(1),pop()) "" tib.
				nw :: setResizable(true) "" tib.
				nw :: setAlwaysOnTop(true) "" tib.
				nw :: setAlwaysOnTop(false) "" tib. 
				
				</selftest> 
				
\ -------------- gui.App -------------------------------------------------------------
\	gui.App	 https://github.com/rogerwang/node-webkit/wiki/App	 
\		kvm.gui.App.quit() nw.close() window.close() similar but none of them returns the errorlevel
\		kvm.gui.App.closeAllWindows()
\		kvm.gui.App.crashBrowser()
\		kvm.gui.App.crashRenderer()
\		kvm.gui.App.setCrashDumpDir(dir)
\	js>	kvm.gui.App.dataPath \ ==> C:\Users\hcchen\AppData\Local\jeforth.3nw (array)
\ 	js> kvm.gui.App.getProxyForURL("http://ibm.com") tib. \ ==> DIRECT (string)

: fullArgv		( -- string ) \ Full command line argv includes nw --options.
				js> kvm.gui.App.fullArgv ;
				/// --remote-debugging-port=9222 can be seen.

: argv			( -- [argv] ) \ Get command line argv array w/o nw --options.
				js> kvm.gui.App.argv ;
				
				<selftest>
					\ I wish some day I'll know how to launch another nw.exe session so I would
					\ be able to test this word better.
					*** fullArgv argv ... 
					fullArgv js> typeof(pop()) char string == \ true
					argv js> mytypeof(pop()) char array == \ true
					js> stack.slice(0) <js> [true,true] </jsV> isSameArray >r dropall r>
					==>judge [if] <js> ['argv'] </jsV> all-pass [then]
				</selftest>

				<selftest>
				.( ----- Demo some gui.App features -------- ) cr
				js>	kvm.gui.App.dataPath tib.
			 	js> kvm.gui.App.getProxyForURL("http://ibm.com") tib.
				js> kvm.gui.App.manifest "" tib. (see)
				js: kvm.gui.App.clearCache() "" tib. \ Clear the HTTP cache in memory and the one on disk.
				</selftest>
				
\ ---------------- gui.Clipboard --------------------------------------------------------------
\	gui.Clipboard  https://github.com/rogerwang/node-webkit/wiki/Clipboard

variable clipboard 0 clipboard ! // ( -- obj ) nw.gui.Clipboard 

: clipboard.init ( -- obj ) \ Get clipboard object
				clipboard @ ?dup if else
					js> kvm.gui.Clipboard.get() clipboard !
				then ;
				
: clipboard@	( -- 'text' ) \ Read data from clipboard, text only.
				clipboard @ js> pop().get('text') ;
				
: clipboard!	( 'text' -- ) \ Write data to clipboard, text only.
				clipboard @ js: pop().set(pop(),'text') ;
				
: clipboard.clear ( -- ) \ Clear clipboard
				clipboard @ js: pop().clear() ;
				
				<selftest>
					*** clipboard clipboard.init clipboard@ clipboard! clipboard.clear ... 
					clipboard.init char 11aa22bb dup clipboard! clipboard@ \ 11aa22bb 11aa22bb
					clipboard.clear clipboard@ "" = \ true
					js> stack.slice(0) <js> ["11aa22bb","11aa22bb",true] </jsV> isSameArray >r dropall r>
					==>judge [if] <js> ['clipboard.init','clipboard@','clipboard!','clipboard.clear'] </jsV> all-pass [then]
				</selftest>
