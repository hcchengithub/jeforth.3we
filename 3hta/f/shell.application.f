
s" shell.application.f"	source-code-header

\ -------------- Microsoft Windows Shell.Application COM object ----------------------------------------------------
\ Refer to MSDN : 
\	Windows desktop applications >  Develop >  Desktop technologies >  
\ 	Desktop Environment >  The Windows Shell >  Shell Reference >  
\ 	Shell Objects for Scripting and Microsoft Visual Basic >  Shell > ...
\ 用 PowerShell 也可以查出(部分) shell.application 的功能。 見於 https://msdn.microsoft.com/en-us/library/windows/desktop/bb774063(v=vs.85).aspx 網友 comment。
\	# get object
\	$shell  = new-object -com shell.application
\	# Display members of the shell.application object. PowerShell 下列出 shell.application members.
\	$shell | get-member
\
\ I guess these pages may be useful too :
\	Microsoft dev center http://dev.windows.com
\	[x] see Evernote for related articles.
\	Scriptable Shell Objects http://msdn.microsoft.com/en-us/library/windows/desktop/bb776890(v=vs.85).aspx
\	好像 shell.application 與 Shell Objects 不同? 無不同,同一件事。
\	Windows Shell https://msdn.microsoft.com/en-us/library/windows/desktop/bb773177(v=vs.85).aspx

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
				/// See explore() metnod, it's better and more interesting.

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

: MyDocument	( -- ) \ Use shell.application :: explore() method to open the MyDocument folder
				shell.application :: explore(5) ;
				/// https://msdn.microsoft.com/en-us/library/windows/desktop/bb774073(v=vs.85).aspx
				/// explore() method is better than open() method by supporting 
				/// ShellSpecialFolderConstants https://msdn.microsoft.com/en-us/library/windows/desktop/bb774096(v=vs.85).aspx
				///	typedef enum  { 
				///	  ssfALTSTARTUP        = 0x1d,
				///	  ssfAPPDATA           = 0x1a,
				///	  ssfBITBUCKET         = 0x0a,
				///	  ssfCOMMONALTSTARTUP  = 0x1e,
				///	  ssfCOMMONAPPDATA     = 0x23,
				///	  ssfCOMMONDESKTOPDIR  = 0x19,
				///	  ssfCOMMONFAVORITES   = 0x1f,
				///	  ssfCOMMONPROGRAMS    = 0x17,
				///	  ssfCOMMONSTARTMENU   = 0x16,
				///	  ssfCOMMONSTARTUP     = 0x18,
				///	  ssfCONTROLS          = 0x03,
				///	  ssfCOOKIES           = 0x21,
				///	  ssfDESKTOP           = 0x00,
				///	  ssfDESKTOPDIRECTORY  = 0x10,
				///	  ssfDRIVES            = 0x11,
				///	  ssfFAVORITES         = 0x06,
				///	  ssfFONTS             = 0x14,
				///	  ssfHISTORY           = 0x22,
				///	  ssfINTERNETCACHE     = 0x20,
				///	  ssfLOCALAPPDATA      = 0x1c,
				///	  ssfMYPICTURES        = 0x27,
				///	  ssfNETHOOD           = 0x13,
				///	  ssfNETWORK           = 0x12,
				///	  ssfPERSONAL          = 0x05,
				///	  ssfPRINTERS          = 0x04,
				///	  ssfPRINTHOOD         = 0x1b,
				///	  ssfPROFILE           = 0x28,
				///	  ssfPROGRAMFILES      = 0x26,
				///	  ssfPROGRAMFILESx86   = 0x30,
				///	  ssfPROGRAMS          = 0x02,
				///	  ssfRECENT            = 0x08,
				///	  ssfSENDTO            = 0x09,
				///	  ssfSTARTMENU         = 0x0b,
				///	  ssfSTARTUP           = 0x07,
				///	  ssfSYSTEM            = 0x25,
				///	  ssfSYSTEMx86         = 0x29,
				///	  ssfTEMPLATES         = 0x15,
				///	  ssfWINDOWS           = 0x24
				///	} ShellSpecialFolderConstants;

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