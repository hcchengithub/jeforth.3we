: @rem ; ' \ aliases echo @echo @echo. @goto :end jeforth.hta @rem cd call @if :ERR pause :END
cd %~dp0
@rem 
@rem   release-test.bat
@rem   
@rem   H.C. Chen 13:24 2017-2-10
@rem 

@echo.
@echo Executing %~nx0 . . . 
@goto batch
\ --------------- start jeforth code ----------------------
wsh.f 
			
\ ---------------- end jeforth code -----------------------

:batch
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



