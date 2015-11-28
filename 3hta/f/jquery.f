
\ include jQuery. jQuery including moved out of jeforth.hta to avoid HTA problems 
\ from happening too early. Those problems are happening on Windows XP and Windows 7.
\ 
				
	js> typeof(jQuery)=="undefined" [if]
		char script createElement ( -- eleScript )
		dup char src char js/jquery-1.11.2.js setAttribute ( -- eleScript )
		js> document.getElementsByTagName('head')[0] swap ( -- eleHead eleScript ) appendChild

		<js>
			// replace the vm.plain() defined in jeforth.hta.
			vm.plain = function (s) {
				// redefined to use jQuery. in html5.f.
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
				// redefined to use jQuery. -- html5.f	
				try {
					var ss = s + ''; // Print-able test
				} catch(err) {
					ss = Object.prototype.toString.apply(s);
				}
				if(vm.screenbuffer!=null) vm.screenbuffer += ss; // 填 null 就可以關掉。
				if(kvm.selftest_visible) $('#outputbox').append(vm.plain(ss)); 
			};
		</js>
	[then]
