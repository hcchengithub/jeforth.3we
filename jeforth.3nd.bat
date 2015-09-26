
if a%COMPUTERNAME%==aWKS-38EN3476     set NODEJSHOME=c:\Users\8304018\Dropbox\learnings\JavaScript\node.js
if a%COMPUTERNAME%==aDESKTOP-Q94AC8A  goto run
if a%COMPUTERNAME%==aT550             goto run
if a%COMPUTERNAME%==aWKS-38EN3477     set NODEJSHOME=c:\Users\8304018.WKSCN\Dropbox\learnings\JavaScript\node.js
path=%path%;%NODEJSHOME%
set NODE_PATH=%NODEJSHOME%\node_modules

@rem subst /d x:
@rem subst x: .
@rem x:
@rem chcp 950

:run
if a%COMPUTERNAME%==aWKS-38EN3476     node64 jeforth.3nd.js %1 %2 %3 %4 %5 %6 %7 %8 %9
if a%COMPUTERNAME%==aDESKTOP-Q94AC8A  node   jeforth.3nd.js %1 %2 %3 %4 %5 %6 %7 %8 %9
if a%COMPUTERNAME%==aT550  			  node   jeforth.3nd.js %1 %2 %3 %4 %5 %6 %7 %8 %9
if a%COMPUTERNAME%==aWKS-38EN3477     node64 jeforth.3nd.js %1 %2 %3 %4 %5 %6 %7 %8 %9


