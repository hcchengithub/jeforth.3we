cd %~dp0

set NODEJSHOME=C:\Program Files\nodejs
if a%COMPUTERNAME%==aWKS-38EN3476     set NODEJSHOME=C:\Program Files\nodejs
if a%COMPUTERNAME%==aWKS-4AEN0404     set NODEJSHOME=C:\Program Files\nodejs
if a%COMPUTERNAME%==aDESKTOP-Q4DUVFG  set NODEJSHOME=C:\Program Files\nodejs
set NODE_PATH=%NODEJSHOME%\node_modules;%NODEJSHOME%\node_modules\simplemde\node_modules
path=c:\Users\hcchen\AppData\Roaming\npm\node_modules\nw\SDK;%path%
start nw ../jeforth.3nw nop %*

