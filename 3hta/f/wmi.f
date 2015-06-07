
\ WMI.f  例舉 WMI 的應用。 

s" wmi.f"	source-code-header

\
\ WMI 可以 access 的東西非常多。這麼多可用的東西頭腦記不得，必須上網查詢，查詢的網址、以及
\ 由 Win32_1394Controller 開始到 Win32_WMISetting 止的幾百個 WMI class 列表附在本檔最下面供
\ 參考。
\

\ Most of wmi.f tools are working on a target computer which can be "localhost" , "." or an IP address or computer
\ name of a remote computer. We need to specify it to a constant named "t/c". If t/c is not defined then it will be
\ "localhost" by default. Define t/c before include wmi.f in command line if your target computer is not localhost.

\ 如果在 include wmi.f 之前先設定 t/c 之值，則整套 wmi.f 都 refer to the specified t/c. 所以你可以去 access 別的機器.
\ 例如 "cscript jeforth.js s' 10.34.98.76' constant t/c include wmi.f list-some-OS-properties" 可以去看遠端機器的內容。
\ 若不先給定 t/c 則以下這段程式會把 t/c 設成 localhost 所以是對本地電腦工作。我不想每次都得指定 target computer 因此
\ 做此安排。

' t/c [if] [else]
	s" localhost" constant t/c // ( -- "target-computer" ) wmi.f tools' default target computer is "localhost".
[then]

: getWMIService	( "target computer" -- objWMIService ) \ Get WMI service object of the target-computer.
				s" winmgmts:{impersonationLevel=impersonate}!\\" swap + s" \root\cimv2" +
				<vb> Set o = GetObject(kvm.pop()): kvm.push(o) </vb> ; 

\ Create JavaScript global variable kvm.objWMIService
t/c getWMIService js: kvm.objWMIService=pop() 
				
\ WMI Win32_NetworkAdapterConfiguration class
\ http://msdn.microsoft.com/en-us/library/windows/desktop/aa394217(v=vs.85).aspx
: objEnumWin32_NetworkAdapterConfiguration 
				( "where-clause" -- objEnumWin32_NetworkAdapterConfiguration ) \ Get Win32_NetworkAdapterConfiguration object onto TOS.
				<js> 
					new Enumerator(
						kvm.objWMIService.ExecQuery("Select * from Win32_NetworkAdapterConfiguration "+pop())
					) 
				</jsV> ;

\ Iterate all network cards (NIC) in this computer list all Network adapters' IP address
: printIPAddress 
				( -- ) \ Print (all) IP Addresses
				s" where IPEnabled = true" objEnumWin32_NetworkAdapterConfiguration >r
				begin
					r@ js> pop().atEnd() if r> drop exit then
					r@ js> pop().item().caption . space
					r@ js> pop().item().IPAddress .VBArray cr
				    r@ js: pop().moveNext() 
				again
				;
				
				<selftest>
					marker -%-%-%-%-%-
					***** get WMI object, get NIC config, print IP addresses ...... 
					js: kvm.screenbuffer=kvm.screenbuffer?kvm.screenbuffer:""; \ enable kvm.screenbuffer, it stops working if is null.
					js> kvm.screenbuffer.length constant start-here // ( -- n ) 開始測試前的 kvm.screenbuffer 尾巴。
					\ Start to do anything ...
					js> kvm.objWMIService js> typeof(pop()) \ "object" 
					printIPAddress
					\ .... done, start checking ...
					start-here <js> kvm.screenbuffer.indexOf("thernet",pop())!=-1 </jsV> \ true  Ethernet
					start-here <js> kvm.screenbuffer.indexOf("dapter",pop())!=-1 </jsV> \ true   Adapter
					start-here <js> kvm.screenbuffer.indexOf("ireless",pop())!=-1 </jsV> \ true  Wireless
					start-here <js> kvm.screenbuffer.indexOf("ontroller",pop())!=-1 </jsV> \ true  Controller
					or or or
					js> stack.slice(0) <js> ["object",true] </jsV> isSameArray >r dropall r>
					-->judge [if] <js> [
						't/c',
						'getWMIService',
						'objEnumWin32_NetworkAdapterConfiguration',
						'printIPAddress'
					] </jsV> all-pass [else] *debug* selftest-failed->>> [then]
					-%-%-%-%-%-
				</selftest>

\ 利用 jeforth for WSH 與其 JavaScript console 手動來操作 WMI 很有用，沒必要寫一大堆人機介面。
\ 跑一下 objEnumWin32_OperatingSystem 準備好 Win32_OperatingSystem object 放在 TOS，此後用 console 進 js console, 
\ var os = pop(), 即可用 os 來 access 所有 Win32_OperatingSystem 的東西。例如：
\     os.item().caption,      os.item().bootdevice,      os.item().countrycode, 
\     os.item().installdate,  os.item().lastbootuptime,  os.item().systemdrive, 
\	  os.item().totalvisiblememorysize 
\ 等等。 這個建議對所有 WMI classes 都適用。

\ Win32_OperatingSystem class
\ http://msdn.microsoft.com/en-us/library/windows/desktop/aa394239(v=vs.85).aspx
code objEnumWin32_OperatingSystem 
				( -- objEnumWin32_OperatingSystem ) \ Get WMI OS object onto TOS.
				push(new Enumerator(kvm.objWMIService.InstancesOf("Win32_OperatingSystem")));
				end-code 

\  win32shutdown options
\ -------------------------------------- 
\  Value    Meaning
\ -------------------------------------- 
\  0 (0x0)  Log Off                   目前研究到這裡，只有 log off 能用
\  4 (0x4)  Forced Log Off (0 + 4)    目前研究到這裡，只有 log off 能用
\  1 (0x1)  Shutdown                  doesn't work on Win7, JScript error : Privilege not held. 待搞懂 SE_SHUTDOWN_NAME
\  5 (0x5)  Forced Shutdown (1 + 4)   doesn't work on Win7, JScript error : Privilege not held. 待搞懂 SE_SHUTDOWN_NAME
\  2 (0x2)  Reboot                    doesn't work on Win7, JScript error : Privilege not held. 待搞懂 SE_SHUTDOWN_NAME
\  6 (0x6)  Forced Reboot (2 + 4)     doesn't work on Win7, JScript error : Privilege not held. 待搞懂 SE_SHUTDOWN_NAME
\  8 (0x8)  Power Off                 doesn't work on Win7, JScript error : Privilege not held. 待搞懂 SE_SHUTDOWN_NAME
\ 12 (0xC)  Forced Power Off (8 + 4)  doesn't work on Win7, JScript error : Privilege not held. 待搞懂 SE_SHUTDOWN_NAME
\ -------------------------------------- 
\ see also  Win32ShutdownTracker method and  SE_SHUTDOWN_NAME privilege, SetSuspendState function
\ To enable the SE_SHUTDOWN_NAME privilege, use the AdjustTokenPrivileges function. For more information, see Changing Privileges in a Token.
\ shutdown.exe since WinXP can do them all.
: win32shutdown ( option -- ) \ 0:logoff, 1:shutdown, 2:reboot, or 8:power off
				objEnumWin32_OperatingSystem js> pop().item().Win32Shutdown(pop()) ;

				<selftest>
					marker -%-%-%-%-%-
					***** Demo how to use objEnumWin32_OperatingSystem object ... 
					js> kvm.screenbuffer.length constant start-here // ( -- n ) 開始測試前的 kvm.screenbuffer 尾巴。
					objEnumWin32_OperatingSystem 
					.( Caption                ) dup js> pop().item().caption . cr
					.( BootdDvice             ) dup js> pop().item().bootdevice . cr
					.( CountryCode            ) dup js> pop().item().countrycode . cr
					.( InstallDate            ) dup js> pop().item().installdate . cr
					.( LastBootupTime         ) dup js> pop().item().lastbootuptime . cr
					.( SystemDrive            ) dup js> pop().item().systemdrive . cr
					.( TotalVisibleMemorySize )     js> pop().item().totalvisiblememorysize
					js> parseInt(pop()/1024) dup . space .( Mega Bytes) cr \ translate string to integer
					2000 > \ true 現在的電腦都有 2G 以上 memory 了吧！
					start-here <js> kvm.screenbuffer.indexOf("Microsoft Windows",pop())!=-1 </jsV> \ true
					js> stack.slice(0) <js> [true, true] </jsV> isSameArray >r dropall r>
					-->judge [if] <js> [
						'objEnumWin32_OperatingSystem'
					] </jsV> all-pass [else] *debug* selftest-failed->>> [then]
					-%-%-%-%-%-
				</selftest>

code objEnumWin32_ComputerSystem 
				( -- objEnumWin32_ComputerSystem ) \ Get WMI Win32_ComputerSystem object onto TOS.
				push(new Enumerator(kvm.objWMIService.InstancesOf("Win32_ComputerSystem")));
				end-code 
				
				<selftest>
					***** Demo how to use objEnumWin32_ComputerSystem object ... 
					marker -%-%-%-%-%-
					js> kvm.screenbuffer.length constant start-here // ( -- n ) 開始測試前的 kvm.screenbuffer 尾巴。
					( ------------ Start to do anything --------------- )
					objEnumWin32_ComputerSystem >r
					." Caption                " r@ js> pop().item().caption dup . cr    \ <<**** get caption
					." Number of Processors:  " r@ js> pop().item().NumberOfProcessors . cr
					." InstallDate            " r@ js> pop().item().InstallDate . cr
					." Manufacturer           " r@ js> pop().item().Manufacturer . cr
					." Model                  " r@ js> pop().item().Model . cr
					." ResetCount             " r@ js> pop().item().ResetCount . cr
					." TotalPhysicalMemory    " r@ js> pop().item().TotalPhysicalMemory . cr
					." System name            " r@ js> pop().item().name dup . cr \ <<**** get system name
					." Domain                 " r@ js> pop().item().Domain . cr
					r> drop
					( ------------ done, start checking ---------------- ) 
					= js> stack.slice(0) <js> [true] </jsV> isSameArray >r dropall r>
					-->judge [if] <js> [
						'objEnumWin32_ComputerSystem'
					] </jsV> all-pass [else] *debug* selftest-failed->>> [then]
					-%-%-%-%-%-
				</selftest>
				
				\ this is a one liner to show memory size in OS's point of view,
				\ jeforth.hta include wmi.f objEnumWin32_OperatingSystem s' pop().item().totalvisiblememorysize' jsEval s' Math.round(pop()/1024)' jsEval . space .( Mega bytes) \ bye
				
\ Win32_PhysicalMemory class
\ http://msdn.microsoft.com/en-us/library/windows/desktop/aa394347(v=vs.85).aspx
code objEnumWin32_PhysicalMemory 
				( -- objEnumWin32_PhysicalMemory ) \ Get WMI Win32_PhysicalMemory object onto TOS.
				push(new Enumerator(kvm.objWMIService.InstancesOf("Win32_PhysicalMemory")));
				end-code 
				
: list-some-Win32_PhysicalMemory-properties 
				( -- total-memory-size ) \ demo how to use objEnumWin32_PhysicalMemory
				objEnumWin32_PhysicalMemory >r
				0 \ total-memory-size
				begin
					." -------------------------------------------" cr
					." BankLabel             " r@ js> pop().item().BankLabel             . cr \ string   
					." Capacity              " r@ js> pop().item().Capacity              js> parseInt(pop()) dup . cr + \ uint64   
					." Caption               " r@ js> pop().item().Caption               . cr \ string   
					." DataWidth             " r@ js> pop().item().DataWidth             . cr \ uint16   
					." DeviceLocator         " r@ js> pop().item().DeviceLocator         . cr \ string   
					." FormFactor            " r@ js> pop().item().FormFactor            . cr \ uint16   
					." InterleaveDataDepth   " r@ js> pop().item().InterleaveDataDepth   . cr \ uint16   
					." InterleavePosition    " r@ js> pop().item().InterleavePosition    . cr \ uint32   
					." Manufacturer          " r@ js> pop().item().Manufacturer          . cr \ string   
					." MemoryType            " r@ js> pop().item().MemoryType            . cr \ uint16   
					." Model                 " r@ js> pop().item().Model                 . cr \ string   
					." PartNumber            " r@ js> pop().item().PartNumber            . cr \ string   
					." SerialNumber          " r@ js> pop().item().SerialNumber          . cr \ string   
					." Speed                 " r@ js> pop().item().Speed                 . cr \ uint32   
					." Tag                   " r@ js> pop().item().Tag                   . cr \ string   
					." TotalWidth            " r@ js> pop().item().TotalWidth            . cr \ uint16   
					." TypeDetail            " r@ js> pop().item().TypeDetail            . cr \ uint16   
				r@ dup js> pop().moveNext();pop().atEnd() until \ This is the way to iterate all memory banks which may be multiple in this computer.
				r> drop
				." -------------------------------------------" cr
				." Total memory size     " 1024 / 1024 / dup . ."  Mega Bytes" cr
  				;
		
				<selftest>
					***** Demo how to use objEnumWin32_PhysicalMemory object ... 
					marker -%-%-%-%-%-
					js> kvm.screenbuffer.length constant start-here // ( -- n ) 開始測試前的 kvm.screenbuffer 尾巴。
					( ------------ Start to do anything --------------- )
					list-some-Win32_PhysicalMemory-properties
					2000 >
					( ------------ done, start checking ---------------- ) 
					js> stack.slice(0) <js> [true] </jsV> isSameArray >r dropall r>
					-->judge [if] <js> [
						'objEnumWin32_PhysicalMemory',
						'list-some-Win32_PhysicalMemory-properties'
					] </jsV> all-pass [else] *debug* selftest-failed->>> [then]
					-%-%-%-%-%-
				</selftest>
				
				\ This is a one liner to show physical memory size, leaving %errorlevel% to be the memory size in MBytes.
				\ jeforth.hta include wmi.f list-some-Win32_PhysicalMemory-properties bye

\ Win32_PnPEntity class
\ http://msdn.microsoft.com/en-us/library/windows/desktop/aa394353(v=vs.85).aspx
\ http://msdn.microsoft.com/en-us/library/windows/desktop/aa394587(v=vs.85).aspx   
code objEnumWin32_PnPEntity 
				( "where-clause" -- objEnumWin32_PnPEntity ) \ Get WMI Win32_PnPEntity object onto TOS.
				push(new Enumerator(kvm.objWMIService.ExecQuery("Select * from Win32_PnPEntity "+pop())));
				end-code 
				
: list-all-PnP-devices 
				( -- count ) \ demo how to use Win32_PnPEntity
				0 "" objEnumWin32_PnPEntity >r
				begin
					r@ js> pop().atEnd() ( count atEnd? )
					if r> drop exit ( count ) else 1+ dup then
				while
					dup 3 .r space r@ js> pop().item().Name . space ." - " r@ js> pop().item().DeviceID . cr
				r@ js: pop().moveNext() repeat 
				;
				
				\ this is a one liner to list all devices. %errorlevel% is the count of devices.
				\ cscript jeforth.js include wmi.f cr list-all-PnP-devices bye

				<selftest>
					***** Demo how to use objEnumWin32_PnPEntity object ... 
					marker -%-%-%-%-%-
					js> kvm.screenbuffer.length constant start-here // ( -- n ) 開始測試前的 kvm.screenbuffer 尾巴。
					( ------------ Start to do anything --------------- )
					list-all-PnP-devices
					10 > \ true
					( ------------ done, start checking ---------------- ) 
					start-here <js> kvm.screenbuffer.indexOf("PCI",pop())!=-1 </jsV> \ true
					start-here <js> kvm.screenbuffer.indexOf("Motherboard resources",pop())!=-1 </jsV> \ true
					start-here <js> kvm.screenbuffer.indexOf("HID-compliant",pop())!=-1 </jsV> \ true
					js> stack.slice(0) <js> [true,true,true,true] </jsV> isSameArray >r dropall r>
					-->judge [if] <js> [
						'objEnumWin32_PnPEntity',
						'list-all-PnP-devices'
					] </jsV> all-pass [else] *debug* selftest-failed->>> [then]
					-%-%-%-%-%-
				</selftest>
				
: list-abnormal-items-in-device-manager 
				( -- 0:ok ) \ Identify devices that are not working (e.g. those marked with an exclamation point icon in Device Manager), return abnormal item count.
				0 s" WHERE ConfigManagerErrorCode <> 0" objEnumWin32_PnPEntity >r  ( 0 | obj )
				begin
					r@  ( 0 obj | obj)
					js> pop().atEnd() ( 0 atEnd? )
					if r> drop exit ( count ) else 1+ dup ( count count ) then
				while ( count | obj )
					." -------------------------------------------" cr
					." Class GUID:   " r@ js> pop().item().ClassGuid              . cr
					." Description:  " r@ js> pop().item().Description            . cr
					." Device ID:    " r@ js> pop().item().DeviceID               . cr
					." Manufacturer: " r@ js> pop().item().Manufacturer           . cr
					." Name:         " r@ js> pop().item().Name                   . cr
					." Service:      " r@ js> pop().item().Service                . cr
					." ErrorCode:    " r@ js> pop().item().ConfigManagerErrorCode . cr
				r@ js: pop().moveNext() repeat 
				;
				
				\ This is a one liner that lists yellow marks and red marks in Device Manager, leaving %errorlevel% with the abnormal item count.
				\ cscript jeforth.js include wmi.f cr list-abnormal-items-in-device-manager bye

				<selftest>
					***** Let's see if there's any abnormal items in device manager ... 
					marker -%-%-%-%-%-
					js> kvm.screenbuffer.length constant start-here // ( -- n ) 開始測試前的 kvm.screenbuffer 尾巴。
					( ------------ Start to do anything --------------- )
					list-abnormal-items-in-device-manager
					js> isNaN(pop()) > \ false
					( ------------ done, start checking ---------------- ) 
					js> stack.slice(0) <js> [false] </jsV> isSameArray >r dropall r>
					-->judge [if] <js> [
						'list-abnormal-items-in-device-manager'
					] </jsV> all-pass [else] *debug* selftest-failed->>> [then]
					-%-%-%-%-%-
				</selftest>

\ MSDN Dev Center - Desktop > Docs > Windows Development Reference > System Administration > Windows Management Instrumentation > Using WMI > Creating WMI Clients > WMI Tasks for Scripts and Applications > WMI Tasks: Computer Hardware
\ http://msdn.microsoft.com/en-us/library/windows/desktop/aa394587(v=vs.85).aspx   
code objEnumWin32_CDROMDrive 
				( "where-clause" -- objEnumWin32_CDROMDrive ) \ Get WMI Win32_CDROMDrive object onto TOS.
				push(new Enumerator(kvm.objWMIService.ExecQuery("Select * from Win32_CDROMDrive "+pop())));
				end-code 
				
: list-CD/DVD-drives 
				( -- count ) \ List CD/DVD drives in this computer.
				0 "" objEnumWin32_CDROMDrive >r  ( 0 | obj )
				begin
					r@  ( 0 obj | obj)
					js> pop().atEnd() ( 0 atEnd? )
					if r> drop exit ( count ) else 1+ dup ( count count ) then
				while ( count | obj )
					." -------------------------------------------" cr
					." Description:       " r@ js> pop().item().Description        . cr
					." Device ID:         " r@ js> pop().item().DeviceID           . cr
					." Manufacturer:      " r@ js> pop().item().Manufacturer       . cr
					." Name:              " r@ js> pop().item().Name               . cr
					." RevisionLevel      " r@ js> pop().item().RevisionLevel      . cr    \ string 
					." SerialNumber       " r@ js> pop().item().SerialNumber       . cr    \ uint16 
					." Size               " r@ js> pop().item().Size               . cr    \ uint64 
					." Status             " r@ js> pop().item().Status             . cr    \ string 
					." TransferRate       " r@ js> pop().item().TransferRate       . cr    \ real64 
					." VolumeName         " r@ js> pop().item().VolumeName         . cr    \ string 
					." VolumeSerialNumber " r@ js> pop().item().VolumeSerialNumber . cr    \ string 
				r@ js: pop().moveNext() repeat 
				;
				
				\ This is a one liner to show CD/DVD drives, leaving %errorlevel% with the count.
				\ cscript jeforth.js include wmi.f list-CD/DVD-drives bye
				
				<selftest>
					***** Demo objEnumWin32_CDROMDrive object ... 
					marker -%-%-%-%-%-
					js> kvm.screenbuffer.length constant start-here // ( -- n ) 開始測試前的 kvm.screenbuffer 尾巴。
					( ------------ Start to do anything --------------- )
					list-CD/DVD-drives
					js> isNaN(pop()) > \ false
					( ------------ done, start checking ---------------- ) 
					js> stack.slice(0) <js> [false] </jsV> isSameArray >r dropall r>
					-->judge [if] <js> [
						'objEnumWin32_CDROMDrive',
						'list-CD/DVD-drives'
					] </jsV> all-pass [else] *debug* selftest-failed->>> [then]
					-%-%-%-%-%-
				</selftest>

\ MSDN Dev Center - Desktop > Docs > Windows Development Reference > System Administration > Windows Management Instrumentation > WMI Reference > WMI Classes > Win32 Classes > Win32_Processor
\ http://msdn.microsoft.com/en-us/library/windows/desktop/aa394373(v=vs.85).aspx
code objEnumWin32_Processor 
				( -- objEnumWin32_Processor ) \ Get WMI Win32_Processor object onto TOS.
				push(new Enumerator(kvm.objWMIService.InstancesOf("Win32_Processor")));
				end-code 
				
: list-all-processors 
				( -- #Cores #LogicalProcessers #Processers ) \ List all processors in this computer. Return physical CPU count.
				0 objEnumWin32_Processor >r  ( 0 | obj )
				begin
					r@  ( 0 obj | obj)
					js> pop().atEnd() ( 0 atEnd? )
					if r> drop exit ( count ) else 1+ dup ( count count ) then
				while ( count | obj )
					." -------------------------------------------" cr
					." AddressWidth                  " r@ js> pop().item().AddressWidth              . cr \ uint16  
					." Architecture                  " r@ js> pop().item().Architecture              . cr \ uint16  
					." Availability                  " r@ js> pop().item().Availability              . cr \ uint16  
					." Caption                       " r@ js> pop().item().Caption                   . cr \ string  
					." CurrentClockSpeed             " r@ js> pop().item().CurrentClockSpeed         . cr \ uint32  
					." CurrentVoltage                " r@ js> pop().item().CurrentVoltage            . cr \ uint16  
					." DataWidth                     " r@ js> pop().item().DataWidth                 . cr \ uint16  
					." Description                   " r@ js> pop().item().Description               . cr \ string  
					." DeviceID                      " r@ js> pop().item().DeviceID                  . cr \ string  
					." ExtClock                      " r@ js> pop().item().ExtClock                  . cr \ uint32  
					." Family                        " r@ js> pop().item().Family                    . cr \ uint16  
					." L2CacheSize                   " r@ js> pop().item().L2CacheSize               . cr \ uint32  
					." L2CacheSpeed                  " r@ js> pop().item().L2CacheSpeed              . cr \ uint32  
					." L3CacheSize                   " r@ js> pop().item().L3CacheSize               . cr \ uint32  
					." L3CacheSpeed                  " r@ js> pop().item().L3CacheSpeed              . cr \ uint32  
					." Level                         " r@ js> pop().item().Level                     . cr \ uint16  
					." LoadPercentage                " r@ js> pop().item().LoadPercentage            . cr \ uint16  
					." Manufacturer                  " r@ js> pop().item().Manufacturer              . cr \ string  
					." MaxClockSpeed                 " r@ js> pop().item().MaxClockSpeed             . cr \ uint32  
					." Name                          " r@ js> pop().item().Name                      . cr \ string  
					." NumberOfCores                 " r@ js> pop().item().NumberOfCores             int dup . swap cr \ uint32  
					." NumberOfLogicalProcessors     " r@ js> pop().item().NumberOfLogicalProcessors int dup . swap cr \ uint32  
					." ProcessorId                   " r@ js> pop().item().ProcessorId               . cr \ string  
					." ProcessorType                 " r@ js> pop().item().ProcessorType             . cr \ uint16  
					." Revision                      " r@ js> pop().item().Revision                  . cr \ uint16  
					." Role                          " r@ js> pop().item().Role                      . cr \ string  
					." SocketDesignation             " r@ js> pop().item().SocketDesignation         . cr \ string  
					." StatusInfo                    " r@ js> pop().item().StatusInfo                . cr \ uint16  
					." Stepping                      " r@ js> pop().item().Stepping                  . cr \ string  
					." SystemName                    " r@ js> pop().item().SystemName                . cr \ string  
					." UniqueId                      " r@ js> pop().item().UniqueId                  . cr \ string  
					." UpgradeMethod                 " r@ js> pop().item().UpgradeMethod             . cr \ uint16  
					." Version                       " r@ js> pop().item().Version                   . cr \ string  
					." PowerManagementSupported      " r@ js> pop().item().PowerManagementSupported  . cr \ boolean ( flag )
					." PowerManagementCapabilities[] " r@ js> pop().item().PowerManagementCapabilities .VBArray cr \ uint16 
				r@ js: pop().moveNext() repeat 
				;

				\ This is a one liner to show processors, leaving %errorlevel% with the physical processor count.
				\ cscript jeforth.js include wmi.f list-all-processors bye

				\ This is a one liner to show processors, leaving %errorlevel% with the logical processor count.
				\ cscript jeforth.js include wmi.f list-all-processors drop bye

				\ This is a one liner to show processors, leaving %errorlevel% with the processor core count.
				\ cscript jeforth.js include wmi.f list-all-processors drop drop bye

				<selftest>
					***** Demo objEnumWin32_Processor object ... 
					marker -%-%-%-%-%-
					js> kvm.screenbuffer.length constant start-here // ( -- n ) 開始測試前的 kvm.screenbuffer 尾巴。
					( ------------ Start to do anything --------------- )
					list-all-processors
					js> isNaN(pop()) \ false
					-rot
					js> isNaN(pop())  \ false
					-rot
					js> isNaN(pop())  \ false
					( ------------ done, start checking ---------------- ) 
					js> stack.slice(0) <js> [false,false,false] </jsV> isSameArray >r dropall r>
					-->judge [if] <js> [
						'objEnumWin32_Processor',
						'list-all-processors'
					] </jsV> all-pass [else] *debug* selftest-failed->>> [then]
					-%-%-%-%-%-
				</selftest>

\ View BIOS info
code objEnumWin32_BIOS 
				( -- objEnumWin32_BIOS ) \ Get WMI Win32_BIOS object onto TOS.
				push(new Enumerator(kvm.objWMIService.InstancesOf("Win32_BIOS")));
				end-code 

				<selftest>
					***** Demo how to use objEnumWin32_BIOS, list Win32_BIOS properties ... 
					marker -%-%-%-%-%-
					js> kvm.screenbuffer.length constant start-here // ( -- n ) 開始測試前的 kvm.screenbuffer 尾巴。
					( ------------ Start to do anything --------------- )
					objEnumWin32_BIOS >r
					." BiosCharacteristics[] " r@ js> pop().item().BiosCharacteristics   .VBArray cr
					." BIOSVersion[]         " r@ js> pop().item().BIOSVersion           .VBArray cr
					." BuildNumber           " r@ js> pop().item().BuildNumber           . cr
					." Caption               " r@ js> pop().item().Caption               . cr
					." CodeSet               " r@ js> pop().item().CodeSet               . cr
					." CurrentLanguage       " r@ js> pop().item().CurrentLanguage       . cr
					." Description           " r@ js> pop().item().Description           . cr
					." IdentificationCode    " r@ js> pop().item().IdentificationCode    . cr
					." InstallableLanguages  " r@ js> pop().item().InstallableLanguages  . cr
					." InstallDate           " r@ js> pop().item().InstallDate           . cr
					." LanguageEdition       " r@ js> pop().item().LanguageEdition       . cr
					." ListOfLanguages[]     " r@ js> pop().item().ListOfLanguages       .VBArray cr
					." Manufacturer          " r@ js> pop().item().Manufacturer          . cr
					." Name                  " r@ js> pop().item().Name                  . cr
					." OtherTargetOS         " r@ js> pop().item().OtherTargetOS         . cr
					." PrimaryBIOS           " r@ js> pop().item().PrimaryBIOS           . cr
					." ReleaseDate           " r@ js> pop().item().ReleaseDate           . cr
					." SerialNumber          " r@ js> pop().item().SerialNumber          . cr
					." SMBIOSBIOSVersion     " r@ js> pop().item().SMBIOSBIOSVersion     . cr
					." SMBIOSMajorVersion    " r@ js> pop().item().SMBIOSMajorVersion    . cr
					." SMBIOSMinorVersion    " r@ js> pop().item().SMBIOSMinorVersion    . cr
					." SMBIOSPresent         " r@ js> pop().item().SMBIOSPresent         . cr
					." SoftwareElementID     " r@ js> pop().item().SoftwareElementID     . cr
					." SoftwareElementState  " r@ js> pop().item().SoftwareElementState  . cr
					." Status                " r@ js> pop().item().Status                . cr
					." TargetOperatingSystem " r@ js> pop().item().TargetOperatingSystem . cr
					." Version               " r@ js> pop().item().Version               . cr
					r> drop
					( ------------ done, start checking ---------------- ) 
					start-here <js> kvm.screenbuffer.indexOf("Status                OK",pop())!=-1 </jsV> \ true
					start-here <js> kvm.screenbuffer.indexOf("PrimaryBIOS           true",pop())!=-1 </jsV> \ true
					\ start-here <js> kvm.screenbuffer.indexOf("en-US",pop())!=-1 </jsV> \ true
					js> stack.slice(0) <js> [true,true] </jsV> isSameArray >r dropall r>
					-->judge [if] <js> [
						'objEnumWin32_BIOS'
					] </jsV> all-pass [else] *debug* selftest-failed->>> [then]
					-%-%-%-%-%-
				</selftest>
				
				\ This is a one liner to show BIOS things.
				\ cscript jeforth.js list-Win32_BIOS-properties bye /f0:wmi.f //nologo

\ View Battery info
\ http://msdn.microsoft.com/en-us/library/windows/desktop/aa394074(v=vs.85).aspx
\ Dev Center - Desktop > Docs > Windows Development Reference > System Administration > Windows Management Instrumentation > WMI Reference > WMI Classes > Win32 Classes > Win32_Battery
code objEnumWin32_Battery 
				( -- objEnumWin32_Battery ) \ Get WMI Win32_Battery object onto TOS.
				push(new Enumerator(kvm.objWMIService.InstancesOf("Win32_Battery")));
				end-code 

				\ This is a one liner to show battery things.
				\ cscript jeforth.js list-Win32_Battery-properties bye /f0:wmi.f //nologo

				<selftest>
					***** Demo how to use objEnumWin32_Battery, list Win32_Battery properties ... 
					marker -%-%-%-%-%-
					js> kvm.screenbuffer.length constant start-here // ( -- n ) 開始測試前的 kvm.screenbuffer 尾巴。
					( ------------ Start to do anything --------------- )
					objEnumWin32_Battery js> tos().atEnd() [if] drop ." This computer has no battery." cr [else] >r
					." Availability                  " r@ js> pop().item().Availability                . cr \ uint16  
					." BatteryRechargeTime           " r@ js> pop().item().BatteryRechargeTime         . cr \ uint32  
					." BatteryStatus                 " r@ js> pop().item().BatteryStatus               . cr \ uint16  
					." Caption                       " r@ js> pop().item().Caption                     . cr \ string  
					." Chemistry                     " r@ js> pop().item().Chemistry                   . cr \ uint16  
					." ConfigManagerErrorCode        " r@ js> pop().item().ConfigManagerErrorCode      . cr \ uint32  
					." ConfigManagerUserConfig       " r@ js> pop().item().ConfigManagerUserConfig     . cr \ boolean 
					." CreationClassName             " r@ js> pop().item().CreationClassName           . cr \ string  
					." Description                   " r@ js> pop().item().Description                 . cr \ string  
					." DesignCapacity                " r@ js> pop().item().DesignCapacity              . cr \ uint32  
					." DesignVoltage                 " r@ js> pop().item().DesignVoltage               . cr \ uint64  
					." DeviceID                      " r@ js> pop().item().DeviceID                    . cr \ string  
					." ErrorCleared                  " r@ js> pop().item().ErrorCleared                . cr \ boolean 
					." ErrorDescription              " r@ js> pop().item().ErrorDescription            . cr \ string  
					." EstimatedChargeRemaining      " r@ js> pop().item().EstimatedChargeRemaining    . cr \ uint16  
					." EstimatedRunTime              " r@ js> pop().item().EstimatedRunTime            . cr \ uint32  
					." ExpectedBatteryLife           " r@ js> pop().item().ExpectedBatteryLife         . cr \ uint32  
					." ExpectedLife                  " r@ js> pop().item().ExpectedLife                . cr \ uint32  
					." FullChargeCapacity            " r@ js> pop().item().FullChargeCapacity          . cr \ uint32  
					." InstallDate                   " r@ js> pop().item().InstallDate                 . cr \ datetime
					." LastErrorCode                 " r@ js> pop().item().LastErrorCode               . cr \ uint32  
					." MaxRechargeTime               " r@ js> pop().item().MaxRechargeTime             . cr \ uint32  
					." Name                          " r@ js> pop().item().Name                        . cr \ string  
					." PNPDeviceID                   " r@ js> pop().item().PNPDeviceID                 . cr \ string  
					." PowerManagementCapabilities[] " r@ js> pop().item().PowerManagementCapabilities .VBArray cr
					." PowerManagementSupported      " r@ js> pop().item().PowerManagementSupported    . cr \ boolean 
					." SmartBatteryVersion           " r@ js> pop().item().SmartBatteryVersion         . cr \ string  
					." Status                        " r@ js> pop().item().Status                      . cr \ string  
					." StatusInfo                    " r@ js> pop().item().StatusInfo                  . cr \ uint16  
					." SystemCreationClassName       " r@ js> pop().item().SystemCreationClassName     . cr \ string  
					." SystemName                    " r@ js> pop().item().SystemName                  . cr \ string  
					." TimeOnBattery                 " r@ js> pop().item().TimeOnBattery               . cr \ uint32  
					." TimeToFullCharge              " r@ js> pop().item().TimeToFullCharge            . cr \ uint32  
					r> drop [then] 
					( ------------ done, start checking ---------------- ) 
					start-here <js> kvm.screenbuffer.indexOf("Status                        OK",pop())!=-1 </jsV> \ true
					start-here <js> kvm.screenbuffer.indexOf("CreationClassName             Win32_Battery",pop())!=-1 </jsV> \ true
					start-here <js> kvm.screenbuffer.indexOf("This computer has no battery",pop())!=-1 </jsV> \ true|false
					or or
					js> stack.slice(0) <js> [true] </jsV> isSameArray >r dropall r>
					-->judge [if] <js> [
						'objEnumWin32_Battery'
					] </jsV> all-pass [else] *debug* selftest-failed->>> [then]
					-%-%-%-%-%-
				</selftest>

\ View Process info
\ http://msdn.microsoft.com/en-us/library/windows/desktop/aa394372(v=vs.85).aspx
\ Win32_Process class
code objEnumWin32_Process
				( "where-clause" -- objEnumWin32_Process ) \ Get WMI Win32_Process object onto TOS.
				push(new Enumerator(kvm.objWMIService.ExecQuery("Select * from Win32_Process "+pop())));
				end-code 

: list-processes 
				( -- count ) \ List all processes
				0 "" objEnumWin32_Process >r  ( 0 | objEnum )
				begin
					r@ js> !pop().atEnd() ( 0 NotAtEnd? )
				while ( count | objEnum )
					1+ ( count++ | objEnum )
					." -------------------------------------------" cr
					." Name:              " r@ js> pop().item().Name               . cr    \ string
					." ProcessId:         " r@ js> pop().item().ProcessId          . cr    \ string
					." CommandLine:       " r@ js> pop().item().CommandLine        . cr    \ string
					." ExecutablePath     " r@ js> pop().item().ExecutablePath     . cr    \ string 
				r@ js: pop().moveNext() repeat 
				r> drop ;
				
				\ This is a one liner to list all processes.
				\ jeforth.hta include wmi.f list-processes 
				
				<selftest>
					***** Demo how to use objEnumWin32_Process, list all processes ... 
					marker -%-%-%-%-%-
					js> kvm.screenbuffer.length constant start-here // ( -- n ) 開始測試前的 kvm.screenbuffer 尾巴。
					( ------------ Start to do anything --------------- )
					list-processes \ count
					( ------------ done, start checking ---------------- ) 
					js> isNaN(pop()) \ false
					start-here <js> kvm.screenbuffer.indexOf("mshta.exe",pop())!=-1 </jsV> \ true
					start-here <js> kvm.screenbuffer.indexOf("System Idle Process",pop())!=-1 </jsV> \ true
					js> stack.slice(0) <js> [false,true,true] </jsV> isSameArray >r dropall r>
					-->judge [if] <js> [
						'objEnumWin32_Process'
					] </jsV> all-pass [else] *debug* selftest-failed->>> [then]
					-%-%-%-%-%-
				</selftest>

: kill-them		( "where-clause" -- count ) \ Kill processes.
				0 swap objEnumWin32_Process >r  ( 0 | obj )
				begin
					r@  ( 0 obj | obj)
					js> !pop().atEnd() ( 0 NotAtEnd? )
				while ( count | obj )
					1+ r@ js: pop().item().terminate(0) 
				r@ js: pop().moveNext() repeat 
				r> drop ;
				/// Usage: Don't forget the where-clause, Case insensitive
				///     s" where name = 'ExCeL.ExE'" kill-them
				///     s" where name like 'chrom%'" kill-them 
				/// Also refer to the "see-process" command
				///     s" where name = 'ExCeL.ExE'" see-process
				///     s" where name like 'chrom%'" see-process
				///     s" where commandline like '%excel%'" see-process
				

: list-them		( "where-clause" -- count ) \ List processes.
				0 swap objEnumWin32_Process >r  ( 0 | obj )
				begin
					r@  ( 0 obj | obj)
					js> !pop().atEnd() ( 0 NotAtEnd? )
				while ( count | obj )
					1+ r@ js> pop().item().name . char : . r@ js> pop().item().ProcessId . cr
				r@ js: pop().moveNext() repeat 
				r> drop ;
				/// Usage: Don't forget the where-clause, Case insensitive
				///     s" where name = 'ExCeL.ExE'" list-them
				///     s" where name like 'chrom%'" list-them 

: see-process ( s" where CommandLine like '%GitHub%' and name = 'powershell.exe'" -- obj ) \ See into a process 
				0 swap objEnumWin32_Process >r  ( 0 | obj )
				begin
					r@  ( 0 obj | obj)
					js> !pop().atEnd() ( 0 NotAtEnd? )
				while ( count | obj )
					1+ 
					cr <o> <hr style="border-width:3px;margin-left:1em;margin-right:1em;border-style:solid;"></o> drop
					."  string   Name;                       " r@ :> item().Name;                        . cr
					."  uint32   ProcessId;                  " r@ :> item().ProcessId;                   . cr
					."  string   Caption;                    " r@ :> item().Caption;                     . cr
					."  string   CommandLine;                " r@ :> item().CommandLine;                 . cr
					."  string   CreationClassName;          " r@ :> item().CreationClassName;           . cr
					."  datetime CreationDate;               " r@ :> item().CreationDate;                . cr
					."  string   CSCreationClassName;        " r@ :> item().CSCreationClassName;         . cr
					."  string   CSName;                     " r@ :> item().CSName;                      . cr
					."  string   Description;                " r@ :> item().Description;                 . cr
					."  string   ExecutablePath;             " r@ :> item().ExecutablePath;              . cr
					."  uint16   ExecutionState;             " r@ :> item().ExecutionState;              . cr
					."  string   Handle;                     " r@ :> item().Handle;                      . cr
					."  uint32   HandleCount;                " r@ :> item().HandleCount;                 . cr
					."  datetime InstallDate;                " r@ :> item().InstallDate;                 . cr
					."  uint64   KernelModeTime;             " r@ :> item().KernelModeTime;              . cr
					."  uint32   MaximumWorkingSetSize;      " r@ :> item().MaximumWorkingSetSize;       . cr
					."  uint32   MinimumWorkingSetSize;      " r@ :> item().MinimumWorkingSetSize;       . cr
					."  string   OSCreationClassName;        " r@ :> item().OSCreationClassName;         . cr
					."  string   OSName;                     " r@ :> item().OSName;                      . cr
					."  uint64   OtherOperationCount;        " r@ :> item().OtherOperationCount;         . cr
					."  uint64   OtherTransferCount;         " r@ :> item().OtherTransferCount;          . cr
					."  uint32   PageFaults;                 " r@ :> item().PageFaults;                  . cr
					."  uint32   PageFileUsage;              " r@ :> item().PageFileUsage;               . cr
					."  uint32   ParentProcessId;            " r@ :> item().ParentProcessId;             . cr
					."  uint32   PeakPageFileUsage;          " r@ :> item().PeakPageFileUsage;           . cr
					."  uint64   PeakVirtualSize;            " r@ :> item().PeakVirtualSize;             . cr
					."  uint32   PeakWorkingSetSize;         " r@ :> item().PeakWorkingSetSize;          . cr
					."  uint32   Priority = NULL;            " r@ :> item().Priority;             		 . cr
					."  uint64   PrivatePageCount;           " r@ :> item().PrivatePageCount;            . cr
					."  uint32   QuotaNonPagedPoolUsage;     " r@ :> item().QuotaNonPagedPoolUsage;      . cr
					."  uint32   QuotaPagedPoolUsage;        " r@ :> item().QuotaPagedPoolUsage;         . cr
					."  uint32   QuotaPeakNonPagedPoolUsage; " r@ :> item().QuotaPeakNonPagedPoolUsage;  . cr
					."  uint32   QuotaPeakPagedPoolUsage;    " r@ :> item().QuotaPeakPagedPoolUsage;     . cr
					."  uint64   ReadOperationCount;         " r@ :> item().ReadOperationCount;          . cr
					."  uint64   ReadTransferCount;          " r@ :> item().ReadTransferCount;           . cr
					."  uint32   SessionId;                  " r@ :> item().SessionId;                   . cr
					."  string   Status;                     " r@ :> item().Status;                      . cr
					."  datetime TerminationDate;            " r@ :> item().TerminationDate;             . cr
					."  uint32   ThreadCount;                " r@ :> item().ThreadCount;                 . cr
					."  uint64   UserModeTime;               " r@ :> item().UserModeTime;                . cr
					."  uint64   VirtualSize;                " r@ :> item().VirtualSize;                 . cr
					."  string   WindowsVersion;             " r@ :> item().WindowsVersion;              . cr
					."  uint64   WorkingSetSize;             " r@ :> item().WorkingSetSize;              . cr
					."  uint64   WriteOperationCount;        " r@ :> item().WriteOperationCount;         . cr
					."  uint64   WriteTransferCount;         " r@ :> item().WriteTransferCount;          . cr
				r@ js: pop().moveNext() repeat 
				r> drop ;
				/// Usage: Don't forget the where-clause, Case insensitive
				///     s" where name = 'ExCeL.ExE'" see-process
				///     s" where name like 'chrom%'" see-process
				///     s" where commandline like '%excel%'" see-process
				/// Also "kill-them' command
				///     s" where name = 'ExCeL.ExE'" kill-them
				///     s" where name like 'chrom%'" kill-them

: get-them		( "where-clause" -- [objWin32_Process,..] ) \ Get processes.
				objEnumWin32_Process >r  [] ( [] | Enum )
				begin
					r@ js> !pop().atEnd() ( [] NotAtEnd? | Enum )
				while ( [] | Enum )
					r@ js> pop().item() ( [] item | Enum )
					js: tos(1).push(pop()) ( [] | Enum )
				r@ js: pop().moveNext() repeat 
				r> drop ( [] ) ;
				/// Usage: Don't forget the where-clause, Case insensitive
				///     s" where name = 'ExCeL.ExE'" get-them
				///     s" where name like 'chrom%'" get-them 

<comment> ～～～～～～ 以下是我的筆記、草稿 ～～～～～～～～

WMI 提供的東西非常多，都可以透過 MSDN 去查詢。網址如下，
Dev Center - Desktop > Docs > Windows Development Reference > System Administration > Windows Management Infrastructure > WMI Reference > WMI Classes
http://msdn.microsoft.com/en-us/library/windows/desktop/aa394554(v=vs.85).aspx

更乾脆點兒，用下列 WMI class 的 name 為 key 直接上網查也許更快，
	Win32_1394Controller
	Win32_1394ControllerDevice
	Win32_AccountSID
	Win32_ActionCheck
	Win32_ActiveRoute
	Win32_AllocatedResource
	Win32_ApplicationCommandLine
	Win32_ApplicationService
	Win32_AssociatedBattery
	Win32_AssociatedProcessorMemory
	Win32_AutochkSetting
	Win32_BaseBoard
	Win32_Battery
	Win32_Binary
	Win32_BindImageAction
	Win32_BIOS
	Win32_BootConfiguration
	Win32_Bus Win32_CacheMemory
	Win32_CDROMDrive
	Win32_CheckCheck
	Win32_CIMLogicalDeviceCIMDataFile
	Win32_ClassicCOMApplicationClasses
	Win32_ClassicCOMClass
	Win32_ClassicCOMClassSetting
	Win32_ClassicCOMClassSettings
	Win32_ClassInforAction
	Win32_ClientApplicationSetting
	Win32_CodecFile
	Win32_COMApplicationSettings
	Win32_COMClassAutoEmulator
	Win32_ComClassEmulator
	Win32_CommandLineAccess
	Win32_ComponentCategory
	Win32_ComputerSystem
	Win32_ComputerSystemProcessor
	Win32_ComputerSystemProduct
	Win32_ComputerSystemWindowsProductActivationSetting
	Win32_Condition
	Win32_ConnectionShare
	Win32_ControllerHastHub
	Win32_CreateFolderAction
	Win32_CurrentProbe
	Win32_DCOMApplication
	Win32_DCOMApplicationAccessAllowedSetting
	Win32_DCOMApplicationLaunchAllowedSetting
	Win32_DCOMApplicationSetting
	Win32_DependentService
	Win32_Desktop
	Win32_DesktopMonitor
	Win32_DeviceBus
	Win32_DeviceMemoryAddress
	Win32_Directory
	Win32_DirectorySpecification
	Win32_DiskDrive
	Win32_DiskDrivePhysicalMedia
	Win32_DiskDriveToDiskPartition
	Win32_DiskPartition
	Win32_DiskQuota
	Win32_DisplayConfiguration
	Win32_DisplayControllerConfiguration
	Win32_DMAChanner
	Win32_DriverForDevice
	Win32_DriverVXD
	Win32_DuplicateFileAction
	Win32_Environment
	Win32_EnvironmentSpecification
	Win32_ExtensionInfoAction
	Win32_Fan
	Win32_FileSpecification
	Win32_FloppyController
	Win32_FloppyDrive
	Win32_FontInfoAction
	Win32_Group
	Win32_GroupDomain
	Win32_GroupUser
	Win32_HeatPipe
	Win32_IDEController
	Win32_IDEControllerDevice
	Win32_ImplementedCategory
	Win32_InfraredDevice
	Win32_IniFileSpecification
	Win32_InstalledSoftwareElement
	Win32_IP4PersistedRouteTable
	Win32_IP4RouteTable
	Win32_IRQResource
	Win32_Keyboard
	Win32_LaunchCondition
	Win32_LoadOrderGroup
	Win32_LoadOrderGroupServiceDependencies
	Win32_LoadOrderGroupServiceMembers
	Win32_LocalTime
	Win32_LoggedOnUser
	Win32_LogicalDisk
	Win32_LogicalDiskRootDirectory
	Win32_LogicalDiskToPartition
	Win32_LogicalFileAccess
	Win32_LogicalFileAuditing
	Win32_LogicalFileGroup
	Win32_LogicalFileOwner
	Win32_LogicalFileSecuritySetting
	Win32_LogicalMemoryConfiguration
	Win32_LogicalProgramGroup
	Win32_LogicalProgramGroupDirectory
	Win32_LogicalProgramGroupItem
	Win32_LogicalProgramGroupItemDataFile
	Win32_LogicalShareAccess
	Win32_LogicalShareAuditing
	Win32_LogicalShareSecuritySetting
	Win32_LogonSession
	Win32_LogonSessionMappedDisk
	Win32_MappedLogicalDisk
	Win32_MemoryArray
	Win32_MemoryArrayLocation
	Win32_MemoryDevice
	Win32_MemoryDeviceArray
	Win32_MemoryDeviceLocation
	Win32_MIMEInfoAction
	Win32_MotherboardDevice
	Win32_MoveFileAction
	Win32_NamedJobObject
	Win32_NamedJobObjectActgInfo
	Win32_NamedJobObjectLimit
	Win32_NamedJobObjectLimitSetting
	Win32_NamedJobObjectProcess
	Win32_NamedJobObjectSecLimit
	Win32_NamedJobObjectSecLimitSetting
	Win32_NamedJobObjectStatistics
	Win32_NetworkAdapter
	Win32_NetworkAdapterConfiguration
	Win32_NetworkAdapterSetting
	Win32_NetworkClient
	Win32_NetworkConnection
	Win32_NetworkLoginProfile
	Win32_NetworkProtocol
	Win32_NTDomain
	Win32_NTEventlogFile
	Win32_NTLogEvent
	Win32_NTLogEventComputer
	Win32_NTLogEvnetLog
	Win32_NTLogEventUser
	Win32_ODBCAttribute
	Win32_ODBCDataSourceAttribute
	Win32_ODBCDataSourceSpecification
	Win32_ODBCDriverAttribute
	Win32_ODBCDriverSoftwareElement
	Win32_ODBCDriverSpecification
	Win32_ODBCSourceAttribute
	Win32_ODBCTranslatorSpecification
	Win32_OnBoardDevice
	Win32_OperatingSystem
	Win32_OperatingSystemAutochkSetting
	Win32_OperatingSystemQFE
	Win32_OSRecoveryConfiguracion
	Win32_PageFile
	Win32_PageFileElementSetting
	Win32_PageFileSetting
	Win32_PageFileUsage
	Win32_ParallelPort
	Win32_Patch
	Win32_PatchFile
	Win32_PatchPackage
	Win32_PCMCIAControler
	Win32_PerfFormattedData_ASP_ActiveServerPages
	Win32_PerfFormattedData_ASPNET_114322_ASPNETAppsv114322
	Win32_PerfFormattedData_ASPNET_114322_ASPNETv114322
	Win32_PerfFormattedData_ASPNET_2040607_ASPNETAppsv2040607
	Win32_PerfFormattedData_ASPNET_2040607_ASPNETv2040607
	Win32_PerfFormattedData_ASPNET_ASPNET
	Win32_PerfFormattedData_ASPNET_ASPNETApplications
	Win32_PerfFormattedData_aspnet_state_ASPNETStateService
	Win32_PerfFormattedData_ContentFilter_IndexingServiceFilter
	Win32_PerfFormattedData_ContentIndex_IndexingService
	Win32_PerfFormattedData_DTSPipeline_SQLServerDTSPipeline
	Win32_PerfFormattedData_Fax_FaxServices
	Win32_PerfFormattedData_InetInfo_InternetInformationServicesGlobal
	Win32_PerfFormattedData_ISAPISearch_HttpIndexingService
	Win32_PerfFormattedData_MSDTC_DistributedTransactionCoordinator
	Win32_PerfFormattedData_NETCLRData_NETCLRData
	Win32_PerfFormattedData_NETCLRNetworking_NETCLRNetworking
	Win32_PerfFormattedData_NETDataProviderforOracle_NETCLRData
	Win32_PerfFormattedData_NETDataProviderforSqlServer_NETDataProviderforSqlServer
	Win32_PerfFormattedData_NETFramework_NETCLRExceptions
	Win32_PerfFormattedData_NETFramework_NETCLRInterop
	Win32_PerfFormattedData_NETFramework_NETCLRJit
	Win32_PerfFormattedData_NETFramework_NETCLRLoading
	Win32_PerfFormattedData_NETFramework_NETCLRLocksAndThreads
	Win32_PerfFormattedData_NETFramework_NETCLRMemory
	Win32_PerfFormattedData_NETFramework_NETCLRRemoting
	Win32_PerfFormattedData_NETFramework_NETCLRSecurity
	Win32_PerfFormattedData_NTFSDRV_ControladordealmacenamientoNTFSdeSMTP
	Win32_PerfFormattedData_Outlook_Outlook
	Win32_PerfFormattedData_PerfDisk_LogicalDisk
	Win32_PerfFormattedData_PerfDisk_PhysicalDisk
	Win32_PerfFormattedData_PerfNet_Browser
	Win32_PerfFormattedData_PerfNet_Redirector
	Win32_PerfFormattedData_PerfNet_Server
	Win32_PerfFormattedData_PerfNet_ServerWorkQueues
	Win32_PerfFormattedData_PerfOS_Cache
	Win32_PerfFormattedData_PerfOS_Memory
	Win32_PerfFormattedData_PerfOS_Objects
	Win32_PerfFormattedData_PerfOS_PagingFile
	Win32_PerfFormattedData_PerfOS_Processor
	Win32_PerfFormattedData_PerfOS_System
	Win32_PerfFormattedData_PerfProc_FullImage_Costly
	Win32_PerfFormattedData_PerfProc_Image_Costly
	Win32_PerfFormattedData_PerfProc_JobObject
	Win32_PerfFormattedData_PerfProc_JobObjectDetails
	Win32_PerfFormattedData_PerfProc_Process
	Win32_PerfFormattedData_PerfProc_ProcessAddressSpace_Costly
	Win32_PerfFormattedData_PerfProc_Thread
	Win32_PerfFormattedData_PerfProc_ThreadDetails_Costly
	Win32_PerfFormattedData_RemoteAccess_RASPort
	Win32_PerfFormattedData_RemoteAccess_RASTotal
	Win32_PerfFormattedData_RSVP_RSVPInterfaces
	Win32_PerfFormattedData_RSVP_RSVPService
	Win32_PerfFormattedData_Spooler_PrintQueue
	Win32_PerfFormattedData_TapiSrv_Telephony
	Win32_PerfFormattedData_Tcpip_ICMP
	Win32_PerfFormattedData_Tcpip_IP
	Win32_PerfFormattedData_Tcpip_NBTConnection
	Win32_PerfFormattedData_Tcpip_NetworkInterface
	Win32_PerfFormattedData_Tcpip_TCP
	Win32_PerfFormattedData_Tcpip_UDP
	Win32_PerfFormattedData_TermService_TerminalServices
	Win32_PerfFormattedData_TermService_TerminalServicesSession
	Win32_PerfFormattedData_W3SVC_WebService
	Win32_PerfRawData_ASP_ActiveServerPages
	Win32_PerfRawData_ASPNET_114322_ASPNETAppsv114322
	Win32_PerfRawData_ASPNET_114322_ASPNETv114322
	Win32_PerfRawData_ASPNET_2040607_ASPNETAppsv2040607
	Win32_PerfRawData_ASPNET_2040607_ASPNETv2040607
	Win32_PerfRawData_ASPNET_ASPNET
	Win32_PerfRawData_ASPNET_ASPNETApplications
	Win32_PerfRawData_aspnet_state_ASPNETStateService
	Win32_PerfRawData_ContentFilter_IndexingServiceFilter
	Win32_PerfRawData_ContentIndex_IndexingService
	Win32_PerfRawData_DTSPipeline_SQLServerDTSPipeline
	Win32_PerfRawData_Fax_FaxServices
	Win32_PerfRawData_InetInfo_InternetInformationServicesGlobal
	Win32_PerfRawData_ISAPISearch_HttpIndexingService
	Win32_PerfRawData_MSDTC_DistributedTransactionCoordinator
	Win32_PerfRawData_NETCLRData_NETCLRData
	Win32_PerfRawData_NETCLRNetworking_NETCLRNetworking
	Win32_PerfRawData_NETDataProviderforOracle_NETCLRData
	Win32_PerfRawData_NETDataProviderforSqlServer_NETDataProviderforSqlServer
	Win32_PerfRawData_NETFramework_NETCLRExceptions
	Win32_PerfRawData_NETFramework_NETCLRInterop
	Win32_PerfRawData_NETFramework_NETCLRJit
	Win32_PerfRawData_NETFramework_NETCLRLoading
	Win32_PerfRawData_NETFramework_NETCLRLocksAndThreads
	Win32_PerfRawData_NETFramework_NETCLRMemory
	Win32_PerfRawData_NETFramework_NETCLRRemoting
	Win32_PerfRawData_NETFramework_NETCLRSecurity
	Win32_PerfRawData_NTFSDRV_ControladordealmacenamientoNTFSdeSMTP
	Win32_PerfRawData_Outlook_Outlook
	Win32_PerfRawData_PerfDisk_LogicalDisk
	Win32_PerfRawData_PerfDisk_PhysicalDisk
	Win32_PerfRawData_PerfNet_Browser
	Win32_PerfRawData_PerfNet_Redirector
	Win32_PerfRawData_PerfNet_Server
	Win32_PerfRawData_PerfNet_ServerWorkQueues
	Win32_PerfRawData_PerfOS_Cache
	Win32_PerfRawData_PerfOS_Memory
	Win32_PerfRawData_PerfOS_Objects
	Win32_PerfRawData_PerfOS_PagingFile
	Win32_PerfRawData_PerfOS_Processor
	Win32_PerfRawData_PerfOS_System
	Win32_PerfRawData_PerfProc_FullImage_Costly
	Win32_PerfRawData_PerfProc_Image_Costly
	Win32_PerfRawData_PerfProc_JobObject
	Win32_PerfRawData_PerfProc_JobObjectDetails
	Win32_PerfRawData_PerfProc_Process
	Win32_PerfRawData_PerfProc_ProcessAddressSpace_Costly
	Win32_PerfRawData_PerfProc_Thread
	Win32_PerfRawData_PerfProc_ThreadDetails_Costly
	Win32_PerfRawData_RemoteAccess_RASPort
	Win32_PerfRawData_RemoteAccess_RASTotal
	Win32_PerfRawData_RSVP_RSVPInterfaces
	Win32_PerfRawData_RSVP_RSVPService
	Win32_PerfRawData_Spooler_PrintQueue
	Win32_PerfRawData_TapiSrv_Telephony
	Win32_PerfRawData_Tcpip_ICMP
	Win32_PerfRawData_Tcpip_IP
	Win32_PerfRawData_Tcpip_NBTConnection
	Win32_PerfRawData_Tcpip_NetworkInterface
	Win32_PerfRawData_Tcpip_TCP
	Win32_PerfRawData_Tcpip_UDP
	Win32_PerfRawData_TermService_TerminalServices
	Win32_PerfRawData_TermService_TerminalServicesSession
	Win32_PerfRawData_W3SVC_WebService
	Win32_PhysicalMedia
	Win32_PhysicalMemory
	Win32_PhysicalMemoryArray
	Win32_PhysicalMemoryLocation
	Win32_PingStatus
	Win32_PNPAllocatedResource
	Win32_PnPDevice
	Win32_PnPEntity
	Win32_PnPSignedDriver
	Win32_PnPSignedDriverCIMDataFile
	Win32_PointingDevice
	Win32_PortableBattery
	Win32_PortConnector
	Win32_PortResource
	Win32_POTSModem
	Win32_POTSModemToSerialPort
	Win32_Printer
	Win32_PrinterConfiguration
	Win32_PrinterController
	Win32_PrinterDriver
	Win32_PrinterDriverDll
	Win32_PrinterSetting
	Win32_PrinterShare
	Win32_PrintJob
	Win32_Process
	Win32_Processor
	Win32_Product
	Win32_ProductCheck
	Win32_ProductResource
	Win32_ProductSoftwareFeatures
	Win32_ProgIDSpecification
	Win32_ProgramGroup
	Win32_ProgramGroupContents
	Win32_Property
	Win32_ProtocolBinding
	Win32_Proxy
	Win32_PublishComponentAction
	Win32_QuickFixEngineering
	Win32_QuotaSetting
	Win32_Refrigeration
	Win32_Registry
	Win32_RegistryAction
	Win32_RemoveFileAction
	Win32_RemoveIniAction
	Win32_ReserveCost
	Win32_ScheduledJob
	Win32_SCSIController
	Win32_SCSIControllerDevice
	Win32_SecuritySettingOfLogicalFile
	Win32_SecuritySettingOfLogicalShare
	Win32_SelfRegModuleAction
	Win32_SerialPort
	Win32_SerialPortConfiguration
	Win32_SerialPortSetting
	Win32_ServerConnection
	Win32_ServerSession
	Win32_Service
	Win32_ServiceControl
	Win32_ServiceSpecification
	Win32_ServiceSpecificationService
	Win32_SessionConnection
	Win32_SessionProcess
	Win32_Share
	Win32_ShareToDirectory
	Win32_ShortcutAction
	Win32_ShortcutFile
	Win32_ShortcutSAP
	Win32_SID
	Win32_SoftwareElement
	Win32_SoftwareElementAction
	Win32_SoftwareElementCheck
	Win32_SoftwareElementCondition
	Win32_SoftwareElementResource
	Win32_SoftwareFeature
	Win32_SoftwareFeatureAction
	Win32_SoftwareFeatureCheck
	Win32_SoftwareFeatureParent
	Win32_SoftwareFeatureSoftwareElements
	Win32_SoundDevice
	Win32_StartupCommand
	Win32_SubDirectory
	Win32_SystemAccount
	Win32_SystemBIOS
	Win32_SystemBootConfiguration
	Win32_SystemDesktop
	Win32_SystemDevices
	Win32_SystemDriver
	Win32_SystemDriverPNPEntity
	Win32_SystemEnclosure
	Win32_SystemLoadOrderGroups
	Win32_SystemLogicalMemoryConfiguration
	Win32_SystemNetworkConnections
	Win32_SystemOperatingSystem
	Win32_SystemPartitions
	Win32_SystemProcesses
	Win32_SystemProgramGroups
	Win32_SystemResources
	Win32_SystemServices
	Win32_SystemSlot
	Win32_SystemSystemDriver
	Win32_SystemTimeZone
	Win32_SystemUsers
	Win32_TapeDrive
	Win32_TCPIPPrinterPort
	Win32_TemperatureProbe
	Win32_Terminal
	Win32_TerminalService
	Win32_TerminalServiceSetting
	Win32_TerminalServiceToSetting
	Win32_TerminalTerminalSetting
	Win32_Thread
	Win32_TimeZone
	Win32_TSAccount
	Win32_TSClientSetting
	Win32_TSEnvironmentSetting
	Win32_TSGeneralSetting
	Win32_TSLogonSetting
	Win32_TSNetworkAdapterListSetting
	Win32_TSNetworkAdapterSetting
	Win32_TSPermissionsSetting
	Win32_TSRemoteControlSetting
	Win32_TSSessionDirectory
	Win32_TSSessionDirectorySetting
	Win32_TSSessionSetting
	Win32_TypeLibraryAction
	Win32_UninterruptiblePowerSupply
	Win32_USBController
	Win32_USBControllerDevice
	Win32_USBHub
	Win32_UserAccount
	Win32_UserDesktop
	Win32_UserInDomain
	Win32_UTCTime
	Win32_VideoController
	Win32_VideoSettings
	Win32_VoltageProbe
	Win32_VolumeQuotaSetting
	Win32_WindowsProductActivation
	Win32_WMIElementSetting
	Win32_WMISetting
</comment>









