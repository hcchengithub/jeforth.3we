: @rem ; ' \ dup alias echo dup alias @echo dup alias @echo. dup alias @goto dup alias :end dup alias jeforth.hta dup alias @rem dup alias cd alias call
cd %~dp0
@rem 
@rem   S e t u p . b a t 
@rem   
@rem   jeforth applications offten need their own directory structure. 
@rem   Chrome App and Chrome Extension both require a 'manifest.json' 
@rem   file at their home directory. So the jeforth.3we/ root can not 
@rem   be the common home. Other requirements like 3nw's package.json 
@rem   and jeforth.3nw.html; 3nd's jeforth.3nd.js; and 3htm's index.html
@rem   alougth they are not conflicting. Each application to have their
@rem   own directory but share the same GitHub repository through 
@rem   mirror linkages of symbolic link and hard link is the solution.
@rem   
@rem   This batch program creates application folders: jeforth.3ca, 
@rem   jeforth.3ce, jeforth.3hta, jeforth.3nw, and jeforth.3nd. They
@rem   are just mirrors of subset of jefforth.3we. It's safe to delete 
@rem   them. Run setup.bat again to rebuild them if any of them are not
@rem   existing. setup.bat won't rebuild existing applications for safe.
@rem   
@rem   Note! This batch must be "Run as administrator" due to priviledge
@rem   commands like mklink.exe and fsutil.exe are utilized. Right click
@rem   setup.bat and select "Run as administrator" to run it.
@rem   
@rem   H.C. Chen 13:24 2016-11-22
@rem 

@echo.
@echo Executing %~nx0 . . . 
@goto batch
\ --------------- start jeforth code ----------------------
\ Preparations
	also wsh.f definitions \ Use wsh.f's "run" command
	0 value flag // ( -- value ) Accumulator of error count
	: +=flag flag + to flag ; // ( n -- flag+=n ) Add TOS to flag
	: ckp ( f #cp -- ) \ Check point, pause and warn if f is true. #cp is check point number.
		swap if 
			s" <h1> Error at check point ##cp </h1>" 
			:> replace(/#cp/,pop()) </o> *debug* err> 
		else
			\ Leave the check point on data stack if no error. It can be useful.
		then ;
		/// Leave a hint when something wrong.
	"" value _a // ( -- path ) Path of the Application currently working on.
	char ..\jeforth.3we constant _h // ( -- path ) path of the Home directory
	: ah ( s -- s' ) \ Replace _a and _h with application path and home path
		:> replace(/_a/g,vm[current]._a).replace(/_h/g,vm[current]._h) ;
	: ahf ( s <filename> -- s' ) \ ah plus _f with filename
		BL word swap ( filename s ) ah :> replace(/_f/g,pop()) ;
	: setup-common-folders ( -- ) \ Setup jeforth common folders
		s" cmd /c mklink /d _a\log 				_h\log              " ah (run)  1 ckp
		s" cmd /c mklink /d _a\3htm 			_h\3htm             " ah (run)  2 ckp
		s" cmd /c mklink /d _a\demo 			_h\demo             " ah (run)  3 ckp
		s" cmd /c mklink /d _a\external-modules _h\external-modules " ah (run)  4 ckp
		s" cmd /c mklink /d _a\f 				_h\f                " ah (run)  5 ckp
		s" cmd /c mklink /d _a\js 				_h\js               " ah (run)  6 ckp
		s" cmd /c mklink /d _a\playground 		_h\playground       " ah (run)  7 ckp
		s" cmd /c mklink /d _a\project-k 		_h\project-k        " ah (run)  8 ckp
		s" cmd /c mklink /d _a\private 			_h\private          " ah (run)  9 ckp
		s" cmd /c mklink /d _a\doc              _h\doc              " ah (run) 10 ckp
		;

\ 3ca	Chrome Applications
	char ..\jeforth.3ca to _a _a GetFolder [if] [else]
	s" cmd /c md _a" :> replace(/_a/,vm[current]._a)      (run) 110 ckp
	setup-common-folders \ mirror of common folders
	\ application specific files and folders
	s" cmd /c mklink    _a\_f  _h\log\_f" ahf 3ca.log.txt 	(run) 111 ckp
	s" cmd /c mklink    _a\_f  _h\3ca\_f" ahf manifest.json (run) 112 ckp
	s" cmd /c mklink /d _a\3ca _h\3ca"    ah 				(run) 113 ckp
	s" cmd /c mklink /h _a\_f  _h\_f"     ahf common.css	(run) 114 ckp
	s" cmd /c mklink /h _a\_f  _h\_f"     ahf index.html	(run) 115 ckp
	[then]
\ 3ce	Chrome Extensions
	char ..\jeforth.3ce to _a _a GetFolder [if] [else]
	s" cmd /c md _a" :> replace(/_a/,vm[current]._a) 								(run) 120 ckp
	setup-common-folders \ mirror of common folders
	\ application specific files and folders
	s" cmd /c mklink    _a\_f  _h\3ce\_f" ahf manifest.json 				(run) 121 ckp
	s" cmd /c mklink /d _a\3ce _h\3ce"    ah 								(run) 123 ckp
	s" cmd /c mklink /h _a\_f  _h\3ce\_f" ahf jeforth.3ce.background.html	(run) 122 ckp
	s" cmd /c mklink /h _a\_f  _h\_f"     ahf common.css					(run) 124 ckp
	s" cmd /c mklink /h _a\_f  _h\3ce\_f" ahf jeforth.3ce.html				(run) 125 ckp
	[then]
\ 3hta	Windows HEML Applications
	char ..\jeforth.3hta to _a _a GetFolder [if] [else]
	s" cmd /c md _a" :> replace(/_a/,vm[current]._a)		(run) 130 ckp
	setup-common-folders \ mirror of common folders
	\ application specific files and folders
	s" cmd /c mklink /d _a\3hta _h\3hta" ah 				(run) 131 ckp
	s" cmd /c mklink /h _a\_f _h\_f"     ahf jeforth.hta	(run) 132 ckp
	s" cmd /c mklink /h _a\_f _h\_f"     ahf common.css		(run) 133 ckp
	[then]
\ 3nd	Node.js
	char ..\jeforth.3nd to _a _a GetFolder [if] [else]
	s" cmd /c md _a" :> replace(/_a/,vm[current]._a)		(run) 140 ckp
	setup-common-folders \ mirror of common folders
	\ application specific files and folders
	s" cmd /c mklink /d _a\3nd _h\3nd"	ah 					(run) 141 ckp
	s" cmd /c mklink /h _a\_f _h\_f"	ahf jeforth.3nd.js	(run) 142 ckp
	
	[then]
\ 3nw	NW.js
	char ..\jeforth.3nw to _a _a GetFolder [if] [else]
	s" cmd /c md _a" :> replace(/_a/,vm[current]._a)		(run) 150 ckp
	setup-common-folders \ mirror of common folders
	\ application specific files and folders
	s" cmd /c mklink /d _a\3nw _h\3nw" ah 					(run) 151 ckp
	s" cmd /c mklink /h _a\_f _h\_f"   ahf package.json		(run) 152 ckp
	s" cmd /c mklink /h _a\_f _h\_f"   ahf jeforth.3nw.html	(run) 152 ckp
	s" cmd /c mklink /h _a\_f _h\_f"   ahf common.css		(run) 153 ckp
	s" cmd /c mklink /d _a\3nd _h\3nd" ah 					(run) 154 ckp
	[then]

bye \ TOS will be the errorlevel returned to DOS
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



