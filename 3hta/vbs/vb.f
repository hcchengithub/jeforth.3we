
	include f/html5.f

	s" vb.f"		source-code-header

					\ include basic.vbs
					\ 添加 VBScript tag into head section, 裡應外合才認得 VBScript.
					char script createElement constant vbsBasic
					vbsBasic char type char text/vbscript setAttribute
					vbsBasic char id   char vbsBasic      setAttribute
					vbsBasic char src  char 3hta/vbs/basic.vbs setAttribute
					eleHead vbsBasic appendChild
				
					\ 不用 global 因為 Note-webkit 已經有用到，改用 kvm 最保險。 
					\ 讓 VBScript 認得 global. global object 含有 jeforth.3hta 所有的 global variables.
					\ js> global <text>
					\ 	Dim global
					\ 	Set global = kvm.pop()
					\ </text> js: vbExecuteGlobal(pop())
				
	code vbEval 	( "string" -- result ) \ Evaluate the given vbs statements return value on TOS.
					try {
						var result = vbEval(pop());
						push(result);
					} catch(err) {
						panic("VBscript error : "+err.message+"\n", "error");
					};
					end-code
					
					<selftest> 
						*** vbEval evaluates a VBS statement ... 
						s" 123 * 456" vbEval
						123 456 * = 
						==>judge [if] <js> ['vbEval'] </jsV> all-pass [then]
					</selftest>

	code vbExecute 	( "string" -- ) \ Execute the given vbs statements, you need to push return value in your program.
					try {
						vbExecute(pop());
					} catch(err) {
						panic("VBscript error : "+err.message+"\n", "error");
					};
					end-code

	code vbExecuteGlobal ( "string" -- ) \ Execute the given vbs statements, you need to push return value in your program.
					try {
						vbExecuteGlobal(pop());
					} catch(err) {
						panic("VBscript error : "+err.message+"\n", "error");
					};
					end-code
					/// Things defined by it will be global.
					
					<selftest> 
						*** vbExecuteGlobal creates global none-volatile things ... 
						<text>
						   Dim vbExecuteGlobal_test_temp
						   vbExecuteGlobal_test_temp = "I am good"
						</text> vbExecuteGlobal 
						js> vbExecuteGlobal_test_temp s" I am good" =
						==>judge [if] <js> ['vbEval'] </jsV> all-pass [then]
					</selftest>
		
	: <vb> 			( <vbs statements> -- "statements" ) \ Execute vbs statements
					char </vb> word 
					compiling if [compile] literal then ; immediate
	
	: </vb> 		( "statements" -- ) \ No return value
					compiling if compile vbExecute else vbExecute then ; immediate
					\ Example,
					\	<vb>
					\	name = InputBox ("What's your name?", "Welcome")
					\	MsgBox "Hello, " & name & " !!", 1, "VBS test"
					\	</vb>

	: vb: 			( <vbs statements> -- ) \ Execute a line of vbs statement
					BL word compiling if [compile] literal compile vbExecute else vbExecute then  ; immediate
					/// Same thing as "s' blablabla' vbExecute" but simpler.
					
	: vb> 			( <vbs statements> -- result ) \ Evaluate vbs statements
					BL word compiling if [compile] literal compile vbEval else vbEval then  ; immediate
					/// Same thing as "s' blablabla' vbEval" but simpler. Return the last statement's value.

					\ Print ScriptEngine version
					vb> ScriptEngine . space char V .
					vb> ScriptEngineMajorVersion  . char . .
					vb> ScriptEngineMinorVersion  . space char Build: .
					vb> ScriptEngineBuildVersion  . 
					cr
					<vb> Set o=GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2"): kvm.push(o) </vb> \ objWMIService
					<js> 
						var objWMIService = pop();
						var myPath = window.location.pathname.toLowerCase();
						var colProcesses = objWMIService.ExecQuery("Select * from Win32_Process Where Name = 'mshta.exe'");
						var enumProcesses = new Enumerator(colProcesses);
						for ( var p = null ; !enumProcesses.atEnd() ; enumProcesses.moveNext() ) {
							p = enumProcesses.item();
						}
						kvm.process = p;
						print("jeforth.hta process ID:" + p.ProcessID + '\n');
						// start /WAIT jeforth.hta js: kvm.process.terminate('12345')
						// echo %errorlevel% ==> prints 
					</js> 
					
	js> kvm.process constant kvm.process // ( -- Win32_process ) Process object of this mshta.exe
					/// see http://msdn.microsoft.com/en-us/library/aa394372(v=vs.85).aspx
					/// or search "Win32_Process class" in MSDN.
	

	: bye			( errorlevel -- ) \ Terminate jeforth.hta return TOS as the errorlevel
					<js> 
						if(stack.length==0 || isNaN(tos())) push(0); 
						kvm.process.terminate(pop());
					</js> ;
					/// start /WAIT jeforth.hta . . . don't forget the /WAIT option!
	
	\ ------------------- Collection and Enumerator Object ----------------------------------------------------------------------
	\
	\ Unlike 'array', members of a 'collection' are not directly accessible. Instead of using index, 
	\ as we do with arrays, you can only move the current item pointer to the first or next element 
	\ of a collection. 
	\ 
	\ The Enumerator object provides a way to access any member of a collection and behaves 
	\ similarly to the For...Each statement in VBScript by while(!enum.atEnd()) {...enum.item()...; enum.moveNext();}
	\ for (var i=0; !enum.atEnd(); i++, enum.moveNext()){}
	\
	\ Enumerator has these methods : atEnd(), item(), moveFirst(), moveNext()
	\

	code Enumerator ( collection -- oEnumerator ) \ Translate collection to oEnumerator.
					push(new Enumerator(pop()))
					end-code
					/// atEnd(), item(void), moveFirst(), moveNext()
					/// while(!enum.atEnd()) {enum.item().Name; enum.moveNext();}
					/// for (var i=0; !enum.atEnd(); i++, enum.moveNext()){...enum.item().Name...}

	\ Example:
	\ This is a collection of PnP entity : push(objWMIService.ExecQuery("Select * from Win32_PnPEntity"))
	\ Translate to an enumerator         : Enumerator constant epnp
	\ Two different ways to list all PnP things:
	\   epnp.moveFirst(); while (!epnp.atEnd()) {systemtype(epnp.item().Name+"\n"); epnp.moveNext();}
	\   epnp.moveFirst(); for (var i=0; !epnp.atEnd(); i++, epnp.moveNext()){systemtype(epnp.item().Name + "\n")}


	\ ------------------- VBArray ----------------------------------------------------------------------
	\
	\ VBScript's safeArray, or VBArray, which has an 'unknown' type in JScript is not a normal JavaScript 
	\ array. JScript can access safeArray through these methods : dimensions(), getItem(i), lbound(), 
	\ ubound(), and toArray(). JSCript VBArray() function translates a safeArray into a JScript object 
	\ that has above methods. But I don't think we need to use it because JScript can access VBArray.

	code VBArray 	( safeArray -- obj ) \ Translate VBA safeArray to JScript object.
					push(new VBArray(pop()))
					end-code
					/// dimensions(), getItem(row,column,...), lbound(), ubound(), toArray()
					/// Note, translate to JScript object is not necessary because JScript can access 
					/// safeArray directly by these methods.

	: .VBArray 		( safeArray -- ) \ Print VBA safeArray. 
					dup null = if else js> pop().toArray() then . ;
					/// typeof(VBArray) is "unknown" when it is something or "null" when it is empty.

	<comment>
	
	Playing with WMI demos @ http://msdn.microsoft.com/en-us/library/aa394599(v=vs.85).aspx

	Example: ...run an application in a hidden window?
	Compatibility: fine, no change needed
	Comment: Use Task Manager to kill an invisible notepad process. -- hcchen5600 2014/07/01 15:37:42 
	         The below ExecQuery demo can find it too.
			 The below objProcess.Terminate() demo can close it.
		<vb>
		Const HIDDEN_WINDOW = 0
		strComputer = "."
		Set objWMIService = GetObject("winmgmts:" _
			& "{impersonationLevel=impersonate}!\\" _
			& strComputer & "\root\cimv2")
		Set objStartup = objWMIService.Get("Win32_ProcessStartup")
		Set objConfig = objStartup.SpawnInstance_
		objConfig.ShowWindow = HIDDEN_WINDOW
		Set objProcess = GetObject( _
			"winmgmts:root\cimv2:Win32_Process")
		errReturn = objProcess.Create( _
		"Notepad.exe", null, objConfig, intProcessID)
		</vb>
		
		\ This is a neat version. Run systeminfo.exe directly is fine, but we need cmd.exe to stay and read the results.
		<vb>
		Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
		Set objStartup = objWMIService.Get("Win32_ProcessStartup")
		Set objConfig = objStartup.SpawnInstance_
		Set objProcess = GetObject("winmgmts:root\cimv2:Win32_Process")
		errReturn = objProcess.Create("cmd /k systeminfo", null, objConfig, intProcessID)
		</vb>

		\ To run anything, includes jeforth.3wsh's run.bat batch program!!
		<vb>
		Set objProcess = GetObject("winmgmts:root\cimv2:Win32_Process")
		errReturn = objProcess.Create("c:\Users\8304018.WKSCN\Dropbox\learnings\github\jeforth.3wsh\run.bat")
		kvm.push(errReturn)
		</vb>
		
		\ The actual application is like this,
		<vb> Set o=GetObject("winmgmts:root\cimv2:Win32_Process"): kvm.push(o) </vb> constant Win32_Process
		Win32_Process js: pop().Create("cmd")
	
	Example: ...determine which scripts are running on the local computer?
	Compatibility: fair, change 'Wscript.Echo' to 'print' then it works
	Comment: Run jeforth.wsh first, you really see it listed.
		<vb>
		strComputer = "." 
		Set objWMIService = GetObject( _
			"winmgmts:\\" & strComputer & "\root\CIMV2") 
		Set colItems = objWMIService.ExecQuery( _
			"SELECT * FROM Win32_Process" & _
			" WHERE Name = 'cscript.exe'" & _
			" OR Name = 'mshta.exe'",,48) 
		For Each objItem in colItems 
			print "-------------------------------------------" & vbCrLf
			print "CommandLine: " & objItem.CommandLine & vbCrLf
			print "Name: " & objItem.Name & vbCrLf
		Next
		</vb>		
		
	Example: ...find out the account name under which a process is running?
	Compatibility: fair, change 'Wscript.Echo' to 'print' then it works. Add vbCrLf too.
	Comment: The above example that runs a hiden notepad.exe which is listed too.
		<vb>
			strComputer = "."
			Set objWMIService = GetObject("winmgmts:" _
				& "{impersonationLevel=impersonate}!\\" _
				& strComputer & "\root\cimv2")
			Set colProcessList = objWMIService.ExecQuery _
				("Select * from Win32_Process")
			For Each objProcess in colProcessList
				colProperties = objProcess.GetOwner( _
					strNameOfUser,strUserDomain)
				print "Process " & objProcess.Name _
					& " is owned by " _ 
					& strUserDomain & "\" & strNameOfUser & "." & vbCrLf
			Next
		</vb>
		
	Example: ...terminate a process using a script?
	Compatibility: fine, no change needed	
	Comment: It closes the above invisible notepad.exe demo.
		<vb>
			strComputer = "."
			Set objWMIService = GetObject("winmgmts:" _
				& "{impersonationLevel=impersonate}!\\" _
				& strComputer & "\root\cimv2")
			Set colProcessList = objWMIService.ExecQuery _
				("Select * from Win32_Process Where Name = 'Notepad.exe'")
			For Each objProcess in colProcessList
				objProcess.Terminate()
			Next
		</vb>
		
	Example: ...determine how much processor time and memory each process is using?
	Compatibility: fair, change 'Wscript.Echo' to 'print' then it works. Add vbCrLf too.
				   fine, no change needed	
	Comment: Wow, so easy!
		<vb>
			strComputer = "."
			Set objWMIService = GetObject("winmgmts:" _
				& "{impersonationLevel=impersonate}!\\" _
				& strComputer & "\root\cimv2")
			Set colProcesses = objWMIService.ExecQuery _
			   ("Select * from Win32_Process")
			For Each objProcess in colProcesses
				print "Process: " & objProcess.Name & vbCrLf
				sngProcessTime = (CSng(objProcess.KernelModeTime) + _
					CSng(objProcess.UserModeTime)) / 10000000
				print "Processor Time: " & sngProcessTime & vbCrLf
				print "Process ID: " & objProcess.ProcessID & vbCrLf
				print "Working Set Size: " _
				& objProcess.WorkingSetSize & vbCrLf
				print "Page File Size: " _
				& objProcess.PageFileUsage & vbCrLf
				print "Page Faults: " & objProcess.PageFaults & vbCrLf & vbCrLf
			Next
		</vb>
		
	Example: ...tell what applications are running on a remote computer? 
	Compatibility: fair, change 'Wscript.Echo' to 'print' then it works. Add vbCrLf too.
				   fine, no change needed	
	Comment: No it doesn't work so far hcchen5600 2014/07/01 18:49:04 
		<vb>
			strComputer = "WKS-38EN3476"
			Set objWMIService = GetObject("winmgmts:" _
				& "{impersonationLevel=impersonate}!\\" _
				& strComputer & "\root\cimv2")
			Set colProcessList = objWMIService.ExecQuery _
				("Select * from Win32_Process")
			For Each objProcess in colProcessList
				print "Process: " & objProcess.Name  & vbCrLf
				print "Process ID: " & objProcess.ProcessID  & vbCrLf
				print "Thread Count: " & objProcess.ThreadCount  & vbCrLf
				print "Page File Size: " _
					& objProcess.PageFileUsage  & vbCrLf
				print "Page Faults: " _
					& objProcess.PageFaults  & vbCrLf
				print "Working Set Size: " _
					& objProcess.WorkingSetSize  & vbCrLf
			Next
		</vb>
		
	Example: Sample VBS WMI reads disk information
	Compatibility: fair, change 'Wscript.Echo' to 'print' then it works. Add vbCrLf too.
	Comment: It works!
		<vb>
			' Disk.vbs
			' Sample VBS WMI
			' Author Guy Thomas http://computerperformance.co.uk/
			' http://www.computerperformance.co.uk/vbscript/wmi_basics.htm
			' Version 1.5 - November 2010
			' -----------------------------------------------' 
			Option Explicit
			Dim objWMIService, objItem, colItems, strComputer, intDrive
			
			' On Error Resume Next
			strComputer = "."
			intDrive = 0
			
			' WMI connection to Root CIM
			Set objWMIService = GetObject("winmgmts:\\" _
			& strComputer & "\root\cimv2")
			Set colItems = objWMIService.ExecQuery(_
			"Select * from Win32_DiskDrive")
			
			' Classic For Next Loop
			For Each objItem in colItems
				intDrive = intDrive + 1
				print "DiskDrive " & intDrive & vbCrLf & _ 
					"Caption: " & objItem.Caption & vbCrLf & _ 
					"Description: " & objItem.Description & vbCrLf & _ 
					"Manufacturer: " & objItem.Manufacturer & vbCrLf & _ 
					"Model: " & objItem.Model & vbCrLf & _ 
					"Name: " & objItem.Name & vbCrLf & _ 
					"Partitions: " & objItem.Partitions & vbCrLf & _ 
					"Size: " & objItem.Size & vbCrLf & _ 
					"Status: " & objItem.Status & vbCrLf & _ 
					"SystemName: " & objItem.SystemName & vbCrLf & _ 
					"TotalCylinders: " & objItem.TotalCylinders & vbCrLf & _ 
					"TotalHeads: " & objItem.TotalHeads & vbCrLf & _ 
					"TotalSectors: " & objItem.TotalSectors & vbCrLf & _ 
					"TotalTracks: " & objItem.TotalTracks & vbCrLf & _ 
					"TracksPerCylinder: " & objItem.TracksPerCylinder 
			Next
			
			' End of Sample Disk VBScript
		</vb>
		
	Example: 
	Compatibility: fair, change 'Wscript.Echo' to 'print' then it works. Add vbCrLf too.
				   fine, no change needed	
	Comment: 
		<vb>
		</vb>

	Example: 
	Compatibility: fair, change 'Wscript.Echo' to 'print' then it works. Add vbCrLf too.
				   fine, no change needed	
	Comment: 
		<vb>
		</vb>

	</comment>		
