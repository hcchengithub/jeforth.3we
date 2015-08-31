"uses strict";
function KsanaVM() {     
	var vm = this;
	var ip=0;
	var stack = [] ;
	var stackwas = []; // Definition of : ... ; needs a temp storage.
	var rstack = [];
	var vocs = [];
	var words = [];
	var current = "forth";
	var context = "forth";
	var order = [context];
	var wordhash = {};
	var dictionary=[]; dictionary[0]=0;
	var here=1;
	var tib="";
	var ntib=0;
	var RET=null; // The 'ret' instruction code. It marks the end of a colon word.
	var EXIT=""; // The 'exit' instruction code.
	var compiling=false;
	var stop = false; // Stop the outer loop
	var newname = ""; // new word's name
	var newxt = function(){}; // new word's function()
	var newhelp = "";
	var type = function(){}; // dummy 
	var g = {}; // global hash

	vm.init = function () { 
		type = vm.type;
	}
	
	function Word(a) {
		this.name = a.shift();  // name and xt are mandatory
		this.xt = a.shift();
		var statement;
		while(statement=a.shift()) {  // extra arguments are statement strings
			eval(statement);
		}
	}
	Word.prototype.toString = function(){return this.name + " " + this.help}; // every word introduces itself
	
	// Support Vocabulary
	function last(){  // returns the last defined word.
		return words[current][words[current].length-1];
	}
	function current_word_list(){  // returns the word-list where new defined words are going to
		return words[current];
	}
	function context_word_list(){  // returns the word-list that is searched first.
		return words[context];
	}
	
	// Reset the forth VM
	function reset(){
		// stack = []; don't clear it's a clue for debug
		rstack = [];
		dictionary[0]=0; // dictionary[0]=0 reserved for inner() as its terminator
		compiling=false;
		ip=0; // forth VM instruction pointer
		stop = true; // ntib = tib.length; // reserve tib and ntib for debug
		type('-------------- Reset forth VM --------------\n');
	}
	
	function panic(msg,severe) {
		var t='';
		if(compiling) t += '\n------------- Panic! while compiling '+newname+' -------------\n';
		else t +=          '\n------------------- P A N I C ! -------------------------\n';
		t += msg;
		t += "stop: " + stop +'\n';
		t += "compiling: " + compiling +'\n';
		t += "stack.length: " + stack.length +'\n';
		t += "rstack.length: " + rstack.length +'\n';
		t += "ip: " + ip +'\n';
		t += "ntib: " + ntib + '\n';
		t += "tib.length: " + tib.length + '\n';
		var beforetib = tib.substr(Math.max(ntib-40,0),40);
		var aftertib  = tib.substr(ntib,80);
		t += "tib: " + beforetib + "<ntib>" + aftertib + "...\n";
		type(t);
		if(compiling) {
			compiling = false;
			stop = true; // ntib = tib.length;
		}
		if(severe) // switch to JavaScript console, if available, for severe issues.
			if(tick("jsc")) {
				dictate("jsc");
			}
	}

	// Get string from recent ntib down to, but not including, the next delimiter.
	// Return {str:"string", flag:boolean}
	// If delimiter is not found then return the entire remaining TIB, multi-lines, through result.str。
	// result.flag indicates delimiter found or not found.
	// o  If you want to read the entire TIB string, use nexttoken('\n|\r'). It eats the next 
	//    white space after ntib. If use nextstring('\n|\r') then the leading white space(s) is included.
	// o  If you need to know whether the delimiter is found, use nextstring()。
	// o  result.str is "" if TIB has nothing left.
	// o  The ending delimiter is remained. 
	// o  The delimiter is a regular expression.
	function nextstring(deli){
		var result={}, index;
		index = (tib.substr(ntib)).search(deli);  // search for delimiter in tib from ntib
		if (index!=-1) {   // delimiter found
			result.str = tib.substr(ntib,index);  // found, index is the length
			result.flag = true;
			ntib += index;  // Now ntib points at the delimiter.
		} else { // delimiter not found.
			result.str = tib.substr(ntib);  // get the tib from ntib to EOL
			result.flag = false;
			ntib = tib.length; // skip to EOL
		}
		return result;
	}
	
	// Get next token which is found after the recent ntib of TIB.
	// If delimiter is RegEx white-space ('\\s') or absent then skip all leading white spaces first, 
	// otherwise, only skip the first character which should be a white space.
	// o  Return "" if TIB has nothing left. 
	// o  Return the remaining TIB if delimiter is not found.
	// o  The ending delimiter is remained. 
	// o  The delimiter is a regular expression.
	function nexttoken(deli){
		if (arguments.length==0) deli='\\s';   // whitespace
		if (deli=='\\s') skipWhiteSpaces(); else ntib += 1; // Doesn't matter if already at end of TIB. 
		var token = nextstring(deli).str;
		return token; 
		function skipWhiteSpaces(){  // skip all white spaces at tib[ntib]
			var index = (tib.substr(ntib)).search('\\S'); // Skip leading whitespaces. index points to next none-whitespace.
			if (index == -1) {  // \S not found, entire line are all white spaces or totally empty
				ntib = tib.length;
			}else{
				ntib += index ; // skip leading whitespaces
			}
		}
	}
	
	// tick() is same thing as forth word '。 
	// Let words[voc][0]=0 also means tick() return 0 indicates "not found".
	// Return the word obj of the given name or 0 if the word is not found.
	function tick(name) {
		return wordhash[name] || 0;  // 0 means 'not found'
	}
	
	// Return a boolean.
	// Is the new word reDef depends on only the words[current] word-list, not all 
	// word-lists, nor the word-hash table. Can't use tick() because tick() searches 
	// the word-hash that includes not only the words[current] word-list.
	function isReDef(name){
		var result = false;
		var wordlist = current_word_list();
		for (var i in wordlist)
			if (wordlist[i].name == name) {
				result = true;
				break;
			}
		return result;
	}
	
	// comma(x) compiles anything into dictionary[here]. x can be number, string, 
	// function, object, array .. etc。
	// To compile a word, comma(tick('word-name'))
	function comma(x) {
		dictionary[here++] = x;
		dictionary[here] = RET;  // dummy
		// [here] will be overwritten, we do this dummy because 
		// RET is the ending mark for 'see' to know where to stop. 
	}
	
	// 討論一下：
	// jeforth 裡 address 與 ip 最後都拿來當 dictionary[] 的 index 用。 address 或 ip 其實
	// 是 dictionary[] 的 index。
	
	// 把所有不同版本的 call() dolist() execute() runcolon() runFunc() 等等都整合成 execute(w)
	// 或 inner(entry), 前者只執行一個 word, 後者沿著 ip 繼續跑. The w can be word
	// object, word name, a function; while entry is an address。
	
	// execute() 類似 CPU instruction 的 single step, 而 inner() 類似 CPU 的 call 指令。
	// 會用 到 inner() 的有 outer() 以及 colon word 的 xt(), 而 execute() 則到處有用。 
	
	// 從 code word 裡 call forth word 的方法有 execute('word') 與 dictate('word word word')
	// 加上 inner(cfa) 三種方法可供選擇。dictate() 暫時岔開一層 outer loop, 於其中
	// 只看到臨時的 TIB 也就是 dictate() 的 input string。

	// 最終極的 inner loop 是由 while(w){ip++; w.xt(); w=dictionary[ip]}; 以及 return 時的
	// ip=rstack.pop(); 組成。只要用具有 false 邏輯屬性的東西來當 ret 以及 exit 就可以滿足。
	// 共有 null, "", false, NaN, undefined, and 0 六種可供選擇。任選 RET=null, EXIT=""。

	// Suspend VM 時，要中止所有的 inner loop 但不 pop return stack 以待 resume 時恢復執行。
	// dictionary[0] 以及 words[<vid>][0] 都固定放 0, 就是要造成 ip=w=0 代表這情形。從 outer 
	// loop 剛進入 inner loop 之時要先 push(0) 進 return stack 如此既 balance return stack 又
	// 讓 0 來扮演這個特殊目的。當 inner loop 在 unbalanced 的情況下撞到 ip=rstack.pop(); where
	// ip is 0 即進入 suspend 程序，保留剩下的 unbalanced rstack 供 debug 參考。
	
	// -------------------- ###### The inner loop ###### -------------------------------------

	// 整理各種不同種類的 entry 翻譯成恰當的 w. 
	// phaseA() 不在 major inner() loop 裡, 不怕花時間。
	function phaseA (entry) { 
		var w = 0; 
		switch(typeof(entry)){
			case "string": // "string" is word name
				w = tick(entry.replace(/(^( |\t)*)|(( |\t)*$)/g,'')); // remove 頭尾 whitespaces
				break;
			case "function": case "object": // object is a word
				w = entry; 
				break;
			case "number": 
				// number could be dictionary entry or 0. 
				// 可能是 does> branch 的 entry 或 ret exit rstack pop 出來的。
				ip = entry;
				w = dictionary[ip]; 
				break;
			default :
				panic("Error! execute() doesn't know how to handle this thing : "+entry+" ("+mytypeof(entry)+")\n","severe");
		}
		return w;
	}

	// 針對不同種類的 w 採取正確方式執行它。
	function phaseB (w) { 
		switch(typeof(w)){
			case "number":  
				// 看到 number 通常是 does> 的 entry, 
				// 不能用 inner() 去 call， 否則會是個不易發現的 bug!!
				// 以下用 push-jump 模擬 call instruction.
				rstack.push(ip); // Forth 的 ip 是「下一個」要執行的指令，亦即 return address.
				ip = w; // jump
				break;
			case "function": 
				w();
				break;
			case "object": // Word object
				try { // 自己處理 JavaScript errors 以免動不動就被甩出去.
					w.xt();
				} catch(err) {
					panic('JavaScript error on word "'+w.name+'" : '+err.message+'\n',"error");
				}
				break;
			default :
				panic("Error! don't know how to execute : "+w+" ("+mytypeof(w)+")\n","error");
		}
	}

	function execute(entry) { 
		var w; 
		if (w = phaseA(entry)){
			if(typeof(w)=="number") panic("Error! please use inner("+w+") instead of execute("+w+").\n","severe");
			else phaseB(w); 
		}
	}

	function inner (entry, resuming) {
		var w = phaseA(entry); // 翻譯成恰當的 w.
		do{
			while(w) {
				ip++; // Forth 的通例，inner loop 準備 execute 這個 word 之前，IP 先指到下一個 word.
				phaseB(w); // 針對不同種類的 w 採取正確方式執行它。
				w = dictionary[ip];
			}
			if(w===0) break; // w==0 is suspend, break inner loop but reserve rstack. Inner loop 未完半途離開。
			else ip = rstack.pop(); // w is either ret(NULL) or exit(""). 準備 return 了。
			if(resuming) w = dictionary[ip]; // 正常的上層 inner() 都已經被 suspend 結束掉了，resume 要自己補位。
		} while(ip && resuming); // Resuming inner loop. ip==0 means resuming has done。
	}
	// ### End of the inner loop ###

	// -------------------------- the outer loop ----------------------------------------------------
	// forth outer loop, 
	// If entry is given then resume from the entry point by executing 
	// the remaining colon thread down until ip reaches 0. That's resume.
	// Then proceed with the tib/ntib string.
	// 
	function outer(entry) {
		if (entry) inner(entry, true); // resume from the breakpoint 
		while(!stop) {
			var token=nexttoken();
			if (token==="") break;    // TIB 收完了， loop 出口在這裡。
			outerExecute(token);
		}
		// 單處理一個 token. 
		function outerExecute(token){
			var w = tick(token);   // not found is 0. w is an Word object.
			if (w) {
				if(!compiling){ // interpret state or immediate words
					if (w.compileonly) {
						panic("Error! "+token+" is compile-only.\n", tib.length-ntib>100);
						return;
					}
					execute(w);
				} else { // compile state
					if (w.immediate) {
						execute(w); // inner(w);
					} else {
						if (w.interpretonly) {
							panic("Error! "+token+" is interpret-only.\n", tib.length-ntib>100);
							return;
						}
						comma(w); // 將 w 編入 dictionary. w is a Word() object
					}
				}
			} else if (isNaN(token)) {
				// parseInt('123abc') 的結果是 123 很危險! 所以前面要用 isNaN() 先檢驗。		
				panic("Error! "+token+" unknown.\n", tib.length-ntib>100);
				return;
			} else {
				if(token.substr(0,2).toLowerCase()=="0x") var n = parseInt(token);
				else  var n = parseFloat(token);
				push(n);
				if (compiling) execute("literal");
			}
		}
	}
	// ### End of the outer loop ###
	
	// code ( -- ) Start to compose a code word. docode() is its run-time.
	// "( ... )" and " \ ..." on first line will be brought into this.help.
	// jeforth.js kernel has only two words, 'code' and 'end-code', jeforth.f
	// will be read from a file that will be a big TIB actually. So we don't 
	// need to consider about how to get user input from keyboard! Getting
	// keyboard input is difficult to me on an event-driven or a non-blocking 
	// environment like Node-webkit.
	function docode() {
	    // 將來所有的 code words 都會認得這裡的 local variables 所以這裡面要避免
		// 用到任何 local variable。 外面的 vm global variables & functions 當然都認得。
		compiling = "code"; // it's true and a clue of compiling a code word.
		newname = nexttoken();
		if(isReDef(newname)) type("reDef "+newname+"\n"); 	// 若用 tick(newname) 就錯了
		push(nextstring("end-code")); 
		if(tos().flag){
			eval(
				'newxt=function(){ /* ' + newname + ' */\n' + 
				pop().str + '\n}' // the ending "\n}" allows // comment at the end
			);
		} else {
			panic("Error! expecting 'end-code'.\n");
			reset();
		}
	}
	
	words[current] = [
		0,  // 令 current_word_list()[0] == 0 有很多好處，當 tick() 
			// 傳回 0 時 current_word_list()[0] 正好是 0, 直接意謂失敗。tick ' 的定義也簡單。
		new Word([
			"code",
			docode,
			"this.vid='forth'",
			"this.wid=1",
			"this.type='code'",
			"this.help='( <name> -- ) Start composing a code word.'",
			"this.selftest='pass'"
		]),
		new Word([
			"end-code",
			function(){
				if(compiling!="code"){ panic("Error! 'end-code' to a none code word.\n"); return};
				current_word_list().push(new Word([newname,newxt]));
				last().vid = current;
				last().wid = current_word_list().length-1;
				last().type = 'code';
				last().help = newhelp;
				wordhash[last().name]=last();
				compiling  = false;
			},
			"this.vid='forth'",
			"this.wid=2",
			"this.type='code'",
			"this.immediate=true",
			"this.compileonly=true",
			"this.help='( -- ) Wrap up the new code word.'"
		])
	];
	
	// 用 JavaScript 的十成功力來找 word。
	wordhash = {"code":current_word_list()[1], "end-code":current_word_list()[2]};
	
	// -------------------- main() ----------------------------------------

	// Recursively evaluate the input. 
	// The input can be multiple lines or an entire ~.f file but
	// it usually is the TIB.
	function dictate(input) {
		var tibwas=tib, ntibwas=ntib, ipwas=ip;
		tib = input; 
		ntib = 0;
		stop = false; // stop 是給 outer loop 看的，這裡要先清除。
		outer();
		tib = tibwas;
		ntib = ntibwas;
		ip = ipwas;
	}
	vm.dictate = dictate;

	// -------------------- end of main() -----------------------------------------

	// Top of Stack access easier. ( tos(2) tos(1) tos(void|0) -- ditto )
	// tos(i,new) returns tos(i) and by the way change tos(i) to new value this is good
	// for counting up or down in a loop.
	function tos(index,value) {	
		switch (arguments.length) {
			case 0 : return stack[stack.length-1];
			case 1 : return stack[stack.length-1-index];
			default : 
				var data = stack[stack.length-1-index]
				stack[stack.length-1-index] = value; 
				return(data); 
		}
	}

	// Top of return Stack access easier. ( rtos(2) rtos(1) rtos(void|0) -- ditto )
	// rtos(i,new) returns rtos(i) and by the way change rtos(i) to new value this is good
	// for counting up or down in a loop.
	function rtos(index,value) {	
		switch (arguments.length) {
			case 0 : return rstack[rstack.length-1];
			case 1 : return rstack[rstack.length-1-index];
			default : 
				var data = rstack[rstack.length-1-index]
				rstack[rstack.length-1-index] = value; 
				return(data); 
		}
	}

	// Stack access easier. e.g. pop(1) gets tos(1) and leaves ( tos(2) tos(1) tos(void|0) -- tos(2) tos(void|0) )
	function pop(index) {	
		switch (arguments.length) {
			case 0  : return stack.pop();
			default : return stack.splice(stack.length-1-index, 1)[0];
		}
	}

	// Stack access easier. e.g. push(data,1) inserts data to tos(1), ( tos2 tos1 tos -- tos2 tos1 data tos )
	function push(data, index) { 
		switch (arguments.length) {
			case 0  : 	panic(" push() what?\n");
			case 1  : 	stack.push(data); 
						break;
			default : 	if (index >= stack.length) {
							stack.unshift(data);
						} else {
							stack.splice(stack.length-1-index,0,data);
						}
		}
	}

	// typeof(array) and typeof(null) are "object"! So a tweak is needed.
	function mytypeof(x){
		var type = typeof x;
		switch (type) {
		case 'object':
			if (!x) type = 'null';
			if (Object.prototype.toString.apply(x) === '[object Array]') type = "array";
		}
		return type;
	}
	// js> mytypeof([])           \ ==> array (string)
	// js> mytypeof(1)            \ ==> number (string)
	// js> mytypeof('a')          \ ==> string (string)
	// js> mytypeof(function(){}) \ ==> function (string)
	// js> mytypeof({})           \ ==> object (string)
	// js> mytypeof(null)         \ ==> null (string)  

	vm.stack = function(){return(stack)}; // debug easier. stack 常被改，留在 vm 裡可能是舊版，所以要隨時從肚子裡抓。
	vm.rstack = function(){return(rstack)}; // debug easier especially debugging TSR
	vm.words = words; // debug easier
	vm.dictionary = dictionary; // debug easier
}
if (typeof exports!='undefined') exports.KsanaVM = KsanaVM;	// export for node.js APP

