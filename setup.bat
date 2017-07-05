: @rem ; ' \ aliases echo @echo @echo. @goto :end jeforth.hta @rem cd call @if :ERR pause :END
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
        s" mklink /d _a\log             _h\log              " ah (dos) 1 ckp
        s" mklink /d _a\3htm            _h\3htm             " ah (dos) 2 ckp
        s" mklink /d _a\demo            _h\demo             " ah (dos) 3 ckp
        s" mklink /d _a\external-modules _h\external-modules" ah (dos) 4 ckp
        s" mklink /d _a\f               _h\f                " ah (dos) 5 ckp
        s" mklink /d _a\js              _h\js               " ah (dos) 6 ckp
        s" mklink /d _a\playground      _h\playground       " ah (dos) 7 ckp
        s" mklink /d _a\project-k       _h\project-k        " ah (dos) 8 ckp
        s" mklink /d _a\doc             _h\doc              " ah (dos) 9 ckp
        ;

\ 3ca   Chrome Applications
    .( Chrome Applications jeforth.3ca ) cr
    char ..\jeforth.3ca to _a _a GetFolder [if] [else]
    s" md _a" :> replace(/_a/,vm[current]._a)        (dos) 110 ckp
    setup-common-folders \ mirror of common folders  
    \ application specific files and folders         
    s" mklink    _a\_f  _h\log\_f" ahf 3ca.log.txt   (dos) 111 ckp
    s" mklink    _a\_f  _h\3ca\_f" ahf manifest.json (dos) 112 ckp
    s" mklink /d _a\3ca _h\3ca"    ah                (dos) 113 ckp
    s" mklink /h _a\_f  _h\_f"     ahf common.css    (dos) 114 ckp
    s" mklink /h _a\_f  _h\_f"     ahf index.html    (dos) 115 ckp
    [then]
\ 3ce   Chrome Extensions
    .( Chrome Extensions jeforth.3ce ) cr
    char ..\jeforth.3ce to _a _a GetFolder [if] [else]
    s" md _a" :> replace(/_a/,vm[current]._a)                       (dos) 120 ckp
    setup-common-folders \ mirror of common folders
    \ application specific files and folders
    s" mklink    _a\_f  _h\3ce\_f" ahf manifest.json                (dos) 121 ckp
    s" mklink /d _a\3ce _h\3ce"    ah                               (dos) 123 ckp
    s" mklink /h _a\_f  _h\3ce\_f" ahf jeforth.3ce.background.html  (dos) 122 ckp
    s" mklink /h _a\_f  _h\_f"     ahf common.css                   (dos) 124 ckp
    s" mklink /h _a\_f  _h\3ce\_f" ahf jeforth.3ce.html             (dos) 125 ckp
    [then]
\ 3hta  Windows HEML Applications
    .( Windows HEML Applications jeforth.3hta ) cr
    char ..\jeforth.3hta to _a _a GetFolder [if] [else]
    s" md _a" :> replace(/_a/,vm[current]._a)       (dos) 130 ckp
    setup-common-folders \ mirror of common folders
    \ application specific files and folders
    s" mklink /d _a\3hta _h\3hta" ah                (dos) 131 ckp
    s" mklink /h _a\_f _h\_f"     ahf jeforth.hta   (dos) 132 ckp
    s" mklink /h _a\_f _h\_f"     ahf common.css    (dos) 133 ckp
    s" mklink    _a\_f _h\_f"     ahf 3hta.bat      (dos) 134 ckp
    [then]
\ 3nd   Node.js
    .( Node.js jeforth.3nd ) cr
    char ..\jeforth.3nd to _a _a GetFolder [if] [else]
    s" md _a" :> replace(/_a/,vm[current]._a)       (dos) 140 ckp
    setup-common-folders \ mirror of common folders
    \ application specific files and folders
    s" mklink /d _a\3nd _h\3nd" ah                  (dos) 141 ckp
    s" mklink /h _a\_f _h\_f"   ahf jeforth.3nd.js  (dos) 142 ckp
    s" mklink    _a\_f _h\_f"   ahf 3nd.bat         (dos) 134 ckp
    [then]
\ 3nw   NW.js
    .( NW.js jeofrth.3nw ) cr
    char ..\jeforth.3nw to _a _a GetFolder [if] [else]
    s" md _a" :> replace(/_a/,vm[current]._a)        (dos) 150 ckp
    setup-common-folders \ mirror of common folders  
    \ application specific files and folders         
    s" mklink /d _a\3nw _h\3nw" ah                   (dos) 151 ckp
    s" mklink /h _a\_f _h\_f"   ahf package.json     (dos) 152 ckp
    s" mklink /h _a\_f _h\_f"   ahf jeforth.3nw.html (dos) 152 ckp
    s" mklink /h _a\_f _h\_f"   ahf common.css       (dos) 153 ckp
    s" mklink /d _a\3nd _h\3nd" ah                   (dos) 154 ckp
    s" mklink    _a\_f _h\_f"   ahf 3nw.bat          (dos) 134 ckp
    [then]
    
\ 3htm HTML 
    .( HTML jeforth.3htm ) cr
    char ..\jeforth.3htm to _a _a GetFolder [if] [else]
    s" md _a" :> replace(/_a/,vm[current]._a)        (dos) 160 ckp
    setup-common-folders \ mirror of common folders
    \ application specific files and folders
    s" mklink /h _a\_f  _h\_f"     ahf common.css    (dos) 161 ckp
    s" mklink /h _a\_f  _h\_f"     ahf index.html    (dos) 162 ckp
    [then]
    
\ Bye
    <o> <h1 style="text-align:center"> 
    jeforth.3we application setup is successfully done </h1>
    <h3 style="text-align:center">Automatically close in 30 seconds</h3> 
    </o> drop 0 ( errorlevel ) 30000 nap
    bye     \ TOS will be the errorlevel returned to DOS, 
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



