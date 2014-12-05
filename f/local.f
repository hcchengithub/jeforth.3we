

	\ Define local variables (-- .... --) 
	\ [ ] for all applications?

	<comment>	
		\ Closure space variable pass down structure is a challenge to forth.
		\ Let's see, in JavaScript, I believe it's the return stack where every instance use return stack 
		\ pointer associate with variable names and pass down. Return stack has two pointers in x86 CPU sp and bp.
		\ Here, we are refering to the bp. 
		\ Local variables are in a nested structure. reDef is normal. 
		\ create : { name1 name2 name3 } moves tos(2) tos(1) tos(0) to rtos(bp-3) rtos(bp-2) rtos(bp-1) 
		\ and rtos(bp) will be the original bp. bp has no initial value. Each word who uses local variable
		\ needs to save-restore bp, why? you further call other words and you need to use your bp after the
		\ return. 
		\ usage name1 translated to js> rtos(bp-3) , "to name1" translated to js: rtos(bp-3,pop()) 

		我覺得 TSR 本身應該是個 create does> word, 類似 clock3.f 裡的「時鐘」。我有點想讓 TSR 產生 annonymous
		word 因為在 HTTP server 的情況下，不可能為每個來訪的 client 都命名。很可能全部集中到一個 array 裡去。
		這個 array 裡的每一cell 就是一個 instance of HTTP client-server connection. 那不就是 word-list 嗎？
		create-does word 一定都是 interpret mode 下 created 出來的，如果是 server 端自動產生的，則前所未見。
		先順著 Nodebeginners ebook Node.js 把習題做完看看。。。。 我覺得，forth 在這方面好像不適合 ==> [ ] 問 FigTaiwan.
	</comment>

	also forth definitions
	
	: doLocalize 	( n -- ) \ data stack to return stack, also setup the BP
					depth over < ?abort" Error! Insufficient argument."
					r> r> rot ( aa bb cc myReturn ret n ) ( R: )
					js: rstack.push(bp);bp=rstack.length-1 ( aa bb cc myReturn ret n ) ( R: bp0 )
					for ( aa bb cc myReturn ret ) ( R: bp0 n ) \ ( aa bb myReturn ret ) ( R: bp0 cc n ) 
						r> ( aa bb cc myReturn ret n ) ( R: bp0 ) \ ( aa bb myReturn ret n ) ( R: bp0 cc )  
						3 roll >r ( aa bb myReturn ret n ) ( R: bp0 cc ) \ ( aa myReturn ret n ) ( R: bp0 cc bb )  
						>r ( aa bb myReturn ret ) ( R: ... bp0 cc n ) \ ( aa myReturn ret ) ( R: bp0 cc bb n )  
					next ( myReturn ret ) ( R: ... bp0 cc bb aa )  
					( ret myReturn ) ( R: ... bp0 cc bb aa ) >r >r ( empty ) ( R: bp0 cc bb aa ret myReturn ) ;
					/// ( aa bb cc n ) ( R: ... ret ) ==> ( empty ) ( R: ... bp0 cc bb aa ret )
					\ ... [return][old bp][cc][bb][aa][return] <---- rstack TOS
					\               ^
					\               |
					\               '------ bp
					\       

	: (-- 			( <refs> -- ) \ Move input arguments to local variables in rstack
					0 begin BL word js> pop()!="--)" while 1+ repeat 
					[compile] literal compile doLocalize ; immediate compile-only
					/// 將來可以進一步把隨後所有的 token 都讀進來直到 ; （含）為止。然後把所有 token 
					/// 當中有 local variable 或 to local variable 都置換成對應的 function(){} 
					/// 清除 local variable 的 ret 程序,
					/// js: push(rstack.pop());rstack=rstack.slice(0,bp+1);bp=rstack.pop();rstack.push(pop()) ; 
					/// 要保留 local data 的 TSR 之 ret 程序，
					/// 0 >r ;
	
	previous definitions
	
	<comment>
		: sum ( aa bb cc -- sum ) \ test scenario
			(-- bp+3 bp+2 bp+1 --) 
			js> rstack[bp+3]+rstack[bp+2]+rstack[bp+1]
			\ 帶 local variable 的 ret 程序之清除 local variable 版
			js: push(rstack.pop());rstack=rstack.slice(0,bp+1);bp=rstack.pop();rstack.push(pop()) ; 

		\ -------- Definition in dictionary --------
		\ 00955: 3        (literal) (object)
		\ 00956: doLocalize ( n -- ) data stack to return stack, also setup the BP (object)
		\ 		 暫時先不認 variable name 證實無誤再來改進
		\ 00957: function (){push(rstack[bp+3]+rstack[bp+2]+rstack[bp+1])} (function)
		\ 00958: function (){bp=rstack[bp];rstack=rstack.slice(0,bp)} (function)
		\        暫時先醜一點，證實無誤再來自動化。可能是用 (-- ... --) 把 local variable 的 scope 包起來。
		\		 順便在結尾做這一段動作。
		\ 00959: ret ( -- ) Mark at the end of a colon word. (object)
		\ ---------- End of the definition -----------		
		
		\ closure 親代關係 可以用一個 local crystal object 來模擬。Crystal 指的是 super man 從家鄉帶出來
		\ 的小東西，卻蘊含整個氪星球的所有遺產。

		: show ( -- ) \ show bp+3 message
			." The message is " js> rstack[bp+3] . cr ;
			/// Caller 是 Callback function 透過 execute('show') 而來。 當時的 IP 一定是 0 因為必定是
			/// 在 waiting state。 rstack.push(IP) 是由所有 colon word 的 xt 執行的。也就是 show 自己，
			/// 而非 execute()。IP 是 0 於是 show 接地，退出 forth VM 回到 execute(), 再回到 callback
			/// function 完成 event。
			

		: tsr ( "msg" xx yy -- ) \ a tsr 
			(-- bp+3 bp+2 bp+1 --) <js> setInterval(function(){execute('show')},1000) </js> 
			( 帶 data 的 TSR 根本就不該 return ) 0 >r ( 保留 return stack ) ;

			\ 帶 local variable 的 ret 程序之保留 local variable 版 <== 這不是個好企圖，
			\ js: push(rstack.pop());rstack=rstack.slice(0,bp+1);bp=rstack.pop();rstack.push(pop()) ; 
			
			\ tsr 回到 test 沒有問題，因為 (-- ... --) 有把 tsr 自己的 ret 移到 rtos 來。但是 test
			\ return 時就會抓到 variable 區！慘了，搞半天把 return 線索提到 rtos 來不對嗎？因為多幾
			\ 層早晚就會出同樣的問題。可是如果不這麼做，連 tsr 自己的 return 都抓錯人，疑惑疑惑。
			
			\ 其實，TSR 根本就不該 destructed 否則還在執行的 TSR 怎麼取用 TSR 提供的 data？ TSR 要收
			\ 工了，才可以 destructed, e.g. the sum above, 此時 local variable 都收拾乾淨，自然就可以
			\ 正確地 return 回去了。"不該 destructed" 是指不 destroid local variables, 還是要 return 
			\ 然而要用 0 >r ; 的方式，直接回到 waiting state. 這暗示： TSR 應該是從 interpret mode 啟
			\ 動的，而非從別的 word 裡 call 過來的，否則該 caller 會被 TSR 中止，直接接地不會回去。
			
			\ 直接接地之後，rstack 雖留有 TSR 的 return address. 如果其值不是 0 那就是來源不是 interpreter
			\ 而是某 caller word, 這有點不合原則，但也不必禁止。總之該 return address 已經不知如何
			\ 才用得上了。
			
			\ ... [return][old bp][cc][bb][aa][return] <---- rstack TOS
			\               ^
			\               |
			\               '------ bp
			\       

		: test char Hi! 11 22 tsr ;

		why execute(Word) does not *eat* rtos() at ret?
		因為 colon word 的 xt 自己有 push IP。TSR trigger 時的 IP 鐵定是 0 吧！？在工作中 event 被 queue
		起來不會發生，必定是回到 waiting state 才會觸發 event 因此 IP 一定是 0.
		但是，在下例 TSR 的情形下，execute() 當時的 ip 沒有意義，到底 ip 是何值？是零。kvm.breakpoint
		設在 show entry 處，查 rstack 即知 ... 
			: tsr ( "msg" xx yy -- ) \ a tsr 
			(-- bp+3 bp+2 bp+1 --) <js> setInterval(function(){execute('show')},1000) </js> 
			( 保護 TSR 的 local data 留在 rstack 裡存活 ) 0 >r ;
		==> ip=953 jsc> rstack ==> [ 0, 0, 22, 11, 'Hi!', 969, 0 ]
									 ^  ^                   ^  ^
									 |  |                   |  |     這就是好奇想知道的 IP 值，果然是 0。
									 |  |                   |  '---- 從 waiting state 進來時，'show'.xt push 進來的 IP 值。
									 |  |                   '------- TSR 回 test 的 return address, 被棄置。
									 |  '--------------------------- bp0
									 '------------------------------ test 的 return address
		==> 如上，保護 TSR 所做的 0 >r ; 與正常 event 發生時 execute('show'), 'show'.xt 所 push 的 IP 都是
			0 ，這個一致性令人安心。
	</comment>

	