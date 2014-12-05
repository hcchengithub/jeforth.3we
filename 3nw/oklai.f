
\ A tutorial on the net "这年头，你只需要懂Node webkit -- OKLAI'S BLOG"
\ http://oklai.name/2013/04/%E8%BF%99%E5%B9%B4%E5%A4%B4%EF%BC%8C%E4%BD%A0%E5%8F%AA%E9%9C%80%E8%A6%81%E6%87%82node-webkit/

include server.f

s" oklai.f"		?skip2 --EOF-- \ skip if already included
				dup .( Including ) . cr char -- over over + + 
			 	also forth definitions (marker) (vocabulary) 
			 	last execute definitions

.( ----- oklai.f 11 ----- ) cr

\ Page 11 , the first example. But it works only when the page is shown in nw.exe. 
\			I found the process.version does not work if the page is shown in any 
\			other borwsers and nw.exe only plays the role of the web server.

	marker --oklai.f-self-test--

.( ----- oklai.f 11 open a Web page ----- ) cr

	<section>
		<text>
			<html>
			<head>
			<title>Hello World!</title>
			</head>
			<body>
			<h1>Hello World!</h1>
			We are using node.js ( 
			<script>
			if (typeof process == "undefined") {
				document.write("process is not defined. " + Date()); 
			} else document.write(process.version + Date()); 
			</script> )
			</body>
			</html>
		</text> constant demo-web-page // ( -- "html" ) a HTML page for exercise.
		demo-web-page 88 webpage 
		s" Click [OK] then you have 30 sec to try to view http://localhost:88 by any browser. "
		s" Note! After that time JavaScript will work on the rests of this oklai.f " +
		s" demo program. " + js: alert(pop())
		1000 30 * sleep 
		s" Time's up! Click [ok] to continue. " js: alert(pop())
	</section> constant oklai.f.11
	\ oklai.f.11 tib.append 

.( ----- oklai.f 22 ----- ) cr

\ Page 18

.( ----- oklai.f 33 ----- ) cr

	<section>
		.(( Now 'win' is the nw.exe main program DOM window object )) 
		win js> pop().title . \ jeforth.3nw -- 3 words jeforth.js for node-webkit with jQuery-terminal	
	
		\ [ ] the 'window' seen in debugger and the 'win' (gui.Window.get()) are different things.
		\ jeforth global variables are window.variables, e.g. window.debug, window.stackwas, window.screenbuffer, etc.
		\ Whild window.title is "undefined", but gui.Window.get().title is
		\ "jeforth.3nw -- 3 words jeforth.js for node-webkit with jQuery-terminal"	
		\ This is not so difficult to understand. i.e. gui.Window.get().minimize() ==> works fine and 
		\ window.minimize() ==> TypeError: Object [object global] has no method 'minimize'	
		
		.(( Demo of the win.on() listener and win.minimize() ))
		: doMinimize ." The nw.exe window is minimized" cr ;
		win js: pop().on('minimize',function(){execute('doMinimize')}) \ Listen to 'minimize'
	
		s" Listener of 'minimize' has setup and working. Click the  [ok] and then " 
		s" You have 30 sec to try minimizing the nw.exe window and see the listener's message." +
		s" Unfortunately, alert() will be minimized when the nw.exe window is minimized. " +
		s" I think this is a bug." + <js> alert(pop()) </js>
		
		1000 30 * sleep 
		s" Time's up! Click [ok] to continue. " 
		s" Watch, the nw.exe window is going to be minimized . . . " +
		s" Try restore the nw.exe window and see the message shown by a listener.") + js: alert(pop())
		
		win js: pop().minimize() \ Do the minimize to the nw.exe window
		
		1000 30 * sleep 
		s" Time's up! Click [ok] to continue. " 
		s" Removing the 'minimize' listener . . " +
		s" You have 15 sec to play on minimize-restore, no more message now.") + js: alert(pop())
	
		win js: pop().removeAllListeners('minimize');
		1000 15 * sleep 
		s" Time's up! Click [ok] to continue. " js: alert(pop())
	</section> constant oklai.f.33
	\ oklai.f.33 tib.append
	
.( ----- oklai.f 44 ----- ) cr

	<section>
		s" Now this is the answer I've been asking for in my head : " 
		s" 'How to open a new nw window?' " +
		s" It's simply the same way to open a new web page." +
		s" Click [ok] then you have 10 min to play on the github homepage." +
		s" 'stopSleeping' command to continue the demo." +  js: alert(pop())
		s" http://github.com"   js> gui.Window.get(window.open(pop())) constant github // ( -- object ) github web page window object
		1000 60 * 10 * sleep 
		s" Time's up! Click [ok] to continue. " js: alert(pop())
		
		s" Now pop the github window to full screen for 10 min . . .  "  js: alert(pop())
		github js: pop().enterFullscreen() \ it works !!
		1000 60 * 10 * sleep 
		s" Time's up! Click [ok] to continue. " js: alert(pop())
		
		s" Now search something on the github page . . . "
		s" then check the nw.exe console. You have 15 sec." + js: alert(pop())
		github js> pop().find("build") .s
		1000 15 * sleep 
		s" Time's up! Click [ok] to continue. " js: alert(pop())
		
		s" Now close the github page ... if you try to click the [x] to close it now," 
		s" you'll find it doesn't work! Because JS host is busying on this alert(). But the close(ture) uses" + 
		s" force to make it successfully." + js: alert(pop())
		github js: pop().close(true) \ true to force to close it.
		
	</section> constant oklai.f.44
	\ oklai.f.44 tib.append

.( ----- oklai.f 55 ----- ) cr
	
	<section>
		s" Here comes the long waiting localhost:88 page . . .  "  
		s" Check forth console if title shown? Try focus on the localhost:88 window."  + js: alert(pop())
		s" http://localhost:88" js> gui.Window.get(window.open(pop())) constant localhost:88 // ( -- object ) localhost:88 web page window object
		localhost:88 js> pop().title . cr \ ==> Hello World!
		localhost:88 js: pop().on('focus',function(){print("hi!\n")})
	</section> constant oklai.f.55
	\ oklai.f.55 tib.append
	
.( ----- oklai.f 66 ----- ) cr

	<section>
		<js> window.menu = new gui.Menu();menu </jsV> constant menu // ( -- obj ) get Menu object
		<js>
		menu.append(new gui.MenuItem({label: 'Item A'}));
		menu.append(new gui.MenuItem({label: 'Item B'}));
		menu.append(new gui.MenuItem({type: 'separator'}));
		menu.append(new gui.MenuItem({label: 'Item C'}));
		document.body.addEventListener('contextmenu',function(ev){
			ev.preventDefault();
			menu.popup(ev.x,ev.y);
			return false;
		});
		</js>
		s" Now try to right clisk anywhere to see the menu . . .  "  js: alert(pop())
	</section> constant oklai.f.66
	\ oklai.f.66 tib.append

.( ----- oklai.f 77 Try menu ----- ) cr

	<section>
		<js> window.trayMenu = new gui.Menu();trayMenu </jsV> constant trayMenu // ( -- obj ) get trayMenu object
		<js>
		trayMenu.append(new gui.MenuItem({label: 'test1'}));	
		trayMenu.append(new gui.MenuItem({label: 'test2'}));	
		trayMenu.append(new gui.MenuItem({label: 'test3'}));
		</js>
		<js>
		win.on('minimize', function() {
			// hide window
			this.hide();
			// Create a try icon
			window.tray = new gui.Tray({title: 'Tray', icon: 'img/icon.png'});
			tray.menu = trayMenu;
			tray.on('click', function(){
				// REmove the tray
				this.remove();
				tray = null;
				// show Window
				win.show();
			});
		});
		</js>
	</section> constant oklai.f.77
	\ oklai.f.77 tib.append
	
.( ----- oklai.f 88 ----- ) cr
.( ----- oklai.f 99 ----- ) cr

\ --EOF--
