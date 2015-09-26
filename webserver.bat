
@echo We need a WEB server to run jeforth.3htm from local or remote, http://localhost:8888 
@echo 原本是 node.js 的 webserver.js 改成 jeforth 有何好處?
@echo jeforth.3nd 有 cd dir 等 dos command 所以 cd 既可以查看 working
@echo directory (或稱 root directory) 又可以任意改變它。讚! 讚! 讚!

node   jeforth.3nd.js include webserver.f

@rem Python is a good Web server oneliner, but something wrong with iframe so I drop it.
@rem if a%COMPUTERNAME%==aWKS-38EN3476    python -m SimpleHTTPServer 8888
@rem if a%COMPUTERNAME%==aWKS-38EN3477    python -m SimpleHTTPServer 8888
@rem if a%COMPUTERNAME%==aDESKTOP-Q94AC8A python -m http.server 8888

