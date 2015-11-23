"uses strict";
function jeForth() {     
	var vm = this;
	vm.major_version = 3; // major version, jeforth.js kernel version.
	var ip=0;
	var stack = [] ;
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
	
	// Call out vm.type()
	// Kernel has no idea of typing, it does not need to 'type'. This is for 
	// the convenience of programs in code ... end-code that always need to 
	// print something.
	function type(s) {
		// defined in project-k kernel jeforth.js
		if(vm.type) vm.type(s);
	}
	
	// Reset the forth VM
	function reset(){
		// defined in project-k kernel jeforth.js
		rstack = [];
		compiling=false;
		ip=0; // forth VM instruction pointer
		stop = true; 
		ntib = tib.length; // don't clear tib, a clue for debug.
		// stack = []; I guess it's a clue for debug
	}

	// panic() calls out to vm.panic()
	// The panic() function gets only message and severity level. 
	// Kernel has no idea how to handle these information so it checks if vm.panic() exists
	// and pass the {msg,serious}, or even more info, over that's all. That's why vm.panic() has to
	// receive a hash structure, because it must be.
	function panic(msg,serious) {
		// defined in project-k kernel jeforth.js
		var state = {
				msg:msg, serious:serious
				// , compiling:compiling, 
				// stack:stack.slice(0), rstack:rstack.slice(0), 
				// ip:ip, tib:tib, ntib:ntib, stop:stop
			};
		if(vm.panic) vm.panic(state);
	}

	// Forth words are instances of Word() constructor.
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
		if (arguments.length==0) deli='\\s';   // white space
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
	
	// Discussions:

	// 'address' or 'ip' are index of dictionary[] array. dictionary[] is the memory of the
	// Forth virtual machine.
	
	// execute() executes a function, a word "name", and a word Object.  

	// inner(entry) jumps into the entry address. The TOS of return stack can be 0, in that
	// case the control will return back to JavaScript host, or the return address.

	// inner() used in outer(), and colon word's xt() while execute() is used everywhere.
	
	// We have 3 ways to call forth words from JavaScript: 1. execute('word'), 
	// 2. dictate('word word word'), and 3. inner(cfa). 

	// dictate() cycles are stand alone tasks. We can suspend an in-completed dictate() and we
	// can also run another dictate() within a dictate().

	// The ultimate inner loop is like this: while(w){ip++; w.xt(); w=dictionary[ip]}; 
	// Boolean(w) == false is the break condition. So I choose null to be the RET instruction
	// and the empty string "" to be the EXIT instruction. Choices are null, "", false, NaN, 
	// undefined, and 0. Total 6 of them. 0 has another meaning explained below.

	// To suspend the Forth virtual machine means to stop inner loop but not pop the 
	// return stack, resume is possible because return stack remained. We need an instruction 
	// to do this and it's 0. dictionary[0] and words[<vid>][0] are always 0 thus ip=w=0 
	// indicates that case. Calling inner loop from outer loop needs to push(0) first so 
	// as to balance the return stack also letting the 0 instruction to stop popping the
	// return stack because there's no more return address, it's outer interpreter remember? 
	
	// -------------------- ###### The inner loop ###### -------------------------------------

	// Translate all possible entry or input to the suitable word type.
	function phaseA (entry) { 
		var w = 0; 
		switch(typeof(entry)){
			case "string": // "string" is word name
				w = tick(entry.replace(/(^( |\t)*)|(( |\t)*$)/mg,'')); // remove leading and tailing white spaces
				break;
			case "function": case "object": // object is a word
				w = entry; 
				break;
			case "number": 
				// number could be dictionary entry or 0. 
				// could be does> branch entry or popped from return stack by RET or EXIT instruction.
				ip = entry;
				w = dictionary[ip]; 
				break;
			default :
				panic("Error! execute() doesn't know how to handle this thing : "+entry+" ("+mytypeof(entry)+")\n","err");
		}
		return w;
	}

	// Execute the given w by the correct method 
	function phaseB (w) { 
		switch(typeof(w)){
			case "number":  
				// Usually a number is the entry of does>. Can't use inner() to call it 
				// The below push-jump mimics the call instruction of a CPU.
				rstack.push(ip); // Forth ip is the "next" instruction to be executed.
				ip = w; // jump , 
				break;
			case "function": 
				w();
				break;
			case "object": // Word object
				try { // take care of JavaScript errors to avoid being kicked out very easily
					w.xt(w);
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
			if(typeof(w)=="number") 
				panic("Error! please use inner("+w+") instead of execute("+w+").\n","severe");
			else phaseB(w); 
		}
	}

	function inner (entry, resuming) {
		// defined in project-k kernel jeforth.js
		var w = phaseA(entry);
		do{
			while(w) {
				ip++; // Forth general rule. IP points to the *next* word. 
				phaseB(w);
				w = dictionary[ip];
			}
			if(w===0) break; // w==0 is suspend, break inner loop but reserve rstack.
			else ip = rstack.pop(); // w is either ret(NULL) or exit(""), return to caller.
			if(resuming) w = dictionary[ip]; // Higher level of inner()'s have been terminated by suspend, do their job.
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
			if (token==="") break;    // TIB done, loop exit.
			outerExecute(token);
		}
		// Handle one token. 
		function outerExecute(token){
			var w = tick(token);   // not found is 0. w is an Word object.
			if (w) {
				if(!compiling){ // interpret state or immediate words
					if (w.compileonly) {
						panic(
							"Error! "+token+" is compile-only.\n", 
							tib.length-ntib>100 // error or warning? depends
						); 
						return;
					}
					execute(w);
				} else { // compile state
					if (w.immediate) {
						execute(w); // inner(w);
					} else {
						if (w.interpretonly) {
							panic(
								"Error! "+token+" is interpret-only.\n", 
								tib.length-ntib>100 // error or warning? depends
							);
							return;
						}
						comma(w); // compile w into dictionary. w is a Word() object
					}
				}
			} else if (isNaN(token)) {
				// parseInt('123abc') is 123, very wrong! Need to check in prior by isNaN().
				panic(
					"Error! "+token+" unknown.\n", 
					tib.length-ntib>100 // error or warning? depends
				);
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
	    // All future code words can see local variables in here, so don't use
		// any local variable. They can *see* variables & functions out side 
		// this function too, that's normal.
		compiling = "code"; // it's true and a clue of compiling a code word.
		newname = nexttoken();
		if(isReDef(newname)) panic("reDef "+newname+"\n"); 	// don't use tick(newname), it's wrong.
		push(nextstring("end-code")); 
		if(tos().flag){
			// _me is the code word object itself.
			eval(
				'newxt=function(_me){ /* ' + newname + ' */\n' + 
				pop().str + '\n}' // the ending "\n}" allows // comment at the end
			);
		} else {
			panic("Error! expecting 'end-code'.\n");
			reset();
		}
	}
	
	words[current] = [
		0,  // Letting current_word_list()[0] == 0 has many advantages. When tick('name') 
			// returns a 0, current_word_list()[0] is 0 too, indicates a not-found.
		new Word([
			"code",
			docode,
			"this.vid='forth'",
			"this.wid=1",
			"this.type='code'",
			"this.help='( <name> -- ) Start composing a code word.'"
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
	
	// Use the best of JavaScript to find a word.
	wordhash = {"code":current_word_list()[1], "end-code":current_word_list()[2]};
	
	// -------------------- main() ----------------------------------------

	// Recursively evaluate the input. The input can be multiple lines or 
	// an entire ~.f file yet it usually is the TIB.
	function dictate(input) {
		var tibwas=tib, ntibwas=ntib, ipwas=ip;
		tib = input; 
		ntib = 0;
		stop = false; // stop outer loop
		outer();
		tib = tibwas;
		ntib = ntibwas;
		ip = ipwas;
	}

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
	// push(formula(pop(i)),i-1) manipulate the tos(i) directly, usually when i is the index of a loop.
	function pop(index) {	
		switch (arguments.length) {
			case 0  : return stack.pop();
			default : return stack.splice(stack.length-1-index, 1)[0];
		}
	}

	// Stack access easier. e.g. push(data,1) inserts data to tos(1), ( tos2 tos1 tos -- tos2 tos1 data tos )
	// push(formula(pop(i)),i-1) manipulate the tos(i) directly, usually when i is the index of a loop.
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
		var ty = typeof x;
		switch (ty) {
		case 'object':
			if (!x) ty = 'null';
			if (Object.prototype.toString.apply(x) === '[object Array]') ty = "array";
		}
		return ty;
	}
	// js> mytypeof([])           \ ==> array (string)
	// js> mytypeof(1)            \ ==> number (string)
	// js> mytypeof('a')          \ ==> string (string)
	// js> mytypeof(function(){}) \ ==> function (string)
	// js> mytypeof({})           \ ==> object (string)
	// js> mytypeof(null)         \ ==> null (string)  

	vm.dictate = dictate; // This is where commands are from. A clause or more.
	vm.execute = execute; // This is where commands are from. A single command.
	vm.stack = function(){return(stack)}; // debug easier. stack got manipulated often, need a fresh grab.
	vm.rstack = function(){return(rstack)}; // debug easier especially debugging TSR
	vm.words = words; // debug easier. works.forth is the root vocabulary or word-list
	vm.dictionary = dictionary; // debug easier
	vm.push = push; // interface for passing data into the VM.
	vm.pop = pop;   // interface for getting data out of the VM.
	vm.tos = tos;   // interface for getting data out of the VM.
	vm.reset = reset; // Recovery from a crash
}
if (typeof exports!='undefined') exports.jeForth = jeForth;	// export for node.js APP

