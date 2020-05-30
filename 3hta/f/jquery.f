
\ include jQuery. jQuery including moved out of jeforth.hta to avoid HTA problems 
\ from happening too early. Those problems are happening on Windows XP and Windows 7.
\ 
				
	js> typeof(jQuery)=="undefined" [if]
		char script createElement ( -- eleScript )
		dup char src char js/jquery-1.11.2.js setAttribute ( -- eleScript )
		js> document.getElementsByTagName('head')[0] swap ( -- eleHead eleScript ) appendChild

		<js>
			vm.plain = function (s) {
				// Modified in jquery.f for new type() that uses jQuery.
				var ss = s + ""; // avoid numbers to fail at s.replace()
				ss = ss.replace(/&/g,'&amp;')
				       .replace(/\t/g,' &nbsp; &nbsp;')
				       .replace(/  /g,' &nbsp;')
				       .replace(/</g,'&lt;')
				       .replace(/>/g,'&gt;')
				       .replace(/\r?\n\r?/g,'<br>');
				return ss;
			}

			vm.type = function (s) { 
				// Modified in jquery.f for new type() that uses jQuery.
				try {
					var ss = s + ''; // Print-able test
				} catch(err) {
					ss = Object.prototype.toString.apply(s);
				}
				if(vm.screenbuffer!=null) vm.screenbuffer += ss; // 填 null 就可以關掉。
				if(vm.selftest_visible) $('#outputbox').append(vm.plain(ss)); 
			};
			
			vm.consoleHandler = function (cmd) {
				// Modified in jquery.f
                if (vm.lang == 'js' || vm.lang != 'forth'){
                    type((cmd?'\n> ':"")+cmd+'\n');
                    result = eval(cmd);
                    if(result != undefined) type(result + "\n");
                    window.scrollTo(0,endofinputbox.offsetTop); inputbox.focus();
                }else{
                    var rlwas = vm.rstack().length; // r)stack l)ength was
                    vm.type((cmd?'\n> ':"")+cmd+'\n');
                    vm.dictate(cmd);  // Pass the command line to jeForth VM
                    (function retry(){
                        // rstack 平衡表示這次 command line 都完成了，這才打 'OK'。
                        // event handler 從 idle 上手，又回到 idle 不會讓別人看到它的 rstack。
                        // 雖然未 OK, 仍然可以 key in 新的 command line 且立即執行。
                        if(vm.rstack().length!=rlwas)
                            setTimeout(retry,100); 
                        else {
                            vm.type(" " + vm.prompt + " ");
                            if ($(inputbox).is(":focus")) // more accurate, Ctrl-Enter usages need this
                                vm.scroll2inputbox();
                        }
                    })();
                }
			}
			
		</js>
	[then]
