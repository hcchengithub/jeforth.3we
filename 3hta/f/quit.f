
\ quit.f for jeforth.3hta
\
\ QUIT is the traditional forth system's CLI loop. jeforth.f kernel is common for all
\ applications. quit.f is the good place to define propritary features of each application.
\  

: ado			( -- ) \ Switch (read/write)TextFile to use ADODB.Stream.
				js: vm.writeTextFile=writeTextFile_ado;vm.readTextFile=readTextFile_ado ;
				/// Windows XP 以及部分 Windows 7 上會有這個問題：
				/// "Safety Settings on this computer prohibit accessing a data source on another domain"
				/// https://www.evernote.com/shard/s22/nl/2472143/db532ac2-04d1-4618-9fc9-e81dc3ed1d0a
				/// 改用 fso 可部分改善。
				
: fso			( -- ) \ Switch (read/write)TextFile to use Scripting.FileSystemObject.
				js: vm.writeTextFile=writeTextFile_fso;vm.readTextFile=readTextFile_fso ;
				/// 用 fso 可部分改善 Windows XP 以及部分 Windows 7 上這個問題：
				/// "Safety Settings on this computer prohibit accessing a data source on another domain"
				/// https://www.evernote.com/shard/s22/nl/2472143/db532ac2-04d1-4618-9fc9-e81dc3ed1d0a
				/// 但是不能用中文 word. git.f(utf-8) 有用到結果 include 半路就會出錯。升級到 Windows 8 
				/// 以上是最好的辦法。

: ado-or-fso?	( -- 'ado'|'fso' ) \ See what's the recent file read/write method, ado or fso.
				js> vm.writeTextFile==writeTextFile_ado if 1 else 0 then 
				js> vm.readTextFile==readTextFile_ado   if 1 else 0 then 1 << +
				js> vm.writeTextFile==writeTextFile_fso if 1 else 0 then 2 << +
				js> vm.readTextFile==readTextFile_fso   if 1 else 0 then 3 << +
				<js> switch(pop()){
					case  3: push('ado'); break;
					case 12: push('fso'); break;
					default: dictate('fso abort" Fatal error! Was none ADO nor FSO, very strange!! Now force to FSO."');
				} </js> ;
				/// fso is older method. Better Windows XP and Windows 7 compatible but can't access utf-8 files.
				/// ado is newer method and is prefereed. But has compatible issues on older Windows. 
				
: cr         	( -- ) \ 到下一列繼續輸出 *** 20111224 sam
				js: type("\n") 1 nap js: vm.scroll2inputbox();inputbox.focus() ;
				/// redefined in quit.f, 1 nap 使輸出流暢。
				/// Focus the display around the inputbox.
				\ 早一點 redefine 以便流暢 include 諸 ~.f 時的 selftest messages.

\ ------------------ Self-test of the jeforth.f kernel --------------------------------------
	\ Do the jeforth.f self-test only when there's no command line. How to see command line is
	\ application dependent. 
	\
	js> vm.argv.length 1 > \ Do we have jobs from command line?
	[if] \ We have jobs from command line to do. Disable self-test.
		js: tick('<selftest>').enabled=false
	[else] \ We don't have jobs from command line to do. So we do the self-test.
		js> tick('<selftest>').enabled=true;tick('<selftest>').buffer tib.insert
	[then] js: tick('<selftest>').buffer="" \ recycle the memory
	
	fso \ In case your OS is Windows XP or Windows 7 with a bad luck.
	include jsc.f		\ JavaScript debug console in 3htm/f
	include voc.f		\ voc.f is basic of forth language
	include vb.f		\ Being able to run VBS is what HTA is for.
	include wmi.f
	
	\ 查看是否 Windows 8 以上？決定要不要改用 ado, utf-8 才會正常。
	objEnumWin32_OperatingSystem :> item().Version float 6.2 >= ( Windows 8 )
	[if] ado [then] 
	\ 若非 Windows 8 以上則續用 fso 就得避免用到中文 word 名。
	\ Windows 7  :  6.1.7601
	\ Windows 8  :  6.2.9200
	\ Windows 10 : 10.0.10240
						
	include html5.f		\ HTML5 is HTA's plateform feature
	include jquery.f    \ Avoid Windows XP, Windows 7 HTA problems from happening immediately
	include element.f	\ HTML element manipulation
	include platform.f 	\ Hotkey handlers and platform features
	include wsh.f		\ Windows Shell Host
	include env.f 		\ Windows environment variables
	include beep.f		\ Define the beep command
	include binary.f	\ Read/Write binary file
	include shell.application.f
  \ include excel.f		\ 有用到時再自行 include 好處多
	include canvas.f
	include mytools.f
	
	: stamp ( -- ) \ Paste date-time at cursor position
			js> clipboardData.getData("text")  ( saved ) \ SAVE-restore
			now t.dateTime ( saved "date time" )
			js: clipboardData.setData("text",pop()) ( saved )
			<vb> WshShell.SendKeys "^v" </vb> 
			500 sleep js: clipboardData.setData("text",pop()) ( empty ) \ save-RESTORE
			;
			/// It works now 2016-05-16 18:11:03. Leave 'stamp' in inputbox then put cursor
			/// at target position, press Ctrl-Enter, then that's it! Date-time pasted to
			/// the target position. Only supported in 3hta so far.
	
	include hte.f
	include ls.f
	marker ---

\ ------------ End of jeforth.f -------------------
	js: vm.screenbuffer=null \ turn off the logging
	.(  OK ) \ The first prompt after system start up.
	js: vm.scroll2inputbox();inputbox.focus()

\ ----------------- run the command line -------------------------------------
	<js> (vm.argv.slice(1)).join(" ") </jsV> tib.insert \ skip first cell which is the *.hta pathname itself.

\ The End



