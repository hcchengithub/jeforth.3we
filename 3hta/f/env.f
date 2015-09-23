\ Big5
\ Words for handling environment variables.

s" env.f"	source-code-header 

js> WshShell.Environment("SYSTEM")  constant WshSysEnv // ( -- obj ) WSH system environment variables
js> WshShell.Environment("PROCESS") constant WshProcEnv // ( -- obj ) WSH process environment variables
js> WshShell.Environment("USER")    constant WshUserEnv // ( -- obj ) WSH user environment variables
.( WshSysEnv.length  = ) WshSysEnv  js> pop().length . cr
.( WshProcEnv.length = ) WshProcEnv js> pop().length . cr
.( WshUserEnv.length = ) WshUserEnv js> pop().length . cr

: sys-env   	( <name> -- value ) \ Get value from a System environment variable
				WshSysEnv js> pop().Item(nexttoken()) ;
					
: sys-env!  	( value "name" -- ) \ Write to a System environment variable. 
				WshSysEnv js> pop().Item(pop())=pop() ; 
				/// You can try but it may not success. 
				/// Vista ok, Win7 Error message is : 沒有使用權限
	
: sys-env@  	( "name" -- value ) \ Get value from a System environment variable
				WshSysEnv js> pop().Item(pop()) ;
	
: proc-env  	( <name> -- value ) \ Get value from a Process environment variable
				WshProcEnv js> pop().Item(nexttoken()) ;

: proc-env@ 	( "name" -- value ) \ Get value from a Process environment variable
				WshProcEnv js> pop().Item(pop()) ;
	
: proc-env! 	( value "name" -- ) \ Write to a Process environment variable.
				WshProcEnv js> pop().Item(pop())=pop() ; 
	
: user-env  	( <name> -- value ) \ Get value from a User environment variable
				WshUserEnv js> pop().Item(nexttoken()) ;

: user-env@  	( "name" -- value ) \ Get value from a User environment variable
				WshUserEnv js> pop().Item(pop()) ;

: user-env!  	( value "name" -- ) \ Write to a User environment variable.
				WshUserEnv js> pop().Item(pop())=pop() ; 

: env@       	( "%name%" -- value ) \ Get value of the environment variable %NAME%
                js> WshShell.expandenvironmentstrings(pop()) ;

				<selftest>
				*** env variables
                ."  sys-env NUMBER_OF_PROCESSORS   = " s" NUMBER_OF_PROCESSORS"    sys-env@  . cr \ 小心此處餵給 sys-env@ proc-env@ 的 env variable name 不能有 white space。
                ."  sys-env OS                     = " s" OS"                      sys-env@  . cr
                ."  sys-env PATH                   = " s" PATH"                    sys-env@  . cr
                ."  sys-env PATHEXT                = " s" PATHEXT"                 sys-env@  . cr
                ."  sys-env PROCESSOR_ARCHITECTURE = " s" PROCESSOR_ARCHITECTURE"  sys-env@  . cr
                ."  sys-env PROCESSOR_IDENTIFIER   = " s" PROCESSOR_IDENTIFIER"    sys-env@  . cr
                ."  sys-env PROCESSOR_LEVEL        = " s" PROCESSOR_LEVEL"         sys-env@  . cr
                ."  sys-env PROCESSOR_REVISION     = " s" PROCESSOR_REVISION"      sys-env@  . cr
                ." proc-env ALLUSERSPROFILE        = " s" ALLUSERSPROFILE"         proc-env@ . cr
                ." proc-env APPDATA                = " s" APPDATA"                 proc-env@ . cr
                ." proc-env COMMONPROGRAMFILES     = " s" COMMONPROGRAMFILES"      proc-env@ . cr
                ." proc-env COMMONPROGRAMFILES(X86)= " s" COMMONPROGRAMFILES(X86)" proc-env@ . cr
                ." proc-env COMMONPROGRAMW6432     = " s" COMMONPROGRAMW6432"      proc-env@ . cr
                ." proc-env COMPUTERNAME           = " s" COMPUTERNAME"            proc-env@ . cr
                ." proc-env COMSPEC                = " s" COMSPEC"                 proc-env@ . cr
                ." proc-env HOMEDRIVE              = " s" HOMEDRIVE"               proc-env@ . cr
                ." proc-env HOMEPATH               = " s" HOMEPATH"                proc-env@ . cr
                ." proc-env LOCALAPPDATA           = " s" LOCALAPPDATA"            proc-env@ . cr
                ." proc-env LOGONSERVER            = " s" LOGONSERVER"             proc-env@ . cr
                ." proc-env PROCESSOR_ARCHITEW6432 = " s" PROCESSOR_ARCHITEW6432"  proc-env@ . cr
                ." proc-env PROGRAMDATA            = " s" PROGRAMDATA"             proc-env@ . cr
                ." proc-env PROGRAMFILES           = " s" PROGRAMFILES"            proc-env@ . cr
                ." proc-env PROGRAMFILES(X86)      = " s" PROGRAMFILES(X86)"       proc-env@ . cr
                ." proc-env PROGRAMW6432           = " s" PROGRAMW6432"            proc-env@ . cr
                ." proc-env PROMPT                 = " s" PROMPT"                  proc-env@ . cr
                ." proc-env PUBLIC                 = " s" PUBLIC"                  proc-env@ . cr
                ." proc-env SESSIONNAME            = " s" SESSIONNAME"             proc-env@ . cr
                ." proc-env SYSTEMDRIVE            = " s" SYSTEMDRIVE"             proc-env@ . cr
                ." proc-env SYSTEMROOT             = " s" SYSTEMROOT"              proc-env@ . cr
                ." proc-env TEMP                   = " s" TEMP"                    proc-env@ . cr
                ." proc-env TMP                    = " s" TMP"                     proc-env@ . cr
                ." proc-env USERDNSDOMAIN          = " s" USERDNSDOMAIN"           proc-env@ . cr
                ." proc-env USERDOMAIN             = " s" USERDOMAIN"              proc-env@ . cr
                ." proc-env USERNAME               = " s" USERNAME"                proc-env@ . cr
                ." proc-env USERPROFILE            = " s" USERPROFILE"             proc-env@ . cr
                ." proc-env WINDIR                 = " s" WINDIR"                  proc-env@ . cr
                ." env      ERRORLEVEL             = " s" %ERRORLEVEL%"            env@      . cr
				[d d] [p "sys-env@","proc-env@","env@" p]
				</selftest>

<comment>
------------ old implementations --------------------------------------------
s' WshSysEnv = WshShell.Environment("SYSTEM")' javascript drop
s' WshProcEnv = WshShell.Environment("PROCESS")' javascript drop
s' WshUserEnv = WshShell.Environment("USER")' javascript drop
.( WshSysEnv.length  = ) s" WshSysEnv.length  " javascript . cr
.( WshProcEnv.length = ) s" WshProcEnv.length " javascript . cr
.( WshUserEnv.length = ) s" WshUserEnv.length " javascript . cr

code sys-env    ( <name> -- value ) \ Get value from a System environment variable
                stack.push(WshSysEnv.Item(nexttoken()));
                end-code
code sys-env!   ( value "name" -- ) \ Write to a System environment variable. You can try but this activity may not success. Vista ok, Win7 Error message is : 沒有使用權限
                var name= stack.pop(); var value=stack.pop(); WshSysEnv.Item(name) = value;
                end-code
code sys-env@   ( "name" -- value ) \ Get value from a System environment variable
                stack.push(WshSysEnv.Item(stack.pop()));
                end-code
code proc-env   ( <name> -- value ) \ Get value from a Process environment variable
                stack.push(WshProcEnv.Item(nexttoken()));
                end-code
code proc-env@  ( "name" -- value ) \ Get value from a Process environment variable
                stack.push(WshProcEnv.Item(stack.pop()));
                end-code
code proc-env!  ( value "name" -- ) \ Write to a Process environment variable.
                var name= stack.pop(); var value=stack.pop(); WshSysProc.Item(name) = value;
                end-code
code user-env   ( <name> -- value ) \ Get value from a User environment variable
                stack.push(WshUserEnv.Item(nexttoken()));
                end-code
code user-env@  ( "name" -- value ) \ Get value from a User environment variable
                stack.push(WshUserEnv.Item(stack.pop()));
                end-code
code user-env!  ( value "name" -- ) \ Write to a User environment variable.
                var name= stack.pop(); var value=stack.pop(); WshUserEnv.Item(name) = value;
                end-code
code env@       ( "%name%" -- value ) \ Get value of the environment variable %NAME%
                stack.push(WshShell.expandenvironmentstrings(stack.pop()))
                end-code
</comment>


