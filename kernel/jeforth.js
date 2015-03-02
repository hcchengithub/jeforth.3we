/*  UTF-8

	=== jeforth 簡介 ===

    2011/12/23  jeforth initial version http://www.jeforth.com by FigTaiwan 爽哥 & Yap.
	本來是用 WWW browser 執行的，以操作 HTML5 為範例，用來推廣 forth，非常簡潔優美。

	我把它 port 到 node-webkit 下執行，以便享有現代新程式的好處。 Forth 天生是個管理大量
	命令的最佳工具，也是與電腦溝通的語法中最簡單的。我們要電腦做的事，本來只有兩句話，用
	其他語言表達經常會變成一整頁。而 forth 的語法最自由，兩句話就是兩句話。


	=== Resources ===

	o  jeforth for WSH source code http://fossilrepos.sourceforge.net/srv.fsl/0/jeforth

	o  jeforth 前身為 http://tutor.ksana.tw/ksanavm 用 C 語言實現 forth 的方法之精彩教
	   材「剎那極簡虛擬機」 by Yap

	o  Yap 講解 jeforth 精彩課程 http://www.jeforth.com/demo.html 感謝 王建鋒 的網站

	o  超精彩的 waterbear 圖形積木介面 jeforth http://jforthblocks.appspot.com/static/code/index_tw.html
       by Jimmy的爸.

	o  http://www.figtaiwan.org FigTaiwan 臺灣符式推廣協會

	=== revision log ===
	
	hcchen5600 2013/08/31 12:25:42 r1 jeforth kernel that has only two words 'code' and 'end-code'.
	hcchen5600 2013/10/03 15:19:26 r4 jQuery-terminal works fine now.
	
*/
"uses strict";
var kvm = (function(){
    function KsanaVm() {     
		var vm = this; // "this" is very confusing to me. Now I am sure 'vm' is 'kvm'.
		if(typeof(kvm)=="undefined"){var kvm=vm} // kvm defined in jeforth.hta is visible but not node.js index.js
		var ip=0; // forth VM instruction pointer
		var stack = [] ;
		var rstack = [];
		var bp=0; // [Secondary return stack pointer in local.f] Breakpoint for jsc debugger.
		var stackwas = []; // Definition of : ... ; needs a temp storage.
		var words = {forth:[]}; // VID vocabulary id "forth" 是原始的 word list. 終端 index 是 WID word ID. forth word 可以 reDef 全在這 array 裡面。每一格都是一個 word object。
		var current = "forth"; // The current word-list new words are going to.
		var context = "forth"; // The word list that is searched first.
		var order = [context]; // The order[order.length-1] word-list is searched first.
		var wordhash = {}; // 利用 JavaScript innate hash table 來用 word name 找出 word object. words[vid][] 與 wordhash{} 相依，但 words[vid][] 會有 reDef 重複的 word, 而 hash table 裡新的會把舊的蓋掉。
		var dictionary=[]; dictionary[0]=0; // dictionary[0]=0 reserved for inner() as its terminator
		var here=1;      // dictionary[here] 
		var tib="";      // terminal input buffer
		var ntib=0;      // index of the TIB
		var RET=null; // The 'ret' instruction code. It marks the end of any colon word.
		var EXIT=""; // The 'exit' instruction code.
		var newname = ""; // new word's name
		var newxt = function(){}; // new word's function()
		var newhelp = ""; // new word's help message.
		var colonxt = function(){}; // colon word's xt function is a constant
		var compiling=false;
		var abortexec=false; // abort outer loop
		// var suspendContext = {tib:"", ntib:0, ip:0}; // Save-restore for Blocking I/O
		// var recentcolonword={}; use "[ last ] literal" or " [ js> last().cfa ] literal" instead
		// var debug = false; move to index.html for easier reachable when working with Chrome debugger.
		var print = function(){}; // dummy 
		// var global; 改用 kvm 了。
		// Initialize KsanaVM
		vm.init = function () { 
			print = kvm.print;
		}
		
		// 這個 Word() constructor 是所有 forth word 共通的，中間的 extra statements 
		// 使個別的 word 可以自由擴充零件。
		function Word(a) {
			this.name = a.shift();  // name and xt are mandatory
			this.xt = a.shift();
		
			// extra statements
			var statement;
			while(statement=a.shift()) {  // extra arguments are statement strings
				eval(statement);
			}
			// wordhash[this.name] = this;  // hash table, quickly finds word. 不該在這裡做--hcchen5600 2014/10/05 10:53:06 
		}
		Word.prototype.toString = function(){return this.help}; // 簡單這樣一行，每個 word 都會自我介紹了
		
		// To support Vocabulary, 原來直接用 words[] 的地方都要用間接的方式。
		function last(){  // returns the newly defined word.
			return words[current][words[current].length-1];
		}
		function current_word_list(){  // returns the word-list where new defined words are going to
			return words[current];
		}
		function context_word_list(){  // returns the word-list that is searched first.
			return words[context];
		}

		// 這個 Constant() constructor 是所有 常數 共通的，等於傳統 doLit 的位置。
		// doLit 廣用於 machine code 原生的 forth。 jeforth 直接放 constant object.
		function Constant(n) {
			this.value = n;
		}
		Constant.prototype.xt = function(){push(this.value)};
		Constant.prototype.toString = function(){
			var description;
			switch (typeof(this.value)){
				case "number":
					description = this.value+"\t(literal)";
					break
				default:  // constant is either number or string
					description = '"'+this.value+'"\t(literal)';
					break
			}
			return (description);
		};
		
		
		// Reset the forth VM
		function reset(){
			// stack = [] ;
			rstack = [];
			dictionary[0]=0; // dictionary[0]=0 reserved for inner() as its terminator
			compiling=false;
			ip=0; // forth VM instruction pointer
			// tib = "\\s";  stop loading if is panic during an including
			ntib = tib.length; // skip the remaining outer loop equals to stop including 
			abortexec=true;  // 讓 forth 自己來清
			debug = false;
			print('-------------- Reset forth VM --------------\n');
		}
		// vm.reset = reset;
		
		function panic(msg,severity) {
			var t='';
			if(compiling) t += '\n------------- Panic! while compiling '+newname+' -------------\n';
			else t +=          '\n------------------- P A N I C ! -------------------------\n';
			t += msg;
			t += "abortexec: " + abortexec +'\n';
			t += "compiling: " + compiling +'\n';
			t += "stack.length: " + stack.length +'\n';
			t += "rstack.length: " + rstack.length +'\n';
			t += "ip: " + ip +'\n';
			t += "ntib: " + ntib + '\n';
			t += "tib.length: " + tib.length + '\n';
			var beforetib = tib.substr(Math.max(ntib-40,0),40);
			var aftertib  = tib.substr(ntib,80);
			t += "tib: " + beforetib + "<ntib>" + aftertib + "...\n";
			print(t);
			if(compiling) {
				compiling = false;
				ntib = tib.length;
			}
			if(severity) // switch to JavaScript console, if available, for severe issues.
				if(tick("jsc")) {
					if(compiling) fortheval("[ jsc ]");
					else fortheval("jsc");
				}
		}
		vm.panic = panic;

		// Get string from recent ntib down to, but not including, the next delimiter.
		// 若 delimiter 沒找到，就把剩下的 TIB (可跨行！) 都收下來傳回 result.str。
		// 為了掌握 delimiter 是否有找到的兩種情況，傳回一個 result.flag 以表達之。
		// 注意！Delimiter remained. It's a regular expression. 
		// o  return {str:"string", flag:boolean}
		// o  要讀一整行時，用 nexttoken('\n|\r') 因會它會處理掉前一個 token 之後
		//    的 white space，若用 nextstring('\n|\r') 就會多出一個前置的 white space.
		// o  有需要知道 delimiter 有沒有找到的場合，才會用到 nextstring()。
		// o  result.str is "" if TIB has nothing left. result.flag indicates if delimiter found.
		// o  Return the remaining TIB if delimiter is not found. (TIB 被吃光了，因此後續問題自動消失)
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
		// If delimiter is RegEx white-space ('\\s') or absent then skip leading white spaces first, 
		// otherwise, only skip the first character (it must be a white-space after any
		// token). 
		// o  Return "" if TIB has nothing left. 
		// o  Return the remaining TIB if delimiter is not found. (因此後續問題不必多看)
		// o  The ending delimiter is remained. 
		// o  The delimiter is a regular expression.
		function nexttoken(deli){
			if (arguments.length==0) deli='\\s';   // whitespace
			if (deli=='\\s') skipWhiteSpaces(); else ntib += 1; // Doesn't matter if already at end of TIB. 
			var token = nextstring(deli).str;
			return token; 
			function skipWhiteSpaces(){  // skip all white spaces at tib[ntib]
				var index = (tib.substr(ntib)).search('\\S'); // Skip leading whitespaces. index points to next none-whitespace. 注意！working string 是以 ntib 為 0 點的 TIB.
				if (index == -1) {  // \S not found, entire line are all white spaces or totally empty
					ntib = tib.length;
				}else{
					ntib += index ; // skip leading whitespaces
				}
			}
		}
		
		// findword() 正名為 tick() 以與 forth ' 同名。 
		// 令 words[0]=0 之後，即可令 tick() 以傳回 0 表示 not found. hcchen5600 2012/01/25 00:55:23
		// Return the word obj of the given name or 0 if the word is not found.
		// 充分利用 JavaScript hash table 的功效，讓 tick() 直接傳回 word object. WID 完全不用了。
		function tick(name) {
			return (wordhash[name]) ? wordhash[name] : 0;  // 0 means 'not found'
		}
		vm.tick = tick;
		
		// Return a boolean.
		// Is the new word reDef depends on only the words[current] word-list, not all 
		// word-lists, nor the word-hash table.
		// can't use isMember() because we don't have current word names in an array.
		// can't use tick() either because tick() searches the word-hash that the meaning
		// is not suitable for isReDef().
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
		
		// Compile 進 dictionary[] 的東西 n 可以是數字,字串,function,object,array .. etc 超厲害的。
		// 不管是什麼，都只佔 dictionary[] 一格。這麼一來 here++ 還是「指向下一 cell」的意義。
		function dictcompile(n) {
			dictionary[here++] = n;
			dictionary[here] = RET;  // [here] will be overwritten, we do this dummy 
										// Because RET is the ending mark for ((see)) to know where to stop. 
		}
		
		// 將 word 編入 dictionary. word can be word name(string) or word obj.
		// wid is obsoleted. Use dictcompile() to compile an entry address.
		function compilecode(word){
			dictcompile(arguments.callee.cases[typeof(word)](word));
		}
		compilecode.cases = {};
		compilecode.cases["string"] = function(word){return tick(word)}; // word name to word object
		compilecode.cases["object"] = function(word){return word};       // assume it's a word object
		
		// 討論一下：
		// jeforth 裡 address 與 ip 最後都拿來當 dictionary[] 的 index 用。 address 或 ip 其實
		// 是 dictionary[] 的 index。
		
		// 把所有不同版本的 call() dolist() execute() runcolon() 等等都整合成 execute(w)
		// 或 inner(entry), 前者只執行一個 word, 後者沿著 ip 繼續跑. The w can be word
		// object, word name, a function, or an dictionary entry。[panic for other inputs]
		
		// execute() 類似 CPU instruction 的 single step, 而 inner() 類似 CPU 的 call 指令。
		// 會用 到 inner() 的有 outer() 以及 colon word 的 xt(), 而 execute() 則到處有用。 
		
		// 從 code word 裡 call forth word 的方法有 execute('word') 與 fortheval('word word word')
		// 加上後來發現的 inner(cfa) 三種方法可供選擇。fortheval() 暫時岔開一層 outer loop, 於其中
		// 只看到臨時的 TIB 也就是 fortheval() 的 input string。

		// 本來 wid 與 entry point address 無法分辨，自從把 wid 改成 Word() object 以後，這
		// 個問題已經不存在了。 jeforth.wsh v1.02 版以後 WID 確定完全沒有用，here 從 10000
		// 開始這個辦法也用不著了。
		
		// 最終極的 inner loop 是 while(w){ip++; w.xt(); w=dictionary[ip]}; ip=rstack.pop(); 只
		// 要用具有 false 邏輯屬性的東西來當 ret 以及 exit 就可以滿足。 共有 null, '', false, 
		// NaN and undefined 可供選擇(0 另有用途如下述)。jeforth.js 裡用 RET=null, EXIT="" 來指定。

		// Suspend VM 時，要中止所有的 inner loop 但不 pop retuurn stack 以待 resume 時恢復執行。
		// dictionary[0] 以及 words[<vid>][0] 都固定放 0, 就是要造成 w=0 來達到這個效果。從 outer 
		// loop 剛進入 inner loop 之時要先 push(0) 進 return stack 如此既 balance return stack 又
		// 讓 0 來扮演這個特殊目的。

		// hcchen5600 2015/03/01 10:30:37 過去的設計有問題！當前這個 word 執行到 ret 時只做 
		// ip=rstack.pop() 則本 inner() 有新 ip 可執行還是會繼續執行，不會結束。 等於是接手上層 
		// inner() 未完成的工作又鑽一層下去，增加 inner() 的層數最後有可能爆掉 JavaScript interpreter。
		// 這個過程要等到 ret 或 exit rstack.pop() 出 0 才會整個一起終了。這造成我稱為 deep inner 
		// loop 的問題!! 我曾經引進 endinner flag 讓 ret, exit, doVar, does> 等這些東西自己發出 
		// colon word 該結束了的明確信號。這等於是又倒回 Yap 原版用 abortexec的辦法，失去 w=0 的意義。
		// 如今 RET=null, EXIT="" 的辦法終於圓滿。
		
		// ----------------------------- the inner loop -------------------------------------------------
		function phaseA (entry) { // 整理各種不同種類的 entry 翻譯成恰當的 w.
			var w = 0; 
			switch(typeof(entry)){
				// case "undefined": 
				// 	w = last(); // call the last word when entry is absent.
				// 	break;
				case "string": // "string" is word name
					w = tick(entry.replace(/(^( |\t)*)|(( |\t)*$)/g,'')); // remove 頭尾 whitespaces
					break;
				case "function": case "object":
					w = entry; 
					break;
				case "number": 
					// number could be dictionary entry or 0. 
					// 可能是 does> branch 等的或 ret exit rstack pop 出來的。
					ip = entry; // inner() 會在 phaseA() 與 phaseB() 之間 ip++ 這裡預先迎合。
					w = dictionary[ip]; 
					break;
				default :
					panic("Error! execute() doesn't know how to handle this thing : "+entry+" ("+mytypeof(entry)+")\n","error");
			}
			return w;
		}

		function phaseB (w) { // 針對不同種類的 w 採取正確方式執行它。
			switch(typeof(w)){
				case "number":  // 看到 number 一定是 does> 的 entry,用 push-jump 模擬 call instruction.
								// 若用 inner() 去 call 則是個不易發現的 bug!!
					rstack.push(ip); // Forth 認為 ip 是「下一個」要執行的指令。
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
			var w = phaseA(entry); 
			if(typeof(w)=="number") panic("Error! don't know how to execute : "+entry+" ("+mytypeof(entry)+")\n","error");
			else phaseB(w); 
		}
		vm.execute = execute;
		
		function inner(entry, resuming) {
			var w = phaseA(entry); // 翻譯成恰當的 w.
			do{
				while(w) { // 這裡是 forth inner loop 決戰速度之所在，奮力衝鋒！
					if(bp<0||bp==ip){vm.jsc.prompt='ip='+ip+" jsc>";eval(vm.jsc.xt)}; // 可用 bp=ip 設斷點, debug colon words.
					ip++; // Forth 的通例，inner loop 準備 execute 這個 word 之前，IP 先指到下一個 word.
					phaseB(w); // 針對不同種類的 w 採取正確方式執行它。
					w = dictionary[ip];
				}
				if(w===0) break; else ip = rstack.pop(); // w==0 is suspend, ip==0 is abortexec
				if(resuming) w = dictionary[ip];
			} while(ip && resuming); // ip==0 means resuming has done
		}
		// ### End of the inner loop ###

		// -------------------------- the outer loop ----------------------------------------------------
		// forth outer loop, evaluates the remaining tib/ntib string.
		// if entry==0 then inner(0) does nothing, otherwise it resumes from the entry point.
		function outer(entry) {
			inner(entry, true); // resume from the breakpoint 
			while(!abortexec) {
				var token=nexttoken();
				if (token==="") break;    // TIB 收完了， loop 出口在這裡。
				outerExecute(token);
			}
		}
		
		// 當初為了 word.selfTest() 裡要讓 compiling==ture state 的 test case 能發
		// 揮作用，必須把 outerExecute() 從 outer() 裡抽出來，以便能單執行一個 word. 
		// 原本以為 outerExecute() 的 input argument 應該是個 Word() object. 真做了才
		// 發現它只能是個 word name string! 頗堪玩味! outerExecute() 後來沒啥實際應用。
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
						compilecode(w); // 將 w 編入 dictionary. w is a Word() object
					}
				}
			} else if (isNaN(token)) {
				// parseInt('123abc') 的結果是 123 很危險! 所以前面要用 isNaN() 先檢驗。		
				panic("Error! "+token+" unknown.\n", tib.length-ntib>100);
				return;
			} else {
				if(token.substr(0,2).toLowerCase()=="0x") var n = parseInt(token);
				else  var n = parseFloat(token);
				if (compiling) {
					dictcompile(new Constant(n)); // 直接用 Constant object 省掉 doLit
				} else {
					push(n);
				}
			}
		}
		// ### End of the outer loop ###
		
		// hcchen5600 2012/07/28 19:01:57 packhelp() 有成功，但是刀斧坑鑿，做進 '(' 與 '\' 裡去如何？ 偏偏又
		// 不行。因為 code word 整個丟給 javascript 執行，不認得 '(' 與 '\'。寫成 packhelp() 可以供 code end-code
		// 以及 : ... ; 使用。把 help message 打包好放進 help.stackdiagram, help.introduction 裡。離開時 ntib
		// 只吃掉與 help 有關的 substring. 傳回值是本 definition 的 help message string.
		
		// Note! 別忘了有這個功能。
		// 讓每個 word 天生就具有 help message 好處太大了。目前這個 function 被用在 docode(), create, : 的定義裡。
		// 我在寫 ( ... ) 的定義時，忘了有這個自動抓 help message 的功能。在應用 ( 時，寫成
		// : test ( foo baa ) bla bla bla ; 結果 ( foo baa ) 一開始就被 packhelp() 收走了我還以為是 ( 有 bug, 抓得
		// 莫名其妙，後來才終於想到是這個原因。
		function packhelp() { // (...) to help.stackdiagram and \... to help.introduction
			var help = {stackdiagram:"", introduction:"", flag:false};
			var tempntib = ntib;
			var ss=nexttoken();   // 看看下個 token 是什麼 ( 或 \ 是我們要處理的
			switch(ss){
				case "(" :
					help.stackdiagram="( " + nexttoken("\\)") + ") ";   // 把 ( ) 加上去，排除空字串的可能性。
					ss = nexttoken(); // 吃掉右邊的 )  [x] 故意漏掉 ) 會怎樣？ 此處 ss 沒用 debug 方便而已。
					help.flag = true;
					tempntib = ntib;  // tempntib 要逐步跟上
					ss = nexttoken();   // 看看下個 token 是什麼? \ 是我們要處理的。
					if (ss!="\\") {
						ntib = tempntib; // restore ntib when the token is not a \ comment.
						break;
					} // if ss == "\\" then proceed to next case . . .
				case "\\" :
					help.introduction = nexttoken('\n|\r');
					help.flag = true;
					// 到這裡 tempntib 已經確定用不著了。不用考慮 restore.
					break;
				default:
					ntib = tempntib; // restore ntib when this token is not a comment.
			}
			if (help.flag){
				ss = (help.stackdiagram) ? help.stackdiagram : "" ;
				if (help.introduction) ss += help.introduction;
			} else {
				ss = "( ?? ) No help message. Use // to add one.";
			}
			return ss;
		}
		
		// code ( -- ) Start to compose a code word. docode() is its run-time.
		// "( ... )" and " \ ..." on first line will be brought into this.help.
		// jeforth.js kernel has only two words, 'code' and 'end-code', jeforth.f
		// will be read from a file that will be a big TIB actually. So we don't 
		// need to consider about how to get user input from keyboard! Getting
		// keyboard input is difficult to me on an event-driven or a non-blocking 
		// environment like Node-webkit.
		function docode() {
			compiling = 11; // 11: code word
			newname = nexttoken();
			if(isReDef(newname)) print("reDef "+newname+"\n"); 	// 若用 tick(newname) 就錯了
			newhelp = newname + " " + packhelp(); // help messages packed
			push(nextstring("end-code")); // 將來所有的 code words 都會認得當初這裡的 local variables 所以要避免。 
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
				"this.creater=['code']",
				"this.help=this.name+' ( <name> -- ) Start composing a code word.'",
				"this.selftest='pass'"
			]),
			new Word([
				"end-code",
				function(){
					if(compiling!=11){ panic("Error! end-code to a none code word.\n"); return};
					current_word_list().push(new Word([newname,newxt,"this.help=newhelp"]));
					last().vid = current;
					last().wid = current_word_list().length-1;
					last().creater = ['code'];
					wordhash[last().name]=last();
					compiling  = false;
				},
				"this.vid='forth'",
				"this.wid=2",
				"this.creater=['code']",
				"this.immediate=true",
				"this.compileonly=true",
				"this.help=this.name+' ( -- ) Wrap up the new code word.'"
			])
		];
		
		// 伴隨 words[][] 的 hash table. 用 JavaScript 的十成功力來找 word 就是要利用這個。
		wordhash = {"code":current_word_list()[1], "end-code":current_word_list()[2]};
		
		// -------------------- main() ----------------------------------------

		// Recursively evaluate one forth command line.
		function fortheval(line){
			var tibwas,ntibwas,ipwas;
			arguments.callee.level += 1;
			tibwas = tib;
			ntibwas = ntib;
			ipwas = ip;
			tib = line;
			ntib = 0;
			abortexec = false; // abortexec 是給 outer loop 看的，這裡要先清除。
			// ip=0;
			outer(0); 
			tib = tibwas;
			ntib = ntibwas;
			ip = ipwas;
			arguments.callee.level -= 1;
		}
		fortheval.level = -1; // 
		vm.fortheval = fortheval; // export the function
	
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
		vm.tos = tos;
	
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
		// vm.rtos = rtos;
	
		// Stack access easier. e.g. pop(1) gets tos(1) and leaves ( tos(2) tos(1) tos(void|0) -- tos(2) tos(void|0) )
		function pop(index) {	
			switch (arguments.length) {
				case 0  : return stack.pop();
				default : return stack.splice(stack.length-1-index, 1)[0];
			}
		}
		vm.pop = pop;
	
		// Stack access easier. e.g. push(data,1) inserts data to tos(1), ( tos2 tos1 tos -- tos2 tos1 data tos )
		function push(data, index) { 
			switch (arguments.length) {
				case 0  : 	panic(" push() what?\n");
				case 1  : 	stack.push(data); 
							break;
				default : 	if (index >= stack.length) {
								stack.unshift(data);
							} else {
								// var datawas = tos(index);
								// stack.splice(stack.length-1-index, 1, datawas, data);
								stack.splice(stack.length-1-index,0,data);
							}
			}
		}
		vm.push = push;
	
		// This is a useful common tool. Compare two arrays.
		function isSameArray(a,b) {
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
							if (memberCount.call(a[i]) != memberCount.call(b[i])) return false;
						} else if (a[i] != b[i]) return false;
					} else if (a[i] != b[i]) return false;
				}
				return true;
			}
		}
	
		// typeof(array) and typeof(null) are "object"! So a tweak is needed.
		function mytypeof(x){
			var type = typeof x;
			switch (type) {
			case 'object':
				if (!x) type = 'null';
				// if (x.constructor == Array) type = "array"; // I saw the below method from json2.js
				if (Object.prototype.toString.apply(x) === '[object Array]') type = "array";
			}
			return type;
		}
		vm.mytypeof = mytypeof;
		// js> mytypeof([])           tib.  \ ==> array (string)
		// js> mytypeof(1)            tib.  \ ==> number (string)
		// js> mytypeof('a')          tib.  \ ==> string (string)
		// js> mytypeof(function(){}) tib.  \ ==> function (string)
		// js> mytypeof({})           tib.  \ ==> object (string)
		// js> mytypeof(null)         tib.  \ ==> null (string)  
		// js> Object.prototype.toString.apply([])           tib. \ ==> [object Array] (string)
		// js> Object.prototype.toString.apply(1)            tib. \ ==> [object Number] (string)
		// js> Object.prototype.toString.apply('a')          tib. \ ==> [object String] (string)
		// js> Object.prototype.toString.apply(function(){}) tib. \ ==> [object Function] (string)
		// js> Object.prototype.toString.apply({})           tib. \ ==> [object Object] (string)
		// js> Object.prototype.toString.apply(null)         tib. \ ==> [object Null] (string)


		// This is a useful common tool. Help to recursively see an object or forth Word.
		// For forth Words, view the briefing. For other objects, try to see into it.
		function see(obj,tab){
			if (tab==undefined) tab = "  "; else tab += "  ";
			switch(mytypeof(obj)){
				case "object" :
				case "array" :
					if (obj.constructor != Word && obj.constructor != Constant ) {
						if (obj&&obj.toString) 
							print(obj.toString() + '\n');
						else 
							print(Object.prototype.toString.apply(obj) + '\n');
						for(var i in obj) {
							print(tab + i + " : ");  // Entire array already printed here.
								if (obj[i]&&obj[i].toString) 
									print(tab + obj[i].toString() + '\n');
								else 
									print(tab + Object.prototype.toString.apply(obj[i]) + '\n');
						}
						break;  // if is Word then do default
					}
				default : // Word(), Constant(), number, string, null, undefined
					var ss = obj + ''; // Print-able test
					print(ss + " (" + mytypeof(obj) + ")\n");
			}
		}
		// vm.see = see;
	
		// JavaScript has no native way to copy an object to another object variable.
		// I design mergeObj() and retrieveObj() to do the copy.

		// mergeObj(to,from) 取聯集 (Object to) = (Object to) + (Object from); 
		// existing (Object to) elements will be over written. If you want to make a copy of 
		// (object from) then the correct way is var to={};mergeObj(to,from); you get a copy of 
		// 'from' in 'to'.
		function mergeObj(to,from){
			for(var i in from) {
				if (typeof(from[i])=="object") {
					if (from[i].constructor == Array ){  // typeof(array) does not return "array" but "object" !!
						to[i] = from[i].slice(0); // this is the way javascript copy array
					} else {
						mergeObj(to[i]={}, from[i]);
					}
				} else {
					to[i] = from[i];
				}
			}
		}
	
		// retrieveObj(to,from) 只挑自己有的 elements. (Object to) = (Object from); 
		// Similar to mergeObj() but only retrieve elements existing in (Object to)
		function retrieveObj(to,from){
			for(var i in from) {
				if (to[i] == undefined) continue;  // skip what is not exiting in the (Ojbect to)
				if (typeof(from[i])=="object") {
					mergeObj(to[i], from[i]);  // could be array or object
				} else {
					to[i] = from[i];
				}
			}
		}
	
		// Get hash table's length or an object's member count.
		// An array's length is array.length but there's no such thing of hash.length for hash{}.
		// memberCount.call(object) gets the given object's member count which is also a hash table's length.
		function memberCount() {
			var i=0;
			for(var members in this) i++;
			return i;
		}
	
		// Tool, check if the item exists in the array or is it a member in the hash keys.
		function isMember(item, thing){
			var result = {flag:false, keyvalue:0};
			if (mytypeof(thing) == "array") {
				for (var i in thing) {
					if (item == thing[i]) {
						result.flag = true;
						result.keyvalue = parseInt(i); // array 被 JavaScript 當作 object 而 i 是個 string, 所以要轉換!
						break;
					}
				}
			} else { // if obj is not an array then assume it's an object
				for (var i in thing) {
					if (item == i) {
						result.flag = true;
						result.keyvalue = thing[i];
						break;
					}
				}
			}
			return result; // {flag:boolean, value:(index of the array or value of the obj member)}
		}
	
		// -------------- Save forth VM's context and pause the recent outer loop ------------------
		// Use resumeForth() to resume. We need to suspend-resume forth VM for blocking words like 
		// 'accept', '*debug*', and 'jsc', and probably more in the future. Event-driven 
		// programming does not have sleep(). To wait for a blocking I/O, suspend-resume is my
		// solution. But note! suspend within a code word will not stop it immediately. It actually
		// suspend before the beginning of the next word. hcchen5600 2013/10/05 22:45:38 

		// Forth words 'suspend' and 'resume' better be code words. Because colon words use return 
		// stack that bothers the resuming. 'resume' must be called by terminal or some way that won't 
		// change the return stack. If resume is in a colon word then the return stack will be changed
		// by pushing a 0 before calling resumeForthVM() that will terminate the original outer loop
		// unexpectedly.
		
		// I can't suspend JavaScript code anyway, therefore to support multiple level of forth VM 
		// suspending does not help much. Only one pair of suspend-resume is allowed at a time.

		function suspendForthVM(){
			if(suspendForthVM.activated){ 
				panic("Error! double suspend.\n", "error");
				return; // can't double suspend.
			}
			arguments.callee.tib = tib; 
			arguments.callee.ntib = ntib; 
			arguments.callee.ip = ip; 
			tib = "";      // tib="" terminates the forth VM outer() loop
			ntib = ip = 0; // ip=0 terminates the forth VM inner() loop
			arguments.callee.activated = true;
		}
		// vm.suspendForthVM = suspendForthVM;
		
		function resumeForthVM() {
			if(!suspendForthVM.activated) {
				panic("Error! nothing to resume.\n", "error");
				return; // can't resume again.
			}
			suspendForthVM.activated = false;
			tib = suspendForthVM.tib;
			ntib = suspendForthVM.ntib;
			outer(suspendForthVM.ip);
		}

		// vm.resumeForthVM = resumeForthVM;
		vm.stack = stack; // debug easier
		vm.rstack = rstack; // debug easier especially debugging TSR
		vm.words = words; // debug easier
		vm.dictionary = dictionary; // debug easier
	}
    return new KsanaVm();
})();
if (typeof exports!='undefined') exports.kvm = kvm;	// export for node.js APP

