    window.vm = new jeForth();
    // vm is now the jeforth virtual machine object. It has no idea about the outside world
    // that can be variant applications: HTML, HTA, Node.js, Node-webkit, .. etc.
    // We need to help it a little as the following example:

    (function(){
		// version
		// minor version specified by application, major version is from jeforth.js kernel.
		vm.minor_version = 1; 
		var version = parseFloat(vm.major_version+"."+vm.minor_version);
		
        // I/O  
        // Forth vm doesn't know how to 'type'.
		vm.screenbuffer=""; // for self-test
		vm.selftest_visible=true;
        var type = vm.type = function (s) {
            try {
                var ss = s + ''; // Print-able test
            } catch(err) {
                ss = Object.prototype.toString.apply(s);
            }
			vm.screenbuffer+=ss;
			if(vm.selftest_visible) $('#outputbox').append(plain(ss));  // jquery makes it simple, will be a lot of work otherwise.
        };
		var panic = vm.panic = function(state){vm.type(state.msg);if(state.serious)debugger;}
        
        // The Forth traditional prompt 'OK' is defined and used in this application main program.
        // Forth vm has no idea about vm.prompt but your program may want to know.
        // In that case, as an example, use vm property to store the vm global variables and functions.
        vm.prompt = "OK";
        vm.greeting = function () {
			vm.type(appname.innerText + " -- r" + version + "\n");
			vm.type("source code http://github.com/hcchengithub/project-k\n");
			return(version);
        };
		
        // The Forth vm has no idea how to clear the display. This is the good place to define 
		// application dependent functions. Use the same function name for all different applications 
		// so the same forth.f source code doesn't need to change.
        function clearScreen(){
            outputbox.innerHTML="";
			vm.screenbuffer="";
        }
        vm.clearScreen = clearScreen;
		
        // System initialization
        jQuery(document).ready(
            function() {
                document.onkeydown = hotKeyHandler; // Must be using onkeydown so as to grab the control.
                // vm.dictate() is the only Forth command interface.
                // Send a command line string, or an entire source code file into the Forth VM through
                // this interface.
                vm.dictate(source_code.value); 
                
            }
        );

        function forthConsoleHandler(cmd) {
            type((cmd?'\n> ':"")+cmd+'\n');
            vm.dictate(cmd);  // Pass the command line to jeForth VM
            type(" " + vm.prompt + " ");
            window.scrollTo(0,endofinputbox.offsetTop); inputbox.focus();
        }

        // onkeydown,onkeypress,onkeyup
        // event.shiftKey event.ctrlKey event.altKey event.metaKey
        // KeyCode test page http://www.asquare.net/javascript/tests/KeyCode.html
        function hotKeyHandler(e) {
			e = (e) ? e : event; var keyCode = (e.keyCode) ? e.keyCode : (e.which) ? e.which : false;
			switch(keyCode) {
                case 13: /* Enter */
                    if(event.ctrlKey) {
                        vm.inputbox = inputbox.value; // w/o the '\n' character ($10).
                        inputbox.value = ""; // To avoid repeating the last command line when long press 'enter'.
                        forthConsoleHandler(vm.inputbox);
                        return(false);
                    }
            }
            return (true); // pass down to following handlers
        }

		// Take care of HTML special characters
        var plain = vm.plain = function (s) {
            var ss = s + ""; // avoid numbers to fail at s.replace()
            ss = ss.replace(/\t/g,' &nbsp; &nbsp;');
            ss = ss.replace(/ /g,'&nbsp;');
            ss = ss.replace(/</g,'&lt;');
            ss = ss.replace(/>/g,'&gt;');
            ss = ss.replace(/\n/g,'<br>');
            return ss;
        }
    })();
