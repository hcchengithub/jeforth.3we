
\ Node-webkit homepage on github, the Wiki page, Geting started guide, Over view
\ https://github.com/rogerwang/node-webkit/wiki/Getting-Started-with-node-webkit

include nw.f

s" Getting-Started.f"	?skip2 --EOF-- \ skip if already included
						dup .( Including ) . cr char -- over over + + 
						also forth definitions (marker) (vocabulary) 
						last execute definitions

.( ----- Example 2. menu bar , context menu ----- ) cr

	<section> 
	<js>
		var menu = new gui.Menu();

		// Add some items with label
		menu.append(new gui.MenuItem({ label: 'Item A' }));
		menu.append(new gui.MenuItem({ label: 'Item B' }));
		menu.append(new gui.MenuItem({ type: 'separator' }));
		menu.append(new gui.MenuItem({ label: 'Item C' }));

		// Remove one item
		menu.removeAt(1);

		// Iterate menu's items
		for (var i = 0; i < menu.items.length; ++i) {
		  print(menu.items[i].label||menu.items[i].type);
		  print('\n');
		}

		// Add a item and bind a callback to item
		menu.append(new gui.MenuItem({
			label: 'Click Me',
			click: function() {
				// Create element in html body
				var element = document.createElement('div');
				element.appendChild(document.createTextNode('Clicked OK'));
				document.body.appendChild(element);
			}
		}));

		// Popup as context menu
		document.body.addEventListener('contextmenu', function(ev) { 
			ev.preventDefault();
			// Popup at place you click
			menu.popup(ev.x, ev.y);
			return false;
		}, false);

		// Get the current window
		\ var win = gui.Window.get();

		// Create a menubar for window menu
		var menubar = new gui.Menu({ type: 'menubar' });

		// Create a menuitem
		var sub1 = new gui.Menu();

		sub1.append(new gui.MenuItem({
			label: 'Test1',
			click: function() {
				var element = document.createElement('div');
				element.appendChild(document.createTextNode('Test 1'));
				document.body.appendChild(element);
			}
		}));

		// You can have submenu!
		menubar.append(new gui.MenuItem({ label: 'Sub1', submenu: sub1}));

		//assign the menubar to window menu
		win.menu = menubar;
	</js>	
	</section> constant example-2 
	\ example-2 tib.append

.( ----- Example 3. Using node.js to check os ----- ) cr

	// You can call node.js and modules directly from the DOM. So it enable endless possibilities for writing apps with node-webkit.
	// get the system platform using node.js
	<section>
		
		js> require('os') constant os // ( -- obj ) get OS object, node.js 'os' module
		.( Our computer is: ) os js> pop().platform() .
		
		// And listen to a window's focus event
		win js: pop().on('focus',function(){print("hi!\n")})		
	</section> constant example-3 
	\ example-3 tib.append

.( ----- Example 4. How to open a window ----- ) cr
	
\ How to open a window ( or Extended Window APIs )
\ https://github.com/rogerwang/node-webkit/wiki/Window
\ evernote:///view/2472143/s22/08b92029-669c-43a5-aa53-9eb717807edb/08b92029-669c-43a5-aa53-9eb717807edb/

	// o Window API requires node-webkit >= v0.3.0
	// o Window is a wrapper of DOM's window object, it has extended operations and 
	//   can receive various window events.
	// o Every Window is an instance of EventEmitter object, and you're able to use 
	//   Window.on(...) to response to native window's events.	
	
	<section>

		\ window.open("http://ibm.com") is the DOM way. 
		\ gui.Window.get(window.open("http://ibm.com")) is the nw way.
		\ While the nw way is more powerful.

		<text> Open an URL by the DOM way window.open("http://devdocs.io") and get the object. stopSleeping to continue . . . </text> js: alert(pop())
		js> window.open("http://devdocs.io") constant devdocs.io1 \ open URL in a nw window by DOM way
		120000 sleep 
		<text> It does not support minimize(). stopSleeping to continue . . . </text> js: alert(pop())
		devdocs.io1 js: pop().minimize() \ ==> JavaScript error : Object [object global] has no method 'minimize'
		
		<text> Open an URL by the nw way gui.Window.get() and get the object. stopSleeping to continue . . . </text> js: alert(pop())
		js> gui.Window.get(window.open("http://devdocs.io")) constant devdocs.io2 \ open URL in a nw window by nw way
		120000 sleep 
		<text> It supports minimize(). stopSleeping to continue . . . </text> js: alert(pop())
		devdocs.io2 js: pop().minimize() \ ==> it works fine!!
		
		<text> Their ability are different because their constructor are different. stopSleeping to continue . . . </text> js: alert(pop())
		devdocs.io1 js> pop().constructor . cr \ ==> function Window() { [native code] }
		devdocs.io2 js> pop().constructor . cr \ ==> I guess this is nw's Window object,
											\ function Window(routing_id, nobind) {
											\   // Get and set id.
											\   var id = global.__nwObjectsRegistry.allocateId();
											\   Object.defineProperty(this, 'id', {
											\   value: id,
											\   writable: false
											\ });
											\ ... snip ...
		120000 sleep 
		<text> stopSleeping to continue . . . </text> js: alert(pop())
		devdocs.io1 js: pop().close() \ close the nw window
		devdocs.io2 js: pop().close() \ close the nw window
		
		<text> 這兩行接著做可以，但分開不知道什麼程度就不行。 [ ] Don't know why. Try devdocs.io2.minimize() and devdocs.io2.close(), stopSleeping to continue . . . </text> js: alert(pop())
		js> window.open("http://devdocs.io") constant devdocs.io1 
		devdocs.io1 js> gui.Window.get(pop()) constant devdocs.io2
		120000 sleep 
		\ devdocs.io2 js: pop().close() \ close the nw window

		<text> 前面示範 gui.Window.get(), 但直接用 gui.Window.open(url[,{manifest}]) 更精采, stopSleeping to continue . . . </text> js: alert(pop())
		<js> 
			gui.Window.open("http://devdocs.io",{
				name: "devdocs", 
				description: "http://devdocs.io homepage", 
				version: "r100",
				position: "mouse", // 果然出現在以 mouse 為中心處
				"new-instance": true
			}) 
		</jsV> constant devdocs.io \ open URL in a nw window by nw way
		
	</section> constant example-4
	\ example-4 tib.append

	.( ----- Example 5. win.something proterties and methods ----- ) cr
	
	<section>
		js> win.width . \ 876
		js: win.width=800 \ it works
		js> win.title . \ jeforth.3nw -- 3 words projectk.js for node-webkit with jQuery-terminal
		js: win.title="hahaha" \ it really changes the nw window's title
		js> win.zoomLevel . \ 0 this is the font size of the forth console
		js: win.zoomLevel=1
		js: win.zoomLevel=2   
		js: win.zoomLevel=-1
		js: win.zoomLevel=3 \ This font size is good on DOH7 OA computer.
		js> win.blur() \ I don't see any effect
		js> win.enterKioskMode() \ I think it's full screen mode.
		js> win.restore() \ 
		js> win.leaveKioskMode()
		js> win.enterKioskMode()
		js: win.showDevTools()
	</section> constant example-5

	.( ----- Example 6. win.on('events') ----- ) cr
	
	<section>
		<js> win.on('close',function(){
			alert(11111);
			win.close(true);  // the 'true' is a must or the close() will bring up the alert() again infinitely.
		}); </js>
	</section> constant example-6

	.( ----- Example 7. Using Node modules ----- ) cr
	
	\ https://github.com/rogerwang/node-webkit/wiki/Using-Node-modules
	\ There are three types of modules in Node.js:
	\ 	o internal modules (parts of Node API http://nodejs.org/docs/latest/api/)
	\ 	o 3rd party modules written in JavaScript
	\ 	o 3rd party modules with C/C++ addons
	\ All of these types can be used in node-webkit.
	\ Other than modules in Node.js, you may use the “Modules” page in Node's wiki 
	\ or npm search to discover many open source modules.

	<section>
	
	</section> constant example-6

	.( ----- Example 8. nw API, the extended Window object ----- ) cr
	\ https://github.com/rogerwang/node-webkit/wiki/Native-UI-API-Manual	
	\ 
	<section>
	</section> constant example-6
	
	<section>
	</section> constant example-6


\ --EOF--	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	