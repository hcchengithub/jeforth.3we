
\ 取得 project-k 的 kernel 得到 constructor jeForth()
js> jeForth [if] [else]
	<h> <Script src="..\project-k\jeforth.js"></Script></h>
	: <kernel>        ( <text> -- "text" ) \ Get multiple-line string
					char </kernel> word ; immediate

	: </kernel>       ( "text" -- ... ) \ Delimiter of <text>
					compiling if literal then ; immediate
					/// Usage: <kernel> word of multiple lines </kernel>
[then]
<js> (new jeForth())</jsV> constant k // ( -- obj ) the project-k object
k :: init(print)
<js> g.k.dictate("code hi type('hello world') end-code")</js>
k :: dictate("hi")
<kernel>
	code //         var s = nexttoken('\n|\r'); last().help = s; end-code // ( <comment> -- ) Give help message to the last word.
	code stop       stop=true end-code // ( -- ) Stop the TIB loop
	code parse-help var ss = " " + pop() + " ", comment = "";
					var stackDiagram = ss.match(/^\s+(\(\s.*\s\))\s+(.*)/); // null or [0] entire line, [1] (...), [2] the rest.
					if(stackDiagram) { 
						comment = (" "+stackDiagram[2]+" ").match(/^\s+\\\s+(.*\S)\s+/); // null or [0] entire line, [1] comment
						if(comment){
							push(stackDiagram[1]+" "+comment[1]);
							push("");
						} else {
							push(stackDiagram[1]);
							push(stackDiagram[2]);
						}
					} else {    
						comment = ss.match(/^\s+\\\s+(.*\S)\s+/); // null or [0] entire line, [1] comment
						if(comment){
							push(comment[1]);
							push("");
						} else {
							push("( ?? ) No help message. Use // to add one.");
							push(ss);
						}
					}   
					end-code        
					// ( "line" -- "helpmsg" "rests" ) Parse "( -- ) \ help foo baa" from 1st input line
	code code       push(nexttoken()); // name of the word
					push(nexttoken('\n|\r')); // rest of the first line
					execute("parse-help"); // ( "name" "helpmsg" "rests" )
					tib = pop() + " " + tib.slice(ntib); // "rests" + tib(ntib)
					ntib = 0;
					newhelp = pop();
					tib = pop() + " " + tib; // "name" + tib
					execute(words.root[1]);
					end-code
					// ( <name ..code..> -- ) Start composing a code word.
	code init       ( -- ) \ Initialize vm.g.members that are moved out from jeforth.js which is thus kept pure.
					// global hash
					vm.g = {};

					// An array's length is array.length but there's no such thing of hash.length for hash{}.
					// memberCount(object) gets the given object's member count which is also a hash table's length.
					vm.g.memberCount = function (obj) {
						var i=0;
						for(var members in obj) i++;
						return i;
					}
					// This is a useful common tool. Compare two arrays.
					vm.g.isSameArray = function (a,b) {
						if (a.length != b.length) {
							return false;
						} else {
							for (var i=0; i < a.length; i++){
								var ta = typeof(a[i]);
								var tb = typeof(b[i]);
								if (ta == tb) {
									if (ta == "number"){
										if (isNaN(a[i]) && isNaN(b[i])) continue; // because (NaN == NaN) 的結果是 false 所以要特別處理。
									}
									if (ta == "object") {  // 怎麼比較 obj? v2.05 之後用 memberCount()
										if (vm.g.memberCount(a[i]) != vm.g.memberCount(b[i])) return false;
									} else if (a[i] != b[i]) return false;
								} else if (a[i] != b[i]) return false;
							}
							return true;
						}
					}
					// Tool, check if the item exists in the array or is it a member in the hash.
					// return {flag, key}
					vm.g.isMember = function (item, thing){
						var result = {flag:false, key:0};
						if (mytypeof(thing) == "array") {
							for (var i in thing) {
								if (item == thing[i]) {
									result.flag = true;
									result.key = parseInt(i); // array 被 JavaScript 當作 object 而 i 是個 string, 所以要轉換!
									break;
								}
							}
						} else { // if obj is not an array then assume it's an object
							for (var i in thing) {
								if (item == i) {
									result.flag = true;
									result.key = thing[i];
									break;
								}
							}
						}
						return result; // {flag:boolean, value:(index of the array or value of the obj member)}
					}
					// How to clear all setInterval() and setTimeOut() without knowing their ID?
					// http://stackoverflow.com/questions/8769598/how-to-clear-all-setinterval-and-settimeout-without-knowing-their-id
					// 缺點是 vm.g.setTimeout.registered() 會大量堆積，需 delete(vm.g.setTimeout.registered()[id.toString()]) 既然還得記住
					// timeoutId 使得 vm.g.setTimeout() 的好處大打折扣。 查看： js> vm.g.setTimeout.registered() (see)
					// setInterval 比較不會大量堆積，最好還是要適時 delete。查看：js> vm.g.setInterval.registered() (see)
					vm.g.setInterval = (function(){
						var registered={};
						f = function(a,b){
							var id = setInterval(a,b);
							registered[id.toString()] = id;
							return id;
						};
						f.clearAll = function(){
							for(var r in registered){clearInterval( registered[r] )}
							registered={};
						};
						f.registered = function(){return(registered)};
						return f;    
					})();
					vm.g.setTimeout = (function(){
						var registered={};
						f = function(a,b){
							var id = setTimeout(a,b);
							registered[id.toString()] = id;
							return id;
						};
						f.clearAll = function(){
							for(var r in registered){clearTimeout( registered[r] )}
							registered={};
						};
						f.registered = function(){return(registered)};
						return f;    
					})();
					// This is a useful common tool. Help to recursively see an object or forth Word.
					// For forth Words, view the briefing. For other objects, try to see into it.
					vm.g.see = function (obj,tab){
						if (tab==undefined) tab = "  "; else tab += "  ";
						switch(mytypeof(obj)){
							case "object" :
							case "array" :
								if (obj.constructor != Word) {
									if (obj&&obj.toString) 
										type(obj.toString() + '\n');
									else 
										type(Object.prototype.toString.apply(obj) + '\n');
									for(var i in obj) {
										type(tab + i + " : ");  // Entire array already printed here.
										if (obj[i] && obj[i].toString || obj[i]===0) 
											type(tab + obj[i].toString() + '\n');
										else
											type(tab + Object.prototype.toString.apply(obj[i]) + '\n');
									}
									break;  // if is Word then do default
								}
							default : // Word(), Constant(), number, string, null, undefined
								var ss = obj + ''; // Print-able test
								type(ss + " (" + mytypeof(obj) + ")\n");
						}
					}
					vm.g.debugInner = function (entry, resuming) {
						var w = phaseA(entry); // 翻譯成恰當的 w.
						do{
							while(w) { // 這裡是 forth inner loop 決戰速度之所在，奮力衝鋒！
								if(bp<0||bp==ip){vm.jsc.prompt='ip='+ip+" jsc>";eval(vm.jsc.xt)}; // 可用 bp=ip 設斷點, debug colon words.
								ip++; // Forth 的通例，inner loop 準備 execute 這個 word 之前，IP 先指到下一個 word.
								phaseB(w); // 針對不同種類的 w 採取正確方式執行它。
								w = dictionary[ip];
							}
							if(w===0) break; else ip = rstack.pop(); // w==0 is suspend, abort inner but reserve rstack
							if(resuming) w = dictionary[ip];
						} while(ip && resuming); // ip==0 means resuming has done
					}
					end-code init
	code words      for(var i=1; i<words.root.length; i++) type(words.root[i].name+" ") end-code // ( -- ) List all words
	code execute    ( Word|"name"|address|empty -- ... ) \ Execute the given word or the last() if stack is empty.
					execute(pop()); end-code
	code interpret-only  ( -- ) \ Make the last new word an interpret-only.
					last().interpretonly=true;
					end-code interpret-only
	code immediate  ( -- ) \ Make the last new word an immediate.
					last().immediate=true
					end-code
	code .((        ( <str> -- ) \ Print following string down to '))' immediately.
					type(nexttoken('\\)\\)'));ntib+=2; end-code immediate

	code \          ( <comment> -- ) \ Comment down to the next '\n'.
					nexttoken('\n') end-code immediate

	code compile-only  ( -- ) \ Make the last new word a compile-only.
					last().compileonly=true
					end-code interpret-only

	\ ------------------ Fundamental words ------------------------------------------------------

	code (create)   ( "name" -- ) \ Create a code word that has a dummy xt, not added into wordhash{} yet
					if(!(newname=pop())) panic("Create what?\n", tib.length-ntib>100);
					if(isReDef(newname)) type("reDef "+newname+"\n"); // 若用 tick(newname) 就錯了
					current_word_list().push(new Word([newname,function(){}]));
					last().vid = current; // vocabulary ID
					last().wid = current_word_list().length-1; // word ID
					last().type = "colon-create";
					// last().help = newname + " " + packhelp(); // help messages packed
					end-code

	code reveal     ( -- ) \ Add the last word into wordhash
					wordhash[last().name]=last() end-code
					\ We don't want the last word to be seen during its colon definition.
					\ So reveal is done in ';' command.

	code ///        ( <comment> -- ) \ Add comment to the new word, it appears in 'see'.
					var ss = nexttoken('\n|\r');
					// ss = ss.replace(/(\s*(\n|\r))|(\s+$)/gm,'\n'); // trim tailing white spaces
					ss = ss.replace(/^/,"\t"); // Add leading \t to each line.
					ss = ss.replace(/\s*$/,'\n'); // trim tailing white spaces
					last().comment = typeof(last().comment) == "undefined" ? ss : last().comment + ss;
					end-code interpret-only

	code (space)    push(" ") end-code // ( -- " " ) Put a space on TOS.

	code BL         push("\\s") end-code // ( -- "\s" ) RegEx white space.

	code CR         push("\n") end-code // ( -- '\n' ) NewLine is ASCII 10(0x0A)
					/// Also String.fromCharCode(10) in JavaScript

	code jsEval     ( "js code" -- result ) \ Evaluate the given JavaScript statements, return the last statement's value.
					try {
					  push(eval(pop()));
					} catch(err) {
					  panic("JavaScript error : "+err.message+"\n", "error");
					};
					end-code

	code jsEvalNo   ( "js code" -- ) \ Evaluate the given JavaScript statements, w/o return value.
					try {
					  eval(pop());
					} catch(err) {
					  panic("JavaScript error : "+err.message+"\n", "error");
					};
					end-code

	code jsFunc     ( "js code" -- function ) \ Compile JavaScript to a function() that returns last statement
					var ss=pop();
					ss = ss.replace(/(^( |\t)*)|(( |\t)*$)/gm,''); // remove 頭尾 white spaces
					ss = ss.replace(/\s*\/\/.*$/gm,''); // remove // comments
					ss = ss.replace(/(\n|\r)*/gm,''); // merge to one line
					ss = ss.replace(/\s*\/\*.*?\*\/\s*/gm,''); // remove /* */ comments
					ss = ss.replace(/;*\s*$/,''); // remove ending ';' from the last statement
					var parsed=ss.match(/^(.*;)(.*)$/); // [entire string,fore part,last statement]|NULL
					if (parsed){
						eval("push(function(){" + parsed[1] + "push(" + parsed[2] + ")})");
					}else{
						eval("push(function(){push(" + ss + ")})");
					}
					end-code
					
	code jsFuncNo   ( "js code" -- function ) \ Compile JavaScript to a function()
					eval("push(function(){" + pop() + "})"); 
					end-code
	code [          compiling=false end-code immediate // ( -- ) 進入直譯狀態, 輸入指令將會直接執行 *** 20111224 sam
	code ]          compiling=true end-code // ( -- ) 進入編譯狀態, 輸入指令將會編碼到系統 dictionary *** 20111224 sam
	code compiling  push(compiling) end-code // ( -- boolean ) Get system state
	code last       push(last()) end-code // ( -- word ) Get the word that was last defined.

	code exit       ( -- ) \ Exit this colon word.
					comma(EXIT) end-code immediate compile-only

	code ret        ( -- ) \ Mark at the end of a colon word.
					comma(RET) end-code immediate compile-only

	code rescan-word-hash ( -- ) \ Rescan all word-lists in the order[] to rebuild wordhash{}
					wordhash = {};
					for (var j=0; j<order.length; j++) { // 越後面的 priority 越高
						for (var i=1; i<words[order[j]].length; i++){  // 從舊到新，以新蓋舊,重建 wordhash{} hash table.
							if (compiling) if (last()==words[order[j]][i]) continue; // skip the last() avoid of an unexpected 'reveal'.
							wordhash[words[order[j]][i].name] = words[order[j]][i];
						}
					}
					end-code
					/// Used in (forget) and vocabulary words.

	code (forget)   ( -- ) \ Forget the last word
					if (last().cfa) here = last().cfa;
					words[current].pop(); // drop the last word
					execute("rescan-word-hash");
					end-code

	code :          ( <name> -- ) \ Begin a forth colon definition.
					newname = nexttoken();
					push(nexttoken('\n|\r')); 
					execute("parse-help"); // ( "name" "helpmsg" "rests" )
					tib = pop() + tib.slice(ntib); // "rests" + tib(ntib)
					ntib = 0;
					newhelp = pop();
					push(newname); execute("(create)"); // 故 colon definition 裡有 last or last() 可用來取得本身。
					compiling=true;
					stackwas = stack.slice(0); // Should not be changed, ';' will check.
					last().type = "colon";
					last().cfa = here;
					last().help = newhelp;
					last().xt = colonxt = function(){
						rstack.push(ip);
						inner(this.cfa);
					}
					end-code

	code ;          ( -- ) \ End of the colon definition.
					if (!vm.g.isSameArray(stackwas,stack)) {
						panic("Stack changed during colon definition, it must be a mistake!\n", "error");
						words[current].pop();
					} else {
						comma(RET);
					}
					compiling = false;
					execute('reveal');
					end-code immediate compile-only

	code (')        ( "name" -- Word ) \ name>Word like tick but the name is from TOS.
					push(tick(pop())) end-code

	code '          ( <name> -- Word ) \ Tick, get word name from TIB, leave the Word object on TOS.
					push(tick(nexttoken())) end-code

	code #tib       push(ntib) end-code // ( -- n ) Get ntib
	code #tib!      ntib = pop() end-code // ( n -- ) Set ntib

	\ ------------------ eforth code words ----------------------------------------------------------------------

	code branch     ip=dictionary[ip] end-code compile-only // ( -- ) 將當前 ip 內數值當作 ip *** 20111224 sam

	code 0branch    if(pop())ip++;else ip=dictionary[ip] end-code compile-only // ( n -- ) 若 n!==0 就將當前 ip 內數值當作 ip, 否則將 ip 進位 *** 20111224 sam
	code !          dictionary[pop()]=pop() end-code // ( n a -- ) 將 n 存入位址 a
	code @          push(dictionary[pop()]) end-code // ( a -- n ) 從位址 a 取出 n
	code >r         rstack.push(pop()) end-code  // ( n -- ) Push n into the return stack.
	code r>         push(rstack.pop()) end-code  // ( -- n ) Pop the return stack
	code r@         push(rstack[rstack.length-1 ]) end-code // ( -- r0 ) Get a copy of the TOS of return stack
	code drop       pop(); end-code // ( x -- ) Remove TOS.
	code dup        push(tos()); end-code // ( a -- a a ) Duplicate TOS.
	code swap       var t=stack.length-1;var b=stack[t];stack[t]=stack[t-1];stack[t-1]=b end-code // ( a b -- b a ) stack operation
	code over       push(stack[stack.length-2]); end-code // ( a b -- a b a ) Stack operation.
	code 0<         push(pop()<0) end-code // ( a -- f ) 比較 a 是否小於 0

	code here!      here=pop() end-code // ( a -- ) 設定系統 dictionary 編碼位址
	code here       push(here) end-code // ( -- a ) 系統 dictionary 編碼位址 a

	\ JavaScript logical operations can be confusing
	\ 在處理邏輯 operator 時我決定用 JavaScript 自己的 Boolean() 來 logicalize 所有的
	\ operands, 這類共有 and or not 三者。為了保留 JavaScript && || 的功能 (邏輯一旦確
	\ 立隨即傳回該 operand 之值) 另外定義 && || 遵照之，結果變成很奇特的功能。Forth 傳
	\ 統的 AND OR NOT XOR 是 bitwise operators, 正好用傳統的大寫給它們。

	code boolean    push(Boolean(pop())) end-code // ( x -- boolean(x) ) Cast TOS to boolean.
	code and        var b=pop(),a=pop();push(Boolean(a)&&Boolean(b)) end-code // ( a b == a and b ) Logical and. See also '&&' and 'AND'.
	code or         var b=pop(),a=pop();push(Boolean(a)||Boolean(b)) end-code // ( a b == a or b ) Logical or. See also '||' and 'OR'.
	code not        push(!Boolean(pop())) end-code // ( x == !x ) Logical not. Capital NOT is for bitwise.
	code &&         push(pop(1)&&pop()) end-code // ( a b == a && b ) if a then b else swap endif
	code ||         push(pop(1)||pop()) end-code // ( a b == a || b ) if a then swap else b endif
	code AND        push(pop() & pop()) end-code // ( a b -- a & b ) Bitwise AND. See also 'and' and '&&'.
	code OR         push(pop() | pop()) end-code // ( a b -- a | b ) Bitwise OR. See also 'or' and '||'.
	code NOT        push(~pop()) end-code // ( a -- ~a ) Bitwise NOT. Small 'not' is for logical.
	code XOR        push(pop() ^ pop()) end-code // ( a b -- a ^ b ) Bitwise exclusive OR.
	code true       push(true) end-code // ( -- true ) boolean true.
	code false      push(false) end-code // ( -- false ) boolean false.
	code ""         push("") end-code // ( -- "" ) empty string.
	code []         push([]) end-code // ( -- [] ) empty array.
	code {}         push({}) end-code // ( -- {} ) empty object.
	code undefined  push(undefined) end-code // ( -- undefined ) Get an undefined value.
	code null       push(null) end-code // ( -- null ) Get a null value.
					/// 'Null' can be used in functions to check whether an argument is given.

	\ Not eforth code words
	\ 以下照理都可以用 eforth 的基本 code words 組合而成 colon words, 我覺得 jeforth 裡適合用 code word 來定義。

	code +          push(pop(1)+pop()) end-code // ( a b -- a+b) Add two numbers or concatenate two strings.
	code *          push(pop()*pop()) end-code // ( a b -- a*b ) Multiplex.
	code -          push(pop(1)-pop()) end-code // ( a b -- a-b ) a-b
	code /          push(pop(1)/pop()) end-code // ( a b -- c ) 計算 a 與 b 兩數相除的商 c
	code 1+         push(pop()+1) end-code // ( a -- a++ ) a += 1
	code 2+         push(pop()+2) end-code // ( a -- a+2 )
	code 1-         push(pop()-1) end-code // ( a -- a-1 ) TOS - 1
	code 2-         push(pop()-2) end-code // ( a -- a-2 ) TOS - 2

	code mod        push(pop(1)%pop()) end-code // ( a b -- c ) 計算 a 與 b 兩數相除的餘 c
	code div        var b=pop();var a=pop();push((a-(a%b))/b) end-code // ( a b -- c ) 計算 a 與 b 兩數相除的整數商 c

	code >>         var n=pop();push(pop()>>n) end-code // ( data n -- data>>n ) Singed right shift
	code <<         var n=pop();push(pop()<<n) end-code // ( data n -- data<<n ) Singed left shift
	code >>>        var n=pop();push(pop()>>>n) end-code // ( data n -- data>>>n ) Unsinged right shift. Note! There's no <<<.

	code 0=         push(pop()==0) end-code // ( a -- f ) 比較 a 是否等於 0
	code 0>         push(pop()>0) end-code // ( a -- f ) 比較 a 是否大於 0
	code 0<>        push(pop()!=0) end-code // ( a -- f ) 比較 a 是否不等於 0
	code 0<=        push(pop()<=0) end-code // ( a -- f ) 比較 a 是否小於等於 0
	code 0>=        push(pop()>=0) end-code // ( a -- f ) 比較 a 是否大於等於 0
	code =          push(pop()==pop()) end-code // ( a b -- a=b ) 經轉換後比較 a 是否等於 b, "123" = 123.
	code ==         push(Boolean(pop())==Boolean(pop())) end-code // ( a b -- f ) 比較 a 與 b 的邏輯
	code ===        push(pop()===pop()) end-code // ( a b -- a===b ) 比較 a 是否全等於 b
	code >          var b=pop();push(pop()>b) end-code // ( a b -- f ) 比較 a 是否大於 b
	code <          var b=pop(); push(pop()<b) end-code // ( a b -- f ) 比較 a 是否小於 b
	code !=         push(pop()!=pop()) end-code // ( a b -- f ) 比較 a 是否不等於 b
	code !==        push(pop()!==pop()) end-code // ( a b -- f ) 比較 a 是否不全等於 b
	code >=         var b=pop();push(pop()>=b) end-code // ( a b -- f ) 比較 a 是否大於等於 b
	code <=         var b=pop();push(pop()<=b) end-code // ( a b -- f ) 比較 a 是否小於等於 b
	code abs        push(Math.abs(pop())) end-code // ( n -- |n| ) Absolute value of n.
	code max        push(Math.max(pop(),pop())) end-code // ( a b -- max(a,b) ) The maximum.
	code min        push(Math.min(pop(),pop())) end-code // ( a b -- min(a,b) ) The minimum.
	code doVar      push(ip); ip=rstack.pop(); end-code compile-only // ( -- a ) 取隨後位址 a , runtime of created words
	code doNext     var i=rstack.pop()-1;if(i>0){ip=dictionary[ip]; rstack.push(i);}else ip++ end-code compile-only // ( -- ) next's runtime.
	code ,          comma(pop()) end-code // ( n -- ) Compile TOS to dictionary.

	\ 目前 Base 切換只影響 .r .0r 的輸出結果。
	\ JavaScript 輸入用外顯的 0xFFFF 形式，用不著 hex decimal 切換。

	code hex        vm.base=16 end-code // ( -- ) 設定數值以十六進制印出 *** 20111224 sam
	code decimal    vm.base=10 end-code // ( -- ) 設定數值以十進制印出 *** 20111224 sam
	code base@      push(vm.base) end-code // ( -- n ) 取得 base 值 n *** 20111224 sam
	code base!      vm.base=pop() end-code // ( n -- ) 設定 n 為 base 值 *** 20111224 sam
	10 base!        // 沒有經過宣告的 variable base 就是 vm.base
	code depth      ( -- depth ) \ Data stack depth
					push(stack.length) end-code
	code pick       ( nj ... n1 n0 j -- nj ... n1 n0 nj ) \ Get a copy of a cell in stack.
					push(tos(pop())) end-code
					/// see rot -rot roll pick
	code roll       ( ... n3 n2 n1 n0 3 -- ... n2 n1 n0 n3 )
					push(pop(pop())) end-code
					/// see rot -rot roll pick

	code .          ( sth -- ) \ Print number or string on TOS.
					type(pop());
					end-code

	: space         (space) . ; // ( -- ) Print a space.

	code word       ( "delimiter" -- "token" <delimiter> ) \ Get next "token" from TIB.
					push(nexttoken(pop())) end-code
					/// First character after 'word' will always be skipped first, token separator.
					/// If delimiter is RegEx '\s' then white spaces before the "token"
					/// will be removed. Otherwise, return TIB[ntib] up to but not include the delimiter.
					/// If delimiter not found then return the entire remaining TIB (can be multiple lines!).

	: [compile]     ' , ; immediate // ( <string> -- ) Compile the next immediate word.
					/// 把下個 word 當成「非立即詞」進行正常 compile, 等於是把它變成正常 word 使用。

	: compile       ( -- ) \ Compile the next word at dictionary[ip] to dictionary[here].
					r> dup @ , 1+ >r ; compile-only 

	code colon-word ( -- ) \ Decorate the last() as a colon word.
					// last().type = "colon";
					last().cfa = here;
					last().xt = colonxt;
					end-code

	: create        ( <name> -- ) \ Create a new word. The new word is a variable by default.
					BL word (create) reveal colon-word compile doVar ;

	code (marker)   ( "name" -- ) \ Create marker "name". Run "name" to forget itself and all newers.
					var lengthwas = current_word_list().length; // save current word list length before create the new marker word
					execute("(create)");execute("reveal");
					last().type = "marker";
					last().herewas = here;
					last().lengthwas = lengthwas; // [x] 引進 vocabulary 之後，此 marker 在只有 forth-wordlist 時使用。有了多個 word-list 之後要改寫。
					var h = "( -- ) I am a marker. I forget everything after me.";
					last().help = h;
					last().xt = function(){ // marker's xt restores the saved context
						here = this.herewas;
						order = [current = context = "root"]; // 萬一此 marker 在引入 vocabulary 之後被 call 到。
						for(var vid in words) if(vid != current) delete words[vid]; // "root" is the only one, clean up other word-lists.
						words[current] = current_word_list().slice(0, this.lengthwas);
						dictionary = dictionary.slice(0,here);
						wordhash = {};
						for (var i=1; i<current_word_list().length; i++){  // 從舊到新，以新蓋舊,重建 wordhash{} hash table.
							wordhash[current_word_list()[i].name] = current_word_list()[i];
						}
					}
					end-code
	: marker        ( <name> -- ) \ Create marker <name>. Run <name> to forget itself and all newers.
					BL word (marker) ;
	code next       comma(tick("doNext"));dictionary[here++]=pop(); end-code immediate compile-only // ( -- ) for ... next (FigTaiwan SamSuanChen)

	code cls        ( -- ) \ Clear jeforth console screen
					vm.screenbuffer = (vm.screenbuffer==null) ? null : "";
					vm.clearScreen();
					end-code
	code abort      reset() end-code // ( -- ) Reset the forth system.

	code literal    ( n -- ) \ Compile TOS as an anonymous constant
					var literal = pop();
					var getLiteral = eval("var f;f=function(){push(literal)/*(" + mytypeof(literal) + ")" + literal.toString() + " */}");
					comma(getLiteral);
					end-code
	code alias      ( Word <alias> -- ) \ Create a new name for an existing word
					var w = pop();
					// To use the correct TIB, must use execute("word") instead of dictate("word").
					execute("BL"); execute("word"); execute("(create)");execute("reveal");
					// mergeObj(last(), w); // copy everything by value from the predecessor includes arrays and objects.
					for(var i in w) last()[i] = w[i]; // copy from predecessor but arrays and objects are by reference
					last().predecessor = last().name;
					last().name = newname;
					last().type = "alias";
					end-code

	\ ------------------ eforth colon words ---------------------------

	' != alias <>   // ( a b -- f ) 比較 a 是否不等於 b, alias of !=.
	code nip        pop(1) end-code // ( a b -- b ) 
	code rot        push(pop(2)) end-code // ( w1 w2 w3 -- w2 w3 w1 ) 
					/// see rot -rot roll pick
	code -rot       push(pop(),1) end-code // ( w1 w2 w3 -- w3 w1 w2 ) 
					/// see rot -rot roll pick
	code 2drop      stack.splice(stack.length-2,2) end-code // ( ... a b -- ... )
	: 2dup          ( w1 w2 -- w1 w2 w1 w2 ) over over ;
	' NOT alias invert // ( w -- ~w )
	: negate        -1 * ; // ( n -- -n ) Negated TOS.
	: within         ( n low high -- within? ) -rot over max -rot min = ;

	: [']           ( <name> -- Word ) \ In colon definitions, compile next word object as a literal.
					' literal ; immediate compile-only

	: allot         here + here! ; // ( n -- ) 增加 n cells 擴充 memory 區塊

	: for           ( count -- ) \ for..next loop.
					compile >r here ; immediate compile-only
					/// for ... next (count ... 2,1) but when count <= 0 still do once!!
					/// for aft ... then next (count-1 ... 2,1) but do nothing if count <= 1.
					/// : test 5 for r@ . space next ; test ==> 5 4 3 2 1
					/// : test 5 for 5 r@ - . space next ; test ==> 0 1 2 3 4 
					/// : test dup for dup r@ - . space next drop ; 5 test ==> 0 1 2 3 4 
					/// : test 10 for 10 r@ - dup . space 5 >= if r> drop 0 >r then next ; test
					/// ==> 0 1 2 3 4 5 , "r> drop 0 >r" is leave/exit/terminate of for..next loop
					
	: begin         ( -- a ) \ begin..again, begin..until, begin..while..until..then, begin..while..repeat
					here ; immediate compile-only
	: until         ( a -- ) \ begin..until, begin..while..until..then,
					compile 0branch , ; immediate compile-only
	: again         ( a -- ) \ begin..again,
					compile  branch , ; immediate compile-only

	: if            ( -- a ) \ if..else..then, if..then
					compile 0branch here 0 , ; immediate compile-only
	: ahead         ( -- a ) \ aft internal use
					compile branch here 0 , ; immediate compile-only
	' ahead alias never immediate compile-only // ( -- a ) never ... then for call-back entry inner(word.cfa+n) 
	: repeat        ( a a -- ) \ begin..while..repeat
					[compile] again here swap ! ; immediate compile-only
	: then          ( a -- ) \ if....else..then, for aft...then next, begin..while..until..then
					here swap ! ; immediate compile-only
	: aft           ( a -- a a ) \ for aft ... then next
					drop [compile] ahead [compile] begin swap ; immediate compile-only
	: else          ( a -- a ) \ if..else..then
					[compile] ahead swap [compile] then ; immediate compile-only
	: while         ( a -- a a ) \ begin..while..repeat, begin..while..until..then
					[compile] if swap ; immediate compile-only
	: char          ( <str> -- str ) \ Get character(s).
					BL word compiling if literal then ; immediate
					/// "char abc" gets "abc", Note! ANS forth "char abc" gets only 'a'.

	: ?dup          dup if dup then ; // ( w -- w w | 0 ) Dup TOS if it is not 0|""|false.

	: variable      ( <string> -- ) \ Create a variable.
					create 0 , [ char push(function(){last().type='colon-variable'}) jsEvalNo , ] ;
					
	: +!            ( n addr -- ) \ Add n into addr, addr is a variable.
					swap over @ swap + swap ! ;
	: ?             @ . ; // ( a -- ) print value of the variable.
	: chars         ( n str -- ) \ Print str n times.
					swap 0 max dup 0= if exit then for dup . next drop ;

	: spaces        ( n -- ) \ print n spaces.
					(space) chars ;
	: .(            char \) word . BL word drop ; immediate // ( <str> -- ) Print following string down to ')' immediately.
	: ."            ( <str> -- ) \ Print following string down to '"'.
					char " word compiling if literal compile .
					else . then BL word drop ; immediate
					\ 本來是 compile-only, 改成都可以。 hcchen5600 2014/07/17 16:40:04
	: .'            ( <str> -- ) \ Print following string down to "'".
					char ' word compiling if literal compile .
					else . then BL word drop ; immediate
					\ 本來是 compile-only, 改成都可以。 hcchen5600 2014/07/17 16:40:04
	: s"            ( <str> -- str ) \ Get string down to the next delimiter.
					char " word compiling if literal then BL word drop ; immediate
	: s'            ( <str> -- str ) \ Get string down to the next delimiter.
					char ' word compiling if literal then BL word drop ; immediate
	: s`            ( <str> -- str ) \ Get string down to the next delimiter.
					char ` word compiling if literal then BL word drop ; immediate
	: does>         ( -- ) \ redirect the last new colon word.xt to after does>
					[compile] ret \ dummy 'ret' mark for 'see' to know where is the end of a creat-does word
					r> [ s" push(function(){push(last().cfa)})" jsEvalNo , ] ! ; 
	: count         ( string -- string length ) \ Get length of the given string
					[ s" push(function(){push(tos().length)})" jsEvalNo , ] ;
	code accept     push(false) end-code // ( -- str T|F ) Read a line from terminal. A fake before I/O ready.
	: refill        ( -- flag ) \ Reload TIB from stdin. return 0 means no input or EOF
					accept if [ s" push(function(){tib=pop();ntib=0})" jsEvalNo , ] 1 else 0 then ;

	: [else] ( -- ) \ 考慮中間的 nested 結構，把下一個 [then] 之前的東西都丟掉。
					1
					begin \ level
						begin \ level
							BL word count \ (level $word len ) 吃掉下一個 word
						while \ (level $word) 查看這個被吃掉的 word
							dup s" [if]" = if \ level $word
								drop 1+ \ level' 如果這個 word 是 [if] 就要多出現一個 [then] 之後才結束
							else \ level $word
								dup s" [else]" = if \ (level)
									drop 1- dup if 1+ then \ (level') 這個看不太懂，似乎是如果最外層多出一個 [else] 就把它當 [then] 用。
								else \ level $word
									s" [then]" = if \ (level)
										1- \ level' \ (level') 如果這個 word 是 [then] 就剝掉一層
									then \ (level') 其他 word 吃掉就算了
								then \ level'
							then \ level'
							?dup if else exit then \ (level') 這個 [then] 是最外層就整個結束，否則繼續吃掉下一個 word.
						repeat \ (level) or (level $word)
						drop   \ (level)
					refill not until \ level
					drop
					; immediate
	: [if]          ( flag -- ) \ Conditional compilation [if] [else] [then]
					if else [compile] [else] then \ skip everything down to [else] or [then] when flag is not true.
					; immediate
	: [then]        ( -- ) \ Conditional compilation [if] [else] [then]
					; immediate
	: js>           ( <expression> -- value ) \ Evaluate JavaScript <expression> which has no white space within.
					BL word compiling if jsFunc , else jsEval then  ; immediate
					/// Same thing as "s' blablabla' jsEval" but simpler. Return the last statement's value.
	: js:           ( <expression> -- ) \ Evaluate JavaScript <expression> which has no white space within
					BL word compiling if jsFuncNo , else jsEvalNo then  ; immediate
					/// Same thing as "s' blablabla' jsEvalNo" but simpler. No return value.
	: ::            ( obj <foo.bar> ) \ Simplified form of "obj js: pop().foo.bar" w/o return value
					BL word js> tos().charAt(0)=='['||tos().charAt(0)=='(' if char pop() else  char pop(). then 
					swap + compiling if jsFuncNo , else jsEvalNo then ; immediate
	: :>            ( obj <foo.bar> ) \ Simplified form of "obj js> pop().foo.bar" w/return value
					BL word js> tos().charAt(0)=='['||tos().charAt(0)=='(' if char pop() else  char pop(). then 
					swap + compiling if jsFunc , else jsEval then ; immediate
	: (             ( <str> -- ) \ Ignore the comment down to ')', can be nested but must be balanced
					js> nextstring(/\(|\)/).str \ word 固定會吃掉第一個 character 故不適用。
					drop js> tib[ntib++] \ 撞到停下來的字母非 '(' 即 ')' 要不就是行尾，都可以 skip 過去
					char ( = if \ 剛才那個字母是啥？
						[ last literal ] dup \ 取得本身
						execute \ recurse nested level
						execute \ recurse 剩下來的部分
					then ; immediate 

	: "msg"abort    ( "errormsg" -- ) \ Panic with error message and abort the forth VM
					js: panic(pop()+'\n') abort ;

	: abort"        ( <msg> -- ) \ Through an error message and abort the forth VM
					char " word literal BL word drop compile "msg"abort ;
					immediate compile-only

	: "msg"?abort   ( "errormsg" flag -- ) \ Conditional panic with error message and abort the forth VM
					if "msg"abort else drop then ;

	: ?abort"       ( f <errormsg> -- ) \ Conditional abort with an error message.
					char " word literal BL word drop
					compile swap compile "msg"?abort ;
					immediate compile-only

	\ 其實所有用 word 取 TIB input string 的 words， 用 file 或 clipboard 輸入時， 都是可
	\ 以跨行的！只差用 keyboard 輸入時受限於 console input 一般都是以「行」為單位的，造成
	\ TIB 只能到行尾為止後面沒了，所以才會跨不了行。將來要讓 keyboard 輸入也能跨行時，就
	\ 用 text。

	: <text>        ( <text> -- "text" ) \ Get multiple-line string
					char </text> word ; immediate

	: </text>       ( "text" -- ... ) \ Delimiter of <text>
					compiling if literal then ; immediate
					/// Usage: <text> word of multiple lines </text>

	: <comment>     ( <comemnt> -- ) \ Can be nested
					[ last literal ] :: level+=1 char <comment>|</comment> word drop 
					; immediate last :: level=0

	: </comment>    ( -- ) \ Can be nested
					['] <comment> js> tos().level>1 swap ( -- flag obj )
					js: tos().level=Math.max(0,pop().level-2) \ 一律減一，再預減一餵給下面加回來
					( -- flag ) if [compile] <comment> then ; immediate 

	: <js>          ( <js statements> -- "statements" ) \ Evaluate JavaScript statements
					char </js>|</jsV>|</jsN>|</jsRaw> word ; immediate

	: </jsN>        ( "statements" -- ) \ No return value
					compiling if jsFuncNo , else jsEvalNo then ; immediate
					/// 可以用來組合 JavaScript function
					last alias </js>  immediate

	: </jsV>        ( "statements" -- ) \ Retrun the value of last statement
					compiling if jsFunc , else jsEval then ; immediate
					/// 可以用來組合 JavaScript function

	: constant      ( n <name> -- ) \ Create a 'constnat', Don't use " in <name>.
					BL word (create) <js> 
					last().type = "constant";
					var s = 'var f;f=function(){push(vm.g["' 
							+ last().name 
							+ '"])}';
					last().xt = eval(s);
					vm.g[last().name] = pop();
					</js> reveal ; 
	: value         ( n <name> -- ) \ Create a 'value' variable, Don't use " in <name>.
					constant last :: type='value' ; 
	: to            ( n <value> -- ) \ Assign n to <value>.
					' ( word ) <js> if (tos().type!="value") panic("Error! Assigning to a none-value.\n",'error') </js>
					compiling if ( word ) 
						<js> var s='var f;f=function(){/* to */ vm.g["'+pop().name+'"]=pop()}';push(eval(s))</js> ( f ) ,
					else ( n word )
						js: vm.g[pop().name]=pop()
					then ; immediate

	: sleep         ( mS -- ) \ Suspend to idle, resume after mS. Can be 'stopSleeping'.
					[ last literal ] ( mS me )
					<js>
						function resume() { 
							if (!me.timeoutId) return; // 萬一想提前結束時其實已經 timeout 過了則不做事。
							delete(vm.g.setTimeout.registered()[me.timeoutId.toString()]);
							tib = tibwas; ntib = ntibwas; me.timeoutId = null;
							outer(ipwas); // resume to the below ending 'ret' and then go through the TIB.
						}
						var tibwas=tib, ntibwas=ntib, ipwas=ip, me=pop(), delay=pop();
						me.resume = resume; // So resume can be triggered from outside
						if (me.timeoutId) {
							panic("Error! double 'sleep' not allowed, use 'nap' instead.\n",true)
						} else {
							tib = ""; ntib = ip = 0; // ip = 0 reserve rstack, suspend the forth VM 
							me.timeoutId = vm.g.setTimeout(resume,delay);
						}
					</js> ;
					/// 為了要能 stopSleeping 引入了 sleep.timeoutId 致使多重 sleeping 必須禁止。
					/// 另設有不可中止的 nap 命令可以多重 nap.

	code stopSleeping ( -- ) \ Resume forth VM sleeping state, opposite of the sleep command.
					clearTimeout(tick('sleep').timeoutId);
					tick('sleep').resume();
					end-code

	: nap           ( mS -- ) \ Suspend to idle, resume after mS. Multiple nap is allowed.
					<js>
						var tibwas=tib, ntibwas=ntib, ipwas=ip, delay=pop();
						tib = ""; ntib = ip = 0; // ip = 0 reserve rstack, suspend the forth VM 
						// setTimeout(resume,delay);
						var timeoutId = vm.g.setTimeout(resume,delay);
						function resume() { 
							delete(vm.g.setTimeout.registered()[timeoutId.toString()]);
							tib = tibwas; ntib = ntibwas;
							outer(ipwas); // resume to the below ending 'ret' and then go through the TIB.
						}
					</js> ;
					/// nap 不用 vm.g.setTimeout 故不能中止，也不會堆積在 vm.g.setTimeout.registered() 裡。

	: cr            js: type("\n") ; // ( -- ) 到下一列繼續輸出 *** 20111224 sam
					\ 個別 quit.f 裡重定義成 : cr js: type("\n") 1 nap js: jump2endofinputbox.click() ;

	code [begin]	( -- ) \ [begin]..[again], [begin].. flag [until]
					rstack.push(ntib) end-code immediate
					/// Don't forget to put some nap.
					/// 'stop' command or {Ctrl-Break} hotkey to abort.
					/// ex. [begin] ." * " 250 nap [again]
					
	code [again]	( -- ) \ [begin]..[again]
					ntib=rtos() end-code immediate
					/// Don't forget to put some nap.
					/// 'stop' command or {Ctrl-Break} hotkey to abort.
					/// ex. [begin] ." * " 250 nap [again]

	code [until]	( flag -- ) \ [begin].. flag [until]
					if(pop()) rstack.pop(); else  ntib=rtos(); end-code immediate
					/// Don't forget to put some nap.
					/// 'stop' command or {Ctrl-Break} hotkey to abort.
					/// ex. [begin] <js> new Date()</jsV> dup . cr 50 mod not 100 nap [until]

	code [for]		( count -- , R: -- #tib count ) \ [for]..[next] 
					rstack.push(ntib); rstack.push(pop()); end-code immediate
					/// Pattern : The normalized for-loop pattern. 0 based.
					///   5 ?dup [if] dup [for] dup r@ - ( COUNT i ) . space ( COUNT ) [next] drop [then]
					///   ==> 0 1 2 3 4
					/// Pattern : Normalized for-loop pattern but n(66) based.
					///   5 js: push(tos()+66,0) [for] dup r@ - ( count+n i ) . space [next] drop
					///   ==> 66 67 68 69 70  OK 		
					/// Pattern : Simplest, fixed times.
					///   5 [for] r@ . space [next]
					///   ==> 5 4 3 2 1
					/// Pattern : fixed times and 0 based index
					///   5 [for] 5 r@ - . space [next]
					///   ==> 0 1 2 3 4
					/// Pattern of break : "r> drop 0 >r" or "js: rstack[rstack.length-1]=0"
					///   10 [for] 10 r@ - dup . space 5 >= [if] r> drop 0 >r [then] [next]
					///   ==> 0 1 2 3 4 5
					/// Don't forget to put some nap.
					/// 'stop' command or {Ctrl-Break} hotkey to abort.

	code [next]		( -- , R: #tib count -- #tib count-1 or empty ) \ [for]..[next]
					rstack[rstack.length-1] -= 1;
					if(rtos()>0){
						ntib=rtos(1);
					} else {
						rstack.pop(); // drop the count
						rstack.pop(); // drop the #tib rewind position
					}
					end-code immediate
					/// Don't forget to put some nap.
					/// 'stop' command or {Ctrl-Break} hotkey to abort.

	: jsc           ( -- ) \ JavaScript console usage: js: vm.jsc.prompt="111>>>";eval(vm.jsc.xt)
					cr ." J a v a S c r i p t   C o n s o l e" cr
					." @@@ under construction @@@" cr ;

	\ ------------------ Tools  ----------------------------------------------------------------------

	: int           ( float -- integer )
					js> parseInt(pop()) ;
	: random        ( -- 0~1 )
					js> Math.random() ;

	: nop           ; // ( -- ) No operation.
	: drops         ( ... n -- ... ) \ Drop n cells from data stack.
					1+ js> stack.splice(stack.length-tos(),pop()) drop ;
					/// We need 'drops' <js> sections in a colon definition are easily to have
					/// many input arguments that need to be dropped.

	\ JavaScript's hex is a little strange.
	\ Example 1: -2 >> 1 is -1 correct, -2 >> 31 is also -1 correct, but -2 >> 32 become -2 !!
	\ Example 2: -1 & 0x7fffffff is 0x7fffffff, but -1 & 0xffffffff will be -1 !!
	\ That means hex is 32 bits and bit 31 is the sign bit. But not exactly, because 0xfff...(over 32 bits)
	\ are still valid numbers. However, my job is just to print hex correctly by using .r and
	\ .0r. So I simply use a workaround that prints higher 16 bits and then lower 16 bits respectively.
	\ So JavaScript's opinion about hex won't bother me anymore.

	code .r         ( num|str n -- ) \ Right adjusted print num|str in n characters (FigTaiwan SamSuanChen)
					var n=pop(); var i=pop();
					if(typeof i == 'number') {
						if(vm.base == 10){
							i=i.toString(vm.base);
						}else{
							i = (i >> 16 & 0xffff || "").toString(vm.base) + (i & 0xffff).toString(vm.base);
						}
					}
					n=n-i.length;
					if(n>0) do {
						i=" "+i;
						n--;
					} while(n>0);
					type(i);
					end-code

	code .0r        ( num|str n -- ) \ Right adjusted print num|str in n characters (FigTaiwan SamSuanChen)
					var n=pop(); var i=pop();
					var minus = "";
					if(typeof i == 'number') {
						if(vm.base == 10){
							if (i<0) minus = '-';
							i=Math.abs(i).toString(vm.base);
						}else{
							i = (i >> 16 & 0xffff || "").toString(vm.base) + (i & 0xffff).toString(vm.base);
						}
					}
					n=n-i.length - (minus?1:0);
					if(n>0) do {
						i="0"+i;
						n--;
					} while (n>0);
					type(minus+i);
					end-code
					/// Limitation: Negative numbers are printed in a strange way. e.g. "0000-123".
					/// We need to take care of that separately.

	code dropall    stack=[] end-code // ( ... -- ) Clear the data stack.
	code (ASCII)    push(pop().charCodeAt(0)) end-code // ( str -- ASCII ) Get a character's ASCII code.
	code ASCII>char ( ASCII -- 'c' ) \ number to character
					push(String.fromCharCode(pop())) end-code
					/// 65 ASCII>char tib. \ ==> A (string)
	: ASCII         ( <str> -- ASCII ) \ Get a character's ASCII code.
					BL word (ASCII) compiling if literal then
					; immediate

	code .s         ( ... -- ... ) \ Dump the data stack.
					var count=stack.length, basewas=vm.base;
					if(count>0) for(var i=0;i<count;i++){
						if (typeof(stack[i])=="number") {
							push(stack[i]); push(i); dictate("decimal 7 .r char : . space dup decimal 11 .r space hex 11 .r char h .");
						} else {
							push(stack[i]); push(i); dictate("decimal 7 .r char : . space .");
						}
						type(" ("+mytypeof(stack[i])+")\n");
					} else type("empty\n");
					vm.base = basewas;
					end-code

	code (words)    ( "option" "word-list" "pattern" -- word[] ) \ Get an array of words, name/help/comments screened by pattern.
					// var RegEx = new RegExp(nexttoken(),"i");
					var pattern = pop(); // nexttoken('\n|\r'); // if use only '\n' then we get an unexpected ending '\r'.
					var word_list = words[pop()];
					var option = pop();
					var result = [];
					for(var i=1;i<word_list.length;i++) {
						if (!pattern) { result.push(word_list[i]); continue; }
						switch(option){ 
							// 這樣寫表示這些 option 都是唯一的。
							case "-t": // -t for matching type pattern, case insensitive.
								if (word_list[i].type.toLowerCase().indexOf(pattern.toLowerCase()) != -1 ) {
									result.push(word_list[i]);
								}
								break;
							case "-T": // -T for matching type pattern exactly.
								if (word_list[i].type==pattern) {
									result.push(word_list[i]);
								}
								break;
							case "-n": // -n for matching only name pattern, case insensitive.
								if (word_list[i].name.toLowerCase().indexOf(pattern.toLowerCase()) != -1 ) {
									result.push(word_list[i]);
								}
								break;
							case "-N": // -N for exactly name only, case sensitive.
								if (word_list[i].name==pattern) {
									result.push(word_list[i]);
								}
								break;
							default:
								var flag =  (word_list[i].name.toLowerCase().indexOf(pattern.toLowerCase()) != -1 ) ||
											(word_list[i].help.toLowerCase().indexOf(pattern.toLowerCase()) != -1 ) ||
											(typeof(word_list[i].comment)!="undefined" && (word_list[i].comment.toLowerCase().indexOf(pattern.toLowerCase()) != -1));
								if (flag) {
									result.push(word_list[i]);
								}
						}
					}
					push(result);
					end-code
					/// option: -n name , -N name

	: words         ( [<pattern>] -- ) \ List words of name/help/comments screened by pattern.
					"" char root char \n|\r word (words) <js>
						var word_list = pop();
						var w = "";
						for (var i=0; i<word_list.length; i++) w += word_list[i].name + " ";
						type(w);
					</js> ;
					/// Search the pattern in help and comments also.

	: (help)        ( "patther" -- ) \ Print help message of screened words
					js> tos().length if
						char root swap "" -rot (words) <js>
							var word_list = pop();
							for (var i=0; i<word_list.length; i++) {
								type(word_list[i].name + " " + word_list[i].help + "\n");
								if (typeof(word_list[i].comment) != "undefined") type(" "+word_list[i].comment+"\n");
							}
						</js>
					else
						<text>
							Enter          : Focus to the input box
							help <pattern> : Print help message of matched words
							see <word>     : See details of the word
							jsc            : JavaScript console
						</text> <js> pop().replace(/^[ \t]*/gm,'  ')</jsV> . cr
					then ;
					/// Original version
					/// Pattern matches name, help and comments.

	: help          ( [<pattern>] -- ) \ Print help message of screened words
					char \n|\r word (help) ;
					/// Original version
					/// Pattern matches name, help and comments.

	code bye        ( ERRORLEVEL -- ) \ Exit to shell with TOS as the ERRORLEVEL.
					// 這些都無效，最後靠 WMI 達成傳回 errorlevel // var errorlevel = pop(); window.errorlevel = typeof(errorlevel)=='number' ? errorlevel : 0; 
					vm.bye();
					end-code

	code tib.append ( "string" -- ) \ Append the "string" to TIB
					tib = tib.slice(ntib); ntib = 0;
					tib += " " + (pop()||""); end-code
					/// vm suspend-resume doesn't allow multiple levels of dictate() so
					/// we need tib.append or tib.insert.

					<comment>
						靠！ tib.append 沒辦法測呀！到了 terminal prompt 手動這樣測，
						OK 111 s" 12345" tib.append 222
						OK .s
							0:         111          6fh (number)
							1:         222          deh (number)
							2:       12345        3039h (number) <=== appended to the ending
					</comment>

	code tib.insert ( "string" -- ) \ Insert the "string" into TIB
					tib = tib.slice(ntib); ntib = 0;
					tib = (pop()||"") + " " + tib; end-code
					/// vm suspend-resume doesn't allow multiple levels of dictate() so
					/// we need tib.append or tib.insert.


	code memberCount ( obj -- count ) \ Get hash table's length or an object's member count.
					push(vm.g.memberCount(pop()));
					end-code

	code isSameArray ( a1 a2 -- T|F ) \ Compare two arrays.
					push(vm.g.isSameArray(pop(), pop()));
					end-code

	code (?)        ( a -- ) \ print value of the variable consider ret and exit
					var x = dictionary[pop()];
					switch(x){
						case null: type('RET');break;
						case "": type('EXIT');break;
						default: type(x);
					}; end-code

	: (dump)        ( addr -- ) \ dump one cell of dictionary
					decimal dup 5 .0r s" : " . dup (?) s"  (" . js> mytypeof(dictionary[pop()]) . s" )" . cr ;
	: dump          ( addr length -- addr' ) \ dump dictionary
					for ( addr ) dup (dump) 1+ next ;
	: d             ( <addr> -- ) \ dump dictionary
					[ last literal ]
					BL word                     \ (me str)
					count 0=                    \ (me str undef?) No start address?
					if                          \ (me str)
						drop                    \ drop the undefined  (me)
						js> tos().lastaddress   \ (me addr)
					else                        \ (me str)
						js> parseInt(pop())     \ (me addr)
					then ( me addr )
					20 dump                         \ (me addr')
					js: pop(1).lastaddress=pop()
					;

	code (see)      ( thing -- ) \ See into the given word, object, array, ... anything.
					var w=pop();
					var basewas = vm.base; vm.base = 10;
					if (!(w instanceof Word)) {
						vm.g.see(w);  // none forth word objects. 意外的好處是不必有 "unkown word" 這種無聊的錯誤訊息。
					}else{
						for(var i in w){
							if (typeof(w[i])=="function") continue;
							if (i=="comment") continue;
							push(i); dictate("16 .r s'  : ' .");
							type(w[i]+" ("+mytypeof(w[i])+")\n");
						}
						if (w.type.indexOf("colon")!=-1){
							var i = w.cfa;
							type("\n-------- Definition in dictionary --------\n");
							do {
								push(i); execute("(dump)");
							} while (dictionary[i++] != RET);
							type("---------- End of the definition -----------\n");
						} else {
							for(var i in w){
								if (typeof(w[i])!="function") continue;
								// if (i=="selfTest") continue;
								push(i); dictate("16 .r s'  :\n' .");
								type(w[i]+"\n");
							}
						}
						if (w.comment != undefined) type("\ncomment:\n"+w.comment+"\n");
					}
					vm.base = basewas;
					end-code
	: see           ' (see) ; // ( <name> -- ) See definition of the word

	\ -------------- Forth Debug Console -------------------------------------------------

	js> inner constant fastInner // ( -- inner ) Original inner() without breakpoint support
	code bp         ( <address> -- ) \ Set breakpoint in a colon word. See also 'db' command.
					bp = parseInt(nexttoken()); inner = vm.g.debugInner; end-code
					/// work with 'jsc' debug console, jsc is application dependent.
	code db         ( -- ) \ Disable breakpoint, inner=fastInner. See also 'bp' command.
					inner = vm.g.fastInner end-code
					/// work with 'jsc' debug console, jsc is application dependent.
					
	: (*debug*)     ( msg -- resume ) \ Suspend to command prompt, execute resume() to quit debugging.
					<js>
						var tibwas=tib, ntibwas=ntib, ipwas=ip, promptwas=vm.prompt;
						vm.prompt = pop().toString();
						push(resume); // The clue for resume
						tib = ""; ntib = ip = 0; // ip = 0 reserve rstack, suspend the forth VM 
						function resume(){tib=tibwas; ntib=ntibwas; vm.prompt=promptwas;outer(ipwas);}
					</js> ;
					/// resume() 線索由 data stack 傳回，故可以多重 debug。但有何用途？
					
	: *debug*       ( <prompt> -- resume ) \ Forth debug console. Execute the resume() to quit debugging.
					BL word compiling if literal compile (*debug*) 
					else (*debug*) then ; immediate
					/// resume() 線索由 data stack 傳回，故可以多重 debug。但有何用途？

</kernel> <js> g.k.dictate(pop())</js>

