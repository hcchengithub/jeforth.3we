
s" shell.application.f"	source-code-header

\ -------------- Microsoft Windows Shell.Application COM object ----------------------------------------------------
\ I think it would be suitable for a stand alone shellapplication.f 
\ [ ] see evernote for related articles.

\ : shell.application ( -- obj ) \ Get shell.application COM object
\ 				char Shell.Application ActiveXObject ;
char Shell.Application ActiveXObject constant shell.application // ( -- obj ) shell.application COM object

: ShutdownWindows ( -- ) \ Pops up the dialog for Log out, Power off, Reboot, Sleep, or Hibernation
				shell.application js> pop().ShutdownWindows() ;

: findfiles		( -- undefined ) \ Launch Win-F diaglog box or Windows 8 U/I to find a file.
				shell.application js> pop().findfiles() ;
				/// The Win8 UI only wants to open the file by an AP. So it 
				/// does not return a meaningful result like a full-path or 
				/// the likes. This is useless.

: open.c:\		( -- ) \ Demo how to open the 'c:\' folder. 
				shell.application <js> pop().Open("C:\\") </js> ;

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
				shell.application <js> pop().FileRun() </js> ;
				/// Similar to above fork or (fork).

: PhysicalMemoryInstalled ( -- nbytes ) \ Get memory size of this computer in OS's view point.
				shell.application 
				<js> pop().GetSystemInformation("PhysicalMemoryInstalled")</jsV> ;

: IsOS_DomainMember ( -- boolean ) \ Is this computer a domain member?
				shell.application 
				<js> pop().GetSystemInformation("IsOS_DomainMember")</jsV> ;

: WindowSwitcher ( -- ) \ equivalent to press Alt-Tab
				shell.application <js> pop().WindowSwitcher() </js> ;

: MyDocument	( -- ) \ Open the MyDocument folder
				shell.application <js> pop().explore(5) </js> ;

\ 忘了以下是啥了，似乎挺有趣，保留。
\ shell.application <js> pop().ShowBrowserBar("{EFA24E61-B078-11d0-89E4-00C04FC9E26E}", true) </js>
\ shell.application <js> pop().ShowBrowserBar("{EFA24E64-B078-11d0-89E4-00C04FC9E26E}", true) </js>
\ shell.application <js> pop().ShowBrowserBar("{30D02401-6A81-11d0-8274-00C04FD5AE38}", true) </js>
\ 0x0010 constant FOF_NOCONFIRMATION 	
\ 0x0080 constant FOF_FILESONLY 		
\ 0x0100 constant FOF_SIMPLEPROGRESS 	
\ 0x0200 constant FOF_NOCONFIRMMKDIR 	
\ 0x0400 constant FOF_NOERRORUI 		

: namespace		( "path" -- folder-obj ) \ Get a destination folder object for copyHere() and moveHere()
				shell.application js> pop().namespace(pop()) ;

: copyhere		( "C:\Reports\*.FR?" folder-obj flags -- ) \ Copy "C:\Reports\*.FR?" to the folder
				js> pop(1).CopyHere(pop(1),pop()) ;

: movehere		( "C:\Reports\*.FR?" folder-obj flags -- ) \ Move "C:\Reports\*.FR?" to the folder
				js> pop(1).MoveHere(pop(1),pop()) ;

: cascadewindows ( -- ) \ Cascade Windows
				shell.application js> pop().CascadeWindows() ;

: tilevertically ( -- ) \ Tile Windows Vertically 
				shell.application js> pop().TileVertically() ;

: tilehorizontally ( -- ) \ Tile Windows Horizontally
				shell.application js> pop().TileHorizontally() ;
\ --EOF--