@rem 
@rem Create symbolic links to the 3HTA working directory.
@rem 
@rem   Hard links are real file headers that share the same file pathname. Many hard links 
@rem can be sharing the same file or directory and all of them are equal, no master. While 
@rem symbolic link is a virtual file pathname that points to the real file or directory. For 
@rem cloud safety, I guess, symblic links may not be acceptable to web browsers. In that cases, 
@rem use hard link instead.
@rem
@rem H.C. Chen 08:51 2017-07-05
@rem 

cd %~dp0

@rem ~%~%~%~%~%~%~%~%~%~%~%~%~%~  admin.bat  ~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~
@rem mklink.exe and fsutil.exe need administrator priviledges, check it.
echo OFF
NET SESSION >nul 2>&1
IF %ERRORLEVEL% EQU 0 (
    ECHO Administrator PRIVILEGES Detected! 
) ELSE (
   echo.
   echo.
   echo  88b 88  dP"Yb  888888        db    8888b.  8b    d8 88 88b 88 
   echo  88Yb88 dP   Yb   88         dPYb    8I  Yb 88b  d88 88 88Yb88 
   echo  88 Y88 Yb   dP   88        dP__Yb   8I  dY 88YbdP88 88 88 Y88 
   echo  88  Y8  YbodP    88       dP""""Yb 8888Y"  88 YY 88 88 88  Y8 
   echo.
   echo ####### ERROR: ADMINISTRATOR PRIVILEGES REQUIRED #########
   echo This script must be run as administrator to work properly!  
   echo Try again with right click and select "Run As Administrator".
   echo ##########################################################
   echo.
   PAUSE
   @rem EXIT /B 1
)
@echo ON
@rem ~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~

這個後來用不著了, 把 nicon nicoff 做進 wmi.f LRV2 specific 也不管了
abort mklink nic.bat ..\jeforth.3we\3hta\nic.bat
abort mklink admin.bat ..\jeforth.3we\admin.bat

