if a%COMPUTERNAME%==aWKS-38EN3476     set CHROMEPATH=c:\Program Files (x86)\Google\Chrome\Application
if a%COMPUTERNAME%==aWKS-38EN3476     set NWPATH=c:\Users\8304018\Dropbox\learnings\node-webkit\node-webkit-v0.7.0-win-ia32
if a%COMPUTERNAME%==aWKS-38EN3476     set NODEJSHOME=c:\Users\8304018\Dropbox\learnings\JavaScript\node.js

if a%COMPUTERNAME%==aWKS-38EN3477     set CHROMEPATH=c:\Program Files (x86)\Google\Chrome\Application
if a%COMPUTERNAME%==aWKS-38EN3477     set NWPATH=c:\Users\8304018.WKSCN\Dropbox\learnings\node-webkit\node-webkit-v0.7.0-win-ia32
if a%COMPUTERNAME%==aWKS-38EN3477     set NODEJSHOME=c:\Users\8304018.WKSCN\Dropbox\learnings\JavaScript\node.js

if a%COMPUTERNAME%==aDESKTOP-Q94AC8A  goto run
if a%COMPUTERNAME%==aT550  goto run


path=%CHROMEPATH%;%NWPATH%;%NODEJSHOME%

chcp 950

@REM ------ debug -------------------
@REM chrome.exe http://127.0.0.1:9222
@REM nw --remote-debugging-port=9222 ../jeforth.3we

@REM ------ working ----------------
@REM nw ../jeforth.3we

:run
start nw ../jeforth.3we %1 %2 %3 %4 %5 %6 %7 %8 %9


