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
				\ SendKey() 很難搞，下面範例指出了很多要點，值得參考。
				*** WshShell launch Calculator and SendKeys() to it
					<vb> WshShell.Run "calc" </vb> 5000 sleep \ 有時候 run 不起來，改 5 秒試試。
					<vb> kvm.push(WshShell.AppActivate("Calculator"))</vb> 1 sleep \ ( boolean )
					\ Windows 10 的行為怪異 AppActivate() 看切到誰，返回值不一定，幸好...
					drop \ ... 都會成功，乾脆不看結果了。
					\ 想像 SendKeys() 有很長的【前後置】delay 時間, 會發生甚麼事? 只要 activated 是 Calculator
					\ 前置時間就沒問題。觀察到有時候 SendKeys 是誤下給 3hta 何故? Active 無故回到 3hta 可能性較低，
					\ 應該是 AppActivate() 沒成功。照這樣想,一定要做 error check。既然 AppActivate() 有傳回
					\ 值,隨後的 sleep 理當沒必要。SendKeys() 之後的 sleep 有意義。要確保 activated 是 Calculator 
					\ 直到 SendKeys() 全部倒完。
					\ 所以原則是：凡有 SendKeys() 就要考慮最後的【後置時間】，讓它徹底完成工作。
					\             預防 focus 半途被切走而把 key 送錯給別人。
					true [if]
						<vb> WshShell.SendKeys "12345" </vb> 1 sleep
						\ 以下離手前必須 sleep，我看過一半下在這裡一半下給 3hta 的情形!
						<vb> WshShell.SendKeys "%{F4}" </vb> 1000 sleep 
						\ 因為 Alt-F4 的特殊性，其後 Alt key 的 keyUp 沒人收，會咬住。
						\ 此時應該 active 回 3hta，要確定它 focus 在 inputbox，要適時
						\ 多按一下 Alt{HOME} (賭它沒用到) 把 Alt 放掉。
						js: inputbox.focus() 100 sleep \ 我覺得 DOM 要花點時間
						<vb> WshShell.SendKeys "%{HOME}" </vb> \ 目的是把 Alt 放掉,不必 sleep。
						true
					[else]
						false
					[then]
					[d true d] [p "ActiveXObject","WshShell" p]

				*** Manipulate clipboard
					js: vm.selftest_visible=false
					\ SAVE-restore. Clipboard can be null, so be careful. 
					js> clipboardData.getData("text") ?dup not [if] "" [then] 
					<js> clipboardData.setData("text","6 6 *") </js> ( 36 )
					<vb> WshShell.SendKeys "^v{enter}" </vb> 500 sleep \ 必須有 sleep 先讓它完成工作再 restore 舊 clipboard 否則會全部攪再一起。
					js: clipboardData.setData("text",pop(1))  \ save-RESTORE
					js: vm.selftest_visible=true
					[d 36 d] [p 'ActiveXObject','WshShell' p]

					\ 改用 clipboard 成功，若用 SendKeys() 遇上中文輸入模式費解。以下留作紀念。
					\   js: document.body.style.imeMode='disabled'; \ [x] 懸案，想要避免中文輸入法干擾，無效！
					\   <vb> WshShell.SendKeys "1{+}" </vb> 100 sleep \ Pad plus
					\   js: document.body.style.imeMode='auto'; 

				</selftest>
				
: activate		( ProcessID|"^title" -- ) \ Activate an application
				WshShell :: AppActivate(pop()) ;
				/// "title" is the leading 3 or more characters, case don't care.
				
: sendkeys		( "keys" -- ) \ Send keys to the recent activated application
				[ last literal ] :> wait ( -- "keys" wait ) 
				WshShell :: sendkeys(pop(1),pop()) ; last :: wait=true
				/// Note! WshShell.SendKeys 對 administrator mode 時的 process 無效。
				/// ----- ' sendkeys :> wait -----
				/// False: Continue running without waiting for the keys to be processed.
				///        可以一邊手動切 app 一邊看到 key buffer dump 過來 dump 過去。
				/// True : (default) Wait for the keys to be processed before returning. 
				///        實驗結果：一開始倒就無法切換。
				/// 
				/// ----- Usage Tip -----
				/// This method places keystrokes in a key buffer. In some cases, you must call this 
				/// method before you call the method that will use the keystrokes. For example, to 
				/// send a password to a dialog box, you must call the SendKeys method before you 
				/// display the dialog box. 
				/// 注意！JavaScript 把控制權交出去之前，這些 key 都在 buffer 裡。故應該先 sendkeys 
				/// 切往 target application 然後 nap 一會兒讓 target application 工作。
				/// 
				/// ----- Special keys -----
				/// +Shift ^Ctrl %Alt {BACKSPACE}or{BS},{BREAK},{CAPSLOCK},{CLEAR},{DELETE} or {DEL},
				/// {DOWN},{END},{ENTER},{ESCAPE} or {ESC},{F1}{F15},{HELP},{HOME},{INSERT},{LEFT},
				/// {NUMLOCK},{PGDN},{PGUP},{RETURN},{RIGHT},{SCROLLLOCK},{TAB},{UP},~(Enter)
				///
				/// ----- Example -----
				/// 先弄出個很大的 string :
				/// <js> var ss="112233"; for(var i=0; i<10000; i++) ss += "ab"; ss += "<end>"</jsV> value ss
				/// Notepad 先跑起來。做下面實驗：
				/// > char untitled ( notepad ) activate 1 nap ss sendkeys 10000 nap
				/// 其中 1 nap 讓 notepad 上手必要， 10000 nap 時間不足以讓 keys 倒完，結果前半段倒往 notepad 後半段倒往 jeforth.3hta 的 inputbox,不論 wait 是 true/false 都一樣,因為實驗做完 jeforth 有下 focus 奪回關注。
				
				
: (run)			( "command-line" -- errorlevel ) \ Run anything like Win-R does and wait for the return.
				<js> WshShell.run(pop(),5,true) </jsV> ;
				/// See also run, (run), fork, (fork), dos, (dos).
				/// Use run or dos if want the return value. 

: run			( <command-line> -- errorlevel ) \ Run anything like Win-R does and wait for the return.
				char \n|\r word (run) ; interpret-only 
				\ The first match of either \r or \n terminates the command line. This is important
				\ otherwise the extra \n may pollute the command line.
				/// See also run, (run), fork, (fork), dos, (dos).
				/// Use run or dos if want the return value. 

				<selftest> 
					\ 這是個簡單明了的範例。
					\ jeforth.3hta 可以靠傳回 TOS 層層套疊協力工作。
					
					*** run anything and get errlevel, includes DOS command-lines
					run jeforth.hta 112233 bye 
					( 112233 )
					( 1 not found ) run cmd /c dir | find "lalilale"    
					( 0 found     ) run cmd /c dir | find "jeforth.hta" 
					[d 112233,1,0 d] [p '(run)','run' p]
				</selftest>

: (fork)		( "command-line" -- ) \ Fork anything like Win-R does, fire and forget, no return value.
				<js> WshShell.run(pop(),5,false) </js> ;
				/// No return value, because the caller doesn't wait.
				/// See also run, (run), fork, (fork), dos, (dos).
				/// Use run or dos if want the return value. 

: fork			( <command-line> -- ) \ Fork anything like Win-R does, fire and forget, no return value.
				char \n|\r word (fork) ;
				/// No return value, because the caller doesn't wait.
				\ The first match of either \r or \n terminates the command line. This is important
				\ otherwise the extra \n may pollute the command line.
				/// See also run, (run), fork, (fork), dos, (dos).
				/// Use run or dos if want the return value. 
				/// Ex. fork chrome --allow-file-access-from-files

: (dos) 		( "command-line" -- errorlevel ) \ Run DOS command-line and stay there. Errorlevel will return.
				s" cmd /c " swap + (run) ;
				/// See also run, (run), fork, (fork), dos, (dos).
				/// Use run or dos if want the return value. 

: dos			( <command-line> -- errorlevel ) \ Run DOS command-line and stay there. Errorlevel will return.
				char \n|\r word s" cmd /k " swap + (run) ;
				\ The first match of either \r or \n terminates the command line. This is important
				\ otherwise the extra \n may pollute the command line.
				/// See also run, (run), fork, (fork), dos, (dos).
				/// Use run or dos if want the return value. 

				<selftest> 
					\ 以下這個測試示範看得人眼花撩亂，但不要低估它。
					\ jeforth.3hta 能夠這樣玩弄 DOS 等於是大大地增強了 DOS 的能力。
					
					*** fork append time stamp into selftest.log ... 
					s" fork and dos test " js> Date().toString() + \ ( pattern )
					s" fork cmd /c echo " over + s" >> selftest.log
					" + tib.insert 
					s' dos find "' swap + s' " selftest.log & exit
					' + tib.insert
					[d 0 d] [p 'dos','(dos)','fork','(fork)' p]
				</selftest>

: FileExists 	( "path-name" -- boolean ) \ Check file object existance, no wildcard.
				js> vm.fso.FileExists(pop()) ; 

code GetFile ( "path-name" -- objFile|false ) \ Get file object, no wildcard.
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
					*** GetFile gets file object
					char . full-path char jeforth.hta path+name
					char jeforth.hta GetFile js> pop().Path
					= [d true d] [p 'full-path','GetFile' p]
				</selftest>

code GetFolder ( "path" -- objFolder|false ) \ Get folder object, no wildcard.
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
					*** GetFolder gets folder object
					char . full-path 
					char . GetFolder js> pop().Path char \ +
					= [d true d] [p 'GetFolder' p]
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
					*** CreateFolder CopyFile MoveFile DeleteFile DeleteFolder
					char selftest.log char temp.log CopyFile
					char selftest.temp CreateFolder drop
					char temp.log char selftest.temp\ MoveFile \ note the '\' is necessary to make it a path.
					char selftest.temp\temp.log	FileExists ( true )
					char selftest.temp\temp.log	DeleteFile
					char selftest.temp DeleteFolder \ Yes! even if it's not empty.
					char selftest.temp\temp.log	FileExists ( false )
					[d true,false d] [p 'CopyFile','DeleteFile','MoveFile','CreateFolder','DeleteFolder' p]
				</selftest>

code >path/		( "path?name" == "path/name" ) \ Unify path delimiter 
				push(pop().replace(/\\\\|\\|\//g,"/")) end-code

code >path\ 	( "path?name" == "path\name" ) \ Unify path delimiter 
				push(pop().replace(/\\\\|\\|\//g,"\\")) end-code

code >path\\	( "path?name" == "path\\name" ) \ Unify path delimiter 
				push(pop().replace(/\\\\|\\|\//g,"\\\\")) end-code

				<selftest> 
					*** >path/ >path\ >path\\ changes path delimiter
					js> window.location.toString().slice(8).replace(/#endofinputbox/,"")
					>path/ >path/ >path\ >path\ >path\\ >path\\
					>path/ >path\ >path/ >path\\
					>path\ >path/ >path\ >path\\
					>path\\ >path/ >path\\ >path\
					FileExists 
					[d true d] [p 'GetFileName' p]
				</selftest>

code GetFileName ( "path-name" -- "filename" ) \ Get file name portion of the given path-name
				push(vm.fso.GetFileName(pop())); 
				end-code 
				/// This fso method works only on the provided path string. 
				/// It does not attempt to resolve the path, nor does it check for the existence of the specified path.
				/// char sdfs/fs/fs/dfs/df/sdf/sdf/s.abc GetFileName tib. \ ==> s.abc (string)

				<selftest> 
					*** GetFileName is a string operation
					char . full-path \ ==> C:\Users\8304018.WKSCN\Dropbox\learnings\github\jeforth.3we\ (string)
					GetFileName ( jeforth.3we (string) )
					js> window.location.toString().replace(/#endofinputbox/,"") \ ==> file:///C:/lalala/jeforth.3we/jeforth.hta (string)
					GetFileName ( jeforth.hta (string) )
					[d "jeforth.3we","jeforth.hta" d] [p 'GetFileName' p]
				</selftest>
				
code GetBaseName ( "path-name" -- "base-name" ) \ Get file base name portion of the given path-name
				push(vm.fso.GetBaseName(pop())); 
				end-code 
				/// This fso method works only on the provided path string. 
				/// It does not attempt to resolve the path, nor does it check for the existence of the specified path.
				/// char sdfs/fs/fs/dfs/df/sdf/sdf/s.abc GetBaseName tib. \ ==> s (string)

				<selftest> 
					*** GetBaseName is a string operation
					char . full-path \ ==> C:\Users\8304018.WKSCN\Dropbox\learnings\github\jeforth.3hta\ (string)
					GetBaseName \ ==> jeforth (string)
					js> window.location.toString() \ ==> file:///C:/Users/lalala/jeforth.3hta/jeforth.hta (string)
					GetBaseName \ ==> jeforth (string)
					[d "jeforth","jeforth" d] [p 'GetBaseName' p]
				</selftest>

code GetExtensionName ( "path-name" -- "ext-name" ) \ Get file extension name portion of the given path-name
				push(vm.fso.GetExtensionName(pop())); 
				end-code 
				/// This fso method works only on the provided path string. 
				/// It does not attempt to resolve the path, nor does it check for the existence of the specified path.
				/// char sdfs/fs/fs/dfs/df/sdf/sdf/s.abc GetExtensionName tib. \ ==> abc (string)

				<selftest> 
					*** GetExtensionName is a string operation
					char . full-path  \ ==> C:\lalala\jeforth.3we\ (string)
					GetExtensionName  \ ==> 3we (string)
					js> window.location.toString().replace(/#endofinputbox/,"")  \ ==> file:///C:/lalala/jeforth.3we/jeforth.hta (string)
					GetExtensionName \ ==> hta (string)
					[d "3we","hta" d] [p 'GetExtensionName' p]
				</selftest>

code GetParentFolderName ( "path-name" -- "folder" ) \ Get parent folder name of the given path-name
				push(vm.fso.GetParentFolderName(pop())); 
				end-code 
				/// This fso method works only on the provided path string. 
				/// It does not attempt to resolve the path, nor does it check for the existence of the specified path.
				/// char aa/bb/cc/dd/ee/ff/gg/s.abc GetParentFolderName tib. \ ==> aa/bb/cc/dd/ee/ff/gg (string)
				<selftest> 
					*** GetParentFolderName is a string operation
					s" file:///C:/Users/8304018.WKSCN/Dropbox/learnings/github/jeforth.3we/jeforth.hta"
					GetParentFolderName \ ==> file:///C:/Users/8304018.WKSCN/Dropbox/learnings/github/jeforth.3we (string)
					dup GetFileName \ jeforth.3we
					[d 
						"file:///C:/Users/8304018.WKSCN/Dropbox/learnings/github/jeforth.3we",
						"jeforth.3we" 
					d] [p 'GetParentFolderName' p]
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
					*** full-path reveals what .\ really is
					char . full-path \ ==> C:\Users\8304018.WKSCN\Dropbox\learnings\github\jeforth.3we\ (string)
					char jeforth.hta path+name \ C:\lalala\jeforth.3we\jeforth.hta
					FileExists \ true
					[d true d] [p 'GetAbsolutePathName','full-path','path+name','FileExists' p]
				</selftest>

code (dir) 		( "folderspec" -- fileObjs[] ) \ Get file obj list of the given folder
				var filecollection;
				filecollection = new Enumerator(vm.fso.GetFolder(pop()).files);
				for (var files = []; !filecollection.atEnd(); filecollection.moveNext()) 
					files.push(filecollection.item());
				push(files); end-code 
				
				<selftest> 
					*** (dir) gets file object list
					char . (dir) js> mytypeof(pop())
					[d "array" d] [p '(dir)' p]
				</selftest>

: precise-timer ( -- float ) \ Get precise timer value from VBS's Timer global variable.
				<vb> vm.push(Timer)</vb> ;

: super_chrome ( -- ) \ Run Chrome by fork chrome --allow-file-access-from-files
				10 for s" where name like 'chrom.exe'" count-process if
					s" where name like 'chrom.exe'" kill-them
				then 500 nap next \ 好像一次殺不乾淨?
				s" chrome --allow-file-access-from-files" (fork) ;
