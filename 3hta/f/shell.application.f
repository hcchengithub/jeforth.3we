
s" shell.application.f"	source-code-header

\ -------------- Microsoft Windows Shell.Application COM object ----------------------------------------------------
\ I think it would be suitable for a stand alone shellapplication.f 
\ [ ] see Evernote for related articles.

char Shell.Application ActiveXObject constant shell.application // ( -- obj ) shell.application COM object

: ShutdownWindows ( -- ) \ Pops up the dialog for Log out, Power off, Reboot, Sleep, or Hibernation
				shell.application :: ShutdownWindows() ;

: findfiles		( -- ) \ Launch Win-F diaglog box or Windows 8 U/I to find a file.
				shell.application :: findfiles() ;
				/// This is useless.
				/// The Win8 UI only wants to open the file by an AP. So it 
				/// does not return a meaningful result like a full-path or 
				/// the likes. 
				/// Win10, just like pressing the Windows key. Useless too.

: open.c:\		( -- ) \ Demo how to open the 'c:\' folder. 
				shell.application :: Open("C:\\") ;
				/// Open(".") no work.

: get-folder	( iOptions -- objFolder ) \ Get folder object through Windows GUI
				shell.application 
				<js> 
					var vRootFolder = 0x11; // special folder 0x11 is MyComputer, or someting like "d:\\"
					var iOptions = pop(1); 
					pop().BrowseForFolder(0,"Get me the folder",iOptions,vRootFolder) 
				</jsV> ;
				/// BrowseForFolder see: 
				///     http://msdn.microsoft.com/en-us/library/windows/desktop/bb774065(v=vs.85).aspx
				/// 'iOptions' try 0xC0 or see: 
				///     'ulFlags' of http://msdn.microsoft.com/en-us/library/bb773205%28VS.85%29.aspx

: run-dialog	( -- ) \ Equivalent to clicking the Start menu and selecting Run.
				shell.application :: FileRun() ;
				/// Similar to above fork or (fork).

: PhysicalMemoryInstalled ( -- nbytes ) \ Get memory size of this computer in OS's view point.
				shell.application :> GetSystemInformation("PhysicalMemoryInstalled") ;

: IsOS_DomainMember ( -- boolean ) \ Is this computer a domain member?
				shell.application :> GetSystemInformation("IsOS_DomainMember") ;

: WindowSwitcher ( -- ) \ equivalent to press Alt-Tab
				shell.application :: WindowSwitcher() ;
				/// 到了 Windows 10 已經不靈了。

: MyDocument	( -- ) \ Open the MyDocument folder
				shell.application :: explore(5) ;

: namespace		( "path" -- objFolder ) \ Get a destination folder object for copyHere() and moveHere()
				shell.application :> namespace(pop()) ;
				/// char c:\ namespace <-- works
				/// char . namespace <-- no work

: copyhere		( "C:\Reports\*.FR?" objFolder flags -- ) \ Copy "C:\Reports\*.FR?" to the folder
				js> pop(1).CopyHere(pop(1),pop()) ;
				/// 0x0010 constant FOF_NOCONFIRMATION 	
				/// 0x0080 constant FOF_FILESONLY 		
				/// 0x0100 constant FOF_SIMPLEPROGRESS 	
				/// 0x0200 constant FOF_NOCONFIRMMKDIR 	
				/// 0x0400 constant FOF_NOERRORUI 		

: movehere		( "C:\Reports\*.FR?" folder-obj flags -- ) \ Move "C:\Reports\*.FR?" to the folder
				js> pop(1).MoveHere(pop(1),pop()) ;

: cascadewindows ( -- ) \ Cascade Windows
				shell.application js> pop().CascadeWindows() ;

: tilevertically ( -- ) \ Tile Windows Vertically 
				shell.application js> pop().TileVertically() ;

: tilehorizontally ( -- ) \ Tile Windows Horizontally
				shell.application js> pop().TileHorizontally() ;
\ --EOF--