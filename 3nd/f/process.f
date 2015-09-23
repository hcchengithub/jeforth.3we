
\ https://github.com/rogerwang/node-webkit/wiki/Using-Node-modules
\ The internal (built-in) modules of Node.js can be used as directly as in Node, 
\ according to the documentation on Node API. For example, you may use the 'process' 
\ module instantly (without any require(…)), as in Node. 

\ http://nodejs.org/docs/latest/api/process.html
\	The process object is a *global object* and can be accessed from anywhere. It is 
\	an instance of EventEmitter.

s" process.f"	source-code-header

js> process constant process // ( -- object ) Node.js process object

				<selftest>
				.( ----- Node.js process object ----- ) cr
				( Let's see goodies in the Node.js process object ) process obj>keys tib.
				<comment>
					title,version,moduleLoadList,versions,arch,platform,
					argv,execArgv,env,pid,features,_needImmediateCallback,
					execPath,debugPort,_getActiveRequests,_getActiveHandles,
					_needTickCallback,reallyExit,abort,chdir,cwd,umask,_kill,
					hrtime,dlopen,uptime,memoryUsage,binding,_usingDomains,
					_tickInfoBox,_events,domain,_maxListeners,EventEmitter,
					_fatalException,_exiting,assert,config,nextTick,
					_nextDomainTick,_tickCallback,_tickDomainCallback,
					_tickFromSpinner,maxTickDepth,stdout,stderr,stdin,openStdin,
					exit,kill,addListener,on,removeListener,mainModule,_nw_app,
					setMaxListeners,emit,once,removeAllListeners,listeners (array)
				</comment>
				process :> title tib.
				( Node.js version ) process :> version tib.
				( Node.js modules ) process :> moduleLoadList tib.
				( Above modules' versions ) process :> versions "" tib. (see) cr
				process :> arch tib.
				process :> platform tib.
				process :> argv tib.
				process :> execArgv tib.
				process :> env "" tib. (see) cr
				process :> pid tib.
				process :> features "" tib. (see) cr
				process :> execPath tib.
				process :> hrtime() tib.
				process :> hrtime() tib.
				process :: nextTick(function(){type(process.hrtime());type('\n')}) "" tib.
				100 sleep 
				process :> uptime() tib. 
				process :> uptime() tib.
				process :> cwd() dup tib.
				process :: chdir('..') "" tib.
				process :> cwd() tib.
				process :: chdir(pop()) "" tib.
				process :> cwd() tib.
				process :> debugPort tib.
				<text> \ debugPort is still 5858 in the following case. 
				\    chrome.exe http://127.0.0.1:9222
				\    nw.exe --remote-debugging-port=9222 jeforth.3we
				</text> <js> pop().replace(/^[ \t]*/mg,"")</jsV> .
				process :> memoryUsage() "" tib. (see) cr
				process :> _tickInfoBox "" tib. (see) cr
				process :> _events "" tib. (see) cr
				process :> domain tib.
				process :> _maxListeners tib.
				process :> _exiting tib.
				( Assertion is supposed to show more info ) <js> process.assert(true,function(){type("Assertion happens when previous argument is false")})</jsV> tib.
				process :> config "" tib. (see) cr
				process :> stdout tib.
				process :> stderr tib.
				( nw does not support stdin yet ) js: try{process.stdin}catch(e){push(e)} tib.
				( nw does not support stdin yet ) js: try{process.openStdin()}catch(e){push(e)} tib.
				( The 2nd argument is signal ID, what's that? ) js: try{process.kill(99999,123321)}catch(e){push(e)} tib.
				( Not really killing self nor Notepad.exe ) process :> kill(process.pid,0) tib.
				( Looks like the gui.App object ) process :> _nw_app "" tib. obj>keys .
				( ref _events above ) process :> listeners("uncaughtException") tib.
				.( ---------- End of process.things demo ----------- ) cr
				[d d] [p 'process' p]
				</selftest>

: process.exit	( exit-code -- ) \ Terminate node.js, actually the entire program.
				js: process.exit(pop()) ;
				/// The exit-code goes to %ERRORLEVEL% if run by Node.exe but *not* nw.exe.
				/// 'bye' command uses window.close() so far (jeforth.3nw r16).
