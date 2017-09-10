
js> vm.appname char jeforth.3hta != [if] ?abort" Sorry! pykb.f is for jeforth.3hta only." \s [then]
include vb.f
include unindent.f

s" pykb.f"   source-code-header
    
    : shellId (  -- processID ) \ Get python processID, only one allowed.
        0 s" where name like '%python%'" objEnumWin32_Process >r  ( 0 | obj )
        begin
            r@  ( 0 obj | obj)
            js> !pop().atEnd() ( 0 NotAtEnd? )
        while ( count | obj )
            1+ ( count )
            r@ :> item().ProcessId swap ( processID count | obj )
        r@ js: pop().moveNext() repeat ( ... count | obj )
        r> drop 1 = if else abort" Ooops! many python are running. Which one?" then ;
        \ use list-them and see-process to investigate the python process
        
    : check-shell ( -- ) \ Abort if Shell is not running.
        shellId not ?abort" Error! python is not running." ;
        
    : activate-shell ( -- ) \ Active python 
        500 nap shellId ?dup if ( processID )
            s' WshShell.AppActivate ' swap + </vb> 
        then 500 nap ; /// assume it's python
    : activate-jeforth ( -- ) \ Come back to jeforth.3hta
        1000 nap s" WshShell.AppActivate " vm.process :> processID + </vb> 500 nap ;

    : <shell> ( <command line> -- ) \ Command line to the python
        char {enter}{enter} char </shell> word + compiling if literal then ; immediate
		/// Note! Use two "" instead of any " in the command line due to VBscript syntax.

    : </shell> ( "command line" -- ) \ Send command line to the python
        compiling if 
            compile check-shell 
            \ '^' and '~' 是 sendkey 的 special character 要改成 "{^}" and "{~}"
            js: push(function(){push(pop().replace(/\^/g,"{^}").replace(/~/g,"{~}"))}) 
            , compile activate-shell 
            s' WshShell.SendKeys "' literal compile swap compile + s' {enter}"' literal 
            compile + [compile] </vb> compile activate-jeforth
        else 
            check-shell
            js> pop().replace(/\^/m,"{^}").replace(/~/g,"{~}") activate-shell
            s' WshShell.SendKeys "' swap + s' {enter}"' + </vb> activate-jeforth
        then ; immediate
        
    : hi ( -- ) \ Let python say hi 
        <shell> version drop</shell> ;

    : <python> ( <block> -- "block" ) \ Multiple lines to the python 
        char </python> word ;
        
    : </python> ( "block" -- ) \ Send block to the python
        check-shell activate-shell
        \ SendKeys 的特殊符號都要改
        <js> 
            ("<accept>\n" + pop() + " </accept>\ntib.insert\n")
            .replace(/\{/mg,"{{}")
            .replace(/\}/mg,"{}}")
            .replace(/\^/gm,"{^}")
            .replace(/~/mg,"{~}")
            .replace(/\n/mg,"{enter}") 
            .replace(/"/mg,"{\"}")
            .replace(/\(/mg,"{(}")
            .replace(/\)/mg,"{)}")
            .replace(/\+/mg,"{+}")
        </jsV>
        <vb>
            block = vm.pop()
            vm.push(block)
            WshShell.SendKeys block
        </vb> ; 
        
	code {F7} ( -- ) \ Send inputbox to the python
		vm.cmdhistory.push(inputbox.value);  // Share the same command history with the host
		push(inputbox.value); // command line 
		inputbox.value=""; // clear the inputbox
		execute("</python>"); // Let target page to execute the command line(s)
		push(false); // terminiate event bubbling
		end-code
		/// 若用 F8 則無效, 猜測是 Chrome debugger 自己要用。
