\ -------------- Tools for self-test --------------------

	variable wut // ( -- Word ) Word under test

	: ==>judge		( boolean -- boolean ) \ print 'pass'(if true) or 'failed!' and stop testing.
					if ." pass" cr wut @ js: pop().selftest='pass' true
					else ." failed!" cr wut @ js: pop().selftest='failed!' \s false then ;

	: ***			( <word> <description down to '\n'> -- ) \ Start to test a word
					BL word dup (') wut ! char \n|\r word \ name desc
					." *** " swap . space 1 sleep \ desc
					wut @ if . else drop ." unknown?" cr abort then 
					depth ?abort" *** Error! Data stack is not empty!" ;
					
	: ****			( <description down to '\n'> -- ) \ Print header of a self-test section
					s" *** " char \n|\r word + . ;

\ If html5.f has been included then selftest can show pass/faled a little better
\ therefore we may not need to use selftest-invisible command. This is good for
\ wmi.f self test. Because they are actually demos that are better to be visible.

' <o> [if]

	variable eleHeader // ( -- element ) The recent self-test header line HTML element

	: -->judge		( boolean -- boolean ) \ print 'pass'(if true) or 'failed!' and stop testing.
					if 
						eleHeader @ <js> pop().innerText+=" pass" </js>
						true
					else 
						eleHeader @ <js> pop().innerText+=" failed" </jsV>
						false js: alert(pop(1));
					then ;
					
	: *****			( <description down to '...'> -- ) \ Print header of a self-test section
					char <div> 
					s" *** " char \n|\r word							\ entire line
					<js> pop().replace(/\s*\.*\s*$/," ... ") </jsV> +	\ replace ending "...." to " ... "
					js> kvm.plain(pop()) +								\ convert HTML special characters
					char </div> + 
					</o> eleHeader ! ;
[then]				
				
code all-pass 	( ["name",...] -- ) \ Pass-mark all these word's selftest flag
				var a=pop();
				for (var i in a) {
					var w = tick(a[i]);
					if(!w) panic("Error! " + a[i] + "?\n");
					else w.selftest='pass';
				}
				end-code

js> print constant printwas // ( -- print ) Save a backup of the original print function.

code selftest-invisible 
				( -- ) \ Turn off display output 
				print=function(s){kvm.screenbuffer += s;} 
				end-code

: selftest-visible 
				( -- ) \ Turn display output back on
				printwas <js> print=pop() </js> ;
				
<comment> 
------------------------------------------------------- 
Self test sample code

		最原始的 *** 最簡單，請看範例。。。
			<selftest>
				*** int 3.14 is 3, 12.34AB is 12 ... 
				3.14 int 3 = 
				char 12.34AB int 12 =
				and
				==>judge drop \ 沒有用到時，把留給 all-pass 的線索 drop 掉。
			</selftest>

		四顆星的 **** 用在一次 test 好幾個 words 時，一定要靠 all-pass 故省掉自動打 pass/failed 。。。
			<selftest>
				marker -%-%-%-%-%-
				**** word1 word2 word3 descriptions ... \ [pass|failed] 會由 ==>judge 打上
				selftest-invisible \ 我想讓畫面整潔，self-test 的過程可以看 kvm.screenbuffer。 
				js> kvm.screenbuffer.length constant start-here // ( -- n ) 開始測試前的 kvm.screenbuffer 尾巴。
				( ------------ Start to do anything --------------- )
				( ------------ done, start checking ---------------- ) 
				start-here <js> kvm.screenbuffer.slice(pop()).indexOf("期望出現的 string")!=-1 </jsV> \ true 
				selftest-visible
				js> stack.slice(0) <js> [0x11,0x22,0x33,0x44] </jsV> isSameArray >r dropall r>
				==>judge [if] <js> [
					'word-name-1',
					'word-name-2'
				] </jsV> all-pass [else] *debug* selftest-failed->>> [then]
				-%-%-%-%-%-
			</selftest>

		五顆星的 ***** 利用 HTML5.f 可以回頭打 pass/failed 適用於不想 selftest-invisible 的場合，selftest 直接當 demo 程式 。。。
			<selftest>
				***** Selftest item description ........
				marker -%-%-%-%-%-
				js> kvm.screenbuffer.length constant start-here // ( -- n ) 開始測試前的 kvm.screenbuffer 尾巴。
				( ------------ Start to do anything --------------- )
				( ------------ done, start checking ---------------- ) 
				start-here <js> kvm.screenbuffer.slice(pop()).indexOf("期望出現的 string")!=-1 </jsV> \ true 
				js> stack.slice(0) <js> [true,11,22,33,false] </jsV> isSameArray >r dropall r>
				-->judge [if] <js> [
					'word111',
					'word222',
					'word333'
				] </jsV> all-pass [else] *debug* selftest-failed->>> [then]
				-%-%-%-%-%-
			</selftest>
			
------------------------------------------------------- 
</comment>
