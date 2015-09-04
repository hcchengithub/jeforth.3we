
.( Including voc.f ) cr

marker --voc.f-- 

char forth constant forth-wordlist // ( -- "forth" ) The vid of forth-wordlist.

				<selftest>
					marker --voc.f-self-test--
				</selftest>

code isMember 	( value group -- key|index T|F ) \ Return key or index if value exists.
				var group = pop();
				var result = vm.g.isMember(pop(), group);
				if (result.flag) {push(result.key); push(true)}
				else push(false);
				end-code
				/// 'item' can be number, string, or object, anything that can be compared by the == operator.
				/// 'group' is either array or object.

				<selftest>
					*** isMember checks array or object
					char name     ' code isMember [if] char code = [then] \ true
					char selftest ' code isMember [if] char pass = [then] \ true true
					' help js> words.forth isMember [if] js> words.forth[pop()].name=='help' [then] \ true true true
					[d true,true,true d] [p "isMember" p]
				</selftest>

code get-context ( -- "vid" ) \ Get the word list that is searched first. 
				push(order[Math.max(0,order.length-1)]) end-code
				/// context is order[last], order[0] is always "forth".

: set-context	 ( "vid" -- ) \ Set the word list that is searched first.
				 js: order[Math.max(1,order.length-1)]=pop() rescan-word-hash ;
				 /// context is order[last], order[0] is protected to always be "forth".

				<selftest>
					*** set-context get-context manipulate the word-list of first priority
					also forth vocabulary vvv char vvv set-context
					get-context char vvv = \ true
					[d true d] [p 'get-context' p]
				</selftest>

code get-current ( -- "vid" ) \ Return vid, new word's destination word list name.
				push(current) end-code

code set-current ( "vid" -- ) \ Set the new word's destination word list name.
				current = pop() end-code

				<selftest>
					*** set-current get-current manipulate the word-list to go to
					also vocabulary vvv000 vvv000 definitions
					also char vvv set-current
					get-current char vvv = \ true
					forth definitions \ change current to forth
					get-current char forth = \ true true
					vvv definitions \ change current to vvv
					get-current char vvv = \ true true true
					: ttt ; js> words.vvv[words.vvv.length-1].name=='ttt' \ true true true true 
					previous \ use the previous word-list as the context
					get-context char vvv000 = \ true true true true true
					[d true,true, true, true, true d] 
					[p 'get-current','forth','(vocabulary)','vocabulary',
					   'definitions','previous','forth-wordlist' p]
				</selftest>

: (vocabulary) 	( "name" -- ) \ create a new word list.
				>r <js> var name=rtos(),flag=false; for(var vid in words) if(vid==name) {flag=true;break};flag </jsV> 
				if s" Error! redefine vocabulary '" r@ + s" ' is not allowed." + "msg"abort then
				r> (create) reveal colon-word js> last().name dup 
				0 , \ dummy cfa, we need to do this because "(create)" doesn't drop the doVar like "create" does.
				, \ pfa is the "name"
				dup js: words[pop()]=[];words[pop()].push(0) ( empty ) \ words[][0] = 0 是源自 jeforth.WSH 的設計。
				<js> 
					last().type='colon-vocabulary';
					last().help = "( -- ) I am a vocabulary. I switch word-list.";
				</js>
				immediate \ 要在 colon definition 裡切換 word-list 所以是 immediate。 
				does> r> @ set-context rescan-word-hash ;
				
: vocabulary	( <name> -- ) \ create a new word list.
				BL word (vocabulary) ;
				
: only       	( -- ) \ Clear vocabulary search order[] list, leave order[0] = forth-wordlist only.
				js: order=order.slice(0,1) rescan-word-hash ;

				<selftest>
					\ search: forth,vvv,vvv000
					\ define: vvv
					*** only leaves 'forth' along ... 
					get-context char forth = \ false
					only
					get-context char forth = \ true
					[d false,true d] [p "only" p]
				</selftest>

code also       order.push(order[order.length-1]) end-code // ( -- ) vocabulary array's dup

code previous   if(order.length>1){order.pop();dictate("rescan-word-hash")} end-code // ( -- ) Drop vocabulary order[] array's TOS

: forth 		( -- ) \ Make forth-wordlist be searched first, which is to set context="forth".
				js> order.length>1 if forth-wordlist set-context then ; immediate
				/// order[0] is always 'forth'.
' get-current alias current // ( -- "vid" ) current is alias of get-current, get the compilation word list's vid name.

\ 如果照 ANS 標準，get-order 應該如下定義。但是 jeforth 有 JavaScript 當靠山，TOS 可以直接操作 array，實在無需如此委屈。
\ code get-order  ( -- vidn ... vid1 n ) \ Get the order[] list with order.length at TOS
\ 				for(var i=0; i<order.length; i++) push(order[i]);
\ 				push(order.length);
\ 				end-code
\ : order 		( -- ) \ list vocabulary array search order.
\ 				get-order ( -- vidn ... vid1 n ) ." search: " for r@ 1- roll . space next cr
\ 				get-current ( -- vid ) ." define: " . cr ;

code get-order  ( -- order-array ) \ Get the vocabulary order array
				push(order);
				end-code

: order 		( -- ) \ list vocabulary array search order.
				." search: " get-order . cr
				." define: " get-current ( -- vid ) . cr ;
				
: definitions 	get-context set-current ; // ( -- ) make current equals to context. current = order[order.length-1].

: get-vocs		js> words obj>keys ; // ( -- vocs[] ) Get all vocabulary names.

: vocs       	." vocs: " get-vocs . cr ; // ( -- ) List all vocabulary names.

				<selftest>
					\ search: forth
					\ define: vvv
					*** also current order vocs
					js: vm.selftest_visible=false
					also vvv
					js: kvm.screenbuffer=kvm.screenbuffer?kvm.screenbuffer:""; \ enable kvm.screenbuffer, it stops working if is null.
					js> kvm.screenbuffer.length constant start-here // ( -- n ) 
					cr only forth also vvv also vvv000 definitions current char vvv000 = \ true
					order 
					start-here <js> kvm.screenbuffer.slice(pop()).indexOf("search: forth,vvv,vvv000")!=-1 </jsV> \ true true
					start-here <js> kvm.screenbuffer.slice(pop()).indexOf("define: vvv000")!=-1 </jsV> \ true true true
					vocs
					js: vm.selftest_visible=true
					start-here <js> kvm.screenbuffer.slice(pop()).indexOf("vocs: forth,vvv,vvv000")!=-1 </jsV> \ true true true true
					[d true,true,true,true d] [p 'current','definitions','order','vocs',
					'get-current','get-order','get-vocs','forth' p]
				</selftest>

: find-vocs     ( "vid" -- index T|F ) \ Is the given "vid" in the vocs?
				get-vocs isMember ;
				/// this is an example of how to access vocs list.

				<selftest>
					*** find-vocs is a demo of accessing vocs list
					char vvv find-vocs swap 1 = and \ true 
					char vvv000 find-vocs swap 2 = and \ true true
					[d true,true d] [p "find-vocs" p]
				</selftest>
				
code search-wordlist ( "name" "vid" -- wordObject|F ) \ A.16.6.1.2192 Linear search from the given word-list.
                var vid = pop();
				var name = pop();
				for (var i=words[vid].length-1; i>0; i--) if(words[vid][i].name == name) break;
				push(i?words[vid][i]:false);
				end-code
				/// jeforth.3nw has wordhash which is much more powerful. 
				/// So we don't use search-wordlist at all. 

				<selftest>
					*** search-wordlist linear search a word-list
					char code char forth search-wordlist js> pop().name=='code' \ true
					[d true d] [p "search-wordlist" p]
				</selftest>

: forget		( <name> -- ) \ Forget the current vocabulary from <name>
				BL word dup (') js> tos().vid js> current = if ( -- name Word )
					js> words[current].length-pop().wid for (forget) next
				else
					drop ." Oooops! '" . ." ' not found in the current vocabulary, "
					current . char . . cr
				then ;

\ marker 十分複雜。
\ 引進 vocabulary 之後，marker 要改寫。請想想: 'here' 只有一個，當 here 退回到某處，在此之後的所有 words 都要丟
\ 掉，不管它屬哪個 word list. 執行一個 vocabulary words 切入之前就存在的 marker 會怎樣？會把 forth-wordlist 倒
\ 回去、here 也倒回去，恢復 current = context = "forth"; 這是原始 marker 要補做的動作。 

code (marker)   ( "name" -- ) \ Create a word named <name>. Run <name> to forget itself and all newers.
				// -------------------- the saving part 1/2 ----------------------------------
				// we need to do this before creating the marker new word
                var lengthwas = {}; // each word-list's length was
				for (var vid in words) lengthwas[vid] = words[vid].length; // go through all word lists to save their length
				// ---------------- Create the marker new word --------------------------
				execute("(create)");execute("reveal");
				// -------------------- the saving part 2/2 ----------------------------------
				var orderwas = []; // FigTaiwan 爽哥提醒
 				for(var i=0; i<order.length; i++) orderwas[i] = order[i]; // FigTaiwan 爽哥提醒. Marker 也得 restore order[] 跟 vocs[].
				last().type='marker'
                last().herewas = here;
                last().lengthwas = lengthwas; // dynamic variable array 的 reference 給了別人之後就不會蒸發掉了。
				
				push(nexttoken('\n|\r')); // rest of the first line
				execute("parse-help"); // ( "helpmsg" "rests" )
				tib = pop() + " " + tib.slice(ntib); ntib = 0; // "rests" + tib(ntib)
				var h = pop(); // help messages packed
				if(h.indexOf("No help message")!=-1) h = "( -- ) I am a marker.";
				last().help = h;
				dictate("get-vocs"); last().vocswas = pop(); 
				last().orderwas = orderwas;  // FigTaiwan 爽哥提醒 // dynamic variable array 的 reference 給了別人之後就不會蒸發掉了。
				// --------------------- the restore phase ----------------------------------
				// xt's job is to restore the saved context  
                last().xt = function(){ 
                    here = this.herewas;
					order.splice(0,order.length); 
					for(var i=0; i<this.orderwas.length; i++) order[i] = this.orderwas[i]; // FigTaiwan 爽哥提醒; order[order.length-1] 就是 context 不必再 save-restore.
					for(var vid in words) {
						if(!vm.g.isMember(vid, this.vocswas).flag) {
							delete words[vid]; // if the word-list was not exist then delete it.
						}
					}
					current = this.vid; // FigTaiwan 爽哥提醒。 我不管 current vocabulary 還在不在，一律 restore 到原來的.
                    dictionary = dictionary.slice(0,here);
					for(var vid in words) { // go through all word lists to restore their length
						words[vid] = words[vid].slice(0, this.lengthwas[vid]); 
					}
                    dictate("rescan-word-hash");
                }
                end-code
				/// voc.f reDef'ed 進一步解決 vocs 的 save-restore. 

: marker     	( <name> -- ) \ Create marker <name>. Run <name> to forget itself and all newers.
				BL word (marker) ;

				<selftest>
					*** marker (marker) are very complicated
					marker ---%%%--- 
					: marker-test-dummy ;
					' marker-test-dummy boolean \ true
					---%%%--- 
					' marker-test-dummy boolean \ false
					[d true,false d] [p '(marker)','marker' p]
				</selftest>

code words		( <["pattern" [-t|-T|-n|-N]]> -- ) \ List all words or words screened by spec.
				var spec = nexttoken("\\r|\\n").replace(/\s+/g," ").split(" "); // [pattern,option,rests]
				for (var j=0; j<order.length; j++) { // 越後面的 priority 越新
					push(order[j]); // vocabulary
					push(spec[0]||""); // pattern
					push(spec[1]||""); // option
					execute("(words)"); // [words...]
					if (tos().length) { 
						type("\n-------- " + order[j] +" ("+ tos().length + " words) --------\n"); 
						for(var i=0; i<tos().length; i++) type(tos()[i].name+" ");
					}
					pop();
				}
				execute("cr");
                end-code interpret-only
				/// Modified by voc.f to support vocabulary.
				last :: comment+=tick("(words)").comment
				/// Example: words ! -n

				<selftest>
					marker ---
					*** words modified for volcabulary
					js> kvm.screenbuffer.length constant start-here // ( -- n ) 
					js: vm.selftest_visible=false
					words \ 
					js: vm.selftest_visible=true
					start-here <js> kvm.screenbuffer.slice(pop()).indexOf("-------- forth (")!=-1 </jsV> \ true
					start-here <js> kvm.screenbuffer.slice(pop()).indexOf("words) --------")!=-1 </jsV> \ true true
					[d true,true d] [p "words" p]
					---
				</selftest>

: help			( <[pattern [switch]]> -- )  \ Print help message of screened words
				char \r|\n word ( spec )
				js> tos().length if 
					<js>
					var spec = pop();
					for (var j=0; j<order.length; j++) { // 越後面的 priority 越新
						push(order[j]); // vocabulary
						push(spec=='*'?"":spec); // "[pattern [switch]]" or "" if spec is '*'
						execute("(help)");
						if (tos()){
							type("\n-------- " + order[j] + " --------\n"); 
							execute('.');
						} else pop();
					}
					</js>
					cr
				else
					drop cr version drop
					\ general-help message 引用原來的.
					['] help :> general_help . cr
				then ; 
				/// Modified by voc.f to support vocabulary.
				last :: comment+=tick("(words)").comment
				/// A pattern of star '*' matches all words.
				/// Example: 
				///   help * <-- show help of all words
				///   help * -N <-- show help of '*' command

				<selftest>
					marker ---
					*** help modified for volcabulary ... 
					js: vm.selftest_visible=false;vm.screenbuffer=""
					help \
					js: vm.selftest_visible=true
					<js> vm.screenbuffer.indexOf("-- forth --")!=-1 </jsV> \ true
					<js> vm.screenbuffer.indexOf("Comment down to the next")!=-1 </jsV> \ true
					[d true,true d] [p "help" p]
					---
				</selftest>

: ?skip2		( "name.f" <EOF> -- "name.f" |empty ) \ skip to <EOF> to avoid double including
				dup (') 			( name.f exist? )
				BL word swap 		( name.f eof exist? )
				if 					( name.f eof )
					word drop 		( name.f )
					BL word 		( name.f eof )
					drop			( name.f )
				else				( name.f eof )
				then				
				drop ;
				/// Conditional skep TIB down to the next EOF mark.
				/// The EOF mark is supposed to be at the end of a \ comment at end of the .f file.
				/// In None-blocking settings, to support suspend-resume of the forth VM, dictate()
				/// can not call itself recursively so as to avoid from confusing the suspend-level.
				/// While 'include' used to utilize dictate() that is now replaced by "tib.insert".
				/// Use ?skip2 at the beginning of a .f file if you don't want it to be double included.

: temp			( -- ) \ The source-code-file.f header macro 
				<text>
					?skip2 --EOF-- \ skip it if already included
					dup .( Including ) . cr char -- over over + +
					js: tick('<selftest>').masterMarker=tos()+"selftest--";
					also forth definitions (marker) (vocabulary)
					last execute definitions
					<selftest>
						js> tick('<selftest>').masterMarker (marker)
					</selftest>
				</text> tib.insert ;
				js: last().name="source-code"+"-header"
				/// skip including if the module has been included.
				/// setup the self-test module
				/// initiate vocabulary for the including module

<selftest> --voc.f-self-test-- </selftest>
js> tick('<selftest>').enabled [if] js> tick('<selftest>').buffer tib.insert [then] 
js: tick('<selftest>').buffer="" \ recycle the memory

\ --EOF--
