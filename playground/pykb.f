
js> vm.appname char jeforth.3hta != [if] ?abort" Sorry! pykb.f is for jeforth.3hta only." \s [then]
include vb.f
include unindent.f

s" pykb.f"   source-code-header

    <text>
    【問題】
    
        取得 command line of DOS BOX cmd 
            s" where processid = 4728" objEnumWin32_Process :> item().CommandLine .s
        來看，明明是 "C:\Windows\System32\cmd.exe" (string)。而且： 
            s" where CommandLine = CommandLine" objEnumWin32_Process :> atEnd()
        傳回 false 表示有東西，而以下這樣竟然不行！
            s" where CommandLine = 'C:\\Windows\\System32\\cmd.exe'" 
            objEnumWin32_Process :> atEnd() \ ==> true (boolean) 表示沒找到！
        這還不只，若用 like 最後的 % 也不能省，真搞不懂。這麼一來想濾掉 Chrome 產生的
        cmd 眼前就沒好辦法了。通通列出來吧！試 hi 看看，不行就用
            
            <id> to processid hi
        
        一個個試。
        
        s" where CommandLine like '%cmd.exe%'" list-them tib.
        s" where name like '%python%'" list-them tib.
        
    </text> . cr

    s" where CommandLine like '%cmd.exe%'" list-them tib.
    s" where name like '%python%'" list-them tib.
    
    0 value processid // ( -- n ) User can specify the target process' ID
                    /// When python is run from a DOSbox or PowerShell we
                    /// must use the Shell's process ID instead of python's ID.
                    /// I don't know how to tell which Shell process ID is the
                    /// one we want except trying to activate it through its ID
                    /// e.g. WshShell :: appActivate(20336) -- where 20336 is 
                    /// from s" where name like '%cmd%'" list-them 
    
    : shellId (  -- processID ) \ Get python processID, only one allowed.
        processid ?dup if exit then \ If given then use it directly
        0 s" where name like '%python%'" objEnumWin32_Process >r  ( 0 | obj )
        begin
            r@  ( 0 obj | obj)
            js> !pop().atEnd() ( 0 NotAtEnd? )
        while ( count | obj )
            1+ ( count )
            r@ :> item().ProcessId swap ( processID count | obj )
        r@ js: pop().moveNext() repeat ( ... count | obj )
        r> drop dup 1 = if drop else cr . abort"  python found. Only ONE is allowed." then ;
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
        <js> 
            ("<accept>\n" + pop() + " </accept>\ntib.insert\n")
            .replace(/\{/mg,"_open_curly_brackets_")
            .replace(/\}/mg,"_clos_curly_brackets_")
            .replace(/_open_curly_brackets_/mg,"{{}")
            .replace(/_clos_curly_brackets_/mg,"{}}")
            .replace(/\^/gm,"{^}")
            .replace(/~/mg,"{~}")
            .replace(/\n/mg,"{enter}") 
            .replace(/"/mg,"{\"}")
            .replace(/\(/mg,"{(}")
            .replace(/\)/mg,"{)}")
            .replace(/\+/mg,"{+}")
            .replace(/\%/mg,"{%}")
        </jsV>
        <vb>
            block = vm.pop()
            vm.push(block)
            WshShell.SendKeys block
        </vb> ; 
        /// 以送程式為主要目的，故 SendKeys 的特殊符號都不作用。
        /// 若想利用這些特殊符號玩花樣，另外寫。
        
	code {F7} ( -- ) \ Send inputbox to the python
		vm.cmdhistory.push(inputbox.value);  // Share the same command history with the host
		push(inputbox.value); // command line 
		inputbox.value=""; // clear the inputbox
		execute("</python>"); // Let target page to execute the command line(s)
		push(false); // terminiate event bubbling
		end-code
		/// 若用 F8 則無效, 猜測是 Chrome debugger 自己要用。
