code //         last().help = nexttoken('\n|\r'); end-code
                // ( <comment> -- ) Give help message to the new word.
code stop       reset() end-code // ( -- ) Stop the TIB loop
code parse-help var ss = " " + pop() + " ", comment = "";
                var stackDiagram = ss.match(/^\s+(\(\s.*?\s\))\s+(.*)/); // null or [0] entire line, [1] (...), [2] the rest.
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
                
code privacy    push(false) end-code // ( -- false ) Default is false, words are nonprivate by default.
                
code code       push(nexttoken()); // name of the word
                push(nexttoken('\n|\r')); // rest of the first line
                execute("parse-help"); // ( "name" "helpmsg" "rests" )
                tib = " " + pop() + tib.slice(ntib); // "rests" + tib(ntib)
                ntib = 0;
                newhelp = pop();
                tib = pop() + " " + tib; // "name" + tib
                execute(words.forth[1]); // execute the old version 'code'.
                end-code
                // ( <name ..code..> -- ) Start composing a code word.
                
code _init_     ( -- ) \ Initialize vm.g.members that are moved out from projectk.js which is thus kept pure.

                // forth's global variable storage
                vm.forth = {};
                
                // To support private word, END-CODE needs one more line
                words.forth[2].xt = function(){ 
                    // was from project-k projectk.js, modified by jeforth.3we jeforth.f _init_ 
                    if(compiling!="code"){ panic("Error! 'END-CODE' to a none code word.\n"); return};
                    current_word_list().push(new Word([newname,newxt]));
                    last().vid = current;
                    last().wid = current_word_list().length-1;
                    last().type = 'code';
                    last().help = newhelp;
                    vm.execute("privacy"); // use the original execute() to avoid warning
                    last().private = Boolean(pop()); // support private word
                    wordhash[last().name]=last();
                    compiling  = false;
                }                

                // Access variables in context from js code
                vm.v = function(name){
                    // FORTH variables (value or constant) can be accessed in js code
                    // throuth vm[context].variableName or vm.forth.variableName
                    // shorter form v(variableName) 
                    // where 'v' means (V)ariable in the recent context.
                    return vm[context][name]
                }

                // Access variables in root vocabulary from js code
                vm.r = function(name){
                    // FORTH variables (value or constant) can be accessed in js code
                    // throuth vm[context].variableName or vm.forth.variableName
                    // shorter form r(variableName) 
                    // where 'r' means the (R)oot context which is the 'forth' word-list.
                    return vm.forth[name]
                }
                
                // An array's length is array.length but there's no such thing of hash.length for hash{}.
                // memberCount(object) gets the given object's member count which is also a hash table's length.
                vm.g = {}; // The global hash
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
                
                // jeforth inner interpreter debugger mode opposed to performance mode
                vm.g.debugInner = function (entry, resuming) {
                    var w = phaseA(entry); // 翻譯成恰當的 w.
                    do{
                        while(w) { // 這裡是 forth inner loop 決戰速度之所在，奮力衝鋒！
                            // 可用 bp=ip 設斷點, debug colon words.
                            if(vm.jsc.bp<0||vm.jsc.bp==ip){
                                if (vm.jsc.enable){ // 需要這個 flag 因為若已經進了 debugInner, 換掉 inner 也出不來。
                                    vm.jsc.prompt=" BreakPoint jsc>";
                                    eval(vm.jsc.xt);
                                }
                            };
                            ip++; // Forth 的通例，inner loop 準備 execute 這個 word 之前，IP 先指到下一個 word.
                            phaseB(w); // 針對不同種類的 w 採取正確方式執行它。
                            w = dictionary[ip];
                        }
                        if(w===0) break; else ip = rstack.pop(); // w==0 is suspend, abort inner but reserve rstack
                        if(resuming) w = dictionary[ip];
                    } while(ip && resuming); // ip==0 means resuming has done
                }
                
                
                // Scan given VID into wordhash{}
                vm.g.scan_vocabulary = function (v,isContext) { 
                    for (var i=1; i<words[v].length; i++){  // The [0] is 0, skip it.
                        // skip the last() to avoid unexpected 'reveal'.
                        if (compiling && last()==words[v][i]) continue; 
                        // skip private words unless in context
                        if (isContext || !words[v][i].private) wordhash[words[v][i].name] = words[v][i];
                    }
                }
                
                // Referenced by name warning when execute(),tick() on a private word.
                // vm.tick is the original version which is used sometimes like in 'all-pass'.
                tick = vm.g.selftest_tick = function tick(name) {
                    // selftest version defined in jeforth.f
                    var w = wordhash[name] || 0; // 0 means 'not found'
                    if (w && w.private)
                        panic("Warning! private word "+w.name+" referenced by name in tick()!\n",true); 
                    return w;
                }
                
                // Referenced by name warning when execute(),tick() on a private word.
                // vm.execute is the original version which is used sometimes like in '(create)'.
                execute = vm.g.selftest_execute = function execute(entry) { 
                    // selftest version defined in jeforth.f 
                    var w, calledByName = typeof entry == "string"; 
                    if (w = phaseA(entry)){
                        if(typeof(w)=="number") {
                            panic("Error! please use inner("+w+") instead of execute("+w+").\n","severe");
                            return;
                        }
                        if (calledByName && typeof(w)=="object" && w.private)
                            panic("Warning! private word "+w.name+" called by name in execute()!\n",true); 
                        phaseB(w); 
                    }
                }
                
                end-code _init_

code version    ( -- revision ) \ print the greeting message and return the revision code
                push(vm.greeting()) end-code

code <selftest> ( <statements> -- ) \ Collect self-test statements. interpret-only
                push(nexttoken("</selftest>"));
                end-code

code </selftest> ( "selftest" -- ) \ Save the self-test statements to <selftest>.buffer. interpret-only
                var my = tick("<selftest>");
                my.buffer = my.buffer || ""; // initialize my.buffer
                my.buffer += pop();
                end-code

                <selftest>
                    <comment>
                    程式只要稍微大一點點，就得附上一些 self-test 讓它伺機檢查自身。隨便有做，穩定性
                    就會提升一大步。 Forth 的結構全部都是 global words， 改動的時候自由無限，難以一
                    一去檢討影響到了哪些 words, 不讓它全面自動測試十分令人擔憂。與其努力抓 bug 不如
                    早點把 self-test 做進去。

                    Self-test 的執行時機是程式開始時，或開機時。沒有特定任務就做 self-test.

                    include 各個 modules 時，循序就做 self-test。藉由 forth 的 marker , (forget) 等
                    self-test 用過即丟， 只花時間，不佔空間。花平時的開發時間不要緊，有特定任務時就
                    跳過 self-test，是則完全不佔執行系統任何時間空間，只佔 source code 的篇幅。

                    我嘗試了種種的 self-test 寫法。有的很醜，混在正常程式裡面相當有礙視線；不醜的很
                    累，佔很大 source code 篇幅。

                    以下是發展到目前最好的方法，projectk.js kernel  裡只有 code end-code 兩個基本 
                    words, 剛進到 jeforth.f  只憑這兩個基本 words 就馬上要為每個 word 都做 self-test 
                    原本是很困難的。 然而，jeforth.f 是整個檔案一次讀進來成為大大的一個 TIB 的， 所
                    以其中已經含有 jeforth.f 的全部功能。如果 self-test 安排在所有的 words 都 load 
                    好以後做，資源充分就不覺有困難。好玩的是，進一步，利用〈selftest〉〈/selftest〉這
                    對「文字蒐集器」在任意處所蒐集「測試程式的本文」，最後再一次把它當成 TIB 執行。實
                    用上〈selftest〉〈/selftest〉出現在每個 word 定義處，裡頭可以放心自由地使用尚未出
                    生的「未來 words」, 對寫程式時的頭腦有很大的幫助。 
                    </comment>

                    marker ~~selftest~~ // ( -- ) marker, clean selftest garbage
                    .( *** Start self-test ) cr
                    *** Data stack should be empty
                        depth [d 0 d] 
                        [p 'code','end-code','.', '."', '.(', ':', ';', 'if', 'else', 'then', 
                        'js>', 'parse-help','cr','depth','<selftest>','</self'+'test>','word',
                        '<js>', '</'+'jsV>' p]
                    *** Rreturn stack should have less than 2 cells
                        description . 
                        js> rstack.length dup . space 2 <= [if] .( pass) cr [else] .( failed!) cr stop [then]
                        [p 'dup','<=','[if]', '[else]', '[then]' p]
                    *** // adds help to the last word
                        ' // :> help.indexOf("message")!=-1 [d true d] [p "//", ":>", "'" p]
                    *** version should return a number
                        js: vm.selftest_visible=false;vm.screenbuffer=""
                        version 
                        js: vm.selftest_visible=true
                        js> typeof(pop())=="number" ( true )
                        <js> vm.screenbuffer.indexOf('j e f o r t h')!=-1 </jsV> ( true )
                        [d true,true d]
                        [p 'version' p]
                </selftest>

code execute    ( Word|"name"|address -- ... ) \ Execute the given word.
                execute(pop()); end-code

                <selftest>
                    *** "drop" drops the TOS
                        321 123 s" drop" execute \ 321
                        654 456 ' drop execute \ 321 654
                        [d 321,654 d] [p 'drop', "'", "execute", '\\' p]
                </selftest>

code interpret-only  ( -- ) \ Make the last new word an interpret-only.
                last().interpretonly=true;
                end-code interpret-only

                <selftest>
                    *** interpret-only marks the last word an interpret-only word
                        ' execute :> interpretonly==true ( false ) 
                        ' interpret-only :> interpretonly==true ( true )
                        [d false,true d] [p "interpret-only" p]
                </selftest>

code immediate  ( -- ) \ Make the last new word an immediate.
                last().immediate=true
                end-code

                <selftest>
                    *** immediate marks the last word an immediate word
                        ' execute :> immediate==true ( false ) 
                        ' \ :> immediate==true ( true )
                        [d false,true d] [p "immediate" p]
                </selftest>
                
code ///        ( <comment> -- ) \ Add comment to the new word, it appears in 'see'.
                var ss = nexttoken('\n|\r');
                ss = ss.replace(/^/,"\t"); // Add leading \t to each line.
                ss = ss.replace(/\s*$/,'\n'); // trim tailing white spaces
                last().comment = typeof(last().comment) == "undefined" ? ss : last().comment + ss;
                end-code interpret-only

                <selftest>
                    *** /// adds comment to the last word
                        1234 constant x
                        /// comment-line-111
                        /// comment-line-222
                        js> last().comment.indexOf("comment-line-111")==-1
                        js> last().comment.indexOf("comment-line-222")==-1
                        x [d false,false,1234 d] [p "///","constant" p]
                        (forget)
                </selftest>
                
code private  ( -- ) \ Make the last word invisible when out of the context.
                last().private=true
                end-code
                /// The opposite is nonprivate.
                
code nonprivate  ( -- ) \ Make the last word non-private so it's globally visible.
                last().private=false
                end-code
                /// The opposite of private.
                
                <selftest>
                    \ *** private marks the last word a private word
                    \   ' execute :> immediate==true ( false ) 
                    \   ' \ :> immediate==true ( true )
                    \   [d false,true d] [p "immediate" p]
                </selftest>

code .((        ( <str> -- ) \ Print string that has ')' in it down to '))' immediately.
                type(nexttoken('\\)\\)'));ntib+=2; end-code immediate

code \          ( <comment> -- ) \ Comment down to the next '\n'.
                nexttoken('\n') end-code immediate

                <selftest>
                    *** TIB lines after \ should be ignored
                        111 \ 222
                        : dummy
                            999
                            \ 333 444 555
                        ;
                        last execute [d 111,999 d] [p '\\' p]
                        (forget)
                </selftest>

code \s         ( -- ) \ Stop outer loop which may be loading forth source files.
                stop=true; 
                ntib=tib.length; // 可能沒用，雙重保險。
                end-code

code compile-only  ( -- ) \ Make the last new word a compile-only.
                last().compileonly=true
                end-code interpret-only

                <selftest>
                    *** compile-only marks last word as a compile-only word
                        ' execute :> compileonly==true ( false ) 
                        ' if :> compileonly==true ( true )
                        [d false,true d] [p "compile-only" p]
                </selftest>

\ ------------------ Fundamental words ------------------------------------------------------
                
code (create)   ( "name" -- ) \ Create a code word that has a dummy xt, not added into wordhash{} yet
                if(!(newname=pop())) panic("(create) what?\n", tib.length-ntib>100);
                if(isReDef(newname)) type("reDef "+newname+"\n"); // 若用 tick(newname) 就錯了
                current_word_list().push(new Word([newname,function(){}]));
                last().vid = current; // vocabulary ID
                last().wid = current_word_list().length-1; // word ID
                last().type = "colon-create";
                vm.execute("privacy"); // use the original execute() to avoid warning
                last().private = Boolean(pop());
                end-code

code reveal     ( -- ) \ Add the last word into wordhash
                wordhash[last().name]=last() end-code
                \ We don't want the last word to be seen during its colon definition.
                \ So reveal is done in ';' command.

                <selftest>
                    *** (create) creates a new word
                        char ~(create)~ (create)
                        js> last().name [d "~(create)~" d] [p "(create)","char" p]
                </selftest>

code (space)    push(" ") end-code // ( -- " " ) Put a space on TOS.
code BL         push("\\s") end-code // ( -- "\s" ) RegEx white space, works with 'word' command.
code CR         push("\\n|\\r") end-code // ( -- '\n' ) RegEx new line, works with 'word' command.
                /// Also String.fromCharCode(10) in JavaScript

                <selftest>
                    *** (space) puts a 0x20 on TOS
                        (space) js> String.fromCharCode(32) =
                        [d true d] [p "(space)","=" p]
                    *** BL should return the string '\s' literally
                        BL [d "\\s" d] [p "BL" p]
                    *** CR should return the string \n|\r literally
                        CR js> "\\n|\\r" = 
                        [d true d] [p "CR","=" p]                       
                </selftest>

code jsEval     ( "js code" -- result ) \ Evaluate the given JavaScript statements, return the last statement's value.
                try {
                  push(eval(pop()));
                } catch(err) {
                  panic("JavaScript error : "+err.message+"\n", "error");
                };
                end-code private
                
                <selftest>
                    *** jsEval should eval(tos) and return the last statement's value
                        456 char pop()+1 jsEval [d 457 d] [p "jsEval" p]
                </selftest>

code jsEvalNo   ( "js code" -- ) \ Evaluate the given JavaScript statements, w/o return value.
                try {
                  eval(pop());
                } catch(err) {
                  panic("JavaScript error : "+err.message+"\n", "error");
                };
                end-code private

                <selftest>
                    *** jsEvalNo should eval(tos) but won't return any value
                        456 char 123 jsEvalNo [d 456 d] [p "jsEvalNo" p]
                </selftest>

code jsFunc     ( "js code" -- function ) \ Compile JavaScript to a function() that returns last statement
                // 切出最後一個 statement 以傳回其值比想像中困難。
                // 規定除了最後一行之外行末尾的 ; 不能省略。
                // 出現在 ['"/] 當中的 ';' 會造成分辨錯亂, 必須先換掉, 然後再換回來, 這
                // 就一大段了。即使如此 string 以及 RegEx 中又有 escape char 尚未周全！
                var ss=pop();
                ss = ss.replace(/(^( |\t)*)|(( |\t)*$)/mg,'') // remove 頭尾 whitespaces. .trim() 舊 JScript v5.6 未 support                
                       .replace(/\s*\/\/.*$/gm,'') // remove // comments
                       .replace(/(\n|\r)*/gm,'') // merge to one line
                       .replace(/\s*[/]\*(.|\r|\n)*?\*[/]\s*/gm,'') // remove /* */ comments
                       .replace(/;*\s*$/,''); // remove ending ';' from the last statement
                ss = replace_semicolon_in_quotes(ss); 
                var parsed=ss.match(/^(.*;)(.*)$/); // [entire string,fore part,last statement]|NULL
                if (parsed){
                    parsed[1] = parsed[1].replace(/__SeMiCoLoN__/g,";");
                    parsed[2] = parsed[2].replace(/__SeMiCoLoN__/g,";"); 
                    eval("push(function(){" + parsed[1] + "push(" + parsed[2] + ")})");
                }else{
                    eval("push(function(){push(" + ss + ")})");
                }
                function replace_semicolon_in_quotes(source) { 
                    // return ['"/]foo;bar['"/] ==> ['"/]foo__SeMiCoLoN__bar['"/]
                    var result = "";
                    for (;;) {
                        var aa = nextQuote(source); // ["cooked","raw"]
                        result += aa[0];
                        if (!aa[1]) return (result);
                        source = aa[1];
                    }
                    function nextQuote(source) { 
                        // return ["cooked","raw"]
                        var result="", aa=source.match(/['"/]/);
                        if (!aa) return([source,""]); // Done
                        switch(aa[0]){
                            case "'" : var re = /^(.*?)(['].*?['])(.*)$/; break;
                            case '"' : var re = /^(.*?)(["].*?["])(.*)$/; break;
                            default  : var re = /^(.*?)([/].*?[/])(.*)$/;
                        }
                        var pieces = source.match(re);
                        if(pieces) {
                            result += pieces[1];
                            result += pieces[2].replace(/;/g,"__SeMiCoLoN__");
                            return [result,pieces[3]];
                        } else 
                            return([source,""]); 
                            // 已經不平衡了,算了。因為 ['"/] 裡又可能有 escape char 目前不夠周全。
                    }
                }
                end-code private

code jsFuncNo   ( "js code" -- function ) \ Compile JavaScript to a function()
                eval("push(function(){" + pop() + "})"); 
                end-code private

code [          compiling=false end-code immediate // ( -- ) 進入直譯狀態, 輸入指令將會直接執行 *** 20111224 sam
code ]          compiling=true end-code // ( -- ) 進入編譯狀態, 輸入指令將會編碼到系統 dictionary *** 20111224 sam
code compiling  push(compiling) end-code // ( -- boolean ) Get system state
code last       push(last()) end-code // ( -- word ) Get the word that was last defined.

                <selftest>
                    *** last should return the last word
                        0 constant xxx
                        last :> name [d "xxx" d] [p "last" p]
                        (forget)
                </selftest>

code exit       ( -- ) \ Exit this colon word.
                comma(EXIT) end-code immediate compile-only

                <selftest>
                    *** exit should stop a colon word
                        : dummy 123 exit 456 ;
                        last execute [d 123 d] [p "exit" p]
                        (forget)
                </selftest>

code ret        ( -- ) \ Mark at the end of a colon word.
                comma(RET) end-code immediate compile-only

code rescan-word-hash ( -- ) \ Rescan all word-lists in the order[] to rebuild wordhash{}
                wordhash = {}; context = order[order.length-1];
                vm.g.scan_vocabulary("forth",false); // forth always available
                for (var j=0; j<order.length-1; j++) 
                    vm.g.scan_vocabulary(order[j],false); // The latter the higher priority
                vm.g.scan_vocabulary(context,true); // The context has the highest priority
                end-code

code all        ( -- ) \ Temporarily make all private words public, so "all words" shows them all.
                for (var j=0; j<order.length; j++) 
                    vm.g.scan_vocabulary(order[j],true); // The latter the higher priority
                end-code
                
code (forget)   ( -- ) \ Forget the last word
                if (last().cfa) here = last().cfa;
                words[current].pop(); // drop the last word
                execute("rescan-word-hash");
                end-code 

                <selftest>
                    *** (forget) should forget the last word
                        : remember-me ; (forget)
                        last :> name=="remember-me" [d false d] 
                        [p "(forget)","rescan-word-hash" p]
                </selftest>

code :          ( <name> -- ) \ Begin a forth colon definition.
                newname = nexttoken();
                push(nexttoken('\n|\r')); // rest of the first line
                execute("parse-help"); // ( "helpmsg" "rests" )
                tib = " " + pop() + tib.slice(ntib); ntib = 0; // "rests" + tib(ntib)
                newhelp = /* newname + " " + */ pop(); // help messages packed
                push(newname); execute("(create)"); // 故 colon definition 裡有 last or last() 可用來取得本身。
                compiling=true;
                tick(':').stackwas = stack.slice(0); // Should not be changed, ';' will check.
                last().type = "colon";
                last().cfa = here;
                last().help = newhelp;
                last().xt = colonxt = function(){
                    rstack.push(ip);
                    inner(this.cfa);
                }
                end-code

code ;          ( -- ) \ End of the colon definition.
                if (!vm.g.isSameArray(tick(':').stackwas,stack)) {
                    panic("Stack changed during colon definition, it must be a mistake!\n", "error");
                    words[current].pop();
                } else {
                    comma(RET);
                }
                compiling = false;
                execute('reveal');
                end-code immediate compile-only

code (')        ( "name" -- Word ) \ name>Word like tick but the name is from TOS.
                push(vm.tick(pop())) // use the original tick() to avoid warning
                end-code

code '          ( <name> -- Word ) \ Tick, get word name from TIB, leave the Word object on TOS.
                push(vm.tick(nexttoken())) // use the original tick() to avoid warning
                end-code


                <selftest>
                    *** ' tick and (') should return a word object
                        ' code :> name char end-code (') :> name
                        [d "code","end-code" d] [p "'","(')" p]
                </selftest>

code #tib       push(ntib) end-code // ( -- n ) Get ntib
code #tib!      ntib = pop() end-code // ( n -- ) Set ntib

\ ------------------ eforth code words ----------------------------------------------------------------------

code branch     ip=dictionary[ip] end-code compile-only // ( -- ) 將當前 ip 內數值當作 ip *** 20111224 sam

                <selftest>
                    *** branch should jump to run hello
                    marker ---
                        : sum 0 1 begin 2dup + -rot nip 1+ dup 10 > if drop exit then again ;
                        : test sum 55 = ;
                        test [d true d] [p '2dup', '-rot', 'nip', '1+', '>', '0branch' p]
                    ---
                </selftest>

code 0branch    if(pop())ip++;else ip=dictionary[ip] end-code compile-only // ( n -- ) 若 n!==0 就將當前 ip 內數值當作 ip, 否則將 ip 進位 *** 20111224 sam
code !          dictionary[pop()]=pop() end-code // ( n a -- ) 將 n 存入位址 a
code @          push(dictionary[pop()]) end-code // ( a -- n ) 從位址 a 取出 n
code >r         rstack.push(pop()) end-code  // ( n -- ) Push n into the return stack.
code r>         push(rstack.pop()) end-code  // ( -- n ) Pop the return stack
code r@         push(rtos()) end-code // ( -- r0 ) Get a copy of the TOS of return stack
code drop       pop(); end-code // ( x -- ) Remove TOS.
code dup        push(tos()) end-code // ( a -- a a ) Duplicate TOS.
code swap       push(pop(1)) end-code // ( a b -- b a ) stack operation
code over       push(tos(1)) end-code // ( a b -- a b a ) Stack operation.
code 0<         push(pop()<0) end-code // ( a -- f ) 比較 a 是否小於 0

                <selftest>
                    *** ! @ >r r> r@ drop dup swap over 0<
                    marker ---
                    variable x 123 x ! x @ 123 = \ true
                    111 dup >r r@ r> + swap 2 * = and \ true
                    333 444 drop 333 = and \ true
                    555 666 swap 555 = \ true 666 true
                    rot and swap \ true 666
                    0< not and \ true
                    -1 0< and \ true
                    false over \ true
                    [d true, false, true d] [p '!', '@', '>r', 'r>', 'r@', 'swap', 'drop',
                    'dup', 'over', '0<', '2drop','marker' p]
                    ---
                </selftest>

code here!      here=pop() end-code // ( a -- ) 設定系統 dictionary 編碼位址
code here       push(here) end-code // ( -- a ) 系統 dictionary 編碼位址 a

                <selftest>
                    *** here! here, forth dictionary pointer
                    marker ~~~
                        marker ---
                        10000 here! here ( 10000 )
                        : dummy ; ' dummy js> pop().cfa 10000 >= ( true )
                        (forget)
                        ---
                        : dummy ; ' dummy js> pop().cfa 888 < ( true )
                        [d 10000,true,true d] [p 'here', 'here!', ">=", "<" p]
                        (forget)
                    ~~~ 
                </selftest>

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
code ||         tos(1) ? pop() : pop(1) end-code // ( a b == a || b ) if a then a else b endif
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

                <selftest>
                    *** boolean and or && || not AND OR NOT XOR
                    undefined not \ true
                    "" boolean \ true false
                    and \ false
                    false and \ false
                    false or \ false
                    true or \ true
                    true and \ true
                    true or \ true
                    false or \ true
                    {} [] || \ true {}
                    [] && \ true []
                    swap \ [] true
                    && \ true
                    "" && \ true ""
                    not \ false
                    1 2 AND \ true 0
                    2 OR NOT  \ true -3
                    -3 = \ true true
                    1 2 XOR \ true true 3
                    0 XOR 3 = \ true true true
                    and and \ true
                    <js> function test(x){ return x }; test() </jsV> null = \ true true
                    [d true,true d] [p 'and', 'or', 'not', '||', '&&', 'AND', 'OR', 'NOT', 'XOR',
                    'true', 'false', '""', '[]', '{}', 'undefined', 'boolean', 'null' p] 
                </selftest>

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

                <selftest>
                    *** + * - / 1+ 2+ 1- 2-
                    1 1 + 2 * 1 - 3 / 1+ 2+ 1- 2- 1 = [d true d]
                    [p '+', '*', '-', '/', '1+', '2+', '1-', '2-' p]
                </selftest>

code mod        push(pop(1)%pop()) end-code // ( a b -- c ) 計算 a 與 b 兩數相除的餘 c
code div        push(parseInt(pop(1)/pop())) end-code // ( a b -- c ) 計算 a 與 b 兩數相除的整數商 c

                <selftest>
                    *** mod 7 mod 3 is 1
                        7 3 mod [d 1 d] [p "mod" p]
                    *** div 7 div 3 is 2
                        7 3 div [d 2 d] [p "div" p]
                </selftest>

code >>         var n=pop();push(pop()>>n) end-code // ( data n -- data>>n ) Singed right shift
code <<         var n=pop();push(pop()<<n) end-code // ( data n -- data<<n ) Singed left shift
code >>>        var n=pop();push(pop()>>>n) end-code // ( data n -- data>>>n ) Unsinged right shift. Note! There's no <<<.

                <selftest>
                    *** >> -1 signed right shift n times will be still -1
                        -1 9 >> [d -1 d] [p ">>" p]
                    *** >> -4 signed right shift becomes -2
                        -4 1 >> [d -2 d] [p ">>" p]
                    *** << -1 signed left shift 63 times become the smallest int number
                        -1 63 << 0x80000000 -1 * = [d true d] [p "<<" p]
                    *** >>> -1 >>> 1 become 7fffffff
                        -1 1 >>> 0x7fffffff = [d true d] [p ">>>" p]
                </selftest>

code 0=         push(pop()==0) end-code // ( a -- f ) 比較 a 是否等於 0
code 0>         push(pop()>0) end-code // ( a -- f ) 比較 a 是否大於 0
code 0<>        push(pop()!=0) end-code // ( a -- f ) 比較 a 是否不等於 0
code 0<=        push(pop()<=0) end-code // ( a -- f ) 比較 a 是否小於等於 0
code 0>=        push(pop()>=0) end-code // ( a -- f ) 比較 a 是否大於等於 0
code =          push(pop()==pop()) end-code // ( a b -- a=b ) 經轉換後比較 a 是否等於 b, "123" = 123.

                <selftest>
                    *** 0= 0> 0<> 0 <= 0>=
                        "" 0= \ true
                        undefined 0= \ true false
                        1 0> \ true false true
                        0 0> \ true false true false
                        XOR -rot XOR + 2 = \ true
                        0<> \ false
                        0= \ true
                        0<> \ true
                        0<= \ true
                        0>= \ true
                        99 && \ 99
                        0= \ false
                        99 || 0<> \ true
                        -1 0<= \ true true
                        1 0>= \ true true true
                        s" 123" 123 = \ \ true true true true
                        [d true,true,true,true d]
                        [p '0=', '0>', '0<>', '0<=', '0>=', '=' p]
                </selftest>

code ==         push(Boolean(pop())==Boolean(pop())) end-code // ( a b -- f ) 比較 a 與 b 的邏輯
code ===        push(pop()===pop()) end-code // ( a b -- a===b ) 比較 a 是否全等於 b
code >          var b=pop();push(pop()>b) end-code // ( a b -- f ) 比較 a 是否大於 b
code <          var b=pop(); push(pop()<b) end-code // ( a b -- f ) 比較 a 是否小於 b
code !=         push(pop()!=pop()) end-code // ( a b -- f ) 比較 a 是否不等於 b
code !==        push(pop()!==pop()) end-code // ( a b -- f ) 比較 a 是否不全等於 b
code >=         var b=pop();push(pop()>=b) end-code // ( a b -- f ) 比較 a 是否大於等於 b
code <=         var b=pop();push(pop()<=b) end-code // ( a b -- f ) 比較 a 是否小於等於 b


                <selftest>
                    *** == compares after booleanized
                        {} [] == \ true
                        "" null == \ true
                        "" undefined == \ true
                        s" 123" 123 == \ true
                        [d true,true,true,true d] [p "==",'""',"null", "undefined" p]
                    *** === compares the type also
                        "" 0 = \ true
                        "" 0 == \ true
                        "" 0 === \ false
                        s" 123" 123 = \ true
                        s" 123" 123 == \ true
                        s" 123" 123 === \ false
                        [d true,true,false,true,true,false d]
                        [p "===" p]
                    *** > < >= <= != !== <>
                        1 2 > \ false
                        1 1 > \ false
                        2 1 > \ true
                        1 2 < \ true
                        1 1 < \ false
                        2 1 < \ fasle
                        1 2 >= \ false
                        1 1 >= \ true
                        2 1 >= \ true
                        1 2 <= \ true
                        1 1 <= \ true
                        2 1 <= \ fasle
                        1 1 <> \ false
                        0 1 <> \ true
                        [d false,false,true,true,false,false,false,true,true,true,true,false,false,true d]
                        [p '<', '>=', '<=', '!=', '!==', '<>' p]
                </selftest>

code abs        push(Math.abs(pop())) end-code // ( n -- |n| ) Absolute value of n.
code max        push(Math.max(pop(),pop())) end-code // ( a b -- max(a,b) ) The maximum.
code min        push(Math.min(pop(),pop())) end-code // ( a b -- min(a,b) ) The minimum.

                <selftest>
                    *** abs makes negative positive
                        1 63 << abs [d 0x80000000 d] [p "abs" p]
                    *** max min
                        1 -2 3 max max (  3 )
                        1 -2 3 min min ( -2 )
                        [d 3,-2 d] [p "max","min" p]
                </selftest>

code doVar      push(ip); ip=rstack.pop(); end-code compile-only private
                // ( -- a ) 取隨後位址 a , runtime of created words
code doNext     var i=rstack.pop()-1;if(i>0){ip=dictionary[ip]; rstack.push(i);}else ip++ end-code 
                compile-only
                // ( -- ) next's runtime.
code ,          comma(pop()) end-code // ( n -- ) Compile TOS to dictionary.

                <selftest>
                    *** doVar doNext
                    marker ---
                        variable x
                        : tt for x @ . x @ 1+ x ! next ;
                        js: vm.selftest_visible=false;vm.screenbuffer=""
                        10 tt space \ "0123456789 "
                        x @ ( 10 )
                        js: vm.selftest_visible=true
                        <js> vm.screenbuffer.slice(-11)=="0123456789 "</jsV> ( true )
                        [d 10,true d]
                        [p 'doNext','space', ',', 'colon-word', 'create',
                        'for', 'next' p]
                    ---
                </selftest>

code depth      ( -- depth ) \ Data stack depth
                push(stack.length) end-code
code pick       ( nj ... n1 n0 j -- nj ... n1 n0 nj ) \ Get a copy of a cell in stack.
                push(tos(pop())) end-code
                /// see rot -rot roll pick
code roll       ( ... n3 n2 n1 n0 3 -- ... n2 n1 n0 n3 )
                push(pop(pop())) end-code
                /// see rot -rot roll pick

                <selftest>
                    *** pick 2 from 1 2 3 gets 1 2 3 1
                        1 2 3 0 pick 3 = depth 4 = and >r 3 drops \ true
                        1 2 3 1 pick 2 = depth 4 = and >r 3 drops \ true
                        1 2 3 2 pick 1 = depth 4 = and >r 3 drops \ true
                        r> r> r> [d true,true,true d] [p "pick",">r","r>" p]
                    *** roll 2 from 1 2 3 gets 2 3 1
                        1 2 3 0 roll 3 = depth 3 = and >r 2 drops \ true
                        1 2 3 1 roll 2 = depth 3 = and >r 2 drops \ true
                        1 2 3 2 roll 1 = depth 3 = and >r 2 drops \ true
                        r> r> r> [d true,true,true d] [p "roll" p]
                </selftest>
code .          type(pop()); end-code // ( sth -- ) Print number or string on TOS.
: space         (space) . ; // ( -- ) Print a space.
code word       ( "delimiter" -- "token" <delimiter> ) \ Get next "token" from TIB.
                push(nexttoken(pop())) end-code
                /// First character after 'word' will always be skipped first, token separator.
                /// If delimiter is RegEx '\s' then white spaces before the "token"
                /// will be removed. Otherwise, return TIB[ntib] up to but not include the delimiter.
                /// If delimiter not found then return the entire remaining TIB (can be multiple lines!).

                <selftest>
                    *** word reads "string" from TIB
                    marker ---
                    char \s word    111    222 222 === >r s" 111" === r> and \ true , whitespace 會切掉
                    char  2 word    111    222 222 === >r s"    111    " === r> and \ true , whitespace 照收
                    : </div> ;
                    char </div> word    此後到 </ div> 之
                                前都被收進，可
                                以跨行！ come-find-me-!!
                    </div> js> pop().indexOf("come-find-me-!!")!=-1 \ true
                    [d true,true,true d] [p "word" p]
                    ---
                </selftest>

: [compile]     ' , ; immediate // ( <string> -- ) Compile the next immediate word.
                /// 把下個 word 當成「非立即詞」進行正常 compile, 等於是把它變成正常 word 使用。

: compile       ( -- ) \ Compile the next word at dictionary[ip] to dictionary[here].
                r> dup @ , 1+ >r ; compile-only 

                <selftest>
                    *** [compile] compile [ ]
                    marker ---
                    : iii ; immediate
                    : jjj ;
                    : test [compile] iii compile jjj ; \ 正常執行 iii，把 jjj 放進 dictionary
                    : use [ test ] ; \ 如果 jjj 是 immediate 就可以不要 [ ... ]
                    ' use js> pop().cfa @ ' jjj = [d true d]
                    [p "[compile]",'compile', '[', ']' p]
                    ---
                </selftest>

code colon-word ( -- ) \ Decorate the last() as a colon word.
                // last().type = "colon";
                last().cfa = here;
                last().xt = colonxt;
                end-code private

: create        ( <name> -- ) \ Create a new word. The new word is a variable by default.
                BL word (create) reveal colon-word compile doVar ;

code (marker)   ( "name" -- ) \ Create marker "name". Run "name" to forget itself and all newers.
                var lengthwas = current_word_list().length; // save current word list length before create the new marker word
                execute("(create)");execute("reveal");
                last().type = "marker";
                last().herewas = here;
                last().lengthwas = lengthwas; // [x] 引進 vocabulary 之後，此 marker 在只有 forth-wordlist 時使用。有了多個 word-list 之後要改寫。
                push(nexttoken('\n|\r')); // rest of the first line
                execute("parse-help"); // ( "helpmsg" "rests" )
                tib = " " + pop() + tib.slice(ntib); ntib = 0; // "rests" + tib(ntib)
                newhelp = pop();
                var h = newhelp; // help messages packed
                if(h.indexOf("No help message")!=-1) h = "( -- ) I am a marker. I forget everything after me.";
                last().help = /* newname + " " + */ h;
                last().xt = function(){ // marker's xt restores the saved context
                    here = this.herewas;
                    order = [current = context = "forth"]; // 萬一此 marker 在引入 vocabulary 之後被 call 到。
                    for(var vid in words) if(vid != "forth") delete words[vid]; // "forth" is the only one, clean up other word-lists.
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
code next       ( -- ) \ for ... next (FigTaiwan SamSuanChen)
                comma(vm.tick("doNext")); // use original tick() to avoid warning
                dictionary[here++]=pop(); 
                end-code immediate compile-only 
code cls        ( -- ) \ Clear jeforth console screen
                vm.screenbuffer = (vm.screenbuffer==null) ? null : "";
                vm.clearScreen();
                end-code
code abort      reset() end-code // ( -- ) Reset the forth system.

code literal    ( n -- ) \ Compile TOS as an anonymous constant
                var literal = pop();
                var getLiteral = eval(
                        "var f;f=function(){push(literal)/*(" 
                        + mytypeof(literal) + ")" 
                        // avoid all "*/" and longer string
                        + literal.toString().slice(0,20).replace(/\*[/]/g,"*_/") 
                        + " */}"
                    );
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

                <selftest>
                    *** alias should create a new word that acts same
                    marker ---
                        1234 constant x ' x alias y
                        y [d 1234 d] [p "alias" p] 
                    ---
                </selftest>

\ ------------------ eforth colon words ---------------------------

' != alias <>   // ( a b -- f ) 比較 a 是否不等於 b, alias of !=.
' nonprivate alias public /// alias of nonprivate

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

                <selftest>
                    *** nip rot -rot 2drop 2dup invert negate within
                    1 2 3 4 nip \ 1 2 4
                    -rot \ 4 1 2
                    2drop \ 4
                    3 2dup \ 4 3 4 3
                    invert negate \ 4 3 4 4
                    = rot rot \ true 4 3
                    5 within \ true true
                    1 2 3 within \ true true false
                    4 2 3 within \ true true false false
                    -2 -4 -1 within \ true true false false true
                    0 -4 -1 within \ true true false false true false
                    -5 -4 -1 within \ true true false false true false false
                    [d true,true,false,false,true,false,false d]
                    [p 'rot', '-rot', '2drop', '2dup', 'negate', 'invert', 'within' p]
                </selftest>

: [']           ( <name> -- Word ) \ In colon definitions, compile next word object as a literal.
                ' literal ; immediate compile-only

                <selftest>
                    *** ['] tick next word immediately
                    marker ---
                    : x ;
                    : test ['] x ;
                    test ' x = [d true d] [p "[']" p]
                    ---
                </selftest>

: allot         here + here! ; // ( n -- ) 增加 n cells 擴充 memory 區塊

                <selftest>
                    *** allot should consume some dictionary cells
                    marker ---
                    : a ; : b ; ' b :> cfa ' a :> cfa - \ normal distance
                    : aa ;
                    10 allot
                    : bb ; ' bb :> cfa ' aa :> cfa - \ 10 more expected
                    - abs [d 10 d] [p "allot" p]
                    ---
                </selftest>

: for           ( count -- ) \ for..next loop.
                compile >r here ; immediate compile-only
                /// for ... next (count ... 2,1) but when count <= 0 still do once!!
                /// for aft ... then next (count-1 ... 2,1) but do nothing if count <= 1.
                /// Pattern : The normalized for-loop pattern. 0 based.
                ///   : test ?dup if dup for dup r@ - ( COUNT i ) . space ( COUNT ) next drop then ; 
                ///   5 test ==> 0 1 2 3 4 
                /// Pattern : The normalized for-loop pattern. Count down
                ///   : test ?dup if for r@ . space next then ;
                ///   5 test ==> 5 4 3 2 1
                /// Pattern : Normalized for-loop pattern but n based.
                ///   : test js: push(tos()+3,0) for dup r@ - ( count+n i ) . space next drop ; 
                ///   5 test ==> 3 4 5 6 7 ; 1 test ==> 1 ; 0 test ==> nothing
                /// Pattern : Simplest, fixed times.
                ///   : test 5 for r@ . space next ; 
                ///   test ==> 5 4 3 2 1
                /// Pattern : fixed times and 0 based index
                ///   : test 5 for 5 r@ - . space next ; 
                ///   test ==> 0 1 2 3 4 
                /// Pattern of break : "r> drop 0 >r" or "js: rstack[rstack.length-1]=0"
                ///   : test 10 for 10 r@ - dup . space 5 >= if r> drop 0 >r then next ; 
                ///   test ==> 0 1 2 3 4 5 
                
: begin         ( -- a ) \ begin..again, begin..until, begin..while..until..then, begin..while..repeat
                here ; immediate compile-only
: until         ( a -- ) \ begin..until, begin..while..until..then,
                compile 0branch , ; immediate compile-only
: again         ( a -- ) \ begin..again,
                compile  branch , ; immediate compile-only

                <selftest>
                    *** begin again , begin until
                    marker ---
                    : tt
                        1 0 \ index sum
                        begin \ index sum
                            over \ index sum index
                            + \ index sum'
                            swap 1+ \ sum' index'
                            dup 10 > if \ sum' index'
                                drop
                                exit
                            then  \ sum' index'
                            swap  \ index' sum'
                        again
                    ; last execute 55 = \ true
                    : ttt
                        1 0 \ index sum
                        begin \ index sum
                            over \ index sum index
                            + \ index sum'
                            swap 1+ \ sum' index'
                            swap \ index' sum'
                        over 10 > until \ index' sum'
                        nip
                    ; last execute 55 = \ true
                    [d true,true d] [p 'again', 'until', 'over', 'swap', 'dup', 'exit', 'nip' p]
                    ---
                </selftest>

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

                <selftest>
                    *** aft for then next ahead begin while repeat
                    marker ---
                    : tt 5 for r@ next ; last execute + + + + 15 = \ true
                    : ttt 5 for aft r@ then next ; last execute + + + 10 = \ true true
                    depth 2 = \ T T T
                    : tttt
                        0 0 \ index sum
                        begin \ idx sum
                            over 10 <=
                        while \ idx sum
                            over +
                            swap 1+ swap
                        repeat \ idx sum
                        nip
                    ; last execute 55 = \ T T T T
                    [d true,true,true,true d]
                    [p 'for', 'then', 'next', 'ahead', 'begin', 'while', 'repeat' p]
                    ---
                </selftest>

: char          ( <str> -- str ) \ Get character(s).
                BL word compiling if literal then ; immediate
                /// "char abc" gets "abc", Note! ANS forth "char abc" gets only 'a'.
: ?stop         if stop then ; // ( flag -- ) Stop TIB task if flag is true.
: ?dup          dup if dup then ; // ( w -- w w | 0 ) Dup TOS if it is not 0|""|false.

                <selftest>
                    *** ?dup dup only when it's true
                    1 0 ?dup \ 1 0
                    2 ?dup \ 1 0 2 2 
                    [d 1,0,2,2 d] [p "?dup" p]
                </selftest>

    \ case ... endcase definition is copied from 
    \ https://github.com/phf/forth/blob/master/x86/jonesforth.f
    \ Also thanks to FigTaiwan 吳政昌(亞斯) for the hints.

: case          ( -- 0 ) \ ( key ) case <case1> of <do case1> endof <do default> endcase 
                0 ; immediate compile-only
                /// Usage:
                /// ( key ) case 
                ///     char a of char AAAA endof
                ///     char b of char BBBB endof
                ///     char c of char CCCC endof
                ///     \ In default case, the key must be at TOS for being eaten by endcase 
                ///     char ???? swap 
                /// endcase

: of            ( -- ) \ ( key ) case <case1> of <do case1> endof <do default> endcase 
                ['] over , ['] = , [compile] if ['] drop , ; immediate compile-only
                /// see help case

: endof         ( -- ) \ ( key ) case <case1> of <do case1> endof <do default> endcase 
                [compile] else ; immediate compile-only
                /// see help case

: endcase       ( -- ) \ ( key ) case <case1> of <do case1> endof <do default> endcase 
                ['] drop , begin ?dup while [compile] then repeat ; immediate compile-only
                /// see help case

                <selftest>
                    *** case ... endcase 
                    marker ---
                    : test
                        case 
                            char a of char AAAA endof
                            char b of char BBBB endof
                            char c of char CCCC endof
                            \ In default case, the key must be at TOS for being eaten by endcase 
                            char ???? swap 
                        endcase ;
                    char a test \ ==> AAAA (string)
                    char b test \ ==> BBBB (string)
                    char c test \ ==> CCCC (string)
                    char d test \ ==> ???? (string)

                    [d 'AAAA','BBBB','CCCC','????' d]
                    [p 'case', 'of', 'endof', 'endcase' p]
                    ---
                </selftest>

: variable      ( <string> -- ) \ Create a variable.
                create 0 , [ char push(function(){last().type='colon-variable'}) jsEvalNo , ] ;
                
: +!            ( n addr -- ) \ Add n into addr, addr is a variable.
                swap over @ swap + swap ! ;
: ?             @ . ; // ( a -- ) print value of the variable.

                <selftest>
                    *** +! variable
                    marker ---
                    variable x 10 x !
                    5 x +! x @ ( 15 )
                    [d 15 d] [p 'variable', 'marker', '+!', '@', '!', '(' p]
                    ---
                </selftest>

: chars         ( n str -- ) \ Print str n times.
                swap 0 max dup 0= if exit then for dup . next drop ;

: spaces        ( n -- ) \ print n spaces.
                (space) chars ;

                <selftest>
                    *** spaces chars
                    marker ---
                    : test 3 spaces ;
                    js: vm.selftest_visible=false;vm.screenbuffer=""
                    test
                    js: vm.selftest_visible=true
                    <js> vm.screenbuffer.slice(-3)=='   '</jsV>
                    [d true d] [p 'chars',"spaces","(space)" p]
                    ---
                </selftest>

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

                <selftest>
                    *** .( ( ." .' s" s' s`
                    marker ---
                    js: vm.selftest_visible=false;vm.screenbuffer=""
                    .( ff) ( now vm.screenbuffer should be 'ff' )
                    js> vm.screenbuffer.slice(-2)=="ff" \ true
                    : test ." aa" .' bb' s' cc' . s` dd` . s" ee" . ;
                    test js> vm.screenbuffer.slice(-10)=="aabbccddee" \ true
                    js: vm.selftest_visible=true
                    [d true,true d] [p '(', '."', ".'", "s'", "s`", 's"' p]
                    ---
                </selftest>

: count         ( string -- string length ) \ Get length of the given string
                [ s" push(function(){push(tos().length)})" jsEvalNo , ] ;

                <selftest>
                    *** count
                        s" abc" count depth
                        [d "abc",3,2 d] [p "count" p]
                </selftest>

code accept     push(false) end-code // ( -- str T|F ) Read a line from terminal. A fake before I/O ready.
: refill        ( -- flag ) \ Reload TIB from stdin. return 0 means no input or EOF
                accept if [ s" push(function(){tib=pop();ntib=0})" jsEvalNo , ] 1 else 0 then ;

: [else] ( -- ) \ 丟掉以下 TIB 到 "[else]" or "[then]" 為止，考慮了中間的 nested 結構。
                1 \ ( [if] structure nested level )
                begin \ level
                    begin \ ( level )
                        BL word count \ (level $word len ) 取出 [if] 之後 word 下一個 
                    while \ (level $word) 查看這個每個要丟掉的 word 做 nested 處裡。
                        dup s" [if]" = if \ ( level $word )
                            drop 1+ \ ( level' ) 如果這個 word 是 [if] 就把它丟掉，再進一層
                        else \ ( level $word ) 不是 [if] 那麼是否 [else]
                            dup s" [else]" = if \ (level $word)
                                drop \ ( level ) 丟掉 "[else]"
                                1- dup if 1+ then \ (level') level==1 時把它變成 0 準備走出 [if] 結構，
                                \ 其他 level 值則不變，繼續處理剩下的 [if] 結構。
                            else \ level $word, 不是 [else] 那麼是否 [then]
                                s" [then]" = if \ (level)
                                    1- \ level' \ (level') 如果這個 word 是 [then] 就剝掉一層
                                then \ (level')
                            then \ level'
                        then \ level'
                        \ 整個結構的正常出口在這裡
                        ?dup if else exit then 
                        \ 已經到最外層就離手走出 [if] 結構，否則繼續看下一個 word.
                    repeat \ (level) 回頭重來,看 TIB 裡下一個 word。
                    drop   \ (level) TIB 空了，把 null string 丟掉，留下 level。
                refill not until \ reload TIB 然後繼續
                \ level, TIB 斷尾了，可能是 ^z ^d 之類，做不下去了。
                drop \ 把 TIB 斷尾中止後剩下的 level 丟掉。
                ; immediate
                
: [if]          ( flag -- ) \ Conditional compilation [if] [else] [then]
                if else [compile] [else] then \ skip everything down to [else] or [then] when flag is not true.
                ; immediate
                /// [if] 用來把 iTIB 視條件跳到這個 [if] 之後或 [else] 之後。

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

                <selftest>
                    *** value and to work together
                    marker -%-%-%-%-%-
                    112233 value x x 112233 = \ true
                    445566 to x x 445566 = \ true
                    : test 778899 to x ; test x 778899 = \ true
                    -%-%-%-%-%-
                    [d true,true,true d] [p 'value','to' p]
                </selftest>
                
\ This word works fine. But doing this for letting doNext be a private is carried way too far.
\ : next        ( -- ) \ for ... next (FigTaiwan SamSuanChen)
\               ['] doNext , js: dictionary[here++]=pop() ; immediate compile-only
\               \ Redefine after js: and ['] to allow doNext be private

: "msg"abort    ( "errormsg" -- ) \ Panic with error message and abort the forth VM
                js: panic(pop()+'\n') abort ; nonprivate
                \ needed to compose variables into the errormsg

: abort"        ( <msg> -- ) \ Through an error message and abort the forth VM
                char " word literal BL word drop compile "msg"abort ;
                immediate compile-only

: "msg"?abort   ( "errormsg" flag -- ) \ Conditional panic with error message and abort the forth VM
                if "msg"abort else drop then ; nonprivate
                \ needed to compose variables into the errormsg

: ?abort"       ( f <errormsg> -- ) \ Conditional abort with an error message.
                char " word literal BL word drop
                compile swap compile "msg"?abort ;
                immediate compile-only

\ 其實所有用 word 取 TIB input string 的 words， 用 file 或 clipboard 輸入時， 都是可
\ 以跨行的！只差用 keyboard 輸入時受限於 console input 一般都是以「行」為單位的，造成
\ TIB 只能到行尾為止後面沒了，所以才會跨不了行。將來要讓 keyboard 輸入也能跨行時，就
\ 用 text。

\ 費了一番功夫寫就能 nested 的 <text> 及 <comment> , 開發心得在 Ynote 上
\ search "jeforth.3we design a nesting supported〈text〉also〈comment〉"

variable '<text> private
                // ( -- <text> ) Variable reference to the <text> Word object, for indirect call.
                    
: (<text>)      ( <text> -- "text"+"</text>" ) \ Auxiliary <text>, handles nested portion
                '<text> @ execute ( string ) \ 此時 TIB 非 </text> 即行尾
                BL word char </text> = ( string is</text>? )
                if \ 剛才撞上了 </text> ( string )
                    s" </text> " + ( string1' )
                then ; private
                /// (<text>) is almost same as <text> but it consumes the 
                /// next </text> in TIB and returns <text> + "</text>"

: <text>        ( <text> -- "text" ) \ Get multiple-line string, can be nested.
                char </text>|<text> word ( string1 )
                \ 撞到 delimiter 停下來非 <text> 即 </text> 要不就是行尾
                BL word dup char <text> = ( string1 deli is<text>? )
                if \ 剛才撞上了 <text> ( string1 deli )
                    drop s" <text> " + ( string1' )
                    (<text>) ( string1' string2 ) + 
                    [ last literal ] execute ( string1'' string3 ) + ( string )
                else \ 剛才撞上了 </text> 或行尾  ( string1 deli )
                    char </text> swap over = ( string1 "</text>" is</text>? ) 
                    if js: ntib-=pop().length ( string1 )
                    else drop then  ( string1 )
                then ; immediate last '<text> !
                /// If <text> hits <text> in TIB then it returns 
                /// string1 +  "<text>" + (<text>) + <text> 
                /// leaves the next </text> in TIB
                /// Colon definition 中萬一前後不 ballance 會造成 colon definition
                /// 不如預期結束而停留在 compiling state 裡等 closing </text> 的現象。
                
: </text>       ( "text" -- ... ) \ Delimiter of <text>
                compiling if literal then ; immediate
                /// Usage: <text> word of multiple lines </text>

\ Ready to add comment to 'privacy' 
<text> 
 Example 'privacy' definition for a vocabulary. Assume current == context.
 false constant privacy private // ( -- true ) All words in this module are public
 true  constant privacy private // ( -- true ) All words in this module are private
</text> ' privacy :: comment=pop()
                
\ If <comment> hits <comment> in TIB then it drops string1 
\ and does <comment> and does again <comment>

: <comment>     ( <comemnt> -- ) \ Can be nested
                char <comment>|</comment> word drop ( empty )
                BL word char <comment> = ( is<comment>? )
                if \ 剛才撞上了 <comment> ( empty )
                    [ last literal ] dup execute execute
                then ; immediate
                
: </comment>    ; // ( -- ) \ Delimiter of <comment>

                <selftest>
                    *** <comment>...</comment> can be nested now
                    <comment> 
                        aaaa <comment> bbbbbb </comment> cccccc 
                    </comment> 
                    111 222 <comment> 333 </comment> 444
                    [d 111,222,444 d] [p '<comment>', '</comment>', '::' p]
                </selftest>
                
: <js>          ( <js statements> -- "statements" ) \ Evaluate JavaScript statements
                char </js>|</jsV>|</jsN>|</jsRaw> word ; immediate

: </jsN>        ( "statements" -- ) \ No return value
                compiling if jsFuncNo , else jsEvalNo then ; immediate
                /// 可以用來組合 JavaScript function
                last alias </js>  immediate

: </jsV>        ( "statements" -- ) \ Retrun the value of last statement
                compiling if jsFunc , else jsEval then ; immediate
                /// 可以用來組合 JavaScript function

: trim          ( string -- string' ) \ Remove leading&ending white spaces of the multiple line string.
                \ remove 頭尾 whitespaces. 但 .trim() 舊 JScript v5.6 未 support
                dup if <js> pop().toString().replace(/(^\s*)/,'').replace(/(\s*$)/,'') </jsV>
                then ;
                /// If TOS is not a string then do nothing.
                /// NOT every line of a multiple line string, only the begin/end of it.
                /// Work with </o> </h> </e> 前置 white spaces 會變成 [object Text] 必須消除。

\ 2016/12/21 Now constant & value support private and direct-access through vm[vid].name 
\ : constant    ( n <name> -- ) \ Create a 'constnat'
\               BL word (create) <js> 
\                   last().type = "constant";
\                   var s = '(function(){push(vm["_vid_"]["_name_"])})';
\                   var vid = current.replace(/"/g,"\\\"");
\                   var name = last().name.replace(/"/g,"\\\"");
\                   s = s.replace(/_vid_/,vid).replace(/_name_/,name);
\                   last().xt = eval(s);
\                     if(vm[current]==undefined) vm[current]={};
\                   vm[current][last().name] = pop();
\               </js> reveal ; 
\ 2020/07/08 17:17:53 use value word directly for the the variable value instead of putting in current vocabulary 

: constant      ( n <name> -- ) \ Create a 'constnat'
                BL word (create) <js> 
                    last().type = "constant";
                    var s = '(function(_me){push(_me.value)})';
                    last().xt = eval(s);
                    last().value = pop();
                </js> reveal ; 

: value         ( n <name> -- ) \ Create a 'value' variable.
                constant last :: type='value' ; 
                
\ : to          ( n <value> -- ) \ Assign n to <value>.
\               ' ( n word ) 
\                 <js> if (tos().type!="value") panic("Error! Assigning to a none-value.\n",'error') </js>
\               compiling if ( n word ) 
\                   <text>
\                       (function(){/* to */ vm["_vid_"]["_name_"]=pop()})
\                   </text> trim ( n word s ) 
\                     <js> 
\                         var s = pop(); // ( n word )
\                         var vid = tos().vid.replace(/"/g,"\\\"");
\                         var name = pop().name.replace(/"/g,"\\\"");
\                         s = s.replace(/_vid_/,vid).replace(/_name_/,name);
\                         push(eval(s));
\                   </js> ( n xt ) , 
\               else ( n word )
\                   js: vm[tos().vid][pop().name]=pop()
\               then ; immediate

\ 2020/07/08 17:17:53 use value word directly for the the variable value instead of putting in current vocabulary 
: to            ( n <value> -- ) \ Assign n to <value>.
                ' ( n word ) 
                <js> if (tos().type!="value") panic("Error! Assigning to a none-value.\n",'error') </js>
                compiling if ( word ) literal ( empty )
                    <text>
                        (function(){/* to */ pop().value=pop()})
                    </text> trim ( s ) 
                    <js> 
                        var s = pop(); // ( n word )
                        push(eval(s));
                    </js> ( xt ) , ( empty )
                else ( n word )
                    :: value=pop() ( empty ) 
                then ; immediate

                <selftest>
                    *** constant value and to
                    marker ---
                    112233 constant x
                    x value y
                    x y = \ true
                    332211 to y x y = \ false
                    ' x :> type=="constant" \ true
                    ' y :> type=="value" \ true
                    [d true,false,true,true d] [p "constant","value","to" p]
                    ---
                </selftest>

\ 目前 Base 切換只影響 .r .0r 的輸出結果。
\ JavaScript 輸入用外顯的 0xFFFF 形式，用不著 hex decimal 切換。
\ 10 value base // ( -- base ) decimal base is 10, hex base is 16, can be any number.

code decimal    vm.forth.base=10 end-code // ( -- ) 設定數值以十進制印出 *** 20111224 sam
                last execute 
code hex        vm.forth.base=16 end-code // ( -- ) 設定數值以十六進制印出 *** 20111224 sam
code base@      push(vm.forth.base) end-code // ( -- n ) 取得 base 值 n *** 20111224 sam
code base!      vm.forth.base=pop() end-code // ( n -- ) 設定 n 為 base 值 *** 20111224 sam

                <selftest>
                    *** hex decimal base@ base!
                        decimal base@ 0x0A = \ true
                        10 0x10 = \ false
                        hex base@ 0x10 = \ true
                        10 0x10 = \ false !!!! JavaScript 輸入用外顯的表達 10 就是十不會變，這好！
                        0x0A base!
                        base@ 10 = \ true
                        [d true,false,true,false,true d]
                        [p 'decimal','base@', 'base!', 'base' p]
                </selftest>

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
                    setTimeout(resume,delay);
                    function resume() { 
                        if(typeof(tib)!="undefined") {
                            tib = tibwas; ntib = ntibwas;
                        } else debugger;
                        outer(ipwas); // resume to the below ending 'ret' and then go through the TIB.
                    }
                </js> ;
                /// nap 沒有保留外顯的 timeoutId 故不能中止，但也不會堆積在 vm.g.setTimeout.registered() 裡。

: cr            js: type("\n") ; // ( -- ) 到下一列繼續輸出 *** 20111224 sam
                \ 個別 quit.f 裡重定義成 : cr js: type("\n") 1 nap js: window.scrollTo(0,endofinputbox.offsetTop) ;

code cut        ( -- ) \ Cut off used TIB.
                tib=tib.slice(ntib);ntib=0 end-code
                /// "cut ~ 10 nap rewind" repeat running the TIB.
                /// See also <task>

: -word         ( -- array[] ) \ Get TIB used tokens.
                <js> var a=('h '+tib.substr(0,ntib)+' t').split(/\s+/); // 加上 dummy 頭尾再 split 以統一所有狀況。
                a.pop(); a.shift(); /* 丟掉 dummy 頭尾巴 */ a</jsV> ;
                /// 跟 word 有點相反的味道，故以 -word 為名。

: rewind        ( -- ) \ Rewind TIB so as to repeat it. 'stop' to terminate.
                -word <js> var a=pop(),flag=false; for(var i in a) flag = flag || a[i]=='nap'; flag </jsV>
                not ?abort" Warning! no 'nap' in command line, suspicious of infinite loop." js: ntib=0 ;
                /// "cut ~ 10 nap rewind" repeat running the TIB.
                /// See also <task>
                
: ?rewind       ( boolean -- ) \ Conditional rewind TIB so as to repeat it. 'stop' to terminate.
                if rewind then ;

\ To TIB command line TSRs, the tib/ntib is their only private storage. So save-restore and
\ loop back information must be using the tib. That's why we have >t t@ and t> 

code >t         ( int -- ) \ Push the integer to end of TIB as a comment
                tib += "\n\\ " + String.fromCharCode(pop());
                end-code

code t@         ( -- int ) \ Get integer from end of the TIB 
                var value = tib.charCodeAt(tib.length-1);
                push(value); 
                end-code

: t>            ( -- int ) \ Pop integer from end of the TIB 
                t@ ( int ) js: tib=tib.slice(0,-4) ;
                \ the -4 is \n \ space and the int, total 4.

: [begin]       ( -- ) \ [begin]..[again], [begin].. flag [until]
                js> ntib >t ; interpret-only
                /// Don't forget some nap.
                /// 'stop' command or {Ctrl-Break} hotkey to abort.
                /// ex. [begin] .s js> rstack . cr 1000 nap [again]
                
: [again]       ( -- ) \ [begin]..[again]
                t@ js: ntib=pop() ; interpret-only
                /// Don't forget some nap.
                /// 'stop' command or {Ctrl-Break} hotkey to abort.


: [until]       ( flag -- ) \ [begin].. flag [until]
                if  t> drop else [compile] [again] then ; interpret-only
                /// Don't forget some nap.
                /// 'stop' command or {Ctrl-Break} hotkey to abort.
                /// ex. [begin] now t.second dup . space 5 mod not 100 nap [until]

: [for]         ( count -- ) \ (T -- ntib count ) [for]..[next] 
                [compile] [begin] >t ; interpret-only
                /// Instead of using rstack, [for] loop uses tib tail to save-restore 
                /// the loop back address and the count. Thus >t t> and t@ replace
                /// >r r> and r@ respectively.
                /// Pattern : The normalized for-loop pattern. 0 based.
                ///   5 ?dup [if] dup [for] dup t@ - ( COUNT i ) . space ( COUNT ) [next] drop [then]
                ///   ==> 0 1 2 3 4
                /// Pattern : Normalized for-loop pattern but n(66) based.
                ///   5 js: push(tos()+66,0) [for] dup t@ - ( count+n i ) . space [next] drop
                ///   ==> 66 67 68 69 70  OK        
                /// Pattern : Simplest, fixed times.
                ///   5 [for] t@ . space [next]
                ///   ==> 5 4 3 2 1
                /// Pattern : fixed times and 0 based index
                ///   5 [for] 5 t@ - . space [next]
                ///   ==> 0 1 2 3 4
                /// Pattern of break : "t> drop 0 >t" or "js: rstack[rstack.length-1]=0"
                ///   10 [for] 10 t@ - dup . space 5 >= [if] t> drop 0 >t [then] [next]
                ///   ==> 0 1 2 3 4 5
                /// Don't forget some nap.
                /// 'stop' command or {Ctrl-Break} hotkey to abort.

: [next]        ( -- ) \ (T ntib count -- ntib count-1 | empty ) [for]..[next]
                t> 1- dup >t js> pop()>0 ( count>0 ) if 
                    \ rewind
                    t> t> js: ntib=tos() >t >t 
                else
                    \ exit the for loop
                    t> t> 2drop \ drop the count and loop back ntib address
                then ; interpret-only
                /// Don't forget some nap.
                /// 'stop' command or {Ctrl-Break} hotkey to abort.

code (run:)     ( "..if.." -- "..[if].." ) \ Run string with "if","begin","for" in interpret mode
                var ss = pop();
                var result = ss
                    .replace(/(^|\s)(if|else|then|begin|again|until|for|next)(\s|$)/mg,"$1[$2]$3")
                    .replace(/(^|\s)(if|else|then|begin|again|until|for|next)(\s|$)/mg,"$1[$2]$3");
                    // 連做兩次解決 if else then 翻成 [if] else [then] 的現象。 
                push(result);execute("tib.insert"); // 不能用 dictate(), 多重 suspend 時，會有怪現象。
                end-code
                /// Replace "if", "for", "begin", .. etc to "[if]", "[for]", "[beign]" .. etc
                /// I like to use "if" in interpret mode directly instead of "[if]" and
                /// to merge them is difficult to me so far. So I defined this word.
: run:          ( <string> -- ... ) \ Run one-liner with "if","begin","for", in interpret mode
                CR word (run:) ; interpret-only
                /// To run multiple lines use <text>...</text> (run:) or "run>" instead of "run:".
                /// run: is oneliner. I think run: may be used in ~.f files while run> certainly can't.
: run>          ( <string> -- ... ) \ Run multiple lines with "if","begin","for", in interpret mode
                js> push(ntib);ntib=tib.length;tib.slice(pop()) (run:) ; interpret-only
                /// run> go through all the rest of the inputbox; 
                /// run: is oneliner. I think run: may be used in ~.f files while run> certainly can't.

\ ------------------ Tools  ----------------------------------------------------------------------
                
code int        push(parseInt(pop())) end-code   // ( float|string -- integer|NaN )
code float      push(parseFloat(pop())) end-code // ( string -- float|NaN ) 

                <selftest>
                    *** int 3.14 is 3, 12.34AB is 12
                    3.14 int char 12.34AB int
                    [d 3,12 d] [p "int" p]
                </selftest>

: random        ( -- 0~1 )
                js> Math.random() ;

                <selftest>
                    *** random is (0...1)
                    random 0 > random 1 < and
                    random 0 > random 1 < and
                    random 0 > random 1 < and
                    random 0 > random 1 < and
                    [d true,true,true,true d] [p "random" p]
                </selftest>

: nop           ; // ( -- ) No operation.
: drops         ( ... n -- ... ) \ Drop n cells from data stack.
                1+ js> stack.splice(stack.length-tos(),pop()) drop ;
                /// We need 'drops' <js> sections in a colon definition are easily to have
                /// many input arguments that need to be dropped.

                <selftest>
                    *** drops n data stack cells ...
                        1 2 3 4 5 2 drops [d 1,2,3 d] [p "drops" p]
                </selftest>

\ JavaScript's hex is a little strange.
\ Example 1: -2 >> 1 is -1 correct, -2 >> 31 is also -1 correct, but -2 >> 32 become -2 !!
\ Example 2: -1 & 0x7fffffff is 0x7fffffff, but -1 & 0xffffffff will be -1 !!
\ That means hex is 32 bits and bit 31 is the sign bit. But not exactly, because 0xfff...(over 32 bits)
\ are still valid numbers. However, my job is just to print hex correctly by using .r and
\ .0r. So I simply use a workaround that prints higher 16 bits and then lower 16 bits respectively.
\ So JavaScript's opinion about hex won't bother me anymore.

code (.r)       ( num|str n -- "  num|str" ) \ Right adjusted num|str in n characters (FigTaiwan SamSuanChen)
                var n=pop(); var i=pop();
                if(typeof i == 'number') {
                    if(vm.forth.base == 10){
                        i=i.toString(vm.forth.base);
                    }else{
                        i = (i >> 16 & 0xffff || "").toString(vm.forth.base) + (i & 0xffff).toString(vm.forth.base);
                    }
                }
                n=n-i.length;
                if(n>0) do {
                    i=" "+i;
                    n--;
                } while(n>0);
                push(i);
                end-code
                
: .r            ( num|str n -- ) \ Print right adjusted num|str in n characters (FigTaiwan SamSuanChen)
                (.r) . ;
                
code (.0r)      ( num|str n -- "0000num|str" ) \ Right adjusted print num|str in n characters (FigTaiwan SamSuanChen)
                var n=pop(); var i=pop();
                var minus = "";
                if(typeof i == 'number') {
                    if(vm.forth.base == 10){
                        if (i<0) minus = '-';
                        i=Math.abs(i).toString(vm.forth.base);
                    }else{
                        i = (i >> 16 & 0xffff || "").toString(vm.forth.base) + (i & 0xffff).toString(vm.forth.base);
                    }
                }
                n=n-i.length - (minus?1:0);
                if(n>0) do {
                    i="0"+i;
                    n--;
                } while (n>0);
                // type(minus+i);
                push(minus+i);
                end-code
                
: .0r           ( num|str n -- ) \ Right adjusted print num|str in n characters (FigTaiwan SamSuanChen)
                (.0r) . ;
                /// Negative numbers are printed in a strange way. e.g. "0000-123".

                <selftest>
                    <comment> .r 是 FigTaiwan 爽哥那兒抄來的。 JavaScript 本身就有 
                    number.toString(base) 可以任何 base 印出數值。base@ base! hex 
                    decimal 等只對 .r .0r 有用。輸入時照 JavaScript 的慣例，數字就
                    是十進位，0x1234 是十六進位，已經足夠。 .r .0r 很有用, .s 的定
                    義就是靠他們。
                    </comment>
                    *** .r .0r can print hex-decimal
                    marker ---
                    js: vm.selftest_visible=false;vm.screenbuffer=""
                    decimal  -1 10  .r <js> vm.screenbuffer.slice(-10)=='        -1'</jsV> \ true
                    hex      -1 10  .r <js> vm.screenbuffer.slice(-10)=='  ffffffff'</jsV> \ true
                    decimal  56 10 .0r <js> vm.screenbuffer.slice(-10)=='0000000056'</jsV> \ true
                    hex      56 10 .0r <js> vm.screenbuffer.slice(-10)=='0000000038'</jsV> \ true
                    decimal -78 10 .0r <js> vm.screenbuffer.slice(-10)=='-000000078'</jsV> \ true
                    hex     -78 10 .0r <js> vm.screenbuffer.slice(-10)=='00ffffffb2'</jsV> \ true
                    js: vm.selftest_visible=true
                    [d true,true,true,true,true,true d] 
                    [p 'decimal', 'hex', '.0r', '.r' p]
                    ---
                </selftest>

code dropall    stack=[] end-code // ( ... -- ) Clear the data stack.

                <selftest>
                    *** dropall clean the data stack
                    1 2 3 4 5 dropall depth 0= [d true d] [p "dropall","0=" p]
                </selftest>

code (ASCII)    push(pop().charCodeAt(0)) end-code // ( str -- ASCII ) Get str[0]'s ASCII code.
code ASCII>char ( ASCII -- 'c' ) \ ASCII code number to character
                push(String.fromCharCode(pop())) end-code
                /// 65 ASCII>char tib. \ ==> A (string)
: ASCII         ( <str> -- ASCII ) \ Get <str>[0]'s ASCII code.
                BL word (ASCII) compiling if literal then
                ; immediate

                <selftest>
                    *** ASCII (ASCII) ASCII>char
                    marker ---
                    char abc (ASCII) ( 97 )
                    98 ASCII>char ( b )
                    : test ASCII c ; test ( 99 )
                    [d 97,'b',99 d] [p '(ASCII)', 'ASCII>char', "ASCII" p]
                    ---
                </selftest>

code .s         ( ... -- ... ) \ Dump the data stack.
                var count=stack.length, basewas=vm.forth.base;
                if(count>0) for(var i=0;i<count;i++){
                    if (typeof(stack[i])=="number") {
                        push(stack[i]); push(i); dictate("decimal 7 .r char : . space dup decimal 11 .r space hex 11 .r char h .");
                    } else {
                        push(stack[i]); push(i); dictate("decimal 7 .r char : . space .");
                    }
                    type(" ("+mytypeof(stack[i])+")\n");
                } else type("empty\n");
                vm.forth.base = basewas;
                end-code

                <selftest>
                    *** .s is probably the most used word
                    marker ---
                    js: vm.selftest_visible=false;vm.screenbuffer=""
                    32424 -24324 .s
                    js: vm.selftest_visible=true
                    <js> vm.screenbuffer.indexOf('32424')    !=-1 </jsV> \ true
                    <js> vm.screenbuffer.indexOf('7ea8h')    !=-1 </jsV> \ true
                    <js> vm.screenbuffer.indexOf('-24324')   !=-1 </jsV> \ true
                    <js> vm.screenbuffer.indexOf('ffffa0fch')!=-1 </jsV> \ true
                    <js> vm.screenbuffer.indexOf('2:')       ==-1 </jsV> \ true
                    [d 32424,-24324,true,true,true,true,true d] [p ".s" p]
                    ---
                </selftest>

code wordhash>array ( "vid" -- array ) \ Retrive a VID list from the recent active words hash
                var vid=pop(), aa = [], bb = [], j=1; // vid[0] always 0, start from 1.
                // get the raw list
                for (var i in wordhash) 
                    if (wordhash[i].vid==vid) aa.push(wordhash[i]);
                // sort aa by wid to be bb
                while (aa.length) { 
                    for (i=0; i<aa.length; i++) {
                        if (aa[i].wid<=j) {
                            bb.push(aa.splice(i,1)[0]);
                            break;
                        }
                    }
                    if (vm.debug && i>=aa.length) 
                        // warning, rare case like ' code.wid is 7 because reDef'ed
                        debugger; 
                    j += 1;
                }
                push(bb);
                end-code
                
: word_select   ( "vid" "pattern" "option" -- word[] ) \ Get an array of words, name/help/comments screened by pattern.
                rot dup wordhash>array ( "pattern" "option" "vid" array )
                <js> 
                var word_list = pop();
                var vid = pop();
                var option = pop();
                var pattern = pop();
                var result = [];
                var isContext = order[order.length-1] == vid;
                // Remove private words unless in context
                // for (var i=0; i<words[vid].length; i++) {
                //     if (isContext || !words[vid][i].private) 
                //         word_list.push(words[vid][i]);
                // }
                for(var i=0; i<word_list.length; i++) {
                    if (!pattern) { 
                        // no pattern is all public
                        result.push(word_list[i]); 
                        continue; 
                    } 
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
                        case "-f": // -f for fuzzy search in name, help, and comment.
                            var flag =  (word_list[i].name.toLowerCase().indexOf(pattern.toLowerCase()) != -1 ) ||
                                        ((word_list[i].help||"").toLowerCase().indexOf(pattern.toLowerCase()) != -1 ) ||
                                        ((word_list[i].comment||"").toLowerCase().indexOf(pattern.toLowerCase()) != -1);
                            if (flag) {
                                result.push(word_list[i]);
                            }
                            break;
                        default: // any other option, includes -N, for exactly name only, case sensitive.
                            if (word_list[i].name==pattern) {
                                result = [word_list[i]];
                            }
                    }
                }
                push(result); </js> ;
                /// Options: 
                /// -f pattern matches all names, helps and comments. Case insensitive.
                /// -n pattern in name. Case insensitive.
                /// -t pattern in type. Case insensitive. 
                /// -T pattern is exact type.
                /// "" pattern is exact name. 


: words         ( <["pattern" [-t|-T|-n|-f]]> -- ) \ List all words or words screened by spec.
                js> context CR word ( forth line )
                <js> pop().replace(/\s+/g," ").split(" ")</jsV> ( forth [pattern,option,rests] )
                js> tos()[0] swap js> tos()[1] nip word_select <js>
                    var word_list = pop();
                    var w = "";
                    for (var i=0; i<word_list.length; i++) w += word_list[i].name + " ";
                    type(w);
                </js> ;
                /// Original version in jeforth.f
                last :: comment+=tick("word_select").comment
                /// An empty pattern matches all words.

: (help)        ( "word-list" "[pattern [-t|-T|-n|-f]]" -- "msg" ) \ Get help message of screened words
                <js> pop().replace(/\s+/g," ").split(" ")</jsV> ( voc [pattern,option,rests] )
                js> tos()[0] swap js> tos()[1] nip ( forth pattern option ) word_select ( [words...] )
                <js>
                    var word_list = pop();
                    for (var ss="",i=0; i<word_list.length; i++) {
                        ss += word_list[i]+"\n"; // help of the word
                        if (typeof(word_list[i].comment) != "undefined") ss += word_list[i].comment;
                    };ss
                </jsV> ;
                /// Original version in jeforth.f
                last :: comment+=tick("word_select").comment

: help          ( <["pattern" [-t|-T|-n|-f]]> -- ) \ Print the help of screened words
                js> context CR word ( voc pattern )
                js> tos().length if 
                    dup char * = if drop "" then (help) .
                else
                    2drop version drop
                    [ \ 先存起來,供往後新版引用.
                        <text>
                        
                            Basic commands that bring you the whole jeforth world.
                            
                            -- words --
                            Try 'words' command to view all words. It has following options:
                            > words [<pattern> [-n|-N|-t|-T]] 
                            that prints not all but matched words. Try,
                            > help words
                            to view more help of 'words' command. 
                            
                            -- help --
                            You are viewing 'help' now. Yet it has more options, try
                            > help  [<pattern> [-n|-N|-t|-T]]
                            that prints the help of matched words.
                            > help *
                            that prints all words' help.
                            
                            -- see --
                            Use 'see' command to view the definition of a word.
                            > see <word> 
                        </text> <js> pop().replace(/^[ \t]*/gm,'')</jsV> 
                        last :: general_help=pop()
                        last literal
                    ] :> general_help . cr
                then ;
                /// Original version in jeforth.f
                last :: comment+=tick("word_select").comment
                /// A pattern of star '*' matches all words.
                /// Example: 
                ///   help * <-- show help of all words
                ///   help * -N <-- show help of '*' command
                \ 2016/2/2 改成以原來 -N 為默認 option. -N 未定義屬 default 結果還是原來 -N 的效果。
                
                <selftest>
                    <text>
                    本來 words help 都接受 RegEx 的，可是不好用。現已改回普通 non RegEx pattern. 只動
                    word_select 就可以來回修改成 RegEx/non-RegEx.
                    </text> drop

                    *** help words word_select
                    marker ---
                    : test ; // testing help words and word_select 32974974
                    /// 9247329474 comment
                    js: vm.selftest_visible=false;vm.screenbuffer=""
                    \ help test -N
                    help test
                    <js> vm.screenbuffer.indexOf('32974974') !=-1 </jsV> \ true
                    <js> vm.screenbuffer.indexOf('9247329474') !=-1 </jsV> \ true
                    words 9247329474 -f
                    <js> vm.screenbuffer.indexOf('test') !=-1 </jsV> \ true
                    words test -f
                    <js> vm.screenbuffer.indexOf('<selftest>') !=-1 </jsV> \ true
                    <js> vm.screenbuffer.indexOf('***') !=-1 </jsV> \ true
                    js: vm.selftest_visible=true;
                    [d true,true,true,true,true d] [p 'word_select', 'words' p]
                    ---
                </selftest>

code bye        ( ERRORLEVEL -- ) \ Exit to shell with TOS as the ERRORLEVEL.
                // 這些都無效，最後靠 WMI 達成傳回 errorlevel // var errorlevel = pop(); window.errorlevel = typeof(errorlevel)=='number' ? errorlevel : 0; 
                vm.bye();
                end-code

code readTextFile ( "pathname" -- string ) \ Return a string, "" if failed
                try {
                    var data = vm.readTextFile(pop()); 
                } catch (err) {
                    data = "";
                }
                push(data);
                end-code

: readTextFileAuto ( "pathname" -- string ) \ Search and read, panic if failed.
                js> vm.path.slice(0) \ this is the way javascript copy array by value
                over char readTextFile execute ( call by name for 3ce's reDef'ed readTextFile )
                js> tos()!="" if nip nip exit then drop
                js> tos().length for aft ( -- fname [path] )
                    js> tos().pop()+'/'+tos(1) 
                    char readTextFile execute 
                    js> tos()!=""
                    if ( -- fname [path] file )
                        nip nip r> drop exit \ for..next loop 裡面不能光 exit !!!
                    then drop ( -- fname [path] )
                then next ( -- fname [path] )
                drop "" swap <js> panic("Error! File " + pop() + " not found!\n",true) </js> ;

code writeTextFile ( string "pathname" -- ) \ Write string to file. Panic if failed.
                vm.writeTextFile(pop(),pop())
                end-code

\ code tib.append   ( "string" -- ) \ Append the "string" to TIB
\               tib += " " + (pop()||""); end-code
\               /// VM suspend-resume doesn't allow multiple levels of dictate() so
\               /// we need tib.append or tib.insert.

code tib.append ( "string" -- ) \ Append the "string" to TIB
                tib = tib.slice(ntib); ntib = 0;
                tib += " " + (pop()||""); end-code
                /// VM suspend-resume doesn't allow multiple levels of dictate() so
                /// we need tib.append or tib.insert.

                <comment>
                    靠！ tib.append 沒辦法測呀！到了 terminal prompt 手動這樣測，
                    OK 111 s" 12345" tib.append 222
                    OK .s
                        0:         111          6fh (number)
                        1:         222          deh (number)
                        2:       12345        3039h (number) <=== appended to the ending
                </comment>

\ code tib.insert   ( "string" -- ) \ Insert the "string" into TIB
\               var before = tib.slice(0,ntib), after = tib.slice(ntib);
\               tib = before + " " + (pop()||"") + " " + after; end-code
\               /// VM suspend-resume doesn't allow multiple levels of dictate() so
\               /// we need tib.append or tib.insert.

code tib.insert ( "string" -- ) \ Insert the "string" into TIB
                tib = tib.slice(ntib); ntib = 0;
                tib = (pop()||"") + " " + tib; end-code
                /// VM suspend-resume doesn't allow multiple levels of dictate() so
                /// we need tib.append or tib.insert.
: sinclude.js   ( "pathname" -- ) \ Include JavaScript source file
                readTextFileAuto js: eval(pop()) ;
: include.js    ( <pathname> -- ) \ Include JavaScript source file
                BL word sinclude.js ;

                char -=EOF=- ( eof ) <js> (new RegExp(tos()))</jsV> ( eof /eof/ )
                js> ({regex:pop(),pattern:pop()}) constant EOF // ( -- {regex,pattern} ) End of file pattern and RegExp
                
: sinclude      ( "pathname" -- ... ) \ Lodad the given forth source file.
                readTextFileAuto EOF ( file EOF )
                <js> 
                    var EOF = pop()
                    var s = pop()
                    var ss = (s+'x').slice(0,s.search(EOF.regex))
                             + '\n\\ '
                             + EOF.pattern
                             + '\n';
                    // The +'x' is a perfect trick, will be cut both EOF mark exists or not. 
                    // The last \n 避免最後是 \ comment 時吃到後面來
                    if (s) push(ss); else push(""); // skip if file not found
                </js> 
                tib.insert ;
                /// Cut after EOF and append EOF back to guarantee an EOF exists
                /// So, if a ~.f file is copy-paste to jeforth.3we input box, 
                /// instead of through sinclude, then EOF not found will be a problem 
                /// when it is expected in, i.e. source-code-header. Add EOF manually
                /// is the solution.

: include       ( <filename> -- ... ) \ Load the source file
                BL word sinclude ; interpret-only
                
code obj>keys   ( obj -- keys[] ) \ Get all keys of an object.
                var obj=pop();
                var array = [];
                for(var i in obj) array.push(i);
                push(array);
                end-code

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
                }; end-code private

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
                
                <selftest>
                    *** d dump
                    js: vm.selftest_visible=false;vm.screenbuffer=""
                    d 0
                    js: vm.selftest_visible=true
                    <js> vm.screenbuffer.indexOf('00000: 0 (number)') !=-1 </jsV> \ true
                    [d true d] [p 'dump', 'd' p]
                </selftest>

code (see)      ( thing -- ) \ See into the given word, object, array, ... anything.
                var w=pop();
                var basewas = vm.forth.base; vm.forth.base = 10;
                if (!(w instanceof Word)) {
                    type(JSON.stringify(w,"\n","\t"));  // none forth word objects. 意外的好處是不必有 "unkown word" 這種無聊的錯誤訊息。
                }else{
                    for(var i in w){
                        if (typeof(w[i])=="function") continue;
                        if (i=="comment") continue;
                        push(i); dictate("16 .r s'  : ' .");
                        type(w[i]+" ("+mytypeof(w[i])+")\n");
                    }
                    if (w.type.indexOf("colon")!=-1){
                        if(w.cfa) { // 產生一個 colon word 方法很多，不一定已經有 cfa。
                            var i = w.cfa;
                            type("\n-------- Definition in dictionary --------\n");
                            do {
                                push(i); execute(_me["(dump)"]);
                            } while (dictionary[i++] != RET);
                            type("---------- End of the definition -----------\n");
                        }
                    } else {
                        if (typeof w.xt == "function") {
                            push("xt"); dictate("16 .r s'  :\n' .");
                            type(w.xt+"\n");
                        }
                    }
                    if (w.comment != undefined) type("\ncomment:\n"+w.comment+"\n");
                }
                vm.forth.base = basewas;
                end-code
                last :: ["(dump)"]=tick("(dump)")

: see           ' (see) ; // ( <name> -- ) See definition of the word

                <selftest>
                    *** see (see)
                    marker ---
                    : test ; // test.test.test
                    js: vm.selftest_visible=false;vm.screenbuffer=""
                    see test
                    js: vm.selftest_visible=true
                    <js> vm.screenbuffer.indexOf('test.test.test') !=-1 </jsV> \ true
                    <js> vm.screenbuffer.indexOf('cfa') !=-1 </jsV> \ true
                    <js> vm.screenbuffer.indexOf('colon') !=-1 </jsV> \ true
                    [d true,true,true d] [p 'see','(see)','(?)' p]
                    ---
                </selftest>

code notpass    ( -- ) \ List words their sleftest flag are not 'pass'.
                for (var j in words) { // all word-lists
                    for (var i in words[j]) {  // all words in a word-list
                        if(i!=0 && words[j][i].selftest != 'pass') type(words[j][i].name+" ");
                    }
                }
                end-code
code passed     ( -- ) \ List words their sleftest flag are 'pass'.
                for (var j in words) { // all word-lists
                    for (var i in words[j]) {  // all words in a word-list
                        if(i!=0 && words[j][i].selftest == 'pass') type(words[j][i].name+" ");
                    }
                }
                end-code

\ ---------- xstack ----------------------------------------------------------------
[] value xstack // ( -- array ) The xstack 
: x@            xstack :> slice(-1)[0] ; // ( -- n ) Get TOS of the xstack
: x>            xstack :> pop() ; // ( -- n ) Pop the xstack
: >x            xstack :: push(pop()) ; // ( n -- ) Push n into the xstack
: .sx           char [ . xstack . char ] . cr ; // ( -- ) List xstack 
: xdrop         x> drop ; // ( X: ... a -- X: ... ) drop xstack 
: xdropall      [] to xstack ; // ( X: ... -- X: empty ) clear xstack 

                <selftest>
                *** xstack commands x@ x> >x .sx xdrop xdropall 
                    1 >x 2 >x dropall xdropall xstack js> pop().length 0= ( T )
                    4567 >x 1234 >x depth 0= ( TF ) 
                    x@ 1234 = ( TFT  )
                    x> 1234 = ( TFTT )
                    xdrop xstack js> pop().length 0= ( TFTTT )
                    [d true, false, true, true, true d]
                    [p 'x@', 'x>', '>x', '.sx', 'xdrop', 'xdropall' p]
                </selftest>

\ -------------- Debugger : set breakpoint to a colon word -------------------------

js: vm.forth.fastInner=inner \ ( -- inner ) Original inner() without breakpoint support

code be         ( -- ) \ Enable the breakPoint. See also 'bp','bd'.
                inner = vm.g.debugInner; 
                vm.jsc.enable = true;
                execute(_me["bp"]); // call by reference safer than call by name
                end-code interpret-only
                /// work with 'jsc' debug console, jsc is application dependent.
code bd         ( -- ) \ Disable breakpoint, See also 'bp','be'.
                inner = vm.forth.fastInner;
                vm.jsc.enable = false; // 需要這個 flag 因為若已經進了 debugInner, 換掉 inner 也出不來。
                end-code interpret-only
                /// work with 'jsc' debug console, jsc is application dependent.
code bp         ( <address> -- ) \ Set breakpoint in a colon word. See also 'bd','be'.
                var bp = nexttoken();
                vm.jsc.enable = true;
                if (bp) {
                    vm.jsc.bp = parseInt(bp);
                    execute(_me["be"])  // call by reference safer than call by name
                } else {
                    type("Breakpoint : " + vm.jsc.bp);
                    if (inner == vm.g.debugInner) type(", activated\n");
                    else  type(", inactive\n");
                }
                end-code interpret-only
                \ bp be look easily conflictedly reused in the future
                \ call by reference safer than call by name
                ' be :: ["bp"]=last() 
                last :: ["be"]=tick("be")
                /// If no address is given then show the recent breakPoint and 
                /// its status.
                /// work with 'jsc' debug console, jsc is application dependent.

: (*debug*)     ( msg -- ) \ Suspend to command prompt, 'q' to quit debugging.
                cr ." ---- Entering *debug* ----" cr
                [ last literal ] ( _me )
                <js>
                    var _me = pop();
                    if (_me.resume) {
                        panic("Error, already in *debug*, 'q' to resume.\n");
                    } else {
                        var tibwas=tib, ntibwas=ntib, ipwas=ip, promptwas=vm.prompt;
                        vm.prompt = pop().toString();
                        // The clue to resume from debugging
                        _me.resume = function(){
                            tib=tibwas; 
                            ntib=ntibwas; 
                            vm.prompt=promptwas;
                            outer(ipwas);
                        }
                        // ip = 0 reserve rstack, suspend the forth VM 
                        // (*debug*) must be a colon word so as to use this trick.
                        tib = ""; ntib = ip = 0; 
                    }
                </js> ;
                /// 'q' command to quit debugging
code q          ( -- ) \ Quit *debug*
                type("\n ---- Leaving *debug* ----\n");
                var q = tick("(*debug*)").resume; 
                tick("(*debug*)").resume=null; 
                q(); 
                end-code interpret-only
                
: *debug*       ( <prompt> -- resume ) \ Forth debug console. Execute the resume() to quit debugging.
                BL word compiling if literal compile (*debug*) 
                else (*debug*) then ; immediate
                /// 'q' command to quit debugging
                /// *debug* 可以用在 immediate word 裡面, 當 break 到時可能在 
                /// colon definition 的半途，此時 q 要下成 [ q ] , .s 要下成 
                /// [ .s ] ... etc

\ ----------------- Self Test -------------------------------------
: warning-on    ( -- ) \ Turn on run-time warnings 
                js: tick=vm.g.selftest_tick;execute=vm.g.selftest_execute ;
: warning-off   ( -- ) \ Turn off run-time warnings
                js: tick=vm.tick;execute=vm.execute ;
                
"" value description     ( private ) // ( -- "text" ) description of a selftest section
[] value expected_rstack ( private ) // ( -- [..] ) an array to compare rstack in selftest
[] value expected_stack  ( private ) // ( -- [..] ) an array to compare data stack in selftest
0  value test-result     ( private ) // ( -- boolean ) selftest result from [d .. d] 
[] value [all-pass]      ( private ) // ( -- ["words"] ) array of words for all-pass in selftest
: ***           ( <description> -- ) \ Start a selftest section
                CR word trim
                <js> "*** " + pop() + " ... " </jsV> to description
                depth if 
                    description . ." aborted" cr 
                    ." *** Warning, Data stack is not empty." cr
                    stop
                then ;
code all-pass   ( ["name",...] -- ) \ Pass-mark all these word's selftest flag
                var a=pop();
                for (var i in a) {
                    var w = vm.tick(a[i]); // use the original tick()
                    if(!w) panic("Error! " + a[i] + "?\n");
                    else w.selftest='pass';
                }
                end-code private
                
: [r            ( <"text"> -- ) \ Prepare an array of data to compare with rstack in selftest.
                char r] word js> eval("["+pop()+"]") to expected_rstack ;
: r]            ( -- boolean ) \ compare rstack and expected_rstack in selftest
                expected_rstack js> vm.g.isSameArray(rstack,pop()) ;
: [d            ( <"text"> -- ) \ Prepare an array to compare with data stack. End of a selftest section.
                char d] word js> eval("["+pop()+"]") to expected_stack ;
                /// Data stack will be clean after check
: d]            ( -- boolean ) \ compare data stack and expected_stack in selftest
                expected_stack js> vm.g.isSameArray(stack,pop()) to test-result 
                description . test-result if ." pass" cr dropall
                else ." fail" cr stop then ;
                /// Data stack will be clean after check
: [p            ( <"text"> -- ) \ Prepare an array ([all-pass]) of words for all-pass if test-result.
                char p] word js> eval("["+pop()+"]") to [all-pass] ; /// In selftest
: p]            ( -- boolean ) \ all-pass if test-result
                test-result if [all-pass] all-pass then ; /// In selftest
                
                \ Make these words private. Do it this way instead of at their definitions 
                \ to void selftest_tick() warnings
                ' description     :: private=true
                ' expected_rstack :: private=true
                ' expected_stack  :: private=true
                ' test-result     :: private=true
                ' [all-pass]      :: private=true

<selftest>
    *** End of kernel self-test
    [d d] [p 'accept', 'refill', '***' p]
    ~~selftest~~
</selftest>

\ jeforth.f kernel code is now common for different application. I/O may not ready enough to read 
\ selftest.f at this moment, so the below code has been moved to quit.f of each applications.
    \ Do the jeforth.f self-test only when there's no command line
    \   js> vm.argv.length 1 > \ Do we have jobs from command line?
    \   [if] \ We have jobs from command line to do. Disable self-test.
    \       js: tick('<selftest>').enabled=false
    \   [else] \ We don't have jobs from command line to do. So we do the self-test.
    \       js> tick('<selftest>').enabled=true;tick('<selftest>').buffer tib.insert
    \   [then] js: tick('<selftest>').buffer="" \ recycle the memory
