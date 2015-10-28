
\ netsh.f 利用 forth 的自由語法，簡化 netsh 使用。
\ articel the introduces netsh http://helpdeskgeek.com/networking/change-ip-address-and-dns-servers-using-the-command-prompt/
\ netsh manual https://technet.microsoft.com/en-us/library/cc754516

\ [x] 這個 project 破功了,因為部分 netsh.exe 的功能要求 administrator 權限：
\     "The requested operation requires elevation (Run as administrator)."
\     但是 WshShell.SendKeys 對 administrator mode 時的 process 無效，無法
\     由 jeforth.3hta 下達命令過去。
\ [ ] 嘗試由 jeforth.3hta 操控 PowerShell . . . . 

	js> vm.appname char jeforth.3hta != [if] 
		?abort" Sorry! netsh.f is for jeforth.3hta only." \s 
	[then]
	include vb.f
	s" netsh.f"   source-code-header

    : netsh-process-id (  -- processID ... n ) \ Get netsh processID(s) and count
        0 s" where name = 'netsh.exe'" objEnumWin32_Process >r  ( 0 | obj )
        begin
            r@  ( 0 obj | obj)
            js> !pop().atEnd() ( 0 NotAtEnd? )
        while ( count | obj )
            1+ ( count )
            r@ :> item().ProcessId swap ( processID ... count | obj )
        r@ js: pop().moveNext() repeat ( ... count | obj )
        r> drop ;
        
    : netsh ( -- netsh-process-id ) \ Abort if netsh is not running or multiple.
        netsh-process-id <js>
		switch(pop()){
			case 0: panic(" Error! netsh is not running.",true);
			case 1: break;
			default: panic(" Error! multiple netsh are running.",true); 
		}
		</js> ;

    : activate-netsh ( -- ) \ Active netsh.exe, make it on top of the Windows desktop.
        500 nap netsh ?dup if ( processID )
            s' WshShell.AppActivate ' swap + </vb> 
        then 500 nap ;
		
    : activate-jeforth ( -- ) \ Come back to jeforth.3hta
        1000 nap s" WshShell.AppActivate " vm.process :> processID + </vb> 500 nap ;

    : <netsh> ( <command line> -- ) \ Command line to the Git Shell
        char {enter}{enter} char </netsh> word + compiling if literal then ; immediate
		/// Example:
		/// <netsh> int show interface</netsh> <-- list NICs
		/// <netsh> interface ipv4 show dnsserver ""Wi-Fi""</netsh> <-- see DNS
		/// Note! Use two "" instead of any " due to VBscript syntax.

    : </netsh> ( "command line" -- ) \ Send command line to netsh
        compiling if 
            compile netsh compile drop
            \ '^' and '~' 是 sendkey 的 special character 要改成 "{^}" and "{~}"
            js: push(function(){push(pop().replace(/\^/g,"{^}").replace(/~/g,"{~}"))}) 
            , compile activate-netsh
            s' WshShell.SendKeys "' literal compile swap compile + s' {enter}"' literal 
            compile + [compile] </vb> compile activate-jeforth
        else 
            netsh drop
            js> pop().replace(/\^/m,"{^}").replace(/~/g,"{~}") activate-netsh
            s' WshShell.SendKeys "' swap + s' {enter}"' + </vb> activate-jeforth
        then ; immediate
		
	: dnsserver ( -- ) \ Show recent DNS server		
		<netsh> interface ipv4 show dnsserver ""Wi-Fi"" </netsh> ;

	: use-google-dns ( -- ) \ Switch DNS to google's 8.8.8.8 and 8.8.4.4
		<netsh> int ipv4 set dns name=""Wi-Fi"" static 8.8.8.8 primary validate=no</netsh> 
		<netsh> int ipv4 add dns name=""Wi-Fi"" 8.8.4.4 index=2 validate=no</netsh> ;
		/// 這個功能破功了,因為：
		/// The requested operation requires elevation (Run as administrator).
		/// 但是 WshShell.SendKeys 對 administrator mode 時的 process 無效。

	: use-DHCP-dns \ Switch DNS to DHCP
		<netsh> interface ipv4 set dnsservers ""Wi-Fi"" dhcp </netsh> ;
		
	<comment>        
		http://stackoverflow.com/questions/18620173/how-can-i-set-change-dns-using-the-command-prompt-at-windows-8
		要求的作業需要提高的權限 (以系統管理員身分執行)。
		-- Find the interface name --
		netsh interface show interface
		-- Change the interface's DNS to google
		netsh int ipv4 set dns name="乙太網路 2" static 8.8.8.8 primary validate=no
		netsh int ipv4 add dns name="乙太網路 2" 8.8.4.4 index=2 validate=no
		-- Change the interface's DNS to automatic
		netsh interface ipv4 set dnsservers "乙太網路 2" dhcp
		-- See the DNS of the interface
		netsh interface ipv4 show dnsserver "乙太網路 2"
		-- example
		C:\Windows\system32>netsh interface ipv4 show dnsserver "乙太網路 2"

		介面 "乙太網路 2" 的設定
			靜態設定的 DNS 伺服器:                8.8.8.8
												  8.8.4.4
			以哪個尾碼登錄:                       僅主要尾碼
		--
		C:\Windows\system32>netsh interface ipv4 set dnsservers "乙太網路 2" dhcp


		C:\Windows\system32>netsh interface ipv4 show dnsserver "乙太網路 2"

		介面 "乙太網路 2" 的設定
			透過 DHCP 設定的 DNS 伺服器:  192.168.0.1
			以哪個尾碼登錄:                       僅主要尾碼
		--

	</comment>