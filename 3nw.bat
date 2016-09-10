cd %~dp0

@REM ------ debug -------------------
@REM chrome.exe http://127.0.0.1:9222
@REM nw --remote-debugging-port=9222 ../jeforth.3we

set NODEJSHOME=C:\Program Files\nodejs
if a%COMPUTERNAME%==aWKS-38EN3476     set NODEJSHOME=C:\Program Files\nodejs
if a%COMPUTERNAME%==aWKS-4AEN0404     set NODEJSHOME=C:\Program Files\nodejs
if a%COMPUTERNAME%==aDESKTOP-Q4DUVFG  set NODEJSHOME=C:\Program Files\nodejs
set NODE_PATH=%NODEJSHOME%\node_modules;%NODEJSHOME%\node_modules\simplemde\node_modules
start nw ../jeforth.3we nop %1 %2 %3 %4 %5 %6 %7 %8 %9


