
if a%COMPUTERNAME%==aWKS-38EN3476     set NODEJSHOME=c:\Users\8304018\Dropbox\learnings\JavaScript\node.js
if a%COMPUTERNAME%==aDP-20121028UGNO  set NODEJSHOME=d:\hcchen\Dropbox\learnings\JavaScript\node.js
if a%COMPUTERNAME%==aWKS-38EN3477     set NODEJSHOME=c:\Users\8304018.WKSCN\Dropbox\learnings\JavaScript\node.js
path=%path%;%NODEJSHOME%

subst /d x:
subst x: .
x:
chcp 950

if a%COMPUTERNAME%==aWKS-38EN3476     node64 jeforth.3nd.js %1 %2 %3 %4 %5 %6 %7 %8 %9
if a%COMPUTERNAME%==aDP-20121028UGNO  node32 jeforth.3nd.js %1 %2 %3 %4 %5 %6 %7 %8 %9
if a%COMPUTERNAME%==aWKS-38EN3477     node64 jeforth.3nd.js %1 %2 %3 %4 %5 %6 %7 %8 %9

