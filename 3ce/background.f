
	\ background.f for jeforth.3ce background page
	\
	\ QUIT is the traditional forth system's CLI loop. jeforth.f kernel is common for all
	\ applications. quit.f is the good place to define propritary features of each application.
	\ Due to that quit.f has already been used for 3ce extension pages, background.f is thus
	\ the same thing but for the background page only.

	\ ------------------ Self-test of the jeforth.f kernel --------------------------------------
	js> tick('<selftest>').enabled=true;tick('<selftest>').buffer tib.insert
	js: tick('<selftest>').buffer="" \ recycle the memory
	
	: tabid ( -- tabid ) \ The working tab's id.
		js> window.workingTabId ;
		
	code message->tabid ( anything -- ) \ Send a message of anything to tabid
		execute("tabid"); chrome.tabs.sendMessage(pop(),pop()) end-code
		/// Usage: anything message->tabid

