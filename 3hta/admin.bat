
@rem Pause and quit if the script is not running with admin PRIVILEGES
@rem from stackoverflow : http://stackoverflow.com/questions/4051883/batch-script-how-to-check-for-admin-rights#11995662

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
   EXIT 
)
@echo ON

