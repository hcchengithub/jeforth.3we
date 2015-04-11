
\ platform.f for jeforth.3nw 
\ KeyCode test page http://www.asquare.net/javascript/tests/KeyCode.html

include 3htm/f/platform.f
also forth definitions

: {F5}			( -- boolean ) \ Hotkey handler, Confirm reload the application.
				<js> confirm("Really want to restart?") </jsV> 
				if nw :: reloadIgnoringCache() then false ;
				/// Return a false to stop the hotkey event handler chain.
				/// Must intercept onkeydown event to avoid original function.

: {-}			( -- boolean ) \ Inputbox keydown handler, zoom out.
				." {-} "
				js> !event.ctrlKey if true else nw :: zoomLevel-=0.5 false then ;
: {+}			( -- boolean ) \ Inputbox keydown handler, zoom in.
				." {+} "
				js> !event.ctrlKey if true else nw :: zoomLevel+=0.5 false then ;

previous definitions
