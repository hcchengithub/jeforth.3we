
	\ background.f for jeforth.3ce background page
	\
    \ 19:40 2018/08/08 複習時做個筆記。
	\ 本檔只有在 chrome://extensions reload jeforth.3ce 時才會被執行到一次。
    \ 重新啟動 Chrome 時推想也會來跑一次，平常根本不會來。以下所定義的 words 以及
    \ 所掛的 event handler 只有去 attach 人家的頁面時才會用到。
    \ 
	\ QUIT is the traditional forth system's CLI loop. jeforth.f kernel is common for all
	\ applications. quit.f is the good place to define propritary features of each application.
	\ Due to that quit.f has already been used for 3ce extension pages, background.f is thus
	\ the same thing but for the background page only.
    \ 

	\ ------------------ Self-test of the jeforth.f kernel --------------------------------------
	js> tick('<selftest>').enabled=true;tick('<selftest>').buffer tib.insert
	js: tick('<selftest>').buffer="" \ recycle the memory

	<js>
	//	Background page onMessage event hander that receives messages from 
	//  content scripts on target pages. See 3ce SPEC of sendMessage() defined in log.json.
	chrome.runtime.onMessage.addListener(
		function background_onmessage (message, sender, sendResponse) { 
			vm.push(message);vm.push(sender);vm.push(sendResponse);
			vm.execute("background-message-handler");
		}
	)
	</js> 
		
	: background-message-handler ( message sender sendResponse -- ) \ 
		2drop \ sender and sendResponse are not used so far
		<js>
			var message = pop(); // See 3ce SPEC of sendMessage() defined in log.json.
			if (message.addr=="background"){
				if (message.tos!=undefined) {
					vm.push(message.tos);
				} 
				if (message.type) { 
					// type to vm.screenbuffer, although background page has no display.
					// this is useful for debugging and experiments I think
					vm.type(message.type);
				} 
				if (message.forth) {
					vm.dictate(message.forth);
				}
			}
		</js> ;

	
	: tabid ( -- tabid ) \ The working tab's id.
		js> window.workingTabId ;
		
	code message->tabid ( {3ce SPEC of message} -- ) \ Send a message of anything to tabid
		execute("tabid"); chrome.tabs.sendMessage(pop(),pop()) end-code
		/// Usage: anything message->tabid

