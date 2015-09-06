
\ Common Node.js fs module for 3nd, 3nw and more?
\ http://nodejs.org/api/fs.html

s" fs.f"		source-code-header

				<selftest>
				.( ---- Node.js File system object vm.fso ---- ) cr
				.(( vm.fso.statSync(pathname) gets a lot of pathname properties ... )) cr
				char . js> vm.fso.statSync(pop()) dup tib.
				dup :> isDirectory() tib.
				dup :> isFile() tib.
				dup :> isBlockDevice() tib.
				dup :> isCharacterDevice() tib.
				dup :> isSymbolicLink() tib.
				dup :> isFIFO() tib.
				dup :> isSocket() tib.
				dup :> atime tib.
				dup :> ctime tib.
				    :> mtime tib.
				</selftest>

: readdir		( "path" -- array ) \ Read all file names of the dir.
				js> vm.fso.readdirSync(pop()) ;

: exists		( "path" -- boolean ) \  Check if the path or pathname exists
				js> vm.fso.existsSync(pop()) ;
				/// Not only existence but also "operation not permitted" too.

: realpath		( "path" -- "realpath" ) \ Returns the resolved path.
				js> vm.fso.realpathSync(pop()) ;

: (cd)			( "dir" -- ) \ Change directory to "dir", affects process.cwd.
				dup exists if 							( dir )
					js> vm.fso.statSync(tos()).isDirectory()	( dir y/n )
					if js: process.chdir(pop()) exit then						( empty )
				then										( badPath )
				s" Change directory to " swap + s" ?" + "msg"abort ;

: cd			( <dir> -- "cd" ) \ Change directory to <dir>, or show the current directory cd.value.
				CR word ?dup if 	( "dir" )
					(cd)			( empty )
				else				( empty )
					js> process.cwd() .	( empty )
				then ;
				
: [dir] 		( "path" -- [{path:pathname,type:integer}..] ) \ Get array of the directory.
				dup readdir <js> 
					var dir=pop(), path=vm.fso.realpathSync(pop())+'/', result=[];
					for(var i in dir) {
						var pathname = vm.fso.realpathSync(path + dir[i]);
						if(!vm.fso.existsSync(pathname)) continue;
						if(vm.fso.statSync(pathname).isDirectory()){
							result.push({path:pathname,type:1});
						}else{
							result.push({path:pathname,type:0});
						}
					};
					result
				</jsV> ;
				
: (dir) 		( "path" -- ) \ List everything in the directory.
				decimal ." Directory of " dup . cr dup
				readdir <js> 
					var dir=pop(), path=pop()+'/';
					if (path==process.cwd()) path="";
					for(var i in dir) {
						if(!vm.fso.existsSync(path+'/'+dir[i])) continue;
						// s += vm.fso.statSync(path+'/'+dir[i]).mtime + " "; 
						push(vm.fso.statSync(path+'/'+dir[i]).mtime);
						execute('t.dateTime');
						push(vm.fso.statSync(path+'/'+dir[i]).size);
						fortheval("13 .r");
						if(vm.fso.statSync(path+'/'+dir[i]).isDirectory()){
							print(' [' + dir[i] + ']\n');
						}else{
							print(' ' + dir[i] + '\n');
						}
					}
				</js> ;

: dir			( [<dir>] -- ) \ List everything in the directory.
				CR word ?dup if else js> process.cwd() then (dir) ;

code allFiles	( array "path" -- array ) \ Rescan the working dir 
				(function recursion () {
					execute("[dir]");
					var a = pop();
					for ( var i in a ) {
						if (a[i].type){
							push(a[i].path);
							recursion();
						} else {
							tos().push(a[i].path);
						}
					}
				})()
				end-code
				\ Use arguments.callee() instead of giving a name like recursion is ok too.
				\ http://stackoverflow.com/questions/7065120/calling-a-javascript-function-recursively

code findFile	( 'pathname' -- "pathname" ) \ Find a file under the working dir that matches "pathname".
				fortheval(">path\\ [] char . allFiles"); var a = pop(), pathname=pop(), result=pathname;
				for(var i in a) {
					var p = a[i].lastIndexOf(pathname);
					if(p != -1 && (p+pathname.length) == a[i].length ){
						result = a[i];
						break;
					}
				}
				push(result);
				end-code
				/// if not found return the original pathname that may not be in working dir.

				<selftest>
					**** Should not leave anything in the data stack . . . 
					depth not ==>judge drop
				</selftest>
