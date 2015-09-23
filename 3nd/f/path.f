
\ Node.js Path module utilizations
\ http://nodejs.org/docs/latest/api/path.html

s" path.f"		source-code-header

js> require('path') constant path // ( -- obj ) Node.js Path module

				<selftest>
					.( ----- Node.js path module ----- ) cr
					*** See goodies in the Node.js path object as shown above?
						js: vm.screenbuffer=""
						path obj>keys tib.
						<js> vm.screenbuffer.indexOf('resolve,normalize')!=-1 </jsV> ( true )
						[d true d] [p "path" p]
					*** Can we guess the usage of a method throuth viewing it's definition as shown above?
						js: vm.screenbuffer=""
						path :> _makeLong tib.
						path :> sep tib.
						path :> delimiter tib.
						s" x:/foo/bar/.." path :> normalize(pop()) tib.
						<js> vm.screenbuffer.indexOf('==> x:\\foo (string)')!=-1 </jsV> ( true )
						[d true d] [p p]
				</selftest>

: normalize		( 'path' -- "path" ) \ d:\foo\bar\.. => d:\foo
				path :> normalize(pop()) ;
				/// The input doesn't need to be a real path.
				/// . ==> .
				/// ../.. ==> ..\..

: join			( 'pathA' 'pathB' -- "pathA+B" ) \ Join pathnames together
				path :> join(pop(1),pop()) ;
				/// The input doesn't need to be a real path.
				/// separator can be / \ or //, result will be \ in Windows.
				/// The result will be normalized.
				
: dirname		( 'pathname' -- 'path' ) \ d:\foo\bar\file.txt ==> d:\foo\bar
				path :> dirname(pop()) ;
				/// The input doesn't need to be a real path.
				
: basename		( 'pathname' ""|'.ext' -- 'basename' ) \ d:\foo\bar\file.txt ==> 'file.txt' or 'file'
				path :> basename(pop(1),pop()) ;
				/// The input doesn't need to be a real path.
				
: extname		( 'pathname' -- 'extname' ) \ d:\file.txt ==> .txt, d:\file. ==> ., d:\file ==> ""
				path :> extname(pop()) ;
				/// The input doesn't need to be a real path.

				<selftest>
					*** normalize the given string, it doesn't need to be a real path
						js: vm.screenbuffer=""
						( 前後 whitespace 都照抄 ) s"    a//./b\\..\c.e   " normalize tib.
						<js> vm.screenbuffer.indexOf('==>    a\\c.e    (string)')!=-1 </jsV> ( true )
						s" file:///C:/Users/8304018/Dropbox/learnings/github/jeforth.3we/jeforth.3nw.html" normalize tib.
						<js> vm.screenbuffer.indexOf('file:\\C:\\Users\\8304018\\Dropbox')!=-1 </jsV> ( true )
						s" file:///a\\b" s" //c//d.e" join tib.
						<js> vm.screenbuffer.indexOf('file:\\a\\b\\c\\d.e')!=-1 </jsV> ( true )
						s" a\\b" s" //c//d.e" join dirname tib.
						<js> vm.screenbuffer.indexOf('a\\b\\c (string)')!=-1 </jsV> ( true )
						s" a\\b" s" //c//d.e" join "" basename tib.
						<js> vm.screenbuffer.indexOf('==> d.e (string)')!=-1 </jsV> ( true )
						s" a\\b" s" //c//d.e" join extname tib.
						<js> vm.screenbuffer.indexOf('==> .e (string)')!=-1 </jsV> ( true )
						[d true,true,true,true,true,true d] 
						[p "normalize","join","dirname","basename","extname" p]
				</selftest>

code >path/		( "path?name" == "path/name" ) \ Unify path delimiter 
				push(pop().replace(/\\\\|\\|\//g,"/")) end-code
				/// path delimiter 用 '/' 還是用 '\' 要視給誰用而定。Excel 2010 
				/// 的 save-as 要的是 Microsoft 的 \ 而且不能用 \\ 也不能用 /， Excel 
				/// 2003 可以接受用 / 或 \\，而 GetObject() 要的是 \\ 而且不能用 \。
				/// 靠！這真是混亂。所以只好準備 >path/ >path\ >path\\ 來適應各種情況。

code >path\ 	( "path?name" == "path\name" ) \ Unify path delimiter 
				push(pop().replace(/\\\\|\\|\//g,"\\")) end-code
				last :: comment=tick('>path/').comment

code >path\\	( "path?name" == "path\\name" ) \ Unify path delimiter 
				push(pop().replace(/\\\\|\\|\//g,"\\\\")) end-code
				last :: comment=tick('>path/').comment

				<selftest>
					*** Should not leave anything in the data stack
					[d d] [p p]
				</selftest>
