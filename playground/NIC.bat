: @rem ; ' \ aliases echo @echo @echo. @goto :end jeforth.hta @rem cd call @if :ERR pause :END
cd %~dp0
@rem 
@rem   N I C . b a t 
@rem   
@rem   
@rem   H.C. Chen 3:29 PM 6/27/2017
@rem 

@echo.
@echo Executing %~nx0 . . . 
@goto batch
\ --------------- start jeforth code ----------------------

." List all NIC" cr
"" getNIC  ( nic nic ... ) \ No where clause, get all of them
#nic ?dup [if] [for] 
	>r r@ :> caption . cr
	."  / NetConnectionStatus: " r@ :> NetConnectionStatus . cr
	."  / NetEnabled: " r@ :> NetEnabled . cr
	."  / NetworkAddresses: " r@ :> NetworkAddresses . cr
	."  / PermanentAddress: " r@ :> PermanentAddress . cr
	."  / Status: " r@ :> Status . cr
	r> drop
[next] [then]

." List active NIC" cr
activeNIC  ( nic nic ... ) \ assume there are many active NICs
#nic ?dup [if] [for] 
	>r r@ :> caption . cr
	."  / NetConnectionStatus: " r@ :> NetConnectionStatus . cr
	."  / NetEnabled: " r@ :> NetEnabled . cr
	."  / NetworkAddresses: " r@ :> NetworkAddresses . cr
	."  / PermanentAddress: " r@ :> PermanentAddress . cr
	."  / Status: " r@ :> Status . cr
	r> drop
[next] [then]

: nicoff ( -- ) \ Turn off the NIC
	s" where deviceid = 19" getNIC :> disable() 
	dup if 
		." Failed! Error code " . ." . Make sure to run as an administrator." cr
	else
		drop ." NIC device turned off sucessfully." cr
	then ;
	/// return 5 is failed when not an administrator

: nicon	( -- ) \ Turn on the NIC
	s" where deviceid = 19" getNIC :> enable() 
	dup if 
		." Failed! Error code " . ." . Make sure to run as an administrator." cr
	else
		drop ." NIC device turned on sucessfully." cr
	then ;
\ Usage guide
	<o> <h3 style="text-align:center">nicoff or nicon</h3></o> drop cr
	stop
	
\ ---------------- end jeforth code -----------------------

:batch
call admin.bat
@rem ---------- start batch code ---------------------------
start jeforth.hta include %~nx0 \ include the batch program itself
@if %errorlevel% GEQ 1 goto ERR
@rem ------------ end batch code ---------------------------

@goto END
:ERR
@echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
@echo   errorlevel : %errorlevel%
@echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
pause
:END



