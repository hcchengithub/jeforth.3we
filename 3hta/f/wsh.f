\ utf-8

include vb.f

s" wsh.f"	source-code-header

<js> vm.fso = new ActiveXObject("Scripting.FileSystemObject") </jsV> constant vm.fso // ( -- fso ) Scripting.FileSystemObject

				<selftest> 
					*** vm.fso check the recent folder existance
					js> vm.fso.FolderExists('.') \ ==> true (boolean)
					[d true d] [p 'vm.fso' p]
				</selftest>

code ActiveXObject	( "name.application" -- objApp ) \ Open the name.application COM object
				try {
					var obj = new ActiveXObject(pop());
				}catch(err){
					obj = false;
				}
				push(obj);
				end-code
				/// Never! Never! lost the object reference or the application will terminate!
				/// Save it to a constant or so.

\ Make WshShell a global object
				char wscript.shell ActiveXObject constant WshShell // ( -- obj ) WshShell object
				WshShell js: window.WshShell=pop() 

				<selftest> 
				\	Windows 10 小計算機的行為變了, 簡化測法 hcchen5600 2015/09/08 16:47:38 
				\ *** WshShell use SendKeys to manipulate Calculator ... 
				*** WshShell launch Calculator and confirm
					<vb> WshShell.Run "calc" </vb> 1000 sleep \ This is a fork. 
					<vb> kvm.push(WshShell.AppActivate("Calculator"))</vb> 200 sleep \ ( true )
					<vb> WshShell.SendKeys "12345" </vb> 200 sleep \ 太早回來這些 key 會變成由 3hta 衝出來收走
					<vb> WshShell.SendKeys "%{F4}" </vb> 200 sleep \ 太早回來這些 key 會變成由 3hta 衝出來收走
					[d true d] [p "ActiveXObject","WshShell" p]
stop					
				\	js> clipboardData.getData("text") ?dup not [if] "" [then] \ SAVE-restore. Clipboard can be null, so be careful. 
				\	\ js: clipboardData.setData("text","1+2=*3=")
				\	js: clipboardData.setData("text","1+2")
				\	<vb> WshShell.SendKeys "^v{enter}" </vb>             100 sleep \ Ctrl-v
				\	<vb> WshShell.SendKeys "^c" </vb>             100 sleep \ Ctrl-c 
				\	js> clipboardData.getData("text")
				\	js: clipboardData.setData("text",pop(1))  \ save-RESTORE
				\	9 = ==>judge [if] <js> ['ActiveXObject','WshShell'] </jsV> all-pass [then]
				\	<vb> WshShell.SendKeys "%" </vb> \ Release Alt key, some how other wise it got locked.
				\	<comment>
				\	\ 改用 clipboard 已經成功，不怕中文輸入模式。以下留作紀念。
				\	\ js: document.body.style.imeMode='disabled'; \ [x] 懸案，想要避免中文輸入法干擾，無效！
				\	\ <vb> WshShell.SendKeys "1{+}" </vb>           100 sleep \ Pad plus
				\	\ js: document.body.style.imeMode='auto'; 
				\	</comment>
				</selftest>
				
: activate		( ProcessID|"^title" -- ) \ Activate an application
				WshShell :: AppActivate(pop()) ;
				/// "title" is the leading 3 or more characters, case don't care.
				
: sendkeys		( "keys" -- ) \ Send keys to the recent activated application
				[ last literal ] :> wait ( -- "keys" wait ) 
				WshShell :: sendkeys(pop(1),pop()) ;
				/// == ' sendkeys :> wait ==
				/// False: (or omitted) continue running without waiting for the keys to be processed.
				/// True : wait for the keys to be processed before returning control. 
				/// 不 wait 時，可以一邊手動切 app 一邊看到（大量的）key buffer dump 過來 dump 過去。
				/// 要 wait 時，則一開始倒就無法切換。
				/// 
				/// == Usage Tip ==
				/// This method places keystrokes in a key buffer. In some cases, you must call this 
				/// method before you call the method that will use the keystrokes. For example, to 
				/// send a password to a dialog box, you must call the SendKeys method before you 
				/// display the dialog box. 
				/// 注意！JavaScript 把控制權交出去之前，這些 key 都在 buffer 裡。故應該先 sendkeys 
				/// 切往 target application 然後 nap 一會兒讓 target application 工作。
				/// 
				/// == Special keys ==
				/// +Shift ^Ctrl %Alt {BACKSPACE}or{BS},{BREAK},{CAPSLOCK},{CLEAR},{DELETE} or {DEL},
				/// {DOWN},{END},{ENTER},{ESCAPE} or {ESC},{F1}{F15},{HELP},{HOME},{INSERT},{LEFT},
				/// {NUMLOCK},{PGDN},{PGUP},{RETURN},{RIGHT},{SCROLLLOCK},{TAB},{UP},~(Enter)
				///
				/// == Example ==
				/// 先弄出個很大的 string :
				/// <js> var ss="112233"; for(var i=0; i<10000; i++) ss += "ab"; ss += "<end>"</jsV> value ss
				/// Notepad 有先跑起來。做下面實驗，其中 1 nap 讓 notepad 上手必要， 10000 nap 時間不夠
				/// 讓 keys 倒完，結果前半段倒往 notepad 後半段倒往 jeforth.3hta 的 inputbox,
				/// char untitled ( notepad ) activate 1 nap ss sendkeys 10000 nap
				/// 不論 wait 是 true/false 都一樣。
				
				
: (run)			( "command-line" -- errorlevel ) \ Run anything like Win-R does and wait for the return.
				<js> WshShell.run(pop(),5,true) </jsV> ;

: run			( <command-line> -- errorlevel ) \ Run anything like Win-R does and wait for the return.
				char \n|\r word (run) ; interpret-only 
				\ The first match of either \r or \n terminates the command line. This is important
				\ otherwise the extra \n may pollute the command line.

				<selftest> 
					*** run anything and get errlevel, includes DOS command-lines ... 
					run jeforth.hta 112233 bye 
					112233 = \ true
					( 1 not found ) run cmd /c dir | find "lalilale"    
					( 0 found     ) run cmd /c dir | find "jeforth.hta" 
					0 = swap 1 = and and 
					==>judge [if] <js> ['(run)','run'] </jsV> all-pass [then]
				</selftest>

: (fork)		( "command-line" -- ) \ Fork anything like Win-R does, fire and forget, no return value.
				<js> WshShell.run(pop(),5,false) </js> ;
				/// No return value, because the caller doesn't wait.

: fork			( <command-line> -- ) \ Fork anything like Win-R does, fire and forget, no return value.
				char \n|\r word (fork) ;
				/// No return value, because the caller doesn't wait.
				\ The first match of either \r or \n terminates the command line. This is important
				\ otherwise the extra \n may pollute the command line.

: (dos) 		( "command-line" -- errorlevel ) \ Run DOS command-line and return with errorlevel.
				s" cmd /c " swap + (run) ;

: dos			( <command-line> -- errorlevel ) \ Run DOS command-line and stay there. Errorlevel will return.
				char \n|\r word s" cmd /k " swap + (run) ;
				\ The first match of either \r or \n terminates the command line. This is important
				\ otherwise the extra \n may pollute the command line.

				<selftest> 
					*** fork append time stamp into selftest.log ... 
					s" fork and dos test " js> Date().toString() + \ ( pattern )
					s" fork cmd /c echo " over + s" >> selftest.log
					" + tib.insert 
					s' dos find "' swap + s' " selftest.log & exit
					' + tib.insert
					0 = ==>judge [if] <js> ['dos','(dos)','fork','(fork)'] </jsV> all-pass [then]
				</selftest>

: FileExists 	( "path-name" -- boolean ) \ Get file object corresponding to the pathname, no wildcard.
				js> vm.fso.FileExists(pop()) ; 

code GetFile ( "path-name" -- objFile|false ) \ Get file object corresponding to the pathname, no wildcard.
				var f;
				try {	
					f = vm.fso.GetFile(pop()); 
				} catch(err) {
					f = false;
				}
				push(f);
				end-code
				/// char pathname GetFile js> pop().Path tib. full-path
				/// char pathname GetFile js> pop().DateCreated tib.
				/// char pathname GetFile js> pop().DateLastAccessed tib.
				/// char pathname GetFile js> pop().DateLastModified tib.
				/// char a.xls GetFile js> pop().name tib. \ ==> A.XLS (string)
				
				<selftest> 
					*** GetFile gets file object ... 
					char . full-path char jeforth.hta path+name
					char jeforth.hta GetFile js> pop().Path
					= ==>judge [if] <js> ['GetFile'] </jsV> all-pass [then]
				</selftest>

code GetFolder ( "path" -- objFolder|false ) \ Get folder object corresponding to the path, no wildcard.
				var f;
				try {	
					f = vm.fso.GetFolder(pop()); 
				} catch(err) {
					f = false;
				}
				push(f);
				end-code
				/// char . GetFolder js> pop().Name tib.
				/// char . GetFolder js> pop().Path tib.  full-path
				/// char . GetFolder js> pop().DateCreated tib.
				/// char . GetFolder js> pop().DateLastAccessed tib.
				/// char . GetFolder js> pop().DateLastModified tib.
				<selftest> 
					*** GetFolder gets folder object ... 
					char . full-path 
					char . GetFolder js> pop().Path char \ +
					= ==>judge [if] <js> ['GetFolder'] </jsV> all-pass [then]
				</selftest>
				
code subFolders ( objFolder -- [objFolder,...] ) \ Get subfolder paths
				var a=[], fc = new Enumerator(pop().SubFolders);
				for (;!fc.atEnd(); fc.moveNext()) {
					a.push(fc.item());
				}
				push(a);
				end-code

\ 取消了。盲目自動 search file 不如 readTextFileAuto 有定義優先順序。而且 wsh.f 相容性也不好。
\ also forth definitions \ redefine sinclude/include in the forth word-list
\ 
\ : sinclude		( "[path]name" -- ... ) \ Auto search and lodad forth source file.
\ 				char . GetFolder subFolders <js>
\ 					var subfolders = pop();
\ 					var filename = pop();
\ 					var pathname = "";
\ 					for(var i=0; i<subfolders.length; i++){
\ 						push(pathname = subfolders[i].path + '\\' + filename); 
\ 						execute('FileExists');
\ 						if(pop()){
\ 							filename = pathname;
\ 							break;
\ 						}
\ 					}
\ 					push(filename);
\ 				</js> sinclude ; 
\ 				\ Use old sinclude, which does not support auto-search, to complete the job.
\ 
\ : include       ( <filename> -- ... ) \ Auto search and load forth source file.
\ 				BL word sinclude ; interpret-only
\ 				\ Redefine to use new sinclude command.
\ 				
\ 				<selftest> 
\ 					*** subFolders helps redefine sinclude and include ... 
\ 					' include js> pop().vid char forth = \ true, include command is new
\ 					<text> 123 456 </text> char playground/temp.f writeTextFile
\ 					include temp.f
\ 					char playground/temp.f DeleteFile
\ 					456 = swap 123 = and and
\ 					==>judge [if] <js> ['subFolders','sinclude','include'] </jsV> all-pass [then]
\ 				</selftest>
\ 
\ previous definitions

code CreateFolder ( "path" -- objFolder ) \ Create folder
				push(vm.fso.CreateFolder(pop())) end-code

code DeleteFolder ( "folderspec" -- objFolder ) \ Delete folder, wildcard supported
				vm.fso.DeleteFolder(pop()) end-code

code CopyFile 	( "source" "destination" -- ) \ Copies one or more files, Wildcard supported.
				vm.fso.CopyFile(pop(1), pop()) end-code
				/// Panic pops up when error, e.g. target file is read-only.

code DeleteFile ( "pathname" -- ) \ Delete the specified file if it's not read-only, Wildcard supported.
				vm.fso.DeleteFile(pop()) end-code
				/// Panic pops up when error, e.g. target file is read-only.

code MoveFile 	( "source" "destination" -- ) \ Move source file to destination folder, wildCard supported.
				vm.fso.MoveFile(pop(1), pop()) end-code
				/// Panic pops up when error, e.g. target file is read-only.

				<selftest> 
					*** CreateFolder CopyFile MoveFile DeleteFile DeleteFolder ... 
					char selftest.log char temp.log CopyFile
					char selftest.temp CreateFolder drop
					char temp.log char selftest.temp\ MoveFile \ note the '\' is necessary to make it a path.
					char selftest.temp\temp.log	FileExists true = 
					char selftest.temp\temp.log	DeleteFile
					char selftest.temp DeleteFolder \ Yes! even if it's not empty.
					char selftest.temp\temp.log	FileExists false =
					and ==>judge [if] <js> ['CopyFile','DeleteFile','MoveFile',
					'CreateFolder','DeleteFolder'] </jsV> all-pass [then]
				</selftest>

code >path/		( "path?name" == "path/name" ) \ Unify path delimiter 
				push(pop().replace(/\\\\|\\|\//g,"/")) end-code

code >path\ 	( "path?name" == "path\name" ) \ Unify path delimiter 
				push(pop().replace(/\\\\|\\|\//g,"\\")) end-code

code >path\\	( "path?name" == "path\\name" ) \ Unify path delimiter 
				push(pop().replace(/\\\\|\\|\//g,"\\\\")) end-code

				<selftest> 
					*** >path/ >path\ >path\\ changes path delimiter ... 
					js> window.location.toString().slice(8).replace(/#endofinputbox/,"")
					>path/ >path/ >path\ >path\ >path\\ >path\\
					>path/ >path\ >path/ >path\\
					>path\ >path/ >path\ >path\\
					>path\\ >path/ >path\\ >path\
					FileExists 
					==>judge [if] <js> ['GetFileName'] </jsV> all-pass [then]
				</selftest>

code GetFileName ( "path-name" -- "filename" ) \ Get file name portion of the given path-name
				push(vm.fso.GetFileName(pop())); 
				end-code 
				/// This fso method works only on the provided path string. 
				/// It does not attempt to resolve the path, nor does it check for the existence of the specified path.
				/// char sdfs/fs/fs/dfs/df/sdf/sdf/s.abc GetFileName tib. \ ==> s.abc (string)

				<selftest> 
					*** GetFileName is a string operation ... 
					char . full-path \ ==> C:\Users\8304018.WKSCN\Dropbox\learnings\github\jeforth.3we\ (string)
					GetFileName \ ==> jeforth.3we (string)
					js> window.location.toString().replace(/#endofinputbox/,"") \ ==> file:///C:/lalala/jeforth.3we/jeforth.hta (string)
					GetFileName \ ==> jeforth.hta (string)
					char jeforth.hta =
					swap char jeforth.3we =
					and ==>judge [if] <js> ['GetFileName'] </jsV> all-pass [then]
				</selftest>
				
code GetBaseName ( "path-name" -- "base-name" ) \ Get file base name portion of the given path-name
				push(vm.fso.GetBaseName(pop())); 
				end-code 
				/// This fso method works only on the provided path string. 
				/// It does not attempt to resolve the path, nor does it check for the existence of the specified path.
				/// char sdfs/fs/fs/dfs/df/sdf/sdf/s.abc GetBaseName tib. \ ==> s (string)

				<selftest> 
					*** GetBaseName is a string operation ... 
					char . full-path \ ==> C:\Users\8304018.WKSCN\Dropbox\learnings\github\jeforth.3hta\ (string)
					GetBaseName \ ==> jeforth (string)
					js> window.location.toString() \ ==> file:///C:/Users/lalala/jeforth.3hta/jeforth.hta (string)
					GetBaseName \ ==> jeforth (string)
					over = swap char jeforth = \ true true
					and ==>judge [if] <js> ['GetBaseName'] </jsV> all-pass [then]
				</selftest>

code GetExtensionName ( "path-name" -- "ext-name" ) \ Get file extension name portion of the given path-name
				push(vm.fso.GetExtensionName(pop())); 
				end-code 
				/// This fso method works only on the provided path string. 
				/// It does not attempt to resolve the path, nor does it check for the existence of the specified path.
				/// char sdfs/fs/fs/dfs/df/sdf/sdf/s.abc GetExtensionName tib. \ ==> abc (string)

				<selftest> 
					*** GetExtensionName is a string operation ... 
					char . full-path  \ ==> C:\lalala\jeforth.3we\ (string)
					GetExtensionName  \ ==> 3we (string)
					js> window.location.toString().replace(/#endofinputbox/,"")  \ ==> file:///C:/lalala/jeforth.3we/jeforth.hta (string)
					GetExtensionName \ ==> hta (string)
					char hta = swap char 3we = and 
					==>judge [if] <js> ['GetExtensionName'] </jsV> all-pass [then]
				</selftest>

code GetParentFolderName ( "path-name" -- "folder" ) \ Get parent folder name of the given path-name
				push(vm.fso.GetParentFolderName(pop())); 
				end-code 
				/// This fso method works only on the provided path string. 
				/// It does not attempt to resolve the path, nor does it check for the existence of the specified path.
				/// char aa/bb/cc/dd/ee/ff/gg/s.abc GetParentFolderName tib. \ ==> aa/bb/cc/dd/ee/ff/gg (string)
				<selftest> 
					*** GetParentFolderName is a string operation ... 
					char . full-path \ ==> C:\Users\8304018.WKSCN\Dropbox\learnings\github\jeforth.3we\ (string)
					GetParentFolderName \ ==> C:\Users\8304018.WKSCN\Dropbox\learnings\github (string)
					drop \ demo only, 不拿它做判斷
					js> window.location.toString().replace(/#endofinputbox/,"") \ ==> file:///C:/Users/8304018.WKSCN/Dropbox/learnings/github/jeforth.3we/jeforth.hta (string)
					GetParentFolderName \ ==> file:///C:/Users/8304018.WKSCN/Dropbox/learnings/github/jeforth.3we (string)
					GetFileName \ jeforth.3we
					char jeforth.3we = 
					==>judge [if] <js> ['GetParentFolderName','GetAbsolutePathName'] </jsV> all-pass [then]
				</selftest>

code GetAbsolutePathName ( "path-name" -- "path-name" ) \ Get complete and unambiguous path from a provided path specification
				push(vm.fso.GetAbsolutePathName(pop())); end-code
				/// This fso method works only on the provided path string. 
				/// It does not attempt to resolve the path, nor does it check for the existence of the specified path.
				/// char sd//fs/fs\\ddf/s.abc GetAbsolutePathName tib. \ ==> X:\sd\fs\fs\ddf\s.abc (string)

: full-path 	( "short-path" -- "fullpath" ) \ Get full path string of the given short path, w/o error check.
				GetAbsolutePathName char \ + ;

: path+name 	( "short-path" "filename" -- "full-path-name" ) \ Get full pathname
				>r full-path r> + ;
				/// full-path does error check, this word doesn't.

				<selftest> 
					*** full-path reveals what .\ really is ... 
					char . full-path \ ==> C:\Users\8304018.WKSCN\Dropbox\learnings\github\jeforth.3we\ (string)
					char jeforth.hta path+name \ C:\lalala\jeforth.3we\jeforth.hta
					FileExists \ true
					==>judge [if] <js> ['GetAbsolutePathName','full-path','path+name','FileExists'] </jsV> all-pass [then]
				</selftest>

code (dir) 		( "folderspec" -- fileObjs[] ) \ Get file obj list of the given folder
				var filecollection;
				filecollection = new Enumerator(vm.fso.GetFolder(pop()).files);
				for (var files = []; !filecollection.atEnd(); filecollection.moveNext()) 
					files.push(filecollection.item());
				push(files); end-code 
				
				<selftest> 
					*** (dir) gets file object list ... 
					char . (dir) js> mytypeof(pop()) char array = 
					==>judge [if] <js> ['(dir)'] </jsV> all-pass [then]
				</selftest>

: precise-timer ( -- float ) \ Get precise timer value from VBS's Timer global variable.
				<vb> vm.push(Timer)</vb> ;
