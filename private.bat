: @rem ; ' \ aliases echo @echo @echo. @goto :end jeforth.hta @rem cd call @if :ERR pause :END
cd %~dp0
@rem 
@rem   P r i v a t e . b a t 
@rem   
@rem   Same reason as setup.bat but create the 'private' folder only which is not created
@rem   by setup.bat to protect personal data.
@rem   
@rem   H.C. Chen 13:37 2017-03-13
@rem 

@echo.
@echo Executing %~nx0 . . . 
@goto batch
\ --------------- start jeforth code ----------------------
\ Preparations
	er .( Prepare forth commands ) cr
	also wsh.f definitions \ Use wsh.f's "run" command
	0 value flag // ( -- value ) Accumulator of error count
	: +=flag flag + to flag ; // ( n -- flag+=n ) Add TOS to flag
	: ckp ( f #cp -- ) \ Check point, pause and warn if f is true. #cp is check point number.
		swap if 
			s" <h1> Error at check point ##cp </h1>" 
			:> replace(/#cp/,pop()) </o> *debug* err> 
		else
			\ Leave the check point on data stack if no error. 
			\ It can be useful for debugging.
		then ;
		/// Leave a hint when something wrong.
	"" value _a // ( -- path ) Path of the Application currently working on.
	char ..\jeforth.3we constant _h // ( -- path ) path of the Home directory
	: ah ( s -- s' ) \ Replace _a and _h with application path and home path
		:> replace(/_a/g,vm[current]._a).replace(/_h/g,vm[current]._h) ;
	: ahf ( s <filename> -- s' ) \ ah plus _f with filename
		BL word swap ( filename s ) ah :> replace(/_f/g,pop()) ;
	: setup-common-folders ( -- ) \ Setup jeforth common folders
		s" mklink /d _a\log 			_h\log              " ah (dos) 1 ckp
		s" mklink /d _a\3htm 			_h\3htm             " ah (dos) 2 ckp
		s" mklink /d _a\demo 			_h\demo             " ah (dos) 3 ckp
		s" mklink /d _a\external-modules _h\external-modules" ah (dos) 4 ckp
		s" mklink /d _a\f 				_h\f                " ah (dos) 5 ckp
		s" mklink /d _a\js 				_h\js               " ah (dos) 6 ckp
		s" mklink /d _a\playground 		_h\playground       " ah (dos) 7 ckp
		s" mklink /d _a\project-k 		_h\project-k        " ah (dos) 8 ckp
		s" mklink /d _a\doc             _h\doc              " ah (dos) 9 ckp
		;

\ 3ca	Chrome Applications
	.( Chrome Applications jeforth.3ca ) cr
	char ..\jeforth.3ca to _a _a GetFolder [if]
		s" mklink /d _a\private _h\private" ah (dos) 113 ckp
	[then]
\ 3ce	Chrome Extensions
	.( Chrome Extensions jeforth.3ce ) cr
	char ..\jeforth.3ce to _a _a GetFolder [if]
		s" mklink /d _a\private _h\private" ah (dos) 123 ckp
	[then]
\ 3hta	Windows HEML Applications
	.( Windows HEML Applications jeforth.3hta ) cr
	char ..\jeforth.3hta to _a _a GetFolder [if]
		s" mklink /d _a\private _h\private" ah (dos) 133 ckp
	[then]
\ 3nd	Node.js
	.( Node.js jeforth.3nd ) cr
	char ..\jeforth.3nd to _a _a GetFolder [if]
		s" mklink /d _a\private _h\private" ah (dos) 143 ckp
	[then]
\ 3nw	NW.js
	.( NW.js jeofrth.3nw ) cr
	char ..\jeforth.3nw to _a _a GetFolder [if]
		s" mklink /d _a\private _h\private" ah (dos) 153 ckp
	[then]
\ 3htm HTML 
	.( HTML jeforth.3htm ) cr
	char ..\jeforth.3htm to _a _a GetFolder [if]
		s" mklink /d _a\private _h\private" ah (dos) 163 ckp
	[then]

\ Bye
	<o> <h1 style="text-align:center"> 
	jeforth.3we application setup is successfully done </h1>
	<h3 style="text-align:center">Automatically close in 30 seconds</h3> 
	</o> drop 0 ( errorlevel ) 30000 nap
	bye 	\ TOS will be the errorlevel returned to DOS, 
			\ errors were handeled above we don't need it.
			
\ ---------------- end jeforth code -----------------------

:batch
call admin.bat
@rem ---------- start batch code ---------------------------
jeforth.hta include %~nx0 \ include the batch program itself
@if %errorlevel% GEQ 1 goto ERR
@rem ------------ end batch code ---------------------------

@goto END
:ERR
@echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
@echo   errorlevel : %errorlevel%
@echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
pause
:END



