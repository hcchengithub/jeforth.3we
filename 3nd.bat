cd %~dp0
if a%COMPUTERNAME%==aWKS-38EN3476     set NODEJSHOME=C:\Program Files\nodejs
if a%COMPUTERNAME%==aWKS-4AEN0404     set NODEJSHOME=C:\Program Files\nodejs
set NODE_PATH=%NODEJSHOME%\node_modules
@REM set NODE_PATH=%NODEJSHOME%\node_modules

node jeforth.3nd.js %*
